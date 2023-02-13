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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_flowerpower.h"
#include "device_firmwares.h"
#include "utils_versionchecker.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceFlowerPower::DeviceFlowerPower(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DevicePlantSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    //m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    m_deviceCapabilities += DeviceUtils::DEVICE_LAST_MOVE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerPower::DeviceFlowerPower(const QBluetoothDeviceInfo &d, QObject *parent):
    DevicePlantSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    //m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    m_deviceCapabilities += DeviceUtils::DEVICE_LAST_MOVE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerPower::~DeviceFlowerPower()
{
    delete serviceLive;
    delete serviceHistory;
    delete serviceClock;
    delete serviceBattery;
    delete serviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceFlowerPower::serviceScanDone()
{
    //qDebug() << "DeviceFlowerPower::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_infos);
            connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_battery);
            //connect(serviceBattery, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(); });
        }
    }

    if (serviceClock)
    {
        if (serviceClock->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceClock, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_clock);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceClock->discoverDetails(); });
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_history);
            connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerPower::bleWriteDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHistory->discoverDetails(); });
        }
    }

    if (serviceLive)
    {
        if (serviceLive->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceLive, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_live);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceLive->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerPower::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceFlowerPower::addLowEnergyService(" << uuid.toString() << ")";

    // GAP service (UUID 0x1800)
    // ? (UUID 0x1801)

    if (uuid.toString() == "{0000180a-0000-1000-8000-00805f9b34fb}") // Device Information service
    {
        delete serviceInfos;
        serviceInfos = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE &&
            (m_deviceFirmware.isEmpty() || m_deviceFirmware == "UNKN"))
        {
            serviceInfos = m_bleController->createServiceObject(uuid);
            if (!serviceInfos)
                qWarning() << "Cannot create service (infos) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{0000180f-0000-1000-8000-00805f9b34fb}") // Battery service
    {
        delete serviceBattery;
        serviceBattery = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            serviceBattery = m_bleController->createServiceObject(uuid);
            if (!serviceBattery)
                qWarning() << "Cannot create service (battery) for uuid:" << uuid.toString();
        }
    }

    //if (uuid.toString() == "{39e1fb00-84a8-11e2-afba-0002a5d5c51b}") // Upload service

    if (uuid.toString() == "{39e1fc00-84a8-11e2-afba-0002a5d5c51b}") // History service
    {
        delete serviceHistory;
        serviceHistory = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceHistory = m_bleController->createServiceObject(uuid);
            if (!serviceHistory)
                qWarning() << "Cannot create service (history) for uuid:" << uuid.toString();
        }
    }

    if (uuid.toString() == "{39e1fd00-84a8-11e2-afba-0002a5d5c51b}") // FlowerPower clock service
    {
        delete serviceClock;
        serviceClock = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceClock = m_bleController->createServiceObject(uuid);
            if (!serviceClock)
                qWarning() << "Cannot create service (clock) for uuid:" << uuid.toString();
        }
    }

    //if (uuid.toString() == "{39e1fe00-84a8-11e2-afba-0002a5d5c51b}") // FlowerPower calibration service

    if (uuid.toString() == "{39e1fa00-84a8-11e2-afba-0002a5d5c51b}") // Live service
    {
        delete serviceLive;
        serviceLive = nullptr;

        if (m_ble_action != DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceLive = m_bleController->createServiceObject(uuid);
            if (!serviceLive)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerPower::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceInfos)
        {
            QBluetoothUuid fw(QStringLiteral("00002a26-0000-1000-8000-00805f9b34fb")); // handle 0x17
            QLowEnergyCharacteristic cfw = serviceInfos->characteristic(fw);
            if (cfw.value().size() > 0)
            {
                QString fw = cfw.value().split('_')[1].split('-')[1];
                setFirmware(fw);

                if (m_deviceFirmware.size() == 5)
                {
                    if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERPOWER))
                    {
                        m_firmware_uptodate = true;
                        Q_EMIT sensorUpdated();
                    }
                }
            }
            else
            {
                serviceInfos->readCharacteristic(cfw);
            }
        }
    }
}

void DeviceFlowerPower::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

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
            else
            {
                serviceBattery->readCharacteristic(cbat);
            }
        }
    }
}

