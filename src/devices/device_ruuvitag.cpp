/*!
 * This file is part of WatchFlower.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_ruuvitag.h"
#include "utils_maths.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceRuuviTag::DeviceRuuviTag(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceModel = "RuuviTag";
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
}

DeviceRuuviTag::DeviceRuuviTag(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceModel = "RuuviTag";
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
}

DeviceRuuviTag::~DeviceRuuviTag()
{
    //
}

/* ************************************************************************** */

bool DeviceRuuviTag::isRuuviTag(const QBluetoothDeviceInfo &info)
{
    if (!info.name().startsWith("Ruuvi ")) return false;

    // The name alone could be a Ruuvi Air, wait for the advertising data
    const QByteArray data = info.manufacturerData(s_ruuvi_company_id);
    if (data.isEmpty()) return false;

    const uint8_t format = static_cast<uint8_t>(data.at(0));
    return (format == s_ruuvi_format_rawv1 || format == s_ruuvi_format_rawv2);
}

/* ************************************************************************** */

void DeviceRuuviTag::serviceScanDone()
{
    //qDebug() << "DeviceRuuviTag::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceRuuviTag::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceRuuviTag::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceRuuviTag::parseAdvertisementData(const uint16_t adv_mode,
                                            const uint16_t adv_id,
                                            const QByteArray &ba)
{
/*
    qDebug() << "DeviceRuuviTag::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (adv_mode != DeviceUtils::BLE_ADV_MANUFACTURERDATA || adv_id != s_ruuvi_company_id) return;
    if (ba.isEmpty()) return;

    bool status = false;
    const uint8_t format = static_cast<uint8_t>(ba.at(0));
    if (format == s_ruuvi_format_rawv2) status = parseRawV2(ba);
    else if (format == s_ruuvi_format_rawv1) status = parseRawV1(ba);

    if (status && m_temperature > -99.f && m_humidity > -99.f && m_pressure > -99.f)
    {
        m_lastUpdate = QDateTime::currentDateTime();

        if (needsUpdateDb_mini())
        {
            addDatabaseRecord_weatherstation(m_lastUpdate.toSecsSinceEpoch(),
                                             m_temperature, m_humidity, m_pressure);

            refreshDataFinished(true);
        }
        else
        {
            refreshAdvertisement();
        }
/*
        qDebug() << "* RuuviTag manufacturer data:" << getName() << getAddress();
        qDebug() << "- battery:" << m_deviceBattery;
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
        qDebug() << "- pressure:" << m_pressure;
*/
    }
}

/* ************************************************************************** */

bool DeviceRuuviTag::parseRawV1(const QByteArray &ba)
{
    if (ba.size() != 14) return false;
    const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());

    // Temperature uses a sign bit, not two's complement
    float temp = (data[2] & 0x7F) + data[3] / 100.f;
    if (data[2] & 0x80) temp = -temp;

    const float humi = data[1] / 2.f;
    const float pres = (static_cast<uint16_t>((data[4] << 8) | data[5]) + 50000) / 100.f;
    const int battv = static_cast<uint16_t>((data[12] << 8) | data[13]);

    setValues(temp, humi, pres, battv);
    return true;
}

bool DeviceRuuviTag::parseRawV2(const QByteArray &ba)
{
    if (ba.size() != 24) return false;
    const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());

    // MAC address (for macOS and iOS)
    if (!hasAddressMAC())
    {
        setAddressMAC(ba.mid(18, 6).toHex(':').toUpper());
    }

    // Invalid values are the smallest signed or the largest unsigned value, mapped to -99
    const int16_t temp_raw = static_cast<int16_t>((data[1] << 8) | data[2]);
    const uint16_t humi_raw = static_cast<uint16_t>((data[3] << 8) | data[4]);
    const uint16_t pres_raw = static_cast<uint16_t>((data[5] << 8) | data[6]);
    const uint16_t power = static_cast<uint16_t>((data[13] << 8) | data[14]);

    const float temp = (temp_raw != INT16_MIN) ? temp_raw * 0.005f : -99.f;
    const float humi = (humi_raw != 0xFFFF) ? humi_raw * 0.0025f : -99.f;
    const float pres = (pres_raw != 0xFFFF) ? (pres_raw + 50000) / 100.f : -99.f;
    const int battv = ((power >> 5) != 0x7FF) ? (power >> 5) + 1600 : -99;

    setValues(temp, humi, pres, battv);
    return true;
}

void DeviceRuuviTag::setValues(const float temp, const float humi, const float pres, const int battv)
{
    if (temp > -40.f && temp < 100.f && temp != m_temperature)
    {
        m_temperature = temp;
        Q_EMIT dataUpdated();
    }
    if (humi >= 0.f && humi <= 100.f && humi != m_humidity)
    {
        m_humidity = humi;
        Q_EMIT dataUpdated();
    }
    if (pres >= 500.f && pres <= 1200.f && pres != m_pressure)
    {
        m_pressure = pres;
        Q_EMIT dataUpdated();
    }

    // CR2477 coin cell, nominal 3.0 V, considered empty at 2.5 V
    if (battv > 0)
    {
        setBattery(mapNumber(battv, 2500, 3000, 0, 100));
    }
}

/* ************************************************************************** */
