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
    Q_PROPERTY(QString deviceCustomName READ getCustomName NOTIFY datasUpdated)
    Q_PROPERTY(QString devicePlantName READ getPlantName NOTIFY datasUpdated)

    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY datasUpdated)
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

    QString m_deviceName;
    QString m_deviceAddress;
    QBluetoothDeviceInfo bleDevice;

    bool m_available = false;
    bool m_updating = false;
    QDateTime m_lastUpdate;
    QTimer m_updateTimer;

    // ble device datas
    QString m_firmware = "UNKN";
    int m_battery = -1;
    float m_temp = -1;
    int m_hygro = -1;
    int m_luminosity = -1;
    int m_conductivity = -1;

    // ble associated datas
    QString m_customName;
    QString m_plantName;

    // ble device limits
    int m_limitHygroMin = 15;
    int m_limitHygroMax = 30;
    int m_limitTempMin = 15;
    int m_limitTempMax = 30;
    int m_limitLumiMin = 500;
    int m_limitLumiMax = 10000;
    int m_limitConduMin = 250;
    int m_limitConduMax = 750;

public:
    Device(QString &deviceAddr, QString &deviceName);
    Device(const QBluetoothDeviceInfo &d);
    ~Device();

public slots:
    bool refreshDatas();
    void refreshDatasStarted();
    void refreshDatasFinished(bool status);

    void setTimerInterval(int updateIntervalMin = 0);

    bool getSqlDatas();
    bool getSqlCachedDatas();
    bool getBleDatas();

    // ble device
    QString getName() const { return m_deviceName; }
    QString getMacAddress() const { return m_deviceAddress; }

    bool isAvailable() const { return m_available; }
    bool isUpdating() const { return m_updating; }

    // ble device datas
    QString getFirmware() const { return m_firmware; }
    int getBattery() const { return m_battery; }
    float getTemp() const;
    int getHygro() const { return m_hygro; }
    int getLuminosity() const { return m_luminosity; }
    int getConductivity() const { return m_conductivity; }

    QString getTempString() const;
    QString getDataString() const;
    QString getLastUpdateString() const;

    // ble device associated datas
    QString getCustomName() { return m_customName; }
    void setCustomName(QString name);

    QString getPlantName() { return m_plantName; }
    void setPlantName(QString name);

    // ble device limits
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
    QVariantList getBackgroundHourly();
    QVariantList getBackgroundNightly();

Q_SIGNALS:
    void statusUpdated();
    void datasUpdated();
    void limitsUpdated();

private:
    // QLowEnergyController realted
    QLowEnergyController *controller = nullptr;
    bool hasControllerError() const;

    float getTempC() const { return m_temp; }
    float getTempF() const { return (m_temp * 9.f/5.f + 32.f); }

    void deviceConnected();
    void deviceDisconnected();
    void errorReceived(QLowEnergyController::Error);
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceData = nullptr;

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
};

#endif // DEVICE_H