void DeviceFlowerPower::serviceDetailsDiscovered_live(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_live(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceLive && m_ble_action == DeviceUtils::ACTION_LED_BLINK)
        {
            // Make LED blink
            QBluetoothUuid led(QStringLiteral("39e1fa07-84a8-11e2-afba-0002a5d5c51b")); // handle 0x3c
            QLowEnergyCharacteristic cled = serviceLive->characteristic(led);
            serviceLive->writeCharacteristic(cled, QByteArray::fromHex("01"), QLowEnergyService::WriteWithResponse);
            //controller->disconnectFromDevice();
        }

        if (serviceLive && m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            const quint8 *rawData = nullptr;
            double rawValue = 0;

            /////////
/*
            if (VersionChecker(m_firmware) >= Version("1.1.0"))
            {
                QBluetoothUuid sm_calibrated(QStringLiteral("39e1fa09-84a8-11e2-afba-0002a5d5c51b")); // soil moisture
                QBluetoothUuid at_calibrated(QStringLiteral("39e1fa0a-84a8-11e2-afba-0002a5d5c51b")); // air temp
                QBluetoothUuid dli_calibrated(QStringLiteral("39e1fa0b-84a8-11e2-afba-0002a5d5c51b")); // sunlight?

                QBluetoothUuid ea_calibrated(QStringLiteral("39e1fa0c-84a8-11e2-afba-0002a5d5c51b")); // ?
                QBluetoothUuid ecb_calibrated(QStringLiteral("39e1fa0d-84a8-11e2-afba-0002a5d5c51b")); // ?
                QBluetoothUuid ecbp_calibrated(QStringLiteral("39e1fa0e-84a8-11e2-afba-0002a5d5c51b")); // ?
            }
            else
*/
            {
                /////////

                QBluetoothUuid lx(QStringLiteral("39e1fa01-84a8-11e2-afba-0002a5d5c51b")); // handle 0x25
                QLowEnergyCharacteristic chlx = serviceLive->characteristic(lx);

                rawData = reinterpret_cast<const quint8 *>(chlx.value().constData());
                rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
                m_luminosityLux = std::round(1000.0 * 0.08640000000000001 * (192773.17000000001 * std::pow(rawValue, -1.0606619)));

                /////////

                QBluetoothUuid sf(QStringLiteral("39e1fa02-84a8-11e2-afba-0002a5d5c51b")); // handle 0x29
                QLowEnergyCharacteristic chsf = serviceLive->characteristic(sf);

                rawData = reinterpret_cast<const quint8 *>(chsf.value().constData());
                rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
                // sensor output (no soil: 0) - (max observed: 1771) wich maps to 0 - 10 (mS/cm)
                // divide by 177,1 to 10 (mS/cm)
                // divide by 1,771 to 1 (uS/cm)
                m_soilConductivity = std::round(rawValue / 1.771);

                /////////

                QBluetoothUuid st(QStringLiteral("39e1fa03-84a8-11e2-afba-0002a5d5c51b")); // handle 0x2d
                QLowEnergyCharacteristic chst = serviceLive->characteristic(st);

                rawData = reinterpret_cast<const quint8 *>(chst.value().constData());
                rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
                m_soilTemperature = 0.00000003044 * std::pow(rawValue, 3.0) - 0.00008038 * std::pow(rawValue, 2.0) + rawValue * 0.1149 - 30.449999999999999;

                /////////

                QBluetoothUuid t(QStringLiteral("39e1fa04-84a8-11e2-afba-0002a5d5c51b")); // handle 0x31
                QLowEnergyCharacteristic cht = serviceLive->characteristic(t);

                rawData = reinterpret_cast<const quint8 *>(cht.value().constData());
                rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
                m_temperature = 0.00000003044 * std::pow(rawValue, 3.0) - 0.00008038 * std::pow(rawValue, 2.0) + rawValue * 0.1149 - 30.449999999999999;
                if (m_temperature < -10.f) m_temperature = -10.f;
                if (m_temperature > 55.f) m_temperature = 55.f;

                /////////

                QBluetoothUuid sm(QStringLiteral("39e1fa05-84a8-11e2-afba-0002a5d5c51b")); // handle 0x35
                QLowEnergyCharacteristic chsm = serviceLive->characteristic(sm);

                rawData = reinterpret_cast<const quint8 *>(chsm.value().constData());
                rawValue = static_cast<uint16_t>(rawData[0] + (rawData[1] << 8));
                double hygro1 = 11.4293 + (0.0000000010698 * std::pow(rawValue, 4.0) - 0.00000152538 * std::pow(rawValue, 3.0) + 0.000866976 * std::pow(rawValue, 2.0) - 0.169422 * rawValue);
                double hygro2 = 100.0 * (0.0000045 * std::pow(hygro1, 3.0) - 0.00055 * std::pow(hygro1, 2.0) + 0.0292 * hygro1 - 0.053);
                if (hygro2 < 0.0) hygro2 = 0.0;
                if (hygro2 > 60.0) hygro2 = 60.0;
                m_soilMoisture = std::round(hygro2);
            }

            /////////

            // TODO
            //QBluetoothUuid live_mesure_period(QStringLiteral("39e1fa06-84a8-11e2-afba-0002a5d5c51b")); // handle 0x39
            //QBluetoothUuid led_status(QStringLiteral("39e1fa07-84a8-11e2-afba-0002a5d5c51b")); // handle 0x3c

            /////////

            QBluetoothUuid lm(QStringLiteral("39e1fa08-84a8-11e2-afba-0002a5d5c51b")); // handle 0x3f
            QLowEnergyCharacteristic chlm = serviceLive->characteristic(lm);

            rawData = reinterpret_cast<const quint8 *>(chlm.value().constData());
            rawValue = static_cast<uint32_t>(rawData[0] + (rawData[1] << 8) + (rawData[2] << 16) + (rawData[3] << 24));
            m_device_lastmove = rawValue + m_device_wall_time;

            /////////

            if (m_soilTemperature > -10.f && m_soilTemperature < 100.f &&
                m_temperature > -10.f && m_temperature < 100.f &&
                m_luminosityLux >= 0 && m_luminosityLux < 200000)
            {
                // Sometimes, Parrot devices send obviously wrong data over BLE
                // Maybe the sensor is warming up?
                qWarning() << "Parrot sensor values error";
            }

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime(); // TODO // ask for new values?
            }
            else
            {
                bool status = addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                                m_soilMoisture, m_soilConductivity, m_soilTemperature, -99.f,
                                                m_temperature, -99.f, m_luminosityLux);

                refreshDataFinished(status);
                m_bleController->disconnectFromDevice();
            }
