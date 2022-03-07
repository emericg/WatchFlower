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
#include "SettingsManager.h"
#include "DatabaseManager.h"
#include "DeviceManager.h"
#include "NotificationManager.h"
#include "utils/utils_versionchecker.h"

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

DeviceSensor::DeviceSensor(QString &deviceAddr, QString &deviceName, QObject *parent) :
    Device(deviceAddr, deviceName, parent)
{
    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    // Load device infos and limits
    if (m_dbInternal || m_dbExternal)
    {
        getSqlDeviceInfos();
        //getSqlSensorBias();
        getSqlPlantLimits();
        // Load initial data into the GUI (if they are no more than 12h old)
        bool data = false;
        if (!data) data = getSqlPlantData(12*60);
        if (!data) data = getSqlSensorData(12*60);
    }

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensor::actionTimedout);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &DeviceSensor::refreshStart);

    // Device infos
    m_deviceInfos = new DeviceInfos(this);
    m_deviceInfos->load(m_deviceName);
}

DeviceSensor::DeviceSensor(const QBluetoothDeviceInfo &d, QObject *parent) :
    Device(d, parent)
{
    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    // Load device infos and limits
    if (m_dbInternal || m_dbExternal)
    {
        getSqlDeviceInfos();
        //getSqlSensorBias();
        getSqlPlantLimits();
        // Load initial data into the GUI (if they are no more than 12h old)
        bool data = false;
        if (!data) data = getSqlPlantData(12*60);
        if (!data) data = getSqlSensorData(12*60);
    }

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensor::actionTimedout);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &DeviceSensor::refreshStart);

    // Device infos
    m_deviceInfos = new DeviceInfos(this);
    if (m_deviceInfos) m_deviceInfos->load(m_deviceName);
}

DeviceSensor::~DeviceSensor()
{
    qDeleteAll(m_journal_entries);
    m_journal_entries.clear();

    delete m_deviceInfos;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::refreshDataFinished(bool status, bool cached)
{
    //qDebug() << "DeviceSensor::refreshDataFinished()" << getAddress() << getName();

    Device::refreshDataFinished(status, cached);

    if (status == true)
    {
        // Plant sensor?
        if (isPlantSensor())
        {
            SettingsManager *sm = SettingsManager::getInstance();

            // Reorder the device list by water level, if needed
            if (sm->getOrderBy() == "waterlevel")
            {
                if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
            }

            // 'Water me' notification, if enabled
            if (sm->getNotifs())
            {
                // Only if the sensor has a plant
                if (m_soilMoisture > 0 && m_soilMoisture < m_limit_soilMoistureMin)
                {
                    NotificationManager *nm = NotificationManager::getInstance();
                    if (nm)
                    {
                        QString message;
                        if (!m_associatedName.isEmpty())
                            message = tr("You need to water your '%1' now!").arg(m_associatedName);
                        else if (!m_locationName.isEmpty())
                            message = tr("You need to water the plant near '%1'").arg(m_locationName);
                        else
                            message = tr("You need to water one of your (unnamed) plants!");

                        nm->setNotification(message);
                    }
                }
            }
        }
    }
}

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
            qWarning() << "> updateDeviceLastSync.exec() ERROR" << updateDeviceLastSync.lastError().type() << ":" << updateDeviceLastSync.lastError().text();
    }
}

/* ************************************************************************** */

bool DeviceSensor::getSqlDeviceInfos()
{
    //qDebug() << "DeviceSensor::getSqlDeviceInfos(" << m_deviceAddress << ")";
    bool status = Device::getSqlDeviceInfos();

    if ((m_deviceName == "Flower care" || m_deviceName == "Flower mate") && (m_deviceFirmware.size() == 5))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName.startsWith("Flower power")) && (m_deviceFirmware.size() == 5))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERPOWER))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName.startsWith("Parrot pot")) && (m_deviceFirmware.size() == 6))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_PARROTPOT))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "ropot") && (m_deviceFirmware.size() == 5))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_ROPOT))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "MJ_HT_V1") && (m_deviceFirmware.size() == 8))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_LCD))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "ClearGrass Temp & RH") && (m_deviceFirmware.size() == 10))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName.startsWith("Qingping Temp & RH")) && (m_deviceFirmware.size() == 10))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "LYWSD02") && (m_deviceFirmware.size() == 10))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "LYWSD03MMC") && (m_deviceFirmware.size() == 10))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_SQUARE))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "MHO-C401") && (m_deviceFirmware.size() == 10))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK2))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "MHO-303") && (m_deviceFirmware.size() == 10))
    {
        if (Version(m_deviceFirmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_ALARM))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }

    return status;
}

