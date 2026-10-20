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

#include "device_inkbird.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */
/* ************************************************************************** */

QString DeviceInkbirdHelpers::model(const QString &name)
{
    const QString n = name.toLower();
    if (n == "sps") return QStringLiteral("IBS-TH");
    if (n == "tps") return QStringLiteral("IBS-TH2");
    if (n == "ibs-p02b" || n == "ith-11-b" || n == "ith-13-b" || n == "ith-21-b") return name.toUpper();
    return QString();
}

/* ************************************************************************** */

bool DeviceInkbirdHelpers::parseHygrometer(const QString &name, const uint16_t id, const QByteArray &ba, Values &v)
{
    const uint8_t *data = reinterpret_cast<const uint8_t *>(ba.constData());

    if (ba.size() == size_th)
    {
        const uint16_t humidity = static_cast<uint16_t>(data[0] | (data[1] << 8));
        v.noHumiditySensor = (name.toLower() == "tps") && (humidity == 0x0000 || humidity == 0xFFFF);
        if (!v.noHumiditySensor && humidity > 10000) return false;
        if (data[5] > 100) return false;

        v.temperature = static_cast<int16_t>(id) / 100.f;
        if (!v.noHumiditySensor) v.humidity = humidity / 100.f;
        v.battery = data[5];
        return true;
    }
    if (ba.size() == size_ith)
    {
        const uint16_t humidity = static_cast<uint16_t>(data[6] | (data[7] << 8));
        if (humidity > 1000 || data[8] > 100) return false;

        // 0 means no humidity sensor (IBS-P02B)
        v.temperature = static_cast<int16_t>(data[4] | (data[5] << 8)) / 10.f;
        if (humidity != 0) v.humidity = humidity / 10.f;
        v.battery = data[8];
        return true;
    }

    return false;
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceInkbirdHygrometer::DeviceInkbirdHygrometer(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    setup();
}

DeviceInkbirdHygrometer::DeviceInkbirdHygrometer(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    setup();
}

DeviceInkbirdHygrometer::~DeviceInkbirdHygrometer()
{
    //
}

/* ************************************************************************** */

void DeviceInkbirdHygrometer::setup()
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceManufacturer = "Inkbird";
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;

    // A "tps" device saved as an IBS-P01B keeps that model
    const QString model = DeviceInkbirdHelpers::model(m_deviceName);
    if (!(model == "IBS-TH2" && m_deviceModel == DeviceInkbirdHelpers::model_p01b)) m_deviceModel = model;

    // The IBS-P02B and IBS-P01B are pool thermometers
    if (m_deviceModel != "IBS-P02B" && m_deviceModel != DeviceInkbirdHelpers::model_p01b)
        m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

void DeviceInkbirdHygrometer::setNoHumiditySensor()
{
    if (m_deviceModel == "IBS-TH2") setModel(DeviceInkbirdHelpers::model_p01b);

    if (m_deviceSensors & DeviceUtils::SENSOR_HUMIDITY)
    {
        m_deviceSensors -= DeviceUtils::SENSOR_HUMIDITY;
        Q_EMIT sensorsUpdated();
    }
}

/* ************************************************************************** */

bool DeviceInkbirdHygrometer::isInkbirdHygrometer(const QBluetoothDeviceInfo &info)
{
    const QString name = info.name().toLower();
    if (name != "sps" && name != "tps") return !DeviceInkbirdHelpers::model(name).isEmpty();

    // Generic names, confirmed by the Inkbird service UUID or the payload size
    if (info.serviceUuids().contains(QBluetoothUuid(DeviceInkbirdHelpers::service_uuid))) return true;
    for (const auto id: info.manufacturerIds())
    {
        if (info.manufacturerData(id).size() == DeviceInkbirdHelpers::size_th) return true;
    }
    return false;
}

bool DeviceInkbirdHygrometer::isInkbirdHygrometer(const QString &deviceName)
{
    return !DeviceInkbirdHelpers::model(deviceName).isEmpty();
}

/* ************************************************************************** */

void DeviceInkbirdHygrometer::serviceScanDone()
{
    //qDebug() << "DeviceInkbirdHygrometer::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceInkbirdHygrometer::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceInkbirdHygrometer::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceInkbirdHygrometer::parseAdvertisementData(const uint16_t adv_mode,
                                                     const uint16_t adv_id,
                                                     const QByteArray &ba)
{
/*
    qDebug() << "DeviceInkbirdHygrometer::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (adv_mode != DeviceUtils::BLE_ADV_MANUFACTURERDATA) return;

    // Skip the data of previous advertisements, kept by the Bluetooth stack
    const auto seen = m_advSeen.constFind(adv_id);
    if (seen != m_advSeen.cend() && seen.value() == ba && !(adv_id == m_advLastId && ba == m_advLastData)) return;

    DeviceInkbirdHelpers::Values v;
    if (!DeviceInkbirdHelpers::parseHygrometer(m_deviceName, adv_id, ba, v)) return;

    if (m_advSeen.size() >= DeviceInkbirdHelpers::adv_seen_max) m_advSeen.clear();
    m_advSeen.insert(adv_id, ba);
    m_advLastId = adv_id;
    m_advLastData = ba;

    if (v.noHumiditySensor) setNoHumiditySensor();
    if (v.battery >= 0) setBattery(v.battery);

    if (v.temperature != m_temperature || v.humidity != m_humidity)
    {
        m_temperature = v.temperature;
        m_humidity = v.humidity;
        Q_EMIT dataUpdated();
    }

    m_lastUpdate = QDateTime::currentDateTime();

    if (needsUpdateDb_mini())
    {
        if (v.humidity > -99.f) addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);
        else addDatabaseRecord_thermometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature);
        refreshDataFinished(true);
    }
    else
    {
        refreshAdvertisement();
    }
/*
    qDebug() << "* Inkbird manufacturer data:" << getName() << getAddress() << m_deviceModel;
    qDebug() << "- battery:" << m_deviceBattery;
    qDebug() << "- temperature:" << m_temperature;
    qDebug() << "- humidity:" << m_humidity;
*/
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceInkbirdAirQuality::DeviceInkbirdAirQuality(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    setup();
}

DeviceInkbirdAirQuality::DeviceInkbirdAirQuality(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    setup();
}

DeviceInkbirdAirQuality::~DeviceInkbirdAirQuality()
{
    //
}

void DeviceInkbirdAirQuality::setup()
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceManufacturer = "Inkbird";
    m_deviceModel = "IAM-T2";
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

/* ************************************************************************** */

bool DeviceInkbirdAirQuality::isInkbirdAirQuality(const QString &deviceName)
{
    return (deviceName.toLower() == "ink@iam-t2");
}

/* ************************************************************************** */

void DeviceInkbirdAirQuality::serviceScanDone()
{
    //qDebug() << "DeviceInkbirdAirQuality::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceInkbirdAirQuality::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceInkbirdAirQuality::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceInkbirdAirQuality::parseAdvertisementData(const uint16_t adv_mode,
                                                     const uint16_t adv_id,
                                                     const QByteArray &ba)
{
/*
    qDebug() << "DeviceInkbirdAirQuality::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    Q_UNUSED(adv_id)
    if (adv_mode != DeviceUtils::BLE_ADV_MANUFACTURERDATA) return;
    if (ba.size() != DeviceInkbirdHelpers::size_iamt2) return;

    const uint8_t *data = reinterpret_cast<const uint8_t *>(ba.constData());

    // Byte 7 bit 1: the temperature is in °F
    float temperature = static_cast<int16_t>((data[8] << 8) | data[9]) / 10.f;
    if (data[7] & 0x02) temperature = (temperature - 32.f) * 5.f / 9.f;
    const float humidity = static_cast<uint16_t>((data[10] << 8) | data[11]) / 10.f;
    const float co2 = static_cast<uint16_t>((data[12] << 8) | data[13]);
    if (humidity > 100.f || co2 > DeviceInkbirdHelpers::co2_max) return;

    if (temperature != m_temperature || humidity != m_humidity || co2 != m_co2)
    {
        m_temperature = temperature;
        m_humidity = humidity;
        m_co2 = co2;
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
    qDebug() << "* Inkbird manufacturer data:" << getName() << getAddress() << m_deviceModel;
    qDebug() << "- temperature:" << m_temperature;
    qDebug() << "- humidity:" << m_humidity;
    qDebug() << "- co2:" << m_co2;
*/
}

void DeviceInkbirdAirQuality::addDatabaseRecord()
{
    if (!m_dbInternal && !m_dbExternal) return;

    // SQL date format YYYY-MM-DD HH:MM:SS
    QSqlQuery addData;
    addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp, temperature, humidity, co2)" \
                    " VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :temp, :humi, :co2)");
    addData.bindValue(":deviceAddr", getAddress());
    addData.bindValue(":timestamp_rounded", m_lastUpdate.toString("yyyy-MM-dd hh:00:00"));
    addData.bindValue(":timestamp", m_lastUpdate.toString("yyyy-MM-dd hh:mm:ss"));
    addData.bindValue(":temp", m_temperature);
    addData.bindValue(":humi", m_humidity);
    addData.bindValue(":co2", m_co2);

    if (addData.exec())
    {
        m_lastUpdateDatabase = m_lastUpdate;
    }
    else
    {
        qWarning() << "> DeviceInkbirdAirQuality addData.exec() ERROR"
                   << addData.lastError().type() << ":" << addData.lastError().text();
    }
}

/* ************************************************************************** */
