/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
#include "notificationmanager.h"
#include "versionchecker.h"

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

    if (m_bleDevice.isValid() == false)
        qWarning() << "Device() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";

    // Load device infos and limits
    getSqlInfos();
    // Load initial datas into the GUI (if they are no more than 12h old)
    getSqlDatas(12*60);

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::refreshDatasCanceled);

    // Configure update timer (only on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &Device::refreshStart);
}

Device::Device(const QBluetoothDeviceInfo &d, QObject *parent) : QObject(parent)
{
    m_bleDevice = d;
    m_deviceName = m_bleDevice.name();

#if defined(Q_OS_OSX) || defined(Q_OS_IOS)
    m_deviceAddress = m_bleDevice.deviceUuid().toString();
#else
    m_deviceAddress = m_bleDevice.address().toString();
#endif

    if (m_bleDevice.isValid() == false)
        qWarning() << "Device() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";

    // Load device infos and limits
    getSqlInfos();
    // Load initial datas into the GUI (if they are no more than 12h old)
    getSqlDatas(12*60);

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::refreshDatasCanceled);

    // Configure update timer (only on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &Device::refreshStart);
}

Device::~Device()
{
    delete controller;
}

/* ************************************************************************** */
/* ************************************************************************** */

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
    //qDebug() << "Device::refreshStart()" << getAddress() << getName();

    if (getLastUpdateInt() < 0 || getLastUpdateInt() > 1)
    {
        refreshDatasStarted();
        getBleDatas();
    }
    else
    {
        if (m_status != DEVICE_OFFLINE)
        {
            m_status = DEVICE_OFFLINE;
            Q_EMIT statusUpdated();
        }
        Q_EMIT deviceUpdated(this);
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

void Device::refreshDatasCanceled()
{
    //qDebug() << "Device::refreshDatasCanceled()" << getAddress() << getName();

    if (controller)
    {
        controller->disconnectFromDevice();

        m_lastError = QDateTime::currentDateTime();
    }

    refreshDatasFinished(false);
}

/* ************************************************************************** */

void Device::refreshDatasStarted()
{
    //qDebug() << "Device::refreshDatasStarted()" << getAddress() << getName();

    m_updating = true;
    m_status = DEVICE_CONNECTING;
    Q_EMIT statusUpdated();
}

void Device::refreshDatasFinished(bool status, bool cached)
{
    //qDebug() << "Device::refreshDatasFinished()" << getAddress() << getName();

    m_timeoutTimer.stop();

    m_updating = false;
    m_status = DEVICE_OFFLINE;
    Q_EMIT statusUpdated();

    if (status == true)
    {
        // Only update datas on success
        Q_EMIT datasUpdated();

        // Reset update timer
        setUpdateTimer();

        // Reset last error
        m_lastError = QDateTime();

        // 'Water me' notification, if enabled
        SettingsManager *sm = SettingsManager::getInstance();
        if (sm && sm->getNotifs())
        {
            // Only if the sensor has a plant
            if (hasSoilMoistureSensor() &&
                m_hygro > 0 && m_hygro < m_limitHygroMin)
            {
                NotificationManager *nm = NotificationManager::getInstance();
                if (nm)
                {
                    QString message;
                    if (!m_plantName.isEmpty())
                        message = tr("You need to water your '%1' now!").arg(m_plantName);
                    else if (!m_locationName.isEmpty())
                        message = tr("You need to water the plant near '%1'").arg(m_locationName);
                    else
                        message = tr("You need to water one of your (unnamed) plant!");

                    nm->setNotification(message);
                }
            }
        }
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
    return; // we do not update every x hours on mobile, we update everytime the app is on the
#endif

    // If no interval is provided, load the one from settings
    if (updateInterval <= 0)
    {
        SettingsManager *sm = SettingsManager::getInstance();
        updateInterval = sm->getUpdateInterval();
    }

    // Validate the interval
    if (updateInterval < 5 || updateInterval > 120)
        updateInterval = DEFAULT_UPDATE_INTERVAL;

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

        if ((m_deviceName == "Flower care" || m_deviceName == "Flower mate") && (m_firmware.size() == 5))
        {
            if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
            {
                m_firmware_uptodate = true;
                Q_EMIT sensorUpdated();
            }
        }
        else if ((m_deviceName == "ropot") && (m_firmware.size() == 5))
        {
            if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_ROPOT))
            {
                m_firmware_uptodate = true;
                Q_EMIT sensorUpdated();
            }
        }
        else if ((m_deviceName == "MJ_HT_V1") && (m_firmware.size() == 8))
        {
            if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_LCD))
            {
                m_firmware_uptodate = true;
                Q_EMIT sensorUpdated();
            }
        }
        else if ((m_deviceName == "ClearGrass Temp & RH") && (m_firmware.size() == 10))
        {
            if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
            {
                m_firmware_uptodate = true;
                Q_EMIT sensorUpdated();
            }
        }
        else if ((m_deviceName == "LYWSD02") && (m_firmware.size() == 10))
        {
            if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK))
            {
                m_firmware_uptodate = true;
                Q_EMIT sensorUpdated();
            }
        }
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

    QSqlQuery getLimits;
    getLimits.prepare("SELECT hygroMin, hygroMax, tempMin, tempMax, lumiMin, lumiMax, conduMin, conduMax "
                      "FROM limits WHERE deviceAddr = :deviceAddr");
    getLimits.bindValue(":deviceAddr", getAddress());
    getLimits.exec();
    while (getLimits.next())
    {
        m_limitHygroMin = getLimits.value(0).toInt();
        m_limitHygroMax = getLimits.value(1).toInt();
        m_limitTempMin = getLimits.value(2).toInt();
        m_limitTempMax = getLimits.value(3).toInt();
        m_limitLumiMin = getLimits.value(4).toInt();
        m_limitLumiMax = getLimits.value(5).toInt();
        m_limitConduMin = getLimits.value(6).toInt();
        m_limitConduMax = getLimits.value(7).toInt();

        status = true;
        Q_EMIT limitsUpdated();
    }

    return status;
}

