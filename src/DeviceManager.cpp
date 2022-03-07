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

#include "DeviceManager.h"
#include "device.h"
#include "devices/device_flowercare.h"
#include "devices/device_flowerpower.h"
#include "devices/device_parrotpot.h"
#include "devices/device_ropot.h"
#include "devices/device_hygrotemp_lcd.h"
#include "devices/device_hygrotemp_cgg1.h"
#include "devices/device_hygrotemp_clock.h"
#include "devices/device_hygrotemp_square.h"
#include "devices/device_hygrotemp_cgdk2.h"
#include "devices/device_thermobeacon.h"
#include "devices/device_esp32_airqualitymonitor.h"
#include "devices/device_esp32_higrow.h"
#include "devices/device_esp32_geigercounter.h"
#include "devices/device_ess_generic.h"
#include "devices/device_wp6003.h"

#include "utils/utils_app.h"

#include "DatabaseManager.h"

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyConnectionParameters>

#include <QList>
#include <QDebug>

#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

/* ************************************************************************** */

DeviceManager::DeviceManager()
{
    // Data model init
    m_devices_model = new DeviceModel(this);
    m_devices_filter = new DeviceFilter(this);
    m_devices_filter->setSourceModel(m_devices_model);
    SettingsManager *sm = SettingsManager::getInstance();
    if (sm)
    {
        //if (sm->getOrderBy() == "manual") orderby_manual();
        if (sm->getOrderBy() == "location") orderby_location();
        if (sm->getOrderBy() == "plant") orderby_plant();
        if (sm->getOrderBy() == "waterlevel") orderby_waterlevel();
        if (sm->getOrderBy() == "model") orderby_model();
        if (sm->getOrderBy() == "insideoutside") orderby_insideoutside();
    }

    // BLE init
    startBleAgent();
    enableBluetooth(true); // Enables adapter // ONLY if off and permission given
    checkBluetooth();

    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    if (m_dbInternal || m_dbExternal)
    {
        // Load blacklist
        QSqlQuery queryBlacklist;
        queryBlacklist.exec("SELECT deviceAddr FROM devicesBlacklist");
        while (queryBlacklist.next())
        {
            m_devices_blacklist.push_back(queryBlacklist.value(0).toString());
        }

        // Load saved devices
        qDebug() << "Scanning (database) for devices...";

        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            QString deviceAddr = queryDevices.value(1).toString();

            Device *d = nullptr;

            if (deviceName == "Flower care" || deviceName == "Flower mate" || deviceName == "Grow care garden")
                d = new DeviceFlowerCare(deviceAddr, deviceName, this);
            else if (deviceName == "ropot")
                d = new DeviceRopot(deviceAddr, deviceName, this);
            else if (deviceName.startsWith("Flower power"))
                d = new DeviceFlowerPower(deviceAddr, deviceName, this);
            else if (deviceName.startsWith("Parrot pot"))
                d = new DeviceParrotPot(deviceAddr, deviceName, this);
            else if (deviceName == "HiGrow")
                d = new DeviceEsp32HiGrow(deviceAddr, deviceName, this);
            else if (deviceName == "MJ_HT_V1")
                d = new DeviceHygrotempLCD(deviceAddr, deviceName, this);
            else if (deviceName == "ClearGrass Temp & RH")
                d = new DeviceHygrotempCGG1(deviceAddr, deviceName, this);
            else if (deviceName == "Qingping Temp RH Lite")
                d = new DeviceHygrotempCGDK2(deviceAddr, deviceName, this);
            else if (deviceName == "LYWSD02" || deviceName == "MHO-C303")
                d = new DeviceHygrotempClock(deviceAddr, deviceName, this);
            else if (deviceName == "LYWSD03MMC" || deviceName == "MHO-C401")
                d = new DeviceHygrotempSquare(deviceAddr, deviceName, this);
            else if (deviceName == "ThermoBeacon")
                d = new DeviceThermoBeacon(deviceAddr, deviceName, this);
            else if (deviceName.startsWith("WP6003"))
                d = new DeviceWP6003(deviceAddr, deviceName, this);
            else if (deviceName == "AirQualityMonitor")
                d = new DeviceEsp32AirQualityMonitor(deviceAddr, deviceName, this);
            else if (deviceName == "GeigerCounter")
                d = new DeviceEsp32GeigerCounter(deviceAddr, deviceName, this);

            if (d)
            {
                connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
                connect(d, &Device::deviceSynced, this, &DeviceManager::syncDevices_finished);
                m_devices_model->addDevice(d);

                //qDebug() << "* Device added (from database): " << deviceName << "/" << deviceAddr;
            }
        }
    }
}

