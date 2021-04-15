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

#include "device_esp32_geiger.h"
#include "utils/utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>

/* ************************************************************************** */

DeviceEsp32Geiger::DeviceEsp32Geiger(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceSensors += DeviceUtils::SENSOR_GEIGER;
}

DeviceEsp32Geiger::DeviceEsp32Geiger(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_ENVIRONMENTAL;
    m_deviceSensors += DeviceUtils::SENSOR_GEIGER;
}

DeviceEsp32Geiger::~DeviceEsp32Geiger()
{
    if (m_bleController) m_bleController->disconnectFromDevice();

    delete serviceInfos;
    delete serviceBattery;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEsp32Geiger::serviceScanDone()
{
    //qDebug() << "DeviceEsp32Geiger::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceEsp32Geiger::serviceDetailsDiscovered_infos);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceEsp32Geiger::serviceDetailsDiscovered_battery);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceEsp32Geiger::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceEsp32Geiger::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32Geiger::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceEsp32Geiger::addLowEnergyService(" << uuid.toString() << ")";

    //if (uuid.toString() == "{0000180f-0000-1000-8000-00805f9b34fb}") // Infos service

    //if (uuid.toString() == "{0000180f-0000-1000-8000-00805f9b34fb}") // Battery service

    if (uuid.toString() == "{eeee9a32-a000-4cbd-b00b-6b519bf2780f}") // custom data service
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceEsp32Geiger::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32Geiger::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            // TODO
        }
    }
}

void DeviceEsp32Geiger::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32Geiger::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceBattery)
        {
            // Characteristic "Battery Level"
            QBluetoothUuid uuid_batterylevel(QString("00002a19-0000-1000-8000-00805f9b34fb"));
            QLowEnergyCharacteristic cbat = serviceBattery->characteristic(uuid_batterylevel);

            if (cbat.value().size() == 1)
            {
                int lvl = static_cast<uint8_t>(cbat.value().constData()[0]);
                updateBattery(lvl);
            }
        }
    }
}

void DeviceEsp32Geiger::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32Geiger::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            QBluetoothUuid f(QString("eeee9a32-a002-4cbd-b00b-6b519bf2780f")); // handle 0x? // firmware version
            QLowEnergyCharacteristic chf = serviceData->characteristic(f);
            if (chf.value().size() > 0)
            {
                m_deviceFirmware = chf.value();
            }
            if (m_deviceFirmware.size() == 3)
            {
                if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_ESP32_GEIGER))
                {
                    m_firmware_uptodate = true;
                }
            }

            Q_EMIT sensorUpdated();

            QBluetoothUuid d(QString("eeee9a32-a0c1-4cbd-b00b-6b519bf2780f")); // handle 0x? // recap data
            QLowEnergyCharacteristic chd = serviceData->characteristic(d);

            m_rh = chd.value().toFloat();
            m_rm = chd.value().toFloat();
            m_rs = chd.value().toFloat();
            Q_EMIT dataUpdated();

            QBluetoothUuid rt(QString("eeee9a32-a0c0-4cbd-b00b-6b519bf2780f")); // handle 0x? // rt data
            QLowEnergyCharacteristic chrt = serviceData->characteristic(rt);
            m_notificationDesc = chrt.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
            serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32Geiger::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceEsp32Geiger::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{x}")
    {
        Q_UNUSED(data);
    }
}

void DeviceEsp32Geiger::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceEsp32Geiger::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{eeee9a32-a0c0-4cbd-b00b-6b519bf2780f}")
    {
        // Geiger Counter realtime data // handle 0x?

        if (value.size() > 0)
        {
            Q_UNUSED(data);
            m_rh = value.toFloat();
            m_rm = value.toFloat();
            m_rs = value.toFloat();

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_dbInternal || m_dbExternal)
            {
                //
            }

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshDataRealtime(true);
            }
            else
            {
                refreshDataFinished(true);
                m_bleController->disconnectFromDevice();
            }

#ifndef QT_NO_DEBUG
            //qDebug() << "* DeviceEsp32Geiger update:" << getAddress();
            //qDebug() << "- m_firmware:" << m_deviceFirmware;
            //qDebug() << "- m_battery:" << m_deviceBattery;
            //qDebug() << "- radioactivity min:" << m_rm;
            //qDebug() << "- radioactivity sec:" << m_rs;
#endif
        }
    }
}

/* ************************************************************************** */
