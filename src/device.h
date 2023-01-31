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
#include <QByteArray>
#include <QJsonObject>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief The Device class
 */
class Device: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int deviceType READ getDeviceType CONSTANT)
    Q_PROPERTY(int deviceBluetoothMode READ getBluetoothMode CONSTANT)
    Q_PROPERTY(int deviceCapabilities READ getDeviceCapabilities NOTIFY capabilitiesUpdated)
    Q_PROPERTY(int deviceSensors READ getDeviceSensors NOTIFY sensorsUpdated)

    Q_PROPERTY(QString deviceName READ getName NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceModel READ getModel NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceModelID READ getModelID NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceManufacturer READ getManufacturer NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddress READ getAddress NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddressMAC READ getAddressMAC WRITE setAddressMAC NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY sensorUpdated)
    Q_PROPERTY(bool deviceFirmwareUpToDate READ isFirmwareUpToDate NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceBattery READ getBatteryLevel NOTIFY batteryUpdated)

    Q_PROPERTY(bool isPlantSensor READ isPlantSensor NOTIFY sensorUpdated)
    Q_PROPERTY(bool isThermometer READ isThermometer NOTIFY sensorUpdated)
    Q_PROPERTY(bool isEnvironmentalSensor READ isEnvironmentalSensor NOTIFY sensorUpdated)

    Q_PROPERTY(bool isLight READ isLight NOTIFY sensorUpdated)
    Q_PROPERTY(bool isBeacon READ isBeacon NOTIFY sensorUpdated)
    Q_PROPERTY(bool isRemote READ isRemote NOTIFY sensorUpdated)
    Q_PROPERTY(bool isPGP READ isPGP NOTIFY sensorUpdated)

    Q_PROPERTY(bool hasBluetoothConnection READ hasBluetoothConnection CONSTANT)
    Q_PROPERTY(bool hasBluetoothAdvertisement READ hasBluetoothAdvertisement CONSTANT)

    Q_PROPERTY(bool hasRealTime READ hasRealTime NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasHistory READ hasHistory NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasBattery READ hasBatteryLevel NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasClock READ hasClock NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasLED READ hasLED NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasLastMove READ hasLastMove NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasWaterTank READ hasWaterTank NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasButtons READ hasButtons NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasCalibration READ hasCalibration NOTIFY capabilitiesUpdated)
    Q_PROPERTY(bool hasReboot READ hasReboot NOTIFY capabilitiesUpdated)

    Q_PROPERTY(QString deviceLocationName READ getLocationName WRITE setLocationName NOTIFY settingsUpdated)
    Q_PROPERTY(QString deviceAssociatedName READ getAssociatedName WRITE setAssociatedName NOTIFY settingsUpdated)
    Q_PROPERTY(QString devicePlantName READ getAssociatedName WRITE setAssociatedName NOTIFY settingsUpdated) // legacy
    Q_PROPERTY(bool deviceEnabled READ isEnabled WRITE setEnabled NOTIFY settingsUpdated)
    Q_PROPERTY(bool deviceIsInside READ isInside WRITE setInside NOTIFY settingsUpdated)
    Q_PROPERTY(bool deviceIsOutside READ isOutside WRITE setOutside NOTIFY settingsUpdated)

    Q_PROPERTY(int rssi READ getRssi NOTIFY rssiUpdated)
    Q_PROPERTY(bool available READ isAvailable NOTIFY rssiUpdated)

    Q_PROPERTY(int minorClass READ getMinorClass NOTIFY advertisementUpdated)
    Q_PROPERTY(int majorClass READ getMajorClass NOTIFY advertisementUpdated)
    Q_PROPERTY(int serviceClass READ getServiceClass NOTIFY advertisementUpdated)
    Q_PROPERTY(int bluetoothConfiguration READ getBluetoothConfiguration NOTIFY advertisementUpdated)

    Q_PROPERTY(bool enabled READ isEnabled NOTIFY statusUpdated)
    Q_PROPERTY(int status READ getStatus NOTIFY statusUpdated)
    Q_PROPERTY(int action READ getAction NOTIFY statusUpdated)
    Q_PROPERTY(bool busy READ isBusy NOTIFY statusUpdated)
    Q_PROPERTY(bool connected READ isConnected NOTIFY statusUpdated)
    Q_PROPERTY(bool working READ isWorking NOTIFY statusUpdated)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)
    Q_PROPERTY(bool errored READ isErrored NOTIFY statusUpdated)

    Q_PROPERTY(int lastUpdateMin READ getLastUpdateInt NOTIFY statusUpdated)
    Q_PROPERTY(QString lastUpdateStr READ getLastUpdateString NOTIFY statusUpdated)
    Q_PROPERTY(QDateTime lastUpdate READ getLastUpdate NOTIFY statusUpdated)
    Q_PROPERTY(QDateTime lastHistorySync READ getLastHistorySync NOTIFY statusUpdated)
    Q_PROPERTY(QDateTime deviceUptime READ getDeviceUptime NOTIFY statusUpdated)

    Q_PROPERTY(bool selected READ isSelected WRITE setSelected NOTIFY selectionUpdated)
    bool selected = false;
    bool isSelected() const { return selected; }
    void setSelected(bool value) { selected = value; Q_EMIT selectionUpdated(); }

