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

#ifndef DEVICE_SWITCHBOT_H
#define DEVICE_SWITCHBOT_H
/* ************************************************************************** */

#include "device_thermometer.h"
#include "device_environmental.h"

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QByteArray>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief SwitchBot advertisement decoding helpers, shared by the SwitchBot device classes.
 */
class DeviceSwitchBotHelpers
{
public:
    DeviceSwitchBotHelpers() = delete;

    static constexpr uint16_t service_uuid = 0xFD3D;
    static constexpr uint16_t company_id = 0x0969;

    static inline const QString model_meter_pro_co2 = QStringLiteral("Meter Pro CO2");
    static inline const QString model_weather_station = QStringLiteral("Weather Station");

    //! Values decoded from a SwitchBot advertisement, -99 / -1 when not available
    struct Values
    {
        float temperature = -99.f;
        float humidity = -99.f;
        float co2 = -99.f;
        int battery = -1;
    };

    /*!
     * \brief Model of a SwitchBot device, from the model identifier of its service data.
     * \param svd: 0xFD3D service data, byte 0 bits 6-0 model, or a 4 bytes model identifier at the end.
     * \return The model, empty if not a supported model.
     */
    static QString modelFromServiceData(const QByteArray &svd);

    //! \return The model of a SwitchBot device from its name, empty if unknown
    static QString modelFromName(const QString &name);

    //! \return The model of an advertised SwitchBot device, from its service data, else from its name
    static QString model(const QBluetoothDeviceInfo &info);

    //! \return The models of the SwitchBot hygrometers
    static const QStringList &hygrometers();

    /*!
     * \brief Temperature / humidity, 3 bytes.
     *
     * [0] bits 3-0 decimal part (0.1 °C), [1] bit 7 sign (1 positive), bits 6-0 integer part (°C),
     * [2] bit 7 °F display, bits 6-0 humidity (%). Both 0 means no measurement.
     */
    static void decodeTemperatureHumidity(const QByteArray &ba, int pos, Values &v);

    /*!
     * \brief Decode the latest service data and manufacturer data of a SwitchBot device.
     * \param model: device model, see modelFromServiceData().
     * \param svd: latest 0xFD3D service data.
     * \param mfd: latest 0x0969 manufacturer data.
     * \param v: decoded values.
     */
    static void parse(const QString &model, const QByteArray &svd, const QByteArray &mfd, Values &v);

    /*!
     * \brief Keep the latest SwitchBot service data or manufacturer data.
     * \return false if the data is not a SwitchBot one, or if it is encrypted (service data bit 7).
     */
    static bool keep(const uint16_t adv_mode, const uint16_t adv_id,
                     const QByteArray &ba, QByteArray &svd, QByteArray &mfd);
};

/* ************************************************************************** */

/*!
 * SwitchBot (Woan Technology) hygrometers
 * Meter, Meter Plus, Meter Pro, Indoor/Outdoor Thermo-Hygrometer, Weather Station
 *
 * Identified by the model identifier of their service data (0xFD3D), else by their name
 * ("WoSensorTH", "WoSensorTHPlus", "WoSensorTHP", "WoIOSensorTH"), the model is kept in m_deviceModel.
 * The values are split between the service data and the manufacturer data (0x0969) of the same advertisement,
 * the latest of each is kept and they are decoded together.
 *
 * Protocol infos:
 * - WatchFlower/docs/switchbot-ble-api.md
 */
class DeviceSwitchBotHygrometer: public DeviceThermometer
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    QByteArray m_serviceData;       //!< Latest 0xFD3D service data
    QByteArray m_manufacturerData;  //!< Latest 0x0969 manufacturer data

    void setup(const QByteArray &serviceData);

public:
    DeviceSwitchBotHygrometer(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceSwitchBotHygrometer(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceSwitchBotHygrometer();

    /*!
     * \brief Tell if an advertised device is a supported SwitchBot hygrometer.
     * \param info: the advertised device.
     * \return true if its service data model identifier, or its name, is a supported hygrometer.
     */
    static bool isSwitchBotHygrometer(const QBluetoothDeviceInfo &info);

    /*!
     * \brief Tell if a saved device is a supported SwitchBot hygrometer.
     * \param deviceName: the saved device name.
     * \param deviceModel: the saved device model.
     */
    static bool isSwitchBotHygrometer(const QString &deviceName, const QString &deviceModel);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);
};

/* ************************************************************************** */

/*!
 * SwitchBot (Woan Technology) "Meter Pro CO2"
 * CO2, temperature and humidity monitor
 *
 * Identified by the model identifier of its service data (0xFD3D), else by its name ("WoSensorTHPc").
 * The values are split between the service data and the manufacturer data (0x0969) of the same advertisement,
 * the latest of each is kept and they are decoded together.
 *
 * Protocol infos:
 * - WatchFlower/docs/switchbot-ble-api.md
 */
class DeviceSwitchBotAirQuality: public DeviceEnvironmental
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    QByteArray m_serviceData;       //!< Latest 0xFD3D service data
    QByteArray m_manufacturerData;  //!< Latest 0x0969 manufacturer data

    void setup();
    void addDatabaseRecord();

public:
    DeviceSwitchBotAirQuality(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceSwitchBotAirQuality(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceSwitchBotAirQuality();

    /*!
     * \brief Tell if an advertised device is a SwitchBot Meter Pro CO2.
     * \param info: the advertised device.
     * \return true if its service data model identifier, or its name, is a Meter Pro CO2.
     */
    static bool isSwitchBotAirQuality(const QBluetoothDeviceInfo &info);

    /*!
     * \brief Tell if a saved device is a SwitchBot Meter Pro CO2.
     * \param deviceName: the saved device name.
     * \param deviceModel: the saved device model.
     */
    static bool isSwitchBotAirQuality(const QString &deviceName, const QString &deviceModel);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_SWITCHBOT_H
