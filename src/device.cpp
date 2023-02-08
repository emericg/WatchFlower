/*!
 * This file is part of WatchFlower.
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device.h"
#include "DeviceManager.h"
#include "SettingsManager.h"
#include "DatabaseManager.h"
#include "utils_screen.h"

#include <cstdlib>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QJsonDocument>
#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

Device::Device(const QString &deviceAddr, const QString &deviceName, QObject *parent) : QObject(parent)
{
#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
    if (deviceAddr.size() != 38)
        qWarning() << "Device() '" << deviceAddr << "' is an invalid UUID...";

    QBluetoothUuid bleAddr(deviceAddr);
#else
    if (deviceAddr.size() != 17)
        qWarning() << "Device() '" << deviceAddr << "' is an invalid MAC address...";

    QBluetoothAddress bleAddr(deviceAddr);
#endif

    m_bleDevice = QBluetoothDeviceInfo(bleAddr, deviceName, 0);
    m_deviceAddress = deviceAddr;
    m_deviceName = deviceName;

    // Check address validity
    if (m_bleDevice.isValid() == false)
    {
        qWarning() << "Device() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";
    }

    // Device name hacks // Remove MAC address from device names
    {
        if (m_deviceName.startsWith("Flower power")) m_deviceName = "Flower power";
        else if (m_deviceName.startsWith("Parrot pot")) m_deviceName = "Parrot pot";

        if (m_deviceName.startsWith("6003#")) { // ex: 6003#060030393FBB1
            m_deviceAddressMAC = m_deviceName.last(12);
            for (int i = 2; i < m_deviceAddressMAC.size(); i+=3) m_deviceAddressMAC.insert(i, ':');
            m_deviceName = "WP6003";
        }
    }

    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::actionTimedout);

    // Configure RSSI timer
    m_rssiTimer.setSingleShot(true);
    m_rssiTimer.setInterval(m_rssiTimeoutInterval*1000);
    connect(&m_rssiTimer, &QTimer::timeout, this, &Device::cleanRssi);
}

Device::Device(const QBluetoothDeviceInfo &d, QObject *parent) : QObject(parent)
{
    m_bleDevice = d;
    m_deviceName = m_bleDevice.name();

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
    m_deviceAddress = m_bleDevice.deviceUuid().toString();
#else
    m_deviceAddress = m_bleDevice.address().toString();
#endif

    // Check address validity
    if (m_bleDevice.isValid() == false)
    {
        qWarning() << "Device() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";
    }

    // Device name hacks // Remove MAC address from device names
    {
        if (m_deviceName.startsWith("Flower power")) m_deviceName = "Flower power";
        else if (m_deviceName.startsWith("Parrot pot")) m_deviceName = "Parrot pot";

        if (m_deviceName.startsWith("6003#")) { // ex: 6003#060030393FBB1
            m_deviceAddressMAC = m_deviceName.last(12);
            for (int i = 2; i < m_deviceAddressMAC.size(); i+=3) m_deviceAddressMAC.insert(i, ':');
            m_deviceName = "WP6003";
        }
    }

    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::actionTimedout);

    // Configure RSSI timer
    m_rssiTimer.setSingleShot(true);
    m_rssiTimer.setInterval(m_rssiTimeoutInterval*1000);
    connect(&m_rssiTimer, &QTimer::timeout, this, &Device::cleanRssi);
}

Device::~Device()
{
    if (m_bleController)
    {
        m_bleController->disconnectFromDevice();
        delete m_bleController;
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

/*!
 * \brief Device::deviceConnect
 * \return false means immediate error, true means connection process started
 */
