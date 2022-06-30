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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_flowercare_tuya.h"
#include "utils_versionchecker.h"
#include "thirdparty/RC4/rc4.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

DeviceFlowerCare_tuya::DeviceFlowerCare_tuya(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DevicePlantSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerCare_tuya::DeviceFlowerCare_tuya(const QBluetoothDeviceInfo &d, QObject *parent):
    DevicePlantSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode += DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
}

DeviceFlowerCare_tuya::~DeviceFlowerCare_tuya()
{
    delete serviceData;
    delete serviceHandshake;
    delete serviceHistory;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceFlowerCare_tuya::hasHistory() const
{
    return false;
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::serviceScanDone()
{
    //qDebug() << "DeviceFlowerCare_tuya::serviceScanDone(" << m_deviceAddress << ")";

    if (serviceData)
    {
        if (serviceData->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceData, &QLowEnergyService::stateChanged, this, &DeviceFlowerCare_tuya::serviceDetailsDiscovered_data);
            connect(serviceData, &QLowEnergyService::characteristicRead, this, &DeviceFlowerCare_tuya::bleReadDone);

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceData->discoverDetails(); });
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceFlowerCare_tuya::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid.toString() == "{0000fd50-0000-1000-8000-00805f9b34fb}")
    {
        delete serviceData;
        serviceData = nullptr;

        if (m_ble_action != DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceData = m_bleController->createServiceObject(uuid);
            if (!serviceData)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::askForReading()
{
    if (serviceData)
    {
        QBluetoothUuid b(QString("00001a01-0000-1000-8000-00805f9b34fb")); // handle 0x35
        QLowEnergyCharacteristic chb = serviceData->characteristic(b);
        serviceData->readCharacteristic(chb);
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::serviceDetailsDiscovered_data(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare_tuya::serviceDetailsDiscovered_data(" << m_deviceAddress << ") > ServiceDiscovered";

        if (serviceData && m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            int batt = -1;
            QString fw;

            QBluetoothUuid c(QString("00001a02-0000-1000-8000-00805f9b34fb")); // handle 0x38
            QLowEnergyCharacteristic chc = serviceData->characteristic(c);
            if (chc.value().size() > 0)
            {
                batt = chc.value().at(0);
                fw = chc.value().remove(0, 2);
                setBatteryFirmware(batt, fw);
            }

            bool need_modechange = true;
            if (m_deviceFirmware.size() == 5)
            {
                if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
                {
                    m_firmware_uptodate = true;
                    Q_EMIT sensorUpdated();
                }
                if (VersionChecker(m_deviceFirmware) <= VersionChecker("2.6.6"))
                {
                    need_modechange = false;
                }
            }

            if (need_modechange) // if firmware > 2.6.6
            {
                // Change device mode
                QBluetoothUuid a(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
                QLowEnergyCharacteristic cha = serviceData->characteristic(a);
                serviceData->writeCharacteristic(cha, QByteArray::fromHex("A01F"), QLowEnergyService::WriteWithResponse);
            }

            // Ask for a data reading
            askForReading();
        }

        if (serviceData)
        {
            QBluetoothUuid l(QString("00001a00-0000-1000-8000-00805f9b34fb")); // handle 0x33
            QLowEnergyCharacteristic chl = serviceData->characteristic(l);

            if (m_ble_action == DeviceUtils::ACTION_LED_BLINK)
            {
                // Make the LED blink
                serviceData->writeCharacteristic(chl, QByteArray::fromHex("FDFF"), QLowEnergyService::WriteWithoutResponse);

                m_bleController->disconnectFromDevice();
            }
            else
            {
                // Make sure the LED is OFF
                //if (chl.value().size() == 2 && (chl.value().at(0) != 0 || chl.value().at(1) != 0))
                //{
                //    serviceData->writeCharacteristic(chl, QByteArray::fromHex("0000"), QLowEnergyService::WriteWithoutResponse);
                //    qWarning() << "FlowerCare LED was ON!";
                //}
            }
        }
    }
}

void DeviceFlowerCare_tuya::serviceDetailsDiscovered_handshake(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare_tuya::serviceDetailsDiscovered_handshake(" << m_deviceAddress << ") > ServiceDiscovered";
    }
}

void DeviceFlowerCare_tuya::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        //qDebug() << "DeviceFlowerCare_tuya::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerCare_tuya::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();
    Q_UNUSED(value)
}

void DeviceFlowerCare_tuya::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceFlowerCare_tuya::bleReadNotify(" << m_deviceAddress << ")";
    //qDebug() << "DATA: 0x" << value.toHex();
}

void DeviceFlowerCare_tuya::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerCare_tuya::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

    if (c.uuid().toString() == "{00001a01-0000-1000-8000-00805f9b34fb}")
    {
        // MiFlora data // handle 0x35

        if (value.size() > 0)
        {
            // first read might send bad data (0x aa bb cc dd ee ff 99 88 77 66...)
            // until the first write is done
            if (data[0] == 0xAA && data[1] == 0xBB)
                return;

            m_temperature = static_cast<int16_t>(data[0] + (data[1] << 8)) / 10.f;
            m_luminosityLux = data[3] + (data[4] << 8);
            m_soilMoisture = data[7];
            m_soilConductivity = data[8] + (data[9] << 8);

            m_lastUpdate = QDateTime::currentDateTime();

            if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
            {
                refreshRealtime();

                // Ask for a new data reading, but not too often...
                QTimer::singleShot(1000, this, SLOT(askForReading()));
            }
            else
            {
                bool status = addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                                m_soilMoisture, m_soilConductivity, -99.f, -99.f,
                                                m_temperature, -99.f, m_luminosityLux);

                refreshDataFinished(status);
                m_bleController->disconnectFromDevice();
            }
/*
            qDebug() << "* DeviceFlowerCare_tuya update:" << getAddress();
            qDebug() << "- m_firmware:" << m_deviceFirmware;
            qDebug() << "- m_battery:" << m_deviceBattery;
            qDebug() << "- m_soilMoisture:" << m_soilMoisture;
            qDebug() << "- m_soilConductivity:" << m_soilConductivity;
            qDebug() << "- m_temperature:" << m_temperature;
            qDebug() << "- m_luminosityLux:" << m_luminosityLux;
*/
        }

        return;
    }
}

