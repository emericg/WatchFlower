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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DeviceManager.h"
#include "DatabaseManager.h"
#include "SettingsManager.h"

#if defined(Q_OS_ANDROID)
#include "utils_app.h"
#endif

#include "device.h"
#include "devices/device_flowercare.h"
#include "devices/device_flowercare_tuya.h"
#include "devices/device_flowerpower.h"
#include "devices/device_parrotpot.h"
#include "devices/device_ropot.h"
#include "devices/device_bparasite.h"
#include "devices/device_hygrotemp_atc.h"
#include "devices/device_hygrotemp_cgd1.h"
#include "devices/device_hygrotemp_cgdk2.h"
#include "devices/device_hygrotemp_cgg1.h"
#include "devices/device_hygrotemp_cgp1w.h"
#include "devices/device_hygrotemp_clock.h"
#include "devices/device_hygrotemp_square.h"
#include "devices/device_hygrotemp_lywsdcgq.h"
#include "devices/device_thermobeacon.h"
#include "devices/device_cgdn1.h"
#include "devices/device_jqjcy01ym.h"
#include "devices/device_wp6003.h"
#include "devices/device_esp32_airqualitymonitor.h"
#include "devices/device_esp32_higrow.h"
#include "devices/device_esp32_geigercounter.h"

#include <thread>
#include <chrono>

#include <QCoreApplication>
#include <QDateTime>
#include <QList>
#include <QDebug>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlQuery>
#include <QSqlError>

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
#if QT_CONFIG(permissions)
#include <QGuiApplication>
#include <QPermissions>
#endif
#endif

/* ************************************************************************** */

DeviceManager::DeviceManager(bool daemon)
{
    m_daemonMode = daemon;

    // Data model init (unified)
    m_devices_model = new DeviceModel(this);
    m_devices_filter = new DeviceFilter(this);
    m_devices_filter->setSourceModel(m_devices_model);
    m_devices_filter->setDynamicSortFilter(true);

    // Data model init (split)
    m_devicesPlant_model = new DeviceModel(this);
    m_devicesPlant_filter = new DeviceFilter(this);
    m_devicesPlant_filter->setSourceModel(m_devicesPlant_model);
    m_devicesThermo_model = new DeviceModel(this);
    m_devicesThermo_filter = new DeviceFilter(this);
    m_devicesThermo_filter->setSourceModel(m_devicesThermo_model);
    m_devicesEnv_model = new DeviceModel(this);
    m_devicesEnv_filter = new DeviceFilter(this);
    m_devicesEnv_filter->setSourceModel(m_devicesEnv_model);

    // Data model filtering
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
    enableBluetooth(true); // Enables adapter // ONLY if off and permission given
    connect(this, &DeviceManager::bluetoothChanged, this, &DeviceManager::bluetoothStatusChanged);

    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    if (m_dbInternal || m_dbExternal)
    {
        // Load device blacklist
        if (!m_daemonMode)
        {
            QSqlQuery queryBlacklist;
            queryBlacklist.exec("SELECT deviceAddr FROM devicesBlacklist");
            while (queryBlacklist.next())
            {
                m_devices_blacklist.push_back(queryBlacklist.value(0).toString());
            }
        }

        // Load saved devices
        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceModel, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            //QString deviceModel = queryDevices.value(1).toString();
            QString deviceAddr = queryDevices.value(2).toString();

            Device *d = nullptr;

            if (deviceName == "Flower care" || deviceName == "Flower mate" || deviceName == "Grow care garden")
                d = new DeviceFlowerCare(deviceAddr, deviceName, this);
            else if (deviceName == "TY")
                d = new DeviceFlowerCare_tuya(deviceAddr, deviceName, this);
            else if (deviceName == "ropot")
                d = new DeviceRopot(deviceAddr, deviceName, this);
            else if (deviceName.startsWith("Flower power"))
                d = new DeviceFlowerPower(deviceAddr, deviceName, this);
            else if (deviceName.startsWith("Parrot pot"))
                d = new DeviceParrotPot(deviceAddr, deviceName, this);
            else if (deviceName == "bparasite")
                d = new DeviceBParasite(deviceAddr, deviceName, this);
            else if (deviceName == "HiGrow")
                d = new DeviceEsp32HiGrow(deviceAddr, deviceName, this);

            else if (deviceName == "ThermoBeacon")
                d = new DeviceThermoBeacon(deviceAddr, deviceName, this);
            else if (deviceName == "MJ_HT_V1")
                d = new DeviceHygrotempLYWSDCGQ(deviceAddr, deviceName, this);
            else if (deviceName == "LYWSD02" || deviceName == "MHO-C303")
                d = new DeviceHygrotempClock(deviceAddr, deviceName, this);
            else if (deviceName == "LYWSD03MMC" || deviceName == "MHO-C401" ||
                     deviceName == "XMWSDJO4MMC" || deviceName == "MJWSD05MMC")
                d = new DeviceHygrotempSquare(deviceAddr, deviceName, this);
            else if (deviceName == "ClearGrass Temp & RH" || deviceName == "Qingping Temp & RH M")
                d = new DeviceHygrotempCGG1(deviceAddr, deviceName, this);
            else if (deviceName == "Qingping Temp RH Lite")
                d = new DeviceHygrotempCGDK2(deviceAddr, deviceName, this);
            else if (deviceName == "Qingping Alarm Clock")
                d = new DeviceHygrotempCGD1(deviceAddr, deviceName, this);
            else if (deviceName == "Qingping Temp RH Barometer")
                d = new DeviceHygrotempCGP1W(deviceAddr, deviceName, this);
            else if (deviceName == "ATC")
                d = new DeviceHygrotempATC(deviceAddr, deviceName, this);

            else if (deviceName.startsWith("WP6003"))
                d = new DeviceWP6003(deviceAddr, deviceName, this);
            else if (deviceName == "Qingping Air Monitor Lite")
                d = new DeviceCGDN1(deviceAddr, deviceName, this);
            else if (deviceName == "JQJCY01YM")
                d = new DeviceJQJCY01YM(deviceAddr, deviceName, this);
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

                if (d->isPlantSensor())
                {
                    m_devicesPlant_model->addDevice(d);
                }
                else if (d->isThermometer())
                {
                    m_devicesThermo_model->addDevice(d);
                }
                else if (d->isEnvironmentalSensor())
                {
                    m_devicesEnv_model->addDevice(d);
                }
            }
        }
    }

