/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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

#include <QObject>
#include <QList>
#include <QTimer>
#include <QDateTime>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

#define LATEST_KNOWN_FIRMWARE_FLOWERCARE    "3.1.8"
#define LATEST_KNOWN_FIRMWARE_ROPOT         "0.0.0"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP     "00.00.66"

enum DeviceCapabilities {
    DEVICE_BATTERY      = (1 << 0), //!< Can report its battery level
    DEVICE_TEMP         = (1 << 1), //!< Has a temperature sensor
    DEVICE_HYGRO        = (1 << 2), //!< Has a hygrometry sensor
    DEVICE_LUMINOSITY   = (1 << 3), //!< Has a luminosity sensor
    DEVICE_CONDUCTIVITY = (1 << 4), //!< Has a conductivity sensor

    DEVICE_LIMITS       = (1 << 5), //!< Can use limits
    DEVICE_PLANT        = (1 << 6), //!< Is associated to a plant
};

/*!
 * \brief The Device class
 */
class Device: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool available READ isAvailable NOTIFY statusUpdated)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)
    Q_PROPERTY(QString lastUpdate READ getLastUpdateString NOTIFY statusUpdated)

    Q_PROPERTY(QString deviceName READ getName NOTIFY datasUpdated)
    Q_PROPERTY(QString deviceAddress READ getMacAddress NOTIFY datasUpdated)
    Q_PROPERTY(QString deviceLocationName READ getLocationName NOTIFY datasUpdated)
    Q_PROPERTY(QString devicePlantName READ getPlantName NOTIFY datasUpdated)

    Q_PROPERTY(int deviceCapabilities READ getCapabilities NOTIFY datasUpdated)

    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY datasUpdated)
    Q_PROPERTY(bool deviceFirmwareUpToDate READ isFirmwareUpToDate NOTIFY datasUpdated)
    Q_PROPERTY(int deviceBattery READ getBattery NOTIFY datasUpdated)
    Q_PROPERTY(float deviceTempC READ getTempC NOTIFY datasUpdated)
    Q_PROPERTY(int deviceHygro READ getHygro NOTIFY datasUpdated)
    Q_PROPERTY(int deviceLuminosity READ getLuminosity NOTIFY datasUpdated)
    Q_PROPERTY(int deviceConductivity READ getConductivity NOTIFY datasUpdated)
    Q_PROPERTY(QString dataString READ getDataString() NOTIFY datasUpdated)

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
    void datasUpdated();
    void limitsUpdated();

protected:
    QString m_deviceName;
    QString m_deviceAddress;
    QBluetoothDeviceInfo bleDevice;

    int m_capabilities = 0;

    bool m_available = false;
    bool m_updating = false;
    QDateTime m_lastUpdate;
    QTimer m_updateTimer;

    // BLE device infos
    QString m_firmware = "UNKN";
    bool m_firmware_uptodate = false;
    int m_battery = -1;

    // BLE device datas
    float m_temp = -1;
    int m_hygro = -1;
    int m_luminosity = -1;
    int m_conductivity = -1;

    // BLE associated datas
    QString m_locationName;
    QString m_plantName;

    // BLE device limits
    int m_limitHygroMin = 15;
    int m_limitHygroMax = 30;
    int m_limitTempMin = 15;
    int m_limitTempMax = 30;
    int m_limitLumiMin = 500;
    int m_limitLumiMax = 10000;
    int m_limitConduMin = 250;
    int m_limitConduMax = 750;

    // QLowEnergyController related
    QLowEnergyController *controller = nullptr;
    bool hasControllerError() const;

    float getTempC() const { return m_temp; }
    float getTempF() const { return (m_temp * 9.f/5.f + 32.f); }

    void deviceConnected();
    void deviceDisconnected();
    void errorReceived(QLowEnergyController::Error);
    virtual void serviceScanDone();
    virtual void addLowEnergyService(const QBluetoothUuid &uuid);
    virtual void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    virtual void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);

public:
    Device(QString &deviceAddr, QString &deviceName);
    Device(const QBluetoothDeviceInfo &d);
    virtual ~Device();

