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

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

class Device: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString deviceName READ getName NOTIFY datasUpdated)
    Q_PROPERTY(QString deviceAddress READ getMacAddress NOTIFY datasUpdated)

    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY datasUpdated)
    Q_PROPERTY(int deviceBattery READ getBattery NOTIFY datasUpdated)
    Q_PROPERTY(float deviceTemp READ getTemp NOTIFY datasUpdated)
    Q_PROPERTY(int deviceHygro READ getHygro NOTIFY datasUpdated)
    Q_PROPERTY(int deviceLuminosity READ getLuminosity NOTIFY datasUpdated)
    Q_PROPERTY(int deviceConductivity READ getConductivity NOTIFY datasUpdated)

    Q_PROPERTY(QString dataString READ getDataString() NOTIFY datasUpdated)

    Q_PROPERTY(QString deviceCustomName READ getCustomName NOTIFY datasUpdated)
    Q_PROPERTY(QString devicePlantName READ getPlantName NOTIFY datasUpdated)

    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)

public:
    Device();
    Device(QString &deviceAddr, QString &deviceName);
    Device(const QBluetoothDeviceInfo &d);
    ~Device();

public slots:
    bool refreshDatas();
    void refreshDatasStarted();
    bool getSqlDatas();
    bool getBleDatas();
    void refreshDatasFinished();

    // bt device
    QString getName() const { return m_deviceName; }
    QString getMacAddress() const { return m_deviceAddress; }

    bool isAvailable() const { return m_available; }
    bool isUpdating() const { return m_updating; }

    // bt device datas
    QString getFirmware() const { return m_firmware; }
    int getBattery() const { return m_battery; }
    float getTemp() const { return m_temp; }
    int getHygro() const { return m_hygro; }
    int getLuminosity() const { return m_luminosity; }
    int getConductivity() const { return m_conductivity; }

    QString getDataString() const;

    // associated datas
    QString getCustomName() { return m_customName; }
    void setCustomName(QString name);

    QString getPlantName() { return m_plantName; }
    void setPlantName(QString name);

    // limits
    float getTempLimits() const { return 0; }
    void setTempLimits() { return; }
    int getHygroLimits() { return 0; }
    int getLuminosityLimits() { return 0; }
    int getConductivityLimits() { return 0; }

    // Daily graph
    QVariantList getDays();
    QVariantList getDatasDaily(QString dataName);

    // Hourly graph
    QVariantList getHours();
    QVariantList getDatasHourly(QString dataName);

Q_SIGNALS:
    void statusUpdated();
    void datasUpdated();

private:
    // QLowEnergyController realted
    QLowEnergyController *controller = nullptr;
    bool hasControllerError() const;

    void deviceConnected();
    void deviceDisconnected();
    void disconnectFromDevice();
    void errorReceived(QLowEnergyController::Error);
    void serviceScanDone();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    QLowEnergyService *serviceData = nullptr;

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);

private:
    QString m_deviceName;
    QString m_deviceAddress;
    QBluetoothDeviceInfo bleDevice;

    bool m_available = false;
    bool m_updating = false;
    QTimer updateTimer;

    // bt device datas
    QString m_firmware = "UNKN";
    int m_battery = -1;
    float m_temp = -1;
    int m_hygro = -1;
    int m_luminosity = -1;
    int m_conductivity = -1;

    // associated datas
    QString m_customName;
    QString m_plantName;

    // TODO limits
};

#endif // DEVICE_H
