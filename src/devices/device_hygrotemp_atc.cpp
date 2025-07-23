/*!
 * This file is part of SmartCare.
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

#include "device_hygrotemp_atc.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempATC::DeviceHygrotempATC(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempATC::DeviceHygrotempATC(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities = DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempATC::~DeviceHygrotempATC()
{
    //
}

/* ************************************************************************** */

void DeviceHygrotempATC::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempATC::serviceScanDone(" << m_deviceAddress << ")";
}

void DeviceHygrotempATC::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempATC::addLowEnergyService(" << uuid.toString() << ")";
    Q_UNUSED (uuid)
}

/* ************************************************************************** */

void DeviceHygrotempATC::parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &ba)
{
/*
    qDebug() << "DeviceHygrotempATC::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (parseBeaconXiaomi(adv_mode, adv_id, ba) == true ||
        parseBeaconBtHome(adv_mode, adv_id, ba) == true)
    {
        if (m_temperature > -99.f && m_humidity > -99.f)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);

                refreshDataFinished(true);
            }
            else
            {
                refreshRealtimeFinished();
            }
/*
            qDebug() << "* ATC service data:" << getName() << getAddress();
            if (m_deviceBattery > -99) qDebug() << "- battery:" << m_deviceBattery;
            if (m_temperature > -99) qDebug() << "- temperature:" << m_temperature;
            if (m_humidity > -99) qDebug() << "- humidity:" << m_humidity;
*/
        }
    }
}

/* ************************************************************************** */
