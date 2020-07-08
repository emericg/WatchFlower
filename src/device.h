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

#define LATEST_KNOWN_FIRMWARE_FLOWERCARE        "3.2.2"
#define LATEST_KNOWN_FIRMWARE_ROPOT             "1.1.5"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_LCD     "00.00.66"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK    "1.1.2_0007"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK   "1.1.2_0019"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP_SQUARE  "1.0.0_0106"

/* ************************************************************************** */

enum DeviceCapabilities {
    DEVICE_BATTERY           = (1 << 0), //!< Can report its battery level

    DEVICE_TEMPERATURE       = (1 << 1), //!< Has a temperature sensor
    DEVICE_HUMIDITY          = (1 << 2), //!< Has an humidity sensor
    DEVICE_LUMINOSITY        = (1 << 3), //!< Has a luminosity sensor
    DEVICE_SOIL_MOISTURE     = (1 << 4), //!< Has a soil moisture sensor (can be associated to a plant)
    DEVICE_SOIL_CONDUCTIVITY = (1 << 5), //!< Has a conductivity/fertility sensor

    DEVICE_CLOCK             = (1 << 6), //!< Has an onboard clock
    DEVICE_LED               = (1 << 7), //!< Has a blinkable LED
    DEVICE_HISTORY           = (1 << 8), //!< Record sensor history
};

enum DeviceStatus {
    DEVICE_OFFLINE           = 0, //!< Not connected
    DEVICE_QUEUED            = 1, //!< In the update queue, not started
    DEVICE_CONNECTING        = 2, //!< Update started, trying to connect to the device
    DEVICE_UPDATING          = 3, //!< Connected, data update in progress
    DEVICE_UPDATING_HISTORY  = 4, //!< Connected, history update in progress
    DEVICE_ACTION            = 5, //!< Connected, doing something
    DEVICE_UPDATED           = 6, //!< Updated, waiting for disconnect
};

/* ************************************************************************** */

class DeviceNear: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ getName NOTIFY updated)
    Q_PROPERTY(QString addr READ getAddr NOTIFY updated)
    Q_PROPERTY(int rssi READ getRssi NOTIFY updated)

signals:
    void updated();

public:
    DeviceNear(const QString &n, const QString &a, int r,
               QObject *parent) : QObject(parent)
    {
        name = n; addr = a; rssi = r;
    }

    QString name;
    QString addr;
    int rssi;

public slots:
    QString getName() { return name; }
    QString getAddr() { return addr; }
    int getRssi() { return rssi; }
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

    Q_PROPERTY(QString deviceName READ getName NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddress READ getAddress NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceLocationName READ getLocationName NOTIFY sensorUpdated)
    Q_PROPERTY(QString devicePlantName READ getPlantName NOTIFY sensorUpdated)

    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY sensorUpdated)
    Q_PROPERTY(bool deviceFirmwareUpToDate READ isFirmwareUpToDate NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceBattery READ getBattery NOTIFY sensorUpdated)

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

    Q_PROPERTY(int limitHygroMin READ getLimitHygroMin WRITE setLimitHygroMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHygroMax READ getLimitHygroMax WRITE setLimitHygroMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMin READ getLimitTempMin WRITE setLimitTempMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMax READ getLimitTempMax WRITE setLimitTempMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMin READ getLimitLumiMin WRITE setLimitLumiMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMax READ getLimitLumiMax WRITE setLimitLumiMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMin READ getLimitConduMin WRITE setLimitConduMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMax READ getLimitConduMax WRITE setLimitConduMax NOTIFY limitsUpdated)

    Q_PROPERTY(QVariant aioMinMaxData READ getAioMinMaxData NOTIFY aioMinMaxDataUpdated)

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

    int m_capabilities = 0;     //!< See DeviceCapabilities enum

    int m_status = 0;           //!< See DeviceStatus enum
    bool m_updating = false;    //!< Shortcut, if m_status == 2 or 3

    int m_ble_action = 0; // 0: update data, 1: update history, 2: led

    QDateTime m_lastUpdate;
    QDateTime m_lastError;

    QTimer m_updateTimer;
    QTimer m_timeoutTimer;

    // BLE device infos
    QString m_firmware = "UNKN";
    bool m_firmware_uptodate = false;
    int m_battery = -1;

    // BLE device data
    float m_temp = -99.f;
    int m_hygro = -99;
    int m_luminosity = -99;
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

    // BLE
    int m_timeout = 15;
    int m_update_interval = 0;

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

    bool hasBatteryLevel() const { return (m_capabilities & DEVICE_BATTERY); }
    bool hasClock() const { return (m_capabilities & DEVICE_CLOCK); }
    bool hasLED() const { return (m_capabilities & DEVICE_LED); }
    bool hasHistory() const { return (m_capabilities & DEVICE_HISTORY); }
    bool hasTemperatureSensor() const { return (m_capabilities & DEVICE_TEMPERATURE); }
    bool hasHumiditySensor() const { return (m_capabilities & DEVICE_HUMIDITY); }
    bool hasLuminositySensor() const { return (m_capabilities & DEVICE_LUMINOSITY); }
    bool hasSoilMoistureSensor() const { return (m_capabilities & DEVICE_SOIL_MOISTURE); }
    bool hasConductivitySensor() const { return (m_capabilities & DEVICE_SOIL_CONDUCTIVITY); }

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