bool Device::getSqlDatas(int minutes)
{
    //qDebug() << "Device::getSqlDatas(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedDatas;
    cachedDatas.prepare("SELECT temp, hygro, luminosity, conductivity, ts_full " \
                        "FROM datas " \
                        "WHERE deviceAddr = :deviceAddr AND ts_full >= datetime('now', 'localtime', '-" + QString::number(minutes) + " minutes');");
    cachedDatas.bindValue(":deviceAddr", getAddress());

    if (cachedDatas.exec() == false)
        qWarning() << "> cachedDatas.exec() ERROR" << cachedDatas.lastError().type() << ":"  << cachedDatas.lastError().text();
    else
    {
#ifndef QT_NO_DEBUG
        qDebug() << "* Device update:" << getAddress();
        qDebug() << "> SQL datas available...";
#endif
    }

    while (cachedDatas.next())
    {
        m_temp = cachedDatas.value(0).toFloat();
        m_hygro =  cachedDatas.value(1).toInt();
        m_luminosity = cachedDatas.value(2).toInt();
        m_conductivity = cachedDatas.value(3).toInt();

        QString datetime = cachedDatas.value(4).toString();
        m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");

        status = true;
    }

    refreshDatasFinished(status, true);

    return status;
}

/*!
 * \brief Device::getBleDatas
 * \return false means immediate error, true means update process started
 */
bool Device::getBleDatas()
{
    //qDebug() << "Device::getBleDatas(" << m_deviceAddress << ")";

    if (!controller)
    {
        controller = new QLowEnergyController(m_bleDevice);
        if (controller)
        {
            if (controller->role() != QLowEnergyController::CentralRole)
            {
                qWarning() << "BLE controller doesn't have the QLowEnergyController::CentralRole";
                refreshDatasFinished(false, false);
                return false;
            }

            controller->setRemoteAddressType(QLowEnergyController::PublicAddress);

            // Connecting signals and slots for connecting to LE services.
            connect(controller, &QLowEnergyController::connected, this, &Device::deviceConnected);
            connect(controller, QOverload<QLowEnergyController::Error>::of(&QLowEnergyController::error), this, &Device::errorReceived);
            connect(controller, &QLowEnergyController::disconnected, this, &Device::deviceDisconnected);
            connect(controller, &QLowEnergyController::serviceDiscovered, this, &Device::addLowEnergyService);
            connect(controller, &QLowEnergyController::discoveryFinished, this, &Device::serviceScanDone);
        }
        else
        {
            qWarning() << "Unable to create BLE controller";
            refreshDatasFinished(false, false);
            return false;
        }
    }
    else
    {
        //if (controller) qDebug() << "Current BLE controller state:" << controller->state();
    }

    setTimeoutTimer();

    controller->connectToDevice();

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
    return (getLastUpdateInt() >= 0 && getLastUpdateInt() <= sm->getUpdateInterval());
}

