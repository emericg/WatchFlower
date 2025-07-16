/*!
 * This file is part of SmartCare.
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

#ifndef DEVICE_MANAGER_H
#define DEVICE_MANAGER_H
/* ************************************************************************** */

#include "DeviceFilter.h"

#include <QObject>
#include <QVariant>
#include <QList>
#include <QTimer>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

class QBluetoothDeviceInfo;
class QLowEnergyController;

/* ************************************************************************** */

/*!
 * \brief The DeviceManager class
 */
class DeviceManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool hasDevices READ areDevicesAvailable NOTIFY devicesListUpdated)
    Q_PROPERTY(int deviceCount READ getDeviceCount NOTIFY devicesListUpdated)
    Q_PROPERTY(DeviceFilter *devicesList READ getDevicesFiltered NOTIFY devicesListUpdated)

    Q_PROPERTY(DeviceFilter *devicesPlantList READ getDevicesPlantFiltered NOTIFY devicesListUpdated)
    Q_PROPERTY(int devicePlantCount READ getDevicePlantCount NOTIFY devicesListUpdated)
    Q_PROPERTY(DeviceFilter *devicesThermoList READ getDevicesThermoFiltered NOTIFY devicesListUpdated)
    Q_PROPERTY(int deviceThermoCount READ getDeviceThermoCount NOTIFY devicesListUpdated)
    Q_PROPERTY(DeviceFilter *devicesEnvList READ getDevicesEnvFiltered NOTIFY devicesListUpdated)
    Q_PROPERTY(int deviceEnvCount READ getDeviceEnvCount NOTIFY devicesListUpdated)

    Q_PROPERTY(DeviceFilter *devicesNearby READ getDevicesNearby NOTIFY devicesNearbyUpdated)

    ////////

    Q_PROPERTY(bool advertising READ isAdvertising NOTIFY advertisingChanged)
    Q_PROPERTY(bool listening READ isListening NOTIFY listeningChanged)
    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY updatingChanged)
    Q_PROPERTY(bool syncing READ isSyncing NOTIFY syncingChanged)

    Q_PROPERTY(bool bluetooth READ hasBluetooth NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothAdapter READ hasBluetoothAdapter NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothEnabled READ hasBluetoothEnabled NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothPermissions READ hasBluetoothPermissions NOTIFY bluetoothChanged)

    Q_PROPERTY(bool permissionOS READ hasPermissionOS NOTIFY permissionsChanged)
    Q_PROPERTY(bool permissionLocationBLE READ hasPermissionLocationBLE NOTIFY permissionsChanged)
    Q_PROPERTY(bool permissionLocationBackground READ hasPermissionLocationBackground NOTIFY permissionsChanged)
    Q_PROPERTY(bool permissionLocationGPS READ hasPermissionGPS NOTIFY permissionsChanged)

    Q_PROPERTY(int bluetoothHostMode READ getBluetoothHostMode NOTIFY hostModeChanged)

    static const int ble_scanning_duration = 30;
    static const int ble_listening_duration = 60;
    static const int ble_listening_duration_nearby = 60;
    static const int ble_listening_duration_background = 45;

    bool m_dbInternal = false;  //!< do we have an internal SQLite database?
    bool m_dbExternal = false;  //!< do we have a remote MySQL database?

    bool m_daemonMode = false;  //!< did we start without UI?

    bool m_bleAdapter = false;      //!< do we have a BLE adapter?
    bool m_bleEnabled = false;      //!< is the BLE adapter enabled?
    bool m_blePermissions = false;  //!< do we have necessary BLE permissions? (brings together all other permsissions)

    bool m_permOS = false;          //!< do we have OS permissions for BLE? (macOS, iOS, Android)
    bool m_permLocationBLE = false; //!< do we location permission? (Android)
    bool m_permLocationBKG = false; //!< do we background location permission? (Android)
    bool m_permGPS = false;         //!< is the GPS enabled? (Android)

    QBluetoothLocalDevice *m_bluetoothAdapter = nullptr;
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent = nullptr;
    QBluetoothLocalDevice::HostMode m_ble_hostmode = QBluetoothLocalDevice::HostPoweredOff;

    QList <QObject *> m_bluetoothAdapters;

    QList <QString> m_devices_blacklist;

    DeviceModel *m_devices_nearby_model = nullptr;
    DeviceFilter *m_devices_nearby_filter = nullptr;

    DeviceModel *m_devices_model = nullptr;
    DeviceFilter *m_devices_filter = nullptr;

    DeviceModel *m_devicesPlant_model = nullptr;
    DeviceFilter *m_devicesPlant_filter = nullptr;
    DeviceModel *m_devicesThermo_model = nullptr;
    DeviceFilter *m_devicesThermo_filter = nullptr;
    DeviceModel *m_devicesEnv_model = nullptr;
    DeviceFilter *m_devicesEnv_filter = nullptr;

    QList <QObject *> m_devices_updating_queue;
    QList <QObject *> m_devices_updating;

    QList <QObject *> m_devices_syncing_queue;
    QList <QObject *> m_devices_syncing;

    bool m_advertising = false;
    bool isAdvertising() const { return m_advertising; }

    bool m_listening = false;
    bool isListening() const { return m_listening; }

    bool m_scanning = false;
    bool isScanning() const { return m_scanning; }

    bool m_updating = false;
    bool isUpdating() const;

    bool m_syncing = false;
    bool isSyncing() const;

    bool hasBluetooth() const { return (m_bleAdapter && m_bleEnabled && m_blePermissions); }
    bool hasBluetoothAdapter() const { return m_bleAdapter; }
    bool hasBluetoothEnabled() const { return m_bleEnabled; }
    bool hasBluetoothPermissions() const { return m_blePermissions; }

    bool hasPermissionOS() const { return m_permOS; }
    bool hasPermissionLocationBLE() const { return m_permLocationBLE; }
    bool hasPermissionLocationBackground() const { return m_permLocationBKG; }
    bool hasPermissionGPS() const { return m_permGPS; }

    int getBluetoothHostMode() const { return m_ble_hostmode; }

    void startBleAgent();

    void checkBluetoothIOS();
    bool m_checking_ios_ble = false;
    QTimer m_checking_ios_timer;

    void setLastRun();

    QTimer m_updateTimer;
    void setUpdateTimer(int updateIntervalMin = 0);