void Device::deviceConnect()
{
    //qDebug() << "Device::deviceConnect()" << getAddress() << getName();

    if (!m_bleController)
    {
        m_bleController = m_bleController->createCentral(m_bleDevice);
        if (m_bleController)
        {
            if (m_bleController->role() == QLowEnergyController::CentralRole)
            {
                m_bleController->setRemoteAddressType(QLowEnergyController::PublicAddress);

                // Connecting signals and slots for connecting to LE services.
                connect(m_bleController, &QLowEnergyController::connected, this, &Device::deviceConnected);
                connect(m_bleController, &QLowEnergyController::disconnected, this, &Device::deviceDisconnected);
                connect(m_bleController, &QLowEnergyController::serviceDiscovered, this, &Device::addLowEnergyService, Qt::QueuedConnection);
                connect(m_bleController, &QLowEnergyController::discoveryFinished, this, &Device::serviceScanDone, Qt::QueuedConnection); // Windows hack, see: QTBUG-80770 and QTBUG-78488
                connect(m_bleController, QOverload<QLowEnergyController::Error>::of(&QLowEnergyController::errorOccurred), this, &Device::deviceErrored);
                connect(m_bleController, &QLowEnergyController::stateChanged, this, &Device::deviceStateChanged);
            }
            else
            {
                qWarning() << "BLE controller doesn't have the QLowEnergyController::CentralRole";
                refreshDataFinished(false, false);
            }
        }
        else
        {
            qWarning() << "Unable to create BLE controller";
            refreshDataFinished(false, false);
        }
    }

    // Start the actual connection process
    if (m_bleController)
    {
        setTimeoutTimer();
        m_bleController->connectToDevice();
    }
}

void Device::deviceDisconnect()
{
    //qDebug() << "Device::deviceDisconnect()" << getAddress() << getName();

    if (m_bleController && m_bleController->state() != QLowEnergyController::UnconnectedState)
    {
        m_bleController->disconnectFromDevice();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::actionConnect()
{
    //qDebug() << "Device::actionConnect()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_IDLE;
        actionStarted();
        deviceConnect();
    }
}

/* ************************************************************************** */

void Device::actionDisconnect()
{
    //qDebug() << "Device::actionConnect()" << getAddress() << getName();

    deviceDisconnect();
}

/* ************************************************************************** */

void Device::actionScan()
{
    //qDebug() << "Device::actionScan()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_SCAN;
        actionStarted();
        deviceConnect();
    }
}

void Device::actionScanWithValues()
{
    //qDebug() << "Device::actionScanWithValues()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_SCAN_WITH_VALUES;
        actionStarted();
        deviceConnect();
    }
}

/* ************************************************************************** */

void Device::actionClearData()
{
    //qDebug() << "Device::actionClearData()" << getAddress() << getName();

    if (!isBusy())
    {
        QSqlQuery resetDeviceLastSync;
        resetDeviceLastSync.prepare("UPDATE devices SET lastSync = :sync WHERE deviceAddr = :deviceAddr");
        resetDeviceLastSync.bindValue(":sync", QDateTime().toString("yyyy-MM-dd hh:mm:ss"));
        resetDeviceLastSync.bindValue(":deviceAddr", getAddress());
        if (resetDeviceLastSync.exec())
        {
            m_lastHistorySync = QDateTime();
            Q_EMIT statusUpdated();
        }
        else
        {
            qWarning() << "> resetDeviceLastSync.exec() ERROR"
                       << resetDeviceLastSync.lastError().type() << ":" << resetDeviceLastSync.lastError().text();
        }

        QSqlQuery deleteData;
        if (isEnvironmentalSensor()) deleteData.prepare("DELETE FROM sensorData WHERE deviceAddr = :deviceAddr");
        else deleteData.prepare("DELETE FROM plantData WHERE deviceAddr = :deviceAddr");
        deleteData.bindValue(":deviceAddr", getAddress());
        if (deleteData.exec())
        {
            Q_EMIT dataUpdated();
            Q_EMIT historyUpdated();
        }
        else
        {
            qWarning() << "> deleteData.exec() ERROR"
                       << deleteData.lastError().type() << ":" << deleteData.lastError().text();
        }
    }
}

void Device::actionClearDeviceData()
{
    //qDebug() << "Device::actionClearDeviceData()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_CLEAR_HISTORY;
        actionStarted();
        deviceConnect();
    }
}

void Device::actionLedBlink()
{
    //qDebug() << "Device::actionLedBlink()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_LED_BLINK;
        actionStarted();
        deviceConnect();
    }
}

void Device::actionWatering()
{
    //qDebug() << "Device::actionWatering()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_WATERING;
        actionStarted();
        deviceConnect();
    }
}

void Device::actionCalibrate()
{
    //qDebug() << "Device::actionCalibrate()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_CALIBRATE;
        actionStarted();
        deviceConnect();
    }
}

void Device::actionReboot()
{
    //qDebug() << "Device::actionReboot()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_REBOOT;
        actionStarted();
        deviceConnect();
    }
}

void Device::actionShutdown()
{
    //qDebug() << "Device::actionShutdown()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_SHUTDOWN;
        actionStarted();
        deviceConnect();
    }
}

/* ************************************************************************** */

