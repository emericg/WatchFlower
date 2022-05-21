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

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    // MiBeacon? // 12 bytes messages?
    // MiBeacon? // 14 bytes messages?

    if (value.size() == 17) // Qingping data? // 17 bytes messages
    {
#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        QString mac;
        mac += value.mid(7,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(6,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(5,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(4,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(3,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(2,1).toHex().toUpper();

        // Save mac address
        setSetting("mac", mac);
#else
        QString mac;
        Q_UNUSED(mac)
#endif
        int batt = -99;
        float temp = -99.f;
        float humi = -99.f;

        // get data
        if ((data[0] == 0x88 && data[1] == 0x16) || // CGG1
            (data[0] == 0x08 && data[1] == 0x07) || // CGG1
            (data[0] == 0x88 && data[1] == 0x10) || // CGDK2
            (data[0] == 0x08 && data[1] == 0x10) || // CGDK2
            (data[0] == 0x08 && data[1] == 0x09) || // CGD1
            (data[0] == 0x08 && data[1] == 0x0c))   // CGP1W
        {
            temp = static_cast<int32_t>(data[10] + (data[11] << 8)) / 10.f;
            if (temp != m_temperature)
            {
                if (temp > -30.f && temp < 100.f)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
            }

            humi = static_cast<int32_t>(data[12] + (data[13] << 8)) / 10.f;
            if (humi != m_humidity)
            {
                if (humi >= 0.f && humi <= 100.f)
                {
                    m_humidity = humi;
                    Q_EMIT dataUpdated();
                }
            }

            batt = static_cast<int8_t>(data[16]);
            setBattery(batt);
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
                        qWarning() << "> DeviceHygrotempCGD1 addData.exec() ERROR"
                                   << addData.lastError().type() << ":" << addData.lastError().text();
                    }
                }
            }

            refreshDataFinished(true);
        }
/*
        if (batt > -99 || temp > -99 || humi > -99)
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
