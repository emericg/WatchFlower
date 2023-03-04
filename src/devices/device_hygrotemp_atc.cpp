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
 * \date      2023
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_hygrotemp_atc.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempATC::DeviceHygrotempATC(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempATC::DeviceHygrotempATC(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempATC::~DeviceHygrotempATC()
{
    //
}

/* ************************************************************************** */

void DeviceHygrotempATC::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempATC::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceHygrotempATC::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempATC::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED (uuid)
}

/* ************************************************************************** */

void DeviceHygrotempATC::parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &ba)
{
/*
    qDebug() << "DeviceHygrotempATC::parseAdvertisementData(" << m_deviceAddress
             << " - " << adv_mode << " - 0x" << QString::number(adv_id, 16) << ")";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());
    const int data_size = ba.size();

    // MiBeacon protocol / 16b UUID 0xFE95 / 12-20 bytes messages

    if (adv_id == 0xFE95 && ba.size() >= 12)
    {
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

        if (data_size >= 15)
        {
            int batt = -99;
            float temp = -99.f;
            float humi = -99.f;
            // get data
            if (data[11] == 4 && data_size >= 16)
            {
                temp = static_cast<int16_t>(data[14] + (data[15] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    if (temp > -30.f && temp < 100.f)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                    }
                }
                qDebug() << "temp" << temp;
            }
            else if (data[11] == 6 && data_size >= 16)
            {
                humi = static_cast<int16_t>(data[14] + (data[15] << 8)) / 10.f;
                if (humi != m_humidity)
                {
                    if (humi >= 0.f && humi <= 100.f)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[11] == 10 && data_size >= 15)
            {
                batt = static_cast<int8_t>(data[14]);
                setBattery(batt);
            }
            else if (data[11] == 13 && data_size >= 18)
            {
                temp = static_cast<int16_t>(data[14] + (data[15] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
                humi = static_cast<int16_t>(data[16] + (data[17] << 8)) / 10.f;
                if (humi != m_humidity)
                {
                    m_humidity = humi;
                    Q_EMIT dataUpdated();
                }
            }
            else
            {
                qDebug() << "MiBeacon: unknown tag >" << data[11];
            }

            if (m_temperature > -99.f && m_humidity > -99.f)
            {
                m_lastUpdate = QDateTime::currentDateTime();

                if (needsUpdateDb_mini())
                {
                    addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);

                    refreshDataFinished(true);
                }
                else
                {
                    refreshRealtimeFinished();
                }
            }
/*
            if (batt > -99 || temp > -99.f || humi > -99.f)
            {
                qDebug() << "* MiBeacon service data:" << getName() << getAddress() << "(" << data_size << ") bytes";
                if (batt > -99) qDebug() << "- battery:" << batt;
                if (temp > -99) qDebug() << "- temperature:" << temp;
                if (humi > -99) qDebug() << "- humidity:" << humi;
            }
*/
        }
    }
}

/* ************************************************************************** */
