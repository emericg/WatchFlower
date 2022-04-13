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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_hygrotemp_clock.h"
#include "SettingsManager.h"
#include "utils/utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimeZone>

#include <QDebug>

/* ************************************************************************** */

DeviceHygrotempClock::DeviceHygrotempClock(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_CLOCK;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempClock::DeviceHygrotempClock(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_CONNECTION;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_CLOCK;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceHygrotempClock::~DeviceHygrotempClock()
{
    delete serviceData;
    delete serviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceHygrotempClock::serviceScanDone()
{
    //qDebug() << "DeviceHygrotempClock::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceHygrotempClock::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceHygrotempClock::bleReadNotify);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceHygrotempClock::serviceDetailsDiscovered_infos);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempClock::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceHygrotempClock::addLowEnergyService(" << uuid.toString() << ")";

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

    if (uuid.toString() == "{ebe0ccb0-7a0a-4b0c-8a1a-6ff2997da3a6}") // (custom) data service
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = m_bleController->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceHygrotempClock::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempClock::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            SettingsManager *sm = SettingsManager::getInstance();

            // Characteristic "Units" // 1 byte READ WRITE // 0x00 - F, 0x01 - C    READ WRITE
            {
                QBluetoothUuid u(QString("EBE0CCBE-7A0A-4B0C-8A1A-6FF2997DA3A6"));
                QLowEnergyCharacteristic chu = serviceData->characteristic(u);

                const quint8 *unit = reinterpret_cast<const quint8 *>(chu.value().constData());
                //qDebug() << "Units (0xFF: CELSIUS / 0x01: FAHRENHEIT) > " << chu.value();
                if (unit[0] == 0xFF && sm->getTempUnit() == "F")
                {
                    serviceData->writeCharacteristic(chu, QByteArray::fromHex("01"), QLowEnergyService::WriteWithResponse);
                }
                else if (unit[0] == 0x01 && sm->getTempUnit() == "C")
                {
                    serviceData->writeCharacteristic(chu, QByteArray::fromHex("FF"), QLowEnergyService::WriteWithResponse);
                }
            }

            // History
            //UUID_HISTORY = 'EBE0CCBC-7A0A-4B0C-8A1A-6FF2997DA3A6'   # Last idx 152          READ NOTIFY

            // Characteristic "Time" // 5 bytes READ WRITE
            {
                QBluetoothUuid a(QString("EBE0CCB7-7A0A-4B0C-8A1A-6FF2997DA3A6"));
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                //serviceData->readCharacteristic(cha); // trigger a new time read, not necessary

                const qint8 *timedata = reinterpret_cast<const qint8 *>(cha.value().constData());
                int8_t timezone_read = timedata[4]; Q_UNUSED(timezone_read)
                int32_t epoch_read = timedata[0];
                epoch_read += (timedata[1] << 8);
                epoch_read += (timedata[2] << 16);
                epoch_read += (timedata[3] << 24);
/*
                QDateTime time_read;
                time_read.setSecsSinceEpoch(epoch_read);
                qDebug() << "epoch READ: " << epoch_read;
                qDebug() << "QDateTime READ: " << time_read;
                qDebug() << "QTimeZone READ: " << timezone_read;
*/
                int32_t epoch_now = static_cast<int32_t>(QDateTime::currentSecsSinceEpoch()); // This device clock will not handle the year 2038...
                int8_t offset_now = static_cast<int8_t>(QDateTime::currentDateTime().offsetFromUtc() / 3600);
/*
                qDebug() << "QDateTime NOW: " << QDateTime::currentDateTime();
                qDebug() << "QTimeZone NOW: " << offset_now;
                qDebug() << "epoch NOW: " << epoch_now;
*/
                // Note: the device doesn't update its "Time" characteristic value often
                // So we don't use a single minute mismatch, but 5, to avoid reseting clock everytime
                if (std::abs(epoch_read - epoch_now) > 5*60)
                {
                    //qDebug() << "CLOCK TIME NEEDS AN UPDATE (diff: " << std::abs(epoch_read - epoch_now);

                    QByteArray timedata_write;
                    timedata_write.resize(5);
                    timedata_write[0] = static_cast<char>((epoch_now      ) & 0xFF);
                    timedata_write[1] = static_cast<char>((epoch_now >>  8) & 0xFF);
                    timedata_write[2] = static_cast<char>((epoch_now >> 16) & 0xFF);
                    timedata_write[3] = static_cast<char>((epoch_now >> 24) & 0xFF);
                    timedata_write[4] = offset_now;

                    //qDebug() << "QDateTime WRITE:" << timedata_write << " size:" << timedata_write.size();
                    serviceData->writeCharacteristic(cha, timedata_write, QLowEnergyService::WriteWithResponse);
                }
            }

            // Characteristic "Temp&Humi" // 3 bytes, READ NOTIFY
            {
                QBluetoothUuid b(QString("EBE0CCC1-7A0A-4B0C-8A1A-6FF2997DA3A6"));
                QLowEnergyCharacteristic chb = serviceData->characteristic(b);
                m_notificationDesc = chb.clientCharacteristicConfiguration();
                serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
            }

            // Characteristic "Battery level" // 1 byte READ
            {
                QBluetoothUuid b(QString("EBE0CCC4-7A0A-4B0C-8A1A-6FF2997DA3A6")); // handle 0x17
                QLowEnergyCharacteristic chb = serviceData->characteristic(b);

                int lvl = static_cast<uint8_t>(chb.value().constData()[0]);
                setBattery(lvl);
            }
        }
    }
}

void DeviceHygrotempClock::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceHygrotempClock::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            // Characteristic "Firmware Revision String"
            QBluetoothUuid c(QString("00002a26-0000-1000-8000-00805f9b34fb")); // handle 0x06
            QLowEnergyCharacteristic chc = serviceInfos->characteristic(c);
            if (chc.value().size() > 0)
            {
               QString fw = chc.value();
               setFirmware(fw);
            }

            if (m_deviceFirmware.size() == 10)
            {
                if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
            }
        }
    }
}

