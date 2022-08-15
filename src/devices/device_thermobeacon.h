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
 * \date      2021
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_THERMOBEACON_H
#define DEVICE_THERMOBEACON_H
/* ************************************************************************** */

#include "device_thermometer.h"

#include <QObject>
#include <QString>
#include <QList>

#include <QBluetoothUuid>
#include <QBluetoothDeviceInfo>

/* ************************************************************************** */

/*!
 * SensorBlue / Brifit / ORIA "ThermoBeacon"
 *
 * LCD Hygrometer (2ACD3-WS08) / (KEU-WA59D)
 * Keychain Hygrometer (2ACD3-WS07) / (2ACD3-WS02)
 *
 * Protocol infos:
 * - WatchFlower/docs/thermobeacon-ble-api.md
 */
class DeviceThermoBeacon: public DeviceThermometer
{
public:
    DeviceThermoBeacon(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceThermoBeacon(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceThermoBeacon();

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceData = nullptr;
    QLowEnergyDescriptor m_notificationDesc;

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_THERMOBEACON_H
