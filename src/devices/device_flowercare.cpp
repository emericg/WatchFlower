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

DeviceFlowerCare::DeviceFlowerCare(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerCare::DeviceFlowerCare(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerCare::~DeviceFlowerCare()
{
    delete serviceData;
    delete serviceHandshake;
    delete serviceHistory;
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
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }

    if (serviceHandshake)
    {
        if (serviceHandshake->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceHandshake, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare::serviceDetailsDiscovered_handshake);
            connect(serviceHandshake, &QLowEnergyService::characteristicChanged, this, &DeviceFlowerCare::bleReadNotify);
            connect(serviceHandshake, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare::bleReadDone);
            connect(serviceHandshake, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerCare::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHandshake->discoverDetails(); });
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare::serviceDetailsDiscovered_history);
            connect(serviceHistory, &QLowEnergyService::characteristicChanged, this, &DeviceFlowerCare::bleReadNotify);
            connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare::bleReadDone);
            connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerCare::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHistory->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceFlowerCare::addLowEnergyService(" << uuid.toString() << ")";

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

void DeviceFlowerCare::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData && m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            QBluetoothUuid c(QString("00001a02-0000-1000-8000-00805f9b34fb")); // handler 0x38
            QLowEnergyCharacteristic chc = serviceData->characteristic(c);
            if (chc.value().size() > 0)
            {
                m_battery = chc.value().at(0);
                m_deviceFirmware = chc.value().remove(0, 2);
            }

            bool need_firstsend = true;
            if (m_deviceFirmware.size() == 5)
            {
                if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
                {
                    m_firmware_uptodate = true;
                }
                if (Version(m_deviceFirmware) <= Version("2.6.6"))
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

        if (serviceData && m_ble_action == DeviceUtils::ACTION_LED_BLINK)
        {
            // Make LED blink
            QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
            QLowEnergyCharacteristic cha = serviceData->characteristic(a);
            serviceData->writeCharacteristic(cha, QByteArray::fromHex("FDFF"), QLowEnergyService::WriteWithoutResponse);

            controller->disconnectFromDevice();
        }
    }
}

void DeviceFlowerCare::serviceDetailsDiscovered_handshake(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_handshake(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHandshake && m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            // Generate token
            QString addr = m_deviceAddress;
            QByteArray mac = QByteArray::fromHex(addr.remove(':').toLatin1());

            uint8_t pid[2] = {0x98, 0x00};
            uint8_t magicend[4] = {0x92, 0xab, 0x54, 0xfa};
            uint8_t token1[12] = {0x1, 0x22, 0x3, 0x4, 0x5, 0x6, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1};
            uint8_t token2[12] = {0x1, 0x22, 0x3, 0x4, 0x5, 0x6, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1};

            uint8_t mixa[8] = {0};
            mixa[0] = mac[5];
            mixa[1] = mac[3];
            mixa[2] = mac[0];
            mixa[3] = pid[0];
            mixa[4] = pid[0];
            mixa[5] = mac[1];
            mixa[6] = mac[0];
            mixa[7] = mac[4];

            rc4_crypt(mixa, 8, token1, 12);
            rc4_crypt(token2, 12, magicend, 4);

            m_key_challenge = QByteArray::fromRawData((char*)token1, 12);
            m_key_challenge.detach();
            m_key_finish = QByteArray::fromRawData((char*)magicend, 4);
            m_key_finish.detach();

            // Handshake
            /// start session command (write [0x90, 0xca, 0x85, 0xde] on 0x1b)
            /// wait reply and
            /// enable notification for 0x12 handle
            /// send challenge key on 0x12 handle
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

void DeviceFlowerCare::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHistory && m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            //
        }
        if (serviceHistory && m_ble_action == DeviceUtils::ACTION_CLEAR_HISTORY)
        {
            //
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerCare::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();

    if (c.uuid().toString() == "{00000010-0000-1000-8000-00805f9b34fb}")
    {
        if (m_key_challenge.size())
        {
/*
            // Enable notification for 0x12 handle?
            QBluetoothUuid h(QString("00002902-0000-1000-8000-00805f9b34fb")); // handler 0x13
            QLowEnergyCharacteristic chh = serviceHandshake->characteristic(h);
            m_notificationHandshake = chh.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
            serviceHandshake->writeDescriptor(m_notificationHandshake, QByteArray::fromHex("0100"));
*/
            // Send challenge key
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
            // Send finish key
            QBluetoothUuid k(QString("00000001-0000-1000-8000-00805f9b34fb")); // handle 0x12
            QLowEnergyCharacteristic chk = serviceHandshake->characteristic(k);
            serviceHandshake->writeCharacteristic(chk, m_key_finish, QLowEnergyService::WriteWithResponse);
            m_key_finish.clear();

            // Disable notification for 0x12 handle?
        }
        else
        {
            // Start reading history?
/*
            // Enable notification for 0x3e handle
            QBluetoothUuid n(QString("00002902-0000-1000-8000-00805f9b34fb")); // handler 0x3f
            QLowEnergyCharacteristic chn = serviceHistory->characteristic(n);
            m_notificationHistory = chn.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
            serviceHistory->writeDescriptor(m_notificationHistory, QByteArray::fromHex("0100"));
*/
            // Read device time
            QBluetoothUuid h(QString("00001a12-0000-1000-8000-00805f9b34fb")); // handler 0x41
            QLowEnergyCharacteristic chh = serviceHistory->characteristic(h);
            serviceHistory->readCharacteristic(chh);

            // Change the device mode
            QBluetoothUuid m(QString("00001a10-0000-1000-8000-00805f9b34fb")); // handler 0x3e
            QLowEnergyCharacteristic chm = serviceHistory->characteristic(m);
            serviceHistory->writeCharacteristic(chm, QByteArray::fromHex("A00000"), QLowEnergyService::WriteWithResponse);
        }
        return;
    }

    if (c.uuid().toString() == "{00001a10-0000-1000-8000-00805f9b34fb}")
    {
        // Device mode has been changed to 'history'

        // Read history entry count
        QBluetoothUuid i(QString("00001a11-0000-1000-8000-00805f9b34fb")); // handler 0x3c
        QLowEnergyCharacteristic chi = serviceHistory->characteristic(i);
        serviceHistory->readCharacteristic(chi);
        return;
    }
}

void DeviceFlowerCare::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceFlowerCare::bleReadNotify(" << m_deviceAddress << ")";
}

