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
 * \date      2021
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_thermobeacon.h"
#include "SettingsManager.h"
#include "utils/utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimeZone>

#include <QDebug>

/* ************************************************************************** */

DeviceThermoBeacon::DeviceThermoBeacon(QString &deviceAddr, QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceThermoBeacon::DeviceThermoBeacon(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
}

DeviceThermoBeacon::~DeviceThermoBeacon()
{
    delete serviceInfos;
    delete serviceData;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceThermoBeacon::serviceScanDone()
{
    //qDebug() << "DeviceThermoBeacon::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceThermoBeacon::serviceDetailsDiscovered_infos);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(); });
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceThermoBeacon::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicChanged, this, &DeviceThermoBeacon::bleReadNotify);
            //connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceThermoBeacon::bleReadDone);
            connect(serviceData, &QLowEnergyService::characteristicWritten, this, &DeviceThermoBeacon::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceThermoBeacon::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceThermoBeacon::addLowEnergyService(" << uuid.toString() << ")";
/*
    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // infos
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        //if (m_deviceFirmware.isEmpty() || m_deviceFirmware == "UNKN")
        {
            serviceInfos = controller->createServiceObject(uuid);
            if (!serviceInfos)
                qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
        }
    }
*/
    if (uuid.toString() == "{0000ffe0-0000-1000-8000-00805f9b34fb}") // (unknown service) // data
    {
        delete serviceData;
        serviceData = nullptr;

        serviceData = controller->createServiceObject(uuid);
        if (!serviceData)
            qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
    }
}

/* ************************************************************************** */

void DeviceThermoBeacon::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceThermoBeacon::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData)
        {
            QBluetoothUuid uuid_rx(QString("0000FFF3-0000-1000-8000-00805F9B34FB")); // handle 0x24
            QBluetoothUuid uuid_tx(QString("0000FFF5-0000-1000-8000-00805F9B34FB")); // handle 0x21

            // Characteristic "RX" // NOTIFY
            {
                QLowEnergyCharacteristic crx = serviceData->characteristic(uuid_rx);
                m_notificationDesc = crx.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
                serviceData->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
            }

            // Characteristic "TX" // WRITE
            {
                QLowEnergyCharacteristic ctx = serviceData->characteristic(uuid_tx);

                //serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0300000000"), QLowEnergyService::WriteWithoutResponse);
                //DATA: 0x "0300000000036101000000000504000000000000"
                // return 1 pair of data // almost same as 07 ?

                //serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0500000000"), QLowEnergyService::WriteWithResponse);
                // no resp on RX // unknown command

                //serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0600000000"), QLowEnergyService::WriteWithResponse);
                // no resp on RX // unknown command

                //serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0700000000"), QLowEnergyService::WriteWithoutResponse);
                //DATA: 0x "0700000000037901730172015a025e025e020000"
                // return 3 pair of data

                //serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0800000000"), QLowEnergyService::WriteWithResponse);
                // no resp on RX // unknown command

                //serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0900000000"), QLowEnergyService::WriteWithResponse);
                // no resp on RX // unknown command

                if (m_ble_action == DeviceUtils::ACTION_UPDATE ||
                    m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
                {
                    // Ask the device for entry count
                    serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0100000000"), QLowEnergyService::WriteWithoutResponse);
                }

                if (m_ble_action == DeviceUtils::ACTION_CLEAR_HISTORY)
                {
                    serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0200000000"), QLowEnergyService::WriteWithoutResponse);
                    // no resp on RX, 3 slow blinks
                }

                if (m_ble_action == DeviceUtils::ACTION_LED_BLINK)
                {
                    serviceData->writeCharacteristic(ctx, QByteArray::fromHex("0400000000"), QLowEnergyService::WriteWithoutResponse);
                    // no resp on RX, many fast blinks
                }
            }
        }
    }
}

void DeviceThermoBeacon::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        //qDebug() << "DeviceThermoBeacon::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            //
        }
    }
}

/* ************************************************************************** */

void DeviceThermoBeacon::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    qDebug() << "DeviceThermoBeacon::bleWriteDone(" << m_deviceAddress << ")";
    qDebug() << "DATA: 0x" << value.toHex();

    Q_UNUSED(c)
    Q_UNUSED(value)
}

