/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
        m_discoveryAgent->setLowEnergyDiscoveryTimeout(8000);

        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                this, &DeviceManager::addBleDevice);
        connect(m_discoveryAgent, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::error),
                this, &DeviceManager::deviceDiscoveryError);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                this, &DeviceManager::deviceDiscoveryFinished);
    }
    else
    {
        qWarning() << "Unable to create BLE discovery agent...";
    }

    // Load saved devices
    if (m_db)
    {
        // Make sure the list is clean
        qDeleteAll(m_devices);
        m_devices.clear();

        qDebug() << "Scanning (database) for devices...";

        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            QString deviceAddr = queryDevices.value(1).toString();

            //qDebug() << "* Device added (from database): " << deviceName << "/" << deviceAddr;

            Device *d = nullptr;

            if (deviceName == "Flower care" || deviceName == "Flower mate")
                d = new DeviceFlowercare(deviceAddr, deviceName, this);
            else if (deviceName == "ropot")
                d = new DeviceRopot(deviceAddr, deviceName, this);
            else if (deviceName == "MJ_HT_V1")
                d = new DeviceHygrotemp(deviceAddr, deviceName, this);
            else
                d = new Device(deviceAddr, deviceName, this);

            if (d)
            {
                connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
                m_devices.append(d);
            }
        }

        Q_EMIT devicesUpdated();
    }

    refreshDevices_check();
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

void DeviceManager::checkBluetooth()
{
/*
    // List Bluetooth adapters
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
        qDebug() << "> No Bluetooth adapter found...";
    }
*/
    // Enables adapter
    enableBluetooth(true);

    // Check availability
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        if (m_bluetoothAdapter->hostMode() > 0)
        {
            m_btE = true;
            qDebug() << "> Bluetooth adapter available";
        }
        else
            qDebug() << "Bluetooth adapter host mode:" << m_bluetoothAdapter->hostMode();
    }

    Q_EMIT bluetoothChanged();
}

void DeviceManager::enableBluetooth(bool checkPermission)
{
    qDebug() << "enableBluetooth()";

    // TODO // We only try the "first" available Bluetooth adapter
    if (!m_bluetoothAdapter)
    {
        m_bluetoothAdapter = new QBluetoothLocalDevice();
    }

    if (m_bluetoothAdapter)
    {
        m_btA = true;

        if (checkPermission)
        {
            SettingsManager *sm = SettingsManager::getInstance();
            if (sm && sm->getBluetoothControl())
            {
                // Make sure its powered on
                // Doesn't work on all platforms...
                m_bluetoothAdapter->powerOn();
            }
        }
        else
        {
            // Make sure its powered on
            // Doesn't work on all platforms...
            m_bluetoothAdapter->powerOn();
        }

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
        if (m_bluetoothAdapter->isValid() && m_bluetoothAdapter->hostMode() > 0)
        {
            // Already powered on? Power on again anyway. It helps on android...
            m_bluetoothAdapter->powerOn();
        }
#endif

        // Keep us informed of availability changes
        // On some platform it can only inform us about disconnection, not reconnection
        connect(m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged,
                this, &DeviceManager::bluetoothModeChanged);
    }
}

void DeviceManager::bluetoothModeChanged(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "Bluetooth host mode changed, now:" << state;

    if (state > 0)
    {
        m_btE = true;

        // Refresh devices
        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (!dd->isAvailable())
                dd->refreshDatas();
        }
    }
    else
    {
        m_btE = false;

        // Check Bluetooth again?
    }

    Q_EMIT bluetoothChanged();
}

/* ************************************************************************** */

bool DeviceManager::hasDatabase() const
{
    return m_db;
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

bool DeviceManager::isScanning() const
{
    return m_scanning;
}

void DeviceManager::scanDevices()
{
    if (hasBluetooth())
    {
        qDeleteAll(m_devices);
        m_devices.clear();

        qDebug() << "Scanning (Bluetooth) for devices...";

        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
        if (m_discoveryAgent->isActive())
        {
            m_scanning = true;
            Q_EMIT scanningChanged();
        }
    }
}

void DeviceManager::deviceDiscoveryFinished()
{
    qDebug() << "deviceDiscoveryFinished()";

    if (m_db)
    {
        qDebug() << "Scanning (database) for (duplicated) devices...";

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
                    d = new DeviceFlowercare(deviceAddr, deviceName, this);
                else if (deviceName == "ropot")
                    d = new DeviceRopot(deviceAddr, deviceName, this);
                else if (deviceName == "MJ_HT_V1")
                    d = new DeviceHygrotemp(deviceAddr, deviceName, this);
                else
                    d = new Device(deviceAddr, deviceName, this);

                if (d)
                {
                    connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
                    m_devices.append(d);
                }
            }
        }
    }

    m_scanning = false;

    Q_EMIT devicesUpdated();
    Q_EMIT scanningChanged();

    // Now refresh devices datas
    refreshDevices_start();
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
/* ************************************************************************** */

