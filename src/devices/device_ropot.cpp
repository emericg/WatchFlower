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

#include "device_ropot.h"
#include "utils/utils_versionchecker.h"
#include "thirdparty/RC4/rc4.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceRopot::DeviceRopot(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
}

DeviceRopot::DeviceRopot(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
}

DeviceRopot::~DeviceRopot()
{
    delete serviceData;
    delete serviceHandshake;
    delete serviceHistory;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceRopot::serviceScanDone()
{
    //qDebug() << "DeviceRopot::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceRopot::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceRopot::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }

    if (serviceHandshake)
    {
        if (serviceHandshake->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceHandshake, &QLowEnergyService::stateChanged, this, &DeviceRopot::serviceDetailsDiscovered_handshake);
            connect(serviceHandshake, &QLowEnergyService::characteristicChanged, this, &DeviceRopot::bleReadNotify);
            connect(serviceHandshake, &QLowEnergyService::characteristicRead, this, &DeviceRopot::bleReadDone);
            connect(serviceHandshake, &QLowEnergyService::characteristicWritten, this, &DeviceRopot::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHandshake->discoverDetails(); });
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceRopot::serviceDetailsDiscovered_history);
            connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceRopot::bleReadDone);
            connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceRopot::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHistory->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceRopot::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceRopot::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{00001204-0000-1000-8000-00805f9b34fb}") // Generic Telephony
    {
        delete serviceData;
        serviceData = nullptr;

        if (m_ble_action != DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceData = controller->createServiceObject(uuid);
            if (!serviceData)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{0000fe95-0000-1000-8000-00805f9b34fb}")
    {
        delete serviceHandshake;
        serviceHandshake = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceHandshake = controller->createServiceObject(uuid);
            if (!serviceHandshake)
                qWarning() << "Cannot create service (handshake) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{00001206-0000-1000-8000-00805f9b34fb}")
    {
        delete serviceHistory;
        serviceHistory = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceHistory = controller->createServiceObject(uuid);
            if (!serviceHistory)
                qWarning() << "Cannot create service (history) for uuid:" << uuid.toString();
        }
    }
}

/* ************************************************************************** */

void DeviceRopot::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceRopot::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData && m_ble_action == DeviceUtils::ACTION_UPDATE)
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
                if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_ROPOT))
                {
                    m_firmware_uptodate = true;
                }
            }

            Q_EMIT sensorUpdated();

            if (need_firstsend) // always?
            {
                QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handler 0x33
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                serviceData->writeCharacteristic(cha, QByteArray::fromHex("A01F"), QLowEnergyService::WriteWithResponse);
            }

            QBluetoothUuid b(QString("00001a01-0000-1000-8000-00805f9b34fb")); // handler 0x35
            QLowEnergyCharacteristic chb = serviceData->characteristic(b);
            serviceData->readCharacteristic(chb);
        }
    }
}

void DeviceRopot::serviceDetailsDiscovered_handshake(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceRopot::serviceDetailsDiscovered_handshake(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHandshake && m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            // Generate token
            QString addr = m_deviceAddress;
            QByteArray mac = QByteArray::fromHex(addr.remove(':').toLatin1());

            uint8_t pid[2] = {0x01, 0x5d};
            uint8_t magicend[4] = {0x92, 0xab, 0x54, 0xfa};
            uint8_t token1[12] = {0x1, 0x22, 0x3, 0x4, 0x5, 0x6, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1};
            uint8_t token2[12] = {0x1, 0x22, 0x3, 0x4, 0x5, 0x6, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1};

            uint8_t mixb[8] = {0};
            mixb[0] = mac[5];
            mixb[1] = mac[3];
            mixb[2] = mac[0];
            mixb[3] = pid[1];
            mixb[4] = mac[1];
            mixb[5] = mac[5];
            mixb[6] = mac[0];
            mixb[7] = pid[0];

            rc4_crypt(mixb, 8, token1, 12);
            rc4_crypt(token2, 12, magicend, 4);

            m_key_challenge = QByteArray::fromRawData((char*)token1, 12);
            m_key_challenge.detach();
            m_key_finish = QByteArray::fromRawData((char*)magicend, 4);
            m_key_finish.detach();

            // Handshake
            /// start session command (write [0x90, 0xca, 0x85, 0xde] on 0x1b)
            /// wait reply and
            /// enable notification for 0x12 handle
            /// send key on 0x12 handle
            /// wait reply and
            /// send finish key
            /// disable notification for 0x12 handle

            // Start session command
            QBluetoothUuid s(QString("00000010-0000-1000-8000-00805f9b34fb")); // handle 0x1b
            QLowEnergyCharacteristic chs = serviceHandshake->characteristic(s);
            serviceHandshake->writeCharacteristic(chs, QByteArray::fromHex("90ca85de"), QLowEnergyService::WriteWithResponse);
        }
    }
}

