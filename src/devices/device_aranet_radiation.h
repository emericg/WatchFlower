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

#ifndef DEVICE_ARANET_RADIATION_H
#define DEVICE_ARANET_RADIATION_H
/* ************************************************************************** */

#include "device_environmental.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * SAF Tehnika "Aranet Radiation"
 * Ionizing radiation sensor
 *
 * Protocol infos:
 * - WatchFlower/docs/aranet-radiation-ble-api.md
 */
class DeviceAranetRadiation: public DeviceEnvironmental
{
    Q_OBJECT

public:
    DeviceAranetRadiation(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceAranetRadiation(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceAranetRadiation();

    Q_INVOKABLE bool hasData() const;

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceData = nullptr;

    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);

    void parseCurrentReadings(const QByteArray &value);

    // Cumulated radiation dose, read from the device but not exposed to the UI
    uint64_t m_radiationTotal = 0;      //!< nSv
    uint64_t m_radiationDuration = 0;   //!< seconds

    bool areValuesValid(const float radiation) const;
    bool addDatabaseRecord(const int64_t timestamp, const float radiation);
};

/* ************************************************************************** */
#endif // DEVICE_ARANET_RADIATION_H
