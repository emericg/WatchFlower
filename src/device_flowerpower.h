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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_FLOWERPOWER_H
#define DEVICE_FLOWERPOWER_H
/* ************************************************************************** */

#include "device.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Parrot "Flower Power" devices
 *
 * Protocol infos:
 * - https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf
 * - https://www.fanjoe.be/?p=3520
 */
class DeviceFlowerPower: public Device
{
    Q_OBJECT

public:
    DeviceFlowerPower(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceFlowerPower(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceFlowerPower();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_clock(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceBattery = nullptr;
    QLowEnergyService *serviceData = nullptr;
    QLowEnergyService *serviceClock = nullptr;
    QLowEnergyService *serviceHistory = nullptr;
    QLowEnergyDescriptor m_notificationDesc;

    int64_t m_clock;
    int64_t m_lastmove;

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_FLOWERPOWER_H
