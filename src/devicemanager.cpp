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

#include "devicemanager.h"
#include "device.h"

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothServiceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>

#include <QStandardPaths>
#include <QList>
#include <QDir>
#include <QTimer>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

#include <iostream>

/* ************************************************************************** */

DeviceManager::DeviceManager()
{
    loadBluetooth();
    loadDatabase();

    // BLE discovery agent
    m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent();
    if (m_discoveryAgent)
    {
        m_discoveryAgent->setLowEnergyDiscoveryTimeout(5000);

        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, &DeviceManager::addBleDevice);
        connect(m_discoveryAgent, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::error), this, &DeviceManager::deviceDiscoveryError);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, &DeviceManager::deviceDiscoveryFinished);
    }
    else
    {
        qWarning() << "Unable to create BLE discovery agent...";
    }

    // Add static devices first?
    qDebug() << "Scanning (database) for devices...";
    if (m_db)
    {
        qDeleteAll(m_devices);
        m_devices.clear();

        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            QString deviceAddr = queryDevices.value(1).toString();

            qDebug() << "- device: " << deviceName << "/" << deviceAddr;

            Device *d = new Device(deviceAddr, deviceName);
            m_devices.append(d);
        }
    }
}

DeviceManager::~DeviceManager()
{
    delete m_discoveryAgent;

    qDeleteAll(m_devices);
    m_devices.clear();
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::loadBluetooth()
{
    // We check the "first" available BLE adapter only
    //QList<QBluetoothHostInfo> QBluetoothLocalDevice::allDevices()

    if (m_bluetoothAdapter.isValid())
    {
        // Make sure its powered on
        m_bluetoothAdapter.powerOn();

        // Keep us informed of availability changes
        connect(&m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged, this, &DeviceManager::changeBluetoothMode);

        // Check availability
        if (m_bluetoothAdapter.hostMode() > 0)
        {
            m_bt = true;
            qDebug() << "> Bluetooth available";
        }
        else
            qDebug() << "Bluetooth host mode:" << m_bluetoothAdapter.hostMode();
    }

    emit bluetoothChanged();
}

void DeviceManager::loadDatabase()
{
    if (QSqlDatabase::isDriverAvailable("QSQLITE"))
    {
        qDebug() << "> SQLite available";

        QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

        if (dbPath.isEmpty() == false)
        {
            QDir dbDirectory(dbPath);
            if (dbDirectory.exists() == false)
            {
                if (dbDirectory.mkpath(dbPath) == false)
                    qWarning() << "Cannot create dbDirectory...";
            }

            if (dbDirectory.exists() == true)
            {
                dbPath += "/datas.db";

                QSqlDatabase dbFile(QSqlDatabase::addDatabase("QSQLITE"));
                //db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
                dbFile.setDatabaseName(dbPath); // or use ":memory:"

                if (dbFile.open())
                {
                    m_db = true;

                    // Check if our tables exists //////////////////////////////

                    QSqlQuery checkDevices;
                    checkDevices.exec("PRAGMA table_info(devices);");
                    if (!checkDevices.next())
                    {
                        qDebug() << "+ Adding 'devices' table to local database";

                        QSqlQuery createDevices;
                        createDevices.prepare("CREATE TABLE devices (" \
                                                "deviceAddr CHAR(17) PRIMARY KEY," \
                                                "deviceName VARCHAR(255)," \
                                                "customName VARCHAR(255)," \
                                                "plantName VARCHAR(255)" \
                                                ");");

                        if (createDevices.exec() == false)
                            qDebug() << "> createDevices.exec() ERROR" << createDevices.lastError().type() << ":"  << createDevices.lastError().text();
                    }

                    QSqlQuery checkDatas;
                    checkDatas.exec("PRAGMA table_info(datas);");
                    if (!checkDatas.next())
                    {
                        qDebug() << "+ Adding 'datas' table to local database";

                        QSqlQuery createDatas;
                        createDatas.prepare("CREATE TABLE datas (" \
                                            "deviceAddr CHAR(17)," \
                                            "ts DATETIME," \
                                              "temp FLOAT," \
                                              "hygro INT," \
                                              "luminosity INT," \
                                              "conductivity INT," \
                                            " PRIMARY KEY(deviceAddr, ts) " \
                                            " FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE CASCADE ON UPDATE NO ACTION " \
                                            ");");

                        if (createDatas.exec() == false)
                            qDebug() << "> createDatas.exec() ERROR" << createDatas.lastError().type() << ":"  << createDatas.lastError().text();
                    }

                    // Delete everything 7+ days old ///////////////////////////
                    // DATETIME: YYY-MM-JJ HH:MM:SS

                    QSqlQuery sanitizeDatas;
                    sanitizeDatas.exec("DELETE FROM datas WHERE ts <  DATE('now', '-7 days')");

                    if (sanitizeDatas.exec() == false)
                        qDebug() << "> sanitizeDatas.exec() ERROR" << sanitizeDatas.lastError().type() << ":"  << sanitizeDatas.lastError().text();
                }
                else
                {
                    qWarning() << "Cannot open cache database... Error:" << dbFile.lastError();
                }
            }
            else
            {
                qWarning() << "Cannot create nor open dbDirectory...";
            }
        }
        else
        {
            qWarning() << "Cannot find QStandardPaths::AppDataLocation directory...";
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::changeBluetoothMode(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "Bluetooth host mode changed, now:" << state;

    if (state > 0)
    {
        m_bt = true;
        qDebug() << "> Bluetooth available";
    }
    else
        m_bt = false;

    emit bluetoothChanged();
}

bool DeviceManager::isScanning() const
{
    return m_scanning;
}

void DeviceManager::startDeviceDiscovery()
{
    qDeleteAll(m_devices);
    m_devices.clear();
    emit devicesUpdated();

    qDebug() << "Scanning (bluetooth) for devices...";

    m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
    if (m_discoveryAgent->isActive())
    {
        m_scanning = true;
        Q_EMIT scanningChanged();
    }
}

void DeviceManager::deviceDiscoveryFinished()
{
    qDebug() << "Scanning (database) for devices...";
    if (m_db)
    {
        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceName, deviceAddr FROM devices");
        while (queryDevices.next())
        {
            QString deviceName = queryDevices.value(0).toString();
            QString deviceAddr = queryDevices.value(1).toString();

            qDebug() << "- device: " << deviceName << "/" << deviceAddr;

            // device lookup
            bool found = false;
            for (auto d: m_devices)
            {
                Device *dd = qobject_cast<Device*>(d);
                if (dd->getMacAddress() == deviceAddr)
                {
                    found = true;
                    break;
                }
            }
            if (found == false)
            {
                Device *d = new Device(deviceAddr, deviceName);
                m_devices.append(d);
            }
        }
    }
/*
    for (auto d: devices)
    {
        DeviceInfo *dd = qobject_cast<DeviceInfo*>(d);
        dd->refreshDatas();
    }
*/
    m_scanning = false;

    emit devicesUpdated();
    emit scanningChanged();
}

void DeviceManager::deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
        qWarning() << "Writing or reading from the device resulted in an error.";
    else
        qWarning() << "An unknown error has occurred.";

    m_scanning = false;

    emit devicesUpdated();
    emit scanningChanged();
}

/* ************************************************************************** */

void DeviceManager::addBleDevice(const QBluetoothDeviceInfo &info)
{
    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)
    {
        if (info.name() == "Flower care" || info.name() == "Flower mate")
        {
            Device *d = new Device(info);
            m_devices.append(d);

            qDebug() << "Last device added: " << d->getName() << "/" << d->getMacAddress();

            // Also add it to the database?
            if (m_db)
            {
                // if
                QSqlQuery queryDevice;
                queryDevice.prepare("SELECT deviceName FROM devices WHERE deviceAddr = :deviceAddr");
                queryDevice.bindValue(":deviceAddr", d->getMacAddress());
                queryDevice.exec();

                // then
                if (queryDevice.last() == false)
                {
                    qDebug() << "+ Adding device: " << d->getName() << "/" << d->getMacAddress() << "to local database";

                    QSqlQuery addDevice;
                    addDevice.prepare("INSERT INTO devices (deviceAddr, deviceName, customName) VALUES (:deviceAddr, :deviceName, :customName)");
                    addDevice.bindValue(":deviceAddr", d->getMacAddress());
                    addDevice.bindValue(":deviceName", d->getName());
                    addDevice.bindValue(":customName", d->getName());
                    addDevice.exec();
                }
            }
        }
    }
}

bool DeviceManager::areDevicesAvailable() const
{
    if (m_devices.size() > 0)
        return true;
    else
        return false;
}

QVariant DeviceManager::getDevices() const
{
    return QVariant::fromValue(m_devices);
}

/* ************************************************************************** */

bool DeviceManager::hasBluetooth() const
{
    return m_bt;
}

bool DeviceManager::hasDatabase() const
{
    return m_db;
}
/*
QString DeviceManager::getMessage()
{
    return m_message;
}

void DeviceManager::setMessage(QString message)
{
    m_message = message;
    emit messageChanged();
}
*/
