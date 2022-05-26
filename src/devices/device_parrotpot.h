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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_PARROTPOT_H
#define DEVICE_PARROTPOT_H
/* ************************************************************************** */

#include "device_plantsensor.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Parrot Pot devices
 *
 * Protocol infos:
 * - https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf
 */
class DeviceParrotPot: public DevicePlantSensor
{
    Q_OBJECT

public:
    DeviceParrotPot(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceParrotPot(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceParrotPot();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_clock(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_watering(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_live(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceBattery = nullptr;
    QLowEnergyService *serviceClock = nullptr;
    QLowEnergyService *serviceHistory = nullptr;
    QLowEnergyService *serviceWatering = nullptr;
    QLowEnergyService *serviceLive = nullptr;

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_PARROTPOT_H
