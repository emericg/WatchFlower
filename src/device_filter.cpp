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

#include "device_filter.h"

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

/* ************************************************************************** */

bool DeviceFilter::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
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
    roles[LocationRole] = "location";
    roles[WaterLevelRole] = "waterlevel";
    roles[PlantNameRole] = "plant";

    roles[PointerRole] = "pointer";

    return roles;
}

int DeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
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
        if (role == DeviceModelRole) {
            if (device->getName() == "Flower care" || device->getName() == "Flower mate") {
                return "a";
            } else if (device->getName() == "ropot") {
                return "b";
            } else if (device->getName() == "MJ_HT_V1") {
                return "c";
            } else if (device->getName() == "ClearGrass Temp & RH") {
                return "d";
            } else if (device->getName() == "LYWSD02") {
                return "e";
            } else if (device->getName() == "LYWSD03MMC") {
                return "f";
            } else {
                return "z"; //return device.getName();
            }
        }
        if (role == LocationRole)
            return device->getLocationName().toLower();
        if (role == WaterLevelRole) {
            if (device->hasSoilMoistureSensor()) return device->getHumidity();
            else return 199;
        }
        if (role == PlantNameRole)
            return device->getPlantName();

        if (role == PointerRole)
            return QVariant::fromValue(device);

        // If we made it here...
        qWarning() << "Ooops missing DeviceModel role !!! " << role;
    }

    return QVariant();
}

void DeviceModel::getDevices(QList<Device *> &device)
{
    for (auto d: m_devices)
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

void DeviceModel::removeDevice(Device *d)
{
    if (d)
    {
        beginRemoveRows(QModelIndex(), m_devices.indexOf(d), m_devices.indexOf(d));
        m_devices.removeOne(d);
        delete d;
        endRemoveRows();
    }
}

void DeviceModel::sanetize()
{
    //
}

/* ************************************************************************** */
