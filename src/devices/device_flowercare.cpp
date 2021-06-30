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
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerCare::DeviceFlowerCare(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
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

bool DeviceFlowerCare::hasHistory() const
{
#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
    if (hasSetting("mac")) return true;
    return false;
#endif

    return true;
}

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
            serviceData = m_bleController->createServiceObject(uuid);
            if (!serviceData)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{0000fe95-0000-1000-8000-00805f9b34fb}")
    {
        delete serviceHandshake;
        serviceHandshake = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY ||
            m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
        {
            serviceHandshake = m_bleController->createServiceObject(uuid);
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
            serviceHistory = m_bleController->createServiceObject(uuid);
            if (!serviceHistory)
                qWarning() << "Cannot create service (history) for uuid:" << uuid.toString();
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare::askForReading()
{
    if (serviceData)
    {
        QBluetoothUuid b(QString("00001a01-0000-1000-8000-00805f9b34fb")); // handle 0x35
        QLowEnergyCharacteristic chb = serviceData->characteristic(b);
        serviceData->readCharacteristic(chb);
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
            int batt = -1;
            QString fw;

            QBluetoothUuid c(QString("00001a02-0000-1000-8000-00805f9b34fb")); // handle 0x38
            QLowEnergyCharacteristic chc = serviceData->characteristic(c);
            if (chc.value().size() > 0)
            {
                batt = chc.value().at(0);
                fw = chc.value().remove(0, 2);
            }

            setBatteryFirmware(batt, fw);

            bool need_modechange = true;
            if (m_deviceFirmware.size() == 5)
            {
                if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
                if (Version(m_deviceFirmware) <= Version("2.6.6"))
                {
                    need_modechange = false;
                }
            }

            if (need_modechange) // if firmware > 2.6.6
            {
                // Change device mode
                QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                serviceData->writeCharacteristic(cha, QByteArray::fromHex("A01F"), QLowEnergyService::WriteWithResponse);
            }

            // Ask for a data reading
            askForReading();
        }

        if (serviceData)
        {
            QBluetoothUuid l(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
            QLowEnergyCharacteristic chl = serviceData->characteristic(l);

            if (m_ble_action == DeviceUtils::ACTION_LED_BLINK)
            {
                // Make the LED blink
                serviceData->writeCharacteristic(chl, QByteArray::fromHex("FDFF"), QLowEnergyService::WriteWithoutResponse);

                m_bleController->disconnectFromDevice();
            }
            else
            {
                // Make sure the LED is off
                if (chl.value().size() == 2)
                    if (chl.value().at(0) != 0 || chl.value().at(1) != 0)
                        serviceData->writeCharacteristic(chl, QByteArray::fromHex("0000"), QLowEnergyService::WriteWithoutResponse);
            }
        }
    }
}

void DeviceFlowerCare::serviceDetailsDiscovered_handshake(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_handshake(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHandshake &&
            (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY ||
             m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME))
        {
            QString addr = m_deviceAddress;
#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
            addr = getSetting("mac").toString();
#endif
            QByteArray mac = QByteArray::fromHex(addr.remove(':').toLatin1());

            // Generate token
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
            QBluetoothUuid m(QString("00001a10-0000-1000-8000-00805f9b34fb")); // handle 0x3e
            QLowEnergyCharacteristic chm = serviceHistory->characteristic(m);
            serviceHistory->writeCharacteristic(chm, QByteArray::fromHex("A20000"), QLowEnergyService::WriteWithResponse);
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerCare::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString() == "{00000010-0000-1000-8000-00805f9b34fb}")
    {
        if (m_key_challenge.size())
        {
/*
            // Enable notification for 0x12 handle?
            QBluetoothUuid h(QString("00002902-0000-1000-8000-00805f9b34fb")); // handle 0x13
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
            if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
            {
                // Start reading history?
/*
                // Enable notification for 0x3e handle
                QBluetoothUuid n(QString("00002902-0000-1000-8000-00805f9b34fb")); // handle 0x3f
                QLowEnergyCharacteristic chn = serviceHistory->characteristic(n);
                m_notificationHistory = chn.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
                serviceHistory->writeDescriptor(m_notificationHistory, QByteArray::fromHex("0100"));
*/
                if (m_device_time < 0)
                {
                    // Read device time
                    QBluetoothUuid h(QString("00001a12-0000-1000-8000-00805f9b34fb")); // handle 0x41
                    QLowEnergyCharacteristic chh = serviceHistory->characteristic(h);
                    serviceHistory->readCharacteristic(chh);
                }

                // Change device mode
                QBluetoothUuid m(QString("00001a10-0000-1000-8000-00805f9b34fb")); // handle 0x3e
                QLowEnergyCharacteristic chm = serviceHistory->characteristic(m);
                serviceHistory->writeCharacteristic(chm, QByteArray::fromHex("A00000"), QLowEnergyService::WriteWithResponse);
            }
            else if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                // Change device mode
                QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                serviceData->writeCharacteristic(cha, QByteArray::fromHex("A01F"), QLowEnergyService::WriteWithResponse);

                // Ask for a data reading
                askForReading();
            }
        }
        return;
    }

    if (c.uuid().toString() == "{00001a10-0000-1000-8000-00805f9b34fb}")
    {
        // Device mode has been changed to 'history'

        // Read history entry count or entries
        QBluetoothUuid i(QString("00001a11-0000-1000-8000-00805f9b34fb")); // handle 0x3c
        QLowEnergyCharacteristic chi = serviceHistory->characteristic(i);
        serviceHistory->readCharacteristic(chi);
        return;
    }
}

void DeviceFlowerCare::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceFlowerCare::bleReadNotify(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceFlowerCare::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerCare::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{00001a11-0000-1000-8000-00805f9b34fb}")
    {
        QBluetoothUuid i(QString("00001a10-0000-1000-8000-00805f9b34fb")); // handle 0x3c
        QLowEnergyCharacteristic chi = serviceHistory->characteristic(i);

        if (m_history_entry_count < 0)
        {
            // Parse entry count
            m_history_entry_count = static_cast<int16_t>(data[0] + (data[1] << 8));

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceFlowerCare history sync  > " << getAddress();
            qDebug() << "- device_time  :" << m_device_time << "(" << (m_device_time / 3600.0 / 24.0) << "day)";
            qDebug() << "- last_sync    :" << m_lastHistorySync;
            qDebug() << "- entry_count  :" << m_history_entry_count;
#endif

            // We read entry from older to newer (entry_count to 0)
            int entries_to_read = m_history_entry_count;

            // Is m_lastHistorySync valid AND inside the range of stored history entries
            if (m_lastHistorySync.isValid())
            {
                int64_t lastSync_sec = QDateTime::currentSecsSinceEpoch() - m_lastHistorySync.toSecsSinceEpoch();
                int64_t entries_count_sec = (m_history_entry_count * 3600);

                if (lastSync_sec < entries_count_sec)
                {
                    // how many entries are we missing since last sync?
                    entries_to_read = (lastSync_sec / 3600);
                }
            }

            // Is the restart point to old, outside the range of stored history entries?
            if (entries_to_read > m_history_entry_count)
            {
                entries_to_read = m_history_entry_count;
            }

            // Now we can set our first index to read!
            m_history_entry_index = entries_to_read;

            // Sanetize, just to be sure
            if (m_history_entry_index > m_history_entry_count) m_history_entry_index = 0;
            if (m_history_entry_index < 0)
            {
                // abort sync?
                m_bleController->disconnectFromDevice();
                return;
            }

            // Set the progressbar infos
            m_history_session_count = entries_to_read;
            m_history_session_read = 0;
            Q_EMIT progressUpdated();

            // (re)start sync
            QByteArray nextentry(QByteArray::fromHex("A1"));
            nextentry.push_back(m_history_entry_index%256);
            nextentry.push_back(m_history_entry_index/256);

            serviceHistory->writeCharacteristic(chi, nextentry, QLowEnergyService::WriteWithResponse);
        }
        else
        {
            // Parse entry
            int64_t tmcd = (data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24));
            m_lastHistorySync.setSecsSinceEpoch(m_device_wall_time + tmcd);
            float temperature = static_cast<int16_t>(data[4]  + (data[5] << 8)) / 10.f;
            if (temperature > 100.f) temperature = 0.f; // FIXME negative temperatures aren't properly coded?
            int luminosity = data[7] + (data[8] << 8) + (data[9] << 16) + (data[10] << 24);
            int soil_moisture = data[11];
            int soil_conductivity = data[12] + (data[13] << 8) + (data[14] << 16) + (data[15] << 24);

            if (m_dbInternal || m_dbExternal)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                // We only save one value every hour

                QSqlQuery addData;
                addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, soilMoisture, soilConductivity, temperature, luminosity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :hygro, :condu, :temp, :lumi)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", m_lastHistorySync.toString("yyyy-MM-dd hh:00:00"));
                addData.bindValue(":ts_full", m_lastHistorySync.toString("yyyy-MM-dd hh:mm:ss"));
                addData.bindValue(":hygro", soil_moisture);
                addData.bindValue(":condu", soil_conductivity);
                addData.bindValue(":temp", temperature);
                addData.bindValue(":lumi", luminosity);
                if (addData.exec() == false)
                    qWarning() << "> addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();
            }

#ifndef QT_NO_DEBUG
            qDebug() << "* History entry" << m_history_entry_index-1 << " at " << tmcd << " / or" << QDateTime::fromSecsSinceEpoch(m_device_wall_time+tmcd);
            //qDebug() << "- soil_moisture:" << soil_moisture;
            //qDebug() << "- soil_conductivity:" << soil_conductivity;
            //qDebug() << "- temperature:" << temperature;
            //qDebug() << "- luminosity:" << luminosity;
#endif

            // Update progress
            m_history_entry_index--;
            m_history_session_read++;
            Q_EMIT progressUpdated();

            if (m_history_entry_index > 0)
            {
                // Read next entry (format: 0xA1 + entry / 16b little endian)
                QByteArray nextentry(QByteArray::fromHex("A1"));
                nextentry.push_back(m_history_entry_index%256);
                nextentry.push_back(m_history_entry_index/256);
                serviceHistory->writeCharacteristic(chi, nextentry, QLowEnergyService::WriteWithResponse);
            }
            else
            {
                // Finish it
                refreshHistoryFinished(true);
                m_bleController->disconnectFromDevice();
                return;
            }
        }
        return;
    }

    if (c.uuid().toString() == "{00001a12-0000-1000-8000-00805f9b34fb}")
    {
        // Device time
        m_device_time = static_cast<int32_t>(data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24));
        m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;

