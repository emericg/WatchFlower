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

    Q_PROPERTY(int status READ getStatus NOTIFY statusUpdated)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)

    Q_PROPERTY(bool fresh READ isFresh NOTIFY statusUpdated)
    Q_PROPERTY(bool available READ isAvailable NOTIFY statusUpdated)
    Q_PROPERTY(bool errored READ isErrored NOTIFY statusUpdated)

    Q_PROPERTY(bool hasLED READ hasLED NOTIFY statusUpdated)
    Q_PROPERTY(bool hasHistory READ hasHistory NOTIFY statusUpdated)

    Q_PROPERTY(int lastUpdateMin READ getLastUpdateInt NOTIFY statusUpdated)
    Q_PROPERTY(QString lastUpdateStr READ getLastUpdateString NOTIFY statusUpdated)

    Q_PROPERTY(int deviceType READ getDeviceType NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceName READ getName NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddress READ getAddress NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceLocationName READ getLocationName NOTIFY sensorUpdated)
    Q_PROPERTY(QString devicePlantName READ getPlantName NOTIFY sensorUpdated)

    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY sensorUpdated)
    Q_PROPERTY(bool deviceFirmwareUpToDate READ isFirmwareUpToDate NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceBattery READ getBattery NOTIFY sensorUpdated)

    // datas
    Q_PROPERTY(float deviceTemp READ getTemp NOTIFY dataUpdated)
    Q_PROPERTY(float deviceTempC READ getTempC NOTIFY dataUpdated)
    Q_PROPERTY(float deviceTempF READ getTempF NOTIFY dataUpdated)
    Q_PROPERTY(int deviceHumidity READ getHumidity NOTIFY dataUpdated)
    Q_PROPERTY(int deviceLuminosity READ getLuminosity NOTIFY dataUpdated)
    Q_PROPERTY(int deviceConductivity READ getConductivity NOTIFY dataUpdated)

    Q_PROPERTY(int hygroMin READ getHygroMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int hygroMax READ getHygroMax NOTIFY minmaxUpdated)
    Q_PROPERTY(float tempMin READ getTempMin NOTIFY minmaxUpdated)
    Q_PROPERTY(float tempMax READ getTempMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int lumiMin READ getLumiMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int lumiMax READ getLumiMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMin READ getConduMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMax READ getConduMax NOTIFY minmaxUpdated)
    Q_PROPERTY(QVariant aioMinMaxData READ getAioMinMaxData NOTIFY aioMinMaxDataUpdated)

    // limits
    Q_PROPERTY(int limitHygroMin READ getLimitHygroMin WRITE setLimitHygroMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHygroMax READ getLimitHygroMax WRITE setLimitHygroMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMin READ getLimitTempMin WRITE setLimitTempMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMax READ getLimitTempMax WRITE setLimitTempMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMin READ getLimitLumiMin WRITE setLimitLumiMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMax READ getLimitLumiMax WRITE setLimitLumiMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMin READ getLimitConduMin WRITE setLimitConduMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMax READ getLimitConduMax WRITE setLimitConduMax NOTIFY limitsUpdated)

Q_SIGNALS:
    void statusUpdated();
    void sensorUpdated();
    void dataUpdated();
    void historyUpdated();
    void minmaxUpdated();
    void limitsUpdated();
    void aioMinMaxDataUpdated();
    void deviceUpdated(Device *d);

