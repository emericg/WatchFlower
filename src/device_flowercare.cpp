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

#include "device_flowercare.h"
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

DeviceFlowerCare::DeviceFlowerCare(QString &deviceAddr, QString &deviceName, QObject *parent):
    Device(deviceAddr, deviceName, parent)
{
    m_deviceType = DEVICE_PLANTSENSOR;

    m_capabilities += DEVICE_BATTERY;
    m_capabilities += DEVICE_LED;
    m_capabilities += DEVICE_SOIL_MOISTURE;
    m_capabilities += DEVICE_SOIL_CONDUCTIVITY;
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_LIGHT;
}

DeviceFlowerCare::DeviceFlowerCare(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    m_deviceType = DEVICE_PLANTSENSOR;

    m_capabilities += DEVICE_BATTERY;
    m_capabilities += DEVICE_LED;
    m_capabilities += DEVICE_SOIL_MOISTURE;
    m_capabilities += DEVICE_SOIL_CONDUCTIVITY;
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_LIGHT;
}

DeviceFlowerCare::~DeviceFlowerCare()
{
    delete serviceHistory;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceFlowerCare::serviceScanDone()
{
    //qDebug() << "DeviceFlowerCare::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, [=] () { serviceData->discoverDetails(); });
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare::serviceDetailsDiscovered_history);
            connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare::bleReadDone);
            connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerCare::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, [=] () { serviceHistory->discoverDetails(); });
        }
    }
}

void DeviceFlowerCare::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceFlowerCare::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{00001204-0000-1000-8000-00805f9b34fb}") // Generic Telephony
    {
        delete serviceData;
        serviceData = nullptr;

        if (m_ble_action != ACTION_UPDATE_HISTORY)
        {
            serviceData = controller->createServiceObject(uuid);
            if (!serviceData)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{00001206-0000-1000-8000-00805f9b34fb}")
    {
        delete serviceHistory;
        serviceHistory = nullptr;

        if (m_ble_action == ACTION_UPDATE_HISTORY)
        {
            serviceHistory = controller->createServiceObject(uuid);
            if (!serviceHistory)
                qWarning() << "Cannot create service (history) for uuid:" << uuid.toString();
        }
    }
}

void DeviceFlowerCare::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData && m_ble_action == ACTION_UPDATE)
        {
            QBluetoothUuid c(QString("00001a02-0000-1000-8000-00805f9b34fb")); // handler 0x38
            QLowEnergyCharacteristic chc = serviceData->characteristic(c);
            if (chc.value().size() > 0)
            {
                m_battery = chc.value().at(0);
                m_firmware = chc.value().remove(0, 2);
            }

            bool need_firstsend = true;
            if (m_firmware.size() == 5)
            {
                if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
                {
                    m_firmware_uptodate = true;
                }
                if (Version(m_firmware) <= Version("2.6.6"))
                {
                    need_firstsend = false;
                }
            }

            Q_EMIT sensorUpdated();

            if (need_firstsend) // if firmware > 2.6.6
            {
                QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                serviceData->writeCharacteristic(cha, QByteArray::fromHex("A01F"), QLowEnergyService::WriteWithResponse);
            }

            QBluetoothUuid b(QString("00001a01-0000-1000-8000-00805f9b34fb")); // handle 0x35
            QLowEnergyCharacteristic chb = serviceData->characteristic(b);
            serviceData->readCharacteristic(chb);
        }

        if (serviceData && m_ble_action == ACTION_LED_BLINK)
        {
            // Make LED blink
            QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
            QLowEnergyCharacteristic cha = serviceData->characteristic(a);
            serviceData->writeCharacteristic(cha, QByteArray::fromHex("FDFF"), QLowEnergyService::WriteWithoutResponse);

            controller->disconnectFromDevice();
        }
    }
}

void DeviceFlowerCare::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHistory && m_ble_action == ACTION_UPDATE_HISTORY)
        {
            qDebug() << "DeviceFlowerCare > HISTORY " << m_ble_action;

            // Change the device mode and wait for a response
            QBluetoothUuid h(QString("00001a10-0000-1000-8000-00805f9b34fb")); // handler 0x3e
            QLowEnergyCharacteristic chh = serviceHistory->characteristic(h);
            serviceHistory->writeCharacteristic(chh, QByteArray::fromHex("A00000"), QLowEnergyService::WriteWithResponse);
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    qDebug() << "DeviceFlowerCare::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();

    if (c.uuid().toString() == "{00001a10-0000-1000-8000-00805f9b34fb}")
    {
        // Device mode has been changed to history

        // Read history entry count
        QBluetoothUuid i(QString("00001a11-0000-1000-8000-00805f9b34fb")); // handler 0x3c
        QLowEnergyCharacteristic chi = serviceHistory->characteristic(i);
        serviceHistory->readCharacteristic(chi);
    }
}

void DeviceFlowerCare::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceFlowerCare::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATA: 0x" \
             << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
             << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
             << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[10] \
             << hex << data[12]  << hex << data[13]  << hex << data[14] << hex << data[15];
*/
    if (c.uuid().toString() == "{00001a11-0000-1000-8000-00805f9b34fb}")
    {
        // Entry count
        int entries = static_cast<int16_t>(data[0] + (data[1] << 8)) / 10.f;
        qDebug() << "History has" << entries << "entries";

        // Read first entry
        //QBluetoothUuid i(QString("00001a11-0000-1000-8000-00805f9b34fb")); // handler 0x3c
        //QLowEnergyCharacteristic chi = serviceHistory->characteristic(i);
        //serviceHistory->writeCharacteristic(chi, QByteArray::fromHex("A10000"), QLowEnergyService::WriteWithResponse);
    }

    if (c.uuid().toString() == "{00001a01-0000-1000-8000-00805f9b34fb}")
    {
        // MiFlora data // handler 0x35

        if (value.size() > 0)
        {
            // first read might send bad data (0x aa bb cc dd ee ff 99 88 77 66...)
            // until the first write is done
            if (data[0] == 0xAA && data[1] == 0xbb)
                return;

            m_temperature = static_cast<int16_t>(data[0] + (data[1] << 8)) / 10.f;
            m_soil_moisture = data[7];
            m_luminosity = data[3] + (data[4] << 8);
            m_soil_conductivity = data[8] + (data[9] << 8);

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
            qDebug() << "* DeviceFlowerCare update:" << getAddress();
            qDebug() << "- m_firmware:" << m_firmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_luminosity:" << m_luminosity;
            qDebug() << "- m_soil_moisture:" << m_soil_moisture;
            qDebug() << "- m_soil_conductivity:" << m_soil_conductivity;
#endif
        }
    }
}
