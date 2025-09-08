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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_jqjcy01ym.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceJQJCY01YM::DeviceJQJCY01YM(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_HCHO;
}

DeviceJQJCY01YM::DeviceJQJCY01YM(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_HCHO;
}

DeviceJQJCY01YM::~DeviceJQJCY01YM()
{
    //
}

/* ************************************************************************** */

void DeviceJQJCY01YM::serviceScanDone()
{
    //qDebug() << "DeviceJQJCY01YM::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceJQJCY01YM::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceJQJCY01YM::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED (uuid)
}

/* ************************************************************************** */

void DeviceJQJCY01YM::parseAdvertisementData(const uint16_t adv_mode,
                                             const uint16_t adv_id,
                                             const QByteArray &ba)
{
/*
    qDebug() << "DeviceJQJCY01YM::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    // MiBeacon protocol / 16b UUID 0xFE95 / 12-20 bytes messages
    // JQJCY01YM uses 15, 16 and 18 bytes messages
    if (parseBeaconXiaomi(adv_mode, adv_id, ba))
    {
        if (m_temperature > -99.f && m_humidity > -99 && m_hcho > -99.f)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                if (m_dbInternal || m_dbExternal)
                {
                    // SQL date format YYYY-MM-DD HH:MM:SS

                    QSqlQuery addData;
                    addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp, temperature, humidity, hcho)"
                                    " VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :temp, :humi, :hcho)");
                    addData.bindValue(":deviceAddr", getAddress());
                    addData.bindValue(":timestamp_rounded", m_lastUpdate.toString("yyyy-MM-dd hh:00:00"));
                    addData.bindValue(":timestamp", m_lastUpdate.toString("yyyy-MM-dd hh:mm:ss"));
                    addData.bindValue(":temp", m_temperature);
                    addData.bindValue(":humi", m_humidity);
                    addData.bindValue(":hcho", m_hcho);

                    if (addData.exec())
                    {
                        m_lastUpdateDatabase = m_lastUpdate;
                    }
                    else
                    {
                        qWarning() << "> DeviceJQJCY01YM addData.exec() ERROR"
                                   << addData.lastError().type() << ":" << addData.lastError().text();
                    }
                }

                refreshDataFinished(true);
            }
            else
            {
                refreshAdvertisement();
            }
/*
            qDebug() << "* MiBeacon service data:" << getName() << getAddress();
            if (m_temperature > -99) qDebug() << "- temperature:" << m_temperature;
            if (m_humidity > -99) qDebug() << "- humidity:" << m_humidity;
            if (m_hcho > -99) qDebug() << "- formaldehyde:" << m_hcho;
*/
        }
    }
}

/* ************************************************************************** */

bool DeviceJQJCY01YM::hasData() const
{
    //qDebug() << "DeviceJQJCY01YM::hasData()";

    // If we have immediate data (<12h old)
    if (m_temperature > 0.f || m_humidity > 0.f || m_hcho > 0.f)
        return true;

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(*) FROM sensorData WHERE deviceAddr = :deviceAddr;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(DeviceJQJCY01YM) ERROR"
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
