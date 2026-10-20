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

#ifndef DEVICE_RUUVIAIR_H
#define DEVICE_RUUVIAIR_H
/* ************************************************************************** */

#include "device_environmental.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Ruuvi Innovations "Ruuvi Air"
 * Indoor air quality monitor, USB powered, no screen
 *
 * Advertises as "Ruuvi XXXX" (XXXX: last 2 bytes of the MAC address), like the RuuviTag,
 * and is told apart by its data formats: 6 (Bluetooth 4) and E1 (Bluetooth 5 extended advertising).
 *
 * The VOC and NOx indexes (Sensirion, unitless) are not saved,
 * the database VOC column holds concentrations.
 *
 * Protocol infos:
 * - WatchFlower/docs/ruuviair-ble-api.md
 */
class DeviceRuuviAir: public DeviceEnvironmental
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    bool parseFormat6(const QByteArray &ba);
    bool parseFormatE1(const QByteArray &ba);

    void setEnvironment(const QByteArray &ba);
    void addDatabaseRecord();

    static constexpr uint16_t s_ruuvi_company_id = 0x0499;
    static constexpr uint8_t s_ruuvi_format_air = 0x06;
    static constexpr uint8_t s_ruuvi_format_air_extended = 0xE1;

public:
    DeviceRuuviAir(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceRuuviAir(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceRuuviAir();

    /*!
     * \brief Tell if an advertised device is a Ruuvi Air.
     * \param info: the advertised device.
     * \return true if the device name matches, and if its manufacturer data is a Ruuvi Air format.
     */
    static bool isRuuviAir(const QBluetoothDeviceInfo &info);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_RUUVIAIR_H
