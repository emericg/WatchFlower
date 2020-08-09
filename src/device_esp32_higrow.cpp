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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_esp32_higrow.h"
#include "utils/utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>

/* ************************************************************************** */

DeviceEsp32HiGrow::DeviceEsp32HiGrow(QString &deviceAddr, QString &deviceName, QObject *parent):
    Device(deviceAddr, deviceName, parent)
{
    m_deviceType = DEVICE_PLANTSENSOR;

    m_capabilities += DEVICE_BATTERY;
    m_capabilities += DEVICE_SOIL_MOISTURE;
    m_capabilities += DEVICE_SOIL_CONDUCTIVITY;
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_HUMIDITY;
    m_capabilities += DEVICE_LIGHT;
}

DeviceEsp32HiGrow::DeviceEsp32HiGrow(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    m_deviceType = DEVICE_PLANTSENSOR;

    m_capabilities += DEVICE_BATTERY;
    m_capabilities += DEVICE_SOIL_MOISTURE;
    m_capabilities += DEVICE_SOIL_CONDUCTIVITY;
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_HUMIDITY;
    m_capabilities += DEVICE_LIGHT;
}

DeviceEsp32HiGrow::~DeviceEsp32HiGrow()
{
    controller->disconnectFromDevice();
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEsp32HiGrow::serviceScanDone()
{
    //qDebug() << "DeviceEsp32HiGrow::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceEsp32HiGrow::serviceDetailsDiscovered);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceEsp32HiGrow::bleReadDone);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceEsp32HiGrow::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, [=] () { serviceData->discoverDetails(); });
        }
    }
}

void DeviceEsp32HiGrow::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceEsp32HiGrow::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{eeee9a32-a000-4cbd-b00b-6b519bf2780f}") // custom data service
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = controller->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

void DeviceEsp32HiGrow::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32HiGrow::serviceDetailsDiscovered(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            QBluetoothUuid f(QString("eeee9a32-a002-4cbd-b00b-6b519bf2780f")); // firmware
            QLowEnergyCharacteristic chf = serviceData->characteristic(f);
            if (chf.value().size() > 0)
            {
                m_firmware = chf.value();
            }
            if (m_firmware.size() == 3)
            {
                if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_ESP32_HIGROW))
                {
                    m_firmware_uptodate = true;
                }
            }

            QBluetoothUuid b(QString("eeee9a32-a003-4cbd-b00b-6b519bf2780f")); // battery
            QLowEnergyCharacteristic chb = serviceData->characteristic(b);
            if (chb.value().size() > 0)
            {
                m_battery = chb.value().toInt();
            }

            Q_EMIT sensorUpdated();

            QBluetoothUuid rt(QString("eeee9a32-a0a0-4cbd-b00b-6b519bf2780f")); // rt data
            QLowEnergyCharacteristic chrt = serviceData->characteristic(rt);
            //serviceData->readCharacteristic(chrt);
            m_notificationDesc = chrt.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
            serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32HiGrow::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceEsp32HiGrow::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATA: 0x" \
             << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
             << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
             << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[10] \
             << hex << data[12]  << hex << data[13]  << hex << data[14] << hex << data[15];
*/
    if (c.uuid().toString() == "{eeee9a32-a0a0-4cbd-b00b-6b519bf2780f}")
    {
        // HiGrow realtime data // handler 0x?

        if (value.size() == 16)
        {
            m_temperature = static_cast<uint16_t>(data[0] + (data[1] << 8)) / 10.f;
            m_humidity = data[2];
            m_soil_moisture = data[3];
            m_soil_conductivity = static_cast<uint16_t>(data[4] + (data[5] << 8));
            m_luminosity = static_cast<uint32_t>(data[6] + (data[7] << 8) + (data[8] << 16) /*+ (data[6] << 24)*/);

            m_lastUpdate = QDateTime::currentDateTime();

            //if (m_db)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addData;
                addData.prepare("REPLACE INTO datas (deviceAddr, ts, ts_full, temp, hygro, luminosity, conductivity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :temp, :hygro, :luminosity, :conductivity)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tsStr);
                addData.bindValue(":ts_full", tsFullStr);
                addData.bindValue(":temp", m_temperature);
                addData.bindValue(":hygro", m_soil_moisture);
                addData.bindValue(":luminosity", m_luminosity);
                addData.bindValue(":conductivity", m_soil_conductivity);
                if (addData.exec() == false)
                    qWarning() << "> addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();

                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceFirmware = :firmware, deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":firmware", m_firmware);
                updateDevice.bindValue(":battery", m_battery);
                updateDevice.bindValue(":deviceAddr", getAddress());
                if (updateDevice.exec() == false)
                    qWarning() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":" << updateDevice.lastError().text();
            }

            refreshDataFinished(true);
            controller->disconnectFromDevice();

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceEsp32HiGrow update:" << getAddress();
            qDebug() << "- m_firmware:" << m_firmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
            qDebug() << "- m_luminosity:" << m_luminosity;
            qDebug() << "- m_soil_moisture:" << m_soil_moisture;
            qDebug() << "- m_soil_conductivity:" << m_soil_conductivity;
#endif
        }
    }
}
