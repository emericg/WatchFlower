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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "devicemanager.h"
#include "device.h"
#include "device_flowercare.h"
#include "device_hygrotemp_lcd.h"
#include "device_hygrotemp_eink.h"
#include "device_hygrotemp_clock.h"
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
    startBleAgent();

    // Enables adapter // if off and permission given ONLY
    enableBluetooth(true);

    checkBluetooth();
    checkDatabase();

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

            Device *d = nullptr;

            if (deviceName == "Flower care" || deviceName == "Flower mate")
                d = new DeviceFlowercare(deviceAddr, deviceName, this);
            else if (deviceName == "ropot")
                d = new DeviceRopot(deviceAddr, deviceName, this);
            else if (deviceName == "MJ_HT_V1")
                d = new DeviceHygrotempLCD(deviceAddr, deviceName, this);
            else if (deviceName == "ClearGrass Temp & RH")
                d = new DeviceHygrotempEInk(deviceAddr, deviceName, this);
            else if (deviceName == "LYWSD02")
                d = new DeviceHygrotempClock(deviceAddr, deviceName, this);

            if (d)
            {
                connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
                m_devices.append(d);

                //qDebug() << "* Device added (from database): " << deviceName << "/" << deviceAddr;
            }
        }

        Q_EMIT devicesUpdated();
    }

    //listenDevices(); // WIP
}

DeviceManager::~DeviceManager()
{
    delete m_bluetoothAdapter;
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

bool DeviceManager::checkBluetooth()
{
    //qDebug() << "DeviceManager::checkBluetooth()";

#if defined(Q_OS_IOS)
    checkBluetoothIos();
    return true;
#endif

    bool status = false;

    bool btA_was = m_btA;
    bool btE_was = m_btE;

    // Check availability
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_btA = true;

        if (m_bluetoothAdapter->hostMode() > 0)
        {
            m_btE = true;
            status = true;
            qDebug() << "> Bluetooth adapter available";
        }
        else
        {
            m_btE = false;
            qDebug() << "Bluetooth adapter host mode:" << m_bluetoothAdapter->hostMode();
        }
    }
    else
    {
        m_btA = false;
        m_btE = false;
    }

    if (btA_was != m_btA || btE_was != m_btE)
        Q_EMIT bluetoothChanged(); // this function did changed the Bluetooth status

    return status;
}

void DeviceManager::enableBluetooth(bool enforceUserPermissionCheck)
{
    //qDebug() << "DeviceManager::enableBluetooth() enforce:" << enforceUserPermissionCheck;

#if defined(Q_OS_IOS)
    checkBluetoothIos();
    return;
#endif

    bool btA_was = m_btA;
    bool btE_was = m_btE;
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
    // Invalid adapter? (ex: plugged off)
    if (m_bluetoothAdapter && !m_bluetoothAdapter->isValid())
    {
        delete m_bluetoothAdapter;
        m_bluetoothAdapter = nullptr;
    }

    // We only try the "first" available Bluetooth adapter
    // TODO // Handle multiple adapters?
    if (!m_bluetoothAdapter)
    {
        m_bluetoothAdapter = new QBluetoothLocalDevice();
        if (m_bluetoothAdapter)
        {
            // Keep us informed of availability changes
            // On some platform, this can only inform us about disconnection, not reconnection
            connect(m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged,
                    this, &DeviceManager::bluetoothModeChanged);

            connect(this, &DeviceManager::bluetoothChanged,
                    this, &DeviceManager::bluetoothStatusChanged);
        }
    }

    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_btA = true;

        if (m_bluetoothAdapter->hostMode() > 0)
        {
            m_btE = true; // was already activated

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
            // Already powered on? Power on again anyway. It helps on android...
            m_bluetoothAdapter->powerOn();
#endif
        }
        else // Try to activate the adapter
        {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
            // mobile? check if we have the user's permission to do so
            if (enforceUserPermissionCheck)
            {
                SettingsManager *sm = SettingsManager::getInstance();
                if (sm && sm->getBluetoothControl())
                {
                    m_bluetoothAdapter->powerOn(); // Doesn't work on all platforms...
                }
            }
            else
#endif
            // desktop (or mobile but with user action)
            {
                Q_UNUSED(enforceUserPermissionCheck)
                m_bluetoothAdapter->powerOn(); // Doesn't work on all platforms...
            }
        }
    }
    else
    {
        m_btA = false;
        m_btE = false;
    }

    if (btA_was != m_btA || btE_was != m_btE)
        Q_EMIT bluetoothChanged(); // this function did changed the Bluetooth status
}

