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

#ifndef DEVICE_UTILS_H
#define DEVICE_UTILS_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QDate>
#include <QQmlApplicationEngine>
#include <QQmlContext>

/* ************************************************************************** */

#define LATEST_KNOWN_FIRMWARE_FLOWERCARE        "3.2.2"
#define LATEST_KNOWN_FIRMWARE_FLOWERPOWER       "2.0.3"
#define LATEST_KNOWN_FIRMWARE_ROPOT             "1.1.5"
#define LATEST_KNOWN_FIRMWARE_PARROTPOT         "0.29.1"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_LCD     "00.00.66"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK    "1.1.2_0007"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK2   "1.0.0_0010"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK   "1.1.2_0019"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_ALARM   "?"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_SQUARE  "1.0.0_0106"
#define LATEST_KNOWN_FIRMWARE_ESP32_GEIGER      "0.3"
#define LATEST_KNOWN_FIRMWARE_ESP32_HIGROW      "0.3"

/* ************************************************************************** */

class DeviceUtils: public QObject
{
    Q_OBJECT

public:
    static void registerQML()
    {
        qRegisterMetaType<DeviceUtils::DeviceType>("DeviceUtils::DeviceType");
        qRegisterMetaType<DeviceUtils::DeviceCapabilities>("DeviceUtils::DeviceCapabilities");
        qRegisterMetaType<DeviceUtils::DeviceSensors>("DeviceUtils::DeviceSensors");
        qRegisterMetaType<DeviceUtils::DeviceStatus>("DeviceUtils::DeviceStatus");
        qRegisterMetaType<DeviceUtils::DeviceActions>("DeviceUtils::DeviceActions");

        qmlRegisterType<DeviceUtils>("DeviceUtils", 1, 0, "DeviceUtils");
    }

    enum DeviceType {
        DEVICE_PLANTSENSOR          = 0,
        DEVICE_THERMOMETER,
        DEVICE_ENVIRONMENTAL,

        DEVICE_LAMP                 = 8,
        DEVICE_BEACON,
        DEVICE_PGP,
    };
    Q_ENUMS(DeviceType)

    enum DeviceCapabilities {
        DEVICE_BATTERY              = (1 <<  0), //!< Can report its battery level
        DEVICE_CLOCK                = (1 <<  1), //!< Has an onboard clock
        DEVICE_LED_STATUS           = (1 <<  2), //!< Has a status LED
        DEVICE_HISTORY              = (1 <<  3), //!< Record sensor history
        DEVICE_LAST_MOVE            = (1 <<  4), //!< Can report the last time it has been physically moved
        DEVICE_WATER_TANK           = (1 <<  5), //!< Has a water tank / automatic watering capability
        DEVICE_BUTTONS              = (1 <<  6), //!< Has button(s)
        DEVICE_LED_RGB              = (1 <<  8), //!< Has an addressable LED
    };
    Q_ENUMS(DeviceCapabilities)

