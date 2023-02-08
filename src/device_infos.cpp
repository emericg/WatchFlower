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

/* ************************************************************************** */

#include "device_infos.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

/* ************************************************************************** */

DeviceInfosSensor::DeviceInfosSensor(const QString &sensor, const QString &string,
                                     QObject *parent) : QObject(parent)
{
    if (sensor == "Soil moisture") m_sensor = DeviceUtils::SENSOR_SOIL_MOISTURE;
    else if (sensor == "Soil conductivity") m_sensor = DeviceUtils::SENSOR_SOIL_CONDUCTIVITY;
    else if (sensor == "Soil temperature") m_sensor = DeviceUtils::SENSOR_SOIL_TEMPERATURE;
    else if (sensor == "Soil PH") m_sensor = DeviceUtils::SENSOR_SOIL_PH;

    else if (sensor == "Temperature") m_sensor = DeviceUtils::SENSOR_TEMPERATURE;
    else if (sensor == "Humidity") m_sensor = DeviceUtils::SENSOR_HUMIDITY;

    else if (sensor == "Pressure") m_sensor = DeviceUtils::SENSOR_PRESSURE;
    else if (sensor == "Luminosity") m_sensor = DeviceUtils::SENSOR_LUMINOSITY;
    else if (sensor == "UV") m_sensor = DeviceUtils::SENSOR_UV;
    else if (sensor == "Sound") m_sensor = DeviceUtils::SENSOR_SOUND;
    else if (sensor == "Water level") m_sensor = DeviceUtils::SENSOR_WATER_LEVEL;
    else if (sensor == "Water tank") m_sensor = DeviceUtils::SENSOR_WATER_LEVEL;
    else if (sensor == "Wind speed") m_sensor = DeviceUtils::SENSOR_WIND_SPEED;
    else if (sensor == "Wind direction") m_sensor = DeviceUtils::SENSOR_WIND_DIRECTION;

    else if (sensor == "PM1") m_sensor = DeviceUtils::SENSOR_PM1;
    else if (sensor == "PM2.5") m_sensor = DeviceUtils::SENSOR_PM25;
    else if (sensor == "PM10") m_sensor = DeviceUtils::SENSOR_PM10;
    else if (sensor == "O2") m_sensor = DeviceUtils::SENSOR_O2;
    else if (sensor == "O3") m_sensor = DeviceUtils::SENSOR_O3;
    else if (sensor == "CO") m_sensor = DeviceUtils::SENSOR_CO;
    else if (sensor == "CO2") m_sensor = DeviceUtils::SENSOR_CO2;
    else if (sensor == "CO2 (estimated)") m_sensor = DeviceUtils::SENSOR_eCO2;
    else if (sensor == "NO2") m_sensor = DeviceUtils::SENSOR_NO2;
    else if (sensor == "SO2") m_sensor = DeviceUtils::SENSOR_SO2;
    else if (sensor == "VOC") m_sensor = DeviceUtils::SENSOR_VOC;
    else if (sensor == "TVOC") m_sensor = DeviceUtils::SENSOR_VOC;
    else if (sensor == "HCHO") m_sensor = DeviceUtils::SENSOR_HCHO;

    else if (sensor == "Radiation") m_sensor = DeviceUtils::SENSOR_GEIGER;
    else if (sensor == "Geiger counter") m_sensor = DeviceUtils::SENSOR_GEIGER;

    m_string = string;
}

DeviceInfosSensor::~DeviceInfosSensor()
{
    //
}

/* ************************************************************************** */

DeviceInfosCapability::DeviceInfosCapability(const QString &capability, const QString &string,
                                             QObject *parent) : QObject(parent)
{
    if (capability == "realtime") m_capability = DeviceUtils::DEVICE_REALTIME;
    else if (capability == "history") m_capability = DeviceUtils::DEVICE_HISTORY;
    else if (capability == "battery") m_capability = DeviceUtils::DEVICE_BATTERY;
    else if (capability == "clock") m_capability = DeviceUtils::DEVICE_CLOCK;
    else if (capability == "led_status") m_capability = DeviceUtils::DEVICE_LED_STATUS;
    else if (capability == "led_rgb") m_capability = DeviceUtils::DEVICE_LED_RGB;
    else if (capability == "buttons") m_capability = DeviceUtils::DEVICE_BUTTONS;
    else if (capability == "last_move") m_capability = DeviceUtils::DEVICE_LAST_MOVE;
    else if (capability == "water_tank") m_capability = DeviceUtils::DEVICE_WATER_TANK;
    else if (capability == "calibration") m_capability = DeviceUtils::DEVICE_CALIBRATION;
    else if (capability == "reboot") m_capability = DeviceUtils::DEVICE_REBOOT;

    m_string = string;
}

DeviceInfosCapability::~DeviceInfosCapability()
{
    //
}

/* ************************************************************************** */

DeviceInfos::DeviceInfos(QObject *parent) : QObject(parent)
{
    //
}

DeviceInfos::~DeviceInfos()
{
    qDeleteAll(m_sensors);
    m_sensors.clear();

    qDeleteAll(m_capabilities);
    m_capabilities.clear();
}

