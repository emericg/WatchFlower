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

#ifndef DEVICE_INFOS_H
#define DEVICE_INFOS_H
/* ************************************************************************** */

#include "device_utils.h"

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QJsonArray>

/* ************************************************************************** */

class DeviceInfosSensor: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int sensorId READ getSensorId CONSTANT)
    Q_PROPERTY(QString sensorString READ getSensorString CONSTANT)

    DeviceUtils::DeviceSensors m_sensor;
    QString m_string;

    QChar m_value_type;
    float m_value_min;
    float m_value_max;
    float m_value_precision;

    int getSensorId() { return m_sensor; }
    QString getSensorString() { return m_string; }

public:
    DeviceInfosSensor(const QString &sensor, const QString &string, QObject *parent);
    ~DeviceInfosSensor();
};

class DeviceInfosCapability: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int capabilityId READ getCapabilityId CONSTANT)
    Q_PROPERTY(QString capabilityString READ getCapabilityString CONSTANT)

    DeviceUtils::DeviceCapabilities m_capability;
    QString m_string;

    int getCapabilityId() { return m_capability; }
    QString getCapabilityString() { return m_string; }

public:
    DeviceInfosCapability(const QString &capability, const QString &string, QObject *parent);
    ~DeviceInfosCapability();
};

class DeviceInfos: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString deviceModel READ getDeviceModel CONSTANT)
    Q_PROPERTY(QString deviceManufacturer READ getDeviceManufacturer CONSTANT)
    Q_PROPERTY(QString deviceId READ getDeviceId CONSTANT)
    Q_PROPERTY(int deviceYear READ getDeviceYear CONSTANT)
    Q_PROPERTY(QString deviceBattery READ getDeviceBattery CONSTANT)
    Q_PROPERTY(QString deviceScreen READ getDeviceScreen CONSTANT)
    Q_PROPERTY(QString deviceIPrating READ getDeviceIPrating CONSTANT)

    Q_PROPERTY(bool deviceNeedsOfficialApp READ getDeviceNeedsOfficialApp CONSTANT)

    Q_PROPERTY(QVariant deviceSensors READ getDeviceSensors CONSTANT)
    Q_PROPERTY(QVariant deviceCapabilities READ getDeviceCapabilities CONSTANT)

    QString m_model;
    QString m_manufacturer;
    QString m_id;
    int m_year = 2000;
    QString m_battery;
    QString m_screen;
    QString m_ipx;
    bool m_needsOfficialApp = false;

    QList <QObject *> m_sensors;
    QList <QObject *> m_capabilities;

    QString getDeviceModel() { return m_model; }
    QString getDeviceManufacturer() { return m_manufacturer; }
    QString getDeviceId() { return m_id; }
    int getDeviceYear() { return m_year; }
    QString getDeviceBattery() { return m_battery; }
    QString getDeviceScreen() { return m_screen; }
    QString getDeviceIPrating() { return m_ipx; }
    bool getDeviceNeedsOfficialApp() { return m_needsOfficialApp; }

    QVariant getDeviceSensors() { return QVariant::fromValue(m_sensors); }
    QVariant getDeviceCapabilities() { return QVariant::fromValue(m_capabilities); }

public:
    DeviceInfos(QObject *parent);
    ~DeviceInfos();

    void load(const QJsonObject &device);
    bool loadSlow(const QString &name, const QString &model, const QString &modelId);
};

class DeviceInfosLoader: public QObject
{
    // Singleton
    static DeviceInfosLoader *instance;
    DeviceInfosLoader();
    ~DeviceInfosLoader();

    QJsonArray deviceJsonArray;

public:
    static DeviceInfosLoader *getInstance();

    DeviceInfos *getDeviceInfos(const QString &name, const QString &model, const QString &modelId);
};

/* ************************************************************************** */
#endif // DEVICE_INFOS_H