void Device::refreshQueued()
{
    if (m_ble_status == DeviceUtils::DEVICE_OFFLINE)
    {
        m_ble_status = DeviceUtils::DEVICE_QUEUED;
        Q_EMIT statusUpdated();
    }
}

void Device::refreshDequeued()
{
    if (m_ble_status == DeviceUtils::DEVICE_QUEUED)
    {
        m_ble_status = DeviceUtils::DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

void Device::refreshStart()
{
    //qDebug() << "Device::refreshStart()" << getAddress() << getName() << "/ last update: " << getLastUpdateInt();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_UPDATE;
        actionStarted();
        deviceConnect();
    }
}

void Device::refreshStartHistory()
{
    //qDebug() << "Device::refreshStartHistory()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_UPDATE_HISTORY;
        actionStarted();
        deviceConnect();
    }
}

void Device::refreshStartRealtime()
{
    //qDebug() << "Device::refreshStartRealtime()" << getAddress() << getName();

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_UPDATE_REALTIME;
        actionStarted();
        deviceConnect();
    }
}

void Device::refreshStop()
{
    //qDebug() << "Device::refreshStop()" << getAddress() << getName();

    if (m_bleController && m_bleController->state() != QLowEnergyController::UnconnectedState)
    {
        m_bleController->disconnectFromDevice();
    }

    if (m_ble_status != DeviceUtils::DEVICE_OFFLINE)
    {
        m_ble_status = DeviceUtils::DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

void Device::actionCanceled()
{
    //qDebug() << "Device::actionCanceled()" << getAddress() << getName();

    if (m_bleController)
    {
        m_bleController->disconnectFromDevice();
    }

    refreshDataFinished(false);
}

void Device::actionTimedout()
{
    //qDebug() << "Device::actionTimedout()" << getAddress() << getName();

    if (m_bleController)
    {
        m_bleController->disconnectFromDevice();
    }

    refreshDataFinished(false);
}

void Device::refreshRetry()
{
    //qDebug() << "Device::refreshRetry()" << getAddress() << getName();
}

/* ************************************************************************** */

void Device::actionStarted()
{
    //qDebug() << "Device::actionStarted()" << getAddress() << getName();

    m_ble_status = DeviceUtils::DEVICE_CONNECTING;
    Q_EMIT statusUpdated();
}

void Device::refreshDataFinished(bool status, bool cached)
{
    //qDebug() << "Device::refreshDataFinished()" << getAddress() << getName();

    m_timeoutTimer.stop();

    m_ble_status = DeviceUtils::DEVICE_OFFLINE;
    Q_EMIT statusUpdated();

    if (status == true)
    {
        // Only update data on success
        Q_EMIT dataUpdated();

        // Reset last error
        m_lastError = QDateTime();
        Q_EMIT statusUpdated();

        if (m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            Q_EMIT refreshUpdated();
        }
        else if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            Q_EMIT historyUpdated();
        }
    }
    else
    {
        // Set last error (if coming from BLE)
        if (!cached)
        {
            m_lastError = QDateTime::currentDateTime();
            Q_EMIT statusUpdated();
        }
    }

    checkDataAvailability();

    // Inform device manager (if coming from BLE)
    if (!cached)
    {
        if (m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            Q_EMIT deviceUpdated(this);
        }
        else if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            Q_EMIT deviceSynced(this);
        }
    }
}

void Device::refreshHistoryFinished(bool status)
{
    //qDebug() << "Device::refreshHistoryFinished()" << getAddress() << getName();

    m_timeoutTimer.stop();

    m_ble_status = DeviceUtils::DEVICE_OFFLINE;
    Q_EMIT statusUpdated();

    if (status == true)
    {
        // TODO // Update 'last' data on success
    }

    // Even if the status is false, we probably have some new data
    Q_EMIT dataUpdated();
    Q_EMIT historyUpdated();

    checkDataAvailability();

    // Inform device manager
    Q_EMIT deviceSynced(this);
}

void Device::refreshRealtime()
{
    //qDebug() << "Device::refreshRealtime()" << getAddress() << getName();

    Q_EMIT dataUpdated();
    Q_EMIT realtimeUpdated();
}

