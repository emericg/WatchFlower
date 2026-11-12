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

#include "device_parrotpot.h"
#include "device_firmwares.h"
#include "utils_maths.h"

#include <cstdint>
#include <cmath>

#include <QVersionNumber>
#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QDebug>

/* ************************************************************************** */

/*!
 * \brief Extract the version number from a Parrot firmware revision string.
 * \param value: the raw "firmware revision string" characteristic content.
 * \return The version number, or an empty string if the format is unknown.
 *
 * The firmware revision string is formatted as "xxx_yyy-<version>".
 */
static QString parseFirmwareRevision(const QByteArray &value)
{
    const QList<QByteArray> parts = value.split('_');
    if (parts.size() < 2) return QString();

    const QList<QByteArray> subparts = parts.at(1).split('-');
    if (subparts.size() < 2) return QString();

    return QString::fromLatin1(subparts.at(1));
}

/* ************************************************************************** */

DeviceParrotPot::DeviceParrotPot(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DevicePlantSensor(deviceAddr, deviceName, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    //m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    m_deviceCapabilities += DeviceUtils::DEVICE_WATER_TANK;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
    m_deviceSensors += DeviceUtils::SENSOR_WATER_LEVEL;

    m_watertank_capacity = 2.2;
}

DeviceParrotPot::DeviceParrotPot(const QBluetoothDeviceInfo &d, QObject *parent):
    DevicePlantSensor(d, parent)
{
    m_deviceType = DeviceUtils::DEVICE_PLANTSENSOR;
    m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_CONNECTION;
    //m_deviceCapabilities += DeviceUtils::DEVICE_REALTIME;
    //m_deviceCapabilities += DeviceUtils::DEVICE_HISTORY;
    m_deviceCapabilities += DeviceUtils::DEVICE_BATTERY;
    m_deviceCapabilities += DeviceUtils::DEVICE_LED_STATUS;
    m_deviceCapabilities += DeviceUtils::DEVICE_WATER_TANK;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_MOISTURE;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    m_deviceSensors += DeviceUtils::SENSOR_SOIL_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
    m_deviceSensors += DeviceUtils::SENSOR_LUMINOSITY;
    m_deviceSensors += DeviceUtils::SENSOR_WATER_LEVEL;

    m_watertank_capacity = 2.2;
}

DeviceParrotPot::~DeviceParrotPot()
{
    delete serviceHistory;
    delete serviceClock;
    delete serviceWatering;
    delete serviceLive;
    delete serviceBattery;
    delete serviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceParrotPot::serviceScanDone()
{
    //qDebug() << "DeviceParrotPot::serviceScanDone(" << m_deviceAddress << ")";

    m_services_pending = 0;
    m_reads_pending = 0;

    // Every service is discovered with SkipValueDiscovery: a Parrot Pot exposes
    // dozens of characteristics we never look at, and a full discovery reads all
    // of their values *and* descriptors before we get a chance to do anything.
    // The handful of values we need are read explicitly instead, from the
    // serviceDetailsDiscovered_*() handlers.

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceParrotPot::serviceDetailsDiscovered_infos);
            connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceParrotPot::bleReadDone);
            connect(serviceInfos, &QLowEnergyService::errorOccurred, this, &DeviceParrotPot::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceParrotPot::serviceDetailsDiscovered_battery);
            connect(serviceBattery, &QLowEnergyService::characteristicRead, this, &DeviceParrotPot::bleReadDone);
            connect(serviceBattery, &QLowEnergyService::errorOccurred, this, &DeviceParrotPot::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceClock)
    {
        if (serviceClock->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceClock, &QLowEnergyService::stateChanged, this, &DeviceParrotPot::serviceDetailsDiscovered_clock);
            connect(serviceClock, &QLowEnergyService::characteristicRead, this, &DeviceParrotPot::bleReadDone);
            connect(serviceClock, &QLowEnergyService::errorOccurred, this, &DeviceParrotPot::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceClock->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceParrotPot::serviceDetailsDiscovered_history);
            connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceParrotPot::bleReadDone);
            connect(serviceHistory, &QLowEnergyService::errorOccurred, this, &DeviceParrotPot::bleReadErrored);
            //connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceParrotPot::bleWriteDone);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHistory->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceWatering)
    {
        if (serviceWatering->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceWatering, &QLowEnergyService::stateChanged, this, &DeviceParrotPot::serviceDetailsDiscovered_watering);
            connect(serviceWatering, &QLowEnergyService::characteristicRead, this, &DeviceParrotPot::bleReadDone);
            connect(serviceWatering, &QLowEnergyService::errorOccurred, this, &DeviceParrotPot::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceWatering->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceLive)
    {
        if (serviceLive->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceLive, &QLowEnergyService::stateChanged, this, &DeviceParrotPot::serviceDetailsDiscovered_live);
            connect(serviceLive, &QLowEnergyService::characteristicRead, this, &DeviceParrotPot::bleReadDone);
            connect(serviceLive, &QLowEnergyService::errorOccurred, this, &DeviceParrotPot::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceLive->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }
}

/* ************************************************************************** */

/*!
 * \brief Request a characteristic value, and keep track of the pending read.
 * \param service: the service holding the characteristic.
 * \param uuid: the characteristic to read.
 *
 * Services are discovered with SkipValueDiscovery, so a characteristic value is
 * only available once it has been explicitly read. The value ends up in the
 * service's own cache, so it can be picked up with characteristic().value()
 * once bleWorkFinished() reports every read as done.
 */
void DeviceParrotPot::bleReadPending(QLowEnergyService *service, const QBluetoothUuid &uuid)
{
    if (!service) return;

    const QLowEnergyCharacteristic c = service->characteristic(uuid);
    if (!c.isValid())
    {
        qWarning() << "DeviceParrotPot::bleReadPending(" << m_deviceAddress << ") unknown characteristic:" << uuid.toString();
        return;
    }

    m_reads_pending++;
    service->readCharacteristic(c);
}

/*!
 * \brief Account for a service whose details have been discovered.
 *
 * Requests towards a given peripheral are serialised, and the services are
 * discovered in the order they are listed in serviceScanDone(). The reads
 * issued by the earlier services are therefore always queued behind the detail
 * discovery of the last one, meaning no read can complete before every service
 * has had the chance to queue its own.
 *
 * A service that never reaches RemoteServiceDiscovered is deliberately left
 * accounted for: the action then ends on its timeout, like it did when the
 * values were fetched by the discovery itself.
 */
void DeviceParrotPot::serviceDiscoveryFinished()
{
    if (m_services_pending > 0) m_services_pending--;

    bleWorkFinished();
}

/*!
 * \brief Handle a failed characteristic read.
 *
 * A read that errors out never emits characteristicRead(), so its slot in the
 * pending count has to be reclaimed here, or the action would hang until it
 * times out.
 */
void DeviceParrotPot::bleReadErrored(QLowEnergyService::ServiceError error)
{
    if (error != QLowEnergyService::CharacteristicReadError) return;

    qWarning() << "DeviceParrotPot::bleReadErrored(" << m_deviceAddress << ") error:" << error;

    if (m_reads_pending > 0) m_reads_pending--;

    bleWorkFinished();
}

/*!
 * \brief Called whenever a service discovery or a characteristic read settles.
 *
 * Once nothing is in flight anymore, every value we asked for is sitting in its
 * service cache and the live values can be turned into a sensor reading.
 */
void DeviceParrotPot::bleWorkFinished()
{
    if (m_services_pending > 0 || m_reads_pending > 0) return;

    if (m_ble_action == DeviceUtils::ACTION_UPDATE ||
        m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
    {
        parseLiveValues();
    }
}

/* ************************************************************************** */

void DeviceParrotPot::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceParrotPot::addLowEnergyService(" << uuid.toString() << ")";

    if (uuid == uuid_service_infos)
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

    if (uuid == uuid_service_battery)
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

    if (uuid == uuid_service_history)
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

    if (uuid == uuid_service_clock)
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

    if (uuid == uuid_service_watering)
    {
        delete serviceWatering;
        serviceWatering = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE ||
            m_ble_action == DeviceUtils::ACTION_WATERING)
        {
            serviceWatering = m_bleController->createServiceObject(uuid);
            if (!serviceWatering)
                qWarning() << "Cannot create service (watering) for uuid:" << uuid.toString();
        }
    }

    if (uuid == uuid_service_live)
    {
        delete serviceLive;
        serviceLive = nullptr;

        if (m_ble_action == DeviceUtils::ACTION_UPDATE ||
            m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME ||
            m_ble_action == DeviceUtils::ACTION_LED_BLINK)
        {
            serviceLive = m_bleController->createServiceObject(uuid);
            if (!serviceLive)
                qWarning() << "Cannot create service (data) for uuid:" << uuid.toString();
        }
    }
}

/* ************************************************************************** */

void DeviceParrotPot::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceInfos)
    {
        //qDebug() << "DeviceParrotPot::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Firmware Revision String", parsed in bleReadDone()
        bleReadPending(serviceInfos, uuid_firmware);
    }

    serviceDiscoveryFinished();
}

