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

#include "device_govee.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>
#include <QRegularExpression>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */
/* ************************************************************************** */

QString DeviceGoveeHelpers::model(const QString &name)
{
    static const QRegularExpression format(QStringLiteral("^(Govee_)?(GVH|GV|H|B)?(5[0-9]{3})(_?[0-9A-Fa-f]{4})?$"));

    const QRegularExpressionMatch m = format.match(name);
    if (!m.hasMatch() || (m.captured(1).isEmpty() && m.captured(2).isEmpty())) return QString();

    const QString prefix = m.captured(2);
    const QString digits = m.captured(3);
    if (prefix == QLatin1String("B") && digits != QLatin1String("5178")) return QString();
    if (prefix == QLatin1String("GV") && digits == QLatin1String("5179")) return QStringLiteral("GV5179");

    return QStringLiteral("H") + digits;
}

const QStringList &DeviceGoveeHelpers::packed0001()
{
    static const QStringList models = {
        "H5100", "H5101", "H5102", "H5103", "H5104", "H5105", "H5108", "H5110", "H5174", "H5177", "GV5179",
    };
    return models;
}

/* ************************************************************************** */

bool DeviceGoveeHelpers::isValid(const float temperature, const float humidity)
{
    return (temperature >= -40.f && temperature <= 100.f && humidity >= 0.f && humidity <= 100.f);
}

void DeviceGoveeHelpers::unpackTemperatureHumidity(const QByteArray &ba, int pos, Values &v)
{
    const uint32_t raw = DeviceUtils::readBE(ba, pos, 3);
    const uint32_t value = raw & 0x7FFFFF;

    float temperature = (value / 1000) / 10.f;
    if (raw & 0x800000) temperature = -temperature;
    const float humidity = (value % 1000) / 10.f;

    if (isValid(temperature, humidity))
    {
        v.temperature = temperature;
        v.humidity = humidity;
    }
}

bool DeviceGoveeHelpers::unpackErrorBattery(const uint8_t b, Values &v)
{
    if ((b & 0x7F) <= 100) v.battery = (b & 0x7F);
    return (b & 0x80);
}

