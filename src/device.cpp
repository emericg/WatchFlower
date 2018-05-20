/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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

Device::Device(QString &deviceAddr, QString &deviceName)
{
    if (deviceAddr.size() != 17)
        qWarning() << "DeviceInfo() '" << deviceAddr << "' is an invalid mac address...";

    QBluetoothAddress bleAddr(deviceAddr);

    bleDevice = QBluetoothDeviceInfo(bleAddr, deviceName, 0);
    m_deviceAddress = deviceAddr;
    m_deviceName = deviceName;
    m_customName = deviceName;

    if (bleDevice.isValid() == false)
        qWarning() << "DeviceInfo() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";

    // Initial update
    getSqlDatas();
    refreshDatas();

    // Timer update
    SettingsManager *sm = SettingsManager::getInstance();
    int updateInterval = sm->getUpdateInterval();
    if (updateInterval < 5 || updateInterval > 120) updateInterval = UPDATE_INTERVAL;

    m_updateTimer.setInterval(updateInterval*60*1000);
    connect(&m_updateTimer, &QTimer::timeout, this, &Device::refreshDatas);
    m_updateTimer.start();
}

Device::Device(const QBluetoothDeviceInfo &d)
{
    bleDevice = d;
    m_deviceAddress = bleDevice.address().toString();
    m_deviceName = bleDevice.name();
    m_customName = bleDevice.name();

    if (bleDevice.isValid() == false)
        qWarning() << "DeviceInfo() '" << m_deviceAddress << "' is an invalid QBluetoothDeviceInfo...";

    // Initial update
    getSqlDatas();
    refreshDatas();

    // Timer update
    SettingsManager *sm = SettingsManager::getInstance();
    int updateInterval = sm->getUpdateInterval();
    if (updateInterval < 5 || updateInterval > 120) updateInterval = UPDATE_INTERVAL;

    m_updateTimer.setInterval(updateInterval*60*1000);
    connect(&m_updateTimer, &QTimer::timeout, this, &Device::refreshDatas);
    m_updateTimer.start();
}