void DeviceParrotPot::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceBattery)
    {
        //qDebug() << "DeviceParrotPot::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Battery Level", parsed in bleReadDone()
        bleReadPending(serviceBattery, uuid_battery_level);
    }

    serviceDiscoveryFinished();
}

void DeviceParrotPot::serviceDetailsDiscovered_live(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceLive)
    {
        //qDebug() << "DeviceParrotPot::serviceDetailsDiscovered_live(" << m_deviceAddress << ") > ServiceDiscovered";

        if (m_ble_action == DeviceUtils::ACTION_LED_BLINK)
        {
            // Make LED blink
            const QLowEnergyCharacteristic cled = serviceLive->characteristic(uuid_live_led);
            if (cled.isValid())
            {
                serviceLive->writeCharacteristic(cled, QByteArray::fromHex("01"), QLowEnergyService::WriteWithResponse);
            }
            else
            {
                qWarning() << "DeviceParrotPot::serviceDetailsDiscovered_live(" << m_deviceAddress << ") no LED characteristic";
                deviceDisconnect();
            }
        }

        if (m_ble_action == DeviceUtils::ACTION_UPDATE ||
            m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
        {
            // The values land in the service cache, and are parsed together by
            // parseLiveValues() once every read has come back
            bleReadPending(serviceLive, uuid_live_sunlight);
            bleReadPending(serviceLive, uuid_live_soil_ec);
            bleReadPending(serviceLive, uuid_live_soil_temp);
            bleReadPending(serviceLive, uuid_live_air_temp);
            bleReadPending(serviceLive, uuid_live_soil_moisture_cal);
        }
    }

    serviceDiscoveryFinished();
}