void DeviceManager::bluetoothModeChanged(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "DeviceManager::bluetoothModeChanged() host mode now:" << state;

    if (state > QBluetoothLocalDevice::HostPoweredOff)
    {
        m_btE = true;

        // Bluetooth enabled, refresh devices
        refreshDevices_check();
    }
    else
    {
        m_btE = false;

        // Bluetooth disabled, force disconnection
        refreshDevices_stop();
    }

    Q_EMIT bluetoothChanged();
}

void DeviceManager::bluetoothStatusChanged()
{
    qDebug() << "DeviceManager::bluetoothStatusChanged() bt adapter:" << m_btA << "  /  bt enabled:" << m_btE;

    if (m_btA && m_btE)
    {
        refreshDevices_check();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::hasDatabase() const
{
    return m_db;
}

/* ************************************************************************** */

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
    //return (m_discoveryAgent && m_discoveryAgent->isActive());
    return m_scanning;
}

void DeviceManager::startBleAgent()
{
    //qDebug() << "DeviceManager::startBleAgent()";

    // BLE discovery agent
    if (!m_discoveryAgent)
    {
        m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent();
        if (m_discoveryAgent)
        {
            connect(m_discoveryAgent, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::error),
                    this, &DeviceManager::deviceDiscoveryError);
        }
        else
        {
            qWarning() << "Unable to create BLE discovery agent...";
        }
    }
}

void DeviceManager::checkBluetoothIos()
{
#ifdef DEMO_MODE
    // iOS simulator doesn't have Bluetooth at all, so we fake it
    m_btA = true;
    m_btE = true;
    return;
#endif

    // iOS behave differently than all other platforms; there is no way to check
    // adapter status, only to start a device discovery and check for errors

    qDebug() << "DeviceManager::checkBluetoothIos()";

    m_btA = true;

    if (m_discoveryAgent && !m_discoveryAgent->isActive())
    {
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::deviceUpdateReceived);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                   this, &DeviceManager::deviceDiscoveryFinished);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                this, &DeviceManager::bleDiscoveryFinished,
                Qt::UniqueConnection);

        m_discoveryAgent->setLowEnergyDiscoveryTimeout(100);
        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

        if (m_discoveryAgent->isActive())
        {
            qDebug() << "Checking iOS bluetooth...";
        }
    }
}

void DeviceManager::scanDevices()
{
    //qDebug() << "DeviceManager::scanDevices()";

    if (hasBluetooth())
    {
        if (m_discoveryAgent && !m_discoveryAgent->isActive())
        {
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                       this, &DeviceManager::deviceUpdateReceived);

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::addBleDevice,
                    Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                    this, &DeviceManager::deviceDiscoveryFinished,
                    Qt::UniqueConnection);

            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                       this, &DeviceManager::bleDiscoveryFinished);

            m_discoveryAgent->setLowEnergyDiscoveryTimeout(8000);

            m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
            if (m_discoveryAgent->isActive())
            {
                m_scanning = true;
                Q_EMIT scanningChanged();
                qDebug() << "Scanning (Bluetooth) for devices...";
            }
        }
    }
}

void DeviceManager::deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
    {
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";

        if (m_btE)
        {
            m_btE = false;
            refreshDevices_stop();
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        if (m_btE)
        {
            m_btE = false;
            refreshDevices_stop();
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported platform.";

        m_btA = false;
        m_btE = false;
        refreshDevices_stop();
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";
    }
    else
    {
        qWarning() << "An unknown error has occurred.";
    }

    m_scanning = false;

    Q_EMIT devicesUpdated();
    Q_EMIT scanningChanged();
}

void DeviceManager::bleDiscoveryFinished()
{
    //qDebug() << "bleDiscoveryFinished()";

    m_btE = true;
    Q_EMIT bluetoothChanged();
}

void DeviceManager::deviceDiscoveryFinished()
{
    //qDebug() << "deviceDiscoveryFinished()";

    if (m_db)
    {
        qDebug() << "Scanning (database) for saved devices (not found by scanning)...";

        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            QString deviceAddr = queryDevices.value(1).toString();

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
                    d = new DeviceHygrotempLCD(deviceAddr, deviceName, this);
                else if (deviceName == "ClearGrass Temp & RH")
                    d = new DeviceHygrotempEInk(deviceAddr, deviceName, this);
                else if (deviceName == "LYWSD02")
                    d = new DeviceHygrotempClock(deviceAddr, deviceName, this);

                if (d)
                {
                    connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
                    m_devices.append(d);

                    qDebug() << "* Device added (from SQL database): " << deviceName << "/" << deviceAddr;
                }
            }
        }
    }

    m_scanning = false;

    Q_EMIT devicesUpdated();
    Q_EMIT scanningChanged();

    // Now refresh devices datas
    refreshDevices_check();
}