    enum DeviceSensors {
        // plant data
        SENSOR_SOIL_MOISTURE        = (1 <<  0), //!< Has a soil moisture sensor
        SENSOR_SOIL_CONDUCTIVITY    = (1 <<  1), //!< Has a soil conductivity/fertility sensor
        SENSOR_SOIL_TEMPERATURE     = (1 <<  2), //!< Has a soil temperature sensor
        SENSOR_SOIL_PH              = (1 <<  3), //!< Has a soil PH sensor
        // hygrometer data
        SENSOR_TEMPERATURE          = (1 <<  6), //!< Has a temperature sensor
        SENSOR_HUMIDITY             = (1 <<  7), //!< Has an humidity sensor
        // environmental data (weather station)
        SENSOR_PRESSURE             = (1 <<  8), //!< Has a barometer (pressure sensor)
        SENSOR_LUMINOSITY           = (1 <<  9), //!< Has a light sensor
        SENSOR_UV                   = (1 << 10), //!< Has an UV light sensor
        SENSOR_SOUND                = (1 << 11), //!< Has a sound level sensor
        SENSOR_WATER_LEVEL          = (1 << 12), //!< Has a rain gauge (or water tank level)
        SENSOR_WIND_DIRECTION       = (1 << 13), //!< Has a weather vane
        SENSOR_WIND_SPEED           = (1 << 14), //!< Has an anemometer
        // environmental data (air monitoring)
        SENSOR_PM1                  = (1 << 16),
        SENSOR_PM25                 = (1 << 17),
        SENSOR_PM10                 = (1 << 18),
        SENSOR_O2                   = (1 << 19),
        SENSOR_O3                   = (1 << 20),
        SENSOR_CO                   = (1 << 21),
        SENSOR_CO2                  = (1 << 22),
        SENSOR_eCO2                 = (1 << 23),
        SENSOR_NO2                  = (1 << 24),
        SENSOR_SO2                  = (1 << 25),
        SENSOR_VOC                  = (1 << 26),
        SENSOR_HCHO                 = (1 << 27),
        // environmental data (geiger counter)
        SENSOR_GEIGER               = (1 << 31),
    };
    Q_ENUMS(DeviceSensors)

    enum DeviceStatus {
        DEVICE_OFFLINE              =  0, //!< Not connected
        DEVICE_QUEUED               =  1, //!< In the update queue, not started
        DEVICE_CONNECTING           =  2, //!< Trying to connect to the device
        DEVICE_CONNECTED            =  3, //!< Connected

        DEVICE_WORKING              =  8, //!< Connected, doing something
        DEVICE_UPDATING             =  9, //!< Connected, reading latest data
        DEVICE_UPDATING_REALTIME    = 10, //!< Connected, reading realtime data
        DEVICE_UPDATING_HISTORY     = 11, //!< Connected, reading data history
    };
    Q_ENUMS(DeviceStatus)

    enum DeviceActions {
        ACTION_UPDATE = 0,              //!< Read sensor latest data
        ACTION_UPDATE_REALTIME,         //!< Stay connected and read sensor data
        ACTION_UPDATE_HISTORY,          //!< Read sensor history

        ACTION_LED_BLINK = 8,
        ACTION_CLEAR_HISTORY,
        ACTION_WATERING,
    };
    Q_ENUMS(DeviceActions)
};

/* ************************************************************************** */

class AioMinMax: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QDate date READ getDate NOTIFY updated)
    Q_PROPERTY(int day READ getDay NOTIFY updated)
    Q_PROPERTY(bool today READ isToday NOTIFY updated)

    Q_PROPERTY(float tempMin READ getTempMin NOTIFY updated)
    Q_PROPERTY(float tempMean READ getTempMean NOTIFY updated)
    Q_PROPERTY(float tempMax READ getTempMax NOTIFY updated)
    Q_PROPERTY(int hygroMin READ getHygroMin NOTIFY updated)
    Q_PROPERTY(int hygroMax READ getHygroMax NOTIFY updated)

    QDate date;
    int dayNb = -1;
    float tempMin;
    float tempMean = -99;
    float tempMax;
    int hygroMin;
    int hygroMax;

signals:
    void updated();

public:
    AioMinMax(const QDate &dt, float tmin, float t, float tmax, int hmin, int hmax,
              QObject *parent) : QObject(parent)
    {
        date = dt;
        dayNb = dt.day();
        tempMin = tmin; tempMean = t; tempMax = tmax;
        hygroMin = hmin; hygroMax = hmax;
    }

public slots:
    QDate getDate() { return date; }
    int getDay() { return dayNb; }
    bool isToday() { return (date == QDate::currentDate()); }
    float getTempMin() { return tempMin; }
    float getTempMean() { return tempMean; }
    float getTempMax() { return tempMax; }
    int getHygroMin() { return hygroMin; }
    int getHygroMax() { return hygroMax; }
};

/* ************************************************************************** */
#endif // DEVICE_UTILS_H
