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

#ifndef DEVICE_CGDN1_H
#define DEVICE_CGDN1_H
/* ************************************************************************** */

#include "device_environmental.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Qingping "Air Monitor Lite"
 * CGDN1 device / squared body / OLED
 *
 * Protocol infos:
 * - WatchFlower/docs/cgdn1-ble-api.md
 */
class DeviceCGDN1: public DeviceEnvironmental
{
    Q_OBJECT

public:
    DeviceCGDN1(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceCGDN1(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceCGDN1();

    Q_INVOKABLE bool hasData() const;

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
};

/* ************************************************************************** */
#endif // DEVICE_CGDN1_H