void Device::refreshRealtimeFinished()
{
    //qDebug() << "Device::refreshRealtimeFinished()" << getAddress() << getName();

    m_timeoutTimer.stop();

    m_ble_status = DeviceUtils::DEVICE_OFFLINE;
    Q_EMIT statusUpdated();
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::setTimeoutTimer()
{
    m_timeoutTimer.setInterval(m_timeoutInterval*1000);
    m_timeoutTimer.start();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::getSqlDeviceInfos()
{
    //qDebug() << "Device::getSqlDeviceInfos(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery getInfos;
        getInfos.prepare("SELECT deviceModel, deviceFirmware, deviceBattery," \
                           "deviceAddrMAC," \
                           "associatedName, locationName," \
                           "lastSeen, lastSync," \
                           "isEnabled, isOutside," \
                           "manualOrderIndex," \
                           "settings " \
                         "FROM devices WHERE deviceAddr = :deviceAddr");
        getInfos.bindValue(":deviceAddr", getAddress());
        if (getInfos.exec())
        {
            while (getInfos.next())
            {
                m_deviceModel = getInfos.value(0).toString();
                m_deviceFirmware = getInfos.value(1).toString();
                m_deviceBattery = getInfos.value(2).toInt();

                m_deviceAddressMAC = getInfos.value(3).toString();

                m_associatedName = getInfos.value(4).toString();
                m_locationName = getInfos.value(5).toString();

                m_lastHistorySeen = getInfos.value(6).toDateTime();
                m_lastHistorySync = getInfos.value(7).toDateTime();

                if (!getInfos.value(8).isNull())
                    m_isEnabled = getInfos.value(8).toBool();
                if (!getInfos.value(9).isNull())
                    m_isOutside = getInfos.value(9).toBool();

                if (!getInfos.value(10).isNull())
                    m_manualOrderIndex = getInfos.value(10).toInt();

                QString settings = getInfos.value(11).toString();
                QJsonDocument doc = QJsonDocument::fromJson(settings.toUtf8());
                if (!doc.isNull() && doc.isObject())
                {
                    m_additionalSettings = doc.object();
                }

                status = true;
                Q_EMIT batteryUpdated();
                Q_EMIT sensorUpdated();
                Q_EMIT settingsUpdated();
            }
        }
        else
        {
            qWarning() << "> getInfos.exec() ERROR"
                       << getInfos.lastError().type() << ":" << getInfos.lastError().text();
        }
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::isErrored() const
{
    return (getLastErrorInt() >= 0 && getLastErrorInt() <= 5);
}

bool Device::isBusy() const
{
    return (m_ble_status >= DeviceUtils::DEVICE_CONNECTING);
}

bool Device::isConnected() const
{
    return (m_ble_status >= DeviceUtils::DEVICE_CONNECTED);
}

bool Device::isWorking() const
{
    return (m_ble_status == DeviceUtils::DEVICE_WORKING);
}

bool Device::isUpdating() const
{
    return (m_ble_status >= DeviceUtils::DEVICE_UPDATING);
}

/* ************************************************************************** */

QDateTime Device::getDeviceUptime() const
{
    if (m_device_time > 0)
    {
        return QDateTime::fromSecsSinceEpoch(QDateTime::currentDateTime().toSecsSinceEpoch() - m_device_time);
    }

    return QDateTime();
}

float Device::getDeviceUptime_days() const
{
    float days = 0;

    if (m_device_time > 0)
    {
        days = (m_device_time / 3600.f / 24.f);
        if (days < 0.f) days = 0.f;
    }

    return days;
}

QDateTime Device::getLastUpdate() const
{
    return m_lastUpdate;
}

QDateTime Device::getLastHistorySync() const
{
    return m_lastHistorySync;
}

int Device::getLastHistorySync_int() const
{
    if (m_lastHistorySync.isValid())
        return QDateTime::currentDateTime().toSecsSinceEpoch() - m_lastHistorySync.toSecsSinceEpoch();

    return -1;
}

float Device::getLastHistorySync_days() const
{
    int64_t sec = QDateTime::currentDateTime().toSecsSinceEpoch() - m_lastHistorySync.toSecsSinceEpoch();

    float days = (sec / 3600.f / 24.f);
    if (days < 0.f) days = 0.f;

    return days;
}

int Device::getHistoryUpdatePercent() const
{
    return -1;
}

/* ************************************************************************** */

void Device::checkDataAvailability()
{
    //
}

bool Device::needsUpdateRt() const
{
    return false;
}

bool Device::needsUpdateDb() const
{
    return false;
}

bool Device::needsUpdateDb_mini() const
{
    return false;
}

bool Device::needsSync() const
{
    return false;
}

/* ************************************************************************** */

int Device::getLastUpdateInt() const
{
    int mins = -1;

    if (m_lastUpdate.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastUpdate.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two updates...
            qWarning() << "getLastUpdateInt() has a negative value (" << mins << "). Clock mismatch?";

            // TODO start by a modulo 60?
            mins = std::abs(mins);
        }
    }

    return mins;
}

QString Device::getLastUpdateString() const
{
    QString lastUpdate;

    if (m_lastUpdate.isValid())
    {
        // Return timestamp (HH:MM) of last update
        //lastUpdate = m_lastUpdate.toString("HH:MM");

        // Return number of hours or minutes since last update
        int mins = getLastUpdateInt();
        if (mins > 0)
        {
            if (mins < 60) {
                lastUpdate = tr("%n minute(s)", "", mins);
            } else {
                lastUpdate = tr("%n hour(s)", "", std::floor(mins / 60.0));
            }
        }
    }

    return lastUpdate;
}

int Device::getLastUpdateDbInt() const
{
    int mins = -1;

    if (m_lastUpdateDatabase.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastUpdateDatabase.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two updates...
            qWarning() << "getLastUpdateDbInt() has a negative value (" << mins << ") for device" << m_deviceName << ". Clock mismatch?";

            // TODO start by a modulo 60?
            mins = std::abs(mins);
        }
    }

    return mins;
}

int Device::getLastErrorInt() const
{
    int mins = -1;

    if (m_lastError.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastError.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two errors...
            qWarning() << "getLastErrorInt() has a negative value (" << mins << ") for device" << m_deviceName << ". Clock mismatch?";

            // TODO start by a modulo 60?
            mins = std::abs(mins);
        }
    }

    return mins;
}

/* ************************************************************************** */

void Device::setLocationName(const QString &name)
{
    //qDebug() << "setLocationName(" << name << ")";

    if (m_locationName != name)
    {
        m_locationName = name;
        Q_EMIT settingsUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateLocation;
            updateLocation.prepare("UPDATE devices SET locationName = :name WHERE deviceAddr = :deviceAddr");
            updateLocation.bindValue(":name", name);
            updateLocation.bindValue(":deviceAddr", getAddress());
            updateLocation.exec();
        }

        if (SettingsManager::getInstance()->getOrderBy() == "location")
        {
            if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
        }
    }
}

void Device::setAssociatedName(const QString &name)
{
    //qDebug() << "setAssociatedName(" << name << ")";

    if (m_associatedName != name)
    {
        m_associatedName = name;
        Q_EMIT settingsUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateName;
            updateName.prepare("UPDATE devices SET associatedName = :name WHERE deviceAddr = :deviceAddr");
            updateName.bindValue(":name", name);
            updateName.bindValue(":deviceAddr", getAddress());
            updateName.exec();
        }

        if (SettingsManager::getInstance()->getOrderBy() == "plant")
        {
            if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
        }
    }
}

bool Device::hasAddressMAC() const
{
#if !defined(Q_OS_MACOS) && !defined(Q_OS_IOS)
    return true;
#endif

    if (m_deviceAddressMAC.isEmpty())
        return false;

    return true;
}

QString Device::getAddressMAC() const
{
#if !defined(Q_OS_MACOS) && !defined(Q_OS_IOS)
    return m_deviceAddress;
#endif

    return m_deviceAddressMAC;
}

void Device::setAddressMAC(const QString &mac)
{
    //qDebug() << "setAddressMAC(" << mac << ")";

    if (m_deviceAddressMAC != mac)
    {
        m_deviceAddressMAC = mac;
        Q_EMIT settingsUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateMAC;
            updateMAC.prepare("UPDATE devices SET deviceAddrMAC = :mac WHERE deviceAddr = :deviceAddr");
            updateMAC.bindValue(":mac", mac);
            updateMAC.bindValue(":deviceAddr", getAddress());
            updateMAC.exec();
        }
    }
}

void Device::setEnabled(const bool enabled)
{
    //qDebug() << "setEnabled(" << enabled << ")";

    if (m_isEnabled != enabled)
    {
        m_isEnabled = enabled;
        Q_EMIT settingsUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateEnabled;
            updateEnabled.prepare("UPDATE devices SET isEnabled = :enabled WHERE deviceAddr = :deviceAddr");
            updateEnabled.bindValue(":enabled", enabled);
            updateEnabled.bindValue(":deviceAddr", getAddress());
            updateEnabled.exec();
        }
    }
}

