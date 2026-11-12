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

#ifndef DEVICE_PARROTPOT_H
#define DEVICE_PARROTPOT_H
/* ************************************************************************** */

#include "device_plantsensor.h"

#include <QObject>
#include <QList>

#include <QBluetoothUuid>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Parrot Pot devices
 *
 * Parrot devices have MANY services and characteristics, so we use SkipValueDiscovery
 * to speed up connections, and we read the few characteristics values we actually need
 * explicitely, instead of everything being fetched by the discovery.
 *
 * Protocol infos:
 * - WatchFlower/docs/parrotpot-ble-api.md
 * - WatchFlower/docs/flowerpower-ble-api.md
 * - https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf
 */
class DeviceParrotPot: public DevicePlantSensor
{
    Q_OBJECT

    Q_PROPERTY(bool hasWateringSettings READ hasWateringSettings NOTIFY wateringSettingsUpdated)
    Q_PROPERTY(bool wateringAuto READ getWateringAuto NOTIFY wateringSettingsUpdated)
    Q_PROPERTY(float wateringThreshold READ getWateringThreshold NOTIFY wateringSettingsUpdated)
    Q_PROPERTY(float wateringTarget READ getWateringTarget NOTIFY wateringSettingsUpdated)
    Q_PROPERTY(int wateringDelay READ getWateringDelay NOTIFY wateringSettingsUpdated)

Q_SIGNALS:
    void wateringSettingsUpdated();
    void wateringSettingsSaved(bool success);

public:
    DeviceParrotPot(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceParrotPot(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceParrotPot();

    /*!
     * \brief Whether the automatic watering settings have been read from the device at least once.
     */
    bool hasWateringSettings() const;
    bool getWateringAuto() const { return (m_watering_enabled > 0); }
    float getWateringThreshold() const { return m_watering_threshold / 10.f; } //!< in % VWC
    float getWateringTarget() const { return m_watering_target / 10.f; } //!< in % VWC
    int getWateringDelay() const { return (m_watering_delay > 0) ? (m_watering_delay / 4) : 0; } //!< in hours

    /*!
     * \brief Write new automatic watering settings to the device.
     * \param enabled: automatic watering on or off. When off, only the enable flag is written,
     *                 the device keeps its previous bounds and delay.
     * \param threshold: water when the soil moisture drops below this, in %.
     * \param target: stop watering once the soil moisture reaches this, in %.
     * \param delay: wait once the threshold is reached, before watering, in hours, 0: disabled.
     * \return false if the device is busy (connecting, connected or disconnecting) and the write could not start.
     *
     * The outcome is reported with wateringSettingsSaved().
     * A value that only differs from the device one by its rounding is not rewritten,
     * so a 40.5 % set by another application stays 40.5 %.
     */
    Q_INVOKABLE bool actionWateringSettings(bool enabled, int threshold, int target, int delay);

private:
    // Services
    static constexpr QBluetoothUuid uuid_service_infos{QBluetoothUuid::ServiceClassUuid::DeviceInformation};
    static constexpr QBluetoothUuid uuid_service_battery{QBluetoothUuid::ServiceClassUuid::BatteryService};
    static inline const QBluetoothUuid uuid_service_live{QStringLiteral("39e1fa00-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_service_history{QStringLiteral("39e1fc00-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_service_clock{QStringLiteral("39e1fd00-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_service_watering{QStringLiteral("39e1f900-84a8-11e2-afba-0002a5d5c51b")};

    // Characteristics
    static constexpr QBluetoothUuid uuid_firmware{QBluetoothUuid::CharacteristicType::FirmwareRevisionString};
    static constexpr QBluetoothUuid uuid_battery_level{QBluetoothUuid::CharacteristicType::BatteryLevel};
    static inline const QBluetoothUuid uuid_live_sunlight{QStringLiteral("39e1fa01-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_soil_ec{QStringLiteral("39e1fa02-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_soil_temp{QStringLiteral("39e1fa03-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_air_temp{QStringLiteral("39e1fa04-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_led{QStringLiteral("39e1fa07-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_live_soil_moisture_cal{QStringLiteral("39e1fa09-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_clock_time{QStringLiteral("39e1fd01-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_watering_trigger{QStringLiteral("39e1f906-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_watering_tank_level{QStringLiteral("39e1f907-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_watering_threshold{QStringLiteral("39e1f903-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_watering_target{QStringLiteral("39e1f904-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_watering_delay{QStringLiteral("39e1f905-84a8-11e2-afba-0002a5d5c51b")};
    static inline const QBluetoothUuid uuid_watering_enable{QStringLiteral("39e1f90d-84a8-11e2-afba-0002a5d5c51b")};

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_clock(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_watering(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_live(QLowEnergyService::ServiceState newState);
    void serviceDiscoveryFinished();

    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyService *serviceBattery = nullptr;
    QLowEnergyService *serviceClock = nullptr;
    QLowEnergyService *serviceHistory = nullptr;
    QLowEnergyService *serviceWatering = nullptr;
    QLowEnergyService *serviceLive = nullptr;

    int m_services_pending = 0;
    int m_reads_pending = 0;

    void bleReadPending(QLowEnergyService *service, const QBluetoothUuid &uuid);
    void bleReadErrored(QLowEnergyService::ServiceError error);
    void bleWorkFinished();
    void parseLiveValues();

    // Automatic watering settings, in device units, -1 if unknown
    int m_watering_enabled = -1;        //!< f90d, 0 or 1
    int m_watering_threshold = -1;      //!< f903, 0.1 % VWC
    int m_watering_target = -1;         //!< f904, 0.1 % VWC
    int m_watering_delay = -1;          //!< f905, quarter hours

    // Automatic watering settings being written, in device units
    bool m_watering_write_ongoing = false;
    int m_watering_writes_pending = 0;
    int m_watering_write_enabled = 0;
    int m_watering_write_threshold = 0;
    int m_watering_write_target = 0;
    int m_watering_write_delay = 0;

    /*!
     * \brief Load the watering settings cached in the device settings by the last read or write.
     */
    void loadWateringSettings();

    /*!
     * \brief Update the watering settings, and cache them in the device settings.
     */
    void setWateringSettings(int enabled, int threshold, int target, int delay);

    /*!
     * \brief Queue the watering settings writes, once the watering service is discovered.
     */
    void writeWateringSettings();

    /*!
     * \brief Handle a failed characteristic write, while writing the watering settings.
     */
    void bleWriteErrored(QLowEnergyService::ServiceError error);

    /*!
     * \brief End the watering settings write, and report its outcome.
     * \param success: every write has been acknowledged by the device.
     */
    void wateringSettingsWriteFinished(bool success);

    void deviceDisconnected();
    void deviceErrored(QLowEnergyController::Error error);
    void actionTimedOut();

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_PARROTPOT_H