#if defined(Q_OS_LINUX) || defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)
    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &DeviceManager::refreshDevices_check);
    m_updateTimer.setInterval(30*60*1000); // every 30m
    m_updateTimer.start();
#endif
}

DeviceManager::~DeviceManager()
{
    qDeleteAll(m_bluetoothAdapters);
    m_bluetoothAdapters.clear();

    delete m_bluetoothAdapter;
    delete m_discoveryAgent;

    delete m_devices_nearby_filter;
    delete m_devices_nearby_model;

    delete m_devices_filter;
    delete m_devices_model;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::areDevicesConnected() const
{
    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        if (d && d->isConnected())
        {
            return true;
        }
    }

    qDebug() << "DeviceManager::areDevicesConnected() FALSE";

    return false;
}

void DeviceManager::disconnectDevices() const
{
    qDebug() << "DeviceManager::disconnectDevices()";

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);
        dd->actionDisconnect();
    }
}

void DeviceManager::disconnectAndExit() const
{
    if (areDevicesConnected())
    {
        qDebug() << "DeviceManager::disconnectAndExit()";

        disconnectDevices();

        int timeout = 60;

        while (areDevicesConnected() && timeout > 0)
        {
            qApp->processEvents();
            std::this_thread::sleep_for(std::chrono::milliseconds(33));
            timeout--;
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::isUpdating() const
{
    return !m_devices_updating.empty();
}

bool DeviceManager::isSyncing() const
{
    return !m_devices_syncing.empty();
}

/* ************************************************************************** */

bool DeviceManager::checkBluetooth()
{
    //qDebug() << "DeviceManager::checkBluetooth()";

#if defined(Q_OS_IOS)
    // at this point we don't actually try to use checkBluetoothIOS() or we will
    // be caugth in a loop with the OS notifying the user that BLE wants to start
    // but is off, then giving back the focus to the app, thus calling checkBluetooth()...
    return m_bleEnabled;
#endif

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermissions;

    // Check adapter availability
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_bleAdapter = true;

        if (m_bluetoothAdapter->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            m_bleEnabled = true;
        }
        else
        {
            m_bleEnabled = false;
            qDebug() << "Bluetooth adapter host mode:" << m_bluetoothAdapter->hostMode();
        }
    }
    else
    {
        m_bleAdapter = false;
        m_bleEnabled = false;
    }

    // Check OS permissions
    checkBluetoothPermissions();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermissions)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    return (m_bleAdapter && m_bleEnabled && m_blePermissions);
}

bool DeviceManager::enableBluetooth(bool enforceUserPermissionCheck)
{
    //qDebug() << "DeviceManager::enableBluetooth() enforce:" << enforceUserPermissionCheck;

#if defined(Q_OS_IOS)
    checkBluetoothIOS();
    return false;
#endif

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermissions;

    // Invalid adapter? (ex: plugged off)
    if (m_bluetoothAdapter && !m_bluetoothAdapter->isValid())
    {
        qDebug() << "DeviceManager::enableBluetooth() deleting current adapter";

        disconnect(m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged,
                   this, &DeviceManager::bluetoothHostModeStateChanged);

        delete m_bluetoothAdapter;
        m_bluetoothAdapter = nullptr;
    }

    // Select an adapter (if none currently selected)
    if (!m_bluetoothAdapter)
    {
        // Correspond to the "first available" or "default" Bluetooth adapter
        m_bluetoothAdapter = new QBluetoothLocalDevice();
        if (m_bluetoothAdapter)
        {
            // Keep us informed of Bluetooth adapter state change
            // On some platform, this can only inform us about disconnection, not reconnection
            connect(m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged,
                    this, &DeviceManager::bluetoothHostModeStateChanged);
        }
    }

    // Check adapter availability
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_bleAdapter = true;

        if (m_bluetoothAdapter->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            // Was already activated
            m_bleEnabled = true;
        }
        else
        {
            // Try to activate the adapter

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
        qWarning() << "DeviceManager::enableBluetooth() we have an invalid adapter";
        m_bleAdapter = false;
        m_bleEnabled = false;
    }

    //qDebug() << "DeviceManager::enableBluetooth() recap";
    //qDebug() << " - bluetooth" << hasBluetooth();
    //qDebug() << " - bleAdapter" << m_bleAdapter;
    //qDebug() << " - bleEnabled" << m_bleEnabled;
    //qDebug() << " - blePermissions" << m_blePermissions;

    // Check OS permissions
    checkBluetoothPermissions();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermissions)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    return (m_bleAdapter && m_bleEnabled && m_blePermissions);
}

