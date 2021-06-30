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

#ifndef DEVICE_MANAGER_H
#define DEVICE_MANAGER_H
/* ************************************************************************** */

#include "SettingsManager.h"
#include "device_filter.h"
#include "device_utils.h"

#include <QObject>
#include <QVariant>
#include <QList>
#include <QTimer>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
QT_FORWARD_DECLARE_CLASS(QBluetoothDeviceInfo)
QT_FORWARD_DECLARE_CLASS(QLowEnergyController)
QT_FORWARD_DECLARE_CLASS(QLowEnergyConnectionParameters)

/* ************************************************************************** */

/*!
 * \brief The DeviceManager class
 */
class DeviceManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool devices READ areDevicesAvailable NOTIFY devicesListUpdated)
    Q_PROPERTY(bool hasDevices READ areDevicesAvailable NOTIFY devicesListUpdated)
    Q_PROPERTY(DeviceFilter *devicesList READ getDevicesFiltered NOTIFY devicesListUpdated)

    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(bool refreshing READ isRefreshing NOTIFY refreshingChanged)
    Q_PROPERTY(bool updating READ isRefreshing NOTIFY refreshingChanged)

    Q_PROPERTY(bool bluetooth READ hasBluetooth NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothAdapter READ hasBluetoothAdapter NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothEnabled READ hasBluetoothEnabled NOTIFY bluetoothChanged)

    bool m_dbInternal = false;
    bool m_dbExternal = false;
    bool m_btA = false;
    bool m_btE = false;

    QBluetoothLocalDevice *m_bluetoothAdapter = nullptr;
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent = nullptr;
    QLowEnergyConnectionParameters *m_ble_params = nullptr;

    DeviceModel *m_devices_model = nullptr;
    DeviceFilter *m_devices_filter = nullptr;

    QList <QObject *> m_devices_queued;
    QList <QObject *> m_devices_updating;

    QTimer m_refreshTimer;
    bool isRefreshing() const;

    bool m_scanning = false;
    bool isScanning() const;

    bool hasBluetooth() const;
    bool hasBluetoothAdapter() const;
    bool hasBluetoothEnabled() const;

    void checkBluetoothIos();
    void startBleAgent();

public:
    DeviceManager();
    ~DeviceManager();

    Q_INVOKABLE bool checkBluetooth();
    Q_INVOKABLE void enableBluetooth(bool enforceUserPermissionCheck = false);

    Q_INVOKABLE bool areDevicesAvailable() const { return m_devices_model->hasDevices(); }

    Q_INVOKABLE void updateDevice(const QString &address);
    Q_INVOKABLE void removeDevice(const QString &address);
    Q_INVOKABLE void removeDeviceData(const QString &address);

    Q_INVOKABLE void scanDevices();
    Q_INVOKABLE void listenDevices();

    Q_INVOKABLE void orderby_manual();
    Q_INVOKABLE void orderby_model();
    Q_INVOKABLE void orderby_name();
    Q_INVOKABLE void orderby_location();
    Q_INVOKABLE void orderby_waterlevel();
    Q_INVOKABLE void orderby_plant();

    Q_INVOKABLE bool exportDataSave();
    Q_INVOKABLE QString exportDataOpen();
    Q_INVOKABLE QString exportDataFolder();
    bool exportData(const QString &path);

    DeviceFilter *getDevicesFiltered() const { return m_devices_filter; }

    Q_INVOKABLE QVariant getDeviceByProxyIndex(const int index) const
    {
        QModelIndex proxyIndex = m_devices_filter->index(index, 0);
        return QVariant::fromValue(m_devices_filter->data(proxyIndex, DeviceModel::PointerRole));
    }

    void invalidate();

public slots:
    void refreshDevices_check();    //!< Refresh devices with data >xh old
    void refreshDevices_start();    //!< Refresh every devices

    void refreshDevices_continue();
    void refreshDevices_finished(Device *dev);
    void refreshDevices_stop();

private slots:
    // QBluetoothLocalDevice related
    void bluetoothModeChanged(QBluetoothLocalDevice::HostMode);
    void bluetoothStatusChanged();

    // QBluetoothDeviceDiscoveryAgent related
    void bluetoothModeChangedIos();
    void addBleDevice(const QBluetoothDeviceInfo &info);
    void updateBleDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields);
    void deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error);
    void deviceDiscoveryFinished();

Q_SIGNALS:
    void devicesListUpdated();
    void devicesNearUpdated();

    void bluetoothChanged();
    void scanningChanged();
    void refreshingChanged();
};

/* ************************************************************************** */
#endif // DEVICE_MANAGER_H
