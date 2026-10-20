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

#ifndef DEVICE_INKBIRD_H
#define DEVICE_INKBIRD_H
/* ************************************************************************** */

#include "device_thermometer.h"
#include "device_environmental.h"

#include <QObject>
#include <QString>
#include <QStringList>
#include <QHash>
#include <QByteArray>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief Inkbird advertisement decoding helpers, shared by the Inkbird device classes.
 */
class DeviceInkbirdHelpers
{
public:
    DeviceInkbirdHelpers() = delete;

    static constexpr uint16_t service_uuid = 0xFFF0;

    static constexpr int size_th = 7;       //!< IBS-TH, IBS-TH2, IBS-P01B
    static constexpr int size_ith = 16;     //!< IBS-P02B, ITH-11-B, ITH-13-B, ITH-21-B
    static constexpr int size_iamt2 = 15;   //!< IAM-T2

    static constexpr int adv_seen_max = 512;

    static constexpr int co2_max = 40000;

    static inline const QString model_p01b = QStringLiteral("IBS-P01B");

    //! Values decoded from an Inkbird advertisement, -99 / -1 when not available
    struct Values
    {
        float temperature = -99.f;
        float humidity = -99.f;
        float co2 = -99.f;
        int battery = -1;
        bool noHumiditySensor = false;
    };

    /*!
     * \brief Model of an Inkbird hygrometer or thermometer, from its name.
     * \param name: device name, ex: "sps", "tps", "IBS-P02B", "ITH-11-B".
     * \return The model, empty if not a supported model.
     */
    static QString model(const QString &name);

    /*!
     * \brief Decode the manufacturer data of an Inkbird hygrometer or thermometer.
     * \param name: device name, "tps" devices may have no humidity sensor (IBS-P01B).
     * \param id: manufacturer data company ID field, the temperature on the 7 bytes models.
     * \param ba: manufacturer data.
     * \param v: decoded values.
     * \return false if the data is not a valid hygrometer layout (size, or corrupt values).
     */
    static bool parseHygrometer(const QString &name, const uint16_t id, const QByteArray &ba, Values &v);
};

/* ************************************************************************** */

/*!
 * Inkbird hygrometers and thermometers
 * IBS-TH ("sps"), IBS-TH2 / IBS-P01B ("tps"), IBS-P02B, ITH-11-B, ITH-13-B, ITH-21-B
 *
 * Identified by their name, the generic "sps" / "tps" names also need the 0xFFF0 service UUID
 * or a 7 bytes manufacturer data. The model is kept in m_deviceModel,
 * a "tps" device without humidity sensor becomes an IBS-P01B.
 *
 * On the IBS-TH / IBS-TH2 the manufacturer data company ID field is the temperature,
 * and some Bluetooth stacks (BlueZ) keep the data of previous advertisements under their old company IDs:
 * a data already seen is skipped, unless it is the last one used.
 *
 * Protocol infos:
 * - WatchFlower/docs/inkbird-ble-api.md
 */
class DeviceInkbirdHygrometer: public DeviceThermometer
{
    Q_OBJECT

public:
    DeviceInkbirdHygrometer(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceInkbirdHygrometer(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceInkbirdHygrometer();

    /*!
     * \brief Tell if an advertised device is a supported Inkbird hygrometer or thermometer.
     * \param info: the advertised device.
     */
    static bool isInkbirdHygrometer(const QBluetoothDeviceInfo &info);

    /*!
     * \brief Tell if a saved device is a supported Inkbird hygrometer or thermometer.
     * \param deviceName: the saved device name.
     */
    static bool isInkbirdHygrometer(const QString &deviceName);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    QHash <uint16_t, QByteArray> m_advSeen;    //!< Manufacturer data seen, by company ID field
    uint16_t m_advLastId = 0;                   //!< Company ID field of the last manufacturer data used
    QByteArray m_advLastData;                   //!< Last manufacturer data used

    void setup();
    void setNoHumiditySensor();
};

/* ************************************************************************** */

/*!
 * Inkbird IAM-T2 ("Ink@IAM-T2")
 * CO2, temperature and humidity monitor
 *
 * Protocol infos:
 * - WatchFlower/docs/inkbird-ble-api.md
 */
class DeviceInkbirdAirQuality: public DeviceEnvironmental
{
    Q_OBJECT

public:
    DeviceInkbirdAirQuality(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceInkbirdAirQuality(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceInkbirdAirQuality();

    /*!
     * \brief Tell if a device is an Inkbird IAM-T2.
     * \param deviceName: the advertised or saved device name.
     */
    static bool isInkbirdAirQuality(const QString &deviceName);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    void setup();
    void addDatabaseRecord();
};

/* ************************************************************************** */
#endif // DEVICE_INKBIRD_H
