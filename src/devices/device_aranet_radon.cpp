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

#include "device_aranet_radon.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

static uint32_t readUint32LE(const quint8 *d)
{
    return static_cast<uint32_t>(d[0]) |
           (static_cast<uint32_t>(d[1]) << 8) |
           (static_cast<uint32_t>(d[2]) << 16) |
           (static_cast<uint32_t>(d[3]) << 24);
}

/*!
 * \brief Read a radon concentration average.
 * \return Bq/m³, or -1 while the average is still being computed (value >= 0xFF000000).
 */
static int64_t readAverage(const quint8 *d)
{
    uint32_t avg = readUint32LE(d);
    if (avg >= 0xFF000000) return -1;

    return avg;
}

/* ************************************************************************** */

DeviceAranetRadon::DeviceAranetRadon(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    setSensors();
}

DeviceAranetRadon::DeviceAranetRadon(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    setSensors();
}

DeviceAranetRadon::~DeviceAranetRadon()
{
    delete serviceInfos;
    delete serviceData;
}

/* ************************************************************************** */

/*!
 * \brief Is this an "AranetRn+" device? It has a temperature and humidity sensor,
 *        where the "AranetRn1" only reports radon and atmospheric pressure.
 */
bool DeviceAranetRadon::isRadonPlus() const
{
    return m_deviceName.endsWith('+');
}

void DeviceAranetRadon::setSensors()
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;

    if (isRadonPlus())
    {
        m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
        m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceAranetRadon::serviceScanDone()
{
    //qDebug() << "DeviceAranetRadon::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceAranetRadon::serviceDetailsDiscovered_infos);
            connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceAranetRadon::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceAranetRadon::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceAranetRadon::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceAranetRadon::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceAranetRadon::addLowEnergyService(" << uuid.toString() << ")";

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

void DeviceAranetRadon::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (serviceInfos && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranetRadon::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

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

void DeviceAranetRadon::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (serviceData && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranetRadon::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Current Readings"
        // Note: this characteristic is only readable if the device has been paired,
        // or if "Smart Home integration" is enabled
        QBluetoothUuid rd(QStringLiteral("f0cd1504-95da-4f4b-9ac8-aa55d312af0c"));
        QLowEnergyCharacteristic crd = serviceData->characteristic(rd);

        if (crd.value().size() >= 47)
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

void DeviceAranetRadon::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceAranetRadon::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString() == "{00002a26-0000-1000-8000-00805f9b34fb}") // Firmware Revision
    {
        if (value.size() > 0)
        {
            QString fw = value;
            setFirmware(fw);
        }
    }

    if (c.uuid().toString() == "{f0cd1504-95da-4f4b-9ac8-aa55d312af0c}") // Current Readings
    {
        parseCurrentReadings(value);
    }
}

/* ************************************************************************** */

void DeviceAranetRadon::parseCurrentReadings(const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    // This characteristic is shared with the Aranet2 and Radiation models,
    // the first byte tells them apart
    if (value.size() < 47 || data[0] != 3)
    {
        refreshDataFinished(false);
        deviceDisconnect();
        return;
    }

    uint16_t temp = static_cast<uint16_t>(data[7] + (data[8] << 8));
    uint16_t pres = static_cast<uint16_t>(data[9] + (data[10] << 8));
    uint16_t humi = static_cast<uint16_t>(data[11] + (data[12] << 8));

    // Readings taken while the sensor is warming up, or while it is in an error state,
    // are flagged as out of range: bit 14 for temperature, bit 15 for pressure and humidity
    if (pres & 0x8000)
    {
        refreshDataFinished(false);
        deviceDisconnect();
        return;
    }

    m_pressure = pres / 10.f;

    // The AranetRn1 has no temperature nor humidity sensor, and reports zeroes
    if (isRadonPlus())
    {
        m_temperature = (temp & 0x4000) ? -99.f : temp / 20.f;
        m_humidity = (humi & 0x8000) ? -99.f : humi / 10.f;
    }

    // 0x1F00 general error / 0x1F01 no data / 0x1F02 high humidity in the sensor chamber
    uint32_t radon = readUint32LE(data + 13);
    m_radon = (radon >= 0x1F00) ? -1 : radon;
    m_radon_24h = readAverage(data + 22);
    m_radon_7d = readAverage(data + 30);
    m_radon_30d = readAverage(data + 38);

    setBattery(data[6]);

    m_lastUpdate = QDateTime::currentDateTime();

    addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity, m_pressure);

    refreshDataFinished(true);

    deviceDisconnect();
/*
    qDebug() << "* DeviceAranetRadon update:" << getAddress();
    qDebug() << "- m_firmware:" << m_deviceFirmware;
    qDebug() << "- m_battery:" << m_deviceBattery;
    qDebug() << "- m_temperature:" << m_temperature;
    qDebug() << "- m_humidity:" << m_humidity;
    qDebug() << "- m_pressure:" << m_pressure;
    qDebug() << "- radon:" << m_radon << "Bq/m3";
    qDebug() << "- radon 24h:" << m_radon_24h << "/ 7d:" << m_radon_7d << "/ 30d:" << m_radon_30d;
*/
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceAranetRadon::areValuesValid(const float t, const float h, const float p) const
{
    // Atmospheric pressure is the only reading every model has
    if (p < 500.f || p > 1200.f) return false;

    // Temperature and humidity are only checked when the device reported them
    if (t > -99.f && (t < -30.f || t > 100.f)) return false;
    if (h > -99.f && (h < 0.f || h > 100.f)) return false;

    return true;
}

bool DeviceAranetRadon::addDatabaseRecord(const int64_t timestamp,
                                          const float t, const float h, const float p)
{
    bool status = false;

    if (areValuesValid(t, h, p))
    {
        if (m_dbInternal || m_dbExternal)
        {
            // SQL date format YYYY-MM-DD HH:MM:SS

            // We only save one record every x minutes
            int round_seconds = 1200; // 20 mins
            QDateTime tmcd = QDateTime::fromSecsSinceEpoch(timestamp);
            QDateTime tmcd_rounded = QDateTime::fromSecsSinceEpoch(timestamp + (round_seconds - timestamp % round_seconds) - round_seconds);

            QSqlQuery addData;
            addData.prepare("REPLACE INTO thermoData (deviceAddr, timestamp_rounded, timestamp, temperature, humidity, pressure) "
                            "VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :temp, :humi, :pres)");
            addData.bindValue(":deviceAddr", getAddress());
            addData.bindValue(":timestamp_rounded", tmcd_rounded.toString("yyyy-MM-dd hh:mm:00"));
            addData.bindValue(":timestamp", tmcd.toString("yyyy-MM-dd hh:mm:ss"));

            // The AranetRn1 has no temperature nor humidity sensor, store NULLs
            addData.bindValue(":temp", (t > -99.f) ? QVariant(t) : QVariant());
            addData.bindValue(":humi", (h > -99.f) ? QVariant(h) : QVariant());

            addData.bindValue(":pres", p);

            status = addData.exec();

            if (status)
            {
                m_lastUpdateDatabase = tmcd;
            }
            else
            {
                qWarning() << "> DeviceAranetRadon addData.exec() ERROR"
                           << addData.lastError().type() << ":" << addData.lastError().text();
            }
        }
    }
    else
    {
        qWarning() << "DeviceAranetRadon values are INVALID";
    }

    return status;
}

/* ************************************************************************** */
