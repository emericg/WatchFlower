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
 * \date      2023
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_bparasite.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceBParasite::DeviceBParasite(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DevicePlantSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceBParasite::DeviceBParasite(const QBluetoothDeviceInfo &d, QObject *parent):
    DevicePlantSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceBParasite::~DeviceBParasite()
{
    //
}

/* ************************************************************************** */

void DeviceBParasite::parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &ba)
{
/*
    qDebug() << "DeviceBParasite::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (parseBeaconBtHome(adv_mode, adv_id, ba))
    {
        if (m_soilMoisture > -99 && m_temperature > -99.f && m_humidity > -99.f && m_luminosityLux > -99)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                  m_soilMoisture, -99, -99.f, -99.f,
                                  m_temperature, m_humidity, m_luminosityLux);

                refreshDataFinished(true);
            }
            else
            {
                refreshAdvertisement();
            }
        }
/*
        if (batt > -99 || temp > -99.f || humi > -99.f || lumi > -99 || moist > -99)
        {
            qDebug() << "* BtHome service data:" << getName() << getAddress() << "(" << data_size << ") bytes";
            if (batt > -99) qDebug() << "- battery:" << batt;
            if (temp > -99) qDebug() << "- temperature:" << temp;
            if (humi > -99) qDebug() << "- humidity:" << humi;
            if (lumi > -99) qDebug() << "- luminosity:" << lumi;
            if (moist > -99)qDebug() << "- soil moisture:" << moist;
        }
*/
    }
}

/* ************************************************************************** */