/* ************************************************************************** */

void DeviceFlowerCare_tuya::parseAdvertisementData(const QByteArray &value, const uint16_t identifier)
{
    //qDebug() << "DeviceFlowerCare_tuya::parseAdvertisementData(" << m_deviceAddress << ")" << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    // service data / 16b UUID 0xfd50 / 9 bytes messages

    if (value.size() == 9)
    {
        const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());

        int batt = -99;
        float temp = -99.f;
        float humi = -99.f;
        int lumi = -99;
        int moist = -99;
        int fert = -99;

        batt = static_cast<int8_t>(data[6]);
        setBattery(batt);

        humi = static_cast<int16_t>(data[0] + (data[1] << 8));
        temp = static_cast<int16_t>(data[2] + (data[3] << 8)) / 10.f;
        lumi = static_cast<int16_t>(data[4] + (data[5] << 8));
        fert = static_cast<int16_t>(data[7] + (data[8] << 8));

        if (areValuesValid(humi, fert, -99.f, -99.f, temp, -99.f, lumi))
        {
            m_lastUpdate = QDateTime::currentDateTime();

            if (needsUpdateDb_mini())
            {
                addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                  humi, fert, -99.f, -99.f,
                                  temp, -99.f, lumi);
            }

            refreshDataFinished(true);
/*
            qDebug() << "* service data:" << getName() << getAddress() << "(" << value.size() << ") bytes";
            if (batt > -99) qDebug() << "- battery:" << batt;
            if (temp > -99) qDebug() << "- temperature:" << temp;
            if (humi > -99) qDebug() << "- humidity:" << humi;
            if (lumi > -99) qDebug() << "- luminosity:" << lumi;
            if (moist > -99)qDebug() << "- soil moisture:" << moist;
            if (fert > -99) qDebug() << "- soil conductivity:" << fert;
*/
        }
    }
}

/* ************************************************************************** */