void Device::setInside(const bool inside)
{
    setOutside(!inside);
}

void Device::setOutside(const bool outside)
{
    //qDebug() << "setOutside(" << outside << ")";

    if (m_isOutside != outside)
    {
        m_isOutside = outside;
        Q_EMIT settingsUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateOutside;
            updateOutside.prepare("UPDATE devices SET isOutside = :outside WHERE deviceAddr = :deviceAddr");
            updateOutside.bindValue(":outside", outside);
            updateOutside.bindValue(":deviceAddr", getAddress());
            updateOutside.exec();
        }
    }
}

/* ************************************************************************** */

bool Device::hasSetting(const QString &key) const
{
    //qDebug() << "Device::hasSetting(" << key << ")";

    return !m_additionalSettings.value(key).isUndefined();
}

QVariant Device::getSetting(const QString &key) const
{
    //qDebug() << "Device::getSetting(" << key << ")";

    return m_additionalSettings.value(key);
}

bool Device::setSetting(const QString &key, QVariant value)
{
    //qDebug() << "Device::setSetting(" << key << value << ")";
    bool status = false;

    if (m_additionalSettings.value(key) != value)
    {
        m_additionalSettings.insert(key, value.toString());
        Q_EMIT settingsUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QJsonDocument json(m_additionalSettings);
            QString json_str = QString(json.toJson());

            QSqlQuery updateSettings;
            updateSettings.prepare("UPDATE devices SET settings = :settings WHERE deviceAddr = :deviceAddr");
            updateSettings.bindValue(":settings", json_str);
            updateSettings.bindValue(":deviceAddr", getAddress());

            status = updateSettings.exec();
            if (!status)
            {
                qWarning() << "> updateSettings.exec() ERROR"
                           << updateSettings.lastError().type() << ":" << updateSettings.lastError().text();
            }
        }
    }

    return status;
}

/* ************************************************************************** */

void Device::setName(const QString &name)
{
    if (!name.isEmpty())
    {
        if (m_deviceName != name)
        {
            m_deviceName = name;
            Q_EMIT sensorUpdated();
        }
    }
}

void Device::setModel(const QString &model)
{
    if (!model.isEmpty() && m_deviceModel != model)
    {
        m_deviceModel = model;
        Q_EMIT sensorUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery setModel;
            setModel.prepare("UPDATE devices SET deviceModel = :model WHERE deviceAddr = :deviceAddr");
            setModel.bindValue(":model", m_deviceModel);
            setModel.bindValue(":deviceAddr", getAddress());

            if (setModel.exec() == false)
            {
                qWarning() << "> setModel.exec() ERROR"
                           << setModel.lastError().type() << ":" << setModel.lastError().text();
            }
        }
    }
}

void Device::setModelID(const QString &modelID)
{
    if (!modelID.isEmpty() && m_deviceModel != modelID)
    {
        m_deviceModelID = modelID;
        Q_EMIT sensorUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery setModelID;
            setModelID.prepare("UPDATE devices SET deviceModel = :model WHERE deviceAddr = :deviceAddr");
            setModelID.bindValue(":model", m_deviceModelID);
            setModelID.bindValue(":deviceAddr", getAddress());

            if (setModelID.exec() == false)
            {
                qWarning() << "> setModelID.exec() ERROR"
                           << setModelID.lastError().type() << ":" << setModelID.lastError().text();
            }
        }
    }
}

void Device::setFirmware(const QString &firmware)
{
    if (!firmware.isEmpty() && m_deviceFirmware != firmware)
    {
        m_deviceFirmware = firmware;
        Q_EMIT sensorUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery setFirmware;
            setFirmware.prepare("UPDATE devices SET deviceFirmware = :firmware WHERE deviceAddr = :deviceAddr");
            setFirmware.bindValue(":firmware", m_deviceFirmware);
            setFirmware.bindValue(":deviceAddr", getAddress());

            if (setFirmware.exec() == false)
            {
                qWarning() << "> setFirmware.exec() ERROR"
                           << setFirmware.lastError().type() << ":" << setFirmware.lastError().text();
            }
        }
    }
}

