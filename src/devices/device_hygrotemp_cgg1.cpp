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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_hygrotemp_cgg1.h"
#include "device_firmwares.h"
#include "utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempCGG1::DeviceHygrotempCGG1(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    if (deviceName == "ClearGrass Temp & RH") m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempCGG1::DeviceHygrotempCGG1(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    if (d.name() == "ClearGrass Temp & RH") m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempCGG1::~DeviceHygrotempCGG1()
{
    delete serviceInfos;
    delete serviceBattery;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceHygrotempCGG1::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempCGG1::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (m_deviceFirmware.isEmpty() || m_deviceFirmware == "UNKN")
        {
            if (serviceInfos->state() == QLowEnergyService::RemoteService)
            {
                connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceHygrotempCGG1::serviceDetailsDiscovered_infos);

                // Windows hack, see: QTBUG-80770 and QTBUG-78488
                QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
            }
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceHygrotempCGG1::serviceDetailsDiscovered_battery);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceHygrotempCGG1::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceHygrotempCGG1::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempCGG1::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempCGG1::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // Device Information service
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        serviceInfos = m_bleController->createServiceObject(uuid);
        if (!serviceInfos)
            qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
    }

    if (uuid.toString() == "{0000180f-0000-1000-8000-00805f9b34fb}") // Battery service
    {
        delete serviceBattery;
        serviceBattery = nullptr;

        serviceBattery = m_bleController->createServiceObject(uuid);
        if (!serviceBattery)
            qWarning() << "Cannot create service (battery) for uuid:" << uuid.toString();
    }

    if (uuid.toString() == "{22210000-554a-4546-5542-46534450464d}") // (custom) data service
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceHygrotempCGG1::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempCGG1::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            // Characteristic "Firmware Revision String"
            QBluetoothUuid c(QStringLiteral("00002a26-0000-1000-8000-00805f9b34fb"));
            QLowEnergyCharacteristic chc = serviceInfos->characteristic(c);
            if (chc.value().size() > 0)
            {
               QString fw = chc.value();
               setFirmware(fw);
            }

            if (m_deviceFirmware.size() == 10)
            {
                if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_CGG1))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
            }
        }
    }
}

void DeviceHygrotempCGG1::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempCGG1::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceBattery)
        {
            // Characteristic "Battery Level"
            QBluetoothUuid uuid_batterylevel(QStringLiteral("00002a19-0000-1000-8000-00805f9b34fb"));
            QLowEnergyCharacteristic cbat = serviceBattery->characteristic(uuid_batterylevel);

            if (cbat.value().size() == 1)
            {
                int lvl = static_cast<uint8_t>(cbat.value().constData()[0]);
                setBattery(lvl);
            }
        }
    }
}

void DeviceHygrotempCGG1::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempCGG1::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            // hygrotemp readings
            {
                QBluetoothUuid a(QStringLiteral("00000100-0000-1000-8000-00805f9b34fb"));
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                m_notificationDesc = cha.clientCharacteristicConfiguration();
                serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
            }
        }
    }
}
/* ************************************************************************** */

void DeviceHygrotempCGG1::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotempCGG1::bleWriteDone(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceHygrotempCGG1::bleReadDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotempCGG1::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceHygrotempCGG1::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempCGG1::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{00000100-0000-1000-8000-00805f9b34fb}")
    {
        // sensor data

        if (value.size() == 6)
        {
            m_temperature = static_cast<int16_t>(data[2] + (data[3] << 8)) / 10.f;
            m_humidity = static_cast<int16_t>(data[4] + (data[5] << 8)) / 10;

            m_lastUpdate = QDateTime::currentDateTime();
            addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();
            }
            else
            {
                refreshDataFinished(true);
                m_bleController->disconnectFromDevice();
            }
/*
            qDebug() << "* DeviceHygrotempCGG1 update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
*/
        }
    }
}

void DeviceHygrotempCGG1::confirmedDescriptorWrite(const QLowEnergyDescriptor &d, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempCGG1::confirmedDescriptorWrite!";

    if (d.isValid() && d == m_notificationDesc && value == QByteArray::fromHex("0000"))
    {
        //qDebug() << "confirmedDescriptorWrite() disconnect?!";

        //disabled notifications -> assume disconnect intent
        //m_control->disconnectFromDevice();
        //delete m_service;
        //m_service = nullptr;
    }
}

/* ************************************************************************** */

void DeviceHygrotempCGG1::parseAdvertisementData(const uint16_t adv_mode,
                                                 const uint16_t adv_id,
                                                 const QByteArray &ba)
{
/*
    qDebug() << "DeviceHygrotempCGG1::parseAdvertisementData()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (parseBeaconQingping(adv_mode, adv_id, ba))
    {
        if (m_temperature > -99.f && m_humidity > -99.f)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);

                refreshDataFinished(true);
            }
            else
            {
                refreshAdvertisement();
            }
/*
            qDebug() << "* Qingping service data:" << getName() << getAddress();
            if (m_deviceBattery > -99) qDebug() << "- battery:" << m_deviceBattery;
            if (m_temperature > -99) qDebug() << "- temperature:" << m_temperature;
            if (m_humidity > -99) qDebug() << "- humidity:" << m_humidity;
*/
        }
    }
}

/* ************************************************************************** */
