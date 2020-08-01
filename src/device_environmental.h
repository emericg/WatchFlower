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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_ENVIRONMENTAL_H
#define DEVICE_ENVIRONMENTAL_H
/* ************************************************************************** */

#include <QObject>

#include "device.h"

/* ************************************************************************** */

/*!
 * \brief The DeviceEnvironmental class
 */
class DeviceEnvironmental: public Device
{
    Q_OBJECT

    Q_PROPERTY(float deviceRadioactivityH READ getRH NOTIFY dataUpdated)
    Q_PROPERTY(float deviceRadioactivityM READ getRM NOTIFY dataUpdated)
    Q_PROPERTY(float deviceRadioactivityS READ getRS NOTIFY dataUpdated)

protected:
    // specific data
    float m_rh = 999.f;
    float m_rm = -99.f;
    float m_rs = -99.f;

public:
    DeviceEnvironmental(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceEnvironmental(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DeviceEnvironmental();

public slots:
    float getRH() { return m_rh; }
    float getRM() { return m_rm; }
    float getRS() { return m_rs; }
};

/* ************************************************************************** */
#endif // DEVICE_ENVIRONMENTAL_H