bool DeviceSensor::getSqlPlantLimits()
{
    //qDebug() << "DeviceSensor::getSqlPlantLimits(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery getLimits;
    getLimits.prepare("SELECT hygroMin, hygroMax, conduMin, conduMax, phMin, phMax, " \
                      " tempMin, tempMax, humiMin, humiMax, " \
                      " luxMin, luxMax, mmolMin, mmolMax " \
                      "FROM plantLimits WHERE deviceAddr = :deviceAddr");
    getLimits.bindValue(":deviceAddr", getAddress());
    getLimits.exec();
    while (getLimits.next())
    {
        m_limit_soilMoistureMin = getLimits.value(0).toInt();
        m_limit_soilMoistureMax = getLimits.value(1).toInt();
        m_limit_soilConduMin = getLimits.value(2).toInt();
        m_limit_soilConduMax = getLimits.value(3).toInt();
        m_limit_soilPhMin = getLimits.value(4).toInt();
        m_limit_soilPhMax = getLimits.value(5).toInt();
        m_limit_tempMin = getLimits.value(6).toInt();
        m_limit_tempMax = getLimits.value(7).toInt();
        m_limit_humiMin = getLimits.value(8).toInt();
        m_limit_humiMax = getLimits.value(9).toInt();
        m_limit_luxMin = getLimits.value(10).toInt();
        m_limit_luxMax = getLimits.value(11).toInt();
        m_limit_mmolMin = getLimits.value(12).toInt();
        m_limit_mmolMax = getLimits.value(13).toInt();

        status = true;
        Q_EMIT limitsUpdated();
    }

    return status;
}