Device::~Device()
{
    delete controller;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::refreshDatasStarted()
{
    m_available = false;
    m_updating = true;
    Q_EMIT statusUpdated();
}

bool Device::refreshDatas()
{
    bool status = false;

    refreshDatasStarted();

    if (getSqlCachedDatas() == false)
    {
        if (getBleDatas())
        {
            //
        }
        else
        {
            m_available = false;
            refreshDatasFinished();
        }
    }

    return status;
}

void Device::refreshDatasFinished()
{
    m_updating = false;
    Q_EMIT statusUpdated();
    Q_EMIT datasUpdated();
}

/* ************************************************************************** */

bool Device::getSqlDatas()
{
    //qDebug() << "DeviceInfo::getSqlDatas(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery getFirmware;
    getFirmware.prepare("SELECT deviceFirmware FROM devices WHERE deviceAddr = :deviceAddr");
    getFirmware.bindValue(":deviceAddr", getMacAddress());
    getFirmware.exec();
    while (getFirmware.next())
    {
        m_firmware = getFirmware.value(0).toString();
        status = true;
    }

    QSqlQuery getBattery;
    getBattery.prepare("SELECT deviceBattery FROM devices WHERE deviceAddr = :deviceAddr");
    getBattery.bindValue(":deviceAddr", getMacAddress());
    getBattery.exec();
    while (getBattery.next())
    {
        m_battery = getBattery.value(0).toInt();
        status = true;
    }

    QSqlQuery getCustomName;
    getCustomName.prepare("SELECT customName FROM devices WHERE deviceAddr = :deviceAddr");
    getCustomName.bindValue(":deviceAddr", getMacAddress());
    getCustomName.exec();
    while (getCustomName.next())
    {
        m_customName = getCustomName.value(0).toString();
        status = true;
    }

    QSqlQuery getPlantName;
    getPlantName.prepare("SELECT plantName FROM devices WHERE deviceAddr = :deviceAddr");
    getPlantName.bindValue(":deviceAddr", getMacAddress());
    getPlantName.exec();
    while (getPlantName.next())
    {
        m_plantName = getPlantName.value(0).toString();
        status = true;
    }

    return status;
}

bool Device::getSqlCachedDatas()
{
    //qDebug() << "DeviceInfo::getSqlCachedDatas(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedDatas;
    cachedDatas.prepare("SELECT temp, hygro, luminosity, conductivity " \
                        "FROM datas " \
                        "WHERE deviceAddr = :deviceAddr AND ts_full >= datetime('now', 'localtime', '-5 minutes');");
    cachedDatas.bindValue(":deviceAddr", getMacAddress());

    if (cachedDatas.exec() == false)
        qDebug() << "> cachedDatas.exec() ERROR" << cachedDatas.lastError().type() << ":"  << cachedDatas.lastError().text();

    while (cachedDatas.next())
    {
        qDebug() << "Using cachedDatas";
        status = true;

        m_temp = cachedDatas.value(0).toInt();
        m_hygro =  cachedDatas.value(1).toInt();
        m_luminosity =  cachedDatas.value(2).toInt();
        m_conductivity = cachedDatas.value(3).toInt();

        m_available = true;

        refreshDatasFinished();
    }

    return status;
}

bool Device::getBleDatas()
{
    //qDebug() << "DeviceInfo::getDatas(" << m_deviceAddress << ")";

    if (!controller)
    {
        controller = new QLowEnergyController(bleDevice);
        if (controller)
        {
            if (controller->role() != QLowEnergyController::CentralRole)
            {
                qWarning() << "BLE controller doesn't have the QLowEnergyController::CentralRole";
                return false;
            }

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
            return false;
        }
    }
    else
    {
        if (controller)
            qDebug() << "Current BLE controller state:" << controller->state();
    }

    controller->setRemoteAddressType(QLowEnergyController::PublicAddress);
    controller->connectToDevice();

    return true;
}

/* ************************************************************************** */

float Device::getTemp() const
{
    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        return (m_temp * 9.0/5.0 + 32.0);
    else
        return m_temp;
}

QString Device::getTempString() const
{
    QString tempString;

    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        tempString = QString::number((m_temp * 9.0/5.0 + 32.0), 'f', 1) + "°F";
    else
        tempString = QString::number(m_temp, 'f', 1) + "°C";

    return tempString;
}

QString Device::getDataString() const
{
    QString dataString;

    dataString += getTempString() + "  ";
    dataString += QString::number(m_hygro) + "%  ";
    dataString += QString::number(m_luminosity) + " lm";

    return dataString;
}

void Device::setCustomName(QString name)
{
    if (!name.isEmpty())
    {
        m_customName = name;
        qDebug() << "setCustomName(" << m_customName << ")";

        QSqlQuery updateName;
        updateName.prepare("UPDATE devices SET customName = :name WHERE deviceAddr = :deviceAddr");
        updateName.bindValue(":name", name);
        updateName.bindValue(":deviceAddr", getMacAddress());
        updateName.exec();
    }
}

void Device::setPlantName(QString name)
{
    if (!name.isEmpty())
    {
        m_plantName = name;
        qDebug() << "setPlantName(" << m_plantName << ")";

        QSqlQuery updatePlant;
        updatePlant.prepare("UPDATE devices SET plantName = :name WHERE deviceAddr = :deviceAddr");
        updatePlant.bindValue(":name", name);
        updatePlant.bindValue(":deviceAddr", getMacAddress());
        updatePlant.exec();
    }
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
    for (int i = 0; i < lastSevenDays.size(); i++)
    {
        QString day = qvariant_cast<QString>(lastSevenDays.at(i));
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

QVariantList Device::getDatasDaily(QString dataName)
{
    QVariantList datas;
    QDate nextDayToHandle = QDate::currentDate();

    QSqlQuery datasPerDay;
    datasPerDay.prepare("SELECT strftime('%Y-%m-%d', ts) as 'date', strftime('%d', ts) as 'day', avg(" + dataName + ") as 'avg' " \
                        "FROM datas WHERE deviceAddr = :deviceAddr " \
                        "GROUP BY cast(strftime('%d', ts) as datetime) " \
                        "ORDER BY ts DESC;");
    datasPerDay.bindValue(":deviceAddr", getMacAddress());

    if (datasPerDay.exec() == false)
        qDebug() << "> dataPerDay.exec() ERROR" << datasPerDay.lastError().type() << ":"  << datasPerDay.lastError().text();

    while (datasPerDay.next())
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
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day','+1 hour') " \
                         "ORDER BY ts ASC;");
    datasPerHour.bindValue(":deviceAddr", getMacAddress());

    if (datasPerHour.exec() == false)
        qDebug() << "> dataPerHours.exec() ERROR" << datasPerHour.lastError().type() << ":"  << datasPerHour.lastError().text();

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

QVariantList Device::getDatasHourly(QString dataName)
{
    QVariantList datas;
    QTime nexHourToHandle = QTime::currentTime();
    int firstHour = -1;

    QSqlQuery datasPerHour;
    datasPerHour.prepare("SELECT strftime('%H', ts) as 'hour', " + dataName + " " \
                         "FROM datas " \
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day', '+1 hour') " \
                         "ORDER BY ts ASC;");
    datasPerHour.bindValue(":deviceAddr", getMacAddress());

    if (datasPerHour.exec() == false)
        qDebug() << "> datasPerHour.exec() ERROR" << datasPerHour.lastError().type() << ":"  << datasPerHour.lastError().text();

    while (datasPerHour.next())
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

/* ************************************************************************** */
/* ************************************************************************** */

void Device::deviceConnected()
{
    //qDebug() << "DeviceInfo::deviceConnected(" << m_deviceAddress << ")";

    m_available = true;
    controller->discoverServices();
}

void Device::deviceDisconnected()
{
    //qDebug() << "DeviceInfo::deviceDisconnected(" << m_deviceAddress << ")";
    refreshDatasFinished();
}

void Device::disconnectFromDevice()
{
    //qDebug() << "DeviceInfo::disconnectFromDevice(" << m_deviceAddress << ")";
}

void Device::errorReceived(QLowEnergyController::Error error)
{
    qDebug() << "DeviceInfo::errorReceived(" << m_deviceAddress << ") error:" << error;

    m_available = false;
    refreshDatasFinished();
}

void Device::serviceScanDone()
{
    //qDebug() << "DeviceInfo::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &Device::serviceDetailsDiscovered);

            connect(serviceData, &QLowEnergyService::characteristicWritten, this, &Device::bleWriteDone);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &Device::bleReadDone);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &Device::bleReadDone);

            serviceData->discoverDetails();
        }
    }
}

void Device::addLowEnergyService(const QBluetoothUuid &uuid)
{
    if (uuid.toString() == "{00001204-0000-1000-8000-00805f9b34fb}") // generic tel
    {
        //qDebug() << "DeviceInfo::addLowEnergyService() uuid:" << uuid;

        if (serviceData)
            delete serviceData;

        serviceData = controller->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service for uuid";
    }
}

void Device::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{
    //qDebug() << "DeviceInfo::serviceDetailsDiscovered(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::ServiceDiscovered)
        {
            QBluetoothUuid c(QString("00001a02-0000-1000-8000-00805f9b34fb")); // handler 0x38
            QLowEnergyCharacteristic chc = serviceData->characteristic(c);
            if (chc.value().size() > 0)
            {
                m_battery = chc.value().at(0);
                m_firmware = chc.value().remove(0, 2);
            }

            // if firmware > 2.6.6
            {
                QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handler 0x33
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                QByteArray aaaaa = QByteArray::fromHex("A01F");
                serviceData->writeCharacteristic(cha, aaaaa, QLowEnergyService::WriteWithResponse);
            }

            QBluetoothUuid b(QString("00001a01-0000-1000-8000-00805f9b34fb")); // handler 0x35
            QLowEnergyCharacteristic chb = serviceData->characteristic(b);
            serviceData->readCharacteristic(chb);
        }
        else
        {
            qWarning() << "DeviceInfo::serviceDetailsDiscovered() state is:" << newState;
        }
    }

    return;
}

bool Device::hasControllerError() const
{
    if (controller && controller->error() != QLowEnergyController::NoError)
        return true;

    return false;
}

void Device::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceInfo::bleWriteDone(" << m_deviceAddress << ")";
}

