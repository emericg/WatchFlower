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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DeviceManager.h"

#include <QBluetoothDeviceInfo>
#include <QList>
#include <QDebug>

/* ************************************************************************** */

void DeviceManager::updateBleDevice_simple(const QBluetoothDeviceInfo &info)
{
    updateBleDevice(info, QBluetoothDeviceInfo::Field::None);
}

void DeviceManager::updateBleDevice(const QBluetoothDeviceInfo &info,
                                    QBluetoothDeviceInfo::Fields updatedFields)
{
    //qDebug() << "updateBleDevice() " << info.name() << info.address(); // << info.deviceUuid(); // << " updatedFields: " << updatedFields;

    Q_UNUSED(updatedFields) // We don't use QBluetoothDeviceInfo::Fields, it's unreliable

    //if (!info.isValid()) return; // skip invalid devices
    //if (info.isCached()) return; // we probably just hit the device cache
    if (info.rssi() >= 0) return; // we probably just hit the device cache
    if (info.name().isEmpty()) return; // skip beacons
    if (info.name().replace('-', ':') == info.address().toString()) return; // skip beacons

    // Supported devices ///////////////////////////////////////////////////////

    for (auto d: qAsConst(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        if (dd && dd->getAddress() == info.deviceUuid().toString())
#else
        if (dd && dd->getAddress() == info.address().toString())
#endif
        {
            if (!dd->isEnabled()) return;

            //dd->setName(info.name());
            //dd->setRssi(info.rssi());

            // Handle advertisement //

            const QList<quint16> &manufacturerIds = info.manufacturerIds();
            for (const auto id: manufacturerIds)
            {
                //qDebug() << info.name() << info.address() << Qt::hex
                //         << "ID" << id
                //         << "manufacturer data" << Qt::dec << info.manufacturerData(id).count() << Qt::hex
                //         << "bytes:" << info.manufacturerData(id).toHex();

                dd->parseAdvertisementData(DeviceUtils::BLE_ADV_MANUFACTURERDATA, id, info.manufacturerData(id));
            }

            const QList<QBluetoothUuid> &serviceIds = info.serviceIds();
            for (const auto id: serviceIds)
            {
                //qDebug() << info.name() << info.address() << Qt::hex
                //         << "ID" << id
                //         << "service data" << Qt::dec << info.serviceData(id).count() << Qt::hex
                //         << "bytes:" << info.serviceData(id).toHex();

                dd->parseAdvertisementData(DeviceUtils::BLE_ADV_SERVICEDATA, id.toUInt16(), info.serviceData(id));
            }

            // Dynamic updates //
            if (m_listening && dd->hasBluetoothConnection())
            {
                // old or no data: go for refresh
                // also, check if we didn't already fail to update in the last couple minutes
                if (dd->needsUpdateDb() && !dd->isErrored())
                {
                    if (!m_devices_updating_queue.contains(dd) && !m_devices_updating.contains(dd))
                    {
                        m_devices_updating_queue.push_back(dd);
                        dd->refreshQueued();
                        refreshDevices_continue();
                    }
                }
            }

            return;
        }
    }

    if (m_scanning) // Dynamic scanning ////////////////////////////////////////
    {
        //qDebug() << "addBleDevice(" << info.name() << ") FROM DYNAMIC SCANNING";
        addBleDevice(info);
    }
}

/* ************************************************************************** */
