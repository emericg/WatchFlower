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

#ifndef DEVICE_ENVIRONMENTAL_H
#define DEVICE_ENVIRONMENTAL_H
/* ************************************************************************** */

#include "device_sensor.h"

#include <QObject>
#include <QString>

/* ************************************************************************** */

/*!
 * \brief The DeviceEnvironmental class
 */
class DeviceEnvironmental: public DeviceSensor
{
    Q_OBJECT

public:
    DeviceEnvironmental(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceEnvironmental(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DeviceEnvironmental();

    // Chart environmental histogram
    Q_INVOKABLE void updateChartData_environmentalVoc(int maxDays);
    Q_INVOKABLE void updateChartData_environmentalEnv(int maxDays);
};

/* ************************************************************************** */
#endif // DEVICE_ENVIRONMENTAL_H