/*!
 * \brief Turn the live service values into a sensor reading.
 *
 * Only called once every pending read has come back, so the values are the ones
 * we just read from the device, not leftovers from a previous connection.
 */
void DeviceParrotPot::parseLiveValues()
{
    if (!serviceLive) return;

    const QByteArray v_lx = serviceLive->characteristic(uuid_live_sunlight).value();
    const QByteArray v_sf = serviceLive->characteristic(uuid_live_soil_ec).value();
    const QByteArray v_st = serviceLive->characteristic(uuid_live_soil_temp).value();
    const QByteArray v_at = serviceLive->characteristic(uuid_live_air_temp).value();
    const QByteArray v_smc = serviceLive->characteristic(uuid_live_soil_moisture_cal).value();

    if (v_lx.size() < 2 || v_sf.size() < 2 || v_st.size() < 2 || v_at.size() < 2 || v_smc.size() < 4)
    {
        qWarning() << "DeviceParrotPot::parseLiveValues(" << m_deviceAddress << ") incomplete live values";

        if (m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            refreshDataFinished(false);
            deviceDisconnect();
        }
        return;
    }

    const quint8 *rawData = nullptr;
    uint32_t rawValue = 0;

    /////////

    rawData = reinterpret_cast<const quint8 *>(v_lx.constData());
    rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));
    // sensor output is linear in illuminance, and reads ~3 with the sensor obstructed
    m_luminosityLux = static_cast<int>(std::lround(22.06 * rawValue - 73.5));
    if (m_luminosityLux < 0) m_luminosityLux = 0;

    /////////

    rawData = reinterpret_cast<const quint8 *>(v_sf.constData());
    rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));
    // sensor output (no soil: 2036) - (max observed: 1747) wich maps to 0 - 10 (mS/cm)
    if (rawValue < 1500) rawValue = 1500;
    if (rawValue > 2036) rawValue = 2036;
    m_soilConductivity = mapNumber(rawValue, 2036, 1500, 0, 1000, false);

    /////////

    rawData = reinterpret_cast<const quint8 *>(v_st.constData());
    rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));
    m_soilTemperature = 0.00000003044 * std::pow(rawValue, 3.0) - 0.00008038 * std::pow(rawValue, 2.0) + rawValue * 0.1149 - 30.449999999999999;

    /////////

    rawData = reinterpret_cast<const quint8 *>(v_at.constData());
    rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));
    m_temperature = 0.00000003044 * std::pow(rawValue, 3.0) - 0.00008038 * std::pow(rawValue, 2.0) + rawValue * 0.1149 - 30.449999999999999;
    if (m_temperature < -10.f) m_temperature = -10.f;
    if (m_temperature > 55.f) m_temperature = 55.f;

    /////////
/*
    // soil moisture (raw), 39e1fa05-84a8-11e2-afba-0002a5d5c51b
    rawData = reinterpret_cast<const quint8 *>(v_sm.constData());
    rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));
    double hygro1 = 11.4293 + (0.0000000010698 * std::pow(rawValue, 4.0) - 0.00000152538 * std::pow(rawValue, 3.0) + 0.000866976 * std::pow(rawValue, 2.0) - 0.169422 * rawValue);
    double hygro2 = 100.0 * (0.0000045 * std::pow(hygro1, 3.0) - 0.00055 * std::pow(hygro1, 2.0) + 0.0292 * hygro1 - 0.053);
    if (hygro2 < 0.0) hygro2 = 0.0;
    if (hygro2 > 60.0) hygro2 = 60.0;
    m_soilMoisture = std::round(hygro2);
*/
    /////////

    const float soilMoisture = DeviceUtils::readFloatLE(v_smc, 0);
    const bool soilMoistureValid = (std::isfinite(soilMoisture) && soilMoisture >= 0.f && soilMoisture <= 100.f);
    if (soilMoistureValid) m_soilMoisture = static_cast<int>(std::lround(soilMoisture));
/*
    // air temperature (calibrated), 39e1fa0a-84a8-11e2-afba-0002a5d5c51b
    m_temperature = DeviceUtils::readFloatLE(v_atc, 0);
*/
/*
    // sunlight / DLI (calibrated), 39e1fa0b-84a8-11e2-afba-0002a5d5c51b // unusable, give bad values
    m_luminosityLux = std::round(DeviceUtils::readFloatLE(v_dlic, 0)) * 11.574 * 53.93 * 10.0;
*/
    /////////

    if (!soilMoistureValid ||
        m_soilTemperature < -10.f || m_soilTemperature > 100.f ||
        m_temperature < -10.f || m_temperature > 100.f ||
        m_luminosityLux < 0 || m_luminosityLux > 200000)
    {
        // Sometimes, Parrot devices send obviously wrong data over BLE
        // Maybe the sensor is warming up?
        qWarning() << "Parrot sensor values error";

        if (m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            refreshDataFinished(false);
            deviceDisconnect();
        }
    }
    else
    {
        m_lastUpdate = QDateTime::currentDateTime();

        if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
        {
            refreshRealtime(); // TODO // ask for new values?
        }
        else
        {
            bool status = addDatabaseRecord(m_lastUpdate.toSecsSinceEpoch(),
                                            m_soilMoisture, m_soilConductivity, m_soilTemperature, m_watertank_level,
                                            m_temperature, -99.f, m_luminosityLux);

            refreshDataFinished(status);

            deviceDisconnect();
        }
    }

    /////////
