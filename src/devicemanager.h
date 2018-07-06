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

#ifndef DEVICE_MANAGER_H
#define DEVICE_MANAGER_H

#include "settingsmanager.h"

#include <QObject>
#include <QVariant>
#include <QList>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

QT_FORWARD_DECLARE_CLASS (QBluetoothDeviceInfo)
QT_FORWARD_DECLARE_CLASS (QLowEnergyController)

/*!
 * \brief The DeviceManager class
 */
class DeviceManager: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant devicesList READ getDevices NOTIFY devicesUpdated)

    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(bool bluetooth READ hasBluetooth NOTIFY bluetoothChanged)

public:
    DeviceManager();
    ~DeviceManager();

    QVariant getDevices() const { return QVariant::fromValue(m_devices); }

public slots:
    void startDeviceDiscovery();
    void refreshDevices();

    bool hasBluetooth() const;
    bool hasDatabase() const;

    bool isScanning() const;
    bool areDevicesAvailable() const;

private slots:
    // QBluetoothLocalDevice related
    void changeBluetoothMode(QBluetoothLocalDevice::HostMode);

    // QBluetoothDeviceDiscoveryAgent related
    void addBleDevice(const QBluetoothDeviceInfo &);
    void deviceDiscoveryFinished();
    void deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error);

Q_SIGNALS:
    void devicesUpdated();
    void disconnected();

    void scanningChanged();
    void bluetoothChanged();

private:
    bool m_bt = false;
    bool m_db = false;
    bool m_scanning = false;

    void loadBluetooth();
    void loadDatabase();

    QBluetoothLocalDevice m_bluetoothAdapter;
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent = nullptr;
    QLowEnergyController *m_controller = nullptr;

    QList<QObject*> m_devices;
};

#endif // DEVICE_MANAGER_H
