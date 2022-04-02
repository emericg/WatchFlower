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

#ifndef DEVICE_HYGROTEMP_CGP1W_H
#define DEVICE_HYGROTEMP_CGP1W_H
/* ************************************************************************** */

#include "device_sensor.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Qingping (formerly ClearGrass) "Temp & RH Barometer Pro S" / "Temp & RH Monitor Pro S"
 * CGP1W device / squared body / LCD
 *
 * Protocol infos:
 * - WatchFlower/docs/cgp1w-ble-api.md
 */
class DeviceHygrotempCGP1W: public DeviceSensor
{
    Q_OBJECT

    void parseAdvertisementData(const QByteArray &value);

public:
    DeviceHygrotempCGP1W(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceHygrotempCGP1W(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceHygrotempCGP1W();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
};

/* ************************************************************************** */
#endif // DEVICE_HYGROTEMP_CGP1W_H