bool DeviceSensor::getSqlPlantData(int minutes)
{
    //qDebug() << "DeviceSensor::getSqlPlantData(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedData;
    if (m_dbInternal) // sqlite
    {
        cachedData.prepare("SELECT ts_full, soilMoisture, soilConductivity, soilTemperature, soilPH, temperature, humidity, luminosity, watertank " \
                           "FROM plantData " \
                           "WHERE deviceAddr = :deviceAddr AND ts_full >= datetime('now', 'localtime', '-" + QString::number(minutes) + " minutes');");
    }
    else if (m_dbExternal) // mysql
    {
        cachedData.prepare("SELECT DATE_FORMAT(ts_full, '%Y-%m-%e %H:%i:%s')," \
                           " soilMoisture, soilConductivity, soilTemperature, soilPH, temperature, humidity, luminosity, watertank " \
                           "FROM plantData " \
                           "WHERE deviceAddr = :deviceAddr AND ts_full >= TIMESTAMPADD(MINUTE,-" + QString::number(minutes) + ",NOW());");
    }
    cachedData.bindValue(":deviceAddr", getAddress());

    if (cachedData.exec() == false)
    {
        qWarning() << "> cachedDataPlant.exec() ERROR" << cachedData.lastError().type() << ":" << cachedData.lastError().text();
    }
    else
    {
#ifndef QT_NO_DEBUG
        qDebug() << "* Device loaded:" << getAddress();
#endif
    }

    while (cachedData.next())
    {
        m_soilMoisture =  cachedData.value(1).toInt();
        m_soilConductivity = cachedData.value(2).toInt();
        m_soilTemperature = cachedData.value(3).toFloat();
        m_soilPH = cachedData.value(4).toFloat();
        m_temperature = cachedData.value(5).toFloat();
        m_humidity =  cachedData.value(6).toFloat();
        m_luminosityLux = cachedData.value(7).toInt();
        m_watertank_level = cachedData.value(8).toFloat();

        QString datetime = cachedData.value(0).toString();
        m_lastUpdateDatabase = m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");
/*
        qDebug() << ">> timestamp" << m_lastUpdate;
        qDebug() << "- m_soil_moisture:" << m_soil_moisture;
        qDebug() << "- m_soil_conductivity:" << m_soil_conductivity;
        qDebug() << "- m_soil_temperature:" << m_soil_temperature;
        qDebug() << "- m_soil_ph:" << m_soil_ph;
        qDebug() << "- m_temperature:" << m_temperature;
        qDebug() << "- m_humidity:" << m_humidity;
        qDebug() << "- m_luminosity:" << m_luminosity;
        qDebug() << "- m_watertank_level:" << m_watertank_level;
*/
        status = true;
    }

    refreshDataFinished(status, true);
    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlSensorBias()
{
    //qDebug() << "DeviceSensor::getSqlSensorBias(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery getBias;
    getBias.prepare("SELECT soilMoistureBias, soilConduBias, soilTempBias, soilPhBias," \
                    " tempBias, humiBias, pressureBias, luminosityBias " \
                    "FROM sensorBias WHERE deviceAddr = :deviceAddr");
    getBias.bindValue(":deviceAddr", getAddress());
    getBias.exec();
    while (getBias.next())
    {
        m_bias_soilMoisture = getBias.value(0).toFloat();
        m_bias_soilConductivity = getBias.value(1).toFloat();
        m_bias_soilTemperature = getBias.value(2).toFloat();
        m_bias_soilPH = getBias.value(3).toFloat();
        m_bias_temperature = getBias.value(4).toFloat();
        m_bias_humidity = getBias.value(5).toFloat();
        m_bias_pressure = getBias.value(6).toFloat();
        m_bias_luminosityLux = getBias.value(7).toFloat();

        status = true;
        Q_EMIT biasUpdated();
    }

    return status;
}

bool DeviceSensor::setDbBias()
{
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery updateBias;
        updateBias.prepare("REPLACE INTO sensorBias (deviceAddr, " \
                           " soilMoistureBias, soilConduBias, soilTempBias, soilPhBias," \
                           " tempBias, humiBias, pressureBias, luminosityBias)" \
                           " VALUES (:deviceAddr, " \
                                    ":soilMoistureBias, :soilConduBias, :soilTempBias, :soilPhBias, " \
                                    ":tempBias, :humiBias, :pressureBias, :luminosityBias)");
        updateBias.bindValue(":deviceAddr", getAddress());
        updateBias.bindValue(":soilMoistureBias", m_bias_soilMoisture);
        updateBias.bindValue(":soilConduBias", m_bias_soilConductivity);
        updateBias.bindValue(":soilTempBias", m_bias_soilTemperature);
        updateBias.bindValue(":soilPhBias", m_bias_soilPH);
        updateBias.bindValue(":tempBias", m_bias_temperature);
        updateBias.bindValue(":humiBias", m_bias_humidity);
        updateBias.bindValue(":pressureBias", m_bias_humidity);
        updateBias.bindValue(":luminosityBias", m_bias_luminosityLux);

        status = updateBias.exec();
        if (status == false)
            qWarning() << "> updateBias.exec() ERROR" << updateBias.lastError().type() << ":" << updateBias.lastError().text();
    }

    Q_EMIT biasUpdated();

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::getSqlSensorLimits()
{
    //qDebug() << "DeviceSensor::getSqlSensorLimits(" << m_deviceAddress << ")";
    bool status = false;

    // TODO

    return status;
}

bool DeviceSensor::setDbLimits()
{
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery updateLimits;
        updateLimits.prepare("REPLACE INTO plantLimits (deviceAddr, " \
                             " hygroMin, hygroMax, conduMin, conduMax, phMin, phMax, tempMin, tempMax," \
                             " humiMin, humiMax, luxMin, luxMax, mmolMin, mmolMax)" \
                             " VALUES (:deviceAddr, " \
                                      ":hygroMin, :hygroMax, :conduMin, :conduMax, :phMin, :phMax, :tempMin, :tempMax, " \
                                      ":humiMin, :humiMax, :luxMin, :luxMax, :mmolMin, :mmolMax)");
        updateLimits.bindValue(":deviceAddr", getAddress());
        updateLimits.bindValue(":hygroMin", m_limit_soilMoistureMin);
        updateLimits.bindValue(":hygroMax", m_limit_soilMoistureMax);
        updateLimits.bindValue(":conduMin", m_limit_soilConduMin);
        updateLimits.bindValue(":conduMax", m_limit_soilConduMax);
        updateLimits.bindValue(":phMin", m_limit_soilPhMin);
        updateLimits.bindValue(":phMax", m_limit_soilPhMax);
        updateLimits.bindValue(":tempMin", m_limit_tempMin);
        updateLimits.bindValue(":tempMax", m_limit_tempMax);
        updateLimits.bindValue(":humiMin", m_limit_humiMin);
        updateLimits.bindValue(":humiMax", m_limit_humiMax);
        updateLimits.bindValue(":luxMin", m_limit_luxMin);
        updateLimits.bindValue(":luxMax", m_limit_luxMax);
        updateLimits.bindValue(":mmolMin", m_limit_mmolMin);
        updateLimits.bindValue(":mmolMax", m_limit_mmolMax);

        status = updateLimits.exec();
        if (status == false)
            qWarning() << "> updateLimits.exec() ERROR" << updateLimits.lastError().type() << ":" << updateLimits.lastError().text();
    }

    Q_EMIT limitsUpdated();

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
        cachedData.prepare("SELECT timestamp, temperature, humidity, pressure, luminosity, uv, sound, water, windDirection, windSpeed, " \
                             "pm1, pm25, pm10, o2, o3, co, co2, no2, so2, voc, hcho, geiger " \
                           "FROM sensorData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= datetime('now', 'localtime', '-" + QString::number(minutes) + " minutes');");
    }
    else if (m_dbExternal) // mysql
    {
        cachedData.prepare("SELECT DATE_FORMAT(timestamp, '%Y-%m-%e %H:%i:%s'), temperature, humidity, pressure, luminosity, uv, sound, water, windDirection, windSpeed, " \
                             "pm1, pm25, pm10, o2, o3, co, co2, no2, so2, voc, hcho, geiger " \
                           "FROM sensorData " \
                           "WHERE deviceAddr = :deviceAddr AND timestamp >= TIMESTAMPADD(MINUTE,-" + QString::number(minutes) + ",NOW());");
    }
    cachedData.bindValue(":deviceAddr", getAddress());

    if (cachedData.exec() == false)
    {
        qWarning() << "> cachedDataSensor.exec() ERROR" << cachedData.lastError().type() << ":" << cachedData.lastError().text();
    }
    else
    {
#ifndef QT_NO_DEBUG
        qDebug() << "* Device loaded:" << getAddress();
#endif
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
        m_rh = m_rm = m_rs = cachedData.value(21).toFloat();

        QString datetime = cachedData.value(0).toString();
        m_lastUpdateDatabase = m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");
/*
        qDebug() << ">> timestamp" << m_lastUpdate;
        qDebug() << "- m_temperature:" << m_temperature;
        qDebug() << "- m_humidity:" << m_humidity;
        qDebug() << "- m_pressure:" << m_pressure;
        qDebug() << "- m_luminosity:" << m_luminosity;
        qDebug() << "- m_uv:" << m_uv;
        qDebug() << "- m_luminosity:" << m_luminosity;
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
        qDebug() << "- m_rm:" << m_rm;
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

        bool status =  (getLastUpdateInt() >= 0 && getLastUpdateInt() < maxMin);

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

        if (isPlantSensor() || isThermometer())
        {
            // If we have immediate data (<12h old)
            if (m_soilMoisture > 0 || m_soilConductivity > 0 || m_soilTemperature > 0 ||
                m_temperature > -20.f || m_humidity > 0 || m_luminosityLux > 0)
                status = true;

            tableName = "plantData";
        }
        else if (isEnvironmentalSensor())
        {
            // If we have immediate data (<12h old)
            if (m_temperature > -20.f || m_humidity > 0 || m_luminosityLux > 0 ||
                m_pm_10 > 0 || m_co2 > 0 || m_voc > 0 || m_rm > 0)
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

    if (isPlantSensor() || isThermometer())
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
        if (isEnvironmentalSensor()) tableName = "sensorData";

        QSqlQuery dataCount;
        if (m_dbInternal) // sqlite
        {
            dataCount.prepare("SELECT COUNT(" + dataName + ")" \
                              "FROM " + tableName + " " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND " + dataName + " > -20 AND ts >= datetime('now','-" + QString::number(days) + " day');");
        }
        else if (m_dbExternal) // mysql
        {
            dataCount.prepare("SELECT COUNT(" + dataName + ")" \
                              "FROM " + tableName + " " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND " + dataName + " > -20 AND ts >= DATE_SUB(NOW(), INTERVAL " + QString::number(days) + " DAY);");
        }
        dataCount.bindValue(":deviceAddr", getAddress());

        if (dataCount.exec() == false)
            qWarning() << "> dataCount.exec() ERROR" << dataCount.lastError().type() << ":" << dataCount.lastError().text();

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

    if (isPlantSensor() || isThermometer())
    {
        // If we have immediate data (<12h old)
        if (m_soilMoisture > 0 || m_soilConductivity > 0 || m_soilTemperature > 0 ||
            m_temperature > -20.f || m_humidity > 0 || m_luminosityLux > 0)
            return true;

        tableName = "plantData";
    }
    else if (isEnvironmentalSensor())
    {
        // If we have immediate data (<12h old)
        if (m_temperature > -20.f || m_humidity > 0 || m_luminosityLux > 0 ||
            m_pm_10 > 0 || m_co2 > 0 || m_voc > 0 || m_rm > 0)
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

bool DeviceSensor::isDataFresh() const
{
    SettingsManager *sm = SettingsManager::getInstance();
    int maxMin = hasSoilMoistureSensor() ? sm->getUpdateIntervalPlant() : sm->getUpdateIntervalThermo();
    return (getLastUpdateInt() >= 0 && getLastUpdateInt() < maxMin);
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
    return !isDataFresh();
}

bool DeviceSensor::needsUpdateDb() const
{
    return (getLastUpdateDbInt() < 0 || getLastUpdateDbInt() > 60);
}

/* ************************************************************************** */
/* ************************************************************************** */

float DeviceSensor::getTemp() const
{
    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        return getTempF();

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

void DeviceSensor::addJournalEntry(const int type, const QDateTime &date, const QString &comment)
{
    JournalEntry *j = new JournalEntry(type, date, comment, this);
    if (j)
    {
        m_journal_entries.push_back(j);
        Q_EMIT journalUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::updateChartData_history_day()
{
    int maxHours = 24;

    qDeleteAll(m_chartData_history_day);
    m_chartData_history_day.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d %H:%m:%s', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day') " \
                              "GROUP BY strftime('%d-%H', ts) " \
                              "ORDER BY ts DESC "
                              "LIMIT 24;");
        }
        else if (m_dbExternal) // mysql
        {
            graphData.prepare("SELECT DATE_FORMAT(ts, '%Y-%m-%d %H:%m:%s'), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= DATE_SUB(NOW(), INTERVAL -1 DAY) " \
                              "GROUP BY DATE_FORMAT(ts, '%d-%H') " \
                              "ORDER BY ts DESC "
                              "LIMIT 24;");
        }
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            if (m_chartData_history_day.size() < maxHours)
            {
                // missing hours(s)?
                if (previousdata)
                {
                    QDateTime timefromsql = graphData.value(0).toDateTime();
                    int diff = timefromsql.secsTo(previousdata->getDateTime()) / 3600;
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_history_day.size() < (maxHours-1))
                        {
                            QDateTime fakedate(timefromsql.addSecs((i-1) * 3600));
                            m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // data
                ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                           graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                           graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                           this);
                m_chartData_history_day.push_front(d);
                previousdata = d;
            }
        }

        // missing hour(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxHours;
            if (previousdata) missing = (static_cast<ChartDataHistory *>(m_chartData_history_day.last())->getDateTime().secsTo(today)) / 3600;
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addSecs((-i)*3600));
                m_chartData_history_day.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_history_day.size(); i < maxHours; i++)
            {
                QDateTime fakedate(today.addSecs((-i)*3600));
                m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        // first vs last
        if (m_chartData_history_day.size() > 1)
        {
            while (!m_chartData_history_day.isEmpty() &&
                   static_cast<ChartDataHistory *>(m_chartData_history_day.first())->getHour() ==
                   static_cast<ChartDataHistory *>(m_chartData_history_day.last())->getHour())
            {
                m_chartData_history_day.pop_front();
            }
        }

        Q_EMIT chartDataHistoryDaysUpdated();
    }
}

