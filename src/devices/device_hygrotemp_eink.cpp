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

#include "device_hygrotemp_eink.h"
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

DeviceHygrotempEInk::DeviceHygrotempEInk(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempEInk::DeviceHygrotempEInk(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempEInk::~DeviceHygrotempEInk()
{
    delete serviceData;
    delete serviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceHygrotempEInk::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempEInk::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceHygrotempEInk::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceHygrotempEInk::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }

    if (serviceInfos)
    {
        if (m_deviceFirmware.isEmpty() || m_deviceFirmware == "UNKN")
        {
            if (serviceInfos->state() == QLowEnergyService::DiscoveryRequired)
            {
                connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceHygrotempEInk::serviceDetailsDiscovered_infos);

                // Windows hack, see: QTBUG-80770 and QTBUG-78488
                QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
            }
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempEInk::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempEInk::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // infos
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        serviceInfos = controller->createServiceObject(uuid);
        if (!serviceInfos)
            qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
    }

    if (uuid.toString() == "{22210000-554a-4546-5542-46534450464d}") // (unknown service) // data
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = controller->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceHygrotempEInk::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempEInk::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            //
            {
                QBluetoothUuid a(QString("00000100-0000-1000-8000-00805f9b34fb")); // handler 0x??
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                m_notificationDesc = cha.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
                serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
            }
        }
    }
}

void DeviceHygrotempEInk::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempEInk::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            // Characteristic "Firmware Revision String"
            QBluetoothUuid c(QString("00002a26-0000-1000-8000-00805f9b34fb")); // handler 0x0b
            QLowEnergyCharacteristic chc = serviceInfos->characteristic(c);
            if (chc.value().size() > 0)
            {
               m_deviceFirmware = chc.value();
            }

            if (m_deviceFirmware.size() == 10)
            {
                if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
            }
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempEInk::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotempEInk::bleWriteDone(" << m_deviceAddress << ")";
}

void DeviceHygrotempEInk::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    Q_UNUSED(c)
    Q_UNUSED(value)
/*
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    qDebug() << "DeviceHygrotempEInk::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATA: 0x" \
               << hex << data[0] << hex << data[1] << hex << data[2] << hex << data[3] << hex << data[4] << hex << data[5];
*/
}

void DeviceHygrotempEInk::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceHygrotempEInk::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATA: 0x" \
               << hex << data[0] << hex << data[1] << hex << data[2] << hex << data[3] << hex << data[4] << hex << data[5];
*/
    if (c.uuid().toString().toUpper() == "{00000100-0000-1000-8000-00805F9B34FB}")
    {
        // sensor data // handler 0x??

        if (value.size() == 6)
        {
            m_temperature = static_cast<int16_t>(data[2] + (data[3] << 8)) / 10.f;
            m_humidity = static_cast<int16_t>(data[4] + (data[5] << 8)) / 10;

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_dbInternal || m_dbExternal)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addData;
                addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, temperature, humidity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :temp, :humi)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tsStr);
                addData.bindValue(":ts_full", tsFullStr);
                addData.bindValue(":temp", m_temperature);
                addData.bindValue(":humi", m_humidity);
                if (addData.exec() == false)
                    qWarning() << "> addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();

                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceFirmware = :firmware, deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":firmware", m_deviceFirmware);
                updateDevice.bindValue(":battery", m_battery);
                updateDevice.bindValue(":deviceAddr", getAddress());
                if (updateDevice.exec() == false)
                    qWarning() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":" << updateDevice.lastError().text();
            }

            refreshDataFinished(true);
            controller->disconnectFromDevice();

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceHygrotempEInk update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
#endif
        }
    }
}

void DeviceHygrotempEInk::confirmedDescriptorWrite(const QLowEnergyDescriptor &d, const QByteArray &value)
{
    qDebug() << "DeviceHygrotempEInk::confirmedDescriptorWrite!";

    if (d.isValid() && d == m_notificationDesc && value == QByteArray::fromHex("0000"))
    {
        qDebug() << "confirmedDescriptorWrite() disconnect?!";

        //disabled notifications -> assume disconnect intent
        //m_control->disconnectFromDevice();
        //delete m_service;
        //m_service = nullptr;
    }
}
