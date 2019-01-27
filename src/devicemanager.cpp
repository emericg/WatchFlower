/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "devicemanager.h"
#include "device.h"
#include "device_flowercare.h"
#include "device_hygrotemp.h"
#include "device_ropot.h"

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothServiceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>

#include <QStandardPaths>
#include <QList>
#include <QDir>
#include <QTimer>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

/* ************************************************************************** */

DeviceManager::DeviceManager()
{
    checkBluetooth();
    checkDatabase();

    // BLE discovery agent
    m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent();
    if (m_discoveryAgent)
    {
        m_discoveryAgent->setLowEnergyDiscoveryTimeout(5000);

        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, &DeviceManager::addBleDevice);
        connect(m_discoveryAgent, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::error), this, &DeviceManager::deviceDiscoveryError);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, &DeviceManager::deviceDiscoveryFinished);
    }
    else
    {
        qWarning() << "Unable to create BLE discovery agent...";
    }

    // Add static devices first?
    qDebug() << "Scanning (database) for devices...";
    if (m_db)
    {
        qDeleteAll(m_devices);
        m_devices.clear();

        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            QString deviceAddr = queryDevices.value(1).toString();

            //qDebug() << "* Device added (from database): " << deviceName << "/" << deviceAddr;
            Device *d = nullptr;

            if (deviceName == "Flower care" || deviceName == "Flower mate")
                d = new DeviceFlowercare(deviceAddr, deviceName);
            else if (deviceName == "ropot")
                d = new DeviceRopot(deviceAddr, deviceName);
            else if (deviceName == "MJ_HT_V1")
                d = new DeviceHygrotemp(deviceAddr, deviceName);
            else
                d = new Device(deviceAddr, deviceName);

            if (d)
            {
                if (hasBluetooth()) d->refreshDatas();
                m_devices.append(d);
            }
        }
    }

    // Set refresh timer
    connect(&m_refreshingTimer, &QTimer::timeout, this, &DeviceManager::refreshCheck);
    m_refreshingTimer.setInterval(1000);

    // Start refresh timer
    m_refreshingTimer.start();
}

DeviceManager::~DeviceManager()
{
    delete  m_bluetoothAdapter;
    delete m_discoveryAgent;
    delete m_controller;

    qDeleteAll(m_devices);
    m_devices.clear();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::hasBluetooth() const
{
    return (m_btA && m_btE);
}

bool DeviceManager::hasBluetoothAdapter() const
{
    return m_btA;
}

bool DeviceManager::hasBluetoothEnabled() const
{
    return m_btE;
}

bool DeviceManager::hasDatabase() const
{
    return m_db;
}

/* ************************************************************************** */

void DeviceManager::checkBluetooth()
{
    // List bluetooth adapters
    QList<QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
    if (adaptersList.size() > 0)
    {
        for (QBluetoothHostInfo a: adaptersList)
        {
            qDebug() << "- Bluetooth adapter:" << a.name();
        }
    }
    else
    {
        qDebug() << "> No bluetooth adapter found...";
        if (m_bluetoothAdapter)
        {
            disconnect(m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged, this, &DeviceManager::changeBluetoothMode);
            delete m_bluetoothAdapter;
            m_bluetoothAdapter = nullptr;
        }
        Q_EMIT bluetoothChanged();
        return;
    }

    // TODO // We only try the "first" available bluetooth adapter
    if (!m_bluetoothAdapter)
    {
        m_bluetoothAdapter = new QBluetoothLocalDevice();
    }

    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_btA = true;

        // Make sure its powered on
        // Doesn't work on all platforms
        //m_bluetoothAdapter->powerOn();

        // Check availability
        if (m_bluetoothAdapter->hostMode() > 0)
        {
            m_btE = true;
            qDebug() << "> Bluetooth adapter available";

            // Keep us informed of availability changes
            // Can only inform us about disconnection, never reconnection
            connect(m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged, this, &DeviceManager::changeBluetoothMode);
        }
        else
            qDebug() << "Bluetooth adapter host mode:" << m_bluetoothAdapter->hostMode();
    }

    Q_EMIT bluetoothChanged();
}