bool DeviceManager::checkBluetoothPermissions()
{
    //qDebug() << "DeviceManager::checkBluetoothPermissions()";

#if defined(Q_OS_ANDROID)
    //
#elif defined(Q_OS_LINUX) || defined(Q_OS_WINDOWS)
    // These OS don't ask for any particular permissions
    m_permOS = true;
    m_blePermissions = true;
#endif

#if !defined(Q_OS_ANDROID)
    // The location permission(s) debacle is Android only
    m_permLocationBLE = true;
    m_permLocationBKG = true;
    m_permGPS = true;
#endif

    bool os_was = m_permOS;
    bool loc_was = m_permLocationBLE;
    bool loc_bg_was = m_permLocationBKG;
    bool gps_was = m_permGPS;
    bool btP_was = m_blePermissions;

#if defined(Q_OS_ANDROID)
    m_permOS = UtilsApp::checkMobileBluetoothPermission();
    m_permLocationBLE = UtilsApp::checkMobileBleLocationPermission();
    m_permLocationBKG = UtilsApp::checkMobileBackgroundLocationPermission();
    m_permGPS = UtilsApp::isMobileGpsEnabled();

    m_blePermissions = m_permOS && m_permLocationBLE;
#endif

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
#if QT_CONFIG(permissions)
    if (qApp)
    {
        switch (qApp->checkPermission(QBluetoothPermission{}))
        {
        case Qt::PermissionStatus::Undetermined:
        case Qt::PermissionStatus::Denied:
            m_permOS = false;
            m_blePermissions = false;
            break;
        case Qt::PermissionStatus::Granted:
            m_permOS = true;
            m_blePermissions = true;
            break;
        }
    }
#endif // QT_CONFIG(permissions)
#endif // defined(Q_OS_MACOS) || defined(Q_OS_IOS)

    if (os_was != m_permOS || gps_was != m_permGPS ||
        loc_was != m_permLocationBLE || loc_bg_was != m_permLocationBKG)
    {
        // this function did change the Bluetooth permission
        Q_EMIT permissionsChanged();
    }
    if (btP_was != m_blePermissions)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    //qDebug() << "DeviceManager::checkBluetoothPermissions() recap";
    //qDebug() << " - bluetooth" << hasBluetooth();
    //qDebug() << " - bleAdapter" << m_bleAdapter;
    //qDebug() << " - bleEnabled" << m_bleEnabled;
    //qDebug() << " - blePermissions" << m_blePermissions;
    //qDebug() << " - permOS" << m_permOS;
    //qDebug() << " - permLocationBLE" << m_permLocationBLE;
    //qDebug() << " - permLocationBKG" << m_permLocationBKG;
    //qDebug() << " - permGPS" << m_permGPS;

    return m_blePermissions;
}

bool DeviceManager::requestBluetoothPermissions()
{
    //qDebug() << "DeviceManager::requestBluetoothPermissions()";

#if defined(Q_OS_ANDROID)
#if QT_CONFIG(permissions) && QT_VERSION >= QT_VERSION_CHECK(6, 6, 0)

    // qApp->checkPermission(QBluetoothPermission{}) doesn't work on Android
    // so we do it ourselves, the old fashioned way...

    bool permLocationBLE = UtilsApp::checkMobileBleLocationPermission();
    bool permOS = UtilsApp::checkMobileBluetoothPermission();

    if (!permLocationBLE || !permOS)
    {
        if (qApp)
        {
            qApp->requestPermission(QBluetoothPermission{}, this, &DeviceManager::requestBluetoothPermissions_results);
        }
    }

#else // QT_CONFIG(permissions)

    m_permOS = UtilsApp::getMobileBluetoothPermission();
    m_permLocationBLE = UtilsApp::getMobileBleLocationPermission();
    m_blePermissions = m_permOS && m_permLocationBLE;

#endif // QT_CONFIG(permissions)
#endif // defined(Q_OS_ANDROID)

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
#if QT_CONFIG(permissions)

    if (qApp)
    {
        switch (qApp->checkPermission(QBluetoothPermission{}))
        {
        case Qt::PermissionStatus::Undetermined:
            qDebug() << "Qt::PermissionStatus::Undetermined";
            qApp->requestPermission(QBluetoothPermission{}, this, &DeviceManager::requestBluetoothPermissions_results);
            break;
        case Qt::PermissionStatus::Granted:
            qDebug() << "Qt::PermissionStatus::Granted";
            m_permOS = true;
            m_blePermissions = true;
            break;
        case Qt::PermissionStatus::Denied:
            qDebug() << "Qt::PermissionStatus::Denied";
            m_permOS = false;
            m_blePermissions = false;
            break;
        }
    }

#endif // QT_CONFIG(permissions)
#endif // defined(Q_OS_MACOS) || defined(Q_OS_IOS)

    //qDebug() << "DeviceManager::requestBluetoothPermissions() recap";
    //qDebug() << " - bluetooth" << hasBluetooth();
    //qDebug() << " - bleAdapter" << m_bleAdapter;
    //qDebug() << " - bleEnabled" << m_bleEnabled;
    //qDebug() << " - blePermissions" << m_blePermissions;
    //qDebug() << " - permOS" << m_permOS;
    //qDebug() << " - permLocationBLE" << m_permLocationBLE;
    //qDebug() << " - permLocationBKG" << m_permLocationBKG;
    //qDebug() << " - permGPS" << m_permGPS;

    return m_blePermissions;
}

void DeviceManager::requestBluetoothPermissions_results()
{
    // evaluate the results
#if defined(Q_OS_IOS)
    checkBluetoothPermissions();
#else
    checkBluetooth();
#endif

    if (m_blePermissions)
    {
        // try enabling the adapter
        if (!m_bleAdapter || !m_bleEnabled)
        {
            enableBluetooth();
        }
    }
    else
    {
        // try again?
        //requestBluetoothPermissions();
    }
}

