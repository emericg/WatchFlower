/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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
#include "SettingsManager.h"
#include "DeviceManager.h"
#include "NotificationManager.h"
#include "utils/utils_versionchecker.h"

#include <cstdlib>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>
#include <QJsonDocument>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

Device::Device(QString &deviceAddr, QString &deviceName, QObject *parent) : QObject(parent)
{
#if defined(Q_OS_OSX) || defined(Q_OS_IOS)
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

    // Device name hack // Remove MAC address from device name
    if (m_deviceName.startsWith("Flower power")) m_deviceName = "Flower power";
    else if (m_deviceName.startsWith("Parrot pot")) m_deviceName = "Parrot pot";
    else if (m_deviceName.startsWith("6003#")) m_deviceName = "WP6003";

    if (m_bleDevice.isValid() == false)
        qWarning() << "Device() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::refreshDataCanceled);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &Device::refreshStart);

    m_rssiTimer.setSingleShot(true);
    m_rssiTimer.setInterval(10*1000); // 10s
    connect(&m_rssiTimer, &QTimer::timeout, this, &Device::cleanRssi);
}

Device::Device(const QBluetoothDeviceInfo &d, QObject *parent) : QObject(parent)
{
    m_bleDevice = d;
    m_deviceName = m_bleDevice.name();

    // Device name hack // Remove MAC address from device name
    if (m_deviceName.startsWith("Flower power")) m_deviceName = "Flower power";
    else if (m_deviceName.startsWith("Parrot pot")) m_deviceName = "Parrot pot";
    else if (m_deviceName.startsWith("6003#")) m_deviceName = "WP6003";

#if defined(Q_OS_OSX) || defined(Q_OS_IOS)
    m_deviceAddress = m_bleDevice.deviceUuid().toString();
#else
    m_deviceAddress = m_bleDevice.address().toString();
#endif

    if (m_bleDevice.isValid() == false)
        qWarning() << "Device() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";
}