void DeviceManager::checkDatabase()
{
    if (QSqlDatabase::isDriverAvailable("QSQLITE"))
    {
        qDebug() << "> SQLite available";

        QSqlDatabase db = QSqlDatabase::database();

        m_db = db.isValid();
    }
    else
    {
        m_db = false;
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::changeBluetoothMode(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "Bluetooth host mode changed, now:" << state;

    if (state > 0)
    {
        m_btE = true;
    }
    else
    {
        m_btE = false;

        // Check bluetooth again?
    }

    Q_EMIT bluetoothChanged();
}

/* ************************************************************************** */

bool DeviceManager::isScanning() const
{
    return m_scanning;
}

bool DeviceManager::isRefreshing() const
{
    return m_refreshing;
}

void DeviceManager::scanDevices()
{
    if (m_btA)
    {
        qDeleteAll(m_devices);
        m_devices.clear();

        qDebug() << "Scanning (bluetooth) for devices...";

        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
        if (m_discoveryAgent->isActive())
        {
            m_scanning = true;
            Q_EMIT scanningChanged();
        }
    }
}

void DeviceManager::refreshDevices()
{
    if (m_btA && !m_devices.empty())
    {
        m_refreshing = true;

        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd) dd->refreshDatas();
        }

        Q_EMIT refreshingChanged();
        Q_EMIT devicesUpdated();
    }
}

void DeviceManager::refreshCheck()
{
    if (m_btA)
    {
        bool refreshing = false;

        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd)
                refreshing |= dd->isUpdating();
        }

        if (m_refreshing != refreshing)
        {
            m_refreshing = refreshing;
            Q_EMIT refreshingChanged();
        }
    }
}

void DeviceManager::deviceDiscoveryFinished()
{
    qDebug() << "Scanning (database) for devices...";
    if (m_db)
    {
        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            QString deviceAddr = queryDevices.value(1).toString();

            qDebug() << "* Device added (from BLE discovery): " << deviceName << "/" << deviceAddr;

            // device lookup
            bool found = false;
            for (auto d: m_devices)
            {
                Device *dd = qobject_cast<Device*>(d);
                if (dd && dd->getAddress() == deviceAddr)
                {
                    found = true;
                    break;
                }
            }
            if (found == false)
            {
                Device *d = nullptr;

                if (deviceName == "Flower care" || deviceName == "Flower mate")
                    d = new DeviceFlowercare(deviceAddr, deviceName);
                else if (deviceName == "ropot")
                    d = new DeviceRopot(deviceAddr, deviceName);
                else if (deviceName == "MJ_HT_V1")
                    d = new DeviceHygrotemp(deviceAddr, deviceName);
                else
                    d = new Device(deviceAddr, deviceName);

                if (!d)
                    continue;

                m_devices.append(d);
            }
        }
    }
/*
    for (auto d: devices)
    {
        DeviceInfo *dd = qobject_cast<DeviceInfo*>(d);
        dd->refreshDatas();
    }
*/
    m_scanning = false;

    Q_EMIT devicesUpdated();
    Q_EMIT scanningChanged();
}

void DeviceManager::deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
        qWarning() << "Writing or reading from the device resulted in an error.";
    else
        qWarning() << "An unknown error has occurred.";

    m_scanning = false;

    Q_EMIT devicesUpdated();
    Q_EMIT scanningChanged();
}

/* ************************************************************************** */

void DeviceManager::addBleDevice(const QBluetoothDeviceInfo &info)
{
    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)
    {
        if (info.name() == "Flower care" || info.name() == "Flower mate" ||
            info.name() == "ropot" ||
            info.name() == "MJ_HT_V1")
        {
            Device *d = nullptr;

            if (info.name() == "Flower care" || info.name() == "Flower mate")
                d = new DeviceFlowercare(info);
            else if (info.name() == "ropot")
                    d = new DeviceRopot(info);
            else if (info.name() == "MJ_HT_V1")
                    d = new DeviceHygrotemp(info);
            else
                d = new Device(info);

            if (!d)
                return;

            m_devices.append(d);

            qDebug() << "Device added: " << d->getName() << "/" << d->getAddress();
            Q_EMIT devicesUpdated();

            // Also add it to the database?
            if (m_db)
            {
                // if
                QSqlQuery queryDevice;
                queryDevice.prepare("SELECT deviceName FROM devices WHERE deviceAddr = :deviceAddr");
                queryDevice.bindValue(":deviceAddr", d->getAddress());
                queryDevice.exec();

                // then
                if (queryDevice.last() == false)
                {
                    qDebug() << "+ Adding device: " << d->getName() << "/" << d->getAddress() << "to local database";

                    QSqlQuery addDevice;
                    addDevice.prepare("INSERT INTO devices (deviceAddr, deviceName, customName) VALUES (:deviceAddr, :deviceName, :customName)");
                    addDevice.bindValue(":deviceAddr", d->getAddress());
                    addDevice.bindValue(":deviceName", d->getName());
                    addDevice.bindValue(":customName", d->getName());
                    addDevice.exec();
                }
            }
        }
        else
        {
            //qDebug() << "Unsupported device: " << info.name() << "/" << info.address();
        }
    }
}

bool DeviceManager::areDevicesAvailable() const
{
    if (m_devices.size() > 0)
        return true;
    else
        return false;
}

/* ************************************************************************** */
