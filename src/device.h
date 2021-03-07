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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_H
#define DEVICE_H
/* ************************************************************************** */

#include <QObject>
#include <QList>
#include <QTimer>
#include <QDate>
#include <QDateTime>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

#include "device_utils.h"

/* ************************************************************************** */

/*!
 * \brief The Device class
 */
class Device: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int deviceType READ getDeviceType NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceCapabilities READ getDeviceCapabilities NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceSensors READ getDeviceSensors NOTIFY sensorUpdated)

    Q_PROPERTY(bool hasBattery READ hasBatteryLevel NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasClock READ hasClock NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasLED READ hasLED NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasHistory READ hasHistory NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasLastMove READ hasLastMove NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasWaterTank READ hasWaterTank NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasButtons READ hasButtons NOTIFY sensorUpdated)

    Q_PROPERTY(QString deviceName READ getName NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceModel READ getModel NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddress READ getAddress NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY sensorUpdated)
    Q_PROPERTY(bool deviceFirmwareUpToDate READ isFirmwareUpToDate NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceBattery READ getBatteryLevel NOTIFY sensorUpdated)

    Q_PROPERTY(int deviceRssi READ getRssi NOTIFY rssiUpdated)

    Q_PROPERTY(QString deviceLocationName READ getLocationName NOTIFY sensorUpdated) // TODO settingsUpdated
    Q_PROPERTY(QString deviceAssociatedName READ getAssociatedName NOTIFY sensorUpdated)
    Q_PROPERTY(QString devicePlantName READ getAssociatedName NOTIFY sensorUpdated) // legacy
    Q_PROPERTY(bool deviceIsInside READ isInside NOTIFY sensorUpdated)
    Q_PROPERTY(bool deviceIsOutside READ isOutside NOTIFY sensorUpdated)

    Q_PROPERTY(int status READ getStatus NOTIFY statusUpdated)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)
    Q_PROPERTY(bool fresh READ isFresh NOTIFY statusUpdated)
    Q_PROPERTY(bool available READ isAvailable NOTIFY statusUpdated)
    Q_PROPERTY(bool errored READ isErrored NOTIFY statusUpdated)
    Q_PROPERTY(int lastUpdateMin READ getLastUpdateInt NOTIFY statusUpdated)
    Q_PROPERTY(QString lastUpdateStr READ getLastUpdateString NOTIFY statusUpdated)

    Q_PROPERTY(QDateTime lastSync READ getLastSync NOTIFY historyUpdated)
    Q_PROPERTY(int historyUpdatePercent READ getHistoryUpdatePercent NOTIFY historyUpdated)

Q_SIGNALS:
    void connected();
    void disconnected();
    void deviceUpdated(Device *d);
    void sensorUpdated();
    void settingsUpdated();
    void statusUpdated();
    void rssiUpdated();
    void dataUpdated();
    void historyUpdated();

protected:
    int m_deviceType = 0;           //!< See DeviceType enum
    int m_deviceCapabilities = 0;   //!< See DeviceCapabilities enum
    int m_deviceSensors = 0;        //!< See DeviceSensors enum

    // Device data
    QString m_deviceAddress;
    QString m_deviceModel;
    QString m_deviceName;
    QString m_deviceFirmware = "UNKN";
    int m_deviceBattery = -1;

    // Device settings
    QString m_associatedName; // was m_plantName
    QString m_locationName;
    int m_manualOrderIndex = -1;
    bool m_isOutside = false;
    QString m_additionalSettings;

    // Status
    int m_status = 0;           //!< See DeviceStatus enum
    bool m_updating = false;    //!< Shortcut, if m_status == 2 or 3
    int m_ble_action = 0;       //!< See DeviceActions enum
    QDateTime m_lastUpdate;
    QDateTime m_lastSync;
    QDateTime m_lastError;
    int m_retries = 1;
    bool m_firmware_uptodate = false;

    QTimer m_updateTimer;
    void setUpdateTimer(int updateIntervalMin = 0);

    int m_timeoutInterval = 12;
    QTimer m_timeoutTimer;
    void setTimeoutTimer();

    // Device time
    int64_t m_device_time = -1;
    int64_t m_device_wall_time = -1;

    // BLE
    QBluetoothDeviceInfo m_bleDevice;
    QLowEnergyController *controller = nullptr;
    QTimer m_rssiTimer;
    int m_rssi = 1;

    void deviceConnected();
    void deviceDisconnected();
    void errorReceived(QLowEnergyController::Error);
    void stateChanged(QLowEnergyController::ControllerState state);

    virtual void serviceScanDone();
    virtual void addLowEnergyService(const QBluetoothUuid &uuid);
    virtual void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    virtual void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);

    virtual void refreshDataStarted();
    virtual void refreshDataCanceled();
    virtual void refreshDataFinished(bool status, bool cached = false);

    // Get data
    bool getBleData();

    virtual bool getSqlInfos();
    virtual bool getSqlData(int minutes);
    virtual bool getSqlLimits();

    bool m_dbInternal = false;
    bool m_dbExternal = false;

