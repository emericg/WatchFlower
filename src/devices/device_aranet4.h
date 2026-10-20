/*!
 * This file is part of WatchFlower.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_ARANET4_H
#define DEVICE_ARANET4_H
/* ************************************************************************** */

#include "device_environmental.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * SAF Tehnika "Aranet4"
 * CO2, temperature, humidity and atmospheric pressure sensor
 *
 * Protocol infos:
 * - WatchFlower/docs/aranet4-ble-api.md
 */
class DeviceAranet4: public DeviceEnvironmental
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceData = nullptr;

    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);

    void parseCurrentReadings(const QByteArray &value);

    bool areValuesValid(const float temperature, const float humidity,
                        const float pressure, const float co2) const;
    bool addDatabaseRecord(const int64_t timestamp,
                           const float temperature, const float humidity,
                           const float pressure, const float co2);

public:
    DeviceAranet4(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceAranet4(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceAranet4();

    Q_INVOKABLE bool hasData() const;
};

/* ************************************************************************** */
#endif // DEVICE_ARANET4_H
