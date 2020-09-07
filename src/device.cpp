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
#include "settingsmanager.h"
#include "devicemanager.h"
#include "notificationmanager.h"
#include "utils/utils_versionchecker.h"

#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

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

    // Parrot hack // Remove MAC address from device name
    if (m_deviceName.startsWith("Flower power")) m_deviceName = "Flower power";
    else if (m_deviceName.startsWith("Parrot pot")) m_deviceName = "Parrot pot";

    if (m_bleDevice.isValid() == false)
        qWarning() << "Device() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::refreshDataCanceled);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &Device::refreshStart);

    m_rssiTimer.setSingleShot(true);
    m_rssiTimer.setInterval(10000); // 10s
    connect(&m_rssiTimer, &QTimer::timeout, this, &Device::cleanRssi);
}

Device::Device(const QBluetoothDeviceInfo &d, QObject *parent) : QObject(parent)
{
    m_bleDevice = d;
    m_deviceName = m_bleDevice.name();

    // Parrot hack // Remove MAC address from device name
    if (m_deviceName.startsWith("Flower power")) m_deviceName = "Flower power";
    else if (m_deviceName.startsWith("Parrot pot")) m_deviceName = "Parrot pot";

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
            if (controller->role() != QLowEnergyController::CentralRole)
            {
                qWarning() << "BLE controller doesn't have the QLowEnergyController::CentralRole";
                //refreshDataFinished(false, false);
                //return false;
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
            //refreshDataFinished(false, false);
            //return false;
        }
    }
    else
    {
        //if (controller) qDebug() << "Current BLE controller state:" << controller->state();
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

void Device::ledActionStart()
{
    //qDebug() << "Device::ledActionStart()" << getAddress() << getName();

    if (!isUpdating())
    {
        m_ble_action = ACTION_LED_BLINK;
        refreshDataStarted();
        getBleData();
    }
}

void Device::refreshQueue()
{
    if (m_status == DEVICE_OFFLINE)
    {
        m_status = DEVICE_QUEUED;
        Q_EMIT statusUpdated();
    }
}

void Device::refreshStart()
{
    //qDebug() << "Device::refreshStart()" << getAddress() << getName() << "/ last update: " << getLastUpdateInt();

    if (!isUpdating())
    {
        m_retries = 1;
        m_ble_action = ACTION_UPDATE;
        refreshDataStarted();
        getBleData();
    }
}

void Device::refreshHistoryStart()
{
    //qDebug() << "Device::refreshHistoryStart()" << getAddress() << getName();

    if (!isUpdating())
    {
        m_ble_action = ACTION_UPDATE_HISTORY;
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

    if (m_updating || m_status != DEVICE_OFFLINE)
    {
        m_updating = false;
        m_status = DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
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
    }*/
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

/* ************************************************************************** */

void Device::refreshDataStarted()
{
    //qDebug() << "Device::refreshDataStarted()" << getAddress() << getName();

    m_updating = true;
    m_status = DEVICE_CONNECTING;
    Q_EMIT statusUpdated();
}

void Device::refreshDataFinished(bool status, bool cached)
{
    //qDebug() << "Device::refreshDataFinished()" << getAddress() << getName();

    m_timeoutTimer.stop();

    m_updating = false;
    m_status = DEVICE_OFFLINE;
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

        if (hasSoilMoistureSensor())
            updateInterval = sm->getUpdateIntervalPlant();
        else
            updateInterval = sm->getUpdateIntervalThermo();
    }

    // Validate the interval
    if (updateInterval < 5 || updateInterval > 120)
    {
        if (hasSoilMoistureSensor())
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
    m_timeoutTimer.setInterval(m_timeout*1000);
    m_timeoutTimer.start();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::getSqlInfos()
{
    //qDebug() << "Device::getSqlInfos(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery getFirmware;
    getFirmware.prepare("SELECT deviceFirmware FROM devices WHERE deviceAddr = :deviceAddr");
    getFirmware.bindValue(":deviceAddr", getAddress());
    getFirmware.exec();
    while (getFirmware.next())
    {
        m_firmware = getFirmware.value(0).toString();
        status = true;
    }

    QSqlQuery getBattery;
    getBattery.prepare("SELECT deviceBattery FROM devices WHERE deviceAddr = :deviceAddr");
    getBattery.bindValue(":deviceAddr", getAddress());
    getBattery.exec();
    while (getBattery.next())
    {
        m_battery = getBattery.value(0).toInt();
        status = true;
    }

    QSqlQuery getLocationName;
    getLocationName.prepare("SELECT locationName FROM devices WHERE deviceAddr = :deviceAddr");
    getLocationName.bindValue(":deviceAddr", getAddress());
    getLocationName.exec();
    while (getLocationName.next())
    {
        m_locationName = getLocationName.value(0).toString();
        status = true;
    }

    QSqlQuery getPlantName;
    getPlantName.prepare("SELECT plantName FROM devices WHERE deviceAddr = :deviceAddr");
    getPlantName.bindValue(":deviceAddr", getAddress());
    getPlantName.exec();
    while (getPlantName.next())
    {
        m_plantName = getPlantName.value(0).toString();
        status = true;
    }

    Q_EMIT sensorUpdated();

    return status;
}

bool Device::getSqlLimits()
{
    //qDebug() << "Device::getSqlLimits(" << m_deviceAddress << ")";
    return false;
}

bool Device::getSqlData(int minutes)
{
    //qDebug() << "Device::getSqlData(" << m_deviceAddress << ")";
    return false;
}

/*!
 * \brief Device::getBleData
 * \return false means immediate error, true means update process started
 */
bool Device::getBleData()
{
    //qDebug() << "Device::getBleData(" << m_deviceAddress << ")";

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

void Device::setLocationName(const QString &name)
{
    if (m_locationName != name)
    {
        m_locationName = name;
        qDebug() << "setLocationName(" << m_locationName << ")";

        QSqlQuery updateLocation;
        updateLocation.prepare("UPDATE devices SET locationName = :name WHERE deviceAddr = :deviceAddr");
        updateLocation.bindValue(":name", name);
        updateLocation.bindValue(":deviceAddr", getAddress());
        updateLocation.exec();

        Q_EMIT dataUpdated();

        if (SettingsManager::getInstance()->getOrderBy() == "location")
        {
            if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
        }
    }
}

void Device::setAssociatedName(const QString &name)
{
    setPlantName(name);
}

void Device::setPlantName(const QString &name)
{
    if (m_plantName != name)
    {
        m_plantName = name;
        qDebug() << "setPlantName(" << m_plantName << ")";

        QSqlQuery updatePlant;
        updatePlant.prepare("UPDATE devices SET plantName = :name WHERE deviceAddr = :deviceAddr");
        updatePlant.bindValue(":name", name);
        updatePlant.bindValue(":deviceAddr", getAddress());
        updatePlant.exec();

        Q_EMIT dataUpdated();

        if (SettingsManager::getInstance()->getOrderBy() == "plant")
        {
            if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
        }
    }
}

void Device::updateRssi(const int rssi)
{
    m_rssi = rssi;
    Q_EMIT sensorUpdated();

    m_rssiTimer.start();
}

void Device::cleanRssi()
{
    m_rssi = 0;
    Q_EMIT sensorUpdated();
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::deviceConnected()
{
    //qDebug() << "Device::deviceConnected(" << m_deviceAddress << ")";

    Q_EMIT connected();

    m_updating = true;
    m_status = DEVICE_UPDATING;
    Q_EMIT statusUpdated();

    controller->discoverServices();
}

void Device::deviceDisconnected()
{
    //qDebug() << "Device::deviceDisconnected(" << m_deviceAddress << ")";

    Q_EMIT disconnected();

    if (m_status == DEVICE_CONNECTING || m_status == DEVICE_UPDATING)
    {
        // This means we got forcibly disconnected by the device before completing the update
        m_lastError = QDateTime::currentDateTime();
        refreshDataFinished(false);
    }
    else
    {
        m_updating = false;
        m_status = DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

void Device::errorReceived(QLowEnergyController::Error error)
{
    qWarning() << "Device::errorReceived(" << m_deviceAddress << ") error:" << error;

    m_lastError = QDateTime::currentDateTime();
    refreshDataFinished(false);
}

void Device::stateChanged(QLowEnergyController::ControllerState state)
{
    //qDebug() << "Device::stateChanged(" << m_deviceAddress << ") state:" << state;
    Q_UNUSED(state)
}

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