/* ************************************************************************** */

void DeviceManager::bluetoothHostModeStateChanged(QBluetoothLocalDevice::HostMode state)
{
    //qDebug() << "DeviceManager::bluetoothHostModeStateChanged() host mode now:" << state;

    if (state != m_ble_hostmode)
    {
        m_ble_hostmode = state;
        Q_EMIT hostModeChanged();
    }

    if (state > QBluetoothLocalDevice::HostPoweredOff)
    {
        m_bleEnabled = true;
    }
    else
    {
        m_bleEnabled = false;
    }

    Q_EMIT bluetoothChanged();
}

void DeviceManager::bluetoothStatusChanged()
{
    //qDebug() << "DeviceManager::bluetoothStatusChanged() bt adapter:" << m_bleAdapter << " /  bt enabled:" << m_bleEnabled;

    if (m_bleAdapter && m_bleEnabled)
    {
        // Bluetooth enabled, re/start listening
        if (m_devices_model->hasDevices())
        {
            refreshDevices_listen();
        }
        else
        {
            // start scanning?
            //scanDevices_start();
        }
    }
    else
    {
        // Bluetooth disabled, force disconnection
        refreshDevices_stop();
    }
}

void DeviceManager::bluetoothPermissionsChanged()
{
    //qDebug() << "DeviceManager::bluetoothPermissionsChanged()";

    if (m_bleAdapter && m_bleEnabled)
    {
        checkBluetooth();
    }
    else
    {
        enableBluetooth();
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
            //qDebug() << "Scanning method supported:" << m_discoveryAgent->supportedDiscoveryMethods();

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred,
                    this, &DeviceManager::deviceDiscoveryError);
        }
        else
        {
            qWarning() << "Unable to create BLE discovery agent...";
        }
    }
}

void DeviceManager::checkBluetoothIOS()
{
    //qDebug() << "DeviceManager::checkBluetoothIOS()";

    // iOS behave differently than all other platforms; there is no way to check
    // adapter status, we can only to start a device discovery and check if it fails

    // the thing is, when the discovery is started with the BLE adapter turned off,
    // it will actually take up to 30s to report that fact... so after a short while,
    // we check on our own if the discovery agent is still running or not using a timer

    // when the BLE adapter is turned off while the discovery is already running,
    // the error is reported instantly though

    m_bleAdapter = true; // there is no iOS device without a BLE adapter

    m_permOS = true; // TODO
    m_blePermissions = m_permOS;

    // not necessary on iOS // set everything to true
    m_permLocationBLE = true;
    m_permLocationBKG = true;
    m_permGPS = true;

    if (!m_discoveryAgent)
    {
        startBleAgent();
    }
    if (m_discoveryAgent)
    {
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::bleDevice_discovered);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::bleDevice_updated);

        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addBleDeviceNearby);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::bleDeviceNearby_discovered);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::bleDeviceNearby_updated);

        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                this, &DeviceManager::deviceDiscoveryFinished, Qt::UniqueConnection);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

        m_discoveryAgent->setLowEnergyDiscoveryTimeout(8); // 8ms
        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

        if (m_discoveryAgent->isActive())
        {
            qDebug() << "Checking iOS Bluetooth...";

            // this ensure no other function will be able to use the discovery agent while this check is running
            m_checking_ios_ble = true;
            m_bleEnabled = false;

            // this ensure that we catch error as soon as possible (~333ms) and not ~30s later when the OS think we should know
            connect(&m_checking_ios_timer, &QTimer::timeout, this,
                    &DeviceManager::deviceDiscoveryErrorIOS, Qt::UniqueConnection);
            m_checking_ios_timer.setSingleShot(true);
            m_checking_ios_timer.start(333);
        }
    }
}

void DeviceManager::deviceDiscoveryErrorIOS()
{
    //qDebug() << "DeviceManager::deviceDiscoveryErrorIOS()";

    if (m_discoveryAgent) m_discoveryAgent->stop();
    m_checking_ios_ble = false;

    if (m_bleEnabled)
    {
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }
}

