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

#ifndef DEVICE_MANAGER_H
#define DEVICE_MANAGER_H
/* ************************************************************************** */

#include "settingsmanager.h"

class Device;

#include <QObject>
#include <QVariant>
#include <QList>
#include <QTimer>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

QT_FORWARD_DECLARE_CLASS(QBluetoothDeviceInfo)
QT_FORWARD_DECLARE_CLASS(QLowEnergyController)

/* ************************************************************************** */

/*!
 * \brief The DeviceManager class
 */
class DeviceManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool devices READ areDevicesAvailable NOTIFY devicesUpdated)
    Q_PROPERTY(QVariant devicesList READ getDevices NOTIFY devicesUpdated)

    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(bool refreshing READ isRefreshing NOTIFY refreshingChanged)

    Q_PROPERTY(bool bluetooth READ hasBluetooth NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothAdapter READ hasBluetoothAdapter NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothEnabled READ hasBluetoothEnabled NOTIFY bluetoothChanged)

    bool m_db = false;
    bool m_btA = false;
    bool m_btE = false;

    QBluetoothLocalDevice *m_bluetoothAdapter = nullptr;
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent = nullptr;
    QLowEnergyController *m_controller = nullptr;

    bool m_scanning = false;

    QList<QObject*> m_devices;

    QTimer m_refreshTimer;
    QList<QObject*> m_devices_updatelist;

public:
    DeviceManager();
    ~DeviceManager();

    bool hasDatabase() const;
    void checkDatabase();

    bool hasBluetooth() const;
    bool hasBluetoothAdapter() const;
    bool hasBluetoothEnabled() const;
    Q_INVOKABLE void checkBluetooth();
    Q_INVOKABLE void enableBluetooth(bool checkPremisson = false);

    Q_INVOKABLE void scanDevices();
    bool isScanning() const;

    Q_INVOKABLE bool areDevicesAvailable() const { return !m_devices.empty(); }

    QVariant getDevices() const { return QVariant::fromValue(m_devices); }
    Q_INVOKABLE QVariant getFirstDevice() const { if (m_devices.empty()) return QVariant(); return QVariant::fromValue(m_devices.at(0)); }

public slots:
    /*!
     * \brief Refresh devices with datas >xh old
     */
    void refreshDevices_check();
    /*!
     * \brief Refresh every devices
     */
    void refreshDevices_start();

    void refreshDevices_continue();
    void refreshDevices_finished(Device *dev);
    void refreshDevices_stop();
    bool isRefreshing() const;

    void updateDevice(const QString &address);

    void removeDevice(const QString &address);

private slots:
    // QBluetoothLocalDevice related
    void bluetoothModeChanged(QBluetoothLocalDevice::HostMode);

    // QBluetoothDeviceDiscoveryAgent related
    void addBleDevice(const QBluetoothDeviceInfo &);
    void deviceDiscoveryFinished();
    void deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error);

Q_SIGNALS:
    void devicesUpdated();
    void disconnected();

    void scanningChanged();
    void refreshingChanged();
    void bluetoothChanged();
};

/* ************************************************************************** */
#endif // DEVICE_MANAGER_H