#ifndef QT_NO_DEBUG
        qDebug() << "* DeviceFlowerCare clock:" << m_device_time;
#endif
        return;
    }

    if (c.uuid().toString() == "{00001a01-0000-1000-8000-00805f9b34fb}")
    {
        // MiFlora data // handle 0x35

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

                m_lastUpdateDatabase = m_lastUpdate;
            }

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();
                // Ask for a new data reading, but not too often...
                QTimer::singleShot(1000, this, SLOT(askForReading()));
            }
            else
            {
                refreshDataFinished(true);
                m_bleController->disconnectFromDevice();
            }

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceFlowerCare update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
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

void DeviceFlowerCare::parseAdvertisementData(const QByteArray &value)
{
    //qDebug() << "DeviceFlowerCare::parseAdvertisementData(" << m_deviceAddress << ")" << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    // 12-18 bytes messages
    if (value.size() >= 12)
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

        QString mac;
        int batt = -99;
        float temp = -99;
        float hygro = -99;
        int moist = -99;
        int lumi = -99;
        int fert = -99;

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        // Save mac address
        mac += value.mid(10,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(9,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(8,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(7,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(6,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(5,1).toHex().toUpper();

        setSetting("mac", mac);
#else
        Q_UNUSED(mac)
#endif

        if (value.size() >= 16)
        {
            // get data
            if (data[12] == 4 && value.size() >= 17)
            {
                temp = static_cast<int16_t>(data[15] + (data[16] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
            }
            else if (data[12] == 6 && value.size() >= 17)
            {
                hygro = static_cast<int16_t>(data[15] + (data[16] << 8)) / 10.f;
                if (hygro != m_humidity)
                {
                    m_humidity = hygro;
                    Q_EMIT dataUpdated();
                }
            }
            else if (data[12] == 7 && value.size() >= 18)
            {
                lumi = static_cast<int32_t>(data[15] + (data[16] << 8) + (data[17] << 16));
                if (lumi != m_luminosity)
                {
                    m_luminosity = lumi;
                    Q_EMIT dataUpdated();
                }
            }
            else if (data[12] == 8 && value.size() >= 17)
            {
                moist = static_cast<int16_t>(data[15] + (data[16] << 8));
                if (moist != m_soil_moisture)
                {
                    m_soil_moisture = moist;
                    Q_EMIT dataUpdated();
                }
            }
            else if (data[12] == 9 && value.size() >= 17)
            {
                fert = static_cast<int16_t>(data[15] + (data[16] << 8));
                if (fert != m_soil_conductivity)
                {
                    m_soil_conductivity = fert;
                    Q_EMIT dataUpdated();
                }
            }
            else if (data[12] == 10 && value.size() >= 16)
            {
                batt = static_cast<int8_t>(data[15]);
                setBattery(batt);
            }
            else if (data[12] == 11 && value.size() >= 19)
            {
                temp = static_cast<int16_t>(data[15] + (data[16] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
                hygro = static_cast<int16_t>(data[17] + (data[18] << 8)) / 10.f;
                if (hygro != m_humidity)
                {
                    m_humidity = hygro;
                    Q_EMIT dataUpdated();
                }
            }
/*
            if (m_temperature > -99 && m_luminosity > -99 && m_soil_moisture && m_soil_conductivity)
            {
                m_lastUpdate = QDateTime::currentDateTime();

                if (needsUpdateDb())
                {
                    // TODO // UPDATE DB

                    Q_EMIT dataUpdated();
                    Q_EMIT statusUpdated();
                }
            }
*/
#ifndef QT_NO_DEBUG
            //qDebug() << "* DeviceFlowerCare service data:" << getAddress();
            //qDebug() << "- MAC:" << mac;
            //qDebug() << "- battery:" << batt;
            //qDebug() << "- temperature:" << temp;
            //qDebug() << "- humidity:" << hygro;
            //qDebug() << "- luminosity:" << lumi;
            //qDebug() << "- moisture:" << moist;
            //qDebug() << "- fertility:" << fert;
#endif
        }
    }
}

/* ************************************************************************** */