Q_SIGNALS:
    void bluetoothChanged();
    void hostModeChanged();
    void permissionsChanged();

    void adaptersListUpdated();

    void devicesListUpdated();
    void devicesNearbyUpdated();
    void devicesBlacklistUpdated();

    void advertisingChanged();
    void listeningChanged();
    void scanningChanged();
    void updatingChanged();
    void syncingChanged();

private slots:
    // QBluetoothLocalDevice related
    void bluetoothHostModeStateChanged(QBluetoothLocalDevice::HostMode);
    void bluetoothStatusChanged();
    void bluetoothPermissionsChanged();

    // QBluetoothDeviceDiscoveryAgent related
    void addNearbyBleDevice(const QBluetoothDeviceInfo &info);
    void updateNearbyBleDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields);
    void addBleDevice(const QBluetoothDeviceInfo &info);
    void updateBleDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields);
    void updateBleDevice_simple(const QBluetoothDeviceInfo &info);
    void deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error);
    void deviceDiscoveryErrorIOS();
    void deviceDiscoveryFinished();
    void deviceDiscoveryStopped();

public:
    DeviceManager(bool daemon = false);
    ~DeviceManager();

    bool isDaemon() const { return m_daemonMode; }

    // Adapters management
    Q_INVOKABLE bool areAdaptersAvailable() const { return m_bluetoothAdapters.size(); }
    QVariant getAdapters() const { return QVariant::fromValue(m_bluetoothAdapters); }
    int getAdaptersCount() const { return m_bluetoothAdapters.size(); }

    // Bluetooth management
    Q_INVOKABLE bool checkBluetooth();
    Q_INVOKABLE bool checkBluetoothPermissions();
    Q_INVOKABLE bool enableBluetooth(bool enforceUserPermissionCheck = false);
    Q_INVOKABLE bool requestBluetoothPermissions();
    void requestBluetoothPermissions_results();

    // Scanning management
    static int getLastRun_s();
    Q_INVOKABLE int getLastRun();

    Q_INVOKABLE void scanNearby_start();
    Q_INVOKABLE void scanNearby_stop();

    Q_INVOKABLE void scanDevices_start();
    Q_INVOKABLE void scanDevices_stop();

    Q_INVOKABLE void refreshDevices_background();   //!< Refresh devices on the Android background service
    Q_INVOKABLE void refreshDevices_listen();       //!< Refresh devices with data >xh old (as they appear nearby)

    Q_INVOKABLE void listenDevices_start();
    Q_INVOKABLE void listenDevices_stop();

    Q_INVOKABLE void refreshDevices_check();        //!< Refresh devices with data >xh old (if necessary)
    Q_INVOKABLE void refreshDevices_start();        //!< Refresh every device
    void refreshDevices_continue();
    void refreshDevices_finished(Device *dev);
    Q_INVOKABLE void refreshDevices_stop();

    Q_INVOKABLE void syncDevices_check();           //!< Sync history for devices (if necessary)
    Q_INVOKABLE void syncDevices_start();           //!< Sync history for every device
    void syncDevices_continue();
    void syncDevices_finished(Device *dev);
    Q_INVOKABLE void syncDevices_stop();

    // Device management
    Q_INVOKABLE void updateDevice(const QString &address);
    Q_INVOKABLE void syncDevice(const QString &address);
    Q_INVOKABLE void removeDevice(const QString &address);
    Q_INVOKABLE void removeDeviceData(const QString &address);

    Q_INVOKABLE void blacklistBleDevice(const QString &addr);
    Q_INVOKABLE void whitelistBleDevice(const QString &addr);
    Q_INVOKABLE bool isBleDeviceBlacklisted(const QString &addr);

    // Devices list management
    Q_INVOKABLE bool areDevicesAvailable() const { return m_devices_model->hasDevices(); }
    Q_INVOKABLE void disconnectDevices();

    int getDeviceCount() const { return m_devices_model->getDeviceCount(); }
    DeviceFilter *getDevicesFiltered() const { return m_devices_filter; }
    DeviceFilter *getDevicesNearby() const { return m_devices_nearby_filter; }

    DeviceFilter *getDevicesPlantFiltered() const { return m_devicesPlant_filter; }
    int getDevicePlantCount() const { return m_devicesPlant_model->getDeviceCount(); }
    DeviceFilter *getDevicesThermoFiltered() const { return m_devicesThermo_filter; }
    int getDeviceThermoCount() const { return m_devicesThermo_model->getDeviceCount(); }
    DeviceFilter *getDevicesEnvFiltered() const { return m_devicesEnv_filter; }
    int getDeviceEnvCount() const { return m_devicesEnv_model->getDeviceCount(); }

    // Sorting and filtering
    Q_INVOKABLE void orderby_manual();
    Q_INVOKABLE void orderby_model();
    Q_INVOKABLE void orderby_name();
    Q_INVOKABLE void orderby_location();
    Q_INVOKABLE void orderby_waterlevel();
    Q_INVOKABLE void orderby_plant();
    Q_INVOKABLE void orderby_insideoutside();
    void orderby(int role, Qt::SortOrder order);

    Q_INVOKABLE QVariant getDeviceByProxyIndex(const int index,
                                               const DeviceUtils::DeviceType deviceType = DeviceUtils::DEVICE_UNKNOWN) const;

    void invalidate();
    void invalidateFilter();

    // Device data export
    Q_INVOKABLE bool exportDataSave();
    Q_INVOKABLE QString exportDataOpen();
    Q_INVOKABLE QString exportDataFolder();
    bool exportData(const QString &exportFilePath);
};

/* ************************************************************************** */
#endif // DEVICE_MANAGER_H
