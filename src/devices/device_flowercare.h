/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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

#include "device_sensor.h"

#include <cstdint>

#include <QObject>
#include <QList>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * Xiaomi "Flower Care" or VegTrug "Grow Care Home" (HHCCJCY01)
 * VegTrug "Grow Care Garden" (GCLS002)
 *
 * Protocol infos:
 * - WatchFlower/docs/flowercare-ble-api.md
 */
class DeviceFlowerCare: public DeviceSensor
{
    Q_OBJECT

public:
    DeviceFlowerCare(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceFlowerCare(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceFlowerCare();

    void parseAdvertisementData(const QByteArray &value);

public slots:
    virtual bool hasHistory() const;

private slots:
    void askForReading();

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_handshake(QLowEnergyService::ServiceState newState);
    void serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceData = nullptr;
    QLowEnergyService *serviceHandshake = nullptr;
    QLowEnergyService *serviceHistory = nullptr;
    QLowEnergyDescriptor m_notificationHandshake;
    QLowEnergyDescriptor m_notificationHistory;

    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);

    // Handshake
    QString m_deviceMacAddress;
    QByteArray m_key_challenge;
    QByteArray m_key_finish;
};

/* ************************************************************************** */
#endif // DEVICE_FLOWERCARE_H
