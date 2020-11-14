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

/* ************************************************************************** */

#define LATEST_KNOWN_FIRMWARE_FLOWERCARE        "3.2.2"
#define LATEST_KNOWN_FIRMWARE_FLOWERPOWER       "2.0.3"
#define LATEST_KNOWN_FIRMWARE_ROPOT             "1.1.5"
#define LATEST_KNOWN_FIRMWARE_PARROTPOT         "1.2.0"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_LCD     "00.00.66"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK    "1.1.2_0007"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK   "1.1.2_0019"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_ALARM   "?"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_SQUARE  "1.0.0_0106"
#define LATEST_KNOWN_FIRMWARE_ESP32_GEIGER      "0.3"
#define LATEST_KNOWN_FIRMWARE_ESP32_HIGROW      "0.3"

/* ************************************************************************** */

enum DeviceCapabilities {
    DEVICE_BATTERY              = (1 <<  0), //!< Can report its battery level
    DEVICE_CLOCK                = (1 <<  1), //!< Has an onboard clock
    DEVICE_LED                  = (1 <<  2), //!< Has a blinkable LED
    DEVICE_HISTORY              = (1 <<  3), //!< Record sensor history
    DEVICE_LAST_MOVE            = (1 <<  4),
    DEVICE_WATER_TANK           = (1 <<  5),
    DEVICE_BUTTONS              = (1 <<  6),

    DEVICE_SOIL_MOISTURE        = (1 <<  8), //!< Has a soil moisture sensor (can be associated to a plant)
    DEVICE_SOIL_CONDUCTIVITY    = (1 <<  9), //!< Has a soil conductivity/fertility sensor
    DEVICE_SOIL_TEMPERATURE     = (1 << 10), //!< Has a soil temperature sensor
    DEVICE_SOIL_PH              = (1 << 11), //!< Has a soil PH sensor

    DEVICE_TEMPERATURE          = (1 << 12), //!< Has a temperature sensor
    DEVICE_HUMIDITY             = (1 << 13), //!< Has an humidity sensor
    DEVICE_BAROMETER            = (1 << 14), //!< Has a barometer
    DEVICE_LIGHT                = (1 << 15), //!< Has a light sensor
    DEVICE_UV                   = (1 << 16), //!< Has an UV light sensor
    DEVICE_SOUND                = (1 << 17), //!< Has a sound level sensor

    DEVICE_PM1                  = (1 << 18),
    DEVICE_PM25                 = (1 << 19),
    DEVICE_PM10                 = (1 << 20),
    DEVICE_O2                   = (1 << 21),
    DEVICE_O3                   = (1 << 22),
    DEVICE_CO                   = (1 << 23),
    DEVICE_CO2                  = (1 << 24),
    DEVICE_NOX                  = (1 << 26),
    DEVICE_VOC                  = (1 << 26),
    DEVICE_GEIGER               = (1 << 31),
};

enum DeviceType {
    DEVICE_PLANTSENSOR          = 0,
    DEVICE_THERMOMETER,
    DEVICE_ENVIRONMENTAL,
};

enum DeviceStatus {
    DEVICE_OFFLINE              =  0, //!< Not connected
    DEVICE_QUEUED               =  1, //!< In the update queue, not started
    DEVICE_CONNECTING           =  2, //!< Update started, trying to connect to the device
    DEVICE_CONNECTED            =  3, //!< Connected

    DEVICE_ACTION               =  8, //!< Connected, doing something
    DEVICE_UPDATING             =  9, //!< Connected, data update in progress
    DEVICE_UPDATING_HISTORY     = 10, //!< Connected, history update in progress
    DEVICE_UPDATING_REALTIME    = 11, //!< Connected, reading realtime data
};

enum DeviceActions {
    ACTION_UPDATE = 0,
    ACTION_UPDATE_HISTORY,
    ACTION_UPDATE_REALTIME,

    ACTION_LED_BLINK = 8,
    ACTION_WATERING,
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
