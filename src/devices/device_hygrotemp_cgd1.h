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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_HYGROTEMP_CGD1_H
#define DEVICE_HYGROTEMP_CGD1_H
/* ************************************************************************** */

#include "device_thermometer.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Qingping (formerly ClearGrass) "Bluetooth Alarm Clock"
 * CGD1 device / squared body / LCD
 *
 * Protocol infos:
 * - WatchFlower/docs/cgd1-ble-api.md
 */
class DeviceHygrotempCGD1: public DeviceThermometer
{
    Q_OBJECT

public:
    DeviceHygrotempCGD1(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceHygrotempCGD1(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceHygrotempCGD1();

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
};

/* ************************************************************************** */
#endif // DEVICE_HYGROTEMP_CGD1_H
