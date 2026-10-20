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

#ifndef DEVICE_RUUVITAG_H
#define DEVICE_RUUVITAG_H
/* ************************************************************************** */

#include "device_thermometer.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Ruuvi Innovations "RuuviTag"
 * RuuviTag / RuuviTag Pro, round or rectangular body, no screen
 *
 * Advertises as "Ruuvi XXXX" (XXXX: last 2 bytes of the MAC address).
 * Ruuvi Air devices advertise with the same name, but use data formats 6 / E1.
 *
 * Protocol infos:
 * - WatchFlower/docs/ruuvitag-ble-api.md
 */
class DeviceRuuviTag: public DeviceThermometer
{
    Q_OBJECT

    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);

    bool parseRawV1(const QByteArray &ba);
    bool parseRawV2(const QByteArray &ba);

    void setValues(const float temp, const float humi, const float pres, const int battv);

    static constexpr uint16_t s_ruuvi_company_id = 0x0499;
    static constexpr uint8_t s_ruuvi_format_rawv1 = 0x03;
    static constexpr uint8_t s_ruuvi_format_rawv2 = 0x05;

public:
    DeviceRuuviTag(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceRuuviTag(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceRuuviTag();

    /*!
     * \brief Tell if an advertised device is a RuuviTag.
     * \param info: the advertised device.
     * \return true if the device name matches, and if its manufacturer data is a RuuviTag format.
     *
     * Ruuvi Air devices share the "Ruuvi XXXX" name, they are told apart by their data formats.
     */
    static bool isRuuviTag(const QBluetoothDeviceInfo &info);

    void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &value);

private:
};

/* ************************************************************************** */
#endif // DEVICE_RUUVITAG_H
