/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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
 * \date      2021
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_ess_generic.h"
#include "utils/utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>

/* ************************************************************************** */

DeviceEssGeneric::DeviceEssGeneric(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
}

DeviceEssGeneric::DeviceEssGeneric(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
}

DeviceEssGeneric::~DeviceEssGeneric()
{
    if (controller) controller->disconnectFromDevice();
    delete serviceInfos;
    delete serviceBattery;
    delete serviceEnvironmentalSensing;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEssGeneric::serviceScanDone()
{
    //qDebug() << "DeviceEssGeneric::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceEssGeneric::serviceDetailsDiscovered_battery);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(); });
        }
    }

    if (serviceEnvironmentalSensing)
    {
        if (serviceEnvironmentalSensing->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceEnvironmentalSensing, &QLowEnergyService::stateChanged, this, &DeviceEssGeneric::serviceDetailsDiscovered_ess);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceEnvironmentalSensing->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceEssGeneric::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceEssGeneric::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180f-0000-1000-8000-00805f9b34fb}") // Battery service
    {
        delete serviceBattery;
        serviceBattery = nullptr;

        serviceBattery = controller->createServiceObject(uuid);
        if (!serviceBattery)
            qWarning() << "Cannot create service (battery) for uuid:" << uuid.toString();
    }

    if (uuid.toString() == "{0000181A-0000-1000-8000-00805f9b34fb}") // Environmental sensing service
    {
        delete serviceEnvironmentalSensing;
        serviceEnvironmentalSensing = nullptr;

        serviceEnvironmentalSensing = controller->createServiceObject(uuid);
        if (!serviceEnvironmentalSensing)
            qWarning() << "Cannot create service (environmental sensing) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceEssGeneric::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEssGeneric::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Battery Level"
        QBluetoothUuid uuid_batterylevel(QString("00002a19-0000-1000-8000-00805f9b34fb"));
        QLowEnergyCharacteristic cbat = serviceBattery->characteristic(uuid_batterylevel);

        if (cbat.value().size() > 0)
        {
            m_battery = static_cast<uint8_t>(cbat.value().constData()[0]);

            if (m_dbInternal || m_dbExternal)
            {
                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":battery", m_battery);
                updateDevice.bindValue(":deviceAddr", getAddress());
                if (updateDevice.exec() == false)
                    qWarning() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":" << updateDevice.lastError().text();
            }

            Q_EMIT sensorUpdated();
        }
    }
}

void DeviceEssGeneric::serviceDetailsDiscovered_ess(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEssGeneric::serviceDetailsDiscovered_ess(" << m_deviceAddress << ") > ServiceDiscovered";

        QBluetoothUuid uuid_elevation(QString("00002a6c-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_pressure(QString("00002a6d-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_temperature(QString("00002a6e-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_humidity(QString("00002a6f-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_truewindwpeed(QString("00002a70-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_truewinddirection(QString("00002a71-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_apparentwindwpeed(QString("00002a72-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_apparentwinddirection(QString("00002a73-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_gustfactor(QString("00002a74-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_pollen(QString("00002a75-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_uvindex(QString("00002a76-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_irradiance(QString("00002a77-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_rainfall(QString("00002a78-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_windchill(QString("00002a79-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_heatindex(QString("00002a7a-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_dewpoint(QString("00002a7b-0000-1000-8000-00805f9b34fb"));
        QBluetoothUuid uuid_barometricpressuretrend(QString("00002aa3-0000-1000-8000-00805f9b34fb"));

        // Characteristic "pressure"
        QLowEnergyCharacteristic cpres = serviceEnvironmentalSensing->characteristic(uuid_pressure);
        if (cpres.isValid())
        {
            m_pressure = cpres.value().toUInt() / 10.0;

            m_deviceSensors += DeviceUtils::SENSOR_PRESSURE;
            Q_EMIT sensorUpdated();
        }

        // Characteristic "temperature"
        QLowEnergyCharacteristic ctemp = serviceEnvironmentalSensing->characteristic(uuid_temperature);
        if (ctemp.isValid())
        {
            m_temperature = ctemp.value().toInt() / 100.0;

            m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
            Q_EMIT sensorUpdated();
        }

        // Characteristic "humidity"
        QLowEnergyCharacteristic chum = serviceEnvironmentalSensing->characteristic(uuid_humidity);
        if (chum.isValid())
        {
            m_humidity = chum.value().toInt() / 100.0;

            m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
            Q_EMIT sensorUpdated();
        }

        // Characteristic "UV index"
        QLowEnergyCharacteristic cuv = serviceEnvironmentalSensing->characteristic(uuid_uvindex);
        if (cuv.isValid())
        {
            m_uv = cuv.value().toUInt();

            m_deviceSensors += DeviceUtils::SENSOR_UV;
            Q_EMIT sensorUpdated();
        }

        // TODO
    }
}

/* ************************************************************************** */
