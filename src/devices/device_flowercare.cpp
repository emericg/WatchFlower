/*!
 * This file is part of WatchFlower.
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
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
#include "device_firmwares.h"
#include "utils_versionchecker.h"
#include "thirdparty/RC4/rc4.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceFlowerCare::DeviceFlowerCare(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DevicePlantSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
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
    DevicePlantSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
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
    return !m_deviceAddressMAC.isEmpty();
#endif

    return true;
}

/* ************************************************************************** */

void DeviceFlowerCare::serviceScanDone()
{
    //qDebug() << "DeviceFlowerCare::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
            //auto ret = QtConcurrent::run([this](){ serviceData->discoverDetails(); });
            //QMetaObject::invokeMethod(QCoreApplication::instance(), [] () { serviceData->discoverDetails(); });
        }
    }

    if (serviceHandshake)
    {
        if (serviceHandshake->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceHandshake, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare::serviceDetailsDiscovered_handshake);
            connect(serviceHandshake, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare::bleReadDone);
            connect(serviceHandshake, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerCare::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHandshake->discoverDetails(); });
            //auto ret = QtConcurrent::run([this](){ serviceHandshake->discoverDetails(); });
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare::serviceDetailsDiscovered_history);
            connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare::bleReadDone);
            connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerCare::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHistory->discoverDetails(); });
            //auto ret = QtConcurrent::run([this](){ serviceHistory->discoverDetails(); });
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
        QBluetoothUuid b(QStringLiteral("00001a01-0000-1000-8000-00805f9b34fb")); // handle 0x35
        QLowEnergyCharacteristic chb = serviceData->characteristic(b);
        serviceData->readCharacteristic(chb);
    }
}

/* ************************************************************************** */

void DeviceFlowerCare::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData && m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            int batt = -1;
            QString fw;

            QBluetoothUuid c(QStringLiteral("00001a02-0000-1000-8000-00805f9b34fb")); // handle 0x38
            QLowEnergyCharacteristic chc = serviceData->characteristic(c);
            if (chc.value().size() > 0)
            {
                batt = chc.value().at(0);
                fw = chc.value().remove(0, 2);
                setBatteryFirmware(batt, fw);
            }

            bool need_modechange = true;
            if (m_deviceFirmware.size() == 5)
            {
                if (m_deviceName == "Flower care" &&
                    VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
                if (m_deviceName == "Grow care garden" &&
                    VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERCARE_MAX))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
                if (VersionChecker(m_deviceFirmware) <= VersionChecker("2.6.6"))
                {
                    need_modechange = false;
                }
            }

            if (need_modechange) // if firmware > 2.6.6
            {
                // Change device mode
                QBluetoothUuid a(QStringLiteral("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                serviceData->writeCharacteristic(cha, QByteArray::fromHex("A01F"), QLowEnergyService::WriteWithResponse);
            }

            // Ask for a data reading
            if (m_deviceName == "Grow care garden")
                QTimer::singleShot(1000, this, SLOT(askForReading()));
            else
                askForReading();
        }

        if (serviceData)
        {
            QBluetoothUuid l(QStringLiteral("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
            QLowEnergyCharacteristic chl = serviceData->characteristic(l);

            if (m_ble_action == DeviceUtils::ACTION_LED_BLINK)
            {
                // Make the LED blink
                serviceData->writeCharacteristic(chl, QByteArray::fromHex("FDFF"), QLowEnergyService::WriteWithoutResponse);

                m_bleController->disconnectFromDevice();
            }
            else
            {
                // Make sure the LED is OFF
                //if (chl.value().size() == 2 && (chl.value().at(0) != 0 || chl.value().at(1) != 0))
                //{
                //    serviceData->writeCharacteristic(chl, QByteArray::fromHex("0000"), QLowEnergyService::WriteWithoutResponse);
                //    qWarning() << "FlowerCare LED was ON!";
                //}
            }
        }
    }
}

void DeviceFlowerCare::serviceDetailsDiscovered_handshake(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_handshake(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHandshake &&
            (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY ||
             m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME))
        {
            QString addr = getAddressMAC();
            QByteArray mac = QByteArray::fromHex(addr.remove(':').toLatin1());

            // Generate token
            uint8_t pid[2] = {0x98, 0x00};
            uint8_t magicend[4] = {0x92, 0xab, 0x54, 0xfa};
            uint8_t token1[12] = {0x1, 0x22, 0x3, 0x4, 0x5, 0x6, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1};
            uint8_t token2[12] = {0x1, 0x22, 0x3, 0x4, 0x5, 0x6, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1};

            // HHCCJCY01: {0x98, 0x00};
            // HHCCJCY09: {0xBC, 0x03};
            // HHCCPOT002: {0x5D, 0x01};
            if (m_deviceName == "Flower care") { pid[0] = 0x98; pid[1] = 0x00; }
            if (m_deviceName == "Grow care garden") { pid[0] = 0xBC; pid[1] = 0x03; }
            if (m_deviceName == "ropot") { pid[0] = 0x5D; pid[1] = 0x01; }

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
            QBluetoothUuid s(QStringLiteral("00000010-0000-1000-8000-00805f9b34fb")); // handle 0x1b
            QLowEnergyCharacteristic chs = serviceHandshake->characteristic(s);
            serviceHandshake->writeCharacteristic(chs, QByteArray::fromHex("90ca85de"), QLowEnergyService::WriteWithResponse);
        }
    }
}

void DeviceFlowerCare::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHistory && m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            //
        }

        if (serviceHistory && m_ble_action == DeviceUtils::ACTION_CLEAR_HISTORY)
        {
            QBluetoothUuid m(QStringLiteral("00001a10-0000-1000-8000-00805f9b34fb")); // handle 0x3e
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
    Q_UNUSED(value)

    if (c.uuid().toString() == "{00000010-0000-1000-8000-00805f9b34fb}")
    {
        if (m_key_challenge.size())
        {
/*
            // Enable notification for 0x12 handle?
            QBluetoothUuid h(QStringLiteral("00002902-0000-1000-8000-00805f9b34fb")); // handle 0x13
            QLowEnergyCharacteristic chh = serviceHandshake->characteristic(h);
            m_notificationHandshake = chh.clientCharacteristicConfiguration();
            serviceHandshake->writeDescriptor(m_notificationHandshake, QByteArray::fromHex("0100"));
*/
            // Send challenge key
            QBluetoothUuid k(QStringLiteral("00000001-0000-1000-8000-00805f9b34fb")); // handle 0x12
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
            QBluetoothUuid k(QStringLiteral("00000001-0000-1000-8000-00805f9b34fb")); // handle 0x12
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
                QBluetoothUuid n(QStringLiteral("00002902-0000-1000-8000-00805f9b34fb")); // handle 0x3f
                QLowEnergyCharacteristic chn = serviceHistory->characteristic(n);
                m_notificationHistory = chn.clientCharacteristicConfiguration();
                serviceHistory->writeDescriptor(m_notificationHistory, QByteArray::fromHex("0100"));
*/
                if (m_device_time < 0)
                {
                    // Read device time
                    QBluetoothUuid h(QStringLiteral("00001a12-0000-1000-8000-00805f9b34fb")); // handle 0x41
                    QLowEnergyCharacteristic chh = serviceHistory->characteristic(h);
                    serviceHistory->readCharacteristic(chh);
                }

                // Change device mode
                QBluetoothUuid m(QStringLiteral("00001a10-0000-1000-8000-00805f9b34fb")); // handle 0x3e
                QLowEnergyCharacteristic chm = serviceHistory->characteristic(m);
                serviceHistory->writeCharacteristic(chm, QByteArray::fromHex("A00000"), QLowEnergyService::WriteWithResponse);
            }
            else if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                // Change device mode
                QBluetoothUuid a(QStringLiteral("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
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
        QBluetoothUuid i(QStringLiteral("00001a11-0000-1000-8000-00805f9b34fb")); // handle 0x3c
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
        QBluetoothUuid i(QStringLiteral("00001a10-0000-1000-8000-00805f9b34fb")); // handle 0x3c
        QLowEnergyCharacteristic chi = serviceHistory->characteristic(i);

        if (m_history_entryCount < 0)
        {
            // Parse entry count
            m_history_entryCount = static_cast<int16_t>(data[0] + (data[1] << 8));
/*
            qDebug() << "* DeviceFlowerCare history sync  > " << getAddress();
            qDebug() << "- device_time  :" << m_device_time << "(" << (m_device_time / 3600.0 / 24.0) << "day)";
            qDebug() << "- last_sync    :" << m_lastHistorySync;
            qDebug() << "- entry_count  :" << m_history_entryCount;
*/
            // We read entry from older to newer (entry_count to 0)
            int entries_to_read = m_history_entryCount;

            // Is m_lastHistorySync valid AND inside the range of stored history entries
            if (m_lastHistorySync.isValid())
            {
                int64_t lastSync_sec = QDateTime::currentSecsSinceEpoch() - m_lastHistorySync.toSecsSinceEpoch();
                int64_t entries_count_sec = (m_history_entryCount * 3600);

                if (lastSync_sec < entries_count_sec)
                {
                    // how many entries are we missing since last sync?
                    entries_to_read = (lastSync_sec / 3600);
                }
            }

            // Is the restart point to old, outside the range of stored history entries?
            if (entries_to_read > m_history_entryCount)
            {
                entries_to_read = m_history_entryCount;
            }

            // Now we can set our first index to read!
            m_history_entryIndex = entries_to_read;

            // Sanetize, just to be sure
            if (m_history_entryIndex > m_history_entryCount) m_history_entryIndex = 0;
            if (m_history_entryIndex < 0)
            {
                // abort sync?
                m_bleController->disconnectFromDevice();
                return;
            }

            // Set the progressbar infos
            m_history_sessionCount = entries_to_read;
            m_history_sessionRead = 0;
            Q_EMIT progressUpdated();

            // (re)start sync
            QByteArray nextentry(QByteArray::fromHex("A1"));
            nextentry.push_back(m_history_entryIndex%256);
            nextentry.push_back(m_history_entryIndex/256);

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

            addDatabaseRecord(m_device_wall_time + tmcd,
                              soil_moisture, soil_conductivity, -99.f, -99.f,
                              temperature, -99.f, luminosity);
/*
            qDebug() << "* History entry" << m_history_entryIndex-1 << " at " << tmcd << " / or" << QDateTime::fromSecsSinceEpoch(m_device_wall_time+tmcd);
            qDebug() << "- soil_moisture:" << soil_moisture;
            qDebug() << "- soil_conductivity:" << soil_conductivity;
            qDebug() << "- temperature:" << temperature;
            qDebug() << "- luminosity:" << luminosity;
*/
            // Update progress
            m_history_entryIndex--;
            m_history_sessionRead++;
            Q_EMIT progressUpdated();

            if (m_history_entryIndex > 0)
            {
                // Read next entry (format: 0xA1 + entry / 16b little endian)
                QByteArray nextentry(QByteArray::fromHex("A1"));
                nextentry.push_back(m_history_entryIndex%256);
                nextentry.push_back(m_history_entryIndex/256);
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

        qDebug() << "* DeviceFlowerCare clock:" << m_device_time;
        return;
    }

    if (c.uuid().toString() == "{00001a01-0000-1000-8000-00805f9b34fb}")
    {
        // MiFlora data // handle 0x35

        if (value.size() > 0)
        {
            // first read might send bad data (0x aa bb cc dd ee ff 99 88 77 66...)
            // until the first write is done
            if (data[0] == 0xAA && data[1] == 0xBB)
                return;

            m_temperature = static_cast<int16_t>(data[0] + (data[1] << 8)) / 10.f;
            m_luminosityLux = data[3] + (data[4] << 8);
            m_soilMoisture = data[7];
            m_soilConductivity = data[8] + (data[9] << 8);

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();

                // Ask for a new data reading, but not too often...
                QTimer::singleShot(1000, this, SLOT(askForReading()));
            }
            else
            {
                bool status = addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                                m_soilMoisture, m_soilConductivity, -99.f, -99.f,
                                                m_temperature, -99.f, m_luminosityLux);

                refreshDataFinished(status);
                m_bleController->disconnectFromDevice();
            }
/*
            qDebug() << "* DeviceFlowerCare update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_soilMoisture:" << m_soilMoisture;
            qDebug() << "- m_soilConductivity:" << m_soilConductivity;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_luminosityLux:" << m_luminosityLux;
*/
        }

        return;
    }
}

/* ************************************************************************** */

void DeviceFlowerCare::parseAdvertisementData(const uint16_t adv_mode,
                                              const uint16_t adv_id,
                                              const QByteArray &ba)
{
/*
    qDebug() << "DeviceFlowerCare::parseAdvertisementData(" << m_deviceAddress
             << " - " << adv_mode << " - 0x" << adv_id << ")";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    // MiBeacon protocol / 12-10 bytes messages

    if (ba.size() >= 12)
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());
        const int data_size = ba.size();

        // Save mac address (for macOS and iOS)
        if (!hasAddressMAC())
        {
            QString mac;

            mac += ba.mid(10,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(9,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(8,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(7,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(6,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(5,1).toHex().toUpper();

            setAddressMAC(mac);
        }

        if (data_size >= 16)
        {
            int batt = -99;
            float temp = -99.f;
            float humi = -99.f;
            int lumi = -99;
            float form = -99.f;
            int moist = -99;
            int fert = -99;

            // get data
            if (data[12] == 4 && data_size >= 17)
            {
                temp = static_cast<int16_t>(data[15] + (data[16] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    if (temp > -30.f && temp < 100.f)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[12] == 6 && data_size >= 17)
            {
                humi = static_cast<int16_t>(data[15] + (data[16] << 8)) / 10.f;
                if (humi != m_humidity)
                {
                    if (humi >= 0.f && humi <= 100.f)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[12] == 7 && data_size >= 18)
            {
                lumi = static_cast<int32_t>(data[15] + (data[16] << 8) + (data[17] << 16));
                if (lumi != m_luminosityLux)
                {
                    if (lumi >= 0 && lumi < 150000)
                    {
                        m_luminosityLux = lumi;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[12] == 8 && data_size >= 17)
            {
                moist = static_cast<int16_t>(data[15] + (data[16] << 8));
                if (moist != m_soilMoisture)
                {
                    if (moist >= 0 && moist <= 100)
                    {
                        m_soilMoisture = moist;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[12] == 9 && data_size >= 17)
            {
                fert = static_cast<int16_t>(data[15] + (data[16] << 8));
                if (fert != m_soilConductivity)
                {
                    if (fert >= 0 && fert < 20000)
                    {
                        m_soilConductivity = fert;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[12] == 10 && data_size >= 16)
            {
                batt = static_cast<int8_t>(data[15]);
                setBattery(batt);
            }
            else if (data[12] == 13 && data_size >= 19)
            {
                temp = static_cast<int16_t>(data[15] + (data[16] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
                humi = static_cast<int16_t>(data[17] + (data[18] << 8)) / 10.f;
                if (humi != m_humidity)
                {
                    m_humidity = humi;
                    Q_EMIT dataUpdated();
                }
            }
            else if (data[12] == 16 && data_size >= 17)
            {
                form = static_cast<int16_t>(data[15] + (data[16] << 8)) / 10.f;
                if (form != m_hcho)
                {
                    if (form >= 0.f && form <= 100.f)
                    {
                        m_hcho = form;
                        Q_EMIT dataUpdated();
                    }
                }
            }

            if (m_soilMoisture > -99 && m_soilConductivity > -99 && m_temperature > -99.f && m_luminosityLux > -99)
            {
                m_lastUpdate = QDateTime::currentDateTime();

                if (needsUpdateDb_mini())
                {
                    //addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                    //                  m_soilMoisture, m_soilConductivity, -99.f, -99.f,
                    //                  m_temperature, -99.f, m_luminosityLux);
                }

                refreshDataFinished(true);
            }
/*
            if (batt > -99 || temp > -99.f || humi > -99.f || lumi > -99 || form > -99.f || moist > -99 || fert > -99)
            {
                qDebug() << "* MiBeacon service data:" << getName() << getAddress() << "(" << data_size << ") bytes";
                if (batt > -99) qDebug() << "- battery:" << batt;
                if (temp > -99) qDebug() << "- temperature:" << temp;
                if (humi > -99) qDebug() << "- humidity:" << humi;
                if (lumi > -99) qDebug() << "- luminosity:" << lumi;
                if (form > -99) qDebug() << "- formaldehyde:" << form;
                if (moist > -99)qDebug() << "- soil moisture:" << moist;
                if (fert > -99) qDebug() << "- soil conductivity:" << fert;
            }
*/
        }
    }
}

/* ************************************************************************** */