void DeviceManager::deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error <= QBluetoothDeviceDiscoveryAgent::NoError) return;

    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
    {
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";

        if (m_bleEnabled)
        {
            m_bleEnabled = false;
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        m_bleAdapter = false;

        if (m_bleEnabled)
        {
            m_bleEnabled = false;
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Platform.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";

        m_bleEnabled = false;
        m_blePermissions = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::LocationServiceTurnedOffError)
    {
        qWarning() << "deviceDiscoveryError() Location Service Turned Off Error.";

        m_bleEnabled = false;
        m_blePermissions = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::MissingPermissionsError)
    {
        qWarning() << "deviceDiscoveryError() Missing Permissions Error.";

        m_bleEnabled = false;
        m_blePermissions = false;
        Q_EMIT bluetoothChanged();
    }
    else
    {
        qWarning() << "An unknown error has occurred.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }

    listenDevices_stop();
    refreshDevices_stop();
    scanDevices_stop();

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

void DeviceManager::deviceDiscoveryFinished()
{
    //qDebug() << "DeviceManager::deviceDiscoveryFinished()";

#if defined(Q_OS_IOS)
    if (m_checking_ios_ble)
    {
        m_checking_ios_ble = false;
        m_checking_ios_timer.stop();

        if (!m_bleEnabled)
        {
            m_bleEnabled = true;
            Q_EMIT bluetoothChanged();
        }
    }
#endif

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

void DeviceManager::deviceDiscoveryStopped()
{
    qDebug() << "DeviceManager::deviceDiscoveryStopped()";
}

/* ************************************************************************** */

void DeviceManager::setLastRun()
{
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery setLastRun;
        setLastRun.prepare("UPDATE lastRun SET lastRun = :run");
        setLastRun.bindValue(":run", QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss"));

        if (setLastRun.exec())
        {
            if (setLastRun.numRowsAffected() == 0)
            {
                // addLastRun?
            }
        }
        else
        {
            qWarning() << "> setLastRun.exec() ERROR"
                       << setLastRun.lastError().type() << ":" << setLastRun.lastError().text();
        }
    }
}

int DeviceManager::getLastRun_s()
{
    int mins = -1;

    QSqlQuery getLastRun;
    getLastRun.prepare("SELECT lastRun FROM lastRun");

    if (getLastRun.exec())
    {
        if (getLastRun.first())
        {
            QDateTime lastRun = getLastRun.value(0).toDateTime();
            if (lastRun.isValid())
            {
                mins = static_cast<int>(std::floor(lastRun.secsTo(QDateTime::currentDateTime()) / 60.0));
            }
        }
    }
    else
    {
        qWarning() << "> getLastRun.exec() ERROR"
                   << getLastRun.lastError().type() << ":" << getLastRun.lastError().text();
    }

    return mins;
}

int DeviceManager::getLastRun()
{
    if (m_dbInternal || m_dbExternal)
    {
        return getLastRun_s();
    }

    return -1;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::scanDevices_start()
{
    //qDebug() << "DeviceManager::scanDevices_start()";

    // scan
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
                           this, &DeviceManager::addBleDeviceNearby);
                disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                           this, &DeviceManager::bleDeviceNearby_discovered);
                disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                           this, &DeviceManager::bleDeviceNearby_updated);

                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                        this, &DeviceManager::addBleDevice, Qt::UniqueConnection);
                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                        this, &DeviceManager::bleDevice_discovered, Qt::UniqueConnection);
                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                        this, &DeviceManager::bleDevice_updated, Qt::UniqueConnection);

                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                        this, &DeviceManager::deviceDiscoveryFinished, Qt::UniqueConnection);
                connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                        this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

                // start scanning
                m_discoveryAgent->setLowEnergyDiscoveryTimeout(ble_scanning_duration*1000);
                m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

                if (m_discoveryAgent->isActive())
                {
                    m_scanning = true;
                    Q_EMIT scanningChanged();
                    qDebug() << "Scanning for new devices...";
                }
                else
                {
                    qWarning() << "DeviceManager::scanDevices_start() DID NOT START";
                }
            }
        }
    }
    else
    {
        qWarning() << "Cannot scan or listen without BLE or BLE permissions";
    }
}

void DeviceManager::scanDevices_stop()
{
    //qDebug() << "DeviceManager::scanDevices_stop()";

    if (m_discoveryAgent)
    {
        if (m_discoveryAgent->isActive())
        {
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                       this, &DeviceManager::addBleDevice);
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                       this, &DeviceManager::bleDevice_updated);

            m_discoveryAgent->stop();

            if (m_scanning)
            {
                m_scanning = false;
                Q_EMIT scanningChanged();
            }
        }
    }
}

/* ************************************************************************** */

void DeviceManager::listenDevices_start()
{
    //qDebug() << "DeviceManager::listenDevices_start()";

#if defined(Q_OS_ANDROID)
    // An Android service won't be able to scan/listen in the background without the associated permission
    if (m_daemonMode && !m_permLocationBKG) return;
#endif

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
                       this, &DeviceManager::addBleDeviceNearby);
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                       this, &DeviceManager::bleDeviceNearby_discovered);
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                       this, &DeviceManager::bleDeviceNearby_updated);

            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                       this, &DeviceManager::addBleDevice);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::bleDevice_discovered, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                    this, &DeviceManager::bleDevice_updated, Qt::UniqueConnection);

            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                       this, &DeviceManager::deviceDiscoveryFinished);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

            int duration = ble_listening_duration*1000;
            if (m_daemonMode) duration = ble_listening_duration_background*1000;

#if defined(Q_OS_ANDROID) && defined(QT_CONNECTIVITY_PATCHED)
            // Build and apply Android BLE scan filter, otherwise we can't scan while the screen is off
            // Needs a patched QtConnectivity (from https://github.com/emericg/qtconnectivity/tree/blescanfiltering_v1)
            if (m_daemonMode)
            {
                QStringList filteredAddr;
                for (auto d: std::as_const(m_devices_model->m_devices))
                {
                    Device *dd = qobject_cast<Device*>(d);
                    if (dd) filteredAddr += dd->getAddress();
                }
                m_discoveryAgent->setAndroidScanFilter(filteredAddr); // WIP
            }
#endif // Q_OS_ANDROID

            m_discoveryAgent->setLowEnergyDiscoveryTimeout(duration);
            m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

            if (m_discoveryAgent->isActive())
            {
                m_listening = true;
                Q_EMIT listeningChanged();
                //qDebug() << "Listening for BLE advertisement packets...";

                // Update lastRun
                setLastRun();
            }
            else
            {
                qWarning() << "DeviceManager::listenDevices_start() DID NOT START";
            }
        }
    }
    else
    {
        qWarning() << "Cannot scan or listen without BLE or BLE permissions";
    }
}

