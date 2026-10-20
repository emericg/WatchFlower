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

#include "device_ruuviair.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceRuuviAir::DeviceRuuviAir(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceModel = "Ruuvi Air";
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
    m_deviceSensors += DeviceUtils::SENSOR_PM1;
    m_deviceSensors += DeviceUtils::SENSOR_PM25;
    m_deviceSensors += DeviceUtils::SENSOR_PM10;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

DeviceRuuviAir::DeviceRuuviAir(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceModel = "Ruuvi Air";
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
    m_deviceSensors += DeviceUtils::SENSOR_PM1;
    m_deviceSensors += DeviceUtils::SENSOR_PM25;
    m_deviceSensors += DeviceUtils::SENSOR_PM10;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

DeviceRuuviAir::~DeviceRuuviAir()
{
    //
}

/* ************************************************************************** */

bool DeviceRuuviAir::isRuuviAir(const QBluetoothDeviceInfo &info)
{
    if (!info.name().startsWith("Ruuvi ")) return false;

    const QByteArray data = info.manufacturerData(s_ruuvi_company_id);
    if (data.isEmpty()) return false;

    const uint8_t format = static_cast<uint8_t>(data.at(0));
    return (format == s_ruuvi_format_air || format == s_ruuvi_format_air_extended);
}

/* ************************************************************************** */

void DeviceRuuviAir::serviceScanDone()
{
    //qDebug() << "DeviceRuuviAir::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceRuuviAir::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceRuuviAir::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceRuuviAir::parseAdvertisementData(const uint16_t adv_mode,
                                            const uint16_t adv_id,
                                            const QByteArray &ba)
{
/*
    qDebug() << "DeviceRuuviAir::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (adv_mode != DeviceUtils::BLE_ADV_MANUFACTURERDATA || adv_id != s_ruuvi_company_id) return;
    if (ba.isEmpty()) return;

    bool status = false;
    const uint8_t format = static_cast<uint8_t>(ba.at(0));
    if (format == s_ruuvi_format_air_extended) status = parseFormatE1(ba);
    else if (format == s_ruuvi_format_air) status = parseFormat6(ba);

    if (status && m_temperature > -99.f && m_humidity > -99.f && m_co2 > -99.f)
    {
        m_lastUpdate = QDateTime::currentDateTime();

        if (needsUpdateDb_mini())
        {
            addDatabaseRecord();
            refreshDataFinished(true);
        }
        else
        {
            refreshAdvertisement();
        }
/*
        qDebug() << "* Ruuvi Air manufacturer data:" << getName() << getAddress();
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
        qDebug() << "- pressure:" << m_pressure;
        qDebug() << "- co2:" << m_co2;
        qDebug() << "- pm1 / pm2.5 / pm10:" << m_pm_1 << m_pm_25 << m_pm_10;
        qDebug() << "- luminosity:" << m_luminosityLux;
*/
    }
}

/* ************************************************************************** */

void DeviceRuuviAir::setEnvironment(const QByteArray &ba)
{
    // Temperature (int16, 0.005 °C), humidity (uint16, 0.0025 %), pressure (uint16, Pa, +50000 Pa)
    // Invalid values are the smallest signed or the largest unsigned value
    const int16_t temp_raw = static_cast<int16_t>(DeviceUtils::readBE(ba, 1, 2));
    const uint32_t humi_raw = DeviceUtils::readBE(ba, 3, 2);
    const uint32_t pres_raw = DeviceUtils::readBE(ba, 5, 2);

    if (temp_raw != INT16_MIN)
    {
        const float temp = temp_raw * 0.005f;
        if (temp > -40.f && temp < 100.f && temp != m_temperature)
        {
            m_temperature = temp;
            Q_EMIT dataUpdated();
        }
    }
    if (humi_raw != 0xFFFF)
    {
        const float humi = humi_raw * 0.0025f;
        if (humi >= 0.f && humi <= 100.f && humi != m_humidity)
        {
            m_humidity = humi;
            Q_EMIT dataUpdated();
        }
    }
    if (pres_raw != 0xFFFF)
    {
        const float pres = (pres_raw + 50000) / 100.f;
        if (pres != m_pressure)
        {
            m_pressure = pres;
            Q_EMIT dataUpdated();
        }
    }
}