void Device::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "bleReadDone on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "bleReadDone WE HAVE DATAS: 0x" \
               << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
               << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
               << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[10] \
               << hex << data[12]  << hex << data[13]  << hex << data[14] << hex << data[15];
*/
    if (c.uuid().toString() == "{00001a01-0000-1000-8000-00805f9b34fb}") // handler 0x35
    {
        if (value.size() > 0)
        {
            m_temp = (data[0] + (data[1] << 8)) / 10.0;
            m_hygro = data[7];
            m_luminosity = data[3] + (data[4] << 8);
            m_conductivity = data[8] + (data[9] << 8);

#ifndef NDEBUG
            qDebug() << "* Device:" << getMacAddress();
            qDebug() << "- m_firmware:" << m_firmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_temp:" << m_temp;
            qDebug() << "- m_hygro:" << m_hygro;
            qDebug() << "- m_luminosity:" << m_luminosity;
            qDebug() << "- m_conductivity:" << m_conductivity;
#endif // NDEBUG

            refreshDatasFinished();
            controller->disconnectFromDevice();

            //if (m_db)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addDatas;
                addDatas.prepare("REPLACE INTO datas (deviceAddr, ts, ts_full, temp, hygro, luminosity, conductivity) VALUES (:deviceAddr, :ts, :ts_full, :temp, :hygro, :luminosity, :conductivity)");
                addDatas.bindValue(":deviceAddr", getMacAddress());
                addDatas.bindValue(":ts", tsStr);
                addDatas.bindValue(":ts_full", tsFullStr);
                addDatas.bindValue(":temp", m_temp);
                addDatas.bindValue(":hygro", m_hygro);
                addDatas.bindValue(":luminosity", m_luminosity);
                addDatas.bindValue(":conductivity", m_conductivity);
                if (addDatas.exec() == false)
                    qDebug() << "> addDatas.exec() ERROR" << addDatas.lastError().type() << ":"  << addDatas.lastError().text();

                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceFirmware = :firmware, deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":firmware", m_firmware);
                updateDevice.bindValue(":battery", m_battery);
                updateDevice.bindValue(":deviceAddr", getMacAddress());
                if (updateDevice.exec() == false)
                    qDebug() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":"  << updateDevice.lastError().text();
            }
        }
    }
}
