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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DatabaseManager.h"

#include <QDir>
#include <QFile>
#include <QString>
#include <QStandardPaths>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

#define CURRENT_DB_VERSION 2

/* ************************************************************************** */

DatabaseManager *DatabaseManager::instance = nullptr;

DatabaseManager *DatabaseManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new DatabaseManager();
    }

    return instance;
}

DatabaseManager::DatabaseManager()
{
    openDatabase();
}

DatabaseManager::~DatabaseManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::openDatabase()
{
    if (QSqlDatabase::isDriverAvailable("QSQLITE"))
    {
        m_dbAvailable = true;

        if (m_dbOpen)
        {
            closeDatabase();
        }

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
                    m_dbOpen = true;
                }
                else
                {
                    if (dbFile.open())
                    {
                        m_dbOpen = true;

                        // Migrations //////////////////////////////////////////

                        // must be done before the creation, so we migrate old data tables
                        // instead of creating new empty tables

                        migrateDatabase();

                        // Check if our tables exists //////////////////////////

                        createDatabase();

                        // Delete everything 90+ days old ///////////////////////

                        // DATETIME: YYY-MM-JJ HH:MM:SS
                        QSqlQuery sanitizeData;
                        sanitizeData.prepare("DELETE FROM plantData WHERE ts < DATE('now', '-90 days')");

                        if (sanitizeData.exec() == false)
                            qWarning() << "> sanitizeData.exec() ERROR" << sanitizeData.lastError().type() << ":" << sanitizeData.lastError().text();
                    }
                    else
                    {
                        qWarning() << "Cannot open database... Error:" << dbFile.lastError();
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
    else
    {
        qWarning() << "> SQLite is NOT available";
        m_dbAvailable = false;
    }

    return m_dbOpen;
}

/* ************************************************************************** */

void DatabaseManager::closeDatabase()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (db.isValid())
    {
        QString conName = db.connectionName();

        // close db
        db.close();
        db = QSqlDatabase();
        QSqlDatabase::removeDatabase(conName);
        m_dbOpen = false;
    }
}

/* ************************************************************************** */

void DatabaseManager::resetDatabase()
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
        m_dbOpen = false;

        // remove db file
        QFile dbFile(dbName);
        dbFile.remove();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DatabaseManager::createDatabase()
{
    QSqlQuery checkVersion;
    checkVersion.exec("PRAGMA table_info(version);");
    if (!checkVersion.next())
    {
        qDebug() << "+ Adding 'version' table to local database";

        QSqlQuery createVersion;
        createVersion.prepare("CREATE TABLE version (dbVersion INT);");
        if (createVersion.exec())
        {
            QSqlQuery addVersion;
            addVersion.prepare("INSERT INTO version (dbVersion) VALUES (:dbVersion)");
            addVersion.bindValue(":dbVersion", CURRENT_DB_VERSION);
            addVersion.exec();
        }
        else
        {
            qWarning() << "> createVersion.exec() ERROR" << createVersion.lastError().type() << ":" << createVersion.lastError().text();
        }
    }

    QSqlQuery checkDevices;
    checkDevices.exec("PRAGMA table_info(devices);");
    if (!checkDevices.next())
    {
        qDebug() << "+ Adding 'devices' table to local database";

        QSqlQuery createDevices;
        createDevices.prepare("CREATE TABLE devices (" \
                              "deviceAddr CHAR(17) PRIMARY KEY," \
                              "deviceModel VARCHAR(255)," \
                              "deviceName VARCHAR(255)," \
                              "deviceFirmware VARCHAR(255)," \
                              "deviceBattery INT," \
                              "locationName VARCHAR(255)," \
                              "associatedName VARCHAR(255)," \
                              "isInside BOOLEAN," \
                              "settings VARCHAR(255)" \
                              ");");

        if (createDevices.exec() == false)
            qWarning() << "> createDevices.exec() ERROR" << createDevices.lastError().type() << ":" << createDevices.lastError().text();
    }

    QSqlQuery checkData;
    checkData.exec("PRAGMA table_info(plantData);");
    if (!checkData.next())
    {
        qDebug() << "+ Adding 'plantData' table to local database";

        QSqlQuery createData;
        createData.prepare("CREATE TABLE plantData (" \
                           "deviceAddr CHAR(17)," \
                           "ts DATETIME," \
                           "ts_full DATETIME," \
                             "soilMoisture INT," \
                             "soilConductivity INT," \
                             "soilTemperature FLOAT," \
                             "soilPH FLOAT," \
                             "temperature FLOAT," \
                             "humidity FLOAT," \
                             "luminosity INT," \
                           " PRIMARY KEY(deviceAddr, ts) " \
                           " FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE CASCADE ON UPDATE NO ACTION " \
                           ");");

        if (createData.exec() == false)
            qWarning() << "> createData.exec() ERROR" << createData.lastError().type() << ":" << createData.lastError().text();
    }

    QSqlQuery checkLimits;
    checkLimits.exec("PRAGMA table_info(plantLimits);");
    if (!checkLimits.next())
    {
        qDebug() << "+ Adding 'plantLimits' table to local database";
        QSqlQuery createLimits;
        createLimits.prepare("CREATE TABLE plantLimits (" \
                             "deviceAddr CHAR(17)," \
                               "hygroMin INT," \
                               "hygroMax INT," \
                               "conduMin INT," \
                               "conduMax INT," \
                               "phMin FLOAT," \
                               "phMax FLOAT," \
                               "tempMin INT," \
                               "tempMax INT," \
                               "humiMin INT," \
                               "humiMax INT," \
                               "luxMin INT," \
                               "luxMax INT," \
                               "mmolMin INT," \
                               "mmolMax INT," \
                             " PRIMARY KEY(deviceAddr) " \
                             " FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE CASCADE ON UPDATE NO ACTION " \
                             ");");

        if (createLimits.exec() == false)
            qWarning() << "> createLimits.exec() ERROR" << createLimits.lastError().type() << ":" << createLimits.lastError().text();
    }

    QSqlQuery checkSensorData;
    checkSensorData.exec("PRAGMA table_info(sensorData);");
    if (!checkSensorData.next())
    {
        qDebug() << "+ Adding 'sensorData' table to local database";
        QSqlQuery createSensorData;
        createSensorData.prepare("CREATE TABLE sensorData (" \
                                 "deviceAddr CHAR(17)," \
                                   "temperature FLOAT," \
                                   "humidity FLOAT," \
                                   "pression FLOAT," \
                                   "luminosity INT," \
                                   "uv INT," \
                                   "sound FLOAT," \
                                   "pm1 INT," \
                                   "pm25 INT," \
                                   "pm10 INT," \
                                   "o2 INT," \
                                   "o3 INT," \
                                   "co INT," \
                                   "co2 INT," \
                                   "no2 INT," \
                                   "voc INT," \
                                   "geiger FLOAT," \
                                 " PRIMARY KEY(deviceAddr) " \
                                 " FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE CASCADE ON UPDATE NO ACTION " \
                                 ");");

        if (createSensorData.exec() == false)
            qWarning() << "> createSensorData.exec() ERROR" << createSensorData.lastError().type() << ":" << createSensorData.lastError().text();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DatabaseManager::migrateDatabase()
{
    int dbVersion = 0;

    QSqlQuery readVersion;
    readVersion.prepare("SELECT dbVersion FROM version");
    readVersion.exec();
    if (readVersion.next())
    {
        dbVersion = readVersion.value(0).toInt();
        //qDebug() << "dbVersion is #" << dbVersion;
    }

    if (dbVersion > 0 && dbVersion != CURRENT_DB_VERSION)
    {
        bool migration_status = false;

        if (dbVersion == 1) migration_status = migrate_v1v2();

        // Then update version
        if (migration_status)
        {
            QSqlQuery updateDbVersion;
            updateDbVersion.prepare("UPDATE version SET dbVersion=:dbVersion");
            updateDbVersion.bindValue(":dbVersion", CURRENT_DB_VERSION);
            if (updateDbVersion.exec() == false)
                qWarning() << "> updateDbVersion.exec() ERROR" << updateDbVersion.lastError().type() << ":" << updateDbVersion.lastError().text();
        }
    }
}

/* ************************************************************************** */

bool DatabaseManager::migrate_v1v2()
{
    qWarning() << "DatabaseManager::migrate_v1v2()";

    QSqlQuery qmDev1("ALTER TABLE devices ADD deviceModel VARCHAR(255)");
    QSqlQuery qmDev2("ALTER TABLE devices RENAME COLUMN plantName TO associatedName");
    QSqlQuery qmDev3("ALTER TABLE devices ADD isInside BOOLEAN");
    QSqlQuery qmDev4("ALTER TABLE devices ADD settings VARCHAR(255)");

    QSqlQuery qmDat1("ALTER TABLE datas RENAME TO plantData");
    QSqlQuery qmDat2("ALTER TABLE plantData RENAME COLUMN hygro TO soilMoisture");
    QSqlQuery qmDat3("ALTER TABLE plantData RENAME COLUMN conductivity TO soilConductivity");
    QSqlQuery qmDat4("ALTER TABLE plantData RENAME COLUMN temp TO temperature");
    QSqlQuery qmDat5("ALTER TABLE plantData ADD soilTemperature FLOAT");
    QSqlQuery qmDat6("ALTER TABLE plantData ADD soilPH FLOAT");
    QSqlQuery qmDat7("ALTER TABLE plantData ADD humidity FLOAT");

    QSqlQuery qmLim1("ALTER TABLE limits RENAME TO plantLimits");
    QSqlQuery qmLim2("ALTER TABLE plantLimits RENAME COLUMN lumiMin TO luxMin");
    QSqlQuery qmLim3("ALTER TABLE plantLimits RENAME COLUMN lumiMax TO luxMax");
    QSqlQuery qmLim4("ALTER TABLE plantLimits ADD phMin FLOAT");
    QSqlQuery qmLim5("ALTER TABLE plantLimits ADD phMax FLOAT");
    QSqlQuery qmLim6("ALTER TABLE plantLimits ADD humiMin INT");
    QSqlQuery qmLim7("ALTER TABLE plantLimits ADD humiMax INT");
    QSqlQuery qmLim8("ALTER TABLE plantLimits ADD mmolMin INT");
    QSqlQuery qmLim9("ALTER TABLE plantLimits ADD mmolMax INT");

    return true;
}

/* ************************************************************************** */