void DeviceInfos::load(const QJsonObject &obj)
{
    //qDebug() << "DeviceInfos::load(" << obj << ")";

    m_model = obj["model"].toString();
    m_manufacturer = obj["manufacturer"].toString();
    for (const auto &vv: obj["ID"].toArray())
    {
        if (!m_id.isEmpty()) m_id += ", ";
        m_id += vv.toString();
    }

    m_year = obj["year"].toInt();
    m_battery = obj["battery"].toString();
    m_screen = obj["screen"].toString();
    m_ipx = obj["ipx"].toString();
    m_needsOfficialApp = obj["onboarding"].toBool();

    for (const auto &vv: obj["sensors"].toArray())
    {
        QJsonArray vvv = vv.toArray();
        if (vvv.size() == 2)
        {
            DeviceInfosSensor *dis = new DeviceInfosSensor(vvv.at(0).toString(),
                                                           vvv.at(1).toString(),
                                                           this);
            m_sensors.push_back(dis);
        }
    }

    for (const auto &vv: obj["capabilities"].toArray())
    {
        QJsonArray vvv = vv.toArray();
        if (vvv.size() == 2)
        {
            DeviceInfosCapability *dic = new DeviceInfosCapability(vvv.at(0).toString(),
                                                                   vvv.at(1).toString(),
                                                                   this);
            m_capabilities.push_back(dic);
        }
    }
}

bool DeviceInfos::loadSlow(const QString &name, const QString &model, const QString &modelId)
{
    //qDebug() << "DeviceInfos::loadSlow(" << name << model << modelId << ")";

    QFile file(":/devices/devices_sensors.json");

    if (file.open(QIODevice::ReadOnly))
    {
        QJsonDocument capsDoc = QJsonDocument().fromJson(file.readAll());
        QJsonObject capsObj = capsDoc.object();
        file.close();

        QJsonArray deviceArray = capsObj["devices"].toArray();
        for (const auto &value: deviceArray)
        {
            QJsonObject obj = value.toObject();
            if (name == obj["name_ble"].toString() ||
                name.toLower() == obj["model"].toString().toLower() ||
                model.toLower() == obj["model"].toString().toLower() ||
                obj["ID"].toArray().contains(name))
            {
                //qDebug() << "DeviceInfos::load(" << model << ") FOUND";

                m_model = obj["model"].toString();
                m_manufacturer = obj["manufacturer"].toString();
                for (const auto &vv: obj["ID"].toArray())
                {
                    if (!m_id.isEmpty()) m_id += ", ";
                    m_id += vv.toString();
                }

                m_year = obj["year"].toInt();
                m_battery = obj["battery"].toString();
                m_screen = obj["screen"].toString();
                m_ipx = obj["ipx"].toString();
                m_needsOfficialApp = obj["onboarding"].toBool();

                for (const auto &vv: obj["sensors"].toArray())
                {
                    QJsonArray vvv = vv.toArray();
                    if (vvv.size() == 2)
                    {
                        DeviceInfosSensor *dis = new DeviceInfosSensor(vvv.at(0).toString(),
                                                                       vvv.at(1).toString(),
                                                                       this);
                        m_sensors.push_back(dis);
                    }
                }

                for (const auto &vv: obj["capabilities"].toArray())
                {
                    QJsonArray vvv = vv.toArray();
                    if (vvv.size() == 2)
                    {
                        DeviceInfosCapability *dic = new DeviceInfosCapability(vvv.at(0).toString(),
                                                                               vvv.at(1).toString(),
                                                                               this);
                        m_capabilities.push_back(dic);
                    }
                }

                return true;
            }
        }
    }

    return false;
}

/* ************************************************************************** */

DeviceInfosLoader *DeviceInfosLoader::instance = nullptr;

DeviceInfosLoader *DeviceInfosLoader::getInstance()
{
    if (instance == nullptr)
    {
        instance = new DeviceInfosLoader();
    }

    return instance;
}

DeviceInfosLoader::DeviceInfosLoader()
{
    //
}

DeviceInfosLoader::~DeviceInfosLoader()
{
    //
}

DeviceInfos *DeviceInfosLoader::getDeviceInfos(const QString &name, const QString &model, const QString &modelId)
{
    //qDebug() << "DeviceInfosLoader::getDeviceInfos(" << name << model << modelId << ")";

    DeviceInfos *dev = nullptr;

    if (deviceJsonArray.isEmpty())
    {
        QFile jsonFile(":/devices/devices_sensors.json");
        if (jsonFile.open(QIODevice::ReadOnly))
        {
            QJsonDocument jsonDoc = QJsonDocument().fromJson(jsonFile.readAll());
            QJsonObject jsonObj = jsonDoc.object();

            deviceJsonArray = jsonObj["devices"].toArray();

            jsonFile.close();
        }
    }

    for (const auto &value: qAsConst(deviceJsonArray))
    {
        QJsonObject obj = value.toObject();
        if (name == obj["name_ble"].toString() ||
            name.toLower() == obj["model"].toString().toLower() ||
            model.toLower() == obj["model"].toString().toLower() ||
            obj["ID"].toArray().contains(name))
        {
            dev = new DeviceInfos(this);
            dev->load(obj);
        }
    }

    return dev;
}

/* ************************************************************************** */
