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

#include "device_hygrotemp_cgd1.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempCGD1::DeviceHygrotempCGD1(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    //m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempCGD1::DeviceHygrotempCGD1(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    //m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempCGD1::~DeviceHygrotempCGD1()
{
    //
}

/* ************************************************************************** */

void DeviceHygrotempCGD1::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempCGD1::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceHygrotempCGD1::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempCGD1::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED (uuid)
}

/* ************************************************************************** */

void DeviceHygrotempCGD1::parseAdvertisementData(const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempCGD1::parseAdvertisementData(" << m_deviceAddress << ")" << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    // 28 bytes messages?
    if (value.size() >= 28)
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

        float temp = -99.f;
        float humi = -99.f;

        // get data

        temp = static_cast<int32_t>(data[20] + (data[21] << 8) + (data[22] << 16) + (data[23] << 24)) / 10.f;
        if (temp != m_temperature)
        {
            if (temp > -20.f && temp < 100.f)
            {
                m_temperature = temp;
                Q_EMIT dataUpdated();
            }
        }

        humi = static_cast<int32_t>(data[24] + (data[25] << 8) + (data[26] << 16) + (data[27] << 24)) / 10.f;
        if (humi != m_humidity)
        {
            if (humi >= 0.f && humi <= 100.f)
            {
                m_humidity = humi;
                Q_EMIT dataUpdated();
            }
        }

        if (m_temperature > -99.f && m_humidity > -99.f)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb())
            {
                if (m_dbInternal || m_dbExternal)
                {
                    // SQL date format YYYY-MM-DD HH:MM:SS
                    QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
                    QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                    QSqlQuery addData;
                    addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, temperature, humidity)"
                                    " VALUES (:deviceAddr, :ts, :ts_full, :temp, :humi)");
                    addData.bindValue(":deviceAddr", getAddress());
                    addData.bindValue(":ts", tsStr);
                    addData.bindValue(":ts_full", tsFullStr);
                    addData.bindValue(":temp", m_temperature);
                    addData.bindValue(":humi", m_humidity);

                    if (addData.exec())
                    {
                        m_lastUpdateDatabase = m_lastUpdate;
                    }
                    else
                    {
                        qWarning() << "> DeviceCGD1 addData.exec() ERROR"
                                   << addData.lastError().type() << ":" << addData.lastError().text();
                    }
                }

                refreshDataFinished(true);
            }
        }
/*
        if (temp > -99 || humi > -99)
        {
            qDebug() << "* CGD1 service data:" << getName() << getAddress() << "(" << value.size() << ") bytes";
            if (!mac.isEmpty()) qDebug() << "- MAC:" << mac;
            if (temp > -99) qDebug() << "- temperature:" << temp;
            if (humi > -99) qDebug() << "- humidity:" << humi;
        }
*/
    }
}

/* ************************************************************************** */