void DeviceSensor::updateChartData_history_day(const QDateTime &d)
{
    qDeleteAll(m_chartData_history_day);
    m_chartData_history_day.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d %H:%m:%s', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND ts BETWEEN '" + d.toString("yyyy-MM-dd 00:00:00") + "' AND '" + d.toString("yyyy-MM-dd 23:59:59") + "' " \
                              "GROUP BY strftime('%d-%H', ts) " \
                              "ORDER BY ts DESC;");
        }
        else if (m_dbExternal) // mysql
        {
            // TODO
        }
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            if (m_chartData_history_day.size() < 24)
            {
                // missing hours(s)?
                if (previousdata)
                {
                    QDateTime timefromsql = graphData.value(0).toDateTime();
                    int diff = timefromsql.secsTo(previousdata->getDateTime()) / 3600;
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_history_day.size() < 23)
                        {
                            QDateTime fakedate(timefromsql.addSecs((i-1) * 3600));
                            m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // data
                ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                           graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                           graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                           this);
                m_chartData_history_day.push_front(d);
                previousdata = d;
            }
        }

        // missing hour(s)?
        if (previousdata)
        {
            QDateTime first = static_cast<ChartDataHistory *>(m_chartData_history_day.first())->getDateTime();
            QDateTime last = static_cast<ChartDataHistory *>(m_chartData_history_day.last())->getDateTime();

            for (int i = first.time().hour(), h = 1; i > 0; i--, h++)
            {
                QDateTime fakedate(first.addSecs((-h)*3600));
                m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
            for (int i = last.time().hour(), h = 1; i < 23; i++, h++)
            {
                QDateTime fakedate(last.addSecs((h)*3600));
                m_chartData_history_day.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }
        else
        {
            for (int i = 0; i < 24; i++)
            {
                QDateTime fakedate(d.date(), QTime(i, 0, 0));
                m_chartData_history_day.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        Q_EMIT chartDataHistoryDaysUpdated();
    }
}

/* ************************************************************************** */

void DeviceSensor::updateChartData_history_month(int maxDays)
{
    if (maxDays <= 0) return;
    int maxMonths = 1;

    qDeleteAll(m_chartData_history_month);
    m_chartData_history_month.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity), " \
                              " max(temperature), max(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-" + QString::number(maxMonths) + " month') " \
                              "GROUP BY strftime('%Y-%m-%d', ts) " \
                              "ORDER BY ts DESC "
                              "LIMIT :maxDays;");
        }
        else if (m_dbExternal) // mysql
        {
            graphData.prepare("SELECT DATE_FORMAT(ts, '%Y-%m-%d'), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity), " \
                              " max(temperature), max(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= DATE_SUB(NOW(), INTERVAL -" + QString::number(maxMonths) + " MONTH) " \
                              "GROUP BY DATE_FORMAT(ts, '%Y-%m-%d') " \
                              "ORDER BY ts DESC "
                              "LIMIT :maxDays;");
        }
        graphData.bindValue(":deviceAddr", getAddress());
        graphData.bindValue(":maxDays", maxDays);

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        bool minmaxChanged = false;

        while (graphData.next())
        {
            if (m_chartData_history_month.size() < maxDays)
            {
                // missing day(s)?
                if (previousdata)
                {
                    QDateTime datefromsql = graphData.value(0).toDateTime();
                    int diff = datefromsql.daysTo(previousdata->getDateTime());
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_history_month.size() < (maxDays-1))
                        {
                            QDateTime fakedate(datefromsql.addDays(i-1));
                            m_chartData_history_month.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // min/max
                if (graphData.value(1).toInt() < m_soilMoistureMin) { m_soilMoistureMin = graphData.value(1).toInt(); minmaxChanged = true; }
                if (graphData.value(2).toInt() < m_soilConduMin) { m_soilConduMin = graphData.value(2).toInt(); minmaxChanged = true; }
                if (graphData.value(3).toFloat() < m_soilTempMin) { m_soilTempMin = graphData.value(3).toFloat(); minmaxChanged = true; }
                if (graphData.value(4).toFloat() < m_tempMin) { m_tempMin = graphData.value(4).toFloat(); minmaxChanged = true; }
                if (graphData.value(5).toInt() < m_humiMin) { m_humiMin = graphData.value(5).toInt(); minmaxChanged = true; }
                if (graphData.value(6).toInt() < m_luxMin) { m_luxMin = graphData.value(6).toInt(); minmaxChanged = true; }

                if (graphData.value(1).toInt() > m_soilMoistureMax) { m_soilMoistureMax = graphData.value(1).toInt(); minmaxChanged = true; }
                if (graphData.value(2).toInt() > m_soilConduMax) { m_soilConduMax = graphData.value(2).toInt(); minmaxChanged = true; }
                if (graphData.value(3).toFloat() > m_soilTempMax) { m_soilTempMax = graphData.value(3).toFloat(); minmaxChanged = true; }
                if (graphData.value(4).toFloat() > m_tempMax) { m_tempMax = graphData.value(4).toFloat(); minmaxChanged = true; }
                if (graphData.value(5).toInt() > m_humiMax) { m_humiMax = graphData.value(5).toInt(); minmaxChanged = true; }
                if (graphData.value(6).toInt() > m_luxMax) { m_luxMax = graphData.value(6).toInt(); minmaxChanged = true; }

                // data
                ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                           graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                           graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                           graphData.value(7).toFloat(), graphData.value(8).toFloat(),
                                                           this);
                m_chartData_history_month.push_front(d);
                previousdata = d;
            }
        }

        if (minmaxChanged) { Q_EMIT minmaxUpdated(); }

        // missing day(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxDays;
            if (previousdata) missing = static_cast<ChartDataHistory *>(m_chartData_history_month.last())->getDateTime().daysTo(today);
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_history_month.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_history_month.size(); i < maxDays; i++)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_history_month.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        // first vs last (for months less than 31 days long)
        if (m_chartData_history_month.size() > 1)
        {
            while (!m_chartData_history_month.isEmpty() &&
                   static_cast<ChartDataHistory *>(m_chartData_history_month.first())->getDay() ==
                   static_cast<ChartDataHistory *>(m_chartData_history_month.last())->getDay())
            {
                m_chartData_history_month.pop_front();
            }
        }

        // weekly graph
        {
            //qDeleteAll(m_chartData_history_week); // we only stores refs
            m_chartData_history_week.clear();

            int sz = m_chartData_history_month.size() - 1;
            for (int j = sz; j > 0; j--)
            {
                m_chartData_history_week.push_front(m_chartData_history_month.at(j));
                if (m_chartData_history_week.size() >= 7) break;
            }

            Q_EMIT chartDataHistoryWeeksUpdated();
        }

        Q_EMIT chartDataHistoryMonthsUpdated();
    }
}