void DeviceManager::listenDevices_stop()
{
    //qDebug() << "DeviceManager::listenDevices_stop()";
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::updateDevice(const QString &address)
{
    //qDebug() << "DeviceManager::updateDevice() " << address;

    if (hasBluetooth())
    {
        for (auto d: std::as_const(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && dd->getAddress() == address &&
                dd->isEnabled() && dd->hasBluetoothConnection())
            {
                if (!m_devices_updating_queue.contains(dd) && !m_devices_updating.contains(dd))
                {
                    m_devices_updating_queue.push_back(dd);
                    dd->refreshQueued();
                    refreshDevices_continue();
                }
                break;
            }
        }
    }
}

void DeviceManager::refreshDevices_background()
{
    //qDebug() << "DeviceManager::refreshDevices_background()";

#if defined(Q_OS_ANDROID) && defined(QT_CONNECTIVITY_PATCHED)
    if (m_permLocationBKG)
    {
        /// Background refresh (using passive scanning)
        /// If patched QtConnectivity AND android.permission.ACCESS_BACKGROUND_LOCATION

        //UtilsLog::getInstance()->pushLog("(daemon) refreshDevices_background(WITH permission)");

        refreshDevices_listen();
        return;
    }
#endif // Q_OS_ANDROID && QT_CONNECTIVITY_PATCHED

    if (m_permLocationBLE)
    {
        /// Background refresh (using active connections)

        //UtilsLog::getInstance()->pushLog("(daemon) refreshDevices_background(WITHOUT permission)");

        refreshDevices_check();
        return;
    }
}

void DeviceManager::refreshDevices_listen()
{
    //qDebug() << "DeviceManager::refreshDevices_listen()";

    // Already updating?
    if (isListening() || isUpdating() || isScanning())
    {
        // Here we can:             // > do nothing, and queue another refresh
        //refreshDevices_stop();    // > (or) cancel current refresh
        //return;                   // > (or) bail
    }

    // Make sure we have Bluetooth and devices
    if (checkBluetooth() && m_devices_model->hasDevices())
    {
        m_devices_updating_queue.clear();
        m_devices_updating.clear();

        // Passive refresh
        listenDevices_start();
    }
}

void DeviceManager::refreshDevices_check()
{
    //qDebug() << "DeviceManager::refreshDevices_check()";

    // Already updating?
    if (isUpdating() || isScanning())
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

        // Passive refresh
        listenDevices_start();

        // Start active refresh (if needed)
        for (int i = 0; i < m_devices_model->rowCount(); i++)
        {
            QModelIndex e = m_devices_filter->index(i, 0);
            Device *dd = qvariant_cast<Device *>(m_devices_filter->data(e, DeviceModel::PointerRole));

            if (dd)
            {
                if (!dd->isEnabled()) continue;
                if (!dd->hasBluetoothConnection()) continue;

                // old or no data: go for refresh
                if (dd->needsUpdateDb())
                {
                    if (!m_devices_updating_queue.contains(dd) && !m_devices_updating.contains(dd))
                    {
                        m_devices_updating_queue.push_back(dd);
                        dd->refreshQueued();
                    }
                }
            }
        }

        if (!m_devices_updating_queue.isEmpty())
        {
            // Update lastRun
            setLastRun();
        }

        refreshDevices_continue();
    }
}

