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

#include "device_switchbot.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */
/* ************************************************************************** */

QString DeviceSwitchBotHelpers::modelFromServiceData(const QByteArray &svd)
{
    if (svd.isEmpty()) return QString();

    switch (static_cast<uint8_t>(svd.at(0)) & 0x7F)
    {
        case 0x54: case 0x74: return QStringLiteral("Meter");                           // 'T' 't'
        case 0x69: case 0x49: return QStringLiteral("Meter Plus");                      // 'i' 'I'
        case 0x34: case 0x14: return QStringLiteral("Meter Pro");                       // '4'
        case 0x35: case 0x15: return model_meter_pro_co2;                     // '5'
        case 0x77: case 0x57: return QStringLiteral("Indoor/Outdoor Thermo-Hygrometer"); // 'w' 'W'
    }

    if (svd.size() > 5)
    {
        for (const int pos: { int(svd.size()) - 4, int(svd.size()) - 5 })
        {
            const uint32_t id = DeviceUtils::readBE(svd, pos, 4);
            if (id == 0x001053B0 || id == 0x011053B0) return model_weather_station;
        }
    }

    return QString();
}

QString DeviceSwitchBotHelpers::modelFromName(const QString &name)
{
    if (name == "WoSensorTH") return QStringLiteral("Meter");
    if (name == "WoSensorTHPlus") return QStringLiteral("Meter Plus");
    if (name == "WoSensorTHP") return QStringLiteral("Meter Pro");
    if (name == "WoSensorTHPc") return model_meter_pro_co2;
    if (name == "WoIOSensorTH") return QStringLiteral("Indoor/Outdoor Thermo-Hygrometer");
    return QString();
}

QString DeviceSwitchBotHelpers::model(const QBluetoothDeviceInfo &info)
{
    const QString model = modelFromServiceData(info.serviceData(QBluetoothUuid(service_uuid)));
    return model.isEmpty() ? modelFromName(info.name()) : model;
}

const QStringList &DeviceSwitchBotHelpers::hygrometers()
{
    static const QStringList models = {
        "Meter", "Meter Plus", "Meter Pro", "Indoor/Outdoor Thermo-Hygrometer", model_weather_station,
    };
    return models;
}

/* ************************************************************************** */

void DeviceSwitchBotHelpers::decodeTemperatureHumidity(const QByteArray &ba, int pos, Values &v)
{
    const uint8_t *data = reinterpret_cast<const uint8_t *>(ba.constData()) + pos;

    float temperature = (data[1] & 0x7F) + (data[0] & 0x0F) / 10.f;
    if (!(data[1] & 0x80)) temperature = -temperature;
    const float humidity = data[2] & 0x7F;

    if (temperature == 0.f && humidity == 0.f) return;
    if (humidity > 100.f) return;

    v.temperature = temperature;
    v.humidity = humidity;
}

void DeviceSwitchBotHelpers::parse(const QString &model, const QByteArray &svd, const QByteArray &mfd, Values &v)
{
    if (model == model_weather_station)
    {
        // Values and battery from the manufacturer data, else from the service data
        if (mfd.size() >= 11)
        {
            v.battery = static_cast<uint8_t>(mfd.at(7)) & 0x7F;
            decodeTemperatureHumidity(mfd, 8, v);
        }
        else if (svd.size() >= 6)
        {
            v.battery = static_cast<uint8_t>(svd.at(2)) & 0x7F;
            decodeTemperatureHumidity(svd, 3, v);
        }
        return;
    }

    // Values from the manufacturer data, else from the service data, battery from the service data
    if (mfd.size() >= 11) decodeTemperatureHumidity(mfd, 8, v);
    else if (svd.size() >= 6) decodeTemperatureHumidity(svd, 3, v);
    if (svd.size() >= 3) v.battery = static_cast<uint8_t>(svd.at(2)) & 0x7F;

    if (model == model_meter_pro_co2 && mfd.size() >= 15)
    {
        const int co2 = static_cast<int>(DeviceUtils::readBE(mfd, 13, 2));
        if (co2 <= 9999) v.co2 = co2;
    }
}

bool DeviceSwitchBotHelpers::keep(const uint16_t adv_mode, const uint16_t adv_id,
                                  const QByteArray &ba, QByteArray &svd, QByteArray &mfd)
{
    if (adv_mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA && adv_id == company_id)
    {
        mfd = ba;
        return true;
    }
    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA && adv_id == service_uuid)
    {
        if (ba.isEmpty() || (static_cast<uint8_t>(ba.at(0)) & 0x80)) return false;
        svd = ba;
        return true;
    }
    return false;
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceSwitchBotHygrometer::DeviceSwitchBotHygrometer(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    setup(QByteArray());
}

DeviceSwitchBotHygrometer::DeviceSwitchBotHygrometer(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    setup(d.serviceData(QBluetoothUuid(DeviceSwitchBotHelpers::service_uuid)));
}

DeviceSwitchBotHygrometer::~DeviceSwitchBotHygrometer()
{
    //
}

/* ************************************************************************** */

