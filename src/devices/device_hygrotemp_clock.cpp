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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_hygrotemp_clock.h"
#include "device_firmwares.h"
#include "utils_versionchecker.h"

#include "SettingsManager.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDateTime>
#include <QTimeZone>
#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempClock::DeviceHygrotempClock(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_CLOCK;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempClock::DeviceHygrotempClock(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_CLOCK;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempClock::~DeviceHygrotempClock()
{
    delete serviceData;
    delete serviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceHygrotempClock::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempClock::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceHygrotempClock::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceHygrotempClock::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceHygrotempClock::serviceDetailsDiscovered_infos);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempClock::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempClock::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // Device Information service
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        if (m_deviceFirmware.isEmpty() || m_deviceFirmware == "UNKN")
        {
            serviceInfos = m_bleController->createServiceObject(uuid);
            if (!serviceInfos)
                qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{ebe0ccb0-7a0a-4b0c-8a1a-6ff2997da3a6}") // (custom) data service
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceHygrotempClock::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempClock::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            SettingsManager *sm = SettingsManager::getInstance();

            // Characteristic "Units" // 1 byte READ WRITE // 0x00 - F, 0x01 - C    READ WRITE
            {
                QBluetoothUuid u(QStringLiteral("EBE0CCBE-7A0A-4B0C-8A1A-6FF2997DA3A6"));
                QLowEnergyCharacteristic chu = serviceData->characteristic(u);

                const quint8 *unit = reinterpret_cast<const quint8 *>(chu.value().constData());
                //qDebug() << "Units (0xFF: CELSIUS / 0x01: FAHRENHEIT) > " << chu.value();
                if (unit[0] == 0xFF && sm->getTempUnit() == "F")
                {
                    serviceData->writeCharacteristic(chu, QByteArray::fromHex("01"), QLowEnergyService::WriteWithResponse);
                }
                else if (unit[0] == 0x01 && sm->getTempUnit() == "C")
                {
                    serviceData->writeCharacteristic(chu, QByteArray::fromHex("FF"), QLowEnergyService::WriteWithResponse);
                }
            }

            // History
            //UUID_HISTORY = 'EBE0CCBC-7A0A-4B0C-8A1A-6FF2997DA3A6'   # Last idx 152          READ NOTIFY

            // Characteristic "Time" // 5 bytes READ WRITE
            {
                QBluetoothUuid a(QStringLiteral("EBE0CCB7-7A0A-4B0C-8A1A-6FF2997DA3A6"));
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                //serviceData->readCharacteristic(cha); // trigger a new time read, not necessary

                const qint8 *timedata = reinterpret_cast<const qint8 *>(cha.value().constData());
                int8_t timezone_read = timedata[4]; Q_UNUSED(timezone_read)
                int32_t epoch_read = timedata[0];
                epoch_read += (timedata[1] << 8);
                epoch_read += (timedata[2] << 16);
                epoch_read += (timedata[3] << 24);
/*
                QDateTime time_read;
                time_read.setSecsSinceEpoch(epoch_read);
                qDebug() << "epoch READ: " << epoch_read;
                qDebug() << "QDateTime READ: " << time_read;
                qDebug() << "QTimeZone READ: " << timezone_read;
*/
                int32_t epoch_now = static_cast<int32_t>(QDateTime::currentSecsSinceEpoch()); // This device clock will not handle the year 2038...
                int8_t offset_now = static_cast<int8_t>(QDateTime::currentDateTime().offsetFromUtc() / 3600);
/*
                qDebug() << "QDateTime NOW: " << QDateTime::currentDateTime();
                qDebug() << "QTimeZone NOW: " << offset_now;
                qDebug() << "epoch NOW: " << epoch_now;
*/
                // Note: the device doesn't update its "Time" characteristic value often
                // So we don't use a single minute mismatch, but 5, to avoid reseting clock everytime
                if (std::abs(epoch_read - epoch_now) > 5*60)
                {
                    //qDebug() << "CLOCK TIME NEEDS AN UPDATE (diff: " << std::abs(epoch_read - epoch_now);

                    QByteArray timedata_write;
                    timedata_write.resize(5);
                    timedata_write[0] = static_cast<char>((epoch_now      ) & 0xFF);
                    timedata_write[1] = static_cast<char>((epoch_now >>  8) & 0xFF);
                    timedata_write[2] = static_cast<char>((epoch_now >> 16) & 0xFF);
                    timedata_write[3] = static_cast<char>((epoch_now >> 24) & 0xFF);
                    timedata_write[4] = offset_now;

                    //qDebug() << "QDateTime WRITE:" << timedata_write << " size:" << timedata_write.size();
                    serviceData->writeCharacteristic(cha, timedata_write, QLowEnergyService::WriteWithResponse);
                }
            }

            // Characteristic "Temp&Humi" // 3 bytes, READ NOTIFY
            {
                QBluetoothUuid b(QStringLiteral("EBE0CCC1-7A0A-4B0C-8A1A-6FF2997DA3A6"));
                QLowEnergyCharacteristic chb = serviceData->characteristic(b);
                m_notificationDesc = chb.clientCharacteristicConfiguration();
                serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
            }

            // Characteristic "Battery level" // 1 byte READ
            {
                QBluetoothUuid b(QStringLiteral("EBE0CCC4-7A0A-4B0C-8A1A-6FF2997DA3A6"));
                QLowEnergyCharacteristic chb = serviceData->characteristic(b);

                int lvl = static_cast<uint8_t>(chb.value().constData()[0]);
                setBattery(lvl);
            }
        }
    }
}