/* ************************************************************************** */

void DeviceManager::listenDevices()
{
#if (QT_VERSION >= QT_VERSION_CHECK(5, 12, 0))
    if (m_discoveryAgent && !m_discoveryAgent->isActive())
    {
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                this, &DeviceManager::deviceUpdateReceived,
                Qt::UniqueConnection);

        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                   this, &DeviceManager::deviceDiscoveryFinished);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                   this, &DeviceManager::bleDiscoveryFinished);

        m_discoveryAgent->setLowEnergyDiscoveryTimeout(60000);

        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
        if (m_discoveryAgent->isActive())
        {
            qDebug() << "Listening for ble advertisement devices...";
        }
    }
#endif // Qt 5.12
}

void DeviceManager::deviceUpdateReceived(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields)
{
#if (QT_VERSION >= QT_VERSION_CHECK(5, 12, 0))
    qDebug() << "deviceUpdateReceived() device: " << info.address();// << info.deviceUuid();
    //qDebug() << "deviceUpdateReceived() updatedFields: " << updatedFields;

    if ((updatedFields & 0x0001) == 0x0001) // RSSI = 0x0001
    {
        qDebug() << "RSSI > " << info.rssi();
    }
    if ((updatedFields & 0x0002) == 0x0002) // ManufacturerData = 0x0002
    {
        QHash<quint16, QByteArray> dat = info.manufacturerData();
        qDebug() << "manufacturerData > " << dat;
    }
#endif // Qt 5.12
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::refreshDevices_start()
{
    //qDebug() << "DeviceManager::refreshDevices_start()";

    // Already refreshing?
    if (isRefreshing())
    {
        // Here we can do:

        // nothing, and queue another refresh
        //refreshDevices_stop(); // or cancel current refresh
        return; // or bail
    }

    // Start refresh (if > 1 min)
    if (checkBluetooth() && !m_devices.empty())
    {
        m_devices_updatelist.clear();

        SettingsManager *sm = SettingsManager::getInstance();
        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && (dd->getLastUpdateInt() < 0 || dd->getLastUpdateInt() > 2))
            {
                // as long as we didn't just update it: go for refresh
                m_devices_updatelist.push_back(dd);

                if (sm->getBluetoothCompat())
                    dd->refreshQueue(); // sync
                else
                    dd->refreshStart(); // async
            }
        }

        if (!m_devices_updatelist.empty())
        {
            if (sm->getBluetoothCompat())
                refreshDevices_continue(); // sync

            Q_EMIT refreshingChanged();
        }
    }
}

void DeviceManager::refreshDevices_check()
{
    //qDebug() << "DeviceManager::refreshDevices_check()";

    // Already refreshing?
    if (isRefreshing())
    {
        // Here we can do:
                                    // - nothing, and queue another refresh
        //refreshDevices_stop();    // - or cancel current refresh
        return;                     // - or bail
    }

    // Start refresh (if needed)
    if (checkBluetooth() && !m_devices.empty())
    {
        m_devices_updatelist.clear();

        SettingsManager *sm = SettingsManager::getInstance();
        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && (dd->getLastUpdateInt() < 0 || dd->getLastUpdateInt() > sm->getUpdateInterval()))
            {
                // old or no datas: go for refresh
                m_devices_updatelist.push_back(dd);

                if (sm->getBluetoothCompat())
                    dd->refreshQueue(); // sync
                else
                    dd->refreshStart(); // async
            }
        }

        if (!m_devices_updatelist.empty())
        {
            if (sm->getBluetoothCompat())
                refreshDevices_continue(); // sync

            Q_EMIT refreshingChanged();
        }
    }
}

