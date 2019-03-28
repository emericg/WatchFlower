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

#ifndef DEVICE_ROPOT_H
#define DEVICE_ROPOT_H
/* ************************************************************************** */

#include "device.h"

#include <QObject>
#include <QList>
#include <QTimer>
#include <QDateTime>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief The DeviceRopot class
 *
 * Xiaomi Mijia "Ropot" / "Flowerpot" / "Smart flower pot"
 */
class DeviceRopot: public Device
{
    Q_OBJECT

public:
    DeviceRopot(QString &deviceAddr, QString &deviceName);
    DeviceRopot(const QBluetoothDeviceInfo &d);
    ~DeviceRopot();

public slots:
    QString getDataString() const;

private:
    // QLowEnergyController related
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceData = nullptr;
    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

/* ************************************************************************** */
#endif // DEVICE_ROPOT_H
