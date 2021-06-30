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

#include "device_utils.h"

#include <QObject>
#include <QList>
#include <QTimer>
#include <QDate>
#include <QDateTime>
#include <QJsonObject>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

/* ************************************************************************** */

/*!
 * \brief The Device class
 */
class Device: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int deviceType READ getDeviceType CONSTANT)
    Q_PROPERTY(int deviceCapabilities READ getDeviceCapabilities NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceSensors READ getDeviceSensors NOTIFY sensorUpdated)

    Q_PROPERTY(bool isPlantSensor READ isPlantSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool isThermometer READ isThermometer NOTIFY sensorUpdated)
    Q_PROPERTY(bool isEnvironmentalSensor READ isEnvironmentalSensor NOTIFY sensorUpdated)

    Q_PROPERTY(bool hasRealTime READ hasRealTime NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasHistory READ hasHistory NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasBattery READ hasBatteryLevel NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasClock READ hasClock NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasLED READ hasLED NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasLastMove READ hasLastMove NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasWaterTank READ hasWaterTank NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasButtons READ hasButtons NOTIFY sensorUpdated)

    Q_PROPERTY(bool hasSoilMoistureSensor READ hasSoilMoistureSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasSoilConductivitySensor READ hasSoilConductivitySensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasSoilTemperatureSensor READ hasSoilTemperatureSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasSoilPhSensor READ hasSoilPhSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasTemperatureSensor READ hasTemperatureSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasHumiditySensor READ hasHumiditySensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasPressureSensor READ hasPressureSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasLuminositySensor READ hasLuminositySensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasUvSensor READ hasUvSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasSoundSensor READ hasSoundSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasWaterLevelSensor READ hasWaterLevelSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasWindDirectionSensor READ hasWindDirectionSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasWindSpeedSensor READ hasWindSpeedSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasPM1Sensor READ hasPM1Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasPM25Sensor READ hasPM25Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasPM10Sensor READ hasPM10Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasO2Sensor READ hasO2Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasO3Sensor READ hasO3Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasCoSensor READ hasCoSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasCo2Sensor READ hasCo2Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool haseCo2Sensor READ haseCo2Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasNo2Sensor READ hasNo2Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasSo2Sensor READ hasSo2Sensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasVocSensor READ hasVocSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasHchoSensor READ hasHchoSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool hasGeigerCounter READ hasGeigerCounter NOTIFY sensorUpdated)

    Q_PROPERTY(QString deviceName READ getName NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceModel READ getModel NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddress READ getAddress NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY sensorUpdated)
    Q_PROPERTY(bool deviceFirmwareUpToDate READ isFirmwareUpToDate NOTIFY sensorUpdated)

    Q_PROPERTY(int deviceBattery READ getBatteryLevel NOTIFY batteryUpdated)
    Q_PROPERTY(int deviceRssi READ getRssi NOTIFY rssiUpdated)

    Q_PROPERTY(QString deviceLocationName READ getLocationName NOTIFY settingsUpdated)
    Q_PROPERTY(QString deviceAssociatedName READ getAssociatedName NOTIFY settingsUpdated)
    Q_PROPERTY(bool deviceIsInside READ isInside NOTIFY settingsUpdated)
    Q_PROPERTY(bool deviceIsOutside READ isOutside NOTIFY settingsUpdated)

    Q_PROPERTY(int status READ getStatus NOTIFY statusUpdated)
    Q_PROPERTY(bool busy READ isBusy NOTIFY statusUpdated)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)
    Q_PROPERTY(bool errored READ isErrored NOTIFY statusUpdated)
    Q_PROPERTY(bool dataFresh READ isDataFresh NOTIFY statusUpdated)
    Q_PROPERTY(bool dataAvailable READ isDataAvailable NOTIFY statusUpdated)

    Q_PROPERTY(int lastUpdateMin READ getLastUpdateInt NOTIFY statusUpdated)
    Q_PROPERTY(QString lastUpdateStr READ getLastUpdateString NOTIFY statusUpdated)
    Q_PROPERTY(QDateTime lastHistorySync READ getLastHistorySync NOTIFY historyUpdated)
    Q_PROPERTY(QDateTime deviceUptime READ getDeviceUptime NOTIFY statusUpdated)

    Q_PROPERTY(bool selected READ isSelected WRITE setSelected NOTIFY selectionUpdated)
    bool selected = false;
    bool isSelected() const { return selected; }
    void setSelected(bool value) { selected = value; Q_EMIT selectionUpdated(); }