/* ************************************************************************** */

void DeviceHygrotempClock::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceHygrotempClock::bleWriteDone(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceHygrotempClock::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempClock::bleReadDone(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString().toUpper() == "{EBE0CCB7-7A0A-4B0C-8A1A-6FF2997DA3A6}")
    {
        // timedate

        if (value.size() == 5)
        {
            const qint8 *data = reinterpret_cast<const qint8 *>(value.constData());

            qint8 timezone_read = data[4];
            int32_t epoch_read = data[0];
            epoch_read += (data[1] << 8);
            epoch_read += (data[2] << 16);
            epoch_read += (data[3] << 24);

            QDateTime time_read;
            time_read.setSecsSinceEpoch(epoch_read);
            qDebug() << "QDateTime READ: " << time_read;
            qDebug() << "QTimeZone READ: " << timezone_read;
        }
    }
}

void DeviceHygrotempClock::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempClock::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString().toUpper() == "{EBE0CCC1-7A0A-4B0C-8A1A-6FF2997DA3A6}")
    {
        // sensor data

        if (value.size() == 3)
        {
            const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

            m_temperature = static_cast<int16_t>(data[0] + (data[1] << 8)) / 100.f;
            m_humidity = data[2];

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_dbInternal || m_dbExternal)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

                QSqlQuery addData;
                addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, temperature, humidity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :temp, :humi)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tsStr);
                addData.bindValue(":ts_full", tsFullStr);
                addData.bindValue(":temp", m_temperature);
                addData.bindValue(":humi", m_humidity);
                if (addData.exec() == false)
                    qWarning() << "> DeviceHygrotempClock addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();
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
/*
            qDebug() << "* DeviceHygrotempClock update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_humidity:" << m_humidity;
*/
        }
    }
}

void DeviceHygrotempClock::confirmedDescriptorWrite(const QLowEnergyDescriptor &d, const QByteArray &value)
{
    //qDebug() << "DeviceHygrotempClock::confirmedDescriptorWrite!";

    if (d.isValid() && d == m_notificationDesc && value == QByteArray::fromHex("0000"))
    {
        qDebug() << "confirmedDescriptorWrite() disconnect?!";

        //disabled notifications -> assume disconnect intent
        //m_control->disconnectFromDevice();
        //delete m_service;
        //m_service = nullptr;
    }
}

/* ************************************************************************** */