void Device::setBattery(const int battery)
{
    if (battery > 0 && battery <= 100)
    {
        if (!hasBatteryLevel())
        {
            m_deviceCapabilities |= DeviceUtils::DEVICE_BATTERY;
            Q_EMIT capabilitiesUpdated();
        }

        if (m_deviceBattery != battery)
        {
            m_deviceBattery = battery;
            Q_EMIT batteryUpdated();

            if (m_dbInternal || m_dbExternal)
            {
                QSqlQuery setBattery;
                setBattery.prepare("UPDATE devices SET deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                setBattery.bindValue(":battery", m_deviceBattery);
                setBattery.bindValue(":deviceAddr", getAddress());

                if (setBattery.exec() == false)
                {
                    qWarning() << "> setBattery.exec() ERROR"
                               << setBattery.lastError().type() << ":" << setBattery.lastError().text();
                }
            }
        }
    }
}

void Device::setBatteryFirmware(const int battery, const QString &firmware)
{
    bool changes = false;

    if (battery > 0 && battery <= 100 && m_deviceBattery != battery)
    {
        m_deviceBattery = battery;
        Q_EMIT batteryUpdated();
        changes = true;
    }
    if (!firmware.isEmpty() && m_deviceFirmware != firmware)
    {
        m_deviceFirmware = firmware;
        Q_EMIT sensorUpdated();
        changes = true;
    }

    if ((m_dbInternal || m_dbExternal) && changes)
    {
        QSqlQuery setBatteryFirmware;
        setBatteryFirmware.prepare("UPDATE devices SET deviceBattery = :battery, deviceFirmware = :firmware WHERE deviceAddr = :deviceAddr");
        setBatteryFirmware.bindValue(":battery", m_deviceBattery);
        setBatteryFirmware.bindValue(":firmware", m_deviceFirmware);
        setBatteryFirmware.bindValue(":deviceAddr", getAddress());

        if (setBatteryFirmware.exec() == false)
        {
            qWarning() << "> setBatteryFirmware.exec() ERROR"
                       << setBatteryFirmware.lastError().type() << ":" << setBatteryFirmware.lastError().text();
        }
    }
}

/* ************************************************************************** */

void Device::setCoreConfiguration(const int bleconf)
{
    //qDebug() << "Device::setCoreConfiguration(" << bleconf << ")";

    if (bleconf > 0)
    {
        if (m_bluetoothCoreConfiguration != bleconf && m_bluetoothCoreConfiguration != 3)
        {
            if (m_bluetoothCoreConfiguration == 1 && bleconf == 2) m_bluetoothCoreConfiguration = 3;
            else if (m_bluetoothCoreConfiguration == 2 && bleconf == 1) m_bluetoothCoreConfiguration = 3;
            else m_bluetoothCoreConfiguration = bleconf;

            Q_EMIT advertisementUpdated();
        }
    }
}

void Device::setDeviceClass(const int major, const int minor, const int service)
{
    //qDebug() << "Device::setDeviceClass() " << info.name() << info.address() << info.minorDeviceClass() << info.majorDeviceClass() << info.serviceClasses();

    if (m_major != major || m_minor != minor || m_service != service)
    {
        m_major = major;
        m_minor = minor;
        m_service = service;

        Q_EMIT advertisementUpdated();
    }
}

/* ************************************************************************** */

void Device::setRssi(const int rssi)
{
    if (m_rssiMin > rssi)
    {
        m_rssiMin = rssi;
    }
    if (m_rssiMax < rssi)
    {
        m_rssiMax = rssi;
    }

    if (m_rssi != rssi)
    {
        m_rssi = rssi;
        Q_EMIT rssiUpdated();
    }
    m_rssiTimer.start();
}

void Device::cleanRssi()
{
    m_rssi = std::abs(m_rssi);
    Q_EMIT rssiUpdated();
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::deviceConnected()
{
    //qDebug() << "Device::deviceConnected(" << m_deviceAddress << ")";

    m_ble_status = DeviceUtils::DEVICE_CONNECTED;

    if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME ||
        m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
        // Keep screen on
        UtilsScreen *utilsScreen = UtilsScreen::getInstance();
        if (utilsScreen) utilsScreen->keepScreenOn(true);
#endif
        // Stop timeout timer, we'll be long...
        m_timeoutTimer.stop();
    }
    else if (m_ble_action == DeviceUtils::ACTION_IDLE)
    {
        // Stop timeout timer, we'll stay connected...
        m_timeoutTimer.stop();
    }
    else
    {
        // Restart for an additional 10s+?
        setTimeoutTimer();
    }

    if (m_ble_action == DeviceUtils::ACTION_UPDATE)
    {
        m_ble_status = DeviceUtils::DEVICE_UPDATING;
    }
    else if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
    {
        m_ble_status = DeviceUtils::DEVICE_UPDATING_REALTIME;
    }
    else if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
        m_ble_status = DeviceUtils::DEVICE_UPDATING_HISTORY;
    }
    else if (m_ble_action == DeviceUtils::ACTION_SCAN ||
             m_ble_action == DeviceUtils::ACTION_SCAN_WITH_VALUES)
    {
        m_ble_status = DeviceUtils::DEVICE_WORKING;
    }
    else if (m_ble_action == DeviceUtils::ACTION_LED_BLINK ||
             m_ble_action == DeviceUtils::ACTION_CLEAR_HISTORY||
             m_ble_action == DeviceUtils::ACTION_WATERING)
    {
        m_ble_status = DeviceUtils::DEVICE_WORKING;
    }

    Q_EMIT connected();
    Q_EMIT statusUpdated();

    m_bleController->discoverServices();
}

