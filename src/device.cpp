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

Device::Device()
{
    //
}

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
    updateTimer.setInterval(30*60*1000); // 30mins
    connect(&updateTimer, &QTimer::timeout, this, &Device::refreshDatas);
    updateTimer.start();
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
    updateTimer.setInterval(30*60*1000); // 30mins
    connect(&updateTimer, &QTimer::timeout, this, &Device::refreshDatas);
    updateTimer.start();
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

    if (getBleDatas())
    {
        //
    }
    else
    {
        m_available = false;
        refreshDatasFinished();
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

QString Device::getDataString() const
{
    QString dataString;

    dataString += QString::number(m_temp, 'f', 1) + "°C  ";
    dataString += QString::number(m_hygro) + "%  ";
    dataString += QString::number(m_luminosity) + " lux";

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

QVariantList Device::getDays()
{
    QVariantList lastSevenDays;

    QDate firstDay;
    int lastDay = -1;

    QSqlQuery dataPerDay;
    dataPerDay.prepare("SELECT strftime('%Y-%m-%d', ts) as 'date', strftime('%d', ts) as 'day' " \
                       "FROM datas WHERE deviceAddr = :deviceAddr " \
                       "GROUP BY cast(strftime('%d', ts) as datetime) " \
                       "ORDER BY ts ASC;");
    dataPerDay.bindValue(":deviceAddr", getMacAddress());

    if (dataPerDay.exec() == false)
        qDebug() << "> dataPerDay.exec() ERROR" << dataPerDay.lastError().type() << ":"  << dataPerDay.lastError().text();

    while (dataPerDay.next())
    {
        QDate date = QDate::fromString(dataPerDay.value(0).toString(), "yyyy-MM-dd");
        int currentDay = dataPerDay.value(1).toInt();

        // get first day
        if (lastDay == -1)
            firstDay = date;

        // fill holes
        if (lastDay != -1)
        {
            while (((currentDay - 1) > lastDay) && (lastSevenDays.size() < 7))
            {
                QDate dateHole = date.addDays(-1);

                if (lastSevenDays.last() != dateHole.toString("dddd"))
                    lastSevenDays.append(dateHole.toString("dddd"));
                lastDay++;
            }
        }
        lastDay = currentDay;

        lastSevenDays.append(date.toString("dddd"));
    }

    // add front padding if we don't have 7 days
    while (lastSevenDays.size() < 7)
    {
        firstDay = firstDay.addDays(-1);
        lastSevenDays.prepend(firstDay.toString("dddd"));
    }
/*
    // debug
    qDebug() << "Days (" << lastSevenDays.size() << ") : ";
    for (auto d: lastSevenDays)
        qDebug() << d;
*/
    return lastSevenDays;
}

QVariantList Device::getDatasDaily(QString dataName)
{
    QVariantList datas;
    int lastDay = -1;

    QSqlQuery datasPerDay;
    datasPerDay.prepare("SELECT strftime('%Y-%m-%d', ts) as 'date', strftime('%d', ts) as 'day', avg(" + dataName + ") as 'avg' " \
                        "FROM datas WHERE deviceAddr = :deviceAddr " \
                        "GROUP BY cast(strftime('%d', ts) as datetime) " \
                        "ORDER BY ts ASC;");
    datasPerDay.bindValue(":deviceAddr", getMacAddress());

    if (datasPerDay.exec() == false)
        qDebug() << "> dataPerDay.exec() ERROR" << datasPerDay.lastError().type() << ":"  << datasPerDay.lastError().text();

    while (datasPerDay.next())
    {
        int currentDay = datasPerDay.value(1).toInt();

        // fill holes
        if (lastDay != -1)
        {
            while (((currentDay - 1) > lastDay) && (datas.size() < 7))
            {
                datas.append(0);
                lastDay++;
            }
        }
        lastDay = currentDay;

        datas.append(datasPerDay.value(2));
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

QVariantList Device::getHours()
{
    QVariantList lastTwentyfourHours;
    int lastHour = -1;

    QSqlQuery dataPerHours;
    dataPerHours.prepare("SELECT strftime('%H', ts) as 'hours' " \
                         "FROM datas " \
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day') " \
                         "ORDER BY ts ASC;");
    dataPerHours.bindValue(":deviceAddr", getMacAddress());

    if (dataPerHours.exec() == false)
        qDebug() << "> dataPerHours.exec() ERROR" << dataPerHours.lastError().type() << ":"  << dataPerHours.lastError().text();

    while (dataPerHours.next())
    {
        int currentHour = dataPerHours.value(0).toInt();

        // fill holes
        if (lastHour != -1)
        {
            while (lastHour > currentHour && (lastTwentyfourHours.size() < 24)) // front
            {
                lastHour = (++lastHour % 24);
                lastTwentyfourHours.append(lastHour);
            }
            while ((currentHour - 1) > lastHour && (lastTwentyfourHours.size() < 24)) // back
            {
                lastHour++;
                lastTwentyfourHours.append(lastHour);
            }
        }
        lastHour = currentHour;

        lastTwentyfourHours.append(currentHour);
    }

    // add front padding (if we don't have 24H)
    while (lastTwentyfourHours.size() < 24)
    {
        int h = 0;
        if (lastTwentyfourHours.size() > 0)
            h = lastTwentyfourHours.at(0).toInt() - 1;
        if (h < 0)
            h += 24;
        lastTwentyfourHours.prepend(h);
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
    int lastHour = -1;

    QSqlQuery datasPerHour;
    datasPerHour.prepare("SELECT strftime('%H', ts) as 'hour', " + dataName + " " \
                         "FROM datas " \
                         "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day') " \
                         "ORDER BY ts ASC;");
    datasPerHour.bindValue(":deviceAddr", getMacAddress());

    if (datasPerHour.exec() == false)
        qDebug() << "> datasPerHour.exec() ERROR" << datasPerHour.lastError().type() << ":"  << datasPerHour.lastError().text();

    while (datasPerHour.next())
    {
        int currentHour = datasPerHour.value(0).toInt();

        // fill holes
        if (lastHour != -1)
        {
            while (lastHour > currentHour && (datas.size() < 24)) // front
            {
                lastHour = (++lastHour % 24);
                datas.append(0);
            }
            while ((currentHour - 1) > lastHour && (datas.size() < 24)) // back
            {
                lastHour++;
                datas.append(0);
            }
        }
        lastHour = currentHour;

        datas.append(datasPerHour.value(1));
    }

    // add front padding (if we don't have 24H)
    while (datas.size() < 24)
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

            qDebug() << "* Device:" << getMacAddress();
            qDebug() << "- m_firmware:" << m_firmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_temp:" << m_temp;
            qDebug() << "- m_hygro:" << m_hygro;
            qDebug() << "- m_luminosity:" << m_luminosity;
            qDebug() << "- m_conductivity:" << m_conductivity;

            refreshDatasFinished();
            controller->disconnectFromDevice();

            //if (m_db)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");

                QSqlQuery addDatas;
                //addDatas.prepare("INSERT INTO datas (deviceAddr, ts, temp, hygro, luminosity, conductivity) VALUES (:deviceAddr, :ts, :temp, :hygro, :luminosity, :conductivity) ON DUPLICATE KEY UPDATE");
                addDatas.prepare("REPLACE INTO datas (deviceAddr, ts, temp, hygro, luminosity, conductivity) VALUES (:deviceAddr, :ts, :temp, :hygro, :luminosity, :conductivity)");
                addDatas.bindValue(":deviceAddr", getMacAddress());
                addDatas.bindValue(":ts", tsStr);
                addDatas.bindValue(":temp", m_temp);
                addDatas.bindValue(":hygro", m_hygro);
                addDatas.bindValue(":luminosity", m_luminosity);
                addDatas.bindValue(":conductivity", m_conductivity);
                addDatas.exec();
            }
        }
    }
}