bool DeviceGoveeHelpers::parse(const QString &model, const uint16_t id, QByteArray ba, Values &v)
{
    // Some firmwares glue an iBeacon frame ("INTELLI_ROCKS_HW") at the end of the data
    if (ba.size() > ibeacon_suffix_size && ba.contains("INTELLI_ROCKS")) ba.chop(ibeacon_suffix_size);

    const int size = ba.size();
    const uint8_t *data = reinterpret_cast<const uint8_t *>(ba.constData());

    // Packed temperature / humidity, then the error / battery byte
    auto packed = [&](int pos) {
        if (!unpackErrorBattery(data[pos + 3], v)) unpackTemperatureHumidity(ba, pos, v);
        return true;
    };

    // Little endian temperature (int16, 0.01 °C), humidity (uint16, 0.01 %), battery (uint8, %)
    auto littleEndian = [&](int pos) {
        const float temperature = static_cast<int16_t>(data[pos] | (data[pos + 1] << 8)) / 100.f;
        const float humidity = static_cast<uint16_t>(data[pos + 2] | (data[pos + 3] << 8)) / 100.f;
        if (isValid(temperature, humidity))
        {
            v.temperature = temperature;
            v.humidity = humidity;
        }
        if (data[pos + 4] <= 100) v.battery = data[pos + 4];
        return true;
    };

    if (id == id_ec88)
    {
        if (size == 6 && (model == "H5072" || model == "H5075" || model == "H5129")) return packed(1);
        if (size == 7 && model == "H5074") return littleEndian(1);
        if (size == 9 && (model == "H5051" || model == "H5052" || model == "H5071")) return littleEndian(1);
    }
    else if (id == id_0001)
    {
        if ((size == 6 || size == 8) && packed0001().contains(model)) return packed(2);

        if (size == 9 && model == "H5178")
        {
            // Sensor ID: 0 main unit, 1 remote sensor (ignored)
            if (data[2] != 0) return false;
            return packed(3);
        }
        if (size == 8 && model == "H5112")
        {
            // Probe ID: 0x41 probe 1 (temperature and humidity), 0x82 probe 2 (ignored, battery only)
            if (data[7] == 0x41) return packed(2);
            if (data[7] == 0x82)
            {
                unpackErrorBattery(data[5], v);
                return true;
            }
            return false;
        }
        if (size == 6 && model == "H5106")
        {
            // 4 bytes big endian, bit 31 is the temperature sign
            const uint32_t raw = DeviceUtils::readBE(ba, 2, 4);
            const uint32_t value = raw & 0x7FFFFFFF;

            float temperature = (value / 1000000) / 10.f;
            if (raw & 0x80000000) temperature = -temperature;
            const float humidity = ((value % 1000000) / 1000) / 10.f;

            if (isValid(temperature, humidity))
            {
                v.temperature = temperature;
                v.humidity = humidity;
                v.pm25 = value % 1000;
            }
            return true;
        }
        if (size == 8 && model == "H5140")
        {
            // Byte 7: sensor error
            if (data[7] != 0) return true;

            unpackTemperatureHumidity(ba, 2, v);
            v.co2 = static_cast<uint16_t>((data[5] << 8) | data[6]);
            return true;
        }
    }
    else if (id == id_8801)
    {
        if (size == 9 && model == "H5179") return littleEndian(4);
    }

    return false;
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceGoveeHygrometer::DeviceGoveeHygrometer(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    setup();
}

DeviceGoveeHygrometer::DeviceGoveeHygrometer(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    setup();
}

DeviceGoveeHygrometer::~DeviceGoveeHygrometer()
{
    //
}

void DeviceGoveeHygrometer::setup()
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceManufacturer = "Govee";
    m_deviceModel = DeviceGoveeHelpers::model(m_deviceName);
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

/* ************************************************************************** */

bool DeviceGoveeHygrometer::isGoveeHygrometer(const QString &deviceName)
{
    const QString model = DeviceGoveeHelpers::model(deviceName);
    if (model.isEmpty()) return false;

    static const QStringList models = {
        "H5072", "H5075", "H5129", "H5074", "H5051", "H5052", "H5071", "H5178", "H5179", "H5112",
    };
    return models.contains(model) || DeviceGoveeHelpers::packed0001().contains(model);
}

/* ************************************************************************** */

void DeviceGoveeHygrometer::serviceScanDone()
{
    //qDebug() << "DeviceGoveeHygrometer::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceGoveeHygrometer::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceGoveeHygrometer::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceGoveeHygrometer::parseAdvertisementData(const uint16_t adv_mode,
                                                   const uint16_t adv_id,
                                                   const QByteArray &ba)
{
/*
    qDebug() << "DeviceGoveeHygrometer::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (adv_mode != DeviceUtils::BLE_ADV_MANUFACTURERDATA) return;

    DeviceGoveeHelpers::Values v;
    if (!DeviceGoveeHelpers::parse(m_deviceModel, adv_id, ba, v)) return;

    if (v.battery >= 0) setBattery(v.battery);

    if (v.temperature > -99.f && v.humidity > -99.f)
    {
        if (v.temperature != m_temperature || v.humidity != m_humidity)
        {
            m_temperature = v.temperature;
            m_humidity = v.humidity;
            Q_EMIT dataUpdated();
        }

        m_lastUpdate = QDateTime::currentDateTime();

        if (needsUpdateDb_mini())
        {
            addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);
            refreshDataFinished(true);
        }
        else
        {
            refreshAdvertisement();
        }
/*
        qDebug() << "* Govee manufacturer data:" << getName() << getAddress() << m_deviceModel;
        qDebug() << "- battery:" << m_deviceBattery;
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
*/
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceGoveeAirQuality::DeviceGoveeAirQuality(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    setup();
}

DeviceGoveeAirQuality::DeviceGoveeAirQuality(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    setup();
}

DeviceGoveeAirQuality::~DeviceGoveeAirQuality()
{
    //
}

void DeviceGoveeAirQuality::setup()
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceManufacturer = "Govee";
    m_deviceModel = DeviceGoveeHelpers::model(m_deviceName);
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    if (m_deviceModel == "H5106") m_deviceSensors += DeviceUtils::SENSOR_PM25;
    if (m_deviceModel == "H5140") m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

/* ************************************************************************** */

bool DeviceGoveeAirQuality::isGoveeAirQuality(const QString &deviceName)
{
    const QString model = DeviceGoveeHelpers::model(deviceName);
    return (model == "H5106" || model == "H5140");
}

/* ************************************************************************** */

void DeviceGoveeAirQuality::serviceScanDone()
{
    //qDebug() << "DeviceGoveeAirQuality::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceGoveeAirQuality::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceGoveeAirQuality::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceGoveeAirQuality::parseAdvertisementData(const uint16_t adv_mode,
                                                   const uint16_t adv_id,
                                                   const QByteArray &ba)
{
/*
    qDebug() << "DeviceGoveeAirQuality::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (adv_mode != DeviceUtils::BLE_ADV_MANUFACTURERDATA) return;

    DeviceGoveeHelpers::Values v;
    if (!DeviceGoveeHelpers::parse(m_deviceModel, adv_id, ba, v)) return;

    if (v.temperature > -99.f && v.humidity > -99.f)
    {
        if (v.temperature != m_temperature || v.humidity != m_humidity ||
            v.pm25 != m_pm_25 || v.co2 != m_co2)
        {
            m_temperature = v.temperature;
            m_humidity = v.humidity;
            m_pm_25 = v.pm25;
            m_co2 = v.co2;
            Q_EMIT dataUpdated();
        }

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
        qDebug() << "* Govee manufacturer data:" << getName() << getAddress() << m_deviceModel;
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
        qDebug() << "- pm2.5:" << m_pm_25;
        qDebug() << "- co2:" << m_co2;
*/
    }
}

void DeviceGoveeAirQuality::addDatabaseRecord()
{
    if (!m_dbInternal && !m_dbExternal) return;

    // Values not sent by this model are saved as NULL
    auto value = [](float v) { return (v > -99.f) ? QVariant(v) : QVariant(); };

    // SQL date format YYYY-MM-DD HH:MM:SS
    QSqlQuery addData;
    addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp," \
                    " temperature, humidity, pm25, co2)" \
                    " VALUES (:deviceAddr, :timestamp_rounded, :timestamp," \
                    " :temp, :humi, :pm25, :co2)");
    addData.bindValue(":deviceAddr", getAddress());
    addData.bindValue(":timestamp_rounded", m_lastUpdate.toString("yyyy-MM-dd hh:00:00"));
    addData.bindValue(":timestamp", m_lastUpdate.toString("yyyy-MM-dd hh:mm:ss"));
    addData.bindValue(":temp", value(m_temperature));
    addData.bindValue(":humi", value(m_humidity));
    addData.bindValue(":pm25", value(m_pm_25));
    addData.bindValue(":co2", value(m_co2));

    if (addData.exec())
    {
        m_lastUpdateDatabase = m_lastUpdate;
    }
    else
    {
        qWarning() << "> DeviceGoveeAirQuality addData.exec() ERROR"
                   << addData.lastError().type() << ":" << addData.lastError().text();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */
