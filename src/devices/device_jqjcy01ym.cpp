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
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceJQJCY01YM::DeviceJQJCY01YM(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_HCHO;
}

DeviceJQJCY01YM::DeviceJQJCY01YM(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
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

void DeviceJQJCY01YM::parseAdvertisementData(const QByteArray &value)
{
    //qDebug() << "DeviceJQJCY01YM::parseAdvertisementData(" << m_deviceAddress << ")" << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    // 12-18 bytes messages
    if (value.size() >= 12)
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

        QString mac;

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        // Save mac address
        mac += value.mid(10,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(9,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(8,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(7,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(6,1).toHex().toUpper();
        mac += ':';
        mac += value.mid(5,1).toHex().toUpper();

        setSetting("mac", mac);
#else
        Q_UNUSED(mac)
#endif

        if (value.size() >= 15)
        {
            int batt = -99;
            float temp = -99;
            float humi = -99;
            int lumi = -99;
            float form = -99;
            int moist = -99;
            int fert = -99;

            // "5020df02383a5c014357480a10015e"
            // "5020df02283a5c014357480610025302"
            // "5020df025b3a5c014357481010020800"
            // "5120df023e3a5c01435748041002c400"

            // batt\":94
            // hum\":59.5
            // for\":0.08
            // tempc\":19.6,\"tempf\":67.28}

            // get data
            if (data[11] == 4 && value.size() >= 16)
            {
                temp = static_cast<int16_t>(data[14] + (data[15] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    if (temp > -20.f && temp < 100.f)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[11] == 6 && value.size() >= 16)
            {
                humi = static_cast<int16_t>(data[14] + (data[15] << 8)) / 10.f;
                if (humi != m_humidity)
                {
                    if (humi >= 0.f && humi <= 100.f)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else if (data[11] == 10 && value.size() >= 15)
            {
                batt = static_cast<int8_t>(data[14]);
                setBattery(batt);
            }
            else if (data[11] == 11 && value.size() >= 18)
            {
                temp = static_cast<int16_t>(data[14] + (data[15] << 8)) / 10.f;
                if (temp != m_temperature)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
                humi = static_cast<int16_t>(data[16] + (data[17] << 8)) / 10.f;
                if (humi != m_humidity)
                {
                    m_humidity = humi;
                    Q_EMIT dataUpdated();
                }
            }
            else if (data[11] == 16 && value.size() >= 16)
            {
                form = static_cast<int16_t>(data[14] + (data[15] << 8)) / 10.f;
                if (form != m_hcho)
                {
                    if (form >= 0.f && form <= 100.f)
                    {
                        m_hcho = form*100; // mg to µg
                        Q_EMIT dataUpdated();
                    }
                }
            }
            else
            {
                qDebug() << "MiBeacon: unknown tag >" << data[11];
            }

            if (m_temperature > -99 && m_humidity > -99 && m_hcho > -99)
            {
                m_lastUpdate = QDateTime::currentDateTime();
                refreshDataFinished(true);

                if (needsUpdateDb())
                {
                    // TODO // UPDATE DB
                }
            }

            if (temp > -99 || humi > -99 || lumi > -99 || form > -99 || moist > -99 || fert > -99)
            {
                qDebug() << "* MiBeacon service data:" << getName() << getAddress() << "(" << value.size() << ") bytes";
                if (!mac.isEmpty()) qDebug() << "- MAC:" << mac;
                if (batt > -99) qDebug() << "- battery:" << batt;
                if (temp > -99) qDebug() << "- temperature:" << temp;
                if (humi > -99) qDebug() << "- humidity:" << humi;
                if (lumi > -99) qDebug() << "- luminosity:" << lumi;
                if (form > -99) qDebug() << "- formaldehyde:" << form;
                if (moist > -99) qDebug() << "- soil moisture:" << moist;
                if (fert > -99) qDebug() << "- soil fertility:" << fert;
            }

        }
    }
}

/* ************************************************************************** */