DeviceManager::~DeviceManager()
{
    delete m_bluetoothAdapter;
    delete m_discoveryAgent;
    delete m_ble_params;

    delete m_devices_nearby_filter;
    delete m_devices_nearby_model;

    delete m_devices_filter;
    delete m_devices_model;
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

bool DeviceManager::isListening() const
{
    return m_listening;
}

bool DeviceManager::isScanning() const
{
    return m_scanning;
}

/* ************************************************************************** */

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
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

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
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }
}

/* ************************************************************************** */

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
    qDebug() << "DeviceManager::bluetoothStatusChanged() bt adapter:" << m_btA << " /  bt enabled:" << m_btE;

    if (m_btA && m_btE)
    {
        refreshDevices_check();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::startBleAgent()
{
    //qDebug() << "DeviceManager::startBleAgent()";

    // BLE discovery agent
    if (!m_discoveryAgent)
    {
        m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent();
        if (m_discoveryAgent)
        {
            connect(m_discoveryAgent, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::errorOccurred),
                    this, &DeviceManager::deviceDiscoveryError, Qt::UniqueConnection);
        }
        else
        {
            qWarning() << "Unable to create BLE discovery agent...";
        }
    }
}

void DeviceManager::checkBluetoothIos()
{
    // iOS behave differently than all other platforms; there is no way to check
    // adapter status, only to start a device discovery and check for errors

    qDebug() << "DeviceManager::checkBluetoothIos()";

    m_btA = true;

    if (m_discoveryAgent && !m_discoveryAgent->isActive())
    {
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::detectBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::updateBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addNearbyBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::updateNearbyBleDevice);

        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                   this, &DeviceManager::deviceDiscoveryFinished);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                this, &DeviceManager::bluetoothModeChangedIos, Qt::UniqueConnection);

        m_discoveryAgent->setLowEnergyDiscoveryTimeout(8); // 8ms
        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

        if (m_discoveryAgent->isActive())
        {
            qDebug() << "Checking iOS Bluetooth...";
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

    if (m_scanning)
    {
        m_scanning = false;
        Q_EMIT scanningChanged();
    }
}

void DeviceManager::deviceDiscoveryFinished()
{
    qDebug() << "DeviceManager::deviceDiscoveryFinished()";

    // Now refresh devices data
    refreshDevices_check();
}

void DeviceManager::deviceDiscoveryStopped()
{
    //qDebug() << "DeviceManager::deviceDiscoveryStopped()";

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

void DeviceManager::bluetoothModeChangedIos()
{
    //qDebug() << "DeviceManager::bluetoothModeChangedIos()";

    if (!m_btE)
    {
        m_btE = true;
        Q_EMIT bluetoothChanged();

        // Now refresh devices data
        //refreshDevices_check();
        refreshDevices_listen();
    }
}

/* ************************************************************************** */
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

            m_discoveryAgent->setLowEnergyDiscoveryTimeout(ble_scanning_nearby_duration*1000);
            m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

            if (m_discoveryAgent->isActive())
            {
                m_listening = true;
                Q_EMIT listeningChanged();
                qDebug() << "Listening (Bluetooth) for devices...";
            }
        }
    }
}

void DeviceManager::scanNearby_stop()
{
    qDebug() << "DeviceManager::scanNearby_stop()";

    if (hasBluetooth())
    {
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
}

void DeviceManager::addNearbyBleDevice(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "DeviceManager::addNearbyBleDevice()" << " > NAME" << info.name() << " > RSSI" << info.rssi();

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
            dd->setRssi(info.rssi());
            return;
        }
    }

    addNearbyBleDevice(info);
}

/* ************************************************************************** */

void DeviceManager::scanDevices_start()
{
    //qDebug() << "DeviceManager::scanDevices_start()";

    if (hasBluetooth())
    {
        if (!m_discoveryAgent)
        {
            startBleAgent();
        }
        if (m_discoveryAgent)
        {
            if (m_discoveryAgent->isActive() && m_scanning)
            {
                qWarning() << "DeviceManager::scanDevices_start() already scanning?";
            }
            else
            {
                disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                           this, &DeviceManager::addNearbyBleDevice);
                disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                           this, &DeviceManager::updateNearbyBleDevice);

                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                        this, &DeviceManager::deviceDiscoveryFinished, Qt::UniqueConnection);
                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                        this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);
                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                        this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                        this, &DeviceManager::addBleDevice, Qt::UniqueConnection);
                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                        this, &DeviceManager::updateBleDevice, Qt::UniqueConnection);

                m_discoveryAgent->setLowEnergyDiscoveryTimeout(ble_scanning_duration*1000);
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
}

