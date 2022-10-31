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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_THERMOMETER_H
#define DEVICE_THERMOMETER_H
/* ************************************************************************** */

#include "device_sensor.h"

#include <QObject>
#include <QString>
#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

/* ************************************************************************** */

/*!
 * \brief The DeviceThermometer class
 */
class DeviceThermometer: public DeviceSensor
{
    Q_OBJECT

protected:
    bool areValuesValid_thermometer(const float t) const;
    bool addDatabaseRecord_thermometer(const int64_t timestamp, const float t);

    bool areValuesValid_hygrometer(const float t, const float h) const;
    bool addDatabaseRecord_hygrometer(const int64_t timestamp, const float t, const float h);

    bool areValuesValid_weatherstation(const float t, const float h, const float p) const;
    bool addDatabaseRecord_weatherstation(const int64_t timestamp, const float t, const float h, const float p);

public:
    DeviceThermometer(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceThermometer(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DeviceThermometer();

    // Chart thermometer "min/max"
    Q_INVOKABLE void updateChartData_thermometerMinMax(int maxDays);

    // Chart thermometer "AIO"
    Q_INVOKABLE void getChartData_thermometerAIO(int maxDays, QDateTimeAxis *axis,
                                                 QLineSeries *temp, QLineSeries *hygro);
};

/* ************************************************************************** */
#endif // DEVICE_THERMOMETER_H