Q_SIGNALS:
    void connected();
    void disconnected();

    void deviceUpdated(Device *d);
    void deviceSynced(Device *d);
    void sensorUpdated();
    void sensorsUpdated();
    void capabilitiesUpdated();
    void settingsUpdated();
    void selectionUpdated();

    void batteryUpdated();
    void rssiUpdated();
    void advertisementUpdated();
    void statusUpdated();
    void dataAvailableUpdated();
    void dataUpdated();
    void refreshUpdated();  // sent when a manual refresh is successful
    void historyUpdated();  // sent when history sync is successful
    void realtimeUpdated(); // sent when a realtime update is received

protected:
    int m_deviceType = 0;           //!< See DeviceUtils::DeviceType enum
    int m_deviceCapabilities = 0;   //!< See DeviceUtils::DeviceCapabilities enum
    int m_deviceSensors = 0;        //!< See DeviceUtils::DeviceSensors enum
    int m_deviceBluetoothMode = 0;  //!< See DeviceUtils::BluetoothMode enum

    // Device data
    QString m_deviceAddress;
    QString m_deviceAddressMAC;     //!< Used only on macOS and iOS, mostly to interact with other platforms
    QString m_deviceManufacturer;
    QString m_deviceModelID;
    QString m_deviceModel;
    QString m_deviceName;

    QString m_deviceFirmware = "UNKN";
    int m_deviceBattery = -1;

    // Db availability shortcuts
    bool m_dbInternal = false;
    bool m_dbExternal = false;

    // Device settings
    QString m_associatedName;
    QString m_locationName;
    int m_manualOrderIndex = -1;
    bool m_isEnabled = true;
    bool m_isOutside = false;
    QJsonObject m_additionalSettings;

    // Status
    int m_ble_status = 0;           //!< See DeviceStatus enum
    int m_ble_action = 0;           //!< See DeviceActions enum
    QDateTime m_lastUpdate;
    QDateTime m_lastUpdateDatabase;
    QDateTime m_lastHistorySeen;
    QDateTime m_lastHistorySync;
    QDateTime m_lastError;
    bool m_firmware_uptodate = false;

    int m_timeoutInterval = 12;
    QTimer m_timeoutTimer;
    void setTimeoutTimer();

    // Device time
    int64_t m_device_time = -1;
    int64_t m_device_wall_time = -1;

    // BLE
    QBluetoothDeviceInfo m_bleDevice;
    QLowEnergyController *m_bleController = nullptr;

    int m_bluetoothCoreConfiguration = 0; //!< See QBluetoothDeviceInfo::CoreConfiguration enum

    int m_rssi = 0;
    int m_rssiMin = 0;
    int m_rssiMax = -100;

    QTimer m_rssiTimer;
    int m_rssiTimeoutInterval = 16;

    int m_major = 0;
    int m_minor = 0;
    int m_service = 0;

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
    virtual void refreshHistoryFinished(bool status);
    virtual void refreshRealtime();
    virtual void refreshRealtimeFinished();

    virtual bool getSqlDeviceInfos();

    // helpers
    void setModel(const QString &model);
    void setModelID(const QString &modelID);
    void setBattery(const int battery);
    void setBatteryFirmware(const int battery, const QString &firmware);
    void setFirmware(const QString &firmware);
    bool isFirmwareUpToDate() const { return m_firmware_uptodate; }