/*
    qDebug() << "* DeviceParrotPot update:" << getAddress();
    qDebug() << "- m_firmware:" << m_deviceFirmware;
    qDebug() << "- m_battery:" << m_deviceBattery;
    qDebug() << "- m_soilMoisture:" << m_soilMoisture;
    qDebug() << "- m_soilConductivity:" << m_soilConductivity;
    qDebug() << "- m_soilTemperature:" << m_soilTemperature;
    qDebug() << "- m_temperature:" << m_temperature;
    qDebug() << "- m_luminosityLux:" << m_luminosityLux;
*/
}

void DeviceParrotPot::serviceDetailsDiscovered_watering(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceWatering)
    {
        //qDebug() << "DeviceParrotPot::serviceDetailsDiscovered_watering(" << m_deviceAddress << ") > ServiceDiscovered";

        if (m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            // Characteristic "water tank level", parsed in bleReadDone()
            bleReadPending(serviceWatering, uuid_watering_tank_level);
        }

        if (m_ble_action == DeviceUtils::ACTION_WATERING)
        {
            const QLowEnergyCharacteristic cwt = serviceWatering->characteristic(uuid_watering_trigger);
            if (cwt.isValid())
            {
                serviceWatering->writeCharacteristic(cwt, QByteArray::fromHex("0800"));
            }
            else
            {
                qWarning() << "DeviceParrotPot::serviceDetailsDiscovered_watering(" << m_deviceAddress << ") no watering trigger characteristic";
                deviceDisconnect();
            }
        }
    }

    serviceDiscoveryFinished();
}

void DeviceParrotPot::serviceDetailsDiscovered_clock(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceClock)
    {
        //qDebug() << "DeviceParrotPot::serviceDetailsDiscovered_clock(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "current time", parsed in bleReadDone()
        bleReadPending(serviceClock, uuid_clock_time);
    }

    serviceDiscoveryFinished();
}

void DeviceParrotPot::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceHistory)
    {
        //qDebug() << "DeviceParrotPot::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";
    }

    serviceDiscoveryFinished();
}

/* ************************************************************************** */

void DeviceParrotPot::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceParrotPot::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    Q_UNUSED(c)
    Q_UNUSED(value)
}

void DeviceParrotPot::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceParrotPot::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    // Read firmware version
    if (c.uuid() == uuid_firmware)
    {
        QString fw = parseFirmwareRevision(value);
        if (!fw.isEmpty())
        {
            setFirmware(fw);

            QVersionNumber fw_version = QVersionNumber::fromString(m_deviceFirmware);
            if (!fw_version.isNull() &&
                fw_version >= QVersionNumber::fromString(LATEST_KNOWN_FIRMWARE_PARROTPOT))
            {
                m_firmware_uptodate = true;
                Q_EMIT firmwareUpdated();
            }
        }
    }

    // Read battery level
    if (c.uuid() == uuid_battery_level)
    {
        if (value.size() == 1)
        {
            int lvl = static_cast<uint8_t>(value.constData()[0]);
            setBattery(lvl);
        }
    }

    // Read water tank level
    if (c.uuid() == uuid_watering_tank_level)
    {
        if (value.size() >= 1)
        {
            int water_percent = static_cast<uint8_t>(value.constData()[0]);
            m_watertank_level = (water_percent * m_watertank_capacity) / 100.0;

            //qDebug() << "* DeviceParrotPot water tank: " << m_watertank_level;
        }
    }

    // Read device clock
    if (c.uuid() == uuid_clock_time)
    {
        if (value.size() >= 4)
        {
            const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
            m_device_time = DeviceUtils::readLE(data, 0, 4);
            m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;

            qDebug() << "* DeviceParrotPot clock: " << m_device_time;
        }
    }

    if (m_reads_pending > 0) m_reads_pending--;

    bleWorkFinished();
}

void DeviceParrotPot::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceParrotPot::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    Q_UNUSED(c)
    Q_UNUSED(value)
}

/* ************************************************************************** */