void DeviceManager::refreshDevices_start()
{
    //qDebug() << "DeviceManager::refreshDevices_start()";

    // Already updating?
    if (isUpdating() || isScanning())
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

        // Passive refresh
        listenDevices_start();

        // Start active refresh (if last device update > 1 min)
        for (auto d: std::as_const(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);

            // as long as we didn't just finished updating it: go for refresh
            if (dd && dd->isEnabled() && dd->hasBluetoothConnection() &&
                (dd->getLastUpdateInt() < 0 || dd->getLastUpdateInt() > 2))
            {
                if (!m_devices_updating_queue.contains(dd) && !m_devices_updating.contains(dd))
                {
                    m_devices_updating_queue.push_back(dd);
                    dd->refreshQueued();
                }
            }
        }

        if (!m_devices_updating_queue.isEmpty())
        {
            // Update lastRun
            setLastRun();
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

    if (m_discoveryAgent && m_discoveryAgent->isActive())
    {
        m_discoveryAgent->stop();

        if (m_listening) {
            m_listening = false;
            Q_EMIT listeningChanged();
        }
        if (m_scanning) {
            m_scanning = false;
            Q_EMIT scanningChanged();
        }
    }

    m_devices_updating.clear();
    m_updating = false;
    Q_EMIT updatingChanged();

    if (!m_devices_updating_queue.empty())
    {
        for (auto d: std::as_const(m_devices_updating))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd) dd->refreshStop();
        }

        m_devices_updating_queue.clear();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::syncDevice(const QString &address)
{
    //qDebug() << "DeviceManager::syncDevice() " << address;

    if (hasBluetooth())
    {
        for (auto d: std::as_const(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd && dd->getAddress() == address)
            {
                m_devices_syncing_queue.push_back(dd);
                dd->refreshQueued();

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
                // We need history support
                if (!dd->hasHistory()) continue;

                // Old or no data: go for a sync
                if (dd->getLastHistorySync_int() < 0 || dd->getLastHistorySync_int() > 6*60*60)
                {
                    m_devices_syncing_queue.push_back(dd);
                    dd->refreshQueued();
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
        for (auto d: std::as_const(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd)
            {
                // We need history support
                if (!dd->hasHistory()) continue;

                // Old or no data: go for a sync
                if (dd->getLastHistorySync_int() < 0 || dd->getLastHistorySync_int() > 6*60*60)
                {
                    m_devices_syncing_queue.push_back(dd);
                    dd->refreshQueued();
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
        for (auto d: std::as_const(m_devices_syncing))
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
    SettingsManager *sm = SettingsManager::getInstance();

    // Various sanity checks
    {
        if (info.rssi() >= 0) return; // we probably just hit the device cache
        //if ((info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) == false) return; // not a BLE device
        if (m_devices_blacklist.contains(info.address().toString())) return; // device is blacklisted
        if (m_devices_blacklist.contains(info.deviceUuid().toString())) return; // device is blacklisted
        if (sm && sm->getBluetoothLimitScanningRange() && info.rssi() < -70) return; // device is too far away
        if ((info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) == false) return; // not a BLE device

        for (auto ed: std::as_const(m_devices_model->m_devices)) // device is already in the UI
        {
            Device *edd = qobject_cast<Device*>(ed);
            if (edd && (edd->getAddress() == info.address().toString() ||
                        edd->getAddress() == info.deviceUuid().toString()))
            {
                return;
            }
        }
    }

    qDebug() << "DeviceManager::addBleDevice()" << " > NAME" << info.name() << " > RSSI" << info.rssi();

    Device *d = nullptr;

    // Regular WatchFlower device
    if (info.name() == "Flower care" || info.name() == "Flower mate" ||
        info.name() == "Grow care garden" ||
        info.name() == "TY" ||
        info.name() == "ropot" ||
        info.name().startsWith("Flower power") ||
        info.name().startsWith("Parrot pot") ||
        info.name() == "HiGrow" ||
        info.name() == "bparasite" ||
        info.name() == "ThermoBeacon" ||
        info.name() == "MJ_HT_V1" ||
        info.name() == "LYWSD02" || info.name() == "MHO-C303" ||
        info.name() == "LYWSD03MMC" || info.name() == "MHO-C401" ||
        info.name() == "XMWSDJO4MMC" || info.name() == "MJWSD05MMC" ||
        info.name() == "ClearGrass Temp & RH" || info.name() == "Qingping Temp & RH M" ||
        info.name() == "Qingping Temp RH Lite" ||
        info.name() == "Qingping Temp RH Barometer" ||
        info.name() == "Qingping Alarm Clock" ||
        info.name() == "Qingping Air Monitor Lite" ||
        info.name().startsWith("ATC_") ||
        info.name().startsWith("6003#") ||
        info.name() == "JQJCY01YM" ||
        info.name() == "AirQualityMonitor" ||
        info.name() == "GeigerCounter")
    {
        // Create the device
        if (info.name() == "Flower care" || info.name() == "Flower mate" || info.name() == "Grow care garden")
            d = new DeviceFlowerCare(info, this);
        else if (info.name() == "TY")
            d = new DeviceFlowerCare_tuya(info, this);
        else if (info.name() == "ropot")
            d = new DeviceRopot(info, this);
        else if (info.name().startsWith("Flower power"))
            d = new DeviceFlowerPower(info, this);
        else if (info.name().startsWith("Parrot pot"))
            d = new DeviceParrotPot(info, this);
        else if (info.name() == "bparasite")
            d = new DeviceBParasite(info, this);
        else if (info.name() == "HiGrow")
            d = new DeviceEsp32HiGrow(info, this);

        else if (info.name() == "ThermoBeacon")
            d = new DeviceThermoBeacon(info, this);
        else if (info.name() == "MJ_HT_V1")
            d = new DeviceHygrotempLYWSDCGQ(info, this);
        else if (info.name() == "LYWSD02" || info.name() == "MHO-C303")
            d = new DeviceHygrotempClock(info, this);
        else if (info.name() == "LYWSD03MMC" || info.name() == "MHO-C401" ||
                 info.name() == "XMWSDJO4MMC" || info.name() == "MJWSD05MMC")
            d = new DeviceHygrotempSquare(info, this);
        else if (info.name() == "ClearGrass Temp & RH" || info.name() == "Qingping Temp & RH M")
            d = new DeviceHygrotempCGG1(info, this);
        else if (info.name() == "Qingping Temp RH Lite")
            d = new DeviceHygrotempCGDK2(info, this);
        else if (info.name() == "Qingping Alarm Clock")
            d = new DeviceHygrotempCGD1(info, this);
        else if (info.name() == "Qingping Temp RH Barometer")
            d = new DeviceHygrotempCGP1W(info, this);
        else if (info.name().startsWith("ATC_"))
            d = new DeviceHygrotempATC(info, this);

        else if (info.name().startsWith("6003#"))
            d = new DeviceWP6003(info, this);
        else if (info.name() == "Qingping Air Monitor Lite")
            d = new DeviceCGDN1(info, this);
        else if (info.name() == "JQJCY01YM")
            d = new DeviceJQJCY01YM(info, this);
        else if (info.name() == "AirQualityMonitor")
            d = new DeviceEsp32AirQualityMonitor(info, this);
        else if (info.name() == "GeigerCounter")
            d = new DeviceEsp32GeigerCounter(info, this);
    }

    if (d)
    {
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
                addDevice.prepare("INSERT INTO devices (deviceAddr, deviceModel, deviceName) VALUES (:deviceAddr, :deviceModel, :deviceName)");
                addDevice.bindValue(":deviceAddr", d->getAddress());
                addDevice.bindValue(":deviceModel", d->getModel());
                addDevice.bindValue(":deviceName", d->getName());

                if (addDevice.exec() == false)
                {
                    qWarning() << "> addDevice.exec() ERROR"
                               << addDevice.lastError().type() << ":" << addDevice.lastError().text();
                }
            }
        }

        // Connect and handle update
        connect(d, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
        connect(d, &Device::deviceSynced, this, &DeviceManager::syncDevices_finished);

        if (d->hasBluetoothConnection())
        {
            SettingsManager *sm = SettingsManager::getInstance();

            // old or no data: go for refresh
            if (d->getLastUpdateInt() < 0 ||
                d->getLastUpdateInt() > (int)(d->isPlantSensor() ? sm->getUpdateIntervalPlant() : sm->getUpdateIntervalThermo()))
            {
                if (!m_devices_updating_queue.contains(d) && !m_devices_updating.contains(d))
                {
                    m_devices_updating_queue.push_back(d);
                    d->refreshQueued();
                    refreshDevices_continue();
                }
            }
        }

        // Add it to the UI
        m_devices_model->addDevice(d);

        if (d->isPlantSensor())
        {
            m_devicesPlant_model->addDevice(d);
        }
        else if (d->isThermometer())
        {
            m_devicesThermo_model->addDevice(d);
        }
        else if (d->isEnvironmentalSensor())
        {
            m_devicesEnv_model->addDevice(d);
        }

        Q_EMIT devicesListUpdated();
        qDebug() << "Device added (from BLE discovery): " << d->getName() << "/" << d->getAddress();
    }
    else
    {
        //qDebug() << "Unsupported device: " << info.name() << "/" << info.address();
    }
}

void DeviceManager::disconnectDevices()
{
    //qDebug() << "DeviceManager::disconnectDevices()";

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);
        dd->deviceDisconnect();
    }
}

void DeviceManager::removeDevice(const QString &address)
{
    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);

        if (dd->getAddress() == address)
        {
            qDebug() << "- Removing device: " << dd->getName() << "/" << dd->getAddress() << "from local database";

            // Make sure its not being used
            disconnect(dd, &Device::deviceUpdated, this, &DeviceManager::refreshDevices_finished);
            disconnect(dd, &Device::deviceSynced, this, &DeviceManager::syncDevices_finished);
            dd->refreshStop();
            refreshDevices_finished(dd);

            // Remove from database // Don't remove the actual data, nor the limits
            if (m_dbInternal || m_dbExternal)
            {
                QSqlQuery removeDevice;
                removeDevice.prepare("DELETE FROM devices WHERE deviceAddr = :deviceAddr");
                removeDevice.bindValue(":deviceAddr", dd->getAddress());

                if (removeDevice.exec() == false)
                {
                    qWarning() << "> removeDevice.exec() ERROR"
                               << removeDevice.lastError().type() << ":" << removeDevice.lastError().text();
                }
            }

            // Remove device
            m_devices_model->removeDevice(dd, true);
            m_devicesPlant_model->removeDevice(dd, false);
            m_devicesThermo_model->removeDevice(dd, false);
            m_devicesEnv_model->removeDevice(dd, false);
            Q_EMIT devicesListUpdated();

            break;
        }
    }
}

void DeviceManager::removeDeviceData(const QString &address)
{
    for (auto d: std::as_const(m_devices_model->m_devices))
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

void DeviceManager::invalidate()
{
    m_devices_filter->invalidate();
}

void DeviceManager::invalidateFilter()
{
    m_devices_filter->invalidatefilter();
}

QVariant DeviceManager::getDeviceByProxyIndex(const int index, const DeviceUtils::DeviceType deviceType) const
{
    DeviceFilter *filter = m_devices_filter;
    if (deviceType > 0)
    {
        if (deviceType == DeviceUtils::DEVICE_PLANTSENSOR) filter = m_devicesPlant_filter;
        if (deviceType == DeviceUtils::DEVICE_THERMOMETER) filter = m_devicesThermo_filter;
        if (deviceType == DeviceUtils::DEVICE_ENVIRONMENTAL) filter = m_devicesEnv_filter;
    }

    QModelIndex proxyIndex = filter->index(index, 0);
    return QVariant::fromValue(filter->data(proxyIndex, DeviceModel::PointerRole));
}

void DeviceManager::orderby(int role, Qt::SortOrder order)
{
    m_devices_filter->setSortRole(role);
    m_devices_filter->sort(0, order);
    m_devices_filter->invalidate();

    if (m_devicesPlant_filter) {
        m_devicesPlant_filter->setSortRole(role);
        m_devicesPlant_filter->sort(0, order);
        m_devicesPlant_filter->invalidate();
    }
    if (m_devicesThermo_filter) {
        m_devicesThermo_filter->setSortRole(role);
        m_devicesThermo_filter->sort(0, order);
        m_devicesThermo_filter->invalidate();
    }
    if (m_devicesEnv_filter) {
        m_devicesEnv_filter->setSortRole(role);
        m_devicesEnv_filter->sort(0, order);
        m_devicesEnv_filter->invalidate();
    }
}

/* ************************************************************************** */

void DeviceManager::orderby_manual()
{
    orderby(DeviceModel::ManualIndexRole, Qt::AscendingOrder);
}

void DeviceManager::orderby_model()
{
    orderby(DeviceModel::DeviceModelRole, Qt::AscendingOrder);
}

void DeviceManager::orderby_name()
{
    orderby(DeviceModel::DeviceNameRole, Qt::AscendingOrder);
}

void DeviceManager::orderby_location()
{
    orderby(DeviceModel::AssociatedLocationRole, Qt::AscendingOrder);
}

void DeviceManager::orderby_waterlevel()
{
    orderby(DeviceModel::SoilMoistureRole, Qt::AscendingOrder);
}

void DeviceManager::orderby_plant()
{
    orderby(DeviceModel::PlantNameRole, Qt::AscendingOrder);
}

void DeviceManager::orderby_insideoutside()
{
    orderby(DeviceModel::InsideOutsideRole, Qt::AscendingOrder);
}

/* ************************************************************************** */
