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

#ifndef DEVICE_HYGROTEMP_LCD_H
#define DEVICE_HYGROTEMP_LCD_H
/* ************************************************************************** */

#include "device.h"

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief The DeviceHygrotempLCDLCD class
 *
 * Xiaomi MiJia "bluetooth Temperature and Humidity sensor with LCD"
 * ClearGrass "Digital bluetooth Thermometer and Hygrometer"
 *
 * Protocol infos:
 * - https://github.com/sputnikdev/eclipse-smarthome-bluetooth-binding/issues/18
 *
 * // Connect using btgatt-client:
 * - $ btgatt-client -d 4C:65:A8:D0:6D:C8
 * - > register-notify 0x000e   // temp and humidity
 * - > read-value 0x0018        // battery
 */
class DeviceHygrotempLCD: public Device
{
    Q_OBJECT

public:
    DeviceHygrotempLCD(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceHygrotempLCD(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceHygrotempLCD();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_datas(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceDatas = nullptr;
    QLowEnergyService *serviceBattery = nullptr;
    QLowEnergyService *serviceInfos = nullptr;
    QLowEnergyDescriptor m_notificationDesc;
    void confirmedDescriptorWrite(const QLowEnergyDescriptor &d, const QByteArray &value);

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_HYGROTEMP_LCD_H
