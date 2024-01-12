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

#include "device_flowercare_tuya.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceFlowerCare_tuya::DeviceFlowerCare_tuya(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DevicePlantSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerCare_tuya::DeviceFlowerCare_tuya(const QBluetoothDeviceInfo &d, QObject *parent):
    DevicePlantSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerCare_tuya::~DeviceFlowerCare_tuya()
{
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceFlowerCare_tuya::serviceScanDone()
{
    //qDebug() << "DeviceFlowerCare_tuya::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare_tuya::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare_tuya::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceFlowerCare_tuya::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000fd50-0000-1000-8000-00805f9b34fb}")
    {
        delete serviceData;
        serviceData = nullptr;

        QBluetoothUuid a(QStringLiteral("00000001-0000-1001-8001-00805f9b07d0")); // W // W no resp
        QBluetoothUuid b(QStringLiteral("00000002-0000-1001-8001-00805f9b07d0")); // NOTIFY

        {
            serviceData = m_bleController->createServiceObject(uuid);
            if (!serviceData)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare_tuya::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::parseAdvertisementData(const uint16_t adv_mode,
                                                   const uint16_t adv_id,
                                                   const QByteArray &ba)
{
/*
    qDebug() << "DeviceFlowerCare::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    // service data / 16b UUID 0xFD50 / 9 bytes messages
    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA && adv_id == 0xFD50 && ba.size() == 9)
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());

        int batt = -99;
        float temp = -99.f;
        int lumi = -99;
        int moist = -99;
        int fert = -99;

        batt = static_cast<int>(data[6]);
        setBattery(batt);

        moist = static_cast<int>(data[0]);
        temp = static_cast<int16_t>(data[2] + (data[1] << 8)) / 10.f;
        lumi = static_cast<int16_t>(data[3] + (data[4] << 8) + (data[5] << 16));
        fert = static_cast<int16_t>(data[8] + (data[7] << 8));

        if (areValuesValid(moist, fert, -99.f, -99.f, temp, -99.f, lumi))
        {
            m_lastUpdate = QDateTime::currentDateTime();

            m_soilMoisture = moist;
            m_soilConductivity = fert;
            m_temperature = temp;
            m_luminosityLux = lumi;

            if (needsUpdateDb_mini())
            {
                addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                  moist, fert, -99.f, -99.f,
                                  temp, -99.f, lumi);

                refreshDataFinished(true);
            }
            else
            {
                refreshAdvertisement();
            }
/*
            qDebug() << "* Tuya service data:" << getName() << getAddress() << "(" << value.size() << ") bytes";
            if (m_deviceBattery > -99) qDebug() << "- battery:" << m_deviceBattery;
            if (m_soilMoisture > -99) qDebug() << "- soil moisture:" << m_soilMoisture;
            if (m_soilConductivity > -99) qDebug() << "- soil conductivity:" << m_soilConductivity;
            if (m_temperature > -99) qDebug() << "- temperature:" << m_temperature;
            if (m_luminosityLux > -99) qDebug() << "- luminosity:" << m_luminosityLux;
*/
        }
    }
}

/* ************************************************************************** */
