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

#include "device_cgdn1.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceCGDN1::DeviceCGDN1(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceEnvironmental(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
    m_deviceSensors += DeviceUtils::SENSOR_PM25;
    m_deviceSensors += DeviceUtils::SENSOR_PM10;
}

DeviceCGDN1::DeviceCGDN1(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceEnvironmental(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_CO2;
    m_deviceSensors += DeviceUtils::SENSOR_PM25;
    m_deviceSensors += DeviceUtils::SENSOR_PM10;
}

DeviceCGDN1::~DeviceCGDN1()
{
    //
}

/* ************************************************************************** */

void DeviceCGDN1::serviceScanDone()
{
    //qDebug() << "DeviceCGDN1::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceCGDN1::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceCGDN1::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED (uuid)
}

/* ************************************************************************** */

void DeviceCGDN1::parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &ba)
{
/*
    qDebug() << "DeviceCGDN1::parseAdvertisementData(" << m_deviceAddress
             << " - " << adv_mode << " - 0x" << adv_id << ")";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (ba.size() >= 24) // Qingping data protocol // 24 bytes messages
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());

        // Save mac address (for macOS and iOS)
        if (!hasAddressMAC())
        {
            QString mac;

            mac += ba.mid(10,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(9,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(8,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(7,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(6,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(5,1).toHex().toUpper();

            setAddressMAC(mac);
        }

        float temp = -99.f;
        float humi = -99.f;
        float co2 = -99.f;
        float pm2 = -99.f;
        float pm10 = -99.f;

        // get data
        if ((data[0] == 0x04 || data[0] == 0x08 || data[0] == 0x80 || data[0] == 0x88) &&
            ((data[1] == 0x01 || data[1] == 0x07 || data[1] == 0x16) || // CGG1
             (data[1] == 0x10) || // CGDK2
             (data[1] == 0x09) || // CGP1W
             (data[1] == 0x15) || // CGF1W
             (data[1] == 0x1e) || // CGC1
             (data[1] == 0x0c) || // CGD1
             (data[1] == 0x0e || data[1] == 0x24) ||  // CGDN1
             (data[1] == 0x0f))) // CGM1
        {
            temp = static_cast<int16_t>(data[10] + (data[11] << 8)) / 10.f;
            if (temp != m_temperature)
            {
                if (temp > -30.f && temp < 100.f)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
            }
            humi = static_cast<int16_t>(data[12] + (data[13] << 8)) / 10.f;
            if (humi != m_humidity)
            {
                if (humi >= 0.f && humi <= 100.f)
                {
                    m_humidity = humi;
                    Q_EMIT dataUpdated();
                }
            }

            pm2 = static_cast<int16_t>(data[16] + (data[17] << 8));
            if (pm2 != m_pm_25)
            {
                if (pm2 >= 0 && pm2 <= 1000)
                {
                    m_pm_25 = pm2;
                    Q_EMIT dataUpdated();
                }
            }
            pm10 = static_cast<int16_t>(data[18] + (data[19] << 8));
            if (pm10 != m_pm_10)
            {
                if (pm10 >= 0 && pm10 <= 1000)
                {
                    m_pm_10 = pm10;
                    Q_EMIT dataUpdated();
                }
            }

            co2 = static_cast<int16_t>(data[22] + (data[23] << 8));
            if (co2 != m_co2)
            {
                if (co2 >= 0 && co2 <= 9999)
                {
                    m_co2 = co2;
                    Q_EMIT dataUpdated();
                }
            }
        }
        else
        {
            qDebug() << "Qingping data: unknown device ID >" << data[0] << data[1];
        }

        if (m_temperature > -99.f && m_humidity > -99.f && m_co2 > -99.f && m_pm_25 > -99.f && m_pm_10 > -99.f)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                if (m_dbInternal || m_dbExternal)
                {
                    // SQL date format YYYY-MM-DD HH:MM:SS

                    QSqlQuery addData;
                    addData.prepare("REPLACE INTO sensorData (deviceAddr, timestamp_rounded, timestamp, temperature, humidity, co2, pm25, pm10)"
                                    " VALUES (:deviceAddr, :timestamp_rounded, :timestamp, :temp, :humi, :co2, :pm25, :pm10)");
                    addData.bindValue(":deviceAddr", getAddress());
                    addData.bindValue(":timestamp_rounded", m_lastUpdate.toString("yyyy-MM-dd hh:00:00"));
                    addData.bindValue(":timestamp", m_lastUpdate.toString("yyyy-MM-dd hh:mm:ss"));
                    addData.bindValue(":temp", m_temperature);
                    addData.bindValue(":humi", m_humidity);
                    addData.bindValue(":co2", m_co2);
                    addData.bindValue(":pm25", m_pm_25);
                    addData.bindValue(":pm10", m_pm_10);

                    if (addData.exec())
                    {
                        m_lastUpdateDatabase = m_lastUpdate;
                    }
                    else
                    {
                        qWarning() << "> DeviceCGDN1 addData.exec() ERROR"
                                   << addData.lastError().type() << ":" << addData.lastError().text();
                    }
                }

                refreshDataFinished(true);
            }
        }
/*
            if (batt > -99 || temp > -99.f || humi > -99.f || co2 > -99.f || pm2 > -99.f || pm10 > -99.f)
            {
                qDebug() << "* MiBeacon service data:" << getName() << getAddress() << "(" << data_size << ") bytes";
                if (batt > -99) qDebug() << "- battery:" << batt;
                if (temp > -99) qDebug() << "- temperature:" << temp;
                if (humi > -99) qDebug() << "- humidity:" << humi;
                if (co2 > -99) qDebug() << "- co2:" << co2;
                if (pm2 > -99) qDebug() << "- pm 2.5:" << pm2;
                if (pm10 > -99) qDebug() << "- pm 10 :" << pm10;
            }
*/
        }
}

/* ************************************************************************** */

bool DeviceCGDN1::hasData() const
{
    //qDebug() << "DeviceCGDN1::hasData()";

    // If we have immediate data (<12h old)
    if (m_temperature > 0 || m_humidity > 0 || m_co2 > 0 || m_pm_25 > 0 || m_pm_10 > 0)
        return true;

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(*) FROM sensorData WHERE deviceAddr = :deviceAddr;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(DeviceCGDN1) ERROR"
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
