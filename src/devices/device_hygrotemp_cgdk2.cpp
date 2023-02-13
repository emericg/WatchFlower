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
 * \date      2021
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_hygrotemp_cgdk2.h"
#include "device_firmwares.h"
#include "utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempCGDK2::DeviceHygrotempCGDK2(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceThermometer(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempCGDK2::DeviceHygrotempCGDK2(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceThermometer(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempCGDK2::~DeviceHygrotempCGDK2()
{
    delete serviceInfos;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceHygrotempCGDK2::serviceScanDone()
{
    qDebug() << "DeviceHygrotempCGDK2::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (m_deviceFirmware.isEmpty() || m_deviceFirmware == "UNKN")
        {
            if (serviceInfos->state() == QLowEnergyService::RemoteService)
            {
                connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceHygrotempCGDK2::serviceDetailsDiscovered_infos);

                // Windows hack, see: QTBUG-80770 and QTBUG-78488
                QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
            }
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceHygrotempCGDK2::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceHygrotempCGDK2::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempCGDK2::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempCGDK2::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // Device Information service
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        serviceInfos = m_bleController->createServiceObject(uuid);
        if (!serviceInfos)
            qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
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

void DeviceHygrotempCGDK2::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempCGDK2::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

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
                if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
            }
        }
    }
}

void DeviceHygrotempCGDK2::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempCGDK2::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

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

void DeviceHygrotempCGDK2::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotempCGDK2::bleWriteDone(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceHygrotempCGDK2::bleReadDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotempCGDK2::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceHygrotempCGDK2::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempCGDK2::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{00000100-0000-1000-8000-00805f9b34fb}")
    {
        // sensor data

        if (value.size() == 7)
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
            qDebug() << "* DeviceHygrotempCGDK2 update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
*/
        }
    }
}

void DeviceHygrotempCGDK2::confirmedDescriptorWrite(const QLowEnergyDescriptor &d, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempCGDK2::confirmedDescriptorWrite!";

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

void DeviceHygrotempCGDK2::parseAdvertisementData(const uint16_t adv_mode,
                                                  const uint16_t adv_id,
                                                  const QByteArray &ba)
{
/*
    qDebug() << "DeviceHygrotempCGDK2::parseAdvertisementData(" << m_deviceAddress
             << " - " << adv_mode << " - 0x" << adv_id << ")";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    if (ba.size() == 17) // Qingping data protocol // 17 bytes messages
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());

        // Save mac address (for macOS and iOS)
        if (!hasAddressMAC())
        {
            QString mac;

            mac += ba.mid(10,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(9,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(8,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(7,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(6,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(5,1).toHex().toUpper();

            setAddressMAC(mac);
        }

        int batt = -99;
        float temp = -99.f;
        float humi = -99.f;

        // get data
        if ((data[0] == 0x04 || data[0] == 0x08 || data[0] == 0x80 || data[0] == 0x88) &&
            ((data[1] == 0x01 || data[1] == 0x07 || data[1] == 0x16) || // CGG1
             (data[1] == 0x10) || // CGDK2
             (data[1] == 0x09) || // CGP1W
             (data[1] == 0x15) || // CGF1W
             (data[1] == 0x1e) || // CGC1
             (data[1] == 0x0c) || // CGD1
             (data[1] == 0x0e || data[1] == 0x24) ||  // CGDN1
             (data[1] == 0x0f))) // CGM1
        {
            temp = static_cast<int16_t>(data[10] + (data[11] << 8)) / 10.f;
            if (temp != m_temperature)
            {
                if (temp > -30.f && temp < 100.f)
                {
                    m_temperature = temp;
                    Q_EMIT dataUpdated();
                }
            }

            humi = static_cast<int16_t>(data[12] + (data[13] << 8)) / 10.f;
            if (humi != m_humidity)
            {
                if (humi >= 0.f && humi <= 100.f)
                {
                    m_humidity = humi;
                    Q_EMIT dataUpdated();
                }
            }

            batt = static_cast<int8_t>(data[16]);
            setBattery(batt);
        }
        else
        {
            qDebug() << "Qingping data: unknown device ID >" << data[0] << data[1];
        }

        if (m_temperature > -99.f && m_humidity > -99.f)
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                addDatabaseRecord_hygrometer(m_lastUpdate.toSecsSinceEpoch(), m_temperature, m_humidity);
            }

            refreshDataFinished(true);
        }
/*
        if (batt > -99 || temp > -99.f || humi > -99.f)
        {
            qDebug() << "* CGDK2 service data:" << getName() << getAddress() << "(" << value.size() << ") bytes";
            if (batt > -99) qDebug() << "- battery:" << batt;
            if (temp > -99) qDebug() << "- temperature:" << temp;
            if (humi > -99) qDebug() << "- humidity:" << humi;
        }
*/
    }
}

/* ************************************************************************** */
