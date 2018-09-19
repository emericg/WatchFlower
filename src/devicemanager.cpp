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
    loadBluetooth();
    loadDatabase();

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

            if (!d)
                return;

            m_devices.append(d);
        }
    }
}

DeviceManager::~DeviceManager()
{
    delete m_discoveryAgent;

    qDeleteAll(m_devices);
    m_devices.clear();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::hasBluetooth() const
{
    return m_bt;
}

bool DeviceManager::hasDatabase() const
{
    return m_db;
}

/* ************************************************************************** */

void DeviceManager::loadBluetooth()
{
    // List bluetooth adapters
    QList<QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
    if (adaptersList.size() > 0)
    {
        for (QBluetoothHostInfo a: adaptersList)
        {
            //qDebug() << "- Bluetooth adapter:" << a.name();
        }
    }
    else
    {
        qDebug() << "> No bluetooth adapter found...";
        return;
    }

    // TODO // We only try the "first" available bluetooth adapter
    if (m_bluetoothAdapter.isValid())
    {
        // Make sure its powered on
        m_bluetoothAdapter.powerOn();

        // Keep us informed of availability changes
        connect(&m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged, this, &DeviceManager::changeBluetoothMode);

        // Check availability
        if (m_bluetoothAdapter.hostMode() > 0)
        {
            m_bt = true;
            qDebug() << "> Bluetooth adapter available";
        }
        else
            qDebug() << "Bluetooth adapter host mode:" << m_bluetoothAdapter.hostMode();
    }

    emit bluetoothChanged();
}

void DeviceManager::loadDatabase()
{
    if (QSqlDatabase::isDriverAvailable("QSQLITE"))
    {
        qDebug() << "> SQLite available";

        QSqlDatabase db = QSqlDatabase::database();
        if (db.isValid())
        {
            m_db = true;
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::changeBluetoothMode(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "Bluetooth host mode changed, now:" << state;

    if (state > 0)
    {
        m_bt = true;
        qDebug() << "> Bluetooth available";
    }
    else
        m_bt = false;

    emit bluetoothChanged();
}

/* ************************************************************************** */

bool DeviceManager::isScanning() const
{
    return m_scanning;
}

void DeviceManager::startDeviceDiscovery()
{
    if (m_bt)
    {
        qDeleteAll(m_devices);
        m_devices.clear();
        emit devicesUpdated();

        qDebug() << "Scanning (bluetooth) for devices...";

        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
        if (m_discoveryAgent->isActive())
        {
            m_scanning = true;
            emit scanningChanged();
        }
    }
}

void DeviceManager::refreshDevices()
{
    if (m_bt)
    {
        m_scanning = true;
        emit scanningChanged();

        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd)
                dd->refreshDatas();
        }

        m_scanning = false;
        emit scanningChanged();
        emit devicesUpdated();
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
                if (dd && dd->getMacAddress() == deviceAddr)
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

    emit devicesUpdated();
    emit scanningChanged();
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

    emit devicesUpdated();
    emit scanningChanged();
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

            qDebug() << "Last device added: " << d->getName() << "/" << d->getMacAddress();

            // Also add it to the database?
            if (m_db)
            {
                // if
                QSqlQuery queryDevice;
                queryDevice.prepare("SELECT deviceName FROM devices WHERE deviceAddr = :deviceAddr");
                queryDevice.bindValue(":deviceAddr", d->getMacAddress());
                queryDevice.exec();

                // then
                if (queryDevice.last() == false)
                {
                    qDebug() << "+ Adding device: " << d->getName() << "/" << d->getMacAddress() << "to local database";

                    QSqlQuery addDevice;
                    addDevice.prepare("INSERT INTO devices (deviceAddr, deviceName, customName) VALUES (:deviceAddr, :deviceName, :customName)");
                    addDevice.bindValue(":deviceAddr", d->getMacAddress());
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