public:
    Device(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    Device(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~Device();

    void setName(const QString &name);
    void setDeviceClass(const int major, const int minor, const int service);
    virtual void setCoreConfiguration(const int bleconf);

    // Device infos
    QString getModel() const { return m_deviceModel; }
    QString getModelID() const { return m_deviceModelID; }
    QString getName() const { return m_deviceName; }
    QString getAddress() const { return m_deviceAddress; }
    QString getManufacturer() const { return m_deviceManufacturer; }
    QString getFirmware() const { return m_deviceFirmware; }
    int getBatteryLevel() const { return m_deviceBattery; }

    // Device type, capabilities and sensors
    int getDeviceType() const { return m_deviceType; }
    int getDeviceCapabilities() const { return m_deviceCapabilities; }
    int getDeviceSensors() const { return m_deviceSensors; }

    int getBluetoothConfiguration() const { return m_bluetoothCoreConfiguration; }
    int getBluetoothMode() const { return m_deviceBluetoothMode; }
    bool hasBluetoothConnection() const { return (m_deviceBluetoothMode & DeviceUtils::DEVICE_BLE_CONNECTION); }
    bool hasBluetoothAdvertisement() const { return (m_deviceBluetoothMode & DeviceUtils::DEVICE_BLE_ADVERTISEMENT); }

    bool isPlantSensor() const { return (m_deviceType == DeviceUtils::DEVICE_PLANTSENSOR); }
    bool isThermometer() const { return (m_deviceType == DeviceUtils::DEVICE_THERMOMETER); }
    bool isEnvironmentalSensor() const { return (m_deviceType == DeviceUtils::DEVICE_ENVIRONMENTAL); }
    bool isLight() const { return (m_deviceType == DeviceUtils::DEVICE_LIGHT); }
    bool isBeacon() const { return (m_deviceType == DeviceUtils::DEVICE_BEACON); }
    bool isRemote() const { return (m_deviceType == DeviceUtils::DEVICE_REMOTE); }
    bool isPGP() const { return (m_deviceType == DeviceUtils::DEVICE_PGP); }

    virtual bool hasRealTime() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_REALTIME); }
    virtual bool hasHistory() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_HISTORY); }
    bool hasBatteryLevel() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_BATTERY); }
    bool hasClock() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_CLOCK); }
    bool hasLED() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_LED_STATUS); }
    bool hasLastMove() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_LAST_MOVE); }
    bool hasWaterTank() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_WATER_TANK); }
    bool hasButtons() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_BUTTONS); }
    bool hasCalibration() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_CALIBRATION); }
    bool hasReboot() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_REBOOT); }

    // Device RSSI
    void setRssi(const int rssi);
    void cleanRssi();

    bool isAvailable() const { return (m_rssi < 0); }
    int getRssi() const { return m_rssi; }
    int getRssiMin() const { return m_rssiMin; }
    int getRssiMax() const { return m_rssiMax; }

    int getMinorClass() const { return m_minor; }
    int getMajorClass() const { return m_major; }
    int getServiceClass() const { return m_service; }

    // Device status
    int getAction() const { return m_ble_action; }
    int getStatus() const { return m_ble_status; }
    bool isBusy() const;                //!< Is currently doing/trying something?
    bool isConnected() const;           //!< Is currently connected
    bool isWorking() const;             //!< Is currently working?
    bool isUpdating() const;            //!< Is currently being updated?
    bool isErrored() const;             //!< Has emitted a BLE error

    QDateTime getLastUpdate() const;
    QString getLastUpdateString() const;
    int getLastUpdateInt() const;
    int getLastUpdateDbInt() const;
    int getLastErrorInt() const;

    QDateTime getDeviceUptime() const;
    float getDeviceUptime_days() const;
    QDateTime getLastHistorySync() const;
    int getLastHistorySync_int() const;
    float getLastHistorySync_days() const;
    virtual int getHistoryUpdatePercent() const;

    virtual void checkDataAvailability();
    virtual bool needsUpdateRt() const;
    virtual bool needsUpdateDb() const;
    virtual bool needsUpdateDb_mini() const;
    virtual bool needsSync() const;

    // Device associated data
    QString getLocationName() const { return m_locationName; }
    void setLocationName(const QString &name);
    QString getAssociatedName() const { return m_associatedName; }
    void setAssociatedName(const QString &name);
    bool hasAddressMAC() const;
    QString getAddressMAC() const;
    void setAddressMAC(const QString &mac);
    int getManualIndex() const { return m_manualOrderIndex; }
    bool isEnabled() const { return m_isEnabled; }
    void setEnabled(const bool enabled);
    bool isInside() const { return !m_isOutside; }
    void setInside(const bool inside);
    bool isOutside() const { return m_isOutside; }
    void setOutside(const bool outside);
    // Device additional settings
    Q_INVOKABLE bool hasSetting(const QString &key) const;
    Q_INVOKABLE QVariant getSetting(const QString &key) const;
    Q_INVOKABLE bool setSetting(const QString &key, QVariant value);

    // Start actions
    Q_INVOKABLE void actionConnect();
    Q_INVOKABLE void actionDisconnect();
    Q_INVOKABLE void actionScan();
    Q_INVOKABLE void actionScanWithValues();
    Q_INVOKABLE void actionClearData();
    Q_INVOKABLE void actionClearDeviceData();
    Q_INVOKABLE void actionLedBlink();
    Q_INVOKABLE void actionWatering();
    Q_INVOKABLE void actionCalibrate();
    Q_INVOKABLE void actionReboot();
    Q_INVOKABLE void actionShutdown();

    // BLE advertisement
    virtual void parseAdvertisementData(const uint16_t adv_mode,
                                        const uint16_t adv_id,
                                        const QByteArray &data);

public slots:
    void deviceConnect();               //!< Initiate a BLE connection with a device
    void deviceDisconnect();

    void refreshQueued();
    void refreshDequeued();

    void refreshStart();
    void refreshStartHistory();
    void refreshStartRealtime();
    void refreshRetry();
    void refreshStop();
};

/* ************************************************************************** */
#endif // DEVICE_H
