/*!
 * This file is part of WatchFlower.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_aranet2.h"

#include <cstdint>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceAranet2::DeviceAranet2(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceAranet2::DeviceAranet2(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceAranet2::~DeviceAranet2()
{
    delete serviceInfos;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceAranet2::serviceScanDone()
{
    //qDebug() << "DeviceAranet2::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceAranet2::serviceDetailsDiscovered_infos);
            connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceAranet2::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceAranet2::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceAranet2::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceAranet2::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceAranet2::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // Device Information service
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        if (m_deviceFirmware.isEmpty() || m_deviceFirmware == "UNKN")
        {
            serviceInfos = m_bleController->createServiceObject(uuid);
            if (!serviceInfos)
                qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{0000fce0-0000-1000-8000-00805f9b34fb}" ||  // (custom) Aranet service, firmware >= 1.2.0
        uuid.toString() == "{f0cd1400-95da-4f4b-9ac8-aa55d312af0c}")   // (custom) Aranet service, firmware < 1.2.0
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceAranet2::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (serviceInfos && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranet2::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Firmware Revision"
        // Note: 0x2a28 "Software Revision" holds the factory firmware version, not the current one
        QBluetoothUuid fw(QStringLiteral("00002a26-0000-1000-8000-00805f9b34fb"));
        QLowEnergyCharacteristic cfw = serviceInfos->characteristic(fw);

        if (cfw.value().size() > 0)
        {
            QString fw = cfw.value();
            setFirmware(fw);
        }
        else
        {
            serviceInfos->readCharacteristic(cfw);
        }
    }
}

void DeviceAranet2::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (serviceData && newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceAranet2::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Current Readings"
        // Note: this characteristic is only readable if the device has been paired,
        // or if "Smart Home integration" is enabled
        QBluetoothUuid rd(QStringLiteral("f0cd1504-95da-4f4b-9ac8-aa55d312af0c"));
        QLowEnergyCharacteristic crd = serviceData->characteristic(rd);

        if (crd.value().size() >= 12)
        {
            parseCurrentReadings(crd.value());
        }
        else
        {
            serviceData->readCharacteristic(crd);
        }
    }
}

/* ************************************************************************** */

void DeviceAranet2::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceAranet2::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString() == "{00002a26-0000-1000-8000-00805f9b34fb}") // Firmware Revision
    {
        if (value.size() > 0)
        {
            QString fw = value;
            setFirmware(fw);
        }
    }

    if (c.uuid().toString() == "{f0cd1504-95da-4f4b-9ac8-aa55d312af0c}") // Current Readings
    {
        parseCurrentReadings(value);
    }
}

/* ************************************************************************** */

void DeviceAranet2::parseCurrentReadings(const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    // This characteristic is shared with the Aranet Radiation and Radon models,
    // the first byte tells them apart
    if (value.size() < 12 || data[0] != 2)
    {
        refreshDataFinished(false);
        deviceDisconnect();
        return;
    }

    uint16_t interval = static_cast<uint16_t>(DeviceUtils::readLE(data, 2, 2));
    int64_t ago = static_cast<uint16_t>(DeviceUtils::readLE(data, 4, 2));

    uint16_t temp = static_cast<uint16_t>(DeviceUtils::readLE(data, 7, 2));
    uint16_t humi = static_cast<uint16_t>(DeviceUtils::readLE(data, 9, 2));

    // Readings taken while the sensor is warming up, or while it is in an error state,
    // are flagged as out of range: bit 14 for temperature, bit 15 for humidity
    if ((temp & 0x4000) || (humi & 0x8000))
    {
        refreshDataFinished(false);
        deviceDisconnect();
        return;
    }

    m_temperature = temp / 20.f;
    m_humidity = humi / 10.f;

    setBattery(data[6]);

    if (ago > interval) ago = 0; // out of sync, use current time instead

    m_lastUpdate = QDateTime::currentDateTime().addSecs(-ago);

    addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);

    refreshDataFinished(true);

    deviceDisconnect();
/*
    qDebug() << "* DeviceAranet2 update:" << getAddress();
    qDebug() << "- m_firmware:" << m_deviceFirmware;
    qDebug() << "- m_battery:" << m_deviceBattery;
    qDebug() << "- m_temperature:" << m_temperature;
    qDebug() << "- m_humidity:" << m_humidity;
*/
}

/* ************************************************************************** */