void DeviceManager::scanDevices_stop()
{
    //qDebug() << "DeviceManager::scanDevices_stop()";

    if (hasBluetooth())
    {
        if (m_discoveryAgent)
        {
            if (m_discoveryAgent->isActive())
            {
                disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                           this, &DeviceManager::addBleDevice);

                m_discoveryAgent->stop();
            }
        }
    }
}

/* ************************************************************************** */

void DeviceManager::listenDevices()
{
    //qDebug() << "DeviceManager::listenDevices()";

    if (hasBluetooth())
    {
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

            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                       this, &DeviceManager::addNearbyBleDevice);
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                       this, &DeviceManager::updateNearbyBleDevice);

            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                       this, &DeviceManager::addBleDevice);
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                       this, &DeviceManager::deviceDiscoveryFinished);

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::detectBleDevice, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                    this, &DeviceManager::updateBleDevice, Qt::UniqueConnection);

            m_discoveryAgent->setLowEnergyDiscoveryTimeout(ble_listening_duration*1000);
            m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

            if (m_discoveryAgent->isActive())
            {
                m_listening = true;
                Q_EMIT listeningChanged();
                qDebug() << "Listening for BLE advertisement devices...";
            }
        }
    }
}

void DeviceManager::updateBleDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields)
{
    //qDebug() << "updateBleDevice() " << info.address() /*<< info.deviceUuid()*/ << " updatedFields: " << updatedFields;
    Q_UNUSED(updatedFields)

    for (auto d: qAsConst(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        if (dd && dd->getAddress() == info.deviceUuid().toString())
#else
        if (dd && dd->getAddress() == info.address().toString())
#endif
        {
            const QVector<quint16> &manufacturerIds = info.manufacturerIds();
            for (const auto id: manufacturerIds)
            {
                //qDebug() << info.name() << info.address() << Qt::hex
                //         << "ID" << id
                //         << "data" << Qt::dec << info.manufacturerData(id).count() << Qt::hex
                //         << "bytes:" << info.manufacturerData(id).toHex();

                dd->parseAdvertisementData(info.manufacturerData(id));
            }

            const QList<QBluetoothUuid> &serviceIds = info.serviceIds();
            for (const auto id: serviceIds)
            {
                //qDebug() << info.name() << info.address() << Qt::hex
                //         << "ID" << id
                //         << "data" << Qt::dec << info.serviceData(id).count() << Qt::hex
                //         << "bytes:" << info.serviceData(id).toHex();

                dd->parseAdvertisementData(info.serviceData(id));
            }

            // Dynamic updates
            if (m_listening)
            {
                if (dd->getName() == "ThermoBeacon") return;

                if (dd->needsUpdateRt())
                {
                    // old or no data: go for refresh
                    m_devices_updating_queue.push_back(dd);
                    dd->refreshQueue();
                    refreshDevices_continue();
                }
            }

            return;
        }
    }

    if (m_scanning)
    {
        addBleDevice(info);
    }
}

void DeviceManager::detectBleDevice(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "detectBleDevice() " << info.address() /*<< info.deviceUuid()*/;

    for (auto d: qAsConst(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        if (dd && dd->getAddress() == info.deviceUuid().toString())
#else
        if (dd && dd->getAddress() == info.address().toString())
#endif
        {
            if (dd->getName() == "ThermoBeacon") return;

            if (dd->needsUpdateRt())
            {
                // old or no data: go for refresh
                m_devices_updating_queue.push_back(dd);
                dd->refreshQueue();
                refreshDevices_continue();
            }

            return;
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::isUpdating() const
{
    return !m_devices_updating.empty();
}

void DeviceManager::updateDevice(const QString &address)
{
    //qDebug() << "DeviceManager::updateDevice() " << address;

    if (hasBluetooth())
    {
        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && dd->getAddress() == address)
            {
                m_devices_updating_queue += dd;
                dd->refreshQueue();
                refreshDevices_continue();
                break;
            }
        }
    }
}

void DeviceManager::refreshDevices_listen()
{
    //qDebug() << "DeviceManager::refreshDevices_listen()";

    // Already updating?
    if (isScanning() || isUpdating())
    {
        // Here we can:             // > do nothing, and queue another refresh
        //refreshDevices_stop();    // > (or) cancel current refresh
        return;                     // > (or) bail
    }

    // Make sure we have Bluetooth and devices
    if (checkBluetooth() && m_devices_model->hasDevices())
    {
        m_devices_updating_queue.clear();
        m_devices_updating.clear();

        // Background refresh
        listenDevices();
    }
}

void DeviceManager::refreshDevices_check()
{
    //qDebug() << "DeviceManager::refreshDevices_check()";

    // Already updating?
    if (isScanning() || isUpdating())
    {
        // Here we can:             // > do nothing, and queue another refresh
        //refreshDevices_stop();    // > (or) cancel current refresh
        return;                     // > (or) bail
    }

    // Make sure we have Bluetooth and devices
    if (checkBluetooth() && m_devices_model->hasDevices())
    {
        m_devices_updating_queue.clear();
        m_devices_updating.clear();

        // Background refresh
        listenDevices();

        // Start refresh (if needed)
        for (int i = 0; i < m_devices_model->rowCount(); i++)
        {
            QModelIndex e = m_devices_filter->index(i, 0);
            Device *dd = qvariant_cast<Device *>(m_devices_filter->data(e, DeviceModel::PointerRole));

            if (dd)
            {
                if (dd->getName() == "ThermoBeacon") continue;

                if (dd->needsUpdateRt())
                {
                    // old or no data: go for refresh
                    m_devices_updating_queue.push_back(dd);
                    dd->refreshQueue();
                }
            }
        }
        refreshDevices_continue();
    }
}

void DeviceManager::refreshDevices_start()
{
    //qDebug() << "DeviceManager::refreshDevices_start()";

    // Already updating?
    if (isScanning() || isUpdating())
    {
        // Here we can:             // > do nothing, and queue another refresh
        //refreshDevices_stop();    // > (or) cancel current refresh
        return;                     // > (or) bail
    }

    // Make sure we have Bluetooth and devices
    if (checkBluetooth() && m_devices_model->hasDevices())
    {
        m_devices_updating_queue.clear();
        m_devices_updating.clear();

        // Background refresh
        listenDevices();

        // Start refresh (if last device update > 1 min)
        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && (dd->getLastUpdateInt() < 0 || dd->getLastUpdateInt() > 2))
            {
                if (dd->getName() == "ThermoBeacon") continue;

                // as long as we didn't just update it: go for refresh
                m_devices_updating_queue.push_back(dd);
                dd->refreshQueue();
            }
        }
        refreshDevices_continue();
    }
}

void DeviceManager::refreshDevices_continue()
{
    //qDebug() << "DeviceManager::refreshDevices_continue()" << m_devices_updating_queue.size() << "device left";

    if (hasBluetooth())
    {
        if (!m_devices_updating_queue.empty())
        {
            int sim = SettingsManager::getInstance()->getBluetoothSimUpdates();

            while (!m_devices_updating_queue.empty() && m_devices_updating.size() < sim)
            {
                // update next device in the list
                Device *d = qobject_cast<Device*>(m_devices_updating_queue.first());
                if (d)
                {
                    m_devices_updating_queue.removeFirst();
                    m_devices_updating.push_back(d);
                    if (!m_updating)
                    {
                        m_updating = true;
                        Q_EMIT updatingChanged();
                    }

                    d->refreshStart();
                }
            }
        }
    }

    if (m_devices_updating_queue.empty() && m_devices_updating.empty())
    {
        if (m_updating)
        {
            m_updating = false;
            Q_EMIT updatingChanged();
        }
    }
}

void DeviceManager::refreshDevices_finished(Device *dev)
{
    //qDebug() << "DeviceManager::refreshDevices_finished()" << dev->getAddress();

    if (m_devices_updating.contains(dev))
    {
        m_devices_updating.removeAll(dev);

        // update next device in the list
        refreshDevices_continue();
    }
}

void DeviceManager::refreshDevices_stop()
{
    //qDebug() << "DeviceManager::refreshDevices_stop()";

    if (!m_devices_updating_queue.empty())
    {
        for (auto d: qAsConst(m_devices_updating))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd) dd->refreshStop();
        }

        m_devices_updating_queue.clear();
        m_devices_updating.clear();
        m_updating = false;

        Q_EMIT updatingChanged();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::isSyncing() const
{
    return !m_devices_syncing.empty();
}

void DeviceManager::syncDevice(const QString &address)
{
    //qDebug() << "DeviceManager::syncDevice() " << address;

    if (hasBluetooth())
    {
        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && dd->getAddress() == address)
            {
                m_devices_syncing_queue += dd;
                dd->refreshQueue();
                syncDevices_continue();
                break;
            }
        }
    }
}

