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

#ifndef DEVICE_FLOWERCARE_TUYA_H
#define DEVICE_FLOWERCARE_TUYA_H
/* ************************************************************************** */

#include "device_plantsensor.h"

#include <cstdint>

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Tuya "Flower Care" (HHCCJCY10)
 *
 * Protocol infos:
 * - WatchFlower/docs/flowercare_tuya-ble-api.md
 */
class DeviceFlowerCare_tuya: public DevicePlantSensor
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceData = nullptr;

public:
    DeviceFlowerCare_tuya(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceFlowerCare_tuya(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceFlowerCare_tuya();

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_FLOWERCARE_TUYA_H