void DeviceManager::refreshDevices_start()
{
    //qDebug() << "DeviceManager::refreshDevices_start()";

    // TODO // check if we are not already doing something?

    if (hasBluetooth() && !m_devices.empty())
    {
        m_devices_updatelist.clear();

        SettingsManager *sm = SettingsManager::getInstance();
        if (sm->getBluetoothCompat())
        { // v2
            m_devices_updatelist = m_devices;
            //m_devices_updatelist += m_devices; // will retry once

            qDebug() << "starting update for" << m_devices_updatelist.size() << "devices";
            refreshDevices_continue();
        }
        else
        { // v1
            for (auto d: m_devices)
            {
                Device *dd = qobject_cast<Device*>(d);
                if (dd) dd->refreshDatas();
            }

            m_refreshing = true;
            Q_EMIT refreshingChanged();
        }
    }
}

void DeviceManager::refreshDevices_check()
{
    //qDebug() << "DeviceManager::refreshDevices_check()";

    // TODO // check if we are not already doing something?

    if (hasBluetooth() && !m_devices.empty())
    {
        m_devices_updatelist.clear();

        SettingsManager *sm = SettingsManager::getInstance();
        if (sm->getBluetoothCompat())
        { // v2
            for (auto d: m_devices)
            {
                Device *dd = qobject_cast<Device*>(d);

                if (dd && (dd->getLastUpdateInt() < 0 || dd->getLastUpdateInt() > sm->getUpdateInterval()))
                    m_devices_updatelist.push_back(dd); // old or no datas
            }
            refreshDevices_continue();
        }
        else
        { // v1
            for (auto d: m_devices)
            {
                Device *dd = qobject_cast<Device*>(d);
                if (dd && (dd->getLastUpdateInt() < 0 || dd->getLastUpdateInt() > sm->getUpdateInterval()))
                    dd->refreshDatas();
            }

            m_refreshing = true;
            Q_EMIT refreshingChanged();
        }
    }
}

void DeviceManager::refreshDevices_continue()
{
    //qDebug() << "DeviceManager::refreshDevices_continue()" << m_devices_updatelist.size() << "device left";

    if (hasBluetooth() && !m_devices_updatelist.empty())
    {
        m_refreshing = true;
        Q_EMIT refreshingChanged();

        // update next device in the list

        Device *dd = qobject_cast<Device*>(m_devices_updatelist.first());
        if (dd) dd->refreshDatas();
    }
}

void DeviceManager::refreshDevices_finished(Device *dev)
{
    //qDebug() << "DeviceManager::refreshDevices_finished()" << m_devices_updatelist.size() << "device left";

    if (dev && !m_devices_updatelist.isEmpty())
    {
        for (auto d: m_devices_updatelist)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && dd->getAddress() == dev->getAddress())
            {
                m_devices_updatelist.removeAll(d);
                break;
            }
        }
    }

    if (m_devices_updatelist.empty())
    {
        m_refreshing = false;
        Q_EMIT refreshingChanged();
    }
    else
    {
        // update next device in the list
        refreshDevices_continue();
    }
}

void DeviceManager::refreshDevices_stop()
{
    //qDebug() << "DeviceManager::refreshDevices_stop()";

    if (isRefreshing())
    {
        m_devices_updatelist.clear();

        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && dd->isUpdating()) dd->disconnectDevice();
        }

        m_refreshing = false;
        Q_EMIT refreshingChanged();
    }
}

bool DeviceManager::isRefreshing() const
{
    if (m_refreshing || !m_devices_updatelist.empty())
        return true;

    return false;
}

void DeviceManager::updateDevice(const QString &address)
{
    //qDebug() << "DeviceManager::updateDevice() " << address;

    // TODO // check if we are not already doing something?

    if (hasBluetooth())
    {
        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd->getAddress() == address)
            {
                SettingsManager *sm = SettingsManager::getInstance();
                if (sm->getBluetoothCompat())
                { // v2
                    if (m_devices_updatelist.isEmpty())
                    {
                        m_devices_updatelist += dd;
                        refreshDevices_continue();
                    }
                    else
                    {
                        m_devices_updatelist += dd;
                    }
                }
                else
                { // v1
                    dd->refreshDatas();

                    m_refreshing = true;
                    Q_EMIT refreshingChanged();
                }

                break;
            }
        }
    }
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
                    addDevice.prepare("INSERT INTO devices (deviceAddr, deviceName) VALUES (:deviceAddr, :deviceName)");
                    addDevice.bindValue(":deviceAddr", d->getAddress());
                    addDevice.bindValue(":deviceName", d->getName());
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

void DeviceManager::removeDevice(const QString &address)
{
    for (auto d: m_devices)
    {
        Device *dd = qobject_cast<Device*>(d);

        if (dd->getAddress() == address)
        {
            // Make sure its not being used
            disconnect(dd, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
            dd->disconnectDevice();
            refreshDevices_finished(dd);
/*
            // Remove from database // don't remove the actual datas
            qDebug() << "- Removing device: " << dd->getName() << "/" << dd->getAddress() << "to local database";

            QSqlQuery removeDevice;
            removeDevice.prepare("DELETE FROM devices WHERE deviceAddr = :deviceAddr");
            removeDevice.bindValue(":deviceAddr", dd->getAddress());
            removeDevice.exec();
*/
            // Remove device
            m_devices.removeAll(dd);
            qDebug() << "Device removed: " << dd->getName() << "/" << dd->getAddress();
            delete dd;
            Q_EMIT devicesUpdated();
        }
    }
}

/* ************************************************************************** */
