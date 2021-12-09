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

#include "device_esp32_higrow.h"
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

DeviceEsp32HiGrow::DeviceEsp32HiGrow(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceEsp32HiGrow::DeviceEsp32HiGrow(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceEsp32HiGrow::~DeviceEsp32HiGrow()
{
    if (m_bleController) m_bleController->disconnectFromDevice();

    delete serviceInfos;
    delete serviceBattery;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEsp32HiGrow::serviceScanDone()
{
    //qDebug() << "DeviceEsp32HiGrow::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceEsp32HiGrow::serviceDetailsDiscovered_infos);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceEsp32HiGrow::serviceDetailsDiscovered_battery);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceEsp32HiGrow::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceEsp32HiGrow::bleReadDone);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceEsp32HiGrow::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32HiGrow::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceEsp32HiGrow::addLowEnergyService(" << uuid.toString() << ")";

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

    if (uuid.toString() == "{eeee9a32-a000-4cbd-b00b-6b519bf2780f}") // (custom) data service
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceEsp32HiGrow::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32HiGrow::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            QBluetoothUuid f(QString("00002a24-a002-4cbd-b00b-6b519bf2780f")); // firmware version
            QLowEnergyCharacteristic chf = serviceInfos->characteristic(f);

            if (chf.value().size() > 0)
            {
                QString fw = chf.value();
                setFirmware(fw);
            }
        }
    }
}

void DeviceEsp32HiGrow::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32HiGrow::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceBattery)
        {
            // Characteristic "Battery level"
            QBluetoothUuid uuid_batterylevel(QString("00002a19-0000-1000-8000-00805f9b34fb"));
            QLowEnergyCharacteristic cbat = serviceBattery->characteristic(uuid_batterylevel);

            if (cbat.value().size() == 1)
            {
                int lvl = static_cast<uint8_t>(cbat.value().constData()[0]);
                setBattery(lvl);
            }
        }
    }
}

void DeviceEsp32HiGrow::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceEsp32HiGrow::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            QBluetoothUuid rt(QString("eeee9a32-a0c0-4cbd-b00b-6b519bf2780f")); // rt data
            QLowEnergyCharacteristic chrt = serviceData->characteristic(rt);
            m_notificationDesc = chrt.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
            serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
        }
    }
}

/* ************************************************************************** */

void DeviceEsp32HiGrow::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceEsp32HiGrow::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{eeee9a32-a0c0-4cbd-b00b-6b519bf2780f}")
    {
        // HiGrow realtime data

        if (value.size() == 16)
        {
            m_soilMoisture = data[0];
            m_soilConductivity = static_cast<uint16_t>(data[1] + (data[2] << 8));
            //m_soil_temperature = static_cast<uint16_t>(data[3] + (data[4] << 8));
            m_temperature = static_cast<uint16_t>(data[5] + (data[6] << 8)) / 10.f;
            m_humidity = data[7];
            m_luminosityLux = static_cast<uint32_t>(data[8] + (data[9] << 8) + (data[10] << 16));
            //m_pressure = static_cast<uint16_t>(data[11] + (data[12] << 8));

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_dbInternal || m_dbExternal)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addData;
                addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, soilMoisture, soilConductivity, temperature, humidity, luminosity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :hygro, :condu, :temp, :humi, :lumi)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tsStr);
                addData.bindValue(":ts_full", tsFullStr);
                addData.bindValue(":hygro", m_soilMoisture);
                addData.bindValue(":condu", m_soilConductivity);
                addData.bindValue(":temp", m_temperature);
                addData.bindValue(":humi", m_humidity);
                addData.bindValue(":lumi", m_luminosityLux);
                if (addData.exec() == false)
                    qWarning() << "> DeviceEsp32HiGrow addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();

                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceFirmware = :firmware, deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":firmware", m_deviceFirmware);
                updateDevice.bindValue(":battery", m_deviceBattery);
                updateDevice.bindValue(":deviceAddr", getAddress());
                if (updateDevice.exec() == false)
                    qWarning() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":" << updateDevice.lastError().text();

                m_lastUpdateDatabase = m_lastUpdate;
            }

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();
            }
            else
            {
                refreshDataFinished(true);
                m_bleController->disconnectFromDevice();
            }

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceEsp32HiGrow update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_soil_moisture:" << m_soilMoisture;
            qDebug() << "- m_soil_conductivity:" << m_soilConductivity;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
            qDebug() << "- m_luminosity:" << m_luminosityLux;
#endif
        }
    }
}

/* ************************************************************************** */
