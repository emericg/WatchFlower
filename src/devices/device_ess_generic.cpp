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
    m_deviceType = DEVICE_ENVIRONMENTAL;
    m_deviceCapabilities += DEVICE_BATTERY;
}

DeviceEssGeneric::DeviceEssGeneric(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DEVICE_ENVIRONMENTAL;
    m_deviceCapabilities += DEVICE_BATTERY;
}

DeviceEssGeneric::~DeviceEssGeneric()
{
    if (controller) controller->disconnectFromDevice();
    delete serviceEnvironmentalSensing;
    delete serviceBattery;
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
        QBluetoothUuid bat(QString("00002a19-0000-1000-8000-00805f9b34fb"));
        QLowEnergyCharacteristic cbat = serviceBattery->characteristic(bat);

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

        // TODO
    }
}

/* ************************************************************************** */
