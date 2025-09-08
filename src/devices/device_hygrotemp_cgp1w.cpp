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

#include "device_hygrotemp_cgp1w.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempCGP1W::DeviceHygrotempCGP1W(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
}

DeviceHygrotempCGP1W::DeviceHygrotempCGP1W(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
}

DeviceHygrotempCGP1W::~DeviceHygrotempCGP1W()
{
    //
}

/* ************************************************************************** */

void DeviceHygrotempCGP1W::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempCGP1W::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceHygrotempCGP1W::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempCGP1W::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED (uuid)
}

/* ************************************************************************** */

void DeviceHygrotempCGP1W::parseAdvertisementData(const uint16_t adv_mode,
                                                  const uint16_t adv_id,
                                                  const QByteArray &ba)
{
/*
    qDebug() << "DeviceHygrotempCGP1W::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (parseBeaconQingping(adv_mode, adv_id, ba))
    {
        if (m_temperature > -99.f && m_humidity > -99.f && m_pressure > -99.f)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                addDatabaseRecord_weatherstation(m_lastUpdate.toSecsSinceEpoch(),
                                                 m_temperature, m_humidity, m_pressure);

                refreshDataFinished(true);
            }
            else
            {
                refreshAdvertisement();
            }
/*
            qDebug() << "* Qingping service data:" << getName() << getAddress();
            if (m_deviceBattery > -99) qDebug() << "- battery:" << m_deviceBattery;
            if (m_temperature > -99) qDebug() << "- temperature:" << m_temperature;
            if (m_humidity > -99) qDebug() << "- humidity:" << m_humidity;
            if (m_pressure > -99) qDebug() << "- pressure:" << m_pressure;
*/
        }
    }
}

/* ************************************************************************** */
