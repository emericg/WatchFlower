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

#ifndef DEVICE_JQJCY01YM_H
#define DEVICE_JQJCY01YM_H
/* ************************************************************************** */

#include "device_environmental.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Honeywell HCHO Formaldehyde detector
 * JQJCY01YM device / squared body / OLED
 */
class DeviceJQJCY01YM: public DeviceEnvironmental
{
    Q_OBJECT

public:
    DeviceJQJCY01YM(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceJQJCY01YM(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceJQJCY01YM();

    Q_INVOKABLE bool hasData() const;

    void parseAdvertisementData(const QByteArray &value, const uint16_t identifier);

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
};

/* ************************************************************************** */
#endif // DEVICE_JQJCY01YM_H
