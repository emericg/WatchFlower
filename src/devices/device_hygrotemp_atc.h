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
 * \date      2023
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_HYGROTEMP_ATC_H
#define DEVICE_HYGROTEMP_ATC_H
/* ************************************************************************** */

#include "device_thermometer.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Custom firmware for the Xiaomi Thermometers and Telink Flasher
 * - https://github.com/pvvx/ATC_MiThermometer
 *
 * Should work with:
 * Xiaomi Mijia (LYWSD03MMC)
 * Xiaomi Miaomiaoce (MHO-C401)
 * Qingping Temp & RH Monitor (CGG1-Mijia)
 * Qingping Temp & RH Monitor Lite (CGDK2)
 *
 * MiBeacon format:
 * - WatchFlower/docs/mibeacon-ble-api.md
 *
 * BTHome v1 format:
 * - https://bthome.io/v1/
 *
 * BTHome v2 format:
 * - https://bthome.io/format/
 * - WatchFlower/docs/bthome-ble-api.md
 */
class DeviceHygrotempATC: public DeviceThermometer
{
    Q_OBJECT

public:
    DeviceHygrotempATC(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceHygrotempATC(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceHygrotempATC();

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
};

/* ************************************************************************** */
#endif // DEVICE_HYGROTEMP_ATC_H