bool Device::isAvailable() const
{
    return (getLastUpdateInt() >= 0 && getLastUpdateInt() <= 12*60);
}

/* ************************************************************************** */

float Device::getTemp() const
{
    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        return getTempF();

    return getTempC();
}

QString Device::getTempString() const
{
    QString tempString;

    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        tempString = QString::number(getTempF(), 'f', 1) + "°F";
    else
        tempString = QString::number(getTempC(), 'f', 1) + "°C";

    return tempString;
}

int Device::getLastUpdateInt() const
{
    int mins = -1;

    if (m_lastUpdate.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastUpdate.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two updates...
            qDebug() << "getLastUpdateInt() has a negative value (" << mins << "). Clock mismatch?";

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
            qDebug() << "getLastErrorInt() has a negative value (" << mins << "). Clock mismatch?";

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
                lastUpdate = QString::number(mins);
                lastUpdate += tr(" min.");
            } else {
                lastUpdate = QString::number(std::floor(mins / 60.0));
                lastUpdate += tr(" hours");
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

        Q_EMIT datasUpdated();
    }
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

        Q_EMIT datasUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::setDbLimits()
{
    bool status = false;

    QSqlQuery updateLimits;
    updateLimits.prepare("REPLACE INTO limits (deviceAddr, hygroMin, hygroMax, tempMin, tempMax, lumiMin, lumiMax, conduMin, conduMax)"
                         " VALUES (:deviceAddr, :hygroMin, :hygroMax, :tempMin, :tempMax, :lumiMin, :lumiMax, :conduMin, :conduMax)");
    updateLimits.bindValue(":deviceAddr", getAddress());
    updateLimits.bindValue(":hygroMin", m_limitHygroMin);
    updateLimits.bindValue(":hygroMax", m_limitHygroMax);
    updateLimits.bindValue(":tempMin", m_limitTempMin);
    updateLimits.bindValue(":tempMax", m_limitTempMax);
    updateLimits.bindValue(":lumiMin", m_limitLumiMin);
    updateLimits.bindValue(":lumiMax", m_limitLumiMax);
    updateLimits.bindValue(":conduMin", m_limitConduMin);
    updateLimits.bindValue(":conduMax", m_limitConduMax);

    status = updateLimits.exec();
    if (status == false)
        qWarning() << "> updateLimits.exec() ERROR" << updateLimits.lastError().type() << ":"  << updateLimits.lastError().text();

    Q_EMIT limitsUpdated();

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::deviceConnected()
{
    //qDebug() << "Device::deviceConnected(" << m_deviceAddress << ")";

    m_updating = true;
    m_status = DEVICE_UPDATING;
    Q_EMIT statusUpdated();

    controller->discoverServices();
}

void Device::deviceDisconnected()
{
    //qDebug() << "Device::deviceDisconnected(" << m_deviceAddress << ")";

    if (m_status == DEVICE_CONNECTING || m_status == DEVICE_UPDATING)
    {
        // This means we got forcibly disconnected by the device before completing the update
        m_lastError = QDateTime::currentDateTime();
        refreshDatasFinished(false);
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
    //qWarning() << "Device::errorReceived(" << m_deviceAddress << ") error:" << error;
    Q_UNUSED(error)

    m_lastError = QDateTime::currentDateTime();
    refreshDatasFinished(false);
}

void Device::serviceScanDone()
{
    //qDebug() << "Device::serviceScanDone(" << m_deviceAddress << ")";
}

void Device::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "Device::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

void Device::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{
    //qDebug() << "Device::serviceDetailsDiscovered(" << m_deviceAddress << ")";
    Q_UNUSED(newState)
}

bool Device::hasControllerError() const
{
    //qWarning() << "Device::hasControllerError(" << m_deviceAddress << ") error:" << error;

    if (controller && controller->error() != QLowEnergyController::NoError)
        return true;

    return false;
}

void Device::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleWriteDone(" << m_deviceAddress << ")";
}

void Device::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    Q_UNUSED(c)
    Q_UNUSED(value)
/*
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    qDebug() << "Device::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATAS: 0x" \
               << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
               << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
               << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[11] \
               << hex << data[12]  << hex << data[13]  << hex << data[14] << hex << data[15];
*/
}

void Device::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    Q_UNUSED(c)
    Q_UNUSED(value)
/*
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    qDebug() << "Device::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATAS: 0x" \
               << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
               << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
               << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[11] \
               << hex << data[12]  << hex << data[13];
*/
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::hasDatas() const
{
    // If we have immediate datas (<12h old)
    if (m_hygro > 0 || m_temp > -20.f || m_luminosity > 0 || m_conductivity > 0)
        return true;

    // Otherwise, check if we have stored datas
    QSqlQuery hasDatas;
    hasDatas.prepare("SELECT COUNT(*) FROM datas WHERE deviceAddr = :deviceAddr;");
    hasDatas.bindValue(":deviceAddr", getAddress());

    if (hasDatas.exec() == false)
        qWarning() << "> hasDatas.exec() ERROR" << hasDatas.lastError().type() << ":"  << hasDatas.lastError().text();

    while (hasDatas.next())
    {
        if (hasDatas.value(0).toInt() > 0) // datas count
            return true;
    }

    return false;
}

bool Device::hasDatas(const QString &dataName) const
{
    // If we have immediate datas (<12h old)
    if (dataName == "hygro" && m_hygro > 0)
        return true;
    if (dataName == "temp" && m_temp > -20.f)
        return true;
    if (dataName == "luminosity" && m_luminosity > 0)
        return true;
    if (dataName == "conductivity" && m_conductivity > 0)
        return true;

    // Otherwise, check if we have stored datas
    QSqlQuery hasDatas;
    hasDatas.prepare("SELECT COUNT(" + dataName + ") FROM datas WHERE deviceAddr = :deviceAddr AND " + dataName + " > 0;");
    hasDatas.bindValue(":deviceAddr", getAddress());

    if (hasDatas.exec() == false)
        qWarning() << "> hasDatas.exec() ERROR" << hasDatas.lastError().type() << ":"  << hasDatas.lastError().text();

    while (hasDatas.next())
    {
        if (hasDatas.value(0).toInt() > 0) // datas count
            return true;
    }

    return false;
}

int Device::countDatas(const QString &dataName, int days) const
{
    // Count stored datas
    QSqlQuery datasCount;
    datasCount.prepare("SELECT COUNT(" + dataName + ")" \
                       "FROM datas " \
                       "WHERE deviceAddr = :deviceAddr " \
                            "AND " + dataName + " > 0 AND ts >= datetime('now','-" + QString::number(days) + " day','+2 hour');");
    datasCount.bindValue(":deviceAddr", getAddress());

    if (datasCount.exec() == false)
        qWarning() << "> datasCount.exec() ERROR" << datasCount.lastError().type() << ":"  << datasCount.lastError().text();

    while (datasCount.next())
    {
        return datasCount.value(0).toInt();
    }

    return 0;
}

/* ************************************************************************** */
/* ************************************************************************** */

/*!
 * \brief Device::getMonth
 * \return Last 30 days
 *
 * First day is always xxx
 */
QVariantList Device::getMonth()
{
    QVariantList lastSevenDays;

    // first day is always today
    QDate currentDay = QDate::currentDate();
    lastSevenDays.prepend(currentDay.toString("dd"));

    // then fill the 6 days before that
    while (lastSevenDays.size() < 30)
    {
        currentDay = currentDay.addDays(-1);
        lastSevenDays.prepend(currentDay.toString("dd"));
    }

    return lastSevenDays;
/*
    // format days (ex: "mon.")
    QVariantList lastSevenDaysFormated;
    for (int i = 0; i < lastSevenDays.size(); i++)
    {
        QString day = qvariant_cast<QString>(lastSevenDays.at(i));
        day.truncate(2);
        day += ".";
        lastSevenDaysFormated.append(day);
    }
*/
/*
    qDebug() << "Days (" << lastSevenDaysFormated.size() << ") : ";
    for (auto d: lastSevenDaysFormated)
        qDebug() << d;
*/
    //return lastSevenDaysFormated;
}

QVariantList Device::getMonthDatas(const QString &dataName)
{
    QVariantList datas;
    QDate nextDayToHandle = QDate::currentDate();

    QSqlQuery datasPerMonth;
    datasPerMonth.prepare("SELECT strftime('%d', ts) as 'day', avg(" + dataName + ") as 'avg'" \
                        "FROM datas WHERE deviceAddr = :deviceAddr " \
                        "GROUP BY cast(strftime('%d', ts) as datetime) " \
                        "ORDER BY ts DESC;");
    datasPerMonth.bindValue(":deviceAddr", getAddress());

    if (datasPerMonth.exec() == false)
        qWarning() << "> datasPerMonth.exec() ERROR" << datasPerMonth.lastError().type() << ":"  << datasPerMonth.lastError().text();

    while (datasPerMonth.next() && (datas.size() < 30))
    {
        int currentDay = datasPerMonth.value(0).toInt();

        // fill holes
        while (currentDay != nextDayToHandle.day() && (datas.size() < 30))
        {
            datas.prepend(0);
            //qDebug() << "> filling hole for day" << nextDayToHandle.day();

            nextDayToHandle = nextDayToHandle.addDays(-1);
        }
        nextDayToHandle = nextDayToHandle.addDays(-1);

        datas.prepend(datasPerMonth.value(1));
        //qDebug() << "> we have data for day" << currentDay << ", next day to handle is" << nextDayToHandle.day();
    }

    // add front padding if we don't have 7 days
    while (datas.size() < 30)
    {
        datas.prepend(0);
    }
/*
    // debug
    qDebug() << "Datas (" << dataName << "/" << datas.size() << ") : ";
    for (auto d: datas)
        qDebug() << d;
*/
    return datas;
}

QVariantList Device::getMonthBackground(float maxValue)
{
    QVariantList lastSevenDays;

    while (lastSevenDays.size() < 30)
    {
        lastSevenDays.append(maxValue);
    }

    return lastSevenDays;
}

/* ************************************************************************** */
/* ************************************************************************** */

/*!
 * \brief Device::getDays
 * \return List of days of the week
 *
 * First day is always today, then fill it up with the previous 6 days
 */
QVariantList Device::getDays()
{
    QVariantList lastSevenDays;

    // first day is always today
    QDate currentDay = QDate::currentDate();
    lastSevenDays.prepend(currentDay.toString("dddd"));

    // then fill the 6 days before that
    while (lastSevenDays.size() < 7)
    {
        currentDay = currentDay.addDays(-1);
        lastSevenDays.prepend(currentDay.toString("dddd"));
    }

    // format days (ex: "mon.")
    QVariantList lastSevenDaysFormated;
    for (const auto & lastSevenDay : lastSevenDays)
    {
        QString day = qvariant_cast<QString>(lastSevenDay);
        day.truncate(3);
        day += ".";
        lastSevenDaysFormated.append(day);
    }
/*
    qDebug() << "Days (" << lastSevenDaysFormated.size() << ") : ";
    for (auto d: lastSevenDaysFormated)
        qDebug() << d;
*/
    return lastSevenDaysFormated;
}

QVariantList Device::getDatasDaily(const QString &dataName)
{
    QVariantList datas;
    QDate nextDayToHandle = QDate::currentDate();

    QSqlQuery datasPerDay;
    datasPerDay.prepare("SELECT strftime('%Y-%m-%d', ts) as 'date', strftime('%d', ts) as 'day', avg(" + dataName + ") as 'avg' " \
                        "FROM datas WHERE deviceAddr = :deviceAddr " \
                        "GROUP BY cast(strftime('%d', ts) as datetime) " \
                        "ORDER BY ts DESC;");
    datasPerDay.bindValue(":deviceAddr", getAddress());

    if (datasPerDay.exec() == false)
        qWarning() << "> dataPerDay.exec() ERROR" << datasPerDay.lastError().type() << ":"  << datasPerDay.lastError().text();

    while (datasPerDay.next() && (datas.size() < 7))
    {
        int currentDay = datasPerDay.value(1).toInt();

        // fill holes
        while (currentDay != nextDayToHandle.day() && (datas.size() < 7))
        {
            datas.prepend(0);
            //qDebug() << "> filling hole for day" << nextDayToHandle.day();

            nextDayToHandle = nextDayToHandle.addDays(-1);
        }
        nextDayToHandle = nextDayToHandle.addDays(-1);

        datas.prepend(datasPerDay.value(2));
        //qDebug() << "> we have data for day" << currentDay << ", next day to handle is" << nextDayToHandle.day();
    }

    // add front padding if we don't have 7 days
    while (datas.size() < 7)
    {
        datas.prepend(0);
    }
/*
    // debug
    qDebug() << "Datas (" << dataName << "/" << datas.size() << ") : ";
    for (auto d: datas)
        qDebug() << d;
*/
    return datas;
}

/* ************************************************************************** */

/*!
 * \brief Device::getHours
 * \return List of hours
 *
 * Two possibilities:
 * - We have datas, so we go from last data available +24
 * - We don't have datas, so we go from current hour to +24
 */
QVariantList Device::getHours()
{
    QVariantList lastTwentyfourHours;
    int firstHour = -1;

    QSqlQuery datasPerHour;
    datasPerHour.prepare("SELECT strftime('%H', ts) as 'hours' " \
                         "FROM datas " \
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day','+2 hour') " \
                         "ORDER BY ts ASC;");
    datasPerHour.bindValue(":deviceAddr", getAddress());

    if (datasPerHour.exec() == false)
        qWarning() << "> dataPerHours.exec() ERROR" << datasPerHour.lastError().type() << ":"  << datasPerHour.lastError().text();

    while (datasPerHour.next())
    {
        if (firstHour == -1)
        {
            firstHour = datasPerHour.value(0).toInt();
        }
    }

    if (firstHour == -1) // We don't have datas
    {
        QTime now = QTime::currentTime();
        while (lastTwentyfourHours.size() < 24)
        {
            lastTwentyfourHours.append(now.hour());
            now = now.addSecs(3600);
        }
    }
    else // We have datas
    {
        QTime now(firstHour, 0);
        while (lastTwentyfourHours.size() < 24)
        {
            lastTwentyfourHours.append(now.hour());
            now = now.addSecs(3600);
        }
    }
/*
    // debug
    qDebug() << "Hours (" << lastTwentyfourHours.size() << ") : ";
    for (auto h: lastTwentyfourHours)
        qDebug() << h;
*/
    return lastTwentyfourHours;
}

QVariantList Device::getDatasHourly(const QString &dataName)
{
    QVariantList datas;
    QTime nexHourToHandle = QTime::currentTime();
    int firstHour = -1;

    QSqlQuery datasPerHour;
    datasPerHour.prepare("SELECT strftime('%H', ts) as 'hour', " + dataName + " " \
                         "FROM datas " \
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day', '+2 hour') " \
                         "ORDER BY ts ASC;");
    datasPerHour.bindValue(":deviceAddr", getAddress());

    if (datasPerHour.exec() == false)
        qWarning() << "> datasPerHour.exec() ERROR" << datasPerHour.lastError().type() << ":"  << datasPerHour.lastError().text();

    while (datasPerHour.next() && (datas.size() < 24))
    {
        int currentHour = datasPerHour.value(0).toInt();

        if (firstHour == -1)
        {
            firstHour = datasPerHour.value(0).toInt();
            nexHourToHandle = QTime(firstHour, 0);
        }

        // fill holes
        while (currentHour != nexHourToHandle.hour() && (datas.size() < 24))
        {
            datas.append(0);
            //qDebug() << "> filling hole for hour" << nexHourToHandle.hour();

            nexHourToHandle = nexHourToHandle.addSecs(3600);
        }
        nexHourToHandle = nexHourToHandle.addSecs(3600);

        datas.append(datasPerHour.value(1));
        //qDebug() << "> we have data for hour" << currentHour << ", next hour to handle is" << nexHourToHandle.hour();
    }

    // add front padding (if we don't have 24H)
    while (datas.size() < 24)
    {
        datas.append(0);
    }
/*
    // debug
    qDebug() << "Datas (" << dataName << "/" << datas.size() << ") : ";
    for (auto d: datas)
        qDebug() << d;
*/
    return datas;
}

QVariantList Device::getBackgroundHourly(float maxValue)
{
    QVariantList lastTwentyfourHours;
    int firstHour = -1;

    QSqlQuery datasPerHour;
    datasPerHour.prepare("SELECT strftime('%H', ts) as 'hours' " \
                         "FROM datas " \
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day','+2 hour') " \
                         "ORDER BY ts ASC;");
    datasPerHour.bindValue(":deviceAddr", getAddress());

    if (datasPerHour.exec() == false)
        qWarning() << "> dataPerHours.exec() ERROR" << datasPerHour.lastError().type() << ":"  << datasPerHour.lastError().text();

    while (datasPerHour.next())
    {
        if (firstHour == -1)
        {
            firstHour = datasPerHour.value(0).toInt();
        }
    }

    if (firstHour == -1) // We don't have datas
    {
        QTime now = QTime::currentTime();
        while (lastTwentyfourHours.size() < 24)
        {
            if (now.hour() >= 21 || now.hour() <= 8)
                lastTwentyfourHours.append(0);
            else
                lastTwentyfourHours.append(maxValue);

            now = now.addSecs(3600);
        }
    }
    else // We have datas
    {
        QTime now(firstHour, 0);
        while (lastTwentyfourHours.size() < 24)
        {
            if (now.hour() >= 21 || now.hour() <= 8)
                lastTwentyfourHours.append(0);
            else
                lastTwentyfourHours.append(maxValue);

            now = now.addSecs(3600);
        }
    }

    return lastTwentyfourHours;
}

QVariantList Device::getBackgroundNightly(float maxValue)
{
    QVariantList lastTwentyfourHours;
    int firstHour = -1;

    QSqlQuery datasPerHour;
    datasPerHour.prepare("SELECT strftime('%H', ts) as 'hours' " \
                         "FROM datas " \
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day','+2 hour') " \
                         "ORDER BY ts ASC;");
    datasPerHour.bindValue(":deviceAddr", getAddress());

    if (datasPerHour.exec() == false)
        qWarning() << "> dataPerHours.exec() ERROR" << datasPerHour.lastError().type() << ":"  << datasPerHour.lastError().text();

    while (datasPerHour.next())
    {
        if (firstHour == -1)
            firstHour = datasPerHour.value(0).toInt();
    }

    if (firstHour == -1) // We don't have datas
    {
        QTime now = QTime::currentTime();
        while (lastTwentyfourHours.size() < 24)
        {
            if (now.hour() >= 21 || now.hour() <= 8)
                lastTwentyfourHours.append(maxValue);
            else
                lastTwentyfourHours.append(0);
            now = now.addSecs(3600);
        }
    }
    else // We have datas
    {
        QTime now(firstHour, 0);
        while (lastTwentyfourHours.size() < 24)
        {
            if (now.hour() >= 21 || now.hour() <= 8)
                lastTwentyfourHours.append(maxValue);
            else
                lastTwentyfourHours.append(0);
            now = now.addSecs(3600);
        }
    }

    return lastTwentyfourHours;
}

QVariantList Device::getBackgroundDaily(float maxValue)
{
    QVariantList lastSevenDays;

    while (lastSevenDays.size() < 7)
    {
        lastSevenDays.append(maxValue);
    }

    return lastSevenDays;
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::getAioDatas(QtCharts::QDateTimeAxis *axis,
                         QtCharts::QLineSeries *hygro, QtCharts::QLineSeries *temp,
                         QtCharts::QLineSeries *lumi, QtCharts::QLineSeries *cond)
{
    if (!axis || !hygro || !temp || !lumi || !cond)
        return;

    QSqlQuery graphDatas;
    graphDatas.prepare("SELECT temp, hygro, luminosity, conductivity, ts_full " \
                       "FROM datas " \
                       "WHERE deviceAddr = :deviceAddr AND ts_full >= datetime('now', 'localtime', '-" + QString::number(14) + " days');");
    graphDatas.bindValue(":deviceAddr", getAddress());

    if (graphDatas.exec() == false)
    {
        qWarning() << "> graphDatas.exec() ERROR" << graphDatas.lastError().type() << ":"  << graphDatas.lastError().text();
        return;
    }

    axis->setFormat("dd MMM");
    bool minSet = false;
    axis->setMax(QDateTime::currentDateTime());

    while (graphDatas.next())
    {
        QDateTime date = QDateTime::fromString(graphDatas.value(4).toString(), "yyyy-MM-dd hh:mm:ss");
        if (!minSet) {
            axis->setMin(date);
            minSet = true;
        }
        int64_t timecode = date.toMSecsSinceEpoch();

        temp->append(timecode, graphDatas.value(0).toReal());
        hygro->append(timecode, graphDatas.value(1).toReal());
        lumi->append(timecode, graphDatas.value(2).toReal());
        cond->append(timecode, graphDatas.value(3).toReal());
    }
}
