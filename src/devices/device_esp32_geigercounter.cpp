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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_esp32_geigercounter.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>

/* ************************************************************************** */

DeviceEsp32GeigerCounter::DeviceEsp32GeigerCounter(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceSensors += DeviceUtils::SENSOR_GEIGER;
}

DeviceEsp32GeigerCounter::DeviceEsp32GeigerCounter(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceSensors += DeviceUtils::SENSOR_GEIGER;
}

DeviceEsp32GeigerCounter::~DeviceEsp32GeigerCounter()
{
    delete serviceInfos;
    delete serviceBattery;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEsp32GeigerCounter::serviceScanDone()
{
    //qDebug() << "DeviceEsp32GeigerCounter::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceEsp32GeigerCounter::serviceDetailsDiscovered_infos);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceEsp32GeigerCounter::serviceDetailsDiscovered_battery);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceEsp32GeigerCounter::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceEsp32GeigerCounter::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32GeigerCounter::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceEsp32GeigerCounter::addLowEnergyService(" << uuid.toString() << ")";

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

void DeviceEsp32GeigerCounter::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32GeigerCounter::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

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

void DeviceEsp32GeigerCounter::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32GeigerCounter::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceBattery)
        {
            // Characteristic "Battery Level"
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

void DeviceEsp32GeigerCounter::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32GeigerCounter::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
/*
            QBluetoothUuid d(QStringLiteral("eeee9a32-a0c1-4cbd-b00b-6b519bf2780f")); // recap data
            QLowEnergyCharacteristic chd = serviceData->characteristic(d);

            m_rh = chd.value().toFloat();
            m_rm = chd.value().toFloat();
            m_rs = chd.value().toFloat();
            Q_EMIT dataUpdated();
*/
            QBluetoothUuid rt(QStringLiteral("eeee9a32-a0d0-4cbd-b00b-6b519bf2780f")); // rt data
            QLowEnergyCharacteristic chrt = serviceData->characteristic(rt);
            m_notificationDesc = chrt.clientCharacteristicConfiguration();
            serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32GeigerCounter::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceEsp32GeigerCounter::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{x}")
    {
        Q_UNUSED(data)
    }
}

void DeviceEsp32GeigerCounter::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceEsp32GeigerCounter::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{eeee9a32-a0d0-4cbd-b00b-6b519bf2780f}")
    {
        // Geiger Counter realtime data

        if (value.size() > 0)
        {
            Q_UNUSED(data)
            m_rh = value.toFloat();
            m_rm = value.toFloat();
            m_rs = value.toFloat();

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();
            }
            else
            {
                addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(), m_rm);

                refreshDataFinished(true);
                m_bleController->disconnectFromDevice();
            }
/*
            qDebug() << "* DeviceEsp32GeigerCounter update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- radioactivity min:" << m_rm;
            qDebug() << "- radioactivity sec:" << m_rs;
*/
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceEsp32GeigerCounter::hasData() const
{
    //qDebug() << "DeviceEsp32GeigerCounter::hasData()";

    // If we have immediate data (<12h old)
    if (m_rh > 0 || m_rm > 0 || m_rs > 0)
        return true;

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(*) FROM sensorData WHERE deviceAddr = :deviceAddr;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(Esp32Geiger) ERROR"
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

bool DeviceEsp32GeigerCounter::areValuesValid(const float rad_m) const
{
    if (rad_m < 0.f || rad_m > 10000.f) return false;

    return true;
}

bool DeviceEsp32GeigerCounter::addDatabaseRecord(const int64_t timestamp, const float rad_m)
{
    bool status = false;

    if (areValuesValid(rad_m))
    {
        if (m_dbInternal || m_dbExternal)
        {
            // SQL date format YYYY-MM-DD HH:MM:SS

            QSqlQuery addData;
            addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp, radioactivity)"
                            " VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :radioactivity)");
            addData.bindValue(":deviceAddr", getAddress());
            addData.bindValue(":timestamp_rounded", m_lastUpdate.toString("yyyy-MM-dd hh:00:00"));
            addData.bindValue(":timestamp", m_lastUpdate.toString("yyyy-MM-dd hh:mm:ss"));
            addData.bindValue(":radioactivity", rad_m);

            status = addData.exec();

            if (status)
            {
                m_lastUpdateDatabase = m_lastUpdate;
            }
            else
            {
                qWarning() << "> DeviceEsp32GeigerCounter addData.exec() ERROR"
                           << addData.lastError().type() << ":" << addData.lastError().text();
            }
        }
    }
    else
    {
        qWarning() << "DeviceEsp32GeigerCounter values are INVALID";
    }

    return status;
}

/* ************************************************************************** */