void DeviceRopot::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceRopot::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHistory && m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            //
        }
    }
}

/* ************************************************************************** */

void DeviceRopot::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceRopot::bleWriteDone(" << m_deviceAddress << ")";

    if (c.uuid().toString() == "{00000010-0000-1000-8000-00805f9b34fb}")
    {
        if (m_key_finish.size())
        {
/*
            // enable notification for 0x12 handle
            QBluetoothUuid h(QString("00002902-0000-1000-8000-00805f9b34fb")); // handler 0x13
            QLowEnergyCharacteristic chh = serviceHandshake->characteristic(h);
            m_notificationHandshake = chh.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
            serviceHandshake->writeDescriptor(m_notificationHandshake, QByteArray::fromHex("0100"));
*/
            // send challenge key
            QBluetoothUuid k(QString("00000001-0000-1000-8000-00805f9b34fb")); // handle 0x12
            QLowEnergyCharacteristic chk = serviceHandshake->characteristic(k);
            serviceHandshake->writeCharacteristic(chk, m_key_challenge, QLowEnergyService::WriteWithResponse);
        }
        return;
    }

    if (c.uuid().toString() == "{00000001-0000-1000-8000-00805f9b34fb}")
    {
        if (m_key_finish.size())
        {
            // send finish key
            QBluetoothUuid k(QString("00000001-0000-1000-8000-00805f9b34fb")); // handle 0x12
            QLowEnergyCharacteristic chk = serviceHandshake->characteristic(k);
            serviceHandshake->writeCharacteristic(chk, m_key_finish, QLowEnergyService::WriteWithResponse);
            m_key_finish.clear();

            // disabled notification for 0x12 handle?
        }
        else
        {
            // start reading history?
        }
        return;
    }
}

void DeviceRopot::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceRopot::bleReadNotify(" << m_deviceAddress << ")";
}

void DeviceRopot::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceRopot::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATA: 0x" \
             << Qt::hex << data[ 0] << Qt::hex << data[ 1] << Qt::hex << data[ 2] << Qt::hex << data[ 3] \
             << Qt::hex << data[ 4] << Qt::hex << data[ 5] << Qt::hex << data[ 6] << Qt::hex << data[ 7] \
             << Qt::hex << data[ 8] << Qt::hex << data[ 9] << Qt::hex << data[10] << Qt::hex << data[11] \
             << Qt::hex << data[12] << Qt::hex << data[13] << Qt::hex << data[14] << Qt::hex << data[15];
*/
    if (c.uuid().toString() == "{00001a11-0000-1000-8000-00805f9b34fb}")
    {
        QBluetoothUuid i(QString("00001a10-0000-1000-8000-00805f9b34fb")); // handler 0x3c
        QLowEnergyCharacteristic chi = serviceHistory->characteristic(i);

        if (m_history_entry_count < 0)
        {
            // Entry count
            m_history_entry_count = static_cast<int>(data[0] + (data[1] << 8));
            //qDebug() << "> History has" << m_history_entry_count << "m_history_entry_count";

            // Read first entry
            serviceHistory->writeCharacteristic(chi, QByteArray::fromHex("A10000"), QLowEnergyService::WriteWithResponse);
            m_history_entry_read = 0;
        }
        else
        {
            // Parse entry
        }
        return;
    }

    if (c.uuid().toString() == "{00001a12-0000-1000-8000-00805f9b34fb}")
    {
        // Device time
        m_device_time = data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24);
        m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;

#ifndef QT_NO_DEBUG
        qDebug() << "* DeviceRopot clock:" << m_device_time;
#endif
        return;    }

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
            m_soil_conductivity = data[8] + (data[9] << 8);

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_dbInternal || m_dbExternal)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addData;
                addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, soilMoisture, soilConductivity, temperature)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :hygro, :condu, :temp)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tsStr);
                addData.bindValue(":ts_full", tsFullStr);
                addData.bindValue(":hygro", m_soil_moisture);
                addData.bindValue(":condu", m_soil_conductivity);
                addData.bindValue(":temp", m_temperature);
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
            qDebug() << "* DeviceRopot update:" << getAddress();
            qDebug() << "- m_firmware:" << m_firmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_soil_moisture:" << m_soil_moisture;
            qDebug() << "- m_soil_conductivity:" << m_soil_conductivity;
            qDebug() << "- m_temperature:" << m_temperature;
#endif
        }
        return;
    }
}