void Device::deviceDisconnected()
{
    //qDebug() << "Device::deviceDisconnected(" << m_deviceAddress << ")";

    Q_EMIT disconnected();

    if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME ||
        m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
        UtilsScreen *utilsScreen = UtilsScreen::getInstance();
        if (utilsScreen) utilsScreen->keepScreenOn(false);
#endif
    }

    if (m_ble_status == DeviceUtils::DEVICE_UPDATING)
    {
        // This means we got forcibly disconnected by the device before completing the update
        refreshDataFinished(false);
    }
    else if (m_ble_status == DeviceUtils::DEVICE_UPDATING_HISTORY)
    {
        // This means we got forcibly disconnected by the device before completing the history sync
        refreshHistoryFinished(false);
    }
    else if (m_ble_status == DeviceUtils::DEVICE_UPDATING_REALTIME)
    {
        refreshRealtimeFinished();
    }
    else
    {
        m_ble_status = DeviceUtils::DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

void Device::deviceErrored(QLowEnergyController::Error error)
{
    if (error <= QLowEnergyController::NoError) return;
    qWarning() << "Device::deviceErrored(" << m_deviceAddress << ") error:" << error;
/*
    QLowEnergyController::NoError	0	No error has occurred.
    QLowEnergyController::UnknownError	1	An unknown error has occurred.
    QLowEnergyController::UnknownRemoteDeviceError	2	The remote Bluetooth Low Energy device with the address passed to the constructor of this class cannot be found.
    QLowEnergyController::NetworkError	3	The attempt to read from or write to the remote device failed.
    QLowEnergyController::InvalidBluetoothAdapterError	4	The local Bluetooth device with the add…  QLowEnergyController::AdvertisingError (since Qt 5.7)	6	The attempt to start advertising failed.
    QLowEnergyController::RemoteHostClosedError (since Qt 5.10)	7	The remote device closed the connection.
    QLowEnergyController::AuthorizationError (since Qt 5.14)	8	The local Bluetooth device closed the connection due to insufficient authorization.
    QLowEnergyController::MissingPermissionsError (since Qt 6.4)	9	The operating system requests permissions which were not granted by the user.
*/
    m_lastError = QDateTime::currentDateTime();
    refreshDataFinished(false);
}

void Device::deviceStateChanged(QLowEnergyController::ControllerState)
{
    //qDebug() << "Device::deviceStateChanged(" << m_deviceAddress << ") state:" << state;
}

/* ************************************************************************** */

void Device::addLowEnergyService(const QBluetoothUuid &)
{
    //qDebug() << "Device::addLowEnergyService(" << uuid.toString() << ")";
}

void Device::serviceDetailsDiscovered(QLowEnergyService::ServiceState)
{
    //qDebug() << "Device::serviceDetailsDiscovered(" << m_deviceAddress << ")";
}

void Device::serviceScanDone()
{
    //qDebug() << "Device::serviceScanDone(" << m_deviceAddress << ")";
}

/* ************************************************************************** */

void Device::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleWriteDone(" << m_deviceAddress << ")";
}

void Device::bleReadDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleReadDone(" << m_deviceAddress << ")";
}

void Device::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleReadNotify(" << m_deviceAddress << ")";
}

/* ************************************************************************** */

void Device::parseAdvertisementData(const uint16_t, const uint16_t, const QByteArray &)
{
    //qDebug() << "Device::parseAdvertisementData(" << m_deviceAddress << ")";
}

/* ************************************************************************** */
