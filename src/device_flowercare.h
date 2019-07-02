/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_FLOWERCARE_H
#define DEVICE_FLOWERCARE_H
/* ************************************************************************** */

#include "device.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief The DeviceFlowercare class
 *
 * Xiaomi "Flower Care" / "Mi Flora" / ...
 *
 * Protocol infos:
 * - https://github.com/barnybug/miflora
 * - https://github.com/open-homeautomation/miflora
 * - https://github.com/sandeepmistry/node-flower-power
 *
 * Connection steps:
 * 1/ Connect to device MAC address (prefix should be C4:7C:8D:xx:xx:xx)
 * 2/ Use QBluetoothUuid::GenericTelephony service
 * 2a/ Read _HANDLE_READ_NAME(0x03) if you care
 * 2b/ Read _HANDLE_READ_VERSION_BATTERY(0x38)
 *     - byte 0: battery level percentage
 *     - bytes 2-5: firmware version (ASCII)
 * 3/ If (firmware version >= 2.6.6) then write _DATA_MODE_CHANGE = bytes([0xA0, 0x1F]) to _HANDLE_WRITE_MODE_CHANGE(0x33)
 * 4/ Read _HANDLE_READ_SENSOR_DATA(0x35)
 *    * the sensor should return 16 bytes (values are encoded in little endian):
 *    - bytes 0-1: temperature in 0.1°C
 *    - byte 2: unknown
 *    - bytes 3-4: brightness in lumens
 *    - bytes 5-6: unknown
 *    - byte 7: hygrometry
 *    - byte 8-9: conductivity in µS/cm
 *    - bytes 10-15: unknown
 * 5/ Disconnect (or let the device disconnect you after a couple of seconds)
 *
 * // Connect using btgatt-client:
 * - $ btgatt-client -d C4:7C:8D:xx:xx:xx
 * - > write-value 0x0033 0xA0 0x1F // required if firmware version >= 2.6.6
 * - > read-value 0x0035            // the 16b of datas
 *
 * // Connect using gattool (DEPRECATED):
 * - $ gatttool -b C4:7C:8D:xx:xx:xx -I
 * - > connect
 * - > char-write-req 0x0033 A01F   // required if firmware version >= 2.6.6
 * - > char-read-hnd 35             // the 16b of datas
 */
class DeviceFlowercare: public Device
{
    Q_OBJECT

public:
    DeviceFlowercare(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceFlowercare(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceFlowercare();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceDatas = nullptr;
    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_FLOWERCARE_H