void DeviceSensor::updateChartData_history_month(const QDateTime &f, const QDateTime &l)
{
    if (!f.isValid() || !l.isValid()) return;
    int maxDays = 7;

    //qDebug() << "updateChartData_history_month > " << f << " - " << l;

    //qDeleteAll(m_chartData_history_week);
    m_chartData_history_week.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND ts BETWEEN '" + f.toString("yyyy-MM-dd 00:00:00") + "' AND '" + l.toString("yyyy-MM-dd 23:59:59") + "' " \
                              "GROUP BY strftime('%Y-%m-%d', ts) " \
                              "ORDER BY ts DESC;");
        }
        else if (m_dbExternal) // mysql
        {
            // TODO
        }
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            // missing day(s)?
            if (previousdata)
            {
                QDateTime datefromsql = graphData.value(0).toDateTime();
                int diff = datefromsql.daysTo(previousdata->getDateTime());
                for (int i = diff; i > 1; i--)
                {
                    if (m_chartData_history_week.size() < (maxDays-1))
                    {
                        QDateTime fakedate(datefromsql.addDays(i-1));
                        m_chartData_history_week.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                    }
                }
            }

            // data
            ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                       graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                       graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                       this);
            m_chartData_history_week.push_front(d);
            previousdata = d;
        }

        // missing day(s)?
        if (previousdata)
        {
            QDateTime first = static_cast<ChartDataHistory *>(m_chartData_history_week.first())->getDateTime();
            QDateTime last = static_cast<ChartDataHistory *>(m_chartData_history_week.last())->getDateTime();

            for (int i = first.daysTo(f), d = -1; i < 0; i++, d--)
            {
                QDateTime fakedate(first.addDays(d));
                m_chartData_history_week.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
            for (int i = 0; i < last.daysTo(l); i++)
            {
                QDateTime fakedate(last.addDays(i+1));
                m_chartData_history_week.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }
        else
        {
            for (int i = 0; i < maxDays; i++)
            {
                QDateTime fakedate(f.addDays(i));
                m_chartData_history_week.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        Q_EMIT chartDataHistoryWeeksUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::updateChartData_environmentalVoc(int maxDays)
{
    if (maxDays <= 0) return;
    int maxMonths = 2;

    qDeleteAll(m_chartData_env);
    m_chartData_env.clear();
    ChartDataVoc *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d', timestamp), " \
                              " min(voc), avg(voc), max(voc), " \
                              " min(hcho), avg(hcho), max(hcho), " \
                              " min(co2), avg(co2), max(co2) " \
                              "FROM sensorData " \
                              "WHERE deviceAddr = :deviceAddr AND timestamp >= datetime('now','-" + QString::number(maxMonths) + " month') " \
                              "GROUP BY strftime('%Y-%m-%d', timestamp) " \
                              "ORDER BY timestamp DESC "
                              "LIMIT :maxDays;");
        }
        else if (m_dbExternal) // mysql
        {
            graphData.prepare("SELECT DATE_FORMAT(timestamp, '%Y-%m-%d'), " \
                              " min(voc), avg(voc), max(voc), " \
                              " min(hcho), avg(hcho), max(hcho), " \
                              " min(co2), avg(co2), max(co2) " \
                              "FROM sensorData " \
                              "WHERE deviceAddr = :deviceAddr AND timestamp >= DATE_SUB(NOW(), INTERVAL -" + QString::number(maxMonths) + " MONTH) " \
                              "GROUP BY DATE_FORMAT(timestamp, '%Y-%m-%d') " \
                              "ORDER BY timestamp DESC "
                              "LIMIT :maxDays;");
        }
        graphData.bindValue(":deviceAddr", getAddress());
        graphData.bindValue(":maxDays", maxDays);

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            if (m_chartData_env.size() < maxDays)
            {
                // missing day(s)?
                if (previousdata)
                {
                    QDateTime datefromsql = graphData.value(0).toDateTime();
                    int diff = datefromsql.daysTo(previousdata->getDateTime());
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_env.size() < (maxDays-1))
                        {
                            QDateTime fakedate(datefromsql.addDays(i-1));
                            m_chartData_env.push_front(new ChartDataVoc(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // data
                ChartDataVoc *d = new ChartDataVoc(graphData.value(0).toDateTime(),
                                                   graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                   graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                   graphData.value(7).toFloat(), graphData.value(8).toFloat(), graphData.value(9).toFloat(),
                                                   this);
                m_chartData_env.push_front(d);
                previousdata = d;
            }
        }

        // missing day(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxDays;
            if (previousdata) missing = static_cast<ChartDataVoc *>(m_chartData_env.last())->getDateTime().daysTo(today);
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_env.push_back(new ChartDataVoc(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_env.size(); i < maxDays; i++)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_env.push_front(new ChartDataVoc(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99, this));
            }
        }
/*
        // first vs last (for months less than 31 days long)
        if (m_chartData_env.size() > 1)
        {
            while (!m_chartData_env.isEmpty() &&
                   static_cast<ChartDataVoc *>(m_chartData_env.first())->getDay() ==
                   static_cast<ChartDataVoc *>(m_chartData_env.last())->getDay())
            {
                m_chartData_env.pop_front();
            }
        }
*/
        Q_EMIT chartDataEnvUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::updateChartData_thermometerMinMax(int maxDays)
{
    if (maxDays <= 0) return;
    int maxMonths = 2;

    qDeleteAll(m_chartData_minmax);
    m_chartData_minmax.clear();
    m_tempMin = 999.f;
    m_tempMax = -99.f;
    ChartDataMinMax *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d', ts), " \
                              " min(temperature), avg(temperature), max(temperature), " \
                              " min(humidity), max(humidity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-" + QString::number(maxMonths) + " month') " \
                              "GROUP BY strftime('%Y-%m-%d', ts) " \
                              "ORDER BY ts DESC "
                              "LIMIT :maxDays;");
        }
        else if (m_dbExternal) // mysql
        {
            graphData.prepare("SELECT DATE_FORMAT(ts, '%Y-%m-%d'), " \
                              " min(temperature), avg(temperature), max(temperature), " \
                              " min(humidity), max(humidity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= DATE_SUB(NOW(), INTERVAL -" + QString::number(maxMonths) + " MONTH) " \
                              "GROUP BY DATE_FORMAT(ts, '%Y-%m-%d') " \
                              "ORDER BY ts DESC "
                              "LIMIT :maxDays;");
        }
        graphData.bindValue(":deviceAddr", getAddress());
        graphData.bindValue(":maxDays", maxDays);

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        bool minmaxChanged = false;

        while (graphData.next())
        {
            if (m_chartData_minmax.size() < maxDays)
            {
                // missing day(s)?
                if (previousdata)
                {
                    QDateTime datefromsql = graphData.value(0).toDateTime();
                    int diff = datefromsql.daysTo(previousdata->getDateTime());
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_minmax.size() < (maxDays-1))
                        {
                            QDateTime fakedate(datefromsql.addDays(i-1));
                            m_chartData_minmax.push_front(new ChartDataMinMax(fakedate, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // min/max
                if (graphData.value(1).toFloat() < m_tempMin) { m_tempMin = graphData.value(1).toFloat(); minmaxChanged = true; }
                if (graphData.value(3).toFloat() > m_tempMax) { m_tempMax = graphData.value(3).toFloat(); minmaxChanged = true; }
                if (graphData.value(4).toInt() < m_soilMoistureMin) { m_soilMoistureMin = graphData.value(4).toInt(); minmaxChanged = true; }
                if (graphData.value(5).toInt() > m_soilMoistureMax) { m_soilMoistureMax = graphData.value(5).toInt(); minmaxChanged = true; }

                // data
                ChartDataMinMax *d = new ChartDataMinMax(graphData.value(0).toDateTime(),
                                                         graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                         graphData.value(4).toInt(), graphData.value(5).toInt(), this);
                m_chartData_minmax.push_front(d);
                previousdata = d;
            }
        }

        if (minmaxChanged) { Q_EMIT minmaxUpdated(); }

        // missing day(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxDays;
            if (previousdata) missing = static_cast<ChartDataMinMax *>(m_chartData_minmax.last())->getDateTime().daysTo(today);
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_minmax.push_back(new ChartDataMinMax(fakedate, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_minmax.size(); i < maxDays; i++)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_minmax.push_front(new ChartDataMinMax(fakedate, -99, -99, -99, -99, -99, this));
            }
        }
/*
        // first vs last (for months less than 31 days long)
        if (m_chartData_minmax.size() > 1)
        {
            while (!m_chartData_minmax.isEmpty() &&
                   static_cast<ChartDataMinMax *>(m_chartData_minmax.first())->getDay() ==
                   static_cast<ChartDataMinMax *>(m_chartData_minmax.last())->getDay())
            {
                m_chartData_minmax.pop_front();
            }
        }
*/
        Q_EMIT chartDataMinMaxUpdated();
    }
    else
    {
        // No database, use fake values
        m_soilMoistureMin = 0;
        m_soilMoistureMax = 50;
        m_soilConduMin = 0;
        m_soilConduMax = 2000;
        m_soilTempMin = 0.f;
        m_soilTempMax = 36.f;
        m_soilPhMin = 0.f;
        m_soilPhMax = 15.f;
        m_tempMin = 0.f;
        m_tempMax = 36.f;
        m_humiMin = 0;
        m_humiMax = 100;
        m_luxMin = 0;
        m_luxMax = 10000;
        m_mmolMin = 0;
        m_mmolMax = 10000;

        Q_EMIT minmaxUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::getChartData_plantAIO(int maxDays, QDateTimeAxis *axis,
                                         QLineSeries *hygro, QLineSeries *condu,
                                         QLineSeries *temp, QLineSeries *lumi)
{
    if (!axis || !hygro || !condu || !temp || !lumi) return;

    if (m_dbInternal || m_dbExternal)
    {
        QString data = "soilMoisture";
        if (!hasSoilMoistureSensor()) data = "humidity";

        QString time = "datetime('now', 'localtime', '-" + QString::number(maxDays) + " days')";
        if (m_dbExternal) time = "DATE_SUB(NOW(), INTERVAL " + QString::number(maxDays) + " DAY)";

        QSqlQuery graphData;
        graphData.prepare("SELECT ts_full, " + data + ", soilConductivity, temperature, luminosity " \
                          "FROM plantData " \
                          "WHERE deviceAddr = :deviceAddr AND ts_full >= " + time + ";");
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        axis->setFormat("dd MMM");
        axis->setMax(QDateTime::currentDateTime());
        bool minSet = false;
        bool minmaxChanged = false;

        while (graphData.next())
        {
            QDateTime date = QDateTime::fromString(graphData.value(0).toString(), "yyyy-MM-dd hh:mm:ss");
            if (!minSet)
            {
                axis->setMin(date);
                minSet = true;
            }
            qint64 timecode = date.toMSecsSinceEpoch();

            hygro->append(timecode, graphData.value(1).toReal());
            condu->append(timecode, graphData.value(2).toReal());
            temp->append(timecode, graphData.value(3).toReal());
            lumi->append(timecode, graphData.value(4).toReal());

            if (graphData.value(1).toInt() < m_soilMoistureMin) { m_soilMoistureMin = graphData.value(1).toInt(); minmaxChanged = true; }
            if (graphData.value(2).toInt() < m_soilConduMin) { m_soilConduMin = graphData.value(2).toInt(); minmaxChanged = true; }
            if (graphData.value(3).toFloat() < m_tempMin) { m_tempMin = graphData.value(3).toFloat(); minmaxChanged = true; }
            if (graphData.value(4).toInt() < m_luxMin) { m_luxMin = graphData.value(4).toInt(); minmaxChanged = true; }

            if (graphData.value(1).toInt() > m_soilMoistureMax) { m_soilMoistureMax = graphData.value(1).toInt(); minmaxChanged = true; }
            if (graphData.value(2).toInt() > m_soilConduMax) { m_soilConduMax = graphData.value(2).toInt(); minmaxChanged = true; }
            if (graphData.value(3).toFloat() > m_tempMax) { m_tempMax = graphData.value(3).toFloat(); minmaxChanged = true; }
            if (graphData.value(4).toInt() > m_luxMax) { m_luxMax = graphData.value(4).toInt(); minmaxChanged = true; }
        }

        if (minmaxChanged) { Q_EMIT minmaxUpdated(); }
    }
    else
    {
        // No database, use fake values
        m_soilMoistureMin = 0;
        m_soilMoistureMax = 50;
        m_soilConduMin = 0;
        m_soilConduMax = 2000;
        m_soilTempMin = 0.f;
        m_soilTempMax = 36.f;
        m_soilPhMin = 0.f;
        m_soilPhMax = 15.f;
        m_tempMin = 0.f;
        m_tempMax = 36.f;
        m_humiMin = 0;
        m_humiMax = 100;
        m_luxMin = 0;
        m_luxMax = 10000;
        m_mmolMin = 0;
        m_mmolMax = 10000;

        Q_EMIT minmaxUpdated();
    }
}

/* ************************************************************************** */