void DeviceThermoBeacon::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    qDebug() << "DeviceThermoBeacon::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "DATA: 0x" << value.toHex();

    Q_UNUSED(c)
    Q_UNUSED(value)
}

void DeviceThermoBeacon::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    qDebug() << "DeviceThermoBeacon::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "DATA: 0x" << value.toHex();

    QBluetoothUuid uuid_rx(QString("0000FFF3-0000-1000-8000-00805F9B34FB"));
    QBluetoothUuid uuid_tx(QString("0000FFF5-0000-1000-8000-00805F9B34FB"));

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid() == uuid_rx)
    {
        // Parse entry count
        if (data[0] == 01)
        {
            m_history_entry_count = static_cast<int16_t>(data[1] + (data[2] << 8));
            if (m_history_entry_read < 0) m_history_entry_read = 0;

            if (m_device_time < 0)
            {
                // no device time? generate one out of the number of entries
                m_device_time = m_history_entry_count * 10 * 60;
                m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;
            }

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceThermoBeacon data:" << getAddress();
            qDebug() << "- entry_count:" << m_history_entry_count;
            qDebug() << "- entry_read:" << m_history_entry_read;
            qDebug() << "- device_time:" << m_device_time << "(" << (m_device_time / 3600.0 / 24.0) << "day)";
#endif

            QByteArray cmd(QByteArray::fromHex("07"));
            if (m_ble_action == DeviceUtils::ACTION_UPDATE)
            {
                // Ask the LAST 3 values
                int idx = m_history_entry_count - 3;
                cmd.push_back(idx%256);
                cmd.push_back(idx/256);
            }
            else if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
            {
                // Ask the first 3 values (or restart sync at m_history_entry_read)
                int idx = m_history_entry_read;
                cmd.push_back(idx%256);
                cmd.push_back(idx/256);
            }
            cmd.push_back(QByteArray::fromHex("00"));
            cmd.push_back(QByteArray::fromHex("00"));

            QLowEnergyCharacteristic ctx = serviceData->characteristic(uuid_tx);
            serviceData->writeCharacteristic(ctx, cmd, QLowEnergyService::WriteWithoutResponse);
        }

        // Parse entries
        if (data[0] == 07)
        {
            float temp1 = static_cast<int16_t>(data[6] + (data[7] << 8)) / 16.0;
            float temp2 = static_cast<int16_t>(data[8] + (data[9] << 8)) / 16.0;
            float temp3 = static_cast<int16_t>(data[10] + (data[11] << 8)) / 16.0;
            float hygro1 = static_cast<int16_t>(data[12] + (data[13] << 8)) / 16.0;
            float hygro2 = static_cast<int16_t>(data[14] + (data[15] << 8)) / 16.0;
            float hygro3 = static_cast<int16_t>(data[16] + (data[17] << 8)) / 16.0;

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
            {
                // Save these 3 values
                int64_t tmcd = m_device_wall_time + (m_history_entry_read * 10 * 60);

                addDatabaseRecord(tmcd + 0, temp1, hygro1);
                addDatabaseRecord(tmcd + 600, temp2, hygro2);
                addDatabaseRecord(tmcd + 1200, temp3, hygro3);

                // Update progress
                m_history_entry_read += 3;
                Q_EMIT historyUpdated();

                if (m_history_entry_read < m_history_entry_count)
                {
                    // Ask the NEXT 3 pairs
                    QByteArray cmd(QByteArray::fromHex("07"));
                    int idx = m_history_entry_read;
                    cmd.push_back(idx%256);
                    cmd.push_back(idx/256);
                    cmd.push_back(QByteArray::fromHex("00"));
                    cmd.push_back(QByteArray::fromHex("00"));

                    QLowEnergyCharacteristic ctx = serviceData->characteristic(uuid_tx);
                    serviceData->writeCharacteristic(ctx, cmd, QLowEnergyService::WriteWithoutResponse);
                }
                else
                {
                    // Write last sync
                    int64_t lastSync = m_device_wall_time + (m_history_entry_count * 10 * 60);

                    // Finish it
                    refreshDataFinished(true);
                    controller->disconnectFromDevice();
                }
            }
            else
            {
                int64_t tmcd = m_device_wall_time + (m_history_entry_count * 10 * 60);

                // Save this pair (if it's more recent than advertising data)
                if (QDateTime::fromSecsSinceEpoch(tmcd) > m_lastUpdate)
                {
                    m_temperature = temp3;
                    m_humidity = hygro3;
#ifndef QT_NO_DEBUG
                    qDebug() << "* DeviceThermoBeacon addDatabaseRecord() @ " << QDateTime::fromSecsSinceEpoch(tmcd).toString("yyyy-MM-dd hh:mm:ss");
                    qDebug() << "- temperature:" << m_temperature;
                    qDebug() << "- humidity:" << m_humidity;
#endif
                    addDatabaseRecord(tmcd, temp3, hygro3);
                }

                refreshDataFinished(true);
                controller->disconnectFromDevice();
            }
        }
    }
}