protected:
    QString m_deviceName;
    QString m_deviceAddress;
    QBluetoothDeviceInfo m_bleDevice;
    int m_deviceType = 0;       //!< See DeviceType enum
    int m_capabilities = 0;     //!< See DeviceCapabilities enum

    int m_status = 0;           //!< See DeviceStatus enum
    bool m_updating = false;    //!< Shortcut, if m_status == 2 or 3
    QDateTime m_lastUpdate;
    QDateTime m_lastError;

    // BLE
    int m_ble_action = 0;       //!< See DeviceActions enum
    int m_update_interval = 0;
    QTimer m_updateTimer;
    int m_timeout = 15;
    QTimer m_timeoutTimer;

    // BLE device infos
    QString m_firmware = "UNKN";
    bool m_firmware_uptodate = false;
    int m_battery = -1;

    // BLE device data
    float m_temp = -99.f;
    int m_humi = -99;
    int m_luminosity = -99;
    int m_hygro = -99;
    int m_conductivity = -99;

    // SQL associated data
    QString m_locationName;
    QString m_plantName;

    // SQL min/max data (x days period)
    float m_tempMin = 999.f;
    float m_tempMax = -99.f;
    int m_hygroMin = 99999;
    int m_hygroMax = -99;
    int m_luminosityMin = 99999;
    int m_luminosityMax = -99;
    int m_conductivityMin = 99999;
    int m_conductivityMax = -99;

    QList <QObject *> m_aio_minmax_data;

    // BLE device limits
    int m_limitHygroMin = 15;
    int m_limitHygroMax = 50;
    int m_limitTempMin = 14;
    int m_limitTempMax = 28;
    int m_limitLumiMin = 1000;
    int m_limitLumiMax = 3000;
    int m_limitConduMin = 100;
    int m_limitConduMax = 500;

    // QLowEnergyController related
    QLowEnergyController *controller = nullptr;
    bool hasControllerError() const;

    void deviceConnected();
    void deviceDisconnected();
    void errorReceived(QLowEnergyController::Error);
    virtual void serviceScanDone();
    virtual void addLowEnergyService(const QBluetoothUuid &uuid);
    virtual void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    virtual void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);

    void refreshDataStarted();
    void refreshDataCanceled();
    void refreshDataFinished(bool status, bool cached = false);

    void setUpdateTimer(int updateIntervalMin = 0);
    void setTimeoutTimer();

    bool getSqlInfos();
    virtual bool getSqlData(int minutes);
    bool getBleData();

