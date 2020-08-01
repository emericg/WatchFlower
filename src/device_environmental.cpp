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

#include "device_environmental.h"

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

DeviceEnvironmental::DeviceEnvironmental(QString &deviceAddr, QString &deviceName, QObject *parent) :
    Device(deviceAddr, deviceName, parent)
{
    //
}

DeviceEnvironmental::DeviceEnvironmental(const QBluetoothDeviceInfo &d, QObject *parent) :
    Device(d, parent)
{
    //
}

DeviceEnvironmental::~DeviceEnvironmental()
{
    //
}

/* ************************************************************************** */
