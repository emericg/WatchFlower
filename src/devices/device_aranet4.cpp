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

#include "device_aranet4.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceAranet4::DeviceAranet4(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

DeviceAranet4::DeviceAranet4(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

DeviceAranet4::~DeviceAranet4()
{
    delete serviceInfos;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceAranet4::serviceScanDone()
{
    //qDebug() << "DeviceAranet4::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceAranet4::serviceDetailsDiscovered_infos);
            connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceAranet4::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceAranet4::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceAranet4::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceAranet4::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceAranet4::addLowEnergyService(" << uuid.toString() << ")";

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

    if (uuid.toString() == "{0000fce0-0000-1000-8000-00805f9b34fb}" ||  // (custom) Aranet service, firmware >= 1.2.0
        uuid.toString() == "{f0cd1400-95da-4f4b-9ac8-aa55d312af0c}")   // (custom) Aranet service, firmware < 1.2.0
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceAranet4::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (serviceInfos && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranet4::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Firmware Revision"
        // Note: 0x2a28 "Software Revision" holds the factory firmware version, not the current one
        QBluetoothUuid fw(QStringLiteral("00002a26-0000-1000-8000-00805f9b34fb"));
        QLowEnergyCharacteristic cfw = serviceInfos->characteristic(fw);

        if (cfw.value().size() > 0)
        {
            QString fw = cfw.value();
            setFirmware(fw);
        }
        else
        {
            serviceInfos->readCharacteristic(cfw);
        }
    }
}

void DeviceAranet4::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (serviceData && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranet4::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Current Readings + Interval + Ago"
        // Note: on firmwares >= 1.2.0, this characteristic is only readable
        // if the device has been paired, or if "Smart Home integration" is enabled
        QBluetoothUuid rd(QStringLiteral("f0cd3001-95da-4f4b-9ac8-aa55d312af0c"));
        QLowEnergyCharacteristic crd = serviceData->characteristic(rd);

        if (crd.value().size() >= 9)
        {
            parseCurrentReadings(crd.value());
        }
        else
        {
            serviceData->readCharacteristic(crd);
        }
    }
}

/* ************************************************************************** */

void DeviceAranet4::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceAranet4::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString() == "{00002a26-0000-1000-8000-00805f9b34fb}") // Firmware Revision
    {
        if (value.size() > 0)
        {
            QString fw = value;
            setFirmware(fw);
        }
    }

    if (c.uuid().toString() == "{f0cd3001-95da-4f4b-9ac8-aa55d312af0c}") // Current Readings + Interval + Ago
    {
        parseCurrentReadings(value);
    }
}

/* ************************************************************************** */

void DeviceAranet4::parseCurrentReadings(const QByteArray &value)
{
    // 9 bytes for the "Current Readings" characteristic
    // 13 bytes for the "Current Readings + Interval + Ago" characteristic
    if (value.size() < 9)
    {
        refreshDataFinished(false);
        deviceDisconnect();
        return;
    }

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    uint16_t co2 = static_cast<uint16_t>(data[0] + (data[1] << 8));
    uint16_t temp = static_cast<uint16_t>(data[2] + (data[3] << 8));
    uint16_t pres = static_cast<uint16_t>(data[4] + (data[5] << 8));

    // Readings taken while the sensor is warming up, or while it is being calibrated,
    // are flagged as out of range: bit 15 for CO2 and pressure, bit 14 for temperature
    if ((co2 & 0x8000) || (pres & 0x8000) || (temp & 0x4000))
    {
        refreshDataFinished(false);
        deviceDisconnect();
        return;
    }

    m_co2 = co2;
    m_temperature = temp / 20.f;
    m_pressure = pres / 10.f;
    m_humidity = data[6];

    setBattery(data[7]);

    int64_t ago = 0;
    if (value.size() >= 13)
    {
        uint16_t interval = static_cast<uint16_t>(data[9] + (data[10] << 8));
        ago = static_cast<uint16_t>(data[11] + (data[12] << 8));

        if (ago > interval) ago = 0; // out of sync, use current time instead
    }

    m_lastUpdate = QDateTime::currentDateTime().addSecs(-ago);

    addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                      m_temperature, m_humidity, m_pressure, m_co2);

    refreshDataFinished(true);

    deviceDisconnect();
/*
    qDebug() << "* DeviceAranet4 update:" << getAddress();
    qDebug() << "- m_firmware:" << m_deviceFirmware;
    qDebug() << "- m_battery:" << m_deviceBattery;
    qDebug() << "- m_temperature:" << m_temperature;
    qDebug() << "- m_humidity:" << m_humidity;
    qDebug() << "- m_pressure:" << m_pressure;
    qDebug() << "- m_co2:" << m_co2;
*/
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceAranet4::hasData() const
{
    //qDebug() << "DeviceAranet4::hasData()";

    // If we have immediate data (<12h old)
    if (m_temperature > 0.f || m_humidity > 0.f || m_pressure > 0.f || m_co2 > 0.f)
        return true;

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(*) FROM sensorData WHERE deviceAddr = :deviceAddr;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(DeviceAranet4) ERROR"
                       << hasData.lastError().type() << ":" << hasData.lastError().text();
        }

        while (hasData.next())
        {
            if (hasData.value(0).toInt() > 0) // data count
                return true;
        }
    }

    return false;
}

/* ************************************************************************** */

bool DeviceAranet4::areValuesValid(const float temperature, const float humidity,
                                   const float pressure, const float co2) const
{
    if (temperature < -40.f || temperature > 70.f) return false;
    if (humidity < 0.f || humidity > 100.f) return false;
    if (pressure < 500.f || pressure > 1200.f) return false;
    if (co2 < 0.f || co2 > 10000.f) return false;

    return true;
}

bool DeviceAranet4::addDatabaseRecord(const int64_t timestamp,
                                      const float temperature, const float humidity,
                                      const float pressure, const float co2)
{
    bool status = false;

    if (areValuesValid(temperature, humidity, pressure, co2))
    {
        if (m_dbInternal || m_dbExternal)
        {
            // SQL date format YYYY-MM-DD HH:MM:SS
            QDateTime tmcd = QDateTime::fromSecsSinceEpoch(timestamp);

            QSqlQuery addData;
            addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp, temperature, humidity, pressure, co2)"
                            " VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :temp, :humi, :pres, :co2)");
            addData.bindValue(":deviceAddr", getAddress());
            addData.bindValue(":timestamp_rounded", tmcd.toString("yyyy-MM-dd hh:00:00"));
            addData.bindValue(":timestamp", tmcd.toString("yyyy-MM-dd hh:mm:ss"));
            addData.bindValue(":temp", temperature);
            addData.bindValue(":humi", humidity);
            addData.bindValue(":pres", pressure);
            addData.bindValue(":co2", co2);

            status = addData.exec();

            if (status)
            {
                m_lastUpdateDatabase = tmcd;
            }
            else
            {
                qWarning() << "> DeviceAranet4 addData.exec() ERROR"
                           << addData.lastError().type() << ":" << addData.lastError().text();
            }
        }
    }
    else
    {
        qWarning() << "DeviceAranet4 values are INVALID";
    }

    return status;
}

/* ************************************************************************** */