public:
    Device(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    Device(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~Device();

public slots:
    void ledActionStart();
    void refreshQueue();
    void refreshStart();
    void refreshHistoryStart();
    void refreshStop();

    // BLE device
    QString getName() const { return m_deviceName; }
    QString getAddress() const { return m_deviceAddress; }
    int getDeviceType() const { return m_deviceType; }

    bool hasBatteryLevel() const { return (m_capabilities & DEVICE_BATTERY); }
    bool hasClock() const { return (m_capabilities & DEVICE_CLOCK); }
    bool hasLED() const { return (m_capabilities & DEVICE_LED); }
    bool hasHistory() const { return (m_capabilities & DEVICE_HISTORY); }

    bool hasSoilMoistureSensor() const { return (m_capabilities & DEVICE_SOIL_MOISTURE); }
    bool hasSoilConductivitySensor() const { return (m_capabilities & DEVICE_SOIL_CONDUCTIVITY); }
    bool hasSoilTemperatureSensor() const { return (m_capabilities & DEVICE_SOIL_TEMPERATURE); }
    bool hasSoilPhSensor() const { return (m_capabilities & DEVICE_SOIL_PH); }

    bool hasTemperatureSensor() const { return (m_capabilities & DEVICE_TEMPERATURE); }
    bool hasHumiditySensor() const { return (m_capabilities & DEVICE_HUMIDITY); }
    bool hasLuminositySensor() const { return (m_capabilities & DEVICE_LIGHT); }
    bool hasUvSensor() const { return (m_capabilities & DEVICE_UV); }
    bool hasBarometer() const { return (m_capabilities & DEVICE_BAROMETER); }
    bool hasCoSensor() const { return (m_capabilities & DEVICE_CO); }
    bool hasCo2Sensor() const { return (m_capabilities & DEVICE_CO2); }
    bool hasVocSensor() const { return (m_capabilities & DEVICE_VOC); }
    bool hasPM25Sensor() const { return (m_capabilities & DEVICE_PM25); }
    bool hasPM10Sensor() const { return (m_capabilities & DEVICE_PM10); }
    bool hasGeigerCounter() const { return (m_capabilities & DEVICE_GEIGER); }

    int getStatus() const { return m_status; }
    bool isUpdating() const { return m_updating; } //!< Is currently being updated
    bool isErrored() const;     //!< Has emitted a BLE error
    bool isFresh() const;       //!< Has at least >Xh (user set) old data
    bool isAvailable() const;   //!< Has at least >12h old data

    // BLE device infos
    bool isFirmwareUpToDate() const { return m_firmware_uptodate; }
    QString getFirmware() const { return m_firmware; }
    int getBattery() const { return m_battery; }

    // BLE device data
    int getHumidity() const { return m_hygro; }
    int getLuminosity() const { return m_luminosity; }
    int getConductivity() const { return m_conductivity; }
    float getTemp() const;
    float getTempC() const { return m_temp; }
    float getTempF() const { return (m_temp * 9.f/5.f + 32.f); }
    QString getTempString() const;

    QString getLastUpdateString() const;
    int getLastUpdateInt() const;
    int getLastErrorInt() const;

    bool hasData() const;
    bool hasData(const QString &dataName) const;
    int countData(const QString &dataName, int days = 31) const;

    // BLE device associated data
    QString getLocationName() { return m_locationName; }
    void setLocationName(const QString &name);

    QString getPlantName() { return m_plantName; }
    void setPlantName(const QString &name);

    int getHygroMin() const { return m_hygroMin; }
    int getHygroMax() const { return m_hygroMax; }
    float getTempMin() const { return m_tempMin; }
    float getTempMax() const { return m_tempMax; }
    int getLumiMin() const { return m_luminosityMin; }
    int getLumiMax() const { return m_luminosityMax; }
    int getConduMin() const { return m_conductivityMin; }
    int getConduMax() const { return m_conductivityMax; }

    // BLE device limits
    int getLimitHygroMin() const { return m_limitHygroMin; }
    int getLimitHygroMax() const { return m_limitHygroMax; }
    int getLimitTempMin() const { return m_limitTempMin; }
    int getLimitTempMax() const { return m_limitTempMax; }
    int getLimitLumiMin() const { return m_limitLumiMin; }
    int getLimitLumiMax() const { return m_limitLumiMax; }
    int getLimitConduMin() const { return m_limitConduMin; }
    int getLimitConduMax() const { return m_limitConduMax; }
    void setLimitHygroMin(int limitHygroMin) { if (m_limitHygroMin == limitHygroMin) return; m_limitHygroMin = limitHygroMin; setDbLimits(); }
    void setLimitHygroMax(int limitHygroMax) { if (m_limitHygroMax == limitHygroMax) return; m_limitHygroMax = limitHygroMax; setDbLimits(); }
    void setLimitTempMin(int limitTempMin) { if (m_limitTempMin == limitTempMin) return; m_limitTempMin = limitTempMin; setDbLimits(); }
    void setLimitTempMax(int limitTempMax) { if (m_limitTempMax == limitTempMax) return; m_limitTempMax = limitTempMax; setDbLimits(); }
    void setLimitLumiMin(int limitLumiMin) { if (m_limitLumiMin == limitLumiMin) return; m_limitLumiMin = limitLumiMin; setDbLimits(); }
    void setLimitLumiMax(int limitLumiMax) { if (m_limitLumiMax == limitLumiMax) return; m_limitLumiMax = limitLumiMax; setDbLimits(); }
    void setLimitConduMin(int limitConduMin) { if (m_limitConduMin == limitConduMin) return; m_limitConduMin = limitConduMin; setDbLimits(); }
    void setLimitConduMax(int limitConduMax) { if (m_limitConduMax == limitConduMax) return; m_limitConduMax = limitConduMax; setDbLimits(); }
    bool setDbLimits();

    // AIO temperature "min max" graph
    void updateAioMinMaxData(int maxDays);
    QVariant getAioMinMaxData() const { return QVariant::fromValue(m_aio_minmax_data); }

    // AIO line graph
    void getAioLinesData(int maxDays, QtCharts::QDateTimeAxis *axis,
                         QtCharts::QLineSeries *hygro, QtCharts::QLineSeries *temp,
                         QtCharts::QLineSeries *lumi, QtCharts::QLineSeries *cond);

    // Histograms (days)
    QVariantList getDataDays(const QString &dataName, int maxDays);
    QVariantList getBackgroundDays(float maxValue, int maxDays);
    QVariantList getLegendDays(int maxDays);

    // Histograms (hours)
    QVariantList getDataHours(const QString &dataName);
    QVariantList getBackgroundDaytime(float maxValue);
    QVariantList getBackgroundNighttime(float maxValue);
    QVariantList getLegendHours();
};

/* ************************************************************************** */
#endif // DEVICE_H
