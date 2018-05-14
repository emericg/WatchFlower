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

#include "settingsmanager.h"

#include <QStandardPaths>
#include <QSettings>
#include <QDir>
#include <QDebug>

#include <QSqlQuery>
#include <QSqlError>

/* ************************************************************************** */

SettingsManager::SettingsManager()
{
    readSettings();
    loadDatabase();
}

SettingsManager::~SettingsManager()
{
    //
}

/* ************************************************************************** */

bool SettingsManager::readSettings()
{
    bool status = false;

    QSettings settings("WatchFlower", "WatchFlower");
    settings.sync();

    if (settings.status() == QSettings::NoError)
    {
        if (settings.contains("settings/trayEnabled"))
            m_trayEnabled = settings.value("settings/trayEnabled").toBool();

        if (settings.contains("settings/updateInterval"))
            m_updateInterval = settings.value("settings/updateInterval").toUInt();

        if (settings.contains("settings/degreUnit"))
            m_tempUnit = settings.value("settings/degreUnit").toString();

        status = true;
    }
    else
    {
        qDebug() << "QSettings READ error:" << settings.status();
    }

    return status;
}

bool SettingsManager::writeSettings()
{
    bool status = false;

    QSettings settings("WatchFlower", "WatchFlower");

    if (settings.isWritable())
    {
        settings.setValue("settings/trayEnabled", m_trayEnabled);
        settings.setValue("settings/updateInterval", m_updateInterval);
        settings.setValue("settings/degreUnit", m_tempUnit);
        settings.sync();

        if (settings.status() == QSettings::NoError)
        {
            status = true;
        }
        else
        {
            qDebug() << "QSettings WRITE error:" << settings.status();
        }
    }

    return status;
}

/* ************************************************************************** */

bool SettingsManager::loadDatabase()
{
    if (m_db)
    {
        closeDatabase();
    }

    if (QSqlDatabase::isDriverAvailable("QSQLITE"))
    {
        QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

        if (dbPath.isEmpty() == false)
        {
            QDir dbDirectory(dbPath);
            if (dbDirectory.exists() == false)
            {
                if (dbDirectory.mkpath(dbPath) == false)
                    qWarning() << "Cannot create dbDirectory...";
            }

            if (dbDirectory.exists())
            {
                dbPath += "/datas.db";

                QSqlDatabase dbFile(QSqlDatabase::addDatabase("QSQLITE"));
                dbFile.setDatabaseName(dbPath);

                if (dbFile.isOpen())
                {
                    m_db = true;
                }
                else
                {
                    if (dbFile.open())
                    {
                        m_db = true;

                        // Check if our tables exists //////////////////////////

                        QSqlQuery checkDevices;
                        checkDevices.exec("PRAGMA table_info(devices);");
                        if (!checkDevices.next())
                        {
                            qDebug() << "+ Adding 'devices' table to local database";

                            QSqlQuery createDevices;
                            createDevices.prepare("CREATE TABLE devices (" \
                                                    "deviceAddr CHAR(17) PRIMARY KEY," \
                                                    "deviceName VARCHAR(255),"  \
                                                    "deviceFirmware VARCHAR(255),"  \
                                                    "deviceBattery INT," \
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
                                                "ts_full DATETIME," \
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

                        // Delete everything 7+ days old ///////////////////////
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

    return m_db;
}

void SettingsManager::closeDatabase()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (db.isValid())
    {
        QString conName = db.connectionName();

        // close db
        db.close();
        db = QSqlDatabase();
        QSqlDatabase::removeDatabase(conName);
        m_db = false;
    }
}

void SettingsManager::resetDatabase()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (db.isValid())
    {
        QString dbName = db.databaseName();
        QString conName = db.connectionName();

        // close db
        db.close();
        db = QSqlDatabase();
        QSqlDatabase::removeDatabase(conName);
        m_db = false;

        // remove db file
        QFile dbFile(dbName);
        dbFile.remove();
    }
}

/* ************************************************************************** */

void SettingsManager::reset()
{
    // Settings
    m_trayEnabled = false;
    emit systrayChanged();
    m_updateInterval = UPDATE_INTERVAL;
    emit intervalChanged();
    m_tempUnit = "C";
    emit tempunitChanged();

    // Database
    resetDatabase();
    loadDatabase();
}

/* ************************************************************************** */

bool SettingsManager::readDevices()
{
    return false;
}

/* ************************************************************************** */
