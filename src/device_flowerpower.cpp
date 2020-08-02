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

#include "device_flowerpower.h"
#include "utils_versionchecker.h"

#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>

/* ************************************************************************** */

DeviceFlowerPower::DeviceFlowerPower(QString &deviceAddr, QString &deviceName, QObject *parent):
    Device(deviceAddr, deviceName, parent)
{
    m_deviceType = DEVICE_PLANTSENSOR;

    m_capabilities += DEVICE_BATTERY;
    m_capabilities += DEVICE_LED;
    m_capabilities += DEVICE_SOIL_MOISTURE;
    m_capabilities += DEVICE_SOIL_CONDUCTIVITY;
    m_capabilities += DEVICE_SOIL_TEMPERATURE;
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_LIGHT;
}

DeviceFlowerPower::DeviceFlowerPower(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    m_deviceType = DEVICE_PLANTSENSOR;

    m_capabilities += DEVICE_BATTERY;
    m_capabilities += DEVICE_LED;
    m_capabilities += DEVICE_SOIL_MOISTURE;
    m_capabilities += DEVICE_SOIL_CONDUCTIVITY;
    m_capabilities += DEVICE_SOIL_TEMPERATURE;
    m_capabilities += DEVICE_TEMPERATURE;
    m_capabilities += DEVICE_LIGHT;
}

DeviceFlowerPower::~DeviceFlowerPower()
{
    delete serviceHistory;
    delete serviceData;
    delete serviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceFlowerPower::serviceScanDone()
{
    //qDebug() << "DeviceFlowerPower::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_infos);
            //connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            serviceInfos->discoverDetails();
        }
    }

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_data);
            //connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            serviceData->discoverDetails();
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::DiscoveryRequired)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_history);
            //connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            //connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerPower::bleWriteDone);
            serviceHistory->discoverDetails();
        }
    }
}

void DeviceFlowerPower::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceFlowerPower::addLowEnergyService(" << uuid.toString() << ")";

    // GAP service (UUID 0x1800)
    // ? (UUID 0x1801)

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // Device Information
    {
        delete serviceInfos;
        serviceInfos = nullptr;
/*
        if (m_ble_action == ACTION_UPDATE)
        {
            serviceInfos = controller->createServiceObject(uuid);
            if (!serviceInfos)
                qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
        }
*/
    }

    if (uuid.toString() == "{39e1fa00-84a8-11e2-afba-0002a5d5c51b}") // Live service
    {
        delete serviceData;
        serviceData = nullptr;

        if (m_ble_action != ACTION_UPDATE_HISTORY)
        {
            serviceData = controller->createServiceObject(uuid);
            if (!serviceData)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }

    //if (uuid.toString() == "{39e1fb00-84a8-11e2-afba-0002a5d5c51b}") // upload service

    if (uuid.toString() == "{39e1fc00-84a8-11e2-afba-0002a5d5c51b}") // History service
    {
        delete serviceHistory;
        serviceHistory = nullptr;

        if (m_ble_action == ACTION_UPDATE_HISTORY)
        {
            serviceHistory = controller->createServiceObject(uuid);
            if (!serviceHistory)
                qWarning() << "Cannot create service (history) for uuid:" << uuid.toString();
        }
    }

    //if (uuid.toString() == "{39e1fd00-84a8-11e2-afba-0002a5d5c51b}") // FlowerPower clock service
    //if (uuid.toString() == "{39e1fe00-84a8-11e2-afba-0002a5d5c51b}") // FlowerPower calibration service
}

void DeviceFlowerPower::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        QBluetoothUuid fw(QString("00002a26-0000-1000-8000-00805f9b34fb")); // handler 0x?
        QLowEnergyCharacteristic cfw = serviceData->characteristic(fw);
        if (cfw.value().size() > 0)
        {
            m_firmware = cfw.value();
            qDebug() << "DeviceFlowerPower firmware " << m_firmware;
        }

        if (m_firmware.size() == 5)
        {
            if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERPOWER))
            {
                m_firmware_uptodate = true;
            }
        }

        Q_EMIT sensorUpdated();
    }
}

