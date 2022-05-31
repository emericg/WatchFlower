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

#ifndef DEVICE_ESP32_GEIGER_H
#define DEVICE_ESP32_GEIGER_H
/* ************************************************************************** */

#include "device_environmental.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Homemade ESP32 Geiger Counter.
 * - https://github.com/emericg/esp32-environmental-sensors/tree/master/GeigerCounter
 *
 * Protocol infos:
 * - https://github.com/emericg/esp32-environmental-sensors/blob/master/GeigerCounter/doc/geigercounter-ble-api.md
 */
class DeviceEsp32GeigerCounter: public DeviceEnvironmental
{
    Q_OBJECT

public:
    DeviceEsp32GeigerCounter(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceEsp32GeigerCounter(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceEsp32GeigerCounter();

    Q_INVOKABLE virtual bool hasData() const;

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceBattery = nullptr;
    QLowEnergyService *serviceData = nullptr;
    QLowEnergyDescriptor m_notificationDesc;

    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);

    bool areValuesValid(const float rad_m) const;

    bool addDatabaseRecord(const int64_t timestamp, const float rad_m);
};

/* ************************************************************************** */
#endif // DEVICE_ESP32_GEIGER_H