void DeviceManager::syncDevices_check()
{
    //qDebug() << "DeviceManager::syncDevices_check()";

    // Already syncing?
    if (isSyncing())
    {
        // Here we can:             // > do nothing, and queue another sync
        //syncDevices_stop();       // > (or) cancel current sync
        return;                     // > (or) bail
    }

    // Make sure we have Bluetooth and devices
    if (checkBluetooth() && m_devices_model->hasDevices())
    {
        m_devices_syncing_queue.clear();
        m_devices_syncing.clear();

        // Start sync (if necessary)
        for (int i = 0; i < m_devices_model->rowCount(); i++)
        {
            QModelIndex e = m_devices_filter->index(i, 0);
            Device *dd = qvariant_cast<Device *>(m_devices_filter->data(e, DeviceModel::PointerRole));

            if (dd)
            {
                if (!(dd->getName() == "Flower care" || dd->getName() == "ThermoBeacon")) continue;

                if (dd->getLastHistorySync_int() < 0 || dd->getLastHistorySync_int() > 6*60*60)
                {
                    // old or no data: go for refresh
                    m_devices_syncing_queue.push_back(dd);
                    dd->refreshQueue();
                }
            }
        }

        syncDevices_continue();
    }
}

void DeviceManager::syncDevices_start()
{
    //qDebug() << "DeviceManager::syncDevices_start()";

    // Already syncing?
    if (isSyncing())
    {
        // Here we can:             // > do nothing, and queue another sync
        //syncDevices_stop();       // > (or) cancel current sync
        return;                     // > (or) bail
    }

    // Make sure we have Bluetooth and devices
    if (checkBluetooth() && m_devices_model->hasDevices())
    {
        m_devices_syncing_queue.clear();
        m_devices_syncing.clear();

        // Start sync (if necessary)
        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd)
            {
                if (!(dd->getName() == "Flower care" || dd->getName() == "ThermoBeacon")) continue;

                if (dd->getLastHistorySync_int() < 0 || dd->getLastHistorySync_int() > 6*60*60)
                {
                    m_devices_syncing_queue.push_back(dd);
                    dd->refreshQueue();
                }
            }
        }

        syncDevices_continue();
    }
}