/*
            qDebug() << "* DeviceFlowerPower update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_device_lastmove : " << QDateTime::fromSecsSinceEpoch(m_device_lastmove);
            qDebug() << "- m_soilMoisture:" << m_soilMoisture;
            qDebug() << "- m_soilConductivity:" << m_soilConductivity;
            qDebug() << "- m_soilTemperature : " << m_soilTemperature;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_luminosityLux:" << m_luminosityLux;
*/
        }
    }
}

void DeviceFlowerPower::serviceDetailsDiscovered_clock(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_clock(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceClock)
        {
            QBluetoothUuid clk(QStringLiteral("39e1fd01-84a8-11e2-afba-0002a5d5c51b")); // handle 0x70
            QLowEnergyCharacteristic cclk = serviceClock->characteristic(clk);
            if (cclk.value().size() > 0)
            {
                const quint8 *data = reinterpret_cast<const quint8 *>(cclk.value().constData());
                m_device_time = data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24);
                m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;

                qDebug() << "* DeviceFlowerPower clock: " << m_device_time;
            }
        }
    }
}

void DeviceFlowerPower::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceHistory && m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            //39e1fc01-84a8-11e2-afba-0002a5d5c51b	0x48	read	number of entries
            //39e1fc02-84a8-11e2-afba-0002a5d5c51b	0x4c	read	last entry index
            //39e1fc03-84a8-11e2-afba-0002a5d5c51b	0x50	read/write	start transfert index
            //39e1fc04-84a8-11e2-afba-0002a5d5c51b	0x54	read	current session id
            //39e1fc05-84a8-11e2-afba-0002a5d5c51b	0x58	read	current session start index
            //39e1fc06-84a8-11e2-afba-0002a5d5c51b	0x5c	read	current session period
        }

        if (serviceHistory && m_ble_action == DeviceUtils::ACTION_CLEAR_HISTORY)
        {
            //
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerPower::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerPower::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString() == "{x}")
    {
        if (value.size() > 0)
        {
            //const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
        }
    }
}

void DeviceFlowerPower::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerPower::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    //const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
    //const int data_size = value.size();

    // Read firmware version
    if (c.uuid().toString() == "00002a26-0000-1000-8000-00805f9b34fb")
    {
        QString fw = value.split('_')[1].split('-')[1];
        setFirmware(fw);

        if (m_deviceFirmware.size() == 5)
        {
            if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERPOWER))
            {
                m_firmware_uptodate = true;
                Q_EMIT sensorUpdated();
            }
        }
    }

    // Read battery level
    if (c.uuid().toString() == "00002a19-0000-1000-8000-00805f9b34fb")
    {
        if (value.size() == 1)
        {
            int lvl = static_cast<uint8_t>(value.constData()[0]);
            setBattery(lvl);
        }
    }
}

void DeviceFlowerPower::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerPower::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    if (c.uuid().toString() == "{x}")
    {
        if (value.size() > 0)
        {
            //const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
        }
    }
}

/* ************************************************************************** */
