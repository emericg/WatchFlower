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

#include "device_aranet_radiation.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceAranetRadiation::DeviceAranetRadiation(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_GEIGER;
}

DeviceAranetRadiation::DeviceAranetRadiation(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_GEIGER;
}

DeviceAranetRadiation::~DeviceAranetRadiation()
{
    delete serviceInfos;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceAranetRadiation::serviceScanDone()
{
    //qDebug() << "DeviceAranetRadiation::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceAranetRadiation::serviceDetailsDiscovered_infos);
            connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceAranetRadiation::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceAranetRadiation::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceAranetRadiation::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceAranetRadiation::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceAranetRadiation::addLowEnergyService(" << uuid.toString() << ")";

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

void DeviceAranetRadiation::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (serviceInfos && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranetRadiation::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

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

void DeviceAranetRadiation::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (serviceData && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranetRadiation::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Current Readings"
        // Note: this characteristic is only readable if the device has been paired,
        // or if "Smart Home integration" is enabled
        QBluetoothUuid rd(QStringLiteral("f0cd1504-95da-4f4b-9ac8-aa55d312af0c"));
        QLowEnergyCharacteristic crd = serviceData->characteristic(rd);

        if (crd.value().size() >= 28)
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

void DeviceAranetRadiation::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceAranetRadiation::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
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

void DeviceAranetRadiation::parseCurrentReadings(const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    // This characteristic is shared with the Aranet2 and Radon models,
    // the first byte tells them apart
    if (value.size() < 28 || data[0] != 4)
    {
        refreshDataFinished(false);
        deviceDisconnect();
        return;
    }

    uint16_t interval = static_cast<uint16_t>(DeviceUtils::readLE(data, 2, 2));
    int64_t ago = static_cast<uint16_t>(DeviceUtils::readLE(data, 4, 2));

    uint32_t rate = DeviceUtils::readLE(data, 7, 4);

    m_radiationTotal = 0;
    m_radiationDuration = 0;
    for (int i = 0; i < 8; i++)
    {
        m_radiationTotal |= static_cast<uint64_t>(data[11 + i]) << (i * 8);
        m_radiationDuration |= static_cast<uint64_t>(data[19 + i]) << (i * 8);
    }

    // The device reports nSv/h, WatchFlower stores and displays µSv/h.
    // The per hour, minute and second values are all set to the dose rate, as the
    // ESP32 geiger counter does, so that the UI thresholds stay consistent.
    m_rh = rate / 1000.f;
    m_rm = m_rh;
    m_rs = m_rh;
    m_radioactivity = m_rh;

    setBattery(data[6]);

    if (ago > interval) ago = 0; // out of sync, use current time instead

    m_lastUpdate = QDateTime::currentDateTime().addSecs(-ago);

    addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(), m_rh);

    refreshDataFinished(true);

    deviceDisconnect();
/*
    qDebug() << "* DeviceAranetRadiation update:" << getAddress();
    qDebug() << "- m_firmware:" << m_deviceFirmware;
    qDebug() << "- m_battery:" << m_deviceBattery;
    qDebug() << "- dose rate:" << m_rh << "µSv/h";
    qDebug() << "- dose total:" << m_radiationTotal << "nSv";
    qDebug() << "- dose duration:" << m_radiationDuration << "s";
*/
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceAranetRadiation::hasData() const
{
    //qDebug() << "DeviceAranetRadiation::hasData()";

    // If we have immediate data (<12h old)
    if (m_rh > 0.f || m_rm > 0.f)
        return true;

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(*) FROM sensorData WHERE deviceAddr = :deviceAddr;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(DeviceAranetRadiation) ERROR"
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

bool DeviceAranetRadiation::areValuesValid(const float radiation) const
{
    if (radiation < 0.f || radiation > 10000.f) return false;

    return true;
}

bool DeviceAranetRadiation::addDatabaseRecord(const int64_t timestamp, const float radiation)
{
    bool status = false;

    if (areValuesValid(radiation))
    {
        if (m_dbInternal || m_dbExternal)
        {
            // SQL date format YYYY-MM-DD HH:MM:SS
            QDateTime tmcd = QDateTime::fromSecsSinceEpoch(timestamp);

            QSqlQuery addData;
            addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp, radioactivity)"
                            " VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :radioactivity)");
            addData.bindValue(":deviceAddr", getAddress());
            addData.bindValue(":timestamp_rounded", tmcd.toString("yyyy-MM-dd hh:00:00"));
            addData.bindValue(":timestamp", tmcd.toString("yyyy-MM-dd hh:mm:ss"));
            addData.bindValue(":radioactivity", radiation);

            status = addData.exec();

            if (status)
            {
                m_lastUpdateDatabase = tmcd;
            }
            else
            {
                qWarning() << "> DeviceAranetRadiation addData.exec() ERROR"
                           << addData.lastError().type() << ":" << addData.lastError().text();
            }
        }
    }
    else
    {
        qWarning() << "DeviceAranetRadiation values are INVALID";
    }

    return status;
}

/* ************************************************************************** */