void DeviceManager::syncDevices_continue()
{
    //qDebug() << "DeviceManager::syncDevices_continue()" << m_devices_syncing_queue.size() << "device left";

    if (hasBluetooth())
    {
        if (!m_devices_syncing_queue.empty())
        {
            int sim = 1;

            while (!m_devices_syncing_queue.empty() && m_devices_syncing.size() < sim)
            {
                // update next device in the list
                Device *d = qobject_cast<Device*>(m_devices_syncing_queue.first());
                if (d)
                {
                    m_devices_syncing_queue.removeFirst();
                    m_devices_syncing.push_back(d);
                    if (!m_syncing)
                    {
                        m_syncing = true;
                        Q_EMIT syncingChanged();
                    }

                    d->refreshStartHistory();
                }
            }
        }
    }

    if (m_devices_syncing_queue.empty() && m_devices_syncing.empty())
    {
        if (m_syncing)
        {
            m_syncing = false;
            Q_EMIT syncingChanged();
        }
    }
}

void DeviceManager::syncDevices_finished(Device *dev)
{
    //qDebug() << "DeviceManager::syncDevices_finished()" << dev->getAddress();

    if (m_devices_syncing.contains(dev))
    {
        m_devices_syncing.removeAll(dev);

        // sync next device in the list
        syncDevices_continue();
    }
}