public slots:
    bool refreshDatas();
    void refreshDatasStarted();
    void refreshDatasFinished(bool status, bool cached = false);

    void setTimerInterval(int updateIntervalMin = 0);

    bool getSqlDatas();
    bool getSqlCachedDatas();
    bool getBleDatas();

    // BLE device
    QString getName() const { return m_deviceName; }
    QString getMacAddress() const { return m_deviceAddress; }

    int getCapabilities() const { return m_capabilities; }

    bool isAvailable() const { return m_available; }
    bool isUpdating() const { return m_updating; }

    // BLE device infos
    QString getFirmware() const { return m_firmware; }
    bool isFirmwareUpToDate() const { return m_firmware_uptodate; }
    int getBattery() const { return m_battery; }

    // BLE device datas
    float getTemp() const;
    int getHygro() const { return m_hygro; }
    int getLuminosity() const { return m_luminosity; }
    int getConductivity() const { return m_conductivity; }

    QString getTempString() const;
    virtual QString getDataString() const;
    QString getLastUpdateString() const;

    // BLE device associated datas
    QString getLocationName() { return m_locationName; }
    void setLocationName(QString name);

    QString getPlantName() { return m_plantName; }
    void setPlantName(QString name);

    // BLE device limits
    int getLimitHygroMin() const { return m_limitHygroMin; }
    int getLimitHygroMax() const { return m_limitHygroMax; }
    int getLimitTempMin() const { return m_limitTempMin; }
    int getLimitTempMax() const { return m_limitTempMax; }
    int getLimitLumiMin() const { return m_limitLumiMin; }
    int getLimitLumiMax() const { return m_limitLumiMax; }
    int getLimitConduMin() const { return m_limitConduMin; }
    int getLimitConduMax() const { return m_limitConduMax; }
    void setLimitHygroMin(int limitHygroMin) { m_limitHygroMin = limitHygroMin; setDbLimits(); }
    void setLimitHygroMax(int limitHygroMax) { m_limitHygroMax = limitHygroMax; setDbLimits(); }
    void setLimitTempMin(int limitTempMin) { m_limitTempMin = limitTempMin; setDbLimits(); }
    void setLimitTempMax(int limitTempMax) { m_limitTempMax = limitTempMax; setDbLimits(); }
    void setLimitLumiMin(int limitLumiMin) { m_limitLumiMin = limitLumiMin; setDbLimits(); }
    void setLimitLumiMax(int limitLumiMax) { m_limitLumiMax = limitLumiMax; setDbLimits(); }
    void setLimitConduMin(int limitConduMin) { m_limitConduMin = limitConduMin; setDbLimits(); }
    void setLimitConduMax(int limitConduMax) { m_limitConduMax = limitConduMax; setDbLimits(); }
    bool setDbLimits();

    // Daily graph
    QVariantList getDays();
    QVariantList getDatasDaily(QString dataName);

    // Hourly graph
    QVariantList getHours();
    QVariantList getDatasHourly(QString dataName);
    QVariantList getBackgroundHourly(float maxValue);
    QVariantList getBackgroundNightly(float maxValue);
    QVariantList getBackgroundDaily(float maxValue);
};

struct Version
{
    int major = 0, minor = 0, revision = 0, build = 0;

    Version(QString version_qstr)
    {
        sscanf(version_qstr.toLatin1().constData(), "%d.%d.%d.%d",
               &major, &minor, &revision, &build);
    }

    bool operator == (const Version &other)
    {
        return (major == other.major
                && minor == other.minor
                && revision == other.revision
                && build == other.build);
    }
    bool operator < (const Version &other)
    {
/*
        qDebug() << "operator <";
        qDebug() << major << "." << minor << "." << revision << "." << build;
        qDebug() << other.major << "." << other.minor << "." << other.revision << "." << other.build;
*/
        if (major < other.major)
            return true;
        if (major > other.major)
            return false;
        if (minor < other.minor)
            return true;
        if (minor > other.minor)
            return false;
        if (revision < other.revision)
            return true;
        if (revision > other.revision)
            return false;
        if (build < other.build)
            return true;
        if (build > other.build)
            return false;

        return false;
    }
    bool operator <= (const Version &other)
    {
        if (*this < other || *this == other)
            return true;

        return false;
    }
    bool operator >= (const Version &other)
    {
        if (*this > other || *this == other)
            return true;

        return false;
    }
    bool operator > (const Version &other)
    {
        if (!(*this == other) && !(*this < other))
            return true;

        return false;
    }
};

#endif // DEVICE_H
