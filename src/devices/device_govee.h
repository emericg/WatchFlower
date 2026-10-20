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

#ifndef DEVICE_GOVEE_H
#define DEVICE_GOVEE_H
/* ************************************************************************** */

#include "device_thermometer.h"
#include "device_environmental.h"

#include <QObject>
#include <QString>
#include <QStringList>
#include <QByteArray>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief Govee advertisement decoding helpers, shared by the Govee device classes.
 */
class DeviceGoveeHelpers
{
public:
    DeviceGoveeHelpers() = delete;

    static constexpr uint16_t id_ec88 = 0xEC88;     //!< Manufacturer data company ID field
    static constexpr uint16_t id_0001 = 0x0001;     //!< Manufacturer data company ID field
    static constexpr uint16_t id_8801 = 0x8801;     //!< Manufacturer data company ID field

    static constexpr int ibeacon_suffix_size = 25;  //!< iBeacon frame glued by some firmwares

    //! Values decoded from a Govee advertisement, -99 / -1 when not available
    struct Values
    {
        float temperature = -99.f;
        float humidity = -99.f;
        float pm25 = -99.f;
        float co2 = -99.f;
        int battery = -1;
    };

    /*!
     * \brief Model of a Govee device, from its name.
     * \param name: device name, ex: "GVH5102_C1B9", "Govee_H5179_3CD5", "GV5140303A", "B51782BC8".
     * \return The model, ex: "H5102", "GV5179", empty if the name is not a Govee model name.
     */
    static QString model(const QString &name);

    //! \return The models with the packed temperature / humidity / battery layout, company ID field 0x0001
    static const QStringList &packed0001();

    //! \return true if the temperature and humidity are within the sensors range
    static bool isValid(const float temperature, const float humidity);

    /*!
     * \brief Packed temperature / humidity, 3 bytes big endian, bit 23 is the temperature sign.
     */
    static void unpackTemperatureHumidity(const QByteArray &ba, int pos, Values &v);

    /*!
     * \brief Sensor error (bit 7) and battery level (bits 0-6) byte.
     * \return true if the sensor reports an error.
     */
    static bool unpackErrorBattery(const uint8_t b, Values &v);

    /*!
     * \brief Decode the manufacturer data of a Govee device.
     * \param model: device model, see model().
     * \param id: manufacturer data company ID field.
     * \param ba: manufacturer data.
     * \param v: decoded values.
     * \return false if the data is not the layout of that model.
     */
    static bool parse(const QString &model, const uint16_t id, QByteArray ba, Values &v);
};

/* ************************************************************************** */

/*!
 * Govee hygrometers
 * H5072, H5075, H5129, H5074, H5051, H5052, H5071 (company ID field 0xEC88),
 * H5100 to H5105, H5108, H5110, H5174, H5177, GV5179, H5178, H5112 (0x0001),
 * H5179 (0x8801)
 *
 * Identified by their name ("GVH5102_C1B9", "Govee_H5179_3CD5", "B51782BC8", "GV5112AC3D"...),
 * the model is kept in m_deviceModel.
 * H5178: main unit values only, the remote sensor is ignored.
 * H5112: probe 1 values only (temperature and humidity), probe 2 is ignored.
 *
 * Protocol infos:
 * - WatchFlower/docs/govee-ble-api.md
 */
class DeviceGoveeHygrometer: public DeviceThermometer
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    void setup();

public:
    DeviceGoveeHygrometer(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceGoveeHygrometer(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceGoveeHygrometer();

    /*!
     * \brief Tell if a device is a supported Govee hygrometer.
     * \param deviceName: the advertised device name.
     * \return true if the name holds the model of a supported Govee hygrometer.
     */
    static bool isGoveeHygrometer(const QString &deviceName);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);
};

/* ************************************************************************** */

/*!
 * Govee air quality monitors
 * H5106 (temperature, humidity, PM2.5), H5140 (temperature, humidity, CO2), company ID field 0x0001
 *
 * Identified by their name ("GVH5106_4E05", "GV5140303A"...), the model is kept in m_deviceModel.
 *
 * Protocol infos:
 * - WatchFlower/docs/govee-ble-api.md
 */
class DeviceGoveeAirQuality: public DeviceEnvironmental
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    void setup();
    void addDatabaseRecord();

public:
    DeviceGoveeAirQuality(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceGoveeAirQuality(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceGoveeAirQuality();

    /*!
     * \brief Tell if a device is a supported Govee air quality monitor.
     * \param deviceName: the advertised device name.
     * \return true if the name holds the model of a supported Govee air quality monitor.
     */
    static bool isGoveeAirQuality(const QString &deviceName);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_GOVEE_H