void DeviceManager::syncDevices_stop()
{
    //qDebug() << "DeviceManager::syncDevices_stop()";

    if (!m_devices_syncing_queue.empty())
    {
        for (auto d: qAsConst(m_devices_syncing))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd) dd->refreshStop();
        }

        m_devices_syncing_queue.clear();
        m_devices_syncing.clear();
        m_updating = false;

        Q_EMIT syncingChanged();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::blacklistBleDevice(const QString &addr)
{
    qDebug() << "DeviceManager::blacklistBleDevice(" << addr << ")";

    if (m_dbInternal || m_dbExternal)
    {
        // if
        QSqlQuery queryDevice;
        queryDevice.prepare("SELECT deviceAddr FROM devicesBlacklist WHERE deviceAddr = :deviceAddr");
        queryDevice.bindValue(":deviceAddr", addr);
        queryDevice.exec();

        // then
        if (queryDevice.last() == false)
        {
            qDebug() << "+ Blacklisting device: " << addr;

            QSqlQuery blacklistDevice;
            blacklistDevice.prepare("INSERT INTO devicesBlacklist (deviceAddr) VALUES (:deviceAddr)");
            blacklistDevice.bindValue(":deviceAddr", addr);

            if (blacklistDevice.exec() == true)
            {
                m_devices_blacklist.push_back(addr);
                Q_EMIT devicesBlacklistUpdated();
            }
        }
    }
}

void DeviceManager::whitelistBleDevice(const QString &addr)
{
    qDebug() << "DeviceManager::whitelistBleDevice(" << addr << ")";

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery whitelistDevice;
        whitelistDevice.prepare("DELETE FROM devicesBlacklist WHERE deviceAddr = :deviceAddr");
        whitelistDevice.bindValue(":deviceAddr", addr);

        if (whitelistDevice.exec() == true)
        {
            m_devices_blacklist.removeAll(addr);
            Q_EMIT devicesBlacklistUpdated();
        }
    }
}

bool DeviceManager::isBleDeviceBlacklisted(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        // if
        QSqlQuery queryDevice;
        queryDevice.prepare("SELECT deviceAddr FROM devicesBlacklist WHERE deviceAddr = :deviceAddr");
        queryDevice.bindValue(":deviceAddr", addr);
        queryDevice.exec();

        // then
        return queryDevice.last();
    }

    return false;
}

/* ************************************************************************** */

void DeviceManager::addBleDevice(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "DeviceManager::addBleDevice()" << " > NAME" << info.name() << " > RSSI" << info.rssi();

    if (info.rssi() >= 0) return; // we probably just hit the device cache
    if (m_devices_blacklist.contains(info.address().toString()))return; // device is blacklisted

    SettingsManager *sm = SettingsManager::getInstance();
    if (sm && sm->getBluetoothLimitScanningRange() && info.rssi() < -70) return; // device is too far away

    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)
    {
        if (info.name() == "Flower care" || info.name() == "Flower mate" || info.name() == "Grow care garden" ||
            info.name().startsWith("Flower power") ||
            info.name().startsWith("Parrot pot") ||
            info.name() == "ropot" ||
            info.name() == "MJ_HT_V1" ||
            info.name() == "ClearGrass Temp & RH" ||
            info.name() == "Qingping Temp RH Lite" ||
            info.name() == "LYWSD02" || info.name() == "MHO-C303" ||
            info.name() == "LYWSD03MMC" || info.name() == "MHO-C401" ||
            info.name() == "ThermoBeacon" ||
            info.name().startsWith("6003#") ||
            info.name() == "AirQualityMonitor" ||
            info.name() == "GeigerCounter" ||
            info.name() == "HiGrow")
        {
            // Check if it's not already in the UI
            for (auto ed: qAsConst(m_devices_model->m_devices))
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
            Device *d = nullptr;

            if (info.name() == "Flower care" || info.name() == "Flower mate" || info.name() == "Grow care garden")
                d = new DeviceFlowerCare(info, this);
            else if (info.name() == "ropot")
                d = new DeviceRopot(info, this);
            else if (info.name().startsWith("Flower power"))
                d = new DeviceFlowerPower(info, this);
            else if (info.name().startsWith("Parrot pot"))
                d = new DeviceParrotPot(info, this);
            else if (info.name() == "HiGrow")
                d = new DeviceEsp32HiGrow(info, this);
            else if (info.name() == "MJ_HT_V1")
                d = new DeviceHygrotempLCD(info, this);
            else if (info.name() == "ClearGrass Temp & RH")
                d = new DeviceHygrotempCGG1(info, this);
            else if (info.name() == "Qingping Temp RH Lite")
                d = new DeviceHygrotempCGDK2(info, this);
            else if (info.name() == "LYWSD02" || info.name() == "MHO-C303")
                d = new DeviceHygrotempClock(info, this);
            else if (info.name() == "LYWSD03MMC" || info.name() == "MHO-C401")
                d = new DeviceHygrotempSquare(info, this);
            else if (info.name() == "ThermoBeacon")
                d = new DeviceThermoBeacon(info, this);
            else if (info.name().startsWith("6003#"))
                d = new DeviceWP6003(info, this);
            else if (info.name() == "AirQualityMonitor")
                d = new DeviceEsp32AirQualityMonitor(info, this);
            else if (info.name() == "GeigerCounter")
                d = new DeviceEsp32GeigerCounter(info, this);

            if (!d) return;

            connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);

            SettingsManager *sm = SettingsManager::getInstance();
            if (d->getLastUpdateInt() < 0 ||
                d->getLastUpdateInt() > (int)(d->isPlantSensor() ? sm->getUpdateIntervalPlant() : sm->getUpdateIntervalThermo()))
            {
                // Old or no data: mark it as queued until the deviceManager sync new devices
                d->refreshQueue();
            }

            // Add it to the database?
            if (m_dbInternal || m_dbExternal)
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
            m_devices_model->addDevice(d);
            Q_EMIT devicesListUpdated();

            qDebug() << "Device added (from BLE discovery): " << d->getName() << "/" << d->getAddress();

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
            // try to get the MAC address immediately
            updateBleDevice(info, 0);
#endif
        }
        else
        {
            //qDebug() << "Unsupported device: " << info.name() << "/" << info.address();
        }
    }
}