Q_SIGNALS:
    void connected();
    void disconnected();

    void deviceUpdated(Device *d);
    void sensorUpdated();
    void statusUpdated();
    void settingsUpdated();
    void batteryUpdated();
    void rssiUpdated();
    void dataUpdated();
    void historyUpdated();
    void selectionUpdated();

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

    // Db
    bool m_dbInternal = false;
    bool m_dbExternal = false;

    // Device settings
    QString m_associatedName;
    QString m_locationName;
    int m_manualOrderIndex = -1;
    bool m_isOutside = false;
    QJsonObject m_additionalSettings;

    // Status
    int m_ble_status = 0;           //!< See DeviceStatus enum
    int m_ble_action = 0;           //!< See DeviceActions enum
    QDateTime m_lastUpdate;
    QDateTime m_lastUpdateDatabase;
    QDateTime m_lastHistorySync;
    QDateTime m_lastError;
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
    QLowEnergyController *m_bleController = nullptr;
    QTimer m_rssiTimer;
    int m_rssi = 1;

    virtual void deviceConnected();
    virtual void deviceDisconnected();
    virtual void deviceErrored(QLowEnergyController::Error);
    virtual void deviceStateChanged(QLowEnergyController::ControllerState state);

    virtual void addLowEnergyService(const QBluetoothUuid &uuid);
    virtual void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);
    virtual void serviceScanDone();

    virtual void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);

    virtual void actionStarted();
    virtual void actionCanceled();
    virtual void actionTimedout();
    virtual void refreshDataFinished(bool status, bool cached = false);
    virtual void refreshDataRealtime(bool status);
    virtual void refreshHistoryFinished(bool status);

    virtual bool getSqlDeviceInfos();

    // helpers
    bool isFirmwareUpToDate() const { return m_firmware_uptodate; }
    void setFirmware(const QString &firmware);
    void setBattery(const int battery);
    void setBatteryFirmware(const int battery, const QString &firmware);

public:
    Device(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    Device(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~Device();

    // Device infos
    QString getModel() const { return m_deviceModel; }
    QString getName() const { return m_deviceName; }
    QString getAddress() const { return m_deviceAddress; }
    QString getFirmware() const { return m_deviceFirmware; }
    int getBatteryLevel() const { return m_deviceBattery; }

    // Device type, capabilities and sensors
    int getDeviceType() const { return m_deviceType; }
    int getDeviceCapabilities() const { return m_deviceCapabilities; }
    int getDeviceSensors() const { return m_deviceSensors; }

    bool isPlantSensor() const { return (m_deviceType == DeviceUtils::DEVICE_PLANTSENSOR); }
    bool isThermometer() const { return (m_deviceType == DeviceUtils::DEVICE_THERMOMETER); }
    bool isEnvironmentalSensor() const { return (m_deviceType == DeviceUtils::DEVICE_ENVIRONMENTAL); }

    bool hasRealTime() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_REALTIME); }
    virtual bool hasHistory() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_HISTORY); }
    bool hasBatteryLevel() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_BATTERY); }
    bool hasClock() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_CLOCK); }
    bool hasLED() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_LED_STATUS); }
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
    bool hasCo2Sensor() const { return ((m_deviceSensors & DeviceUtils::SENSOR_CO2) || (m_deviceSensors & DeviceUtils::SENSOR_eCO2)); }
    bool haseCo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_eCO2); }
    bool hasNo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_NO2); }
    bool hasSo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SO2); }
    bool hasVocSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_VOC); }
    bool hasHchoSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_HCHO); }
    bool hasGeigerCounter() const { return (m_deviceSensors & DeviceUtils::SENSOR_GEIGER); }

    // Device RSSI
    int getRssi() const { return m_rssi; }
    void setRssi(const int rssi);
    void cleanRssi();

    // BLE advertisement
    virtual void parseAdvertisementData(const QByteArray &value);

public slots:
    void deviceConnect();               //!< Initiate a BLE connection with a device
    void deviceDisconnect();

    void actionLedBlink();
    void actionWatering();
    void actionClearData();
    void actionClearHistory();

    void refreshQueue();
    void refreshStart();
    void refreshStartHistory();
    void refreshStartRealtime();
    void refreshRetry();
    void refreshStop();

    // Status
    int getStatus() const { return m_ble_status; }
    bool isDataFresh() const;           //!< Has at least >Xh (user set) old data
    bool isDataAvailable() const;       //!< Has at least >12h old data
    bool isBusy() const;                //!< Is currently doing something?
    bool isWorking() const;             //!< Is currently working?
    bool isUpdating() const;            //!< Is currently being updated?
    bool isErrored() const;             //!< Has emitted a BLE error

    bool needsUpdateRt() const;
    bool needsUpdateDb() const;

    QString getLastUpdateString() const;
    int getLastUpdateInt() const;
    int getLastUpdateDbInt() const;
    int getLastErrorInt() const;

    QDateTime getDeviceUptime() const;
    float getDeviceUptime_days() const;
    QDateTime getLastHistorySync() const;
    float getLastHistorySync_days() const;
    virtual int getHistoryUpdatePercent() const;

    // Device associated data
    QString getLocationName() { return m_locationName; }
    void setLocationName(const QString &name);
    QString getAssociatedName() { return m_associatedName; }
    void setAssociatedName(const QString &name);
    int getManualIndex() const { return m_manualOrderIndex; }
    bool isInside() const { return !m_isOutside; }
    bool isOutside() const { return m_isOutside; }
    void setOutside(const bool outside);
    // Device additional settings
    bool hasSetting(const QString &key) const;
    QVariant getSetting(const QString &key) const;
    bool setSetting(const QString &key, QVariant value);
};

/* ************************************************************************** */
#endif // DEVICE_H