Device::~Device()
{
    delete controller;
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::deviceConnect()
{
    qDebug() << "Device::deviceConnect()" << getAddress() << getName();

    if (!controller)
    {
        controller = new QLowEnergyController(m_bleDevice);
        if (controller)
        {
            if (controller->role() == QLowEnergyController::CentralRole)
            {
                controller->setRemoteAddressType(QLowEnergyController::PublicAddress);

                // Connecting signals and slots for connecting to LE services.
                connect(controller, &QLowEnergyController::connected, this, &Device::deviceConnected);
                connect(controller, &QLowEnergyController::disconnected, this, &Device::deviceDisconnected);
                connect(controller, &QLowEnergyController::serviceDiscovered, this, &Device::addLowEnergyService, Qt::QueuedConnection);
                connect(controller, &QLowEnergyController::discoveryFinished, this, &Device::serviceScanDone, Qt::QueuedConnection); // Windows hack, see: QTBUG-80770 and QTBUG-78488
                connect(controller, QOverload<QLowEnergyController::Error>::of(&QLowEnergyController::error), this, &Device::errorReceived);
                connect(controller, &QLowEnergyController::stateChanged, this, &Device::stateChanged);
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

    if (controller)
    {
        setTimeoutTimer();
        controller->connectToDevice();
    }
}

void Device::deviceDisconnect()
{
    qDebug() << "Device::deviceDisconnect()" << getAddress() << getName();

    if (controller)
    {
        controller->disconnectFromDevice();
    }
}

/* ************************************************************************** */

void Device::actionClearHistory()
{
    //qDebug() << "Device::actionClearHistory()" << getAddress() << getName();

    if (!isUpdating())
    {
        m_ble_action = DeviceUtils::ACTION_CLEAR_HISTORY;
        refreshDataStarted();
        getBleData();
    }
}

void Device::actionLedBlink()
{
    //qDebug() << "Device::actionLedBlink()" << getAddress() << getName();

    if (!isUpdating())
    {
        m_ble_action = DeviceUtils::ACTION_LED_BLINK;
        refreshDataStarted();
        getBleData();
    }
}

void Device::actionWatering()
{
    //qDebug() << "Device::actionWatering()" << getAddress() << getName();

    if (!isUpdating())
    {
        m_ble_action = DeviceUtils::ACTION_WATERING;
        refreshDataStarted();
        getBleData();
    }
}

/* ************************************************************************** */

void Device::refreshQueue()
{
    if (m_status == DeviceUtils::DEVICE_OFFLINE)
    {
        m_status = DeviceUtils::DEVICE_QUEUED;
        Q_EMIT statusUpdated();
    }
}

void Device::refreshStart()
{
    //qDebug() << "Device::refreshStart()" << getAddress() << getName() << "/ last update: " << getLastUpdateInt();

    if (!isUpdating())
    {
        m_retries = 1;
        m_ble_action = DeviceUtils::ACTION_UPDATE;
        refreshDataStarted();
        getBleData();
    }
}

void Device::refreshHistoryStart()
{
    //qDebug() << "Device::refreshHistoryStart()" << getAddress() << getName();

    if (!isUpdating())
    {
        m_ble_action = DeviceUtils::ACTION_UPDATE_HISTORY;
        refreshDataStarted();
        getBleData();
    }
}

void Device::refreshStop()
{
    //qDebug() << "Device::refreshStop()" << getAddress() << getName();

    if (controller && controller->state() != QLowEnergyController::UnconnectedState)
    {
        controller->disconnectFromDevice();
    }

    if (m_updating || m_status != DeviceUtils::DEVICE_OFFLINE)
    {
        m_updating = false;
        m_status = DeviceUtils::DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

void Device::refreshDataCanceled()
{
    //qDebug() << "Device::refreshDataCanceled()" << getAddress() << getName();

    if (controller)
    {
        controller->disconnectFromDevice();

        m_lastError = QDateTime::currentDateTime();
    }

    refreshDataFinished(false);
}

void Device::refreshRetry()
{
    //qDebug() << "Device::refreshRetry()" << getAddress() << getName();
/*
    if (controller)
    {
        m_retries--;
        if (m_retries > 0)
        {
            controller->disconnectFromDevice();

            //connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::refreshDataCanceled);

            m_timeoutTimer.start();
            controller->connectToDevice();
        }
        else
        {
            refreshDataCanceled();
        }
    }
*/
}

/* ************************************************************************** */

void Device::refreshDataStarted()
{
    //qDebug() << "Device::refreshDataStarted()" << getAddress() << getName();

    m_updating = true;
    m_status = DeviceUtils::DEVICE_CONNECTING;
    Q_EMIT statusUpdated();
}

void Device::refreshDataFinished(bool status, bool cached)
{
    //qDebug() << "Device::refreshDataFinished()" << getAddress() << getName();

    m_timeoutTimer.stop();

    m_updating = false;
    m_status = DeviceUtils::DEVICE_OFFLINE;
    Q_EMIT statusUpdated();

    if (status == true)
    {
        // Only update data on success
        Q_EMIT dataUpdated();

        // Reset update timer
        setUpdateTimer();

        // Reset last error
        m_lastError = QDateTime();
    }
    else
    {
        // Set error timer value
        setUpdateTimer(ERROR_UPDATE_INTERVAL);
    }

    // Inform device manager
    if (!cached)
        Q_EMIT deviceUpdated(this);
}

void Device::refreshHistoryFinished(bool status)
{
    //qDebug() << "Device::refreshHistoryFinished()" << getAddress() << getName();

    m_timeoutTimer.stop();

    m_updating = false;
    m_status = DeviceUtils::DEVICE_OFFLINE;
    Q_EMIT statusUpdated();

    // Even if the status is false, we probably have some new data
    Q_EMIT dataUpdated();
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::setUpdateTimer(int updateInterval)
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return; // we do not update every x hours on mobile, we update everytime the app is on the foreground
#endif

    // If no interval is provided, load the one from settings
    if (updateInterval <= 0)
    {
        SettingsManager *sm = SettingsManager::getInstance();

        if (getDeviceType() == DeviceUtils::DEVICE_PLANTSENSOR)
            updateInterval = sm->getUpdateIntervalPlant();
        else
            updateInterval = sm->getUpdateIntervalThermo();
    }

    // Validate the interval
    if (updateInterval < 5 || updateInterval > 120)
    {
        if (getDeviceType() == DeviceUtils::DEVICE_PLANTSENSOR)
            updateInterval = PLANT_UPDATE_INTERVAL;
        else
            updateInterval = THERMO_UPDATE_INTERVAL;
    }

    // Is our timer already set to this particular interval?
    if (m_updateTimer.interval() != updateInterval*60*1000)
    {
        m_updateTimer.setInterval(updateInterval*60*1000);
        m_updateTimer.start();
    }
}

void Device::setTimeoutTimer()
{
    m_timeoutTimer.setInterval(m_timeoutInterval*1000);
    m_timeoutTimer.start();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::getSqlInfos()
{
    //qDebug() << "Device::getSqlInfos(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery getInfos;
        getInfos.prepare("SELECT deviceModel, deviceFirmware, deviceBattery, associatedName, locationName, lastSync, isOutside, settings" \
                         " FROM devices WHERE deviceAddr = :deviceAddr");
        getInfos.bindValue(":deviceAddr", getAddress());
        if (getInfos.exec())
        {
            while (getInfos.next())
            {
                m_deviceModel = getInfos.value(0).toString();
                m_deviceFirmware = getInfos.value(1).toString();
                m_deviceBattery = getInfos.value(2).toInt();
                m_associatedName = getInfos.value(3).toString();
                m_locationName = getInfos.value(4).toString();
                m_lastSync = getInfos.value(5).toDateTime();
                //m_manualOrderIndex = 0; // TODO
                m_isOutside = getInfos.value(6).toBool();

                QString settings = getInfos.value(7).toString();
                QJsonDocument doc = QJsonDocument::fromJson(settings.toUtf8());
                if (!doc.isNull() && doc.isObject())
                {
                    m_additionalSettings = doc.object();
                }

                status = true;
                Q_EMIT sensorUpdated();
                Q_EMIT batteryUpdated();
                Q_EMIT settingsUpdated();
            }
        }
        else
        {
            qWarning() << "> getInfos.exec() ERROR" << getInfos.lastError().type() << ":" << getInfos.lastError().text();
        }
    }

    return status;
}

bool Device::getSqlLimits()
{
    //qDebug() << "Device::getSqlLimits(" << m_deviceAddress << ")";
    return false;
}

bool Device::getSqlData(int)
{
    //qDebug() << "Device::getSqlData(" << m_deviceAddress << ")";
    return false;
}

/* ************************************************************************** */
/* ************************************************************************** */

/*!
 * \brief Device::getBleData
 * \return false means immediate error, true means update process started
 */
bool Device::getBleData()
{
    //qDebug() << "Device::getBleData(" << m_deviceAddress << ")";

    // Create a QLowEnergyController (if needed)
    if (!controller)
    {
        controller = new QLowEnergyController(m_bleDevice);
        if (controller)
        {
            if (controller->role() != QLowEnergyController::CentralRole)
            {
                qWarning() << "BLE controller doesn't have the QLowEnergyController::CentralRole";
                refreshDataFinished(false, false);
                return false;
            }

            controller->setRemoteAddressType(QLowEnergyController::PublicAddress);

            // Connecting signals and slots for connecting to LE services.
            connect(controller, &QLowEnergyController::connected, this, &Device::deviceConnected);
            connect(controller, &QLowEnergyController::disconnected, this, &Device::deviceDisconnected);
            connect(controller, &QLowEnergyController::serviceDiscovered, this, &Device::addLowEnergyService);
            connect(controller, &QLowEnergyController::discoveryFinished, this, &Device::serviceScanDone, Qt::QueuedConnection); // Windows hack, see: QTBUG-80770 and QTBUG-78488
            connect(controller, QOverload<QLowEnergyController::Error>::of(&QLowEnergyController::error), this, &Device::errorReceived);
            connect(controller, &QLowEnergyController::stateChanged, this, &Device::stateChanged);
        }
        else
        {
            qWarning() << "Unable to create BLE controller";
            refreshDataFinished(false, false);
            return false;
        }
    }
    else
    {
        //if (controller) qDebug() << "Current BLE controller state:" << controller->state();
    }

    // Start the actual connection process
    if (controller)
    {
        setTimeoutTimer();

        controller->connectToDevice();
    }

    return true;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::isErrored() const
{
    return (getLastErrorInt() >= 0 && getLastErrorInt() <= 12*60);
}

bool Device::isFresh() const
{
    SettingsManager *sm = SettingsManager::getInstance();
    return (getLastUpdateInt() >= 0 &&
            getLastUpdateInt() <= (hasSoilMoistureSensor() ? sm->getUpdateIntervalPlant() : sm->getUpdateIntervalThermo()));
}

bool Device::isAvailable() const
{
    return (getLastUpdateInt() >= 0 && getLastUpdateInt() <= 12*60);
}

/* ************************************************************************** */

QDateTime Device::getLastSync() const
{
    return m_lastSync;
}

int Device::getHistoryUpdatePercent() const
{
    return -1;
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

int Device::getLastErrorInt() const
{
    int mins = -1;

    if (m_lastError.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastError.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two errors...
            qWarning() << "getLastErrorInt() has a negative value (" << mins << "). Clock mismatch?";

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

/* ************************************************************************** */

void Device::setLocationName(const QString &name)
{
    if (m_locationName != name)
    {
        m_locationName = name;
        //qDebug() << "setLocationName(" << m_locationName << ")";

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateLocation;
            updateLocation.prepare("UPDATE devices SET locationName = :name WHERE deviceAddr = :deviceAddr");
            updateLocation.bindValue(":name", name);
            updateLocation.bindValue(":deviceAddr", getAddress());
            updateLocation.exec();
        }

        Q_EMIT dataUpdated();

        if (SettingsManager::getInstance()->getOrderBy() == "location")
        {
            if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
        }
    }
}

void Device::setAssociatedName(const QString &name)
{
    if (m_associatedName != name)
    {
        m_associatedName = name;
        //qDebug() << "setAssociatedName(" << m_associatedName << ")";

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updatePlant;
            updatePlant.prepare("UPDATE devices SET associatedName = :name WHERE deviceAddr = :deviceAddr");
            updatePlant.bindValue(":name", name);
            updatePlant.bindValue(":deviceAddr", getAddress());
            updatePlant.exec();
        }

        Q_EMIT dataUpdated();

        if (SettingsManager::getInstance()->getOrderBy() == "plant")
        {
            if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
        }
    }
}

void Device::setOutside(const bool outside)
{
    if (m_isOutside != outside)
    {
        m_isOutside = outside;

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateOutside;
            updateOutside.prepare("UPDATE devices SET isOutside = :outside WHERE deviceAddr = :deviceAddr");
            updateOutside.bindValue(":outside", outside);
            updateOutside.bindValue(":deviceAddr", getAddress());
            updateOutside.exec();
        }

        Q_EMIT sensorUpdated();
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

    m_additionalSettings.insert(key, value.toString());

    if (m_dbInternal || m_dbExternal)
    {
        QJsonDocument json(m_additionalSettings);
        QString json_str = QString(json.toJson());

        QSqlQuery updateSettings;
        updateSettings.prepare("UPDATE devices SET settings = :settings WHERE deviceAddr = :deviceAddr");
        updateSettings.bindValue(":settings", json_str);
        updateSettings.bindValue(":deviceAddr", getAddress());
        if (updateSettings.exec() == false)
            qWarning() << "> updateSettings.exec() ERROR" << updateSettings.lastError().type() << ":" << updateSettings.lastError().text();
    }

    Q_EMIT sensorUpdated();

    return status;
}

/* ************************************************************************** */

void Device::updateFirmware(const QString &firmware)
{
    if (!firmware.isEmpty() && m_deviceFirmware != firmware)
    {
        m_deviceFirmware = firmware;

        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery updateFirmware;
            updateFirmware.prepare("UPDATE devices SET deviceFirmware = :firmware WHERE deviceAddr = :deviceAddr");
            updateFirmware.bindValue(":firmware", m_deviceFirmware);
            updateFirmware.bindValue(":deviceAddr", getAddress());
            if (updateFirmware.exec() == false)
                qWarning() << "> updateFirmware.exec() ERROR" << updateFirmware.lastError().type() << ":" << updateFirmware.lastError().text();
        }

        Q_EMIT sensorUpdated();
    }
}

void Device::updateBattery(const int battery)
{
    if (battery > 0 && battery <= 100)
    {
        if (m_deviceBattery != battery)
        {
            m_deviceBattery = battery;

            if (m_dbInternal || m_dbExternal)
            {
                QSqlQuery updateBattery;
                updateBattery.prepare("UPDATE devices SET deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateBattery.bindValue(":battery", m_deviceBattery);
                updateBattery.bindValue(":deviceAddr", getAddress());
                if (updateBattery.exec() == false)
                    qWarning() << "> updateBattery.exec() ERROR" << updateBattery.lastError().type() << ":" << updateBattery.lastError().text();
            }

            Q_EMIT batteryUpdated();
        }
    }
}

/* ************************************************************************** */

void Device::updateRssi(const int rssi)
{
    if (m_rssi != rssi)
    {
        m_rssi = rssi;
    }

    Q_EMIT rssiUpdated();
    m_rssiTimer.start();
}

void Device::cleanRssi()
{
    m_rssi = 0;
    Q_EMIT rssiUpdated();
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::deviceConnected()
{
    //qDebug() << "Device::deviceConnected(" << m_deviceAddress << ")";

    m_updating = true;
    m_status = DeviceUtils::DEVICE_CONNECTED;

    if (m_ble_action == DeviceUtils::DEVICE_UPDATING_REALTIME ||
        m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
        // Stop timeout timer, we'll be long...
        m_timeoutTimer.stop();
    }
    else
    {
        // Restart for an additional 10s+?
        setTimeoutTimer();
    }

    if (m_ble_action == DeviceUtils::ACTION_UPDATE)
    {
        m_status = DeviceUtils::DEVICE_UPDATING;
    }
    else if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
    {
        m_status = DeviceUtils::DEVICE_UPDATING_REALTIME;
    }
    else if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
        m_status = DeviceUtils::DEVICE_UPDATING_HISTORY;
    }
    else if (m_ble_action == DeviceUtils::ACTION_LED_BLINK ||
             m_ble_action == DeviceUtils::ACTION_CLEAR_HISTORY||
             m_ble_action == DeviceUtils::ACTION_WATERING)
    {
        m_status = DeviceUtils::DEVICE_WORKING;
    }

    Q_EMIT connected();
    Q_EMIT statusUpdated();

    controller->discoverServices();
}

void Device::deviceDisconnected()
{
    //qDebug() << "Device::deviceDisconnected(" << m_deviceAddress << ")";

    Q_EMIT disconnected();

    if (m_status == DeviceUtils::DEVICE_CONNECTING || m_status == DeviceUtils::DEVICE_UPDATING)
    {
        // This means we got forcibly disconnected by the device before completing the update
        m_lastError = QDateTime::currentDateTime();
        refreshDataFinished(false);
    }
    else if (m_status == DeviceUtils::DEVICE_UPDATING_HISTORY)
    {
        // This means we got forcibly disconnected by the device before completing the history sync
        refreshHistoryFinished(false);
    }
    else
    {
        m_updating = false;
        m_status = DeviceUtils::DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

void Device::errorReceived(QLowEnergyController::Error error)
{
    qWarning() << "Device::errorReceived(" << m_deviceAddress << ") error:" << error;

    m_lastError = QDateTime::currentDateTime();
    refreshDataFinished(false);
}

void Device::stateChanged(QLowEnergyController::ControllerState)
{
    //qDebug() << "Device::stateChanged(" << m_deviceAddress << ") state:" << state;
}

/* ************************************************************************** */

void Device::serviceDetailsDiscovered(QLowEnergyService::ServiceState)
{
    //qDebug() << "Device::serviceDetailsDiscovered(" << m_deviceAddress << ")";
}

void Device::serviceScanDone()
{
    //qDebug() << "Device::serviceScanDone(" << m_deviceAddress << ")";
}

void Device::addLowEnergyService(const QBluetoothUuid &)
{
    //qDebug() << "Device::addLowEnergyService(" << uuid.toString() << ")";
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

void Device::parseAdvertisementData(const QByteArray &)
{
    //qDebug() << "Device::parseAdvertisementData(" << m_deviceAddress << ")";
}

/* ************************************************************************** */
