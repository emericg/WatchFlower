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

#ifndef DEVICE_ARANET_RADON_H
#define DEVICE_ARANET_RADON_H
/* ************************************************************************** */

#include "device_thermometer.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * SAF Tehnika "Aranet Radon"
 * AranetRn1 device / radon and atmospheric pressure
 * AranetRn+ device / radon, atmospheric pressure, temperature and humidity
 *
 * The radon concentration is read from the device, but not exposed to the UI yet,
 * so those sensors are handled as (barometric) thermometers for now.
 *
 * Protocol infos:
 * - WatchFlower/docs/aranetrn-ble-api.md
 */
class DeviceAranetRadon: public DeviceThermometer
{
    Q_OBJECT

public:
    DeviceAranetRadon(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceAranetRadon(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceAranetRadon();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceData = nullptr;

    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);

    void setSensors();
    bool isRadonPlus() const;

    void parseCurrentReadings(const QByteArray &value);

    // Radon concentrations, read from the device but not exposed to the UI.
    // Bq/m³, or -1 when the value is unavailable or still being averaged.
    int64_t m_radon = -1;
    int64_t m_radon_24h = -1;
    int64_t m_radon_7d = -1;
    int64_t m_radon_30d = -1;

    bool areValuesValid(const float t, const float h, const float p) const;
    bool addDatabaseRecord(const int64_t timestamp, const float t, const float h, const float p);
};

/* ************************************************************************** */
#endif // DEVICE_ARANET_RADON_H