public:
    Device(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    Device(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~Device();

    virtual void parseAdvertisementData(const QByteArray &value);

public slots:
    void deviceConnect();
    void deviceDisconnect();

    void ledActionStart();

    void refreshQueue();
    void refreshStart();
    void refreshRetry();
    void refreshHistoryStart();
    void refreshStop();

    // Status
    int getStatus() const { return m_status; }
    bool isUpdating() const { return m_updating; }      //!< Is currently being updated?
    bool isErrored() const;                             //!< Has emitted a BLE error
    bool isFresh() const;                               //!< Has at least >Xh (user set) old data
    bool isAvailable() const;                           //!< Has at least >12h old data

    QString getLastUpdateString() const;
    int getLastUpdateInt() const;
    int getLastErrorInt() const;

    QDateTime getLastSync() const;
    virtual int getHistoryUpdatePercent() const;

    // Device infos
    QString getModel() const { return m_deviceModel; }
    QString getName() const { return m_deviceName; }
    QString getAddress() const { return m_deviceAddress; }
    QString getFirmware() const { return m_deviceFirmware; }
    bool isFirmwareUpToDate() const { return m_firmware_uptodate; }
    int getBatteryLevel() const { return m_deviceBattery; }

    // RSSI
    int getRssi() const { return m_rssi; }
    void updateRssi(const int rssi);
    void cleanRssi();

    // Device associated data
    QString getLocationName() { return m_locationName; }
    void setLocationName(const QString &name);
    QString getAssociatedName() { return m_associatedName; }
    void setAssociatedName(const QString &name);
    int getManualIndex() const { return m_manualOrderIndex; }
    bool isInside() const { return !m_isOutside; }
    bool isOutside() const { return m_isOutside; }
    void setOutside(const bool outside);

    // Device type, capabilities and sensors
    int getDeviceType() const { return m_deviceType; }
    int getDeviceCapabilities() const { return m_deviceCapabilities; }
    int getDeviceSensors() const { return m_deviceSensors; }

    bool isPlantSensor() const { if (m_deviceType == DeviceUtils::DEVICE_PLANTSENSOR) { return true; } return false; }
    bool isThermometer() const { if (m_deviceType == DeviceUtils::DEVICE_THERMOMETER) { return true; } return false; }
    bool isEnvironmentalSensor() const { if (m_deviceType == DeviceUtils::DEVICE_ENVIRONMENTAL) { return true; } return false; }

    bool hasBatteryLevel() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_BATTERY); }
    bool hasClock() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_CLOCK); }
    bool hasLED() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_LED_STATUS); }
    bool hasHistory() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_HISTORY); }
    bool hasLastMove() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_LAST_MOVE); }
    bool hasWaterTank() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_WATER_TANK); }
    bool hasButtons() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_BUTTONS); }

    bool hasSoilMoistureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_MOISTURE); }
    bool hasSoilConductivitySensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_CONDUCTIVITY); }
    bool hasSoilTemperatureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_TEMPERATURE); }
    bool hasSoilPhSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_PH); }

    bool hasTemperatureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_TEMPERATURE); }
    bool hasHumiditySensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_HUMIDITY); }

    bool hasPressureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PRESSURE); }
    bool hasLuminositySensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_LUMINOSITY); }
    bool hasUvSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_UV); }
    bool hasSoundSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOUND); }
    bool hasWaterLevelSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_WATER_LEVEL); }
    bool hasWindDirectionSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_WIND_DIRECTION); }
    bool hasWindSpeedSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_WIND_SPEED); }
    bool hasPM1Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PM1); }
    bool hasPM25Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PM25); }
    bool hasPM10Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PM10); }
    bool hasO2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_O2); }
    bool hasO3Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_O3); }
    bool hasCoSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_CO); }
    bool hasCo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_CO2); }
    bool hasNo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_NO2); }
    bool hasVocSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_VOC); }
    bool hasGeigerCounter() const { return (m_deviceSensors & DeviceUtils::SENSOR_GEIGER); }
};

/* ************************************************************************** */
#endif // DEVICE_H