void DeviceFlowerCare::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceFlowerCare::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
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
            m_history_entry_read++;
            Q_EMIT statusUpdated();

            // Parse entry
            int64_t tmcd = (data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24));
            float temperature = static_cast<int16_t>(data[4]  + (data[5] << 8)+ (data[6] << 16)) / 10.f;
            int luminosity = data[7] + (data[8] << 8) + (data[9] << 16) + (data[10] << 24);
            int soil_moisture = data[11];
            int soil_conductivity = data[12] + (data[13] << 8) + (data[14] << 16) + (data[15] << 24);

            if (m_dbInternal || m_dbExternal)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QDateTime tmcd_qt = QDateTime::fromSecsSinceEpoch(m_device_wall_time+tmcd);

                QSqlQuery addData;
                addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, soilMoisture, soilConductivity, temperature, luminosity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :hygro, :condu, :temp, :lumi)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tmcd_qt.toString("yyyy-MM-dd hh:00:00"));
                addData.bindValue(":ts_full", tmcd_qt.toString("yyyy-MM-dd hh:mm:ss"));
                addData.bindValue(":hygro", soil_moisture);
                addData.bindValue(":condu", soil_conductivity);
                addData.bindValue(":temp", temperature);
                addData.bindValue(":lumi", luminosity);
                if (addData.exec() == false)
                    qWarning() << "> addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();
            }
/*
#ifndef QT_NO_DEBUG
            qDebug() << "* History entry" << m_history_entry_read-1 << " at " << tmcd << " / or" << QDateTime::fromSecsSinceEpoch(m_device_wall_time+tmcd);
            qDebug() << "- soil_moisture:" << soil_moisture;
            qDebug() << "- soil_conductivity:" << soil_conductivity;
            qDebug() << "- temperature:" << temperature;
            qDebug() << "- luminosity:" << luminosity;
#endif
*/
            // Read next entry (format: 0xA1 + entry / 16b little endian)
            if (m_history_entry_read < m_history_entry_count)
            {
                QByteArray nextentry(QByteArray::fromHex("A1"));
                nextentry.push_back(m_history_entry_read%256);
                nextentry.push_back(m_history_entry_read/256);
                serviceHistory->writeCharacteristic(chi, nextentry, QLowEnergyService::WriteWithResponse);
            }
        }
        return;
    }

    if (c.uuid().toString() == "{00001a12-0000-1000-8000-00805f9b34fb}")
    {
        // Device time
        m_device_time = data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24);
        m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;

#ifndef QT_NO_DEBUG
        qDebug() << "* DeviceFlowerCare clock:" << m_device_time;
#endif
        return;
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
            m_luminosity = data[3] + (data[4] << 8);
            m_soil_moisture = data[7];
            m_soil_conductivity = data[8] + (data[9] << 8);

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_dbInternal || m_dbExternal)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addData;
                addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, soilMoisture, soilConductivity, temperature, luminosity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :hygro, :condu, :temp, :lumi)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tsStr);
                addData.bindValue(":ts_full", tsFullStr);
                addData.bindValue(":hygro", m_soil_moisture);
                addData.bindValue(":condu", m_soil_conductivity);
                addData.bindValue(":temp", m_temperature);
                addData.bindValue(":lumi", m_luminosity);
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
            qDebug() << "* DeviceFlowerCare update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_soil_moisture:" << m_soil_moisture;
            qDebug() << "- m_soil_conductivity:" << m_soil_conductivity;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_luminosity:" << m_luminosity;
#endif
        }
        return;
    }
}

/* ************************************************************************** */

int DeviceFlowerCare::getHistoryUpdatePercent() const
{
    int p = -1;

    if (m_status == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
        p = static_cast<int>((m_history_entry_read / m_history_entry_count) * 100);
    }

    return p;
}

/* ************************************************************************** */
