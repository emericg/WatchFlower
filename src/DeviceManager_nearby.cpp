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

#include "DeviceManager.h"

#include <QBluetoothDeviceInfo>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QDebug>

/* ************************************************************************** */

void DeviceManager::scanNearby_start()
{
    //qDebug() << "DeviceManager::scanNearby_start()";

    // init nearby device list
    if (!m_devices_nearby_model)
    {
        m_devices_nearby_model = new DeviceModel(this);
        m_devices_nearby_filter = new DeviceFilter(this);
        m_devices_nearby_filter->setSourceModel(m_devices_nearby_model);

        m_devices_nearby_filter->setSortRole(DeviceModel::DeviceRssiRole);
        m_devices_nearby_filter->sort(0, Qt::AscendingOrder);
        m_devices_nearby_filter->invalidate();
    }

    // clean up nearby device list?
    if (m_devices_nearby_model)
    {
        //m_devices_nearby_model->clearDevices();
    }

    if (hasBluetooth())
    {
        if (!m_bluetoothDiscoveryAgent)
        {
            startBleAgent();
        }

        if (m_bluetoothDiscoveryAgent)
        {
            if (m_bluetoothDiscoveryAgent->isActive() && m_scanning)
            {
                m_bluetoothDiscoveryAgent->stop();
                m_scanning = false;
                Q_EMIT scanningChanged();
            }

            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::bleDeviceNearby_discovered, Qt::UniqueConnection);
            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                    this, &DeviceManager::bleDeviceNearby_updated, Qt::UniqueConnection);

            // start scanning
            m_bluetoothDiscoveryAgent->setLowEnergyDiscoveryTimeout(ble_listening_duration_nearby*1000);
            m_bluetoothDiscoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

            if (m_bluetoothDiscoveryAgent->isActive())
            {
                m_scanning_nearby = true;
                Q_EMIT scanningNearbyChanged();
                qDebug() << "Listening for BLE nearby devices...";
            }
            else
            {
                qWarning() << "DeviceManager::scanNearby_start() DID NOT START";
            }
        }
        else
        {
            qWarning() << "Cannot start BLE agent";
        }
    }
    else
    {
        qWarning() << "Cannot scan or listen without BLE (or BLE permissions)";
    }
}

void DeviceManager::scanNearby_stop()
{
    qDebug() << "DeviceManager::scanNearby_stop()";

    if (m_bluetoothDiscoveryAgent)
    {
        disconnect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::bleDeviceNearby_discovered);
        disconnect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::bleDeviceNearby_updated);

        if (m_bluetoothDiscoveryAgent->isActive())
        {
            m_bluetoothDiscoveryAgent->stop();
        }

        if (m_scanning_nearby)
        {
            m_scanning_nearby = false;
            Q_EMIT scanningNearbyChanged();
        }
    }
}

/* ************************************************************************** */

void DeviceManager::addBleDeviceNearby(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "DeviceManager::addBleDeviceNearby()" << " > NAME" << info.name() << " > RSSI" << info.rssi();

    //if (info.isCached()) return; // we probably just hit the device cache
    if (info.rssi() >= 0) return; // we probably just hit the device cache

    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)
    {
        // Check if it's not already in the UI
        for (auto ed: std::as_const(m_devices_nearby_model->m_devices))
        {
            Device *edd = qobject_cast<Device*>(ed);
#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
            if (edd && edd->getAddress() == info.deviceUuid().toString())
#else
            if (edd && edd->getAddress() == info.address().toString())
#endif
            {
                edd->setName(info.name());
                edd->setRssi(info.rssi());
                return;
            }
        }

        // Create the device
        Device *d = new Device(info, this);
        if (d)
        {
            d->setRssi(info.rssi());

            // Add it to the UI
            m_devices_nearby_model->addDevice(d);
            Q_EMIT devicesNearbyUpdated();

            //qDebug() << "Device nearby added: " << d->getName() << "/" << d->getAddress();
        }
    }
}

void DeviceManager::bleDeviceNearby_discovered(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "DeviceManager::bleDeviceNearby_discovered()" << " > NAME" << info.name() << " > RSSI" << info.rssi();

    addBleDeviceNearby(info);
}

void DeviceManager::bleDeviceNearby_updated(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields)
{
    //qDebug() << "DeviceManager::bleDeviceNearby_updated()" << " > NAME" << info.name() << " > RSSI" << info.rssi();
    Q_UNUSED(updatedFields)

    addBleDeviceNearby(info);
}

/* ************************************************************************** */