void DeviceManager::refreshDevices_continue()
{
    //qDebug() << "DeviceManager::refreshDevices_continue()" << m_devices_updatelist.size() << "device left";

    if (hasBluetooth() && !m_devices_updatelist.empty())
    {
        // update next device in the list

        Device *dd = qobject_cast<Device*>(m_devices_updatelist.first());
        if (dd) dd->refreshStart();
    }
}

void DeviceManager::refreshDevices_finished(Device *dev)
{
    //qDebug() << "DeviceManager::refreshDevices_finished()" << m_devices_updatelist.size() << "device in queue";

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

    //qDebug() << "DeviceManager::refreshDevices_finished()" << m_devices_updatelist.size() << "device left";

    if (m_devices_updatelist.empty())
    {
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

    if (!m_devices_updatelist.empty())
    {
        m_devices_updatelist.clear();

        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd) dd->refreshStop();
        }

        Q_EMIT refreshingChanged();
    }
}

bool DeviceManager::isRefreshing() const
{
    return !m_devices_updatelist.empty();
}

void DeviceManager::updateDevice(const QString &address)
{
    //qDebug() << "DeviceManager::updateDevice() " << address;

    if (hasBluetooth())
    {
        for (auto d: m_devices)
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && dd->getAddress() == address)
            {
                m_devices_updatelist += dd;
                dd->refreshQueue();

                SettingsManager *sm = SettingsManager::getInstance();
                if (!sm->getBluetoothCompat())
                {
                    dd->refreshStart();
                }
                if (sm->getBluetoothCompat() && m_devices_updatelist.size() == 1)
                {
                    refreshDevices_continue();
                }

                Q_EMIT refreshingChanged();
                break;
            }
        }
    }
}

/* ************************************************************************** */

void DeviceManager::addBleDevice(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "addBleDevice";

    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)
    {
        if (info.name() == "Flower care" || info.name() == "Flower mate" ||
            info.name() == "ropot" ||
            info.name() == "MJ_HT_V1" ||
            info.name() == "ClearGrass Temp & RH" ||
            info.name() == "LYWSD02")
        {
            // Check if it's not already in the UI
            for (auto ed: m_devices)
            {
                Device *edd = qobject_cast<Device*>(ed);
#if defined(Q_OS_OSX) || defined(Q_OS_IOS)
                if (edd && edd->getAddress() == info.deviceUuid().toString())
#else
                if (edd && edd->getAddress() == info.address().toString())
#endif
                {
                    return;
                }
            }

            // Create the device
            Device *d = nullptr;

            if (info.name() == "Flower care" || info.name() == "Flower mate")
                d = new DeviceFlowercare(info);
            else if (info.name() == "ropot")
                d = new DeviceRopot(info);
            else if (info.name() == "MJ_HT_V1")
                d = new DeviceHygrotempLCD(info);
            else if (info.name() == "ClearGrass Temp & RH")
                d = new DeviceHygrotempEInk(info);
            else if (info.name() == "LYWSD02")
                d = new DeviceHygrotempClock(info);

            if (!d)
                return;

            connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);

            SettingsManager *sm = SettingsManager::getInstance();
            if (d->getLastUpdateInt() < 0 || d->getLastUpdateInt() > sm->getUpdateInterval())
            {
                // old or no datas: mark it as queued until the deviceManager sync new devices
                d->refreshQueue();
            }

            // Add it to the database?
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

            // Add it to the UI
            m_devices.append(d);
            Q_EMIT devicesUpdated();

            qDebug() << "Device added (from BLE discovery): " << d->getName() << "/" << d->getAddress();
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
            dd->refreshStop();
            refreshDevices_finished(dd);

            // Remove from database // don't remove the actual datas, nor limits
            qDebug() << "- Removing device: " << dd->getName() << "/" << dd->getAddress() << "from local database";

            QSqlQuery removeDevice;
            removeDevice.prepare("DELETE FROM devices WHERE deviceAddr = :deviceAddr");
            removeDevice.bindValue(":deviceAddr", dd->getAddress());
            removeDevice.exec();

            // Remove device
            m_devices.removeAll(dd);
            qDebug() << "- Device removed: " << dd->getName() << "/" << dd->getAddress();
            delete dd;
            Q_EMIT devicesUpdated();

            break;
        }
    }
}

/* ************************************************************************** */