bool DeviceThermoBeacon::addDatabaseRecord(const int64_t tmcd, const float t, const float h)
{
    bool status = false;

    if (t == 0.f && h == 0.f) return status;

    if (m_dbInternal || m_dbExternal)
    {
        // SQL date format YYYY-MM-DD HH:MM:SS
        QDateTime tmcd_qdt = QDateTime::fromSecsSinceEpoch(tmcd);
/*
#ifndef QT_NO_DEBUG
        qDebug() << "* DeviceThermoBeacon addDatabaseRecord() @ " << tmcd_qdt.toString("yyyy-MM-dd hh:mm:ss");
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
#endif
*/
        QSqlQuery addData;
        addData.prepare("REPLACE INTO plantData (deviceAddr, ts, ts_full, temperature, humidity)"
                        " VALUES (:deviceAddr, :ts, :ts_full, :temp, :hygro)");
        addData.bindValue(":deviceAddr", getAddress());
        addData.bindValue(":ts", tmcd_qdt.toString("yyyy-MM-dd hh:00:00"));
        addData.bindValue(":ts_full", tmcd_qdt.toString("yyyy-MM-dd hh:mm:ss"));
        addData.bindValue(":temp", t);
        addData.bindValue(":hygro", h);
        status = addData.exec();

        if (status == false)
            qWarning() << "> addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();
    }

    return status;
}

/* ************************************************************************** */

void DeviceThermoBeacon::parseAdvertisementData(const QByteArray &value)
{
    //qDebug() << "DeviceThermoBeacon::parseAdvertisementData(" << m_deviceAddress << ")" << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    // 20 bytes message
    if (value.size() == 20) return;

    // 18 bytes message
    if (value.size() == 18)
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
        int battv = static_cast<uint16_t>(data[8] + (data[9] << 8));
        m_temperature = static_cast<int16_t>(data[10] + (data[11] << 8)) / 16.0;
        m_humidity = std::round(static_cast<uint16_t>(data[12] + (data[13] << 8)) / 16.0);
        m_device_time = static_cast<int32_t>(data[13] + (data[14] << 8) + (data[15] << 16) + (data[16] << 24)) / 256;
        m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;

        if (battv > 3000) battv = 3000;
        if (battv < 2500) battv = 2500;
        int battlvl = (0 + ((battv-2500) * (100-0)) / (3000-2500));

        if (m_dbInternal || m_dbExternal)
        {
            // Battery
            if (battlvl != m_battery)
            {
                m_battery = battlvl;

                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":battery", m_battery);
                updateDevice.bindValue(":deviceAddr", getAddress());
                if (updateDevice.exec() == false)
                    qWarning() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":" << updateDevice.lastError().text();
            }

            if (getLastUpdateInt() < 0 || getLastUpdateInt() > 30)
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
                    qWarning() << "> addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();
            }
        }

        m_lastUpdate = QDateTime::currentDateTime();
        Q_EMIT deviceUpdated(this);
        Q_EMIT statusUpdated();
        Q_EMIT dataUpdated();

#ifndef QT_NO_DEBUG
        qDebug() << "* DeviceThermoBeacon manufacturer data:" << getAddress();
        qDebug() << "- battery:" << m_battery;
        qDebug() << "- temperature:" << m_temperature;
        qDebug() << "- humidity:" << m_humidity;
        qDebug() << "- device_time:" << m_device_time << "(" << (m_device_time / 3600.0 / 24.0) << "day)";
#endif
    }
}

/* ************************************************************************** */
