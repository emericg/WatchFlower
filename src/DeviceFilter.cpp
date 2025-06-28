/*!
 * This file is part of SmartCare.
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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DeviceFilter.h"
#include "device.h"
#include "device_sensor.h"

#include <cstdlib>
#include <cmath>

#include <QDebug>

/* ************************************************************************** */

DeviceFilter::DeviceFilter(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    //
}

DeviceFilter::~DeviceFilter()
{
    //
}

void DeviceFilter::invalidatefilter()
{
    invalidateFilter();
}

/* ************************************************************************** */

bool DeviceFilter::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceRow)
    Q_UNUSED(sourceParent)

    bool accepted = true;
/*
    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);

    if (!m_acceptedTypes.empty())
    {
        int type = sourceModel()->data(index, ShotModel::DeviceModelRole).toInt();
        if (!m_acceptedTypes.contains(type))
            accepted = false;
    }
*/
    return accepted;
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceModel::DeviceModel(QObject *parent)
    : QAbstractListModel(parent)
{
    //
}

DeviceModel::DeviceModel(const DeviceModel &other, QObject *parent)
    : QAbstractListModel(parent)
{
    m_devices = other.m_devices;
}

DeviceModel::~DeviceModel()
{
    qDeleteAll(m_devices);
    m_devices.clear();
}

/* ************************************************************************** */

QHash <int, QByteArray> DeviceModel::roleNames() const
{
    QHash <int, QByteArray> roles;

    roles[DeviceModelRole] = "model";
    roles[DeviceNameRole] = "name";
    roles[DeviceRssiRole] = "rssi";

    roles[AssociatedLocationRole] = "location";
    roles[AssociatedNameRole] = "plant";
    roles[ManualIndexRole] = "manual";

    roles[PlantNameRole] = "plant";
    roles[SoilMoistureRole] = "waterlevel";
    roles[InsideOutsideRole] = "insideoutside";

    roles[PointerRole] = "pointer";

    return roles;
}

int DeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_devices.count();
}

QVariant DeviceModel::data(const QModelIndex &index, int role) const
{
    //qDebug() << "DeviceModel::data(r:" << index.row() << "c:" << index.column();

    if (index.row() < 0 || index.row() >= m_devices.size() || !index.isValid())
        return QVariant();

    Device *device = m_devices[index.row()];
    if (device)
    {
        // hw device
        if (role == ManualIndexRole)
        {
            return device->getManualIndex();
        }
        if (role == DeviceModelRole)
        {
            if (device->getName() == "Flower care" ||
                device->getName() == "Flower mate" ||
                device->getName() == "TY" ||
                device->getName() == "Grow care garden") { /////// plant sensors
                return "aa";
            } else if (device->getName() == "Flower power") {
                return "ab";
            } else if (device->getName() == "ropot") {
                return "ac";
            } else if (device->getName() == "Parrot pot") {
                return "ad";
            } else if (device->getName() == "HiGrow") {
                return "ae";
            } else if (device->getName() == "bparasite") {
                return "af";
            } else if (device->getName() == "ThermoBeacon") { ///// thermometers
                return "ba";
            } else if (device->getName() == "MJ_HT_V1") {
                return "bb";
            } else if (device->getName() == "LYWSD02") {
                return "bc";
            } else if (device->getName() == "LYWSD03MMC") {
                return "bd";
            } else if (device->getName() == "MHO-C303") {
                return "be";
            } else if (device->getName() == "MHO-C401") {
                return "bf";
            } else if (device->getName() == "XMWSDJO4MMC") {
                return "bg";
            } else if (device->getName() == "MJWSD05MMC") {
                return "bh";
            } else if (device->getName() == "ClearGrass Temp & RH" ||
                       device->getName().startsWith("Qingping Temp & RH")) {
                return "bi";
            } else if (device->getName() == "Qingping Temp RH Lite" ) {
                return "bj";
            } else if (device->getName() == "Qingping Alarm Clock") {
                return "bk";
            } else if (device->getName() == "Qingping Temp RH Barometer") {
                return "bl";
            } else if (device->getName() == "ATC") {
                return "bz";
            } else if (device->getName().startsWith("6003#")) { //// air quality
                return "ca";
            } else if (device->getName() == "CGDN1") {
                return "cb";
            } else if (device->getName() == "JQJCY01YM") {
                return "cd";
            } else if (device->getName() == "AirQualityMonitor") {
                return "ce";
            } else if (device->getName() == "GeigerCounter") {
                return "cz";
            } else {
                return "zzz";
            }
        }
        if (role == DeviceNameRole)
        {
            return device->getName();
        }
        if (role == DeviceRssiRole)
        {
            return std::abs(device->getRssi());
        }
        // user set
        if (role == AssociatedLocationRole)
        {
            if (device->getLocationName().isEmpty())
                return "zzz";
            else
                return device->getLocationName().toLower();
        }
        if (role == AssociatedNameRole)
        {
            if (device->getAssociatedName().isEmpty())
                return "zzz";
            else
                return device->getAssociatedName();
        }
        // plant sensors
        if (role == PlantNameRole)
        {
            if (device->getAssociatedName().isEmpty())
                return "zzz";
            else
                return device->getAssociatedName();
        }
        if (role == SoilMoistureRole)
        {
            DeviceSensor *sensor = dynamic_cast<DeviceSensor *>(device);
            if (sensor && sensor->hasSoilMoistureSensor())
                if (sensor->getHumidity() > -1)
                    return sensor->getHumidity();
                else
                    return 99;
            else
                return 199;
        }
        if (role == InsideOutsideRole)
        {
            DeviceSensor *sensor = dynamic_cast<DeviceSensor *>(device);
            if (sensor && sensor->isInside())
                return 0;
            else
                return 1;
        }

        if (role == PointerRole)
            return QVariant::fromValue(device);

        // If we made it here...
        qWarning() << "Ooops missing DeviceModel role !!! " << role;
    }

    return QVariant();
}

void DeviceModel::getDevices(QList <Device *> &device)
{
    for (auto d: std::as_const(m_devices))
    {
        device.push_back(d);
    }
}

void DeviceModel::addDevice(Device *d)
{
    if (d)
    {
        beginInsertRows(QModelIndex(), getDeviceCount(), getDeviceCount());
        m_devices.push_back(d);
        endInsertRows();
    }
}

void DeviceModel::removeDevice(Device *d, bool del)
{
    if (d)
    {
        beginRemoveRows(QModelIndex(), m_devices.indexOf(d), m_devices.indexOf(d));
        m_devices.removeOne(d);
        if (del) delete d;
        endRemoveRows();
    }
}

void DeviceModel::clearDevices()
{
    for (auto d: std::as_const(m_devices))
    {
        removeDevice(d, true);
    }
}

void DeviceModel::sanetize()
{
    //
}

/* ************************************************************************** */