void DeviceSwitchBotHygrometer::setup(const QByteArray &serviceData)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceManufacturer = "SwitchBot";
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;

    // Model from the service data, else the saved model, else from the name
    QString model = DeviceSwitchBotHelpers::modelFromServiceData(serviceData);
    if (model.isEmpty() && DeviceSwitchBotHelpers::hygrometers().contains(m_deviceModel)) model = m_deviceModel;
    if (model.isEmpty()) model = DeviceSwitchBotHelpers::modelFromName(m_deviceName);
    m_deviceModel = model;
}

/* ************************************************************************** */

bool DeviceSwitchBotHygrometer::isSwitchBotHygrometer(const QBluetoothDeviceInfo &info)
{
    return DeviceSwitchBotHelpers::hygrometers().contains(DeviceSwitchBotHelpers::model(info));
}

bool DeviceSwitchBotHygrometer::isSwitchBotHygrometer(const QString &deviceName, const QString &deviceModel)
{
    return DeviceSwitchBotHelpers::hygrometers().contains(deviceModel) ||
           DeviceSwitchBotHelpers::hygrometers().contains(DeviceSwitchBotHelpers::modelFromName(deviceName));
}

/* ************************************************************************** */

void DeviceSwitchBotHygrometer::serviceScanDone()
{
    //qDebug() << "DeviceSwitchBotHygrometer::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceSwitchBotHygrometer::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceSwitchBotHygrometer::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceSwitchBotHygrometer::parseAdvertisementData(const uint16_t adv_mode,
                                                       const uint16_t adv_id,
                                                       const QByteArray &ba)
{
/*
    qDebug() << "DeviceSwitchBotHygrometer::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (!DeviceSwitchBotHelpers::keep(adv_mode, adv_id, ba, m_serviceData, m_manufacturerData)) return;

    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA)
    {
        const QString model = DeviceSwitchBotHelpers::modelFromServiceData(m_serviceData);
        if (DeviceSwitchBotHelpers::hygrometers().contains(model)) setModel(model);
    }

    DeviceSwitchBotHelpers::Values v;
    DeviceSwitchBotHelpers::parse(m_deviceModel, m_serviceData, m_manufacturerData, v);

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
        qDebug() << "* SwitchBot advertisement:" << getName() << getAddress() << m_deviceModel;
        qDebug() << "- battery:" << m_deviceBattery;
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
*/
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceSwitchBotAirQuality::DeviceSwitchBotAirQuality(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    setup();
}

DeviceSwitchBotAirQuality::DeviceSwitchBotAirQuality(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    setup();
}

DeviceSwitchBotAirQuality::~DeviceSwitchBotAirQuality()
{
    //
}

/* ************************************************************************** */

void DeviceSwitchBotAirQuality::setup()
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceManufacturer = "SwitchBot";
    m_deviceModel = DeviceSwitchBotHelpers::model_meter_pro_co2;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

/* ************************************************************************** */

bool DeviceSwitchBotAirQuality::isSwitchBotAirQuality(const QBluetoothDeviceInfo &info)
{
    return (DeviceSwitchBotHelpers::model(info) == DeviceSwitchBotHelpers::model_meter_pro_co2);
}

bool DeviceSwitchBotAirQuality::isSwitchBotAirQuality(const QString &deviceName, const QString &deviceModel)
{
    return (deviceModel == DeviceSwitchBotHelpers::model_meter_pro_co2 ||
            DeviceSwitchBotHelpers::modelFromName(deviceName) == DeviceSwitchBotHelpers::model_meter_pro_co2);
}

/* ************************************************************************** */

void DeviceSwitchBotAirQuality::serviceScanDone()
{
    //qDebug() << "DeviceSwitchBotAirQuality::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceSwitchBotAirQuality::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceSwitchBotAirQuality::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED(uuid)
}

/* ************************************************************************** */

void DeviceSwitchBotAirQuality::parseAdvertisementData(const uint16_t adv_mode,
                                                       const uint16_t adv_id,
                                                       const QByteArray &ba)
{
/*
    qDebug() << "DeviceSwitchBotAirQuality::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (!DeviceSwitchBotHelpers::keep(adv_mode, adv_id, ba, m_serviceData, m_manufacturerData)) return;

    DeviceSwitchBotHelpers::Values v;
    DeviceSwitchBotHelpers::parse(m_deviceModel, m_serviceData, m_manufacturerData, v);

    if (v.battery >= 0) setBattery(v.battery);

    if (v.temperature > -99.f && v.humidity > -99.f && v.co2 > -99.f)
    {
        if (v.temperature != m_temperature || v.humidity != m_humidity || v.co2 != m_co2)
        {
            m_temperature = v.temperature;
            m_humidity = v.humidity;
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
        qDebug() << "* SwitchBot advertisement:" << getName() << getAddress() << m_deviceModel;
        qDebug() << "- battery:" << m_deviceBattery;
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
        qDebug() << "- co2:" << m_co2;
*/
    }
}

void DeviceSwitchBotAirQuality::addDatabaseRecord()
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
        qWarning() << "> DeviceSwitchBotAirQuality addData.exec() ERROR"
                   << addData.lastError().type() << ":" << addData.lastError().text();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */
