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

#include "device_sensor.h"
#include "device_firmwares.h"
#include "utils_versionchecker.h"

#include "DeviceManager.h"
#include "SettingsManager.h"
#include "NotificationManager.h"

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

DeviceSensor::DeviceSensor(const QString &deviceAddr, const QString &deviceName, QObject *parent) :
    Device(deviceAddr, deviceName, parent)
{
    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensor::actionTimedout);
}

DeviceSensor::DeviceSensor(const QBluetoothDeviceInfo &d, QObject *parent) :
    Device(d, parent)
{
    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensor::actionTimedout);
}

DeviceSensor::~DeviceSensor()
{
    if (m_deviceInfos) delete m_deviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::refreshDataFinished(bool status, bool cached)
{
    //qDebug() << "DeviceSensor::refreshDataFinished()" << getAddress() << getName();

    Device::refreshDataFinished(status, cached);

    if (status == true)
    {
        SettingsManager *sm = SettingsManager::getInstance();
        NotificationManager *nm = NotificationManager::getInstance();
        DeviceManager *dm = static_cast<DeviceManager *>(parent());
        if (!sm || !nm || !dm) return;

        // FIXME // Plant sensor? Reorder the sensor list by water level (if needed)
        //if (isPlantSensor() && sm->getOrderBy() == "waterlevel") dm->invalidate();

        // Notifications enabled?
        if (sm->getNotifs())
        {
            QString title;
            QString message;
            int channel = 0;

            if (isPlantSensor())
            {
                // 'water me' notification // Only if the sensor has a plant?
                if (sm->getNotifWater() &&
                    m_soilMoisture > 0 && m_soilMoisture < m_soilMoisture_limit_min)
                {
                    channel = 1;
                    title = tr("Plant Alarm");

                    if (!m_associatedName.isEmpty())
                        message = tr("You need to water your '%1' now!").arg(m_associatedName);
                    else if (!m_locationName.isEmpty())
                        message = tr("You need to water the plant near '%1'").arg(m_locationName);
                    else
                        message = tr("You need to water one of your plant!");
                }

                // 'sub zero' temperature notification
                if (sm->getNotifSubzero() &&
                    ((hasTemperatureSensor() && m_temperature > -99.f && m_temperature < 2.f) ||
                     (hasSoilTemperatureSensor() && m_soilTemperature > -99.f && m_soilTemperature < 2.f)))
                {
                    channel = 2;
                    title = tr("Sub zero temperature warning");
                    message = tr("Temperature is %1 at %2 on %3").arg(getTempString(),
                                                                      QDateTime::currentDateTime().toString("hh:mm"),
                                                                      QDateTime::currentDateTime().toString("MM/dd"));
                }
            }

            if (isThermometer())
            {
                channel = 2;

                // 'sub zero' temperature notification // Only if the sensor is outside?
                if (sm->getNotifSubzero() && isOutside() &&
                    (hasTemperatureSensor() && m_temperature > -99.f && m_temperature < 2.f))
                {
                    channel = 2;
                    title = tr("Sub zero temperature warning");
                    message = tr("Temperature is %1 at %2 on %3").arg(getTempString(),
                                                                      QDateTime::currentDateTime().toString("hh:mm"),
                                                                      QDateTime::currentDateTime().toString("MM/dd"));
                }
            }

            if (isEnvironmentalSensor() && sm->getNotifEnv())
            {
                channel = 3;

                // 'ventilate' notification
                if ((hasVocSensor() && m_voc > 1000) ||
                    (hasHchoSensor() && m_hcho > 1000) ||
                    (hasCo2Sensor() && m_co2 > 1500))
                {
                    title = tr("Poor air quality");
                    message = tr("You should ventilate your room now!");
                }

                // 'radiation' notification
                if (hasGeigerCounter())
                {
                    title = tr("Radiation warning");
                    if (m_rm > 1) message = tr("Radiation levels are high!");
                    if (m_rm > 10) message = tr("Radiation levels are very high, please advise!");
                }
            }

            if (hasBatteryLevel() && sm->getNotifBatt())
            {
                if (m_deviceBattery < 10)
                {
                    channel = 4;
                    title = tr("Low battery");
                    message = tr("Sensor '%1' has low battery level").arg(m_deviceName);
                }
            }

            // Send notification
            if (!title.isEmpty() && !message.isEmpty())
            {
                nm->setNotification(title, message, channel);
            }
        }
    }
}

/* ************************************************************************** */

void DeviceSensor::refreshHistoryFinished(bool status)
{
    //qDebug() << "DeviceSensor::refreshHistoryFinished()" << getAddress() << getName();

    Device::refreshHistoryFinished(status);

    m_history_entryCount = -1;
    m_history_entryIndex = -1;
    m_history_sessionCount = -1;
    m_history_sessionRead = -1;

    if (m_lastHistorySync.isValid())
    {
        // Write last sync
        QSqlQuery updateDeviceLastSync;
        updateDeviceLastSync.prepare("UPDATE devices SET lastSync = :sync WHERE deviceAddr = :deviceAddr");
        updateDeviceLastSync.bindValue(":sync", m_lastHistorySync.toString("yyyy-MM-dd hh:mm:ss"));
        updateDeviceLastSync.bindValue(":deviceAddr", getAddress());
        if (updateDeviceLastSync.exec() == false)
        {
            qWarning() << "> updateDeviceLastSync.exec() ERROR"
                       << updateDeviceLastSync.lastError().type() << ":" << updateDeviceLastSync.lastError().text();
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceSensor::getSqlDeviceInfos()
{
    //qDebug() << "DeviceSensor::getSqlDeviceInfos(" << m_deviceAddress << ")";
    bool status = Device::getSqlDeviceInfos();

    if ((m_deviceName == "Flower care" || m_deviceName == "Flower mate") && (m_deviceFirmware.size() == 5))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName.startsWith("Flower power")) && (m_deviceFirmware.size() == 5))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERPOWER))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if (m_deviceName == "Grow care garden" && m_deviceFirmware.size() == 5)
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERCARE_MAX))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if (m_deviceName == "TY" && m_deviceFirmware.size() == 4)
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_FLOWERCARE_TUYA))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "ropot") && (m_deviceFirmware.size() == 5))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_ROPOT))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName.startsWith("Parrot pot")) && (m_deviceFirmware.size() == 6))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_PARROTPOT))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "MJ_HT_V1") && (m_deviceFirmware.size() == 8))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_LYWSDCGQ))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "ClearGrass Temp & RH") && (m_deviceFirmware.size() == 10))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName.startsWith("Qingping Temp & RH")) && (m_deviceFirmware.size() == 10))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "LYWSD02") && (m_deviceFirmware.size() == 10))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "LYWSD03MMC") && (m_deviceFirmware.size() == 10))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_LYWSD03MMC))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "XMWSDJO4MMC") && (m_deviceFirmware.size() == 10))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_XMWSDJO4MMC))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "MHO-C401") && (m_deviceFirmware.size() == 10))
    {
        if (VersionChecker(m_deviceFirmware) >= VersionChecker(LATEST_KNOWN_FIRMWARE_HYGROTEMP_MHOC401))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceSensor::getSqlPlantBias()
{
    //qDebug() << "DeviceSensor::getSqlPlantBias(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery getBias;
        getBias.prepare("SELECT soilMoisture_bias, soilConductivity_bias, soilTemperature_bias, soilPH_bias," \
                        " temperature_bias, humidity_bias, luminosity_bias " \
                        "FROM plantBias WHERE deviceAddr = :deviceAddr");
        getBias.bindValue(":deviceAddr", getAddress());

        if (getBias.exec())
        {
            while (getBias.next())
            {
                m_soilMoisture_bias = getBias.value(0).toFloat();
                m_soilConductivity_bias = getBias.value(1).toFloat();
                m_soilTemperature_bias = getBias.value(2).toFloat();
                m_soilPH_bias = getBias.value(3).toFloat();
                m_temperature_bias = getBias.value(4).toFloat();
                m_humidity_bias = getBias.value(5).toFloat();
                m_luminosity_bias = getBias.value(6).toFloat();

                status = true;
                Q_EMIT biasUpdated();
            }
        }
        else
        {
            qWarning() << "> getBias.exec(plant) ERROR"
                       << getBias.lastError().type() << ":" << getBias.lastError().text();
        }
    }

    return status;
}

bool DeviceSensor::setSqlPlantBias()
{
    //qDebug() << "DeviceSensor::setSqlPlantBias(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery updateBias;
        updateBias.prepare("REPLACE INTO plantBias (deviceAddr," \
                             "soilMoisture_bias, soilConductivity_bias, soilTemperature_bias, soilPH_bias," \
                             "temperature_bias, humidity_bias, luminosity_bias) " \
                           "VALUES (:deviceAddr," \
                                   ":soilMoist, :soilCondu, :soilTemp, :soilPH," \
                                   ":temp, :humi, :lumi)");
        updateBias.bindValue(":deviceAddr", getAddress());
        updateBias.bindValue(":soilMoist", m_soilMoisture_bias);
        updateBias.bindValue(":soilCondu", m_soilConductivity_bias);
        updateBias.bindValue(":soilTemp", m_soilTemperature_bias);
        updateBias.bindValue(":soilPH", m_soilPH_bias);
        updateBias.bindValue(":temp", m_temperature_bias);
        updateBias.bindValue(":humi", m_humidity_bias);
        updateBias.bindValue(":lumi", m_luminosity_bias);

        status = updateBias.exec();
        if (status == false)
        {
            qWarning() << "> updateBias.exec(plant) ERROR"
                       << updateBias.lastError().type() << ":" << updateBias.lastError().text();
        }
    }

    Q_EMIT biasUpdated();

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlPlantLimits()
{
    //qDebug() << "DeviceSensor::getSqlPlantLimits(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery getLimits;
        getLimits.prepare("SELECT soilMoisture_min, soilMoisture_max," \
                            "soilConductivity_min, soilConductivity_max," \
                            "soilPH_min, soilPH_max," \
                            "temperature_min, temperature_max, humidity_min, humidity_max," \
                            "luminosityLux_min, luminosityLux_max, luminosityMmol_min, luminosityMmol_max " \
                          "FROM plantLimits WHERE deviceAddr = :deviceAddr");
        getLimits.bindValue(":deviceAddr", getAddress());

        if (getLimits.exec())
        {
            while (getLimits.next())
            {
                m_soilMoisture_limit_min = getLimits.value(0).toInt();
                m_soilMoisture_limit_max = getLimits.value(1).toInt();
                m_soilConductivity_limit_min = getLimits.value(2).toInt();
                m_soilConductivity_limit_max = getLimits.value(3).toInt();
                m_soilPH_limit_min = getLimits.value(4).toInt();
                m_soilPH_limit_max = getLimits.value(5).toInt();
                m_temperature_limit_min = getLimits.value(6).toInt();
                m_temperature_limit_max = getLimits.value(7).toInt();
                m_humidity_limit_min = getLimits.value(8).toInt();
                m_humidity_limit_max = getLimits.value(9).toInt();
                m_luminosityLux_limit_min = getLimits.value(10).toInt();
                m_luminosityLux_limit_max = getLimits.value(11).toInt();
                m_luminosityMmol_limit_min = getLimits.value(12).toInt();
                m_luminosityMmol_limit_max = getLimits.value(13).toInt();

                status = true;
                Q_EMIT limitsUpdated();
            }
        }
        else
        {
            qWarning() << "> getLimits.exec(plant) ERROR"
                       << getLimits.lastError().type() << ":" << getLimits.lastError().text();
        }
    }

    return status;
}

bool DeviceSensor::setSqlPlantLimits()
{
    //qDebug() << "DeviceSensor::setSqlPlantLimits(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery updateLimits;
        updateLimits.prepare("REPLACE INTO plantLimits (deviceAddr," \
                               "soilMoisture_min, soilMoisture_max," \
                               "soilConductivity_min, soilConductivity_max," \
                               "soilPH_min, soilPH_max,"
                               "temperature_min, temperature_max, humidity_min, humidity_max," \
                               "luminosityLux_min, luminosityLux_max, luminosityMmol_min, luminosityMmol_max) " \
                             "VALUES (:deviceAddr," \
                                     ":hygroMin, :hygroMax, :conduMin, :conduMax, :phMin, :phMax, :tempMin, :tempMax," \
                                     ":humiMin, :humiMax, :luxMin, :luxMax, :mmolMin, :mmolMax)");
        updateLimits.bindValue(":deviceAddr", getAddress());
        updateLimits.bindValue(":hygroMin", m_soilMoisture_limit_min);
        updateLimits.bindValue(":hygroMax", m_soilMoisture_limit_max);
        updateLimits.bindValue(":conduMin", m_soilConductivity_limit_min);
        updateLimits.bindValue(":conduMax", m_soilConductivity_limit_max);
        updateLimits.bindValue(":phMin", m_soilPH_limit_min);
        updateLimits.bindValue(":phMax", m_soilPH_limit_max);
        updateLimits.bindValue(":tempMin", m_temperature_limit_min);
        updateLimits.bindValue(":tempMax", m_temperature_limit_max);
        updateLimits.bindValue(":humiMin", m_humidity_limit_min);
        updateLimits.bindValue(":humiMax", m_humidity_limit_max);
        updateLimits.bindValue(":luxMin", m_luminosityLux_limit_min);
        updateLimits.bindValue(":luxMax", m_luminosityLux_limit_max);
        updateLimits.bindValue(":mmolMin", m_luminosityMmol_limit_min);
        updateLimits.bindValue(":mmolMax", m_luminosityMmol_limit_max);

        status = updateLimits.exec();
        if (status == false)
        {
            qWarning() << "> updateLimits.exec(plant) ERROR"
                       << updateLimits.lastError().type() << ":" << updateLimits.lastError().text();
        }
    }

    Q_EMIT limitsUpdated();

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlPlantData(int minutes)
{
    //qDebug() << "DeviceSensor::getSqlPlantData(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedData;
    if (m_dbInternal) // sqlite
    {
        cachedData.prepare("SELECT timestamp, soilMoisture, soilConductivity, soilTemperature, soilPH, temperature, humidity, luminosity, watertank " \
                           "FROM plantData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= datetime('now', 'localtime', '-" + QString::number(minutes) + " minutes') " \
                           "ORDER BY timestamp DESC " \
                           "LIMIT 1;");
    }
    else if (m_dbExternal) // mysql
    {
        cachedData.prepare("SELECT DATE_FORMAT(timestamp, '%Y-%m-%e %H:%i:%s'), soilMoisture, soilConductivity, soilTemperature, soilPH, temperature, humidity, luminosity, watertank " \
                           "FROM plantData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= TIMESTAMPADD(MINUTE,-" + QString::number(minutes) + ",NOW()) " \
                           "ORDER BY timestamp DESC " \
                           "LIMIT 1;");
    }
    cachedData.bindValue(":deviceAddr", getAddress());

    if (cachedData.exec() == false)
    {
        qWarning() << "> cachedData.exec(plant) ERROR"
                   << cachedData.lastError().type() << ":" << cachedData.lastError().text();
    }

    while (cachedData.next())
    {
        m_soilMoisture = cachedData.value(1).toInt();
        m_soilConductivity = cachedData.value(2).toInt();
        m_soilTemperature = cachedData.value(3).toFloat();
        m_soilPH = cachedData.value(4).toFloat();
        m_temperature = cachedData.value(5).toFloat();
        m_humidity = cachedData.value(6).toFloat();
        m_luminosityLux = cachedData.value(7).toInt();
        m_watertank_level = cachedData.value(8).toFloat();

        QString datetime = cachedData.value(0).toString();
        m_lastUpdateDatabase = m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");
/*
        qDebug() << ">> timestamp" << m_lastUpdate;
        qDebug() << "- m_soilMoisture:" << m_soilMoisture;
        qDebug() << "- m_soilConductivity:" << m_soilConductivity;
        qDebug() << "- m_soilTemperature:" << m_soilTemperature;
        qDebug() << "- m_soilPH:" << m_soilPH;
        qDebug() << "- m_temperature:" << m_temperature;
        qDebug() << "- m_humidity:" << m_humidity;
        qDebug() << "- m_luminosityLux:" << m_luminosityLux;
        qDebug() << "- m_watertank_level:" << m_watertank_level;
*/
        status = true;
    }

    refreshDataFinished(status, true);
    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceSensor::getSqlThermoBias()
{
    //qDebug() << "DeviceSensor::getSqlThermoBias(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery getBias;
        getBias.prepare("SELECT temperature_bias, humidity_bias, pressure_bias " \
                        "FROM thermoBias WHERE deviceAddr = :deviceAddr");
        getBias.bindValue(":deviceAddr", getAddress());

        if (getBias.exec())
        {
            while (getBias.next())
            {
                m_temperature_bias = getBias.value(0).toFloat();
                m_humidity_bias = getBias.value(1).toFloat();
                m_pressure_bias = getBias.value(2).toFloat();

                status = true;
                Q_EMIT biasUpdated();
            }
        }
        else
        {
            qWarning() << "> getBias.exec(thermo) ERROR"
                       << getBias.lastError().type() << ":" << getBias.lastError().text();
        }
    }

    return status;
}

bool DeviceSensor::setSqlThermoBias()
{
    //qDebug() << "DeviceSensor::setSqlThermoBias(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery updateBias;
        updateBias.prepare("REPLACE INTO thermoBias (deviceAddr, temperature_bias, humidity_bias, luminosity_bias) " \
                           "VALUES (:deviceAddr, :temp, :humi, :pressure)");
        updateBias.bindValue(":deviceAddr", getAddress());
        updateBias.bindValue(":temp", m_temperature_bias);
        updateBias.bindValue(":humi", m_humidity_bias);
        updateBias.bindValue(":pressure", m_pressure_bias);

        status = updateBias.exec();
        if (status == false)
        {
            qWarning() << "> updateBias.exec(thermo) ERROR"
                       << updateBias.lastError().type() << ":" << updateBias.lastError().text();
        }
    }

    Q_EMIT biasUpdated();

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlThermoLimits()
{
    //qDebug() << "DeviceSensor::getSqlThermoLimits(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery getLimits;
        getLimits.prepare("SELECT temperature_min, temperature_max, humidity_min, humidity_max " \
                          "FROM thermoLimits WHERE deviceAddr = :deviceAddr");
        getLimits.bindValue(":deviceAddr", getAddress());

        if (getLimits.exec())
        {
            while (getLimits.next())
            {
                m_temperature_limit_min = getLimits.value(6).toInt();
                m_temperature_limit_max = getLimits.value(7).toInt();
                m_humidity_limit_min = getLimits.value(8).toInt();
                m_humidity_limit_max = getLimits.value(9).toInt();

                status = true;
                Q_EMIT limitsUpdated();
            }
        }
        else
        {
            qWarning() << "> getLimits.exec(thermo) ERROR"
                       << getLimits.lastError().type() << ":" << getLimits.lastError().text();
        }
    }

    return status;
}

bool DeviceSensor::setSqlThermoLimits()
{
    //qDebug() << "DeviceSensor::setSqlThermoLimits(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery updateLimits;
        updateLimits.prepare("REPLACE INTO thermoLimits (deviceAddr, temperature_min, temperature_max, humidity_min, humidity_max) " \
                             "VALUES (:deviceAddr, :tempMin, :tempMax, :humiMin, :humiMax)");
        updateLimits.bindValue(":deviceAddr", getAddress());
        updateLimits.bindValue(":tempMin", m_temperature_limit_min);
        updateLimits.bindValue(":tempMax", m_temperature_limit_max);
        updateLimits.bindValue(":humiMin", m_humidity_limit_min);
        updateLimits.bindValue(":humiMax", m_humidity_limit_max);

        status = updateLimits.exec();
        if (status == false)
        {
            qWarning() << "> updateLimits.exec(thermo) ERROR"
                       << updateLimits.lastError().type() << ":" << updateLimits.lastError().text();
        }
    }

    Q_EMIT limitsUpdated();

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlThermoData(int minutes)
{
    //qDebug() << "DeviceSensor::getSqlThermoData(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedData;
    if (m_dbInternal) // sqlite
    {
        cachedData.prepare("SELECT timestamp, temperature, humidity, pressure " \
                           "FROM thermoData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= datetime('now', 'localtime', '-" + QString::number(minutes) + " minutes') " \
                           "ORDER BY timestamp DESC " \
                           "LIMIT 1;");
    }
    else if (m_dbExternal) // mysql
    {
        cachedData.prepare("SELECT DATE_FORMAT(timestamp, '%Y-%m-%e %H:%i:%s'), temperature, humidity, pressure " \
                           "FROM thermoData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= TIMESTAMPADD(MINUTE,-" + QString::number(minutes) + ",NOW()) " \
                           "ORDER BY timestamp DESC " \
                           "LIMIT 1;");
    }
    cachedData.bindValue(":deviceAddr", getAddress());

    if (cachedData.exec() == false)
    {
        qWarning() << "> cachedData.exec(thermo) ERROR"
                   << cachedData.lastError().type() << ":" << cachedData.lastError().text();
    }

    while (cachedData.next())
    {
        m_temperature = cachedData.value(1).toFloat();
        m_humidity = cachedData.value(2).toFloat();
        m_pressure = cachedData.value(3).toFloat();

        QString datetime = cachedData.value(0).toString();
        m_lastUpdateDatabase = m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");
/*
        qDebug() << ">> timestamp" << m_lastUpdate;
        qDebug() << "- m_temperature:" << m_temperature;
        qDebug() << "- m_humidity:" << m_humidity;
        qDebug() << "- m_pressure:" << m_pressure;
*/
        status = true;
    }

    refreshDataFinished(status, true);
    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceSensor::getSqlSensorBias()
{
    //qDebug() << "DeviceSensor::getSqlSensorBias(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        // TODO
    }

    return status;
}

bool DeviceSensor::setSqlSensorBias()
{
    //qDebug() << "DeviceSensor::setSqlSensorBias(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        // TODO
    }

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlSensorLimits()
{
    //qDebug() << "DeviceSensor::getSqlSensorLimits(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        // TODO
    }

    return status;
}

bool DeviceSensor::setSqlSensorLimits()
{
    //qDebug() << "DeviceSensor::setSqlSensorLimits(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        // TODO
    }

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlSensorData(int minutes)
{
    //qDebug() << "DeviceSensor::getSqlSensorData(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedData;
    if (m_dbInternal) // sqlite
    {
        cachedData.prepare("SELECT timestamp," \
                             "temperature, humidity, pressure, luminosity, uv, sound, water, windDirection, windSpeed," \
                             "pm1, pm25, pm10, o2, o3, co, co2, no2, so2, voc, hcho, radioactivity " \
                           "FROM sensorData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= datetime('now', 'localtime', '-" + QString::number(minutes) + " minutes')" \
                           "ORDER BY timestamp DESC " \
                           "LIMIT 1;");
    }
    else if (m_dbExternal) // mysql
    {
        cachedData.prepare("SELECT DATE_FORMAT(timestamp, '%Y-%m-%e %H:%i:%s')," \
                             "temperature, humidity, pressure, luminosity, uv, sound, water, windDirection, windSpeed," \
                             "pm1, pm25, pm10, o2, o3, co, co2, no2, so2, voc, hcho, radioactivity " \
                           "FROM sensorData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= TIMESTAMPADD(MINUTE,-" + QString::number(minutes) + ",NOW()) " \
                           "ORDER BY timestamp DESC " \
                           "LIMIT 1;");
    }
    cachedData.bindValue(":deviceAddr", getAddress());

    if (cachedData.exec() == false)
    {
        qWarning() << "> cachedData.exec(sensor) ERROR"
                   << cachedData.lastError().type() << ":" << cachedData.lastError().text();
    }

    while (cachedData.next())
    {
        // hygrometer data
        m_temperature = cachedData.value(1).toFloat();
        m_humidity = cachedData.value(2).toFloat();
        // environmental data
        m_pressure = cachedData.value(3).toFloat();
        m_luminosityLux = cachedData.value(4).toInt();
        m_uv = cachedData.value(5).toFloat();
        m_sound_level = cachedData.value(6).toFloat();
        m_water_level = cachedData.value(7).toFloat();
        m_windDirection = cachedData.value(8).toFloat();
        m_windSpeed = cachedData.value(9).toFloat();
        m_pm_1 = cachedData.value(10).toFloat();
        m_pm_25 = cachedData.value(11).toFloat();
        m_pm_10 = cachedData.value(12).toFloat();
        m_o2 = cachedData.value(13).toFloat();
        m_o3 = cachedData.value(14).toFloat();
        m_co = cachedData.value(15).toFloat();
        m_co2 = cachedData.value(16).toFloat();
        m_no2 = cachedData.value(17).toFloat();
        m_so2 = cachedData.value(18).toFloat();
        m_voc = cachedData.value(19).toFloat();
        m_hcho = cachedData.value(20).toFloat();
        m_radioactivity = m_rh = m_rm = m_rs = cachedData.value(21).toFloat();

        QString datetime = cachedData.value(0).toString();
        m_lastUpdateDatabase = m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");
/*
        qDebug() << ">> timestamp" << m_lastUpdate;
        qDebug() << "- m_temperature:" << m_temperature;
        qDebug() << "- m_humidity:" << m_humidity;
        qDebug() << "- m_pressure:" << m_pressure;
        qDebug() << "- m_luminosityLux:" << m_luminosityLux;
        qDebug() << "- m_uv:" << m_uv;
        qDebug() << "- m_water_level:" << m_water_level;
        qDebug() << "- m_sound_level:" << m_sound_level;
        qDebug() << "- m_wind_direction:" << m_wind_direction;
        qDebug() << "- m_wind_speed:" << m_wind_speed;
        qDebug() << "- m_pm_1:" << m_pm_1;
        qDebug() << "- m_pm_25:" << m_pm_25;
        qDebug() << "- m_pm_10:" << m_pm_10;
        qDebug() << "- m_o2:" << m_o2;
        qDebug() << "- m_o3:" << m_o3;
        qDebug() << "- m_co:" << m_co;
        qDebug() << "- m_co2:" << m_co2;
        qDebug() << "- m_no2:" << m_no2;
        qDebug() << "- m_so2:" << m_so2;
        qDebug() << "- m_voc:" << m_voc;
        qDebug() << "- m_hcho:" << m_hcho;
        qDebug() << "- m_radioactivity:" << m_radioactivity;
*/
        status = true;
    }

    refreshDataFinished(status, true);
    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::checkDataAvailability()
{
    bool somethingchanged = false;

    // fresh
    {
        SettingsManager *sm = SettingsManager::getInstance();
        int maxMin = isPlantSensor() ? sm->getUpdateIntervalPlant() : sm->getUpdateIntervalThermo();

        bool status = (getLastUpdateInt() >= 0 && getLastUpdateInt() < maxMin);

        if (status != m_hasDataFresh)
        {
            m_hasDataFresh = status;
            somethingchanged = true;
        }
    }

    // today
    {
        bool status = (getLastUpdateInt() >= 0 && getLastUpdateInt() <= 12*60);

        if (status != m_hasDataToday)
        {
            m_hasDataToday = status;
            somethingchanged = true;
        }
    }

    // history
    if (0)
    {
        QString tableName;
        bool status = false;

        if (isPlantSensor())
        {
            // If we have immediate data (<12h old)
            if (m_soilMoisture > 0 || m_soilConductivity > 0 || m_soilTemperature > 0.f ||
                m_temperature > -20.f || m_humidity > 0.f || m_luminosityLux > 0)
                status = true;

            tableName = "plantData";
        }
        else if (isThermometer())
        {
            // If we have immediate data (<12h old)
            if (m_temperature > -20.f || m_humidity > 0.f || m_pressure > 0.f)
                status = true;

            tableName = "thermoData";
        }
        else if (isEnvironmentalSensor())
        {
            // If we have immediate data (<12h old)
            if (m_temperature > -20.f || m_humidity > 0.f || m_luminosityLux > 0 ||
                m_pm_10 > 0.f || m_co2 > 0.f || m_voc > 0.f || m_rm > 0.f)
                status = true;

            tableName = "sensorData";
        }

        // Otherwise, check if we have stored data
        if (m_dbInternal || m_dbExternal)
        {
            QSqlQuery hasData;
            hasData.prepare("SELECT COUNT(*) FROM " + tableName + " WHERE deviceAddr = :deviceAddr;");
            hasData.bindValue(":deviceAddr", getAddress());

            if (hasData.exec() == false)
            {
                qWarning() << "> hasData.exec(1) ERROR" << hasData.lastError().type() << ":" << hasData.lastError().text();
                qWarning() << "> hasData.exec(1) >" << hasData.lastQuery();
            }

            while (hasData.next())
            {
                if (hasData.value(0).toInt() > 0) // data count
                    status = true;
            }
        }

        if (status != m_hasDataHistory)
        {
            m_hasDataHistory = status;
            somethingchanged = true;
        }
    }

    if (somethingchanged) Q_EMIT dataAvailableUpdated();
}

bool DeviceSensor::hasDataNamed(const QString &dataName) const
{
    if (dataName.isEmpty()) return false;

    QString tableName;

    if (isPlantSensor())
    {
        // If we have immediate data (<12h old)
        if (dataName == "soilMoisture" && m_soilMoisture > 0)
            return true;
        else if (dataName == "soilConductivity" && m_soilConductivity > 0)
            return true;
        else if (dataName == "soilTemperature" && m_soilTemperature > 0.f)
            return true;
        else if (dataName == "soilPH" && m_soilPH > 0.f)
            return true;
        else if (dataName == "temperature" && m_temperature > -20.f)
            return true;
        else if (dataName == "humidity" && m_humidity > 0.f)
            return true;
        else if (dataName == "luminosityLux" && m_luminosityLux > 0)
            return true;
        else if (dataName == "luminosityMmol" && m_luminosityMmol > 0)
            return true;

        tableName = "plantData";
    }
    else if (isThermometer())
    {
        // If we have immediate data (<12h old)
        if (dataName == "temperature" && m_temperature > -20.f)
            return true;
        else if (dataName == "humidity" && m_humidity > 0.f)
            return true;
        else if (dataName == "pressure" && m_pressure > 0)
            return true;

        tableName = "thermoData";
    }
    else if (isEnvironmentalSensor())
    {
        // If we have immediate data (<12h old)
        if (dataName == "temperature" && m_temperature > -20.f)
            return true;
        else if (dataName == "humidity" && m_humidity > 0)
            return true;

        tableName = "sensorData";
    }
    else
    {
        return false;
    }

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(" + dataName + ") FROM " + tableName + " WHERE deviceAddr = :deviceAddr AND " + dataName + " > 0;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(2) ERROR" << hasData.lastError().type() << ":" << hasData.lastError().text();
            qWarning() << "> hasData.exec(2) >" << hasData.lastQuery();
        }

        while (hasData.next())
        {
            if (hasData.value(0).toInt() > 0) // data count
                return true;
        }
    }

    return false;
}

int DeviceSensor::countDataNamed(const QString &dataName, int days) const
{
    if (dataName.isEmpty()) return false;

    // Count stored data
    if (m_dbInternal || m_dbExternal)
    {
        QString tableName = "plantData";
        if (isThermometer()) tableName = "thermoData";
        if (isEnvironmentalSensor()) tableName = "sensorData";

        QSqlQuery dataCount;
        if (m_dbInternal) // sqlite
        {
            dataCount.prepare("SELECT COUNT(" + dataName + ")" \
                              "FROM " + tableName + " " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND " + dataName + " > -20 AND timestamp >= datetime('now','-" + QString::number(days) + " day');");
        }
        else if (m_dbExternal) // mysql
        {
            dataCount.prepare("SELECT COUNT(" + dataName + ")" \
                              "FROM " + tableName + " " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND " + dataName + " > -20 AND timestamp >= DATE_SUB(NOW(), INTERVAL " + QString::number(days) + " DAY);");
        }
        dataCount.bindValue(":deviceAddr", getAddress());

        if (dataCount.exec() == false)
        {
            qWarning() << "> dataCount.exec() ERROR"
                       << dataCount.lastError().type() << ":" << dataCount.lastError().text();
        }

        while (dataCount.next())
        {
            return dataCount.value(0).toInt();
        }
    }
    else
    {
        // No database
        if (m_soilMoisture > 0 || m_soilConductivity > 0 || m_soilTemperature > 0 ||
            m_temperature > -20.f || m_humidity > 0 || m_luminosityLux > 0)
        return 1;
    }

    return 0;
}

bool DeviceSensor::hasData() const
{
    QString tableName;

    if (isPlantSensor())
    {
        // If we have immediate data (<12h old)
        if (m_soilMoisture > 0 || m_soilConductivity > 0 || m_soilTemperature > 0 ||
            m_temperature > -20.f || m_humidity > 0 || m_luminosityLux > 0)
            return true;

        tableName = "plantData";
    }
    else if (isThermometer())
    {
        // If we have immediate data (<12h old)
        if (m_temperature > -20.f || m_humidity > 0 || m_pressure > 0)
            return true;

        tableName = "thermoData";
    }
    else if (isEnvironmentalSensor())
    {
        // If we have immediate data (<12h old)
        if (m_temperature > -20.f || m_humidity > 0 || m_luminosityLux > 0 ||
            m_pm_10 > 0 || m_co2 > 0 || m_voc > 0 || m_hcho > 0 || m_rm > 0)
            return true;

        tableName = "sensorData";
    }
    else
    {
        return false;
    }

    // Otherwise, check if we have stored data
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery hasData;
        hasData.prepare("SELECT COUNT(*) FROM " + tableName + " WHERE deviceAddr = :deviceAddr;");
        hasData.bindValue(":deviceAddr", getAddress());

        if (hasData.exec() == false)
        {
            qWarning() << "> hasData.exec(3) ERROR" << hasData.lastError().type() << ":" << hasData.lastError().text();
            qWarning() << "> hasData.exec(3) >" << hasData.lastQuery();
        }

        while (hasData.next())
        {
            if (hasData.value(0).toInt() > 0) // data count
                return true;
        }
    }

    return false;
}

bool DeviceSensor::isDataFresh_rt() const
{
    SettingsManager *sm = SettingsManager::getInstance();
    int maxMin = 120;
    if (isPlantSensor()) maxMin = sm->getUpdateIntervalPlant();
    else if (isThermometer()) maxMin = sm->getUpdateIntervalThermo();
    else if (isEnvironmentalSensor()) maxMin = sm->getUpdateIntervalEnv();

    return (getLastUpdateInt() >= 0 && getLastUpdateInt() < maxMin);
}

bool DeviceSensor::isDataFresh_db() const
{
    SettingsManager *sm = SettingsManager::getInstance();
    int maxMin = 120;
    if (isPlantSensor()) maxMin = sm->getUpdateIntervalPlant();
    else if (isThermometer()) maxMin = sm->getUpdateIntervalThermo();
    else if (isEnvironmentalSensor()) maxMin = sm->getUpdateIntervalEnv();

    return (getLastUpdateDbInt() >= 0 && getLastUpdateDbInt() < maxMin);
}

bool DeviceSensor::isDataToday() const
{
    return (getLastUpdateInt() >= 0 && getLastUpdateInt() <= 12*60);
}

bool DeviceSensor::isDataAvailable() const
{
    return hasData();
}

bool DeviceSensor::needsUpdateRt() const
{
    return !isDataFresh_rt();
}

bool DeviceSensor::needsUpdateDb() const
{
    return !isDataFresh_db();
}

bool DeviceSensor::needsUpdateDb_mini() const
{
    int minInterval = 60;
    if (isPlantSensor()) minInterval = 60;
    else if (isThermometer()) minInterval = 20;
    else if (isEnvironmentalSensor()) minInterval = 20;

    return (getLastUpdateDbInt() < 0 || getLastUpdateDbInt() > minInterval);
}

/* ************************************************************************** */
/* ************************************************************************** */

float DeviceSensor::getTemp() const
{
    SettingsManager *s = SettingsManager::getInstance();

    if (s->getTempUnit() == "F") return getTempF();
    return getTempC();
}

QString DeviceSensor::getTempString() const
{
    QString tempString;

    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        tempString = QString::number(getTempF(), 'f', 1) + "°F";
    else
        tempString = QString::number(getTempC(), 'f', 1) + "°C";

    return tempString;
}

/* ************************************************************************** */

float DeviceSensor::getHeatIndex() const
{
    float hi = getTemp();

    if (getTempC() >= 27.f && getHumidity() >= 40.0)
    {
        float T = getTemp();
        float R = getHumidity();

        float c1, c2, c3, c4, c5, c6, c7, c8, c9;
        SettingsManager *s = SettingsManager::getInstance();
        if (s->getTempUnit() == "F")
        {
            c1 = -42.379;
            c2 = 2.04901523;
            c3 = 10.14333127;
            c4 = -0.22475541;
            c5 = -6.83783e-03;
            c6 = -5.481717e-02;
            c7 = 1.22874e-03;
            c8 = 8.5282e-04;
            c9 = -1.99e-06;
        }
        else
        {
            c1 = -8.78469475556;
            c2 = 1.61139411;
            c3 = 2.33854883889;
            c4 = -0.14611605;
            c5 = -0.012308094;
            c6 = -0.0164248277778;
            c7 = 0.002211732;
            c8 = 0.00072546;
            c9 = -0.000003582;
        }

        // Compute heat index (https://en.wikipedia.org/wiki/Heat_index)
        hi = c1 + c2*T + c3*R + c4*T*R + c5*(T*T) + c6*(R*R) +c7*(T*T)*R + c8*T*(R*R) + c9*(T*T)*(R*R);
    }

    return hi;
}

QString DeviceSensor::getHeatIndexString() const
{
    QString hiString;

    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        hiString = QString::number(getHeatIndex(), 'f', 1) + "°F";
    else
        hiString = QString::number(getHeatIndex(), 'f', 1) + "°C";

    return hiString;
}

/* ************************************************************************** */

float DeviceSensor::getDewPoint() const
{
    float dew = (m_temperature - ((14.55 + 0.114 * m_temperature) * (1 - (0.01 * m_humidity)))
                               - (pow(((2.5 + 0.007 * m_temperature) * (1 - (0.01 * m_humidity))), 3))
                               - ((15.9 + 0.117 * m_temperature) * pow((1 - (0.01 * m_humidity)), 14)));

    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F") return ((dew - 32) / 1.8f);
    return dew;
}

QString DeviceSensor::getDewPointString() const
{
    QString dewString;

    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        dewString = QString::number(getDewPoint(), 'f', 1) + "°F";
    else
        dewString = QString::number(getDewPoint(), 'f', 1) + "°C";

    return dewString;
}

/* ************************************************************************** */

int DeviceSensor::getHistoryUpdatePercent() const
{
    int p = 0;

    if (m_ble_status == DeviceUtils::DEVICE_UPDATING_HISTORY)
    {
        if (m_history_sessionCount > 0)
        {
            p = static_cast<int>((m_history_sessionRead / static_cast<float>(m_history_sessionCount)) * 100.f);
        }
    }

    //qDebug() << "DeviceSensor::getHistoryUpdatePercent(" << m_history_session_read << "/" <<  m_history_session_count << ")";

    return p;
}

QDateTime DeviceSensor::getLastMove() const
{
    if (m_device_lastmove > 0)
    {
        return QDateTime::fromSecsSinceEpoch(QDateTime::currentDateTime().toSecsSinceEpoch() - m_device_lastmove);
    }

    return QDateTime();
}

float DeviceSensor::getLastMove_days() const
{
    float days = (m_device_lastmove / 3600.f / 24.f);
    if (days < 0.f) days = 0.f;

    return days;
}

/* ************************************************************************** */
/* ************************************************************************** */
