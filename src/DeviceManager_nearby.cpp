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

    if (hasBluetooth())
    {
        if (!m_devices_nearby_model)
        {
            m_devices_nearby_model = new DeviceModel(this);
            m_devices_nearby_filter = new DeviceFilter(this);
            m_devices_nearby_filter->setSourceModel(m_devices_nearby_model);

            m_devices_nearby_filter->setSortRole(DeviceModel::DeviceRssiRole);
            m_devices_nearby_filter->sort(0, Qt::AscendingOrder);
            m_devices_nearby_filter->invalidate();
        }

        if (!m_discoveryAgent)
        {
            startBleAgent();
        }

        if (m_discoveryAgent)
        {
            if (m_discoveryAgent->isActive() && m_scanning)
            {
                m_discoveryAgent->stop();
                m_scanning = false;
                Q_EMIT scanningChanged();
            }

            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                       this, &DeviceManager::deviceDiscoveryFinished);

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::addNearbyBleDevice, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                    this, &DeviceManager::updateNearbyBleDevice, Qt::UniqueConnection);

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

            m_discoveryAgent->setLowEnergyDiscoveryTimeout(ble_listening_duration_nearby*1000);

            if (hasBluetoothPermissions())
            {
                m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

                if (m_discoveryAgent->isActive())
                {
                    m_listening = true;
                    Q_EMIT listeningChanged();
                    qDebug() << "Listening (Bluetooth) for devices...";
                }
            }
            else
            {
                qWarning() << "Cannot scan or listen without related Android permissions";
            }
        }
    }
}

void DeviceManager::scanNearby_stop()
{
    qDebug() << "DeviceManager::scanNearby_stop()";

    if (m_discoveryAgent)
    {
        if (m_discoveryAgent->isActive())
        {
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                       this, &DeviceManager::addNearbyBleDevice);
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                       this, &DeviceManager::updateNearbyBleDevice);

            m_discoveryAgent->stop();

            if (m_scanning)
            {
                m_scanning = false;
                Q_EMIT scanningChanged();
            }
            if (m_listening)
            {
                m_listening = false;
                Q_EMIT listeningChanged();
            }
        }
    }
}

/* ************************************************************************** */

void DeviceManager::addNearbyBleDevice(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "DeviceManager::addNearbyBleDevice()" << " > NAME" << info.name() << " > RSSI" << info.rssi();

    //if (info.isCached()) return; // we probably just hit the device cache
    if (info.rssi() >= 0) return; // we probably just hit the device cache

    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)
    {
        // Check if it's not already in the UI
        for (auto ed: qAsConst(m_devices_nearby_model->m_devices))
        {
            Device *edd = qobject_cast<Device*>(ed);
#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
            if (edd && edd->getAddress() == info.deviceUuid().toString())
#else
            if (edd && edd->getAddress() == info.address().toString())
#endif
            {
                return;
            }
        }

        // Create the device
        Device *d = new Device(info, this);
        if (!d) return;
        d->setRssi(info.rssi());

        //connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
        //connect(d, &Device::deviceSynced, this, &DeviceManager::syncDevices_finished);

        // Add it to the UI
        m_devices_nearby_model->addDevice(d);
        Q_EMIT devicesNearbyUpdated();

        //qDebug() << "Device nearby added: " << d->getName() << "/" << d->getAddress();
    }
}

void DeviceManager::updateNearbyBleDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields)
{
    //qDebug() << "DeviceManager::updateNearbyBleDevice()" << " > NAME" << info.name() << " > RSSI" << info.rssi();
    Q_UNUSED(updatedFields)

    // Check if it's not already in the UI
    for (auto d: qAsConst(m_devices_nearby_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        if (dd && dd->getAddress() == info.deviceUuid().toString())
#else
        if (dd && dd->getAddress() == info.address().toString())
#endif
        {
            dd->setName(info.name());
            dd->setRssi(info.rssi());
            return;
        }
    }

    addNearbyBleDevice(info);
}

/* ************************************************************************** */