bool DeviceRuuviAir::parseFormat6(const QByteArray &ba)
{
    if (ba.size() != 20) return false;

    setEnvironment(ba);

    const uint32_t pm25 = DeviceUtils::readBE(ba, 7, 2);
    if (pm25 != 0xFFFF && pm25 / 10.f != m_pm_25)
    {
        m_pm_25 = pm25 / 10.f;
        Q_EMIT dataUpdated();
    }

    const uint32_t co2 = DeviceUtils::readBE(ba, 9, 2);
    if (co2 != 0xFFFF && co2 != m_co2)
    {
        m_co2 = co2;
        Q_EMIT dataUpdated();
    }

    // Logarithmic luminosity code, 0 to 65535 lux
    const uint32_t lux_code = DeviceUtils::readBE(ba, 13, 1);
    if (lux_code != 0xFF)
    {
        const int lux = static_cast<int>(std::round(std::exp(lux_code * std::log(65536.0) / 254.0) - 1.0));
        if (lux != m_luminosityLux)
        {
            m_luminosityLux = lux;
            Q_EMIT dataUpdated();
        }
    }

    return true;
}

bool DeviceRuuviAir::parseFormatE1(const QByteArray &ba)
{
    if (ba.size() != 40) return false;

    // MAC address (for macOS and iOS)
    if (!hasAddressMAC() && ba.mid(34, 6) != QByteArray(6, char(0xFF)))
    {
        setAddressMAC(ba.mid(34, 6).toHex(':').toUpper());
    }

    setEnvironment(ba);

    // PM1.0, PM2.5, PM4.0 (not used), PM10 (uint16 each, 0.1 µg/m³)
    float *pm[] = { &m_pm_1, &m_pm_25, nullptr, &m_pm_10 };
    for (int i = 0; i < 4; i++)
    {
        const uint32_t raw = DeviceUtils::readBE(ba, 7 + i * 2, 2);
        if (pm[i] && raw != 0xFFFF && raw / 10.f != *pm[i])
        {
            *pm[i] = raw / 10.f;
            Q_EMIT dataUpdated();
        }
    }

    const uint32_t co2 = DeviceUtils::readBE(ba, 15, 2);
    if (co2 != 0xFFFF && co2 != m_co2)
    {
        m_co2 = co2;
        Q_EMIT dataUpdated();
    }

    // Luminosity (uint24, 0.01 lux)
    const uint32_t lux_raw = DeviceUtils::readBE(ba, 19, 3);
    if (lux_raw != 0xFFFFFF)
    {
        const int lux = static_cast<int>(std::round(lux_raw / 100.0));
        if (lux != m_luminosityLux)
        {
            m_luminosityLux = lux;
            Q_EMIT dataUpdated();
        }
    }

    return true;
}

/* ************************************************************************** */

void DeviceRuuviAir::addDatabaseRecord()
{
    if (!m_dbInternal && !m_dbExternal) return;

    // Values not sent by this data format are saved as NULL
    auto value = [](float v) { return (v > -99.f) ? QVariant(v) : QVariant(); };

    // SQL date format YYYY-MM-DD HH:MM:SS
    QSqlQuery addData;
    addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp," \
                    " temperature, humidity, pressure, luminosity, pm1, pm25, pm10, co2)" \
                    " VALUES (:deviceAddr, :timestamp_rounded, :timestamp," \
                    " :temp, :humi, :pres, :lumi, :pm1, :pm25, :pm10, :co2)");
    addData.bindValue(":deviceAddr", getAddress());
    addData.bindValue(":timestamp_rounded", m_lastUpdate.toString("yyyy-MM-dd hh:00:00"));
    addData.bindValue(":timestamp", m_lastUpdate.toString("yyyy-MM-dd hh:mm:ss"));
    addData.bindValue(":temp", value(m_temperature));
    addData.bindValue(":humi", value(m_humidity));
    addData.bindValue(":pres", value(m_pressure));
    addData.bindValue(":lumi", (m_luminosityLux >= 0) ? QVariant(m_luminosityLux) : QVariant());
    addData.bindValue(":pm1", value(m_pm_1));
    addData.bindValue(":pm25", value(m_pm_25));
    addData.bindValue(":pm10", value(m_pm_10));
    addData.bindValue(":co2", value(m_co2));

    if (addData.exec())
    {
        m_lastUpdateDatabase = m_lastUpdate;
    }
    else
    {
        qWarning() << "> DeviceRuuviAir addData.exec() ERROR"
                   << addData.lastError().type() << ":" << addData.lastError().text();
    }
}

/* ************************************************************************** */
