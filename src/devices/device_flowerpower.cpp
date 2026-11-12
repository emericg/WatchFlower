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

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QVersionNumber>
#include <QDateTime>
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

    m_services_pending = 0;
    m_reads_pending = 0;

    // Every service is discovered with SkipValueDiscovery: a Flower Power exposes
    // dozens of characteristics we never look at, and a full discovery reads all
    // of their values *and* descriptors before we get a chance to do anything.
    // The handful of values we need are read explicitly instead, from the
    // serviceDetailsDiscovered_*() handlers.

    if (serviceInfos)
    {
        if (serviceInfos->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceInfos, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_infos);
            connect(serviceInfos, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            connect(serviceInfos, &QLowEnergyService::errorOccurred, this, &DeviceFlowerPower::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceInfos->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceBattery)
    {
        if (serviceBattery->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceBattery, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_battery);
            connect(serviceBattery, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            connect(serviceBattery, &QLowEnergyService::errorOccurred, this, &DeviceFlowerPower::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceBattery->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceClock)
    {
        if (serviceClock->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceClock, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_clock);
            connect(serviceClock, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            connect(serviceClock, &QLowEnergyService::errorOccurred, this, &DeviceFlowerPower::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceClock->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceHistory)
    {
        if (serviceHistory->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceHistory, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_history);
            connect(serviceHistory, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            connect(serviceHistory, &QLowEnergyService::characteristicWritten, this, &DeviceFlowerPower::bleWriteDone);
            connect(serviceHistory, &QLowEnergyService::errorOccurred, this, &DeviceFlowerPower::bleReadErrored);

            m_services_pending++;

            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { serviceHistory->discoverDetails(QLowEnergyService::SkipValueDiscovery); });
        }
    }

    if (serviceLive)
    {
        if (serviceLive->state() == QLowEnergyService::RemoteService)
        {
            connect(serviceLive, &QLowEnergyService::stateChanged, this, &DeviceFlowerPower::serviceDetailsDiscovered_live);
            connect(serviceLive, &QLowEnergyService::characteristicRead, this, &DeviceFlowerPower::bleReadDone);
            connect(serviceLive, &QLowEnergyService::errorOccurred, this, &DeviceFlowerPower::bleReadErrored);

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
void DeviceFlowerPower::bleReadPending(QLowEnergyService *service, const QBluetoothUuid &uuid)
{
    if (!service) return;

    const QLowEnergyCharacteristic c = service->characteristic(uuid);
    if (!c.isValid())
    {
        qWarning() << "DeviceFlowerPower::bleReadPending(" << m_deviceAddress << ") unknown characteristic:" << uuid.toString();
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
void DeviceFlowerPower::serviceDiscoveryFinished()
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
void DeviceFlowerPower::bleReadErrored(QLowEnergyService::ServiceError error)
{
    if (error != QLowEnergyService::CharacteristicReadError) return;

    qWarning() << "DeviceFlowerPower::bleReadErrored(" << m_deviceAddress << ") error:" << error;

    if (m_reads_pending > 0) m_reads_pending--;

    bleWorkFinished();
}

/*!
 * \brief Called whenever a service discovery or a characteristic read settles.
 *
 * Once nothing is in flight anymore, every value we asked for is sitting in its
 * service cache and the live values can be turned into a sensor reading.
 */
void DeviceFlowerPower::bleWorkFinished()
{
    if (m_services_pending > 0 || m_reads_pending > 0) return;

    if (m_ble_action == DeviceUtils::ACTION_UPDATE ||
        m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
    {
        parseLiveValues();
    }
}

/* ************************************************************************** */

void DeviceFlowerPower::addLowEnergyService(const QBluetoothUuid &uuid)
{
    //qDebug() << "DeviceFlowerPower::addLowEnergyService(" << uuid.toString() << ")";

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

        if (m_ble_action == DeviceUtils::ACTION_UPDATE ||
            m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            serviceClock = m_bleController->createServiceObject(uuid);
            if (!serviceClock)
                qWarning() << "Cannot create service (clock) for uuid:" << uuid.toString();
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

void DeviceFlowerPower::serviceDetailsDiscovered_infos(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceInfos)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_infos(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Firmware Revision String", parsed in bleReadDone()
        bleReadPending(serviceInfos, uuid_firmware);
    }

    serviceDiscoveryFinished();
}

void DeviceFlowerPower::serviceDetailsDiscovered_battery(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceBattery)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_battery(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "Battery Level", parsed in bleReadDone()
        bleReadPending(serviceBattery, uuid_battery_level);
    }

    serviceDiscoveryFinished();
}

void DeviceFlowerPower::serviceDetailsDiscovered_live(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceLive)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_live(" << m_deviceAddress << ") > ServiceDiscovered";

        if (m_ble_action == DeviceUtils::ACTION_LED_BLINK)
        {
            // Make LED blink
            const QLowEnergyCharacteristic cled = serviceLive->characteristic(uuid_live_led);
            if (cled.isValid())
            {
                serviceLive->writeCharacteristic(cled, QByteArray::fromHex("01"), QLowEnergyService::WriteWithResponse);

                //deviceDisconnect();
            }
            else
            {
                qWarning() << "DeviceFlowerPower::serviceDetailsDiscovered_live(" << m_deviceAddress << ") no LED characteristic";
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
            bleReadPending(serviceLive, uuid_live_soil_moisture);

            // The last move date is absent from firmware 2.0.3
            if (serviceLive->characteristic(uuid_live_last_move).isValid())
            {
                bleReadPending(serviceLive, uuid_live_last_move);
            }
            else if (hasLastMove())
            {
                m_deviceCapabilities &= ~DeviceUtils::DEVICE_LAST_MOVE;
                Q_EMIT capabilitiesUpdated();
            }
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
void DeviceFlowerPower::parseLiveValues()
{
    if (!serviceLive) return;

    const QByteArray v_lx = serviceLive->characteristic(uuid_live_sunlight).value();
    const QByteArray v_sf = serviceLive->characteristic(uuid_live_soil_ec).value();
    const QByteArray v_st = serviceLive->characteristic(uuid_live_soil_temp).value();
    const QByteArray v_at = serviceLive->characteristic(uuid_live_air_temp).value();
    const QByteArray v_sm = serviceLive->characteristic(uuid_live_soil_moisture).value();
    const QByteArray v_lm = serviceLive->characteristic(uuid_live_last_move).value();

    if (v_lx.size() < 2 || v_sf.size() < 2 || v_st.size() < 2 || v_at.size() < 2 || v_sm.size() < 2)
    {
        qWarning() << "DeviceFlowerPower::parseLiveValues(" << m_deviceAddress << ") incomplete live values";

        if (m_ble_action == DeviceUtils::ACTION_UPDATE)
        {
            refreshDataFinished(false);
            deviceDisconnect();
        }
        return;
    }

    const quint8 *rawData = nullptr;
    double rawValue = 0;

    /////////
/*
    if (QVersionNumber::fromString(m_firmware) >= Version("1.1.0"))
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

        rawData = reinterpret_cast<const quint8 *>(v_lx.constData());
        rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));

        // The sensor gives a daily light integral, in mol/m²/day
        double dli = 0.08640000000000001 * (192773.17000000001 * std::pow(rawValue, -1.0606619));
        // DLI * 1e6/86400 is the mean PPFD (µmol/m²/s), then PPF to lux for the daylight spectrum
        m_luminosityLux = std::round(dli * 11.574 * 53.93);

        /////////

        rawData = reinterpret_cast<const quint8 *>(v_sf.constData());
        rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));
        // sensor output (no soil: 0) - (max observed: 1771) wich maps to 0 - 10 (mS/cm)
        // divide by 177,1 to 10 (mS/cm)
        // divide by 1,771 to 1 (uS/cm)
        m_soilConductivity = std::round(rawValue / 1.771);

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

        rawData = reinterpret_cast<const quint8 *>(v_sm.constData());
        rawValue = static_cast<uint16_t>(DeviceUtils::readLE(rawData, 0, 2));
        double hygro1 = 11.4293 + (0.0000000010698 * std::pow(rawValue, 4.0) - 0.00000152538 * std::pow(rawValue, 3.0) + 0.000866976 * std::pow(rawValue, 2.0) - 0.169422 * rawValue);
        double hygro2 = 100.0 * (0.0000045 * std::pow(hygro1, 3.0) - 0.00055 * std::pow(hygro1, 2.0) + 0.0292 * hygro1 - 0.053);
        if (hygro2 < 0.0) hygro2 = 0.0;
        if (hygro2 > 60.0) hygro2 = 60.0;
        m_soilMoisture = std::round(hygro2);
    }

    /////////

    // TODO
    //QBluetoothUuid live_mesure_period(QStringLiteral("39e1fa06-84a8-11e2-afba-0002a5d5c51b"));
    //QBluetoothUuid led_status(QStringLiteral("39e1fa07-84a8-11e2-afba-0002a5d5c51b"));

    /////////

    if (v_lm.size() >= 4 && m_device_wall_time > 0)
    {
        rawData = reinterpret_cast<const quint8 *>(v_lm.constData());
        rawValue = static_cast<uint32_t>(DeviceUtils::readLE(rawData, 0, 4));

        // The last move is given as a device uptime, turn it into a timestamp
        m_device_lastmove = rawValue + m_device_wall_time;
    }

    /////////

    if (m_soilTemperature < -10.f || m_soilTemperature > 100.f ||
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
                                            m_soilMoisture, m_soilConductivity, m_soilTemperature, -99.f,
                                            m_temperature, -99.f, m_luminosityLux);

            refreshDataFinished(status);

            deviceDisconnect();
        }
    }

    /////////
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

void DeviceFlowerPower::serviceDetailsDiscovered_clock(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceClock)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_clock(" << m_deviceAddress << ") > ServiceDiscovered";

        // Characteristic "current time", parsed in bleReadDone()
        bleReadPending(serviceClock, uuid_clock_time);
    }

    serviceDiscoveryFinished();
}

void DeviceFlowerPower::serviceDetailsDiscovered_history(QLowEnergyService::ServiceState newState)
{
    if (newState != QLowEnergyService::RemoteServiceDiscovered) return;

    if (serviceHistory)
    {
        //qDebug() << "DeviceFlowerPower::serviceDetailsDiscovered_history(" << m_deviceAddress << ") > ServiceDiscovered";

        if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
        {
            //39e1fc01-84a8-11e2-afba-0002a5d5c51b	0x48	read	number of entries
            //39e1fc02-84a8-11e2-afba-0002a5d5c51b	0x4c	read	last entry index
            //39e1fc03-84a8-11e2-afba-0002a5d5c51b	0x50	read/write	start transfert index
            //39e1fc04-84a8-11e2-afba-0002a5d5c51b	0x54	read	current session id
            //39e1fc05-84a8-11e2-afba-0002a5d5c51b	0x58	read	current session start index
            //39e1fc06-84a8-11e2-afba-0002a5d5c51b	0x5c	read	current session period
        }
    }

    serviceDiscoveryFinished();
}

/* ************************************************************************** */

void DeviceFlowerPower::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerPower::bleWriteDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    Q_UNUSED(c)
    Q_UNUSED(value)
}

void DeviceFlowerPower::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerPower::bleReadDone(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
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
                fw_version >= QVersionNumber::fromString(LATEST_KNOWN_FIRMWARE_FLOWERPOWER))
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

    // Read device clock
    if (c.uuid() == uuid_clock_time)
    {
        if (value.size() >= 4)
        {
            const quint8 *data = reinterpret_cast<const quint8 *>(value.constData());
            m_device_time = DeviceUtils::readLE(data, 0, 4);
            m_device_wall_time = QDateTime::currentSecsSinceEpoch() - m_device_time;

            qDebug() << "* DeviceFlowerPower clock: " << m_device_time;
        }
    }

    if (m_reads_pending > 0) m_reads_pending--;

    bleWorkFinished();
}

void DeviceFlowerPower::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    //qDebug() << "DeviceFlowerPower::bleReadNotify(" << m_deviceAddress << ") on" << c.name() << " / uuid" << c.uuid() << value.size();
    //qDebug() << "DATA: 0x" << value.toHex();

    Q_UNUSED(c)
    Q_UNUSED(value)
}

/* ************************************************************************** */
