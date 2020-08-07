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

#ifndef DEVICE_ESP32_HIGROW_H
#define DEVICE_ESP32_HIGROW_H
/* ************************************************************************** */

#include "device.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * ESP32 HiGrow sensor (with custom firmware).
 *
 * - https://github.com/emericg/esp32-environmental-sensors/tree/master/HiGrow
 */
class DeviceEsp32HiGrow: public Device
{
    Q_OBJECT

public:
    DeviceEsp32HiGrow(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceEsp32HiGrow(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceEsp32HiGrow();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceData = nullptr;
    QLowEnergyDescriptor m_notificationDesc;

    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_ESP32_HIGROW_H