void DeviceFlowerPower::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (m_ble_action == ACTION_LED_BLINK)
        {
            // Make LED blink
            QBluetoothUuid led(QString("39e1fa07-84a8-11e2-afba-0002a5d5c51b")); // handler 0x?
            QLowEnergyCharacteristic cled = serviceData->characteristic(led);
            serviceData->writeCharacteristic(cled, QByteArray::fromHex("01"), QLowEnergyService::WriteWithResponse);
            //controller->disconnectFromDevice();
        }

        if (m_ble_action == ACTION_UPDATE)
        {
            double rawValue = 0;
            const quint8 *rawData = nullptr;

            /////////

            QBluetoothUuid lx(QString("39e1fa01-84a8-11e2-afba-0002a5d5c51b")); // handler 0x?
            QLowEnergyCharacteristic chlx = serviceData->characteristic(lx);

            rawData = reinterpret_cast<const quint8 *>(chlx.value().constData());
            rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
            m_luminosity = 0.08640000000000001 * (192773.17000000001 * pow(rawValue, -1.0606619));

            /////////

            QBluetoothUuid sf(QString("39e1fa02-84a8-11e2-afba-0002a5d5c51b")); // handler 0x?
            QLowEnergyCharacteristic chsf = serviceData->characteristic(sf);

            rawData = reinterpret_cast<const quint8 *>(chsf.value().constData());
            rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
            qDebug() << "soil EC value : " << rawValue;

            /////////

            QBluetoothUuid st(QString("39e1fa03-84a8-11e2-afba-0002a5d5c51b")); // handler 0x?
            QLowEnergyCharacteristic chst = serviceData->characteristic(st);

            rawData = reinterpret_cast<const quint8 *>(chst.value().constData());
            rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
            float m_stemp = 0.00000003044 * pow(rawValue, 3.0) - 0.00008038 * pow(rawValue, 2.0) + rawValue * 0.1149 - 30.449999999999999;
            qDebug() << "soil temperature : " << m_stemp;

            /////////

            QBluetoothUuid t(QString("39e1fa04-84a8-11e2-afba-0002a5d5c51b")); // handler 0x?
            QLowEnergyCharacteristic cht = serviceData->characteristic(t);

            rawData = reinterpret_cast<const quint8 *>(cht.value().constData());
            rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
            m_temp = 0.00000003044 * pow(rawValue, 3.0) - 0.00008038 * pow(rawValue, 2.0) + rawValue * 0.1149 - 30.449999999999999;

            /////////

            QBluetoothUuid sm(QString("39e1fa05-84a8-11e2-afba-0002a5d5c51b")); // handler 0x?
            QLowEnergyCharacteristic chsm = serviceData->characteristic(sm);

            rawData = reinterpret_cast<const quint8 *>(chsm.value().constData());
            rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
            double hygro = 11.4293 + (0.0000000010698 * pow(rawValue, 4.0) - 0.00000152538 * pow(rawValue, 3.0) +  0.000866976 * pow(rawValue, 2.0) - 0.169422 * rawValue);
            m_hygro = 100.0 * (0.0000045 * pow(hygro, 3.0) - 0.00055 * pow(hygro, 2.0) + 0.0292 * hygro - 0.053);
            if (m_hygro < 0.0) m_hygro = 0.0;
            if (m_hygro > 60.0) m_hygro = 60.0;

            /////////

            QBluetoothUuid lm(QString("39e1fa08-84a8-11e2-afba-0002a5d5c51b")); // handler 0x?
            QLowEnergyCharacteristic chlm = serviceData->characteristic(lm);

            rawData = reinterpret_cast<const quint8 *>(chlm.value().constData());
            rawValue = static_cast<uint32_t>(rawData[0] + (rawData[1] << 8) + (rawData[2] << 16) + (rawData[3] << 24));
            qDebug() << "last move date : " << rawValue;

            /////////

            m_lastUpdate = QDateTime::currentDateTime();

            //if (m_db)
            {
                // SQL date format YYYY-MM-DD HH:MM:SS
                QString tsStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:00:00");
                QString tsFullStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
/*
                QSqlQuery addData;
                addData.prepare("REPLACE INTO datas (deviceAddr, ts, ts_full, temp, hygro, luminosity, conductivity)"
                                " VALUES (:deviceAddr, :ts, :ts_full, :temp, :hygro, :luminosity, :conductivity)");
                addData.bindValue(":deviceAddr", getAddress());
                addData.bindValue(":ts", tsStr);
                addData.bindValue(":ts_full", tsFullStr);
                addData.bindValue(":temp", m_temp);
                addData.bindValue(":hygro", m_hygro);
                addData.bindValue(":luminosity", m_luminosity);
                addData.bindValue(":conductivity", m_conductivity);
                if (addData.exec() == false)
                    qWarning() << "> addData.exec() ERROR" << addData.lastError().type() << ":" << addData.lastError().text();
*/
/*
                QSqlQuery updateDevice;
                updateDevice.prepare("UPDATE devices SET deviceFirmware = :firmware, deviceBattery = :battery WHERE deviceAddr = :deviceAddr");
                updateDevice.bindValue(":firmware", m_firmware);
                updateDevice.bindValue(":battery", m_battery);
                updateDevice.bindValue(":deviceAddr", getAddress());
                if (updateDevice.exec() == false)
                    qWarning() << "> updateDevice.exec() ERROR" << updateDevice.lastError().type() << ":" << updateDevice.lastError().text();
*/
            }

            refreshDataFinished(true);
            controller->disconnectFromDevice();

#ifndef QT_NO_DEBUG
            qDebug() << "* DeviceFlowerPower update:" << getAddress();
            qDebug() << "- m_firmware:" << m_firmware;
            qDebug() << "- m_battery:" << m_battery;
            qDebug() << "- m_temperature:" << m_temp;
            qDebug() << "- m_humidity:" << m_humi;
            qDebug() << "- m_hygrometry:" << m_hygro;
            qDebug() << "- m_luminosity:" << m_luminosity;
            qDebug() << "- m_conductivity:" << m_conductivity;
#endif
        }
    }
}

void DeviceFlowerPower::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::ServiceDiscovered)
    {
        qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";
    }
}

/* ************************************************************************** */

void DeviceFlowerPower::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerPower::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();

    if (c.uuid().toString() == "{x}")
    {
        Q_UNUSED(value)
    }
}

void DeviceFlowerPower::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceFlowerPower::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATA: 0x" \
             << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
             << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
             << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[10] \
             << hex << data[12]  << hex << data[13]  << hex << data[14] << hex << data[15];
*/
    if (c.uuid().toString() == "{x}")
    {
        if (value.size() > 0)
        {
            Q_UNUSED(data)
        }
    }
}

void DeviceFlowerPower::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
/*
    qDebug() << "DeviceFlowerPower::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    qDebug() << "WE HAVE DATA: 0x" \
             << hex << data[0]  << hex << data[1]  << hex << data[2] << hex << data[3] \
             << hex << data[4]  << hex << data[5]  << hex << data[6] << hex << data[7] \
             << hex << data[8]  << hex << data[9]  << hex << data[10] << hex << data[10] \
             << hex << data[12]  << hex << data[13]  << hex << data[14] << hex << data[15];
*/
    if (c.uuid().toString() == "{x}")
    {
        if (value.size() > 0)
        {
            Q_UNUSED(data)
        }
    }
}
