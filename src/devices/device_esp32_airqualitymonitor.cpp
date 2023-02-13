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
 * \date      2021
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_esp32_airqualitymonitor.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>

/* ************************************************************************** */

DeviceEsp32AirQualityMonitor::DeviceEsp32AirQualityMonitor(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
    //m_deviceSensors += DeviceUtils::SENSOR_PM25;
    //m_deviceSensors += DeviceUtils::SENSOR_PM10;
    m_deviceSensors += DeviceUtils::SENSOR_VOC;
    m_deviceSensors += DeviceUtils::SENSOR_eCO2;
}

DeviceEsp32AirQualityMonitor::DeviceEsp32AirQualityMonitor(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
    //m_deviceSensors += DeviceUtils::SENSOR_PM25;
    //m_deviceSensors += DeviceUtils::SENSOR_PM10;
    m_deviceSensors += DeviceUtils::SENSOR_VOC;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
}

DeviceEsp32AirQualityMonitor::~DeviceEsp32AirQualityMonitor()
{
    delete serviceInfos;
    delete serviceBattery;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEsp32AirQualityMonitor::serviceScanDone()
{
    //qDebug() << "DeviceEsp32AirQualityMonitor::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_infos);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_battery);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceEsp32AirQualityMonitor::bleReadDone);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceEsp32AirQualityMonitor::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32AirQualityMonitor::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceEsp32AirQualityMonitor::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // Device Information service
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        serviceInfos = m_bleController->createServiceObject(uuid);
        if (!serviceInfos)
            qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
    }

    //if (uuid.toString() == "{0000180f-0000-1000-8000-00805f9b34fb}") // Battery service

    if (uuid.toString() == "{eeee9a32-a000-4cbd-b00b-6b519bf2780f}") // (custom) data service
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            QBluetoothUuid f(QStringLiteral("00002a24-a002-4cbd-b00b-6b519bf2780f")); // firmware version
            QLowEnergyCharacteristic chf = serviceInfos->characteristic(f);

            if (chf.value().size() > 0)
            {
                QString fw = chf.value();
                setFirmware(fw);
            }
        }
    }
}

void DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceBattery)
        {
            // Characteristic "Battery level"
            QBluetoothUuid uuid_batterylevel(QStringLiteral("00002a19-0000-1000-8000-00805f9b34fb"));
            QLowEnergyCharacteristic cbat = serviceBattery->characteristic(uuid_batterylevel);

            if (cbat.value().size() == 1)
            {
                int lvl = static_cast<uint8_t>(cbat.value().constData()[0]);
                setBattery(lvl);
            }
        }
    }
}

void DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32AirQualityMonitor::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            QBluetoothUuid rt(QStringLiteral("eeee9a32-a0a0-4cbd-b00b-6b519bf2780f")); // rt data
            QLowEnergyCharacteristic chrt = serviceData->characteristic(rt);
            m_notificationDesc = chrt.clientCharacteristicConfiguration();
            serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32AirQualityMonitor::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceEsp32AirQualityMonitor::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{eeee9a32-a0a0-4cbd-b00b-6b519bf2780f}")
    {
        // Air Quality Monitor realtime data

        if (value.size() == 16)
        {
            m_temperature = static_cast<uint16_t>(data[0] + (data[1] << 8)) / 10.f;
            m_humidity = data[2];
            m_pressure = static_cast<uint16_t>(data[3] + (data[4] << 8));
            m_voc = static_cast<uint16_t>(data[5] + (data[6] << 8));
            m_co2 = static_cast<uint16_t>(data[7] + (data[8] << 8));

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();
            }
            else
            {
                addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                  m_temperature, m_humidity, m_pressure, m_voc, m_co2);

                refreshDataFinished(true);
                m_bleController->disconnectFromDevice();
            }
/*
            qDebug() << "* DeviceEsp32AirQualityMonitor update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
            qDebug() << "- m_pressure:" << m_pressure;
            qDebug() << "- m_voc:" << m_voc;
            qDebug() << "- m_co2:" << m_co2;
*/
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceEsp32AirQualityMonitor::hasData() const
{
    //qDebug() << "DeviceEsp32AirQualityMonitor::hasData()";

    // If we have immediate data (<12h old)
    if (m_temperature > 0.f || m_humidity > 0.f || m_pressure > 0.f || m_voc > 0.f || m_co2 > 0.f)
        return true;

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(*) FROM sensorData WHERE deviceAddr = :deviceAddr;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(AQI) ERROR"
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

bool DeviceEsp32AirQualityMonitor::areValuesValid(const float temperature, const float humidity,
                                                  const float pressure, const float voc, const float co2) const
{
    if (temperature < -20.f || temperature > 100.f) return false;
    if (humidity < 0.f || humidity > 100.f) return false;
    if (pressure < 900.f || humidity > 1100.f) return false;

    if (voc < 0.f || voc > 10000.f) return false;
    if (co2 < 0.f || co2 > 10000.f) return false;

    return true;
}

bool DeviceEsp32AirQualityMonitor::addDatabaseRecord(const int64_t timestamp,
                                                     const float temperature, const float humidity,
                                                     const float pressure, const float voc, const float co2)
{
    bool status = false;

    if (areValuesValid(temperature, humidity, pressure, voc, co2))
    {
        if (m_dbInternal || m_dbExternal)
        {
            // SQL date format YYYY-MM-DD HH:MM:SS

            QSqlQuery addData;
            addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp, temperature, humidity, pressure, voc, co2)"
                            " VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :temp, :humi, :pres, :voc, :co2)");
            addData.bindValue(":deviceAddr", getAddress());
            addData.bindValue(":timestamp_rounded", m_lastUpdate.toString("yyyy-MM-dd hh:00:00"));
            addData.bindValue(":timestamp", m_lastUpdate.toString("yyyy-MM-dd hh:mm:ss"));
            addData.bindValue(":temp", m_temperature);
            addData.bindValue(":humi", m_humidity);
            addData.bindValue(":pres", m_pressure);
            addData.bindValue(":voc", m_voc);
            addData.bindValue(":co2", m_co2);

            status = addData.exec();

            if (status)
            {
                m_lastUpdateDatabase = m_lastUpdate;
            }
            else
            {
                qWarning() << "> DeviceEsp32AirQualityMonitor addData.exec() ERROR"
                           << addData.lastError().type() << ":" << addData.lastError().text();
            }
        }
    }
    else
    {
        qWarning() << "DeviceEsp32AirQualityMonitor values are INVALID";
    }

    return status;
}

/* ************************************************************************** */