void DeviceHygrotempClock::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempClock::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            // Characteristic "Firmware Revision String"
            QBluetoothUuid c(QStringLiteral("00002a26-0000-1000-8000-00805f9b34fb"));
            QLowEnergyCharacteristic chc = serviceInfos->characteristic(c);
            if (chc.value().size() > 0)
            {
               QString fw = chc.value();
               setFirmware(fw);
            }

            if (m_deviceFirmware.size() == 10)
            {
                if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
            }
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempClock::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotempClock::bleWriteDone(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceHygrotempClock::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempClock::bleReadDone(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString().toUpper() == "{EBE0CCB7-7A0A-4B0C-8A1A-6FF2997DA3A6}")
    {
        // timedate

        if (value.size() == 5)
        {
            const qint8 *data = reinterpret_cast<const qint8 *>(value.constData());

            qint8 timezone_read = data[4];
            int32_t epoch_read = data[0];
            epoch_read += (data[1] << 8);
            epoch_read += (data[2] << 16);
            epoch_read += (data[3] << 24);

            QDateTime time_read;
            time_read.setSecsSinceEpoch(epoch_read);
            qDebug() << "QDateTime READ: " << time_read;
            qDebug() << "QTimeZone READ: " << timezone_read;
        }
    }
}

void DeviceHygrotempClock::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempClock::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString().toUpper() == "{EBE0CCC1-7A0A-4B0C-8A1A-6FF2997DA3A6}")
    {
        // sensor data

        if (value.size() == 3)
        {
            const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

            m_temperature = static_cast<int16_t>(data[0] + (data[1] << 8)) / 100.f;
            m_humidity = data[2];

            m_lastUpdate = QDateTime::currentDateTime();
            addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();
            }
            else
            {
                refreshDataFinished(true);
                m_bleController->disconnectFromDevice();
            }
/*
            qDebug() << "* DeviceHygrotempClock update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
*/
        }
    }
}

void DeviceHygrotempClock::confirmedDescriptorWrite(const QLowEnergyDescriptor &d, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempClock::confirmedDescriptorWrite!";

    if (d.isValid() && d == m_notificationDesc && value == QByteArray::fromHex("0000"))
    {
        qDebug() << "confirmedDescriptorWrite() disconnect?!";

        //disabled notifications -> assume disconnect intent
        //m_control->disconnectFromDevice();
        //delete m_service;
        //m_service = nullptr;
    }
}

/* ************************************************************************** */

void DeviceHygrotempClock::parseAdvertisementData(const uint16_t adv_mode,
                                                  const uint16_t adv_id,
                                                  const QByteArray &ba)
{
/*
    qDebug() << "DeviceHygrotempClock::parseAdvertisementData(" << m_deviceAddress
             << " - " << adv_mode << " - 0x" << adv_id << ")";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (ba.size() >= 12) // MiBeacon protocol / 12-10 bytes messages
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

            if (m_temperature > -99.f && m_humidity > -99.f)
            {
                m_lastUpdate = QDateTime::currentDateTime();

                if (needsUpdateDb_mini())
                {
                    addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);
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