void DeviceManager::removeDevice(const QString &address)
{
    for (auto d: qAsConst(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);

        if (dd->getAddress() == address)
        {
            qDebug() << "- Removing device: " << dd->getName() << "/" << dd->getAddress() << "from local database";

            // Make sure its not being used
            disconnect(dd, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
            dd->refreshStop();
            refreshDevices_finished(dd);

            // Remove from database // Don't remove the actual data, nor the limits
            if (m_dbInternal || m_dbExternal)
            {
                QSqlQuery removeDevice;
                removeDevice.prepare("DELETE FROM devices WHERE deviceAddr = :deviceAddr");
                removeDevice.bindValue(":deviceAddr", dd->getAddress());
                if (removeDevice.exec() == false)
                    qWarning() << "> removeDevice.exec() ERROR" << removeDevice.lastError().type() << ":" << removeDevice.lastError().text();
            }

            // Remove device
            m_devices_model->removeDevice(dd);
            Q_EMIT devicesListUpdated();

            break;
        }
    }
}

void DeviceManager::removeDeviceData(const QString &address)
{
    for (auto d: qAsConst(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);

        if (dd->getAddress() == address)
        {
            qDebug() << "- Removing device data: " << dd->getName() << "/" << dd->getAddress() << "from local database";

            // Remove the actual data & limits
            if (m_dbInternal || m_dbExternal)
            {
                // TODO
            }

            break;
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::exportDataSave()
{
    bool status = false;

    if (!m_devices_model->hasDevices()) return status;

    QString exportDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/WatchFlower";

    // Create exportDirectory
    if (!exportDirectoryPath.isEmpty())
    {
        QDir exportDirectory(exportDirectoryPath);

        // check if directory creation is needed
        if (!exportDirectory.exists())
        {
            exportDirectory.mkpath(exportDirectoryPath);
        }
        // retry
        if (exportDirectory.exists())
        {
            // Get file name
            QString exportFilePath = exportDirectoryPath;
            exportFilePath += "/watchflower_";
            exportFilePath += QDateTime::currentDateTime().toString("yyyy-MM-dd");
            exportFilePath += ".csv";

            if (exportData(exportFilePath))
            {
                status = true;
            }
            else
            {
                status = false;
            }
        }
        else
        {
            qWarning() << "DeviceManager::exportDataSave() cannot create export directory";
            status = false;
        }
    }
    else
    {
        qWarning() << "DeviceManager::exportDataSave() invalid export directory";
        status = false;
    }

    return status;
}

/* ************************************************************************** */

QString DeviceManager::exportDataOpen()
{
    QString exportFilePath;

    if (!m_devices_model->hasDevices()) return exportFilePath;

    // Get temp directory path
    QString exportDirectoryPath = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);

    QDir exportDirectory(exportDirectoryPath + "/export");
    if (!exportDirectory.exists()) exportDirectory.mkpath(exportDirectoryPath + "/export");

    // Get temp file path
    exportFilePath = exportDirectoryPath + "/export/watchflower_" + QDateTime::currentDateTime().toString("yyyy-MM-dd") + ".csv";

    if (exportData(exportFilePath))
    {
        return exportFilePath;
    }

    return QString();
}

QString DeviceManager::exportDataFolder()
{
    // Get temp directory path
    QString exportDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/WatchFlower";

    // check if directory exist
    QDir exportDirectory(exportDirectoryPath);
    if (exportDirectory.exists())
    {
        return exportDirectoryPath;
    }

    return QString();
}

/* ************************************************************************** */

bool DeviceManager::exportData(const QString &exportFilePath)
{
    bool status = false;

    if (!m_devices_model->hasDevices()) return status;
    if (!m_dbInternal && !m_dbExternal) return status;

    SettingsManager *sm = SettingsManager::getInstance();
    bool isCelcius = (sm->getTempUnit() == "C");

    QFile efile;
    efile.setFileName(exportFilePath);
    if (efile.open(QIODevice::WriteOnly))
    {
        status = true;
        QTextStream eout(&efile);

        QString legend = "Timestamp (YYYY-MM-DD hh:mm:ss), Soil moisture (%), Soil conductivity (μs/cm), Temperature (";
        legend += (isCelcius ? "℃" : "℉");
        legend += "), Humidity (%RH), Luminosity (lux)";
        eout << legend << Qt::endl;

        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd)
            {
                QString l = "> " + dd->getName() + " (" + dd->getAddress() + ")";
                eout << l << Qt::endl;

                QSqlQuery data;
                if (m_dbInternal) // sqlite
                {
                    data.prepare("SELECT ts_full, soilMoisture, soilConductivity, soilTemperature, temperature, humidity, luminosity " \
                                 "FROM plantData " \
                                 "WHERE deviceAddr = :deviceAddr AND ts_full >= datetime('now', 'localtime', '-" + QString::number(90) + " days');");
                }
                else if (m_dbExternal) // mysql
                {
                    data.prepare("SELECT ts_full, soilMoisture, soilConductivity, soilTemperature, temperature, humidity, luminosity " \
                                 "FROM plantData " \
                                 "WHERE deviceAddr = :deviceAddr AND ts_full >= DATE_SUB(NOW(), INTERVAL " + QString::number(90) + " DAY);");
                }
                data.bindValue(":deviceAddr", dd->getAddress());

                if (data.exec() == true)
                {
                    while (data.next())
                    {
                        eout << data.value(0).toString() << ",";

                        if (dd->hasSoilMoistureSensor()) eout<< data.value(1).toString();
                        eout << ",";

                        if (dd->hasSoilConductivitySensor()) eout << data.value(2).toString();
                        eout << ",";

                        if (isCelcius) eout << QString::number(data.value(4).toReal(), 'f', 1);
                        else eout << QString::number(data.value(4).toReal()* 1.8 + 32.0, 'f', 1);
                        eout << ",";

                        if (dd->hasHumiditySensor()) eout << data.value(5).toString();
                        eout << ",";

                        if (dd->hasLuminositySensor()) eout << data.value(6).toString();
                        eout << ",";

                        eout << Qt::endl;
                    }
                }
            }
        }

        efile.close();
    }
    else
    {
        qWarning() << "DeviceManager::exportData() cannot open export file: " << exportFilePath;
        status = false;
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::invalidate()
{
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_manual()
{
    m_devices_filter->setSortRole(DeviceModel::DeviceModelRole);
    m_devices_filter->sort(0, Qt::AscendingOrder);
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_model()
{
    m_devices_filter->setSortRole(DeviceModel::DeviceModelRole);
    m_devices_filter->sort(0, Qt::AscendingOrder);
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_name()
{
    m_devices_filter->setSortRole(DeviceModel::DeviceNameRole);
    m_devices_filter->sort(0, Qt::AscendingOrder);
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_location()
{
    m_devices_filter->setSortRole(DeviceModel::AssociatedLocationRole);
    m_devices_filter->sort(0, Qt::AscendingOrder);
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_waterlevel()
{
    m_devices_filter->setSortRole(DeviceModel::SoilMoistureRole);
    m_devices_filter->sort(0, Qt::AscendingOrder);
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_plant()
{
    m_devices_filter->setSortRole(DeviceModel::PlantNameRole);
    m_devices_filter->sort(0, Qt::AscendingOrder);
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_insideoutside()
{
    m_devices_filter->setSortRole(DeviceModel::InsideOutsideRole);
    m_devices_filter->sort(0, Qt::AscendingOrder);
    m_devices_filter->invalidate();
}

/* ************************************************************************** */
