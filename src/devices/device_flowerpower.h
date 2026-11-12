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

#ifndef DEVICE_FLOWERPOWER_H
#define DEVICE_FLOWERPOWER_H
/* ************************************************************************** */

#include "device_plantsensor.h"

#include <QObject>
#include <QList>

#include <QBluetoothUuid>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Parrot "Flower Power" devices
 *
 * Parrot devices have MANY services and characteristics, so we use SkipValueDiscovery
 * to speed up connections, and we read the few characteristics values we actually need
 * explicitely, instead of everything being fetched by the discovery.
 *
 * Protocol infos:
 * - WatchFlower/docs/flowerpower-ble-api.md
 * - https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf
 */
class DeviceFlowerPower: public DevicePlantSensor
{
    Q_OBJECT

public:
    DeviceFlowerPower(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceFlowerPower(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceFlowerPower();

private:
    // Services
    static constexpr QBluetoothUuid uuid_service_infos{QBluetoothUuid::ServiceClassUuid::DeviceInformation};
    static constexpr QBluetoothUuid uuid_service_battery{QBluetoothUuid::ServiceClassUuid::BatteryService};
    static inline const QBluetoothUuid uuid_service_live{QStringLiteral("39e1fa00-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_service_history{QStringLiteral("39e1fc00-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_service_clock{QStringLiteral("39e1fd00-84a8-11e2-afba-0002a5d5c51b")};

    // Characteristics
    static constexpr QBluetoothUuid uuid_firmware{QBluetoothUuid::CharacteristicType::FirmwareRevisionString};
    static constexpr QBluetoothUuid uuid_battery_level{QBluetoothUuid::CharacteristicType::BatteryLevel};
    static inline const QBluetoothUuid uuid_live_sunlight{QStringLiteral("39e1fa01-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_soil_ec{QStringLiteral("39e1fa02-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_soil_temp{QStringLiteral("39e1fa03-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_air_temp{QStringLiteral("39e1fa04-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_soil_moisture{QStringLiteral("39e1fa05-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_led{QStringLiteral("39e1fa07-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_last_move{QStringLiteral("39e1fa08-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_clock_time{QStringLiteral("39e1fd01-84a8-11e2-afba-0002a5d5c51b")};

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_clock(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_live(QLowEnergyService::ServiceState newState);
    void serviceDiscoveryFinished();

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceBattery = nullptr;
    QLowEnergyService *serviceClock = nullptr;
    QLowEnergyService *serviceHistory = nullptr;
    QLowEnergyService *serviceLive = nullptr;

    int m_services_pending = 0;
    int m_reads_pending = 0;

    void bleReadPending(QLowEnergyService *service, const QBluetoothUuid &uuid);
    void bleReadErrored(QLowEnergyService::ServiceError error);
    void bleWorkFinished();
    void parseLiveValues();

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_FLOWERPOWER_H
