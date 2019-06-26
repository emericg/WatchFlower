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

#include "device_hygrotemp.h"
#include "versionchecker.h"

#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>

/* ************************************************************************** */

DeviceHygrotemp::DeviceHygrotemp(QString &deviceAddr, QString &deviceName, QObject *parent):
    Device(deviceAddr, deviceName, parent)
{
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_HYGROMETRY;
}

DeviceHygrotemp::DeviceHygrotemp(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_HYGROMETRY;
}

DeviceHygrotemp::~DeviceHygrotemp()
{
    delete serviceData;
    delete serviceBattery;
    delete serviceInfo;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceHygrotemp::serviceScanDone()
{
    //qDebug() << "DeviceHygrotemp::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceHygrotemp::serviceDetailsDiscovered);
            serviceBattery->discoverDetails();
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceHygrotemp::serviceDetailsDiscovered);
            connect(serviceData, &QLowEnergyService::descriptorWritten, this, &DeviceHygrotemp::confirmedDescriptorWrite);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceHygrotemp::bleReadNotify);
            serviceData->discoverDetails();
        }
    }

    if (serviceInfo)
    {
        if (serviceInfo->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceInfo, &QLowEnergyService::stateChanged, this, &DeviceHygrotemp::serviceDetailsDiscovered); // custom
            serviceInfo->discoverDetails();
        }
    }
}

void DeviceHygrotemp::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotemp::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // DeviceHygrotemp Information
    {
        delete serviceInfo;

        serviceInfo = controller->createServiceObject(uuid);
        if (!serviceInfo)
            qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
    }
/*
    if (uuid.toString() == "{0000180f-0000-1000-8000-00805f9b34fb}") // (unknown service) // battery
    {
        m_capabilities += DEVICE_BATTERY;
        Q_EMIT statusUpdated();

        delete serviceBattery;

        serviceBattery = controller->createServiceObject(uuid);
        if (!serviceBattery)
            qWarning() << "Cannot create service (battery) for uuid:" << uuid.toString();
    }
*/
    if (uuid.toString() == "{226c0000-6476-4566-7562-66734470666d}") // (unknown service) // datas
    {
        delete serviceData;

        serviceData = controller->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (datas) for uuid:" << uuid.toString();
    }
}

void DeviceHygrotemp::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{
    //qDebug() << "DeviceHygrotemp::serviceDetailsDiscovered(" << m_deviceAddress << ")";

    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        if (serviceData)
        {
            // Characteristic "Temp&Humi"
            QBluetoothUuid a(QString("226caa55-6476-4566-7562-66734470666d")); // handler 0x??
            QLowEnergyCharacteristic cha = serviceData->characteristic(a);
            m_notificationDesc = cha.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
            serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));

            // Characteristic "Message"
            //QBluetoothUuid b(QString("226cbb55-6476-4566-7562-66734470666d")); // handler 0x??
        }
/*
        if (serviceBattery)
        {
            // Characteristic "?"
            QBluetoothUuid b(QString("00002a19-0000-1000-8000-00805f9b34fb")); // handler 0x??
            QLowEnergyCharacteristic chb = serviceData->characteristic(b);
            if (chb.value().size() == 1)
            {
                m_battery = chb.value();
            }
        }
*/
        if (serviceInfo)
        {
            // Characteristic "Firmware Revision String"
            QBluetoothUuid c(QString("00002a26-0000-1000-8000-00805f9b34fb")); // handler 0x19
            QLowEnergyCharacteristic chc = serviceInfo->characteristic(c);
            if (chc.value().size() > 0)
            {
               m_firmware = chc.value();
            }

            if (m_firmware.size() == 8)
            {
                if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT datasUpdated();
                }
            }
        }

        Q_EMIT sensorUpdated();
    }
}

void DeviceHygrotemp::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotemp::bleWriteDone(" << m_deviceAddress << ")";
}

void DeviceHygrotemp::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    Q_UNUSED(c)
    Q_UNUSED(value)
/*
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    qDebug() << "DeviceHygrotemp::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATAS: 0x" \
               << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
               << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
               << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[10] \
               << hex << data[12]  << hex << data[13]  << hex << data[14] << hex << data[15];
*/
}

void DeviceHygrotemp::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceHygrotemp::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATAS: 0x" \
               << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
               << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
               << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[10] \
               << hex << data[12]  << hex << data[13];
*/
    if (c.uuid().toString() == "{226caa55-6476-4566-7562-66734470666d}")
    {
        // BLE temperature & humidity sensor datas // handler 0x??

        if (value.size() > 0)
        {
            // Validate data format
            if (data[1] != 0x3D && data[8] != 0x3D)
                return;

            m_temp = value.mid(2, 4).toFloat();
            m_hygro = static_cast<int>(value.mid(9, 4).toFloat()); // FIXME hygro could be a float too

            m_lastUpdate = QDateTime::currentDateTime();

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceHygrotemp update:" << getAddress();
            qDebug() << "- m_firmware:" << m_firmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_temp:" << m_temp;
            qDebug() << "- m_hygro:" << m_hygro;
#endif
            // TODO not working...
            //controller->disconnectFromDevice();

            //if (m_db)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addDatas;
                addDatas.prepare("REPLACE INTO datas (deviceAddr, ts, ts_full, temp, hygro)"
                                 " VALUES (:deviceAddr, :ts, :ts_full, :temp, :hygro)");
                addDatas.bindValue(":deviceAddr", getAddress());
                addDatas.bindValue(":ts", tsStr);
                addDatas.bindValue(":ts_full", tsFullStr);
                addDatas.bindValue(":temp", m_temp);
                addDatas.bindValue(":hygro", m_hygro);
                if (addDatas.exec() == false)
                    qDebug() << "> addDatas.exec() ERROR" << addDatas.lastError().type() << ":"  << addDatas.lastError().text();

                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceFirmware = :firmware, deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":firmware", m_firmware);
                updateDevice.bindValue(":battery", m_battery);
                updateDevice.bindValue(":deviceAddr", getAddress());
                if (updateDevice.exec() == false)
                    qDebug() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":"  << updateDevice.lastError().text();
            }

            refreshDatasFinished(true);
        }
    }
}

void DeviceHygrotemp::confirmedDescriptorWrite(const QLowEnergyDescriptor &d, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotemp::confirmedDescriptorWrite!";

    if (d.isValid() && d == m_notificationDesc && value == QByteArray::fromHex("0000"))
    {
        qDebug() << "confirmedDescriptorWrite() disconnect?!";

        //disabled notifications -> assume disconnect intent
        //m_control->disconnectFromDevice();
        //delete m_service;
        //m_service = 0;
    }
}
