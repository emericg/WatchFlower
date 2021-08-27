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
#include "SettingsManager.h"

#include <QDir>
#include <QFile>
#include <QString>
#include <QDateTime>
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
    openDatabase_sqlite();
    //openDatabase_mysql();
}

DatabaseManager::~DatabaseManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::openDatabase_sqlite()
{
    if (QSqlDatabase::isDriverAvailable("QSQLITE"))
    {
        m_dbInternalAvailable = true;

        if (m_dbInternalOpen)
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
                    m_dbInternalOpen = true;
                }
                else
                {
                    if (dbFile.open())
                    {
                        m_dbInternalOpen = true;

                        // Migrations //////////////////////////////////////////

                        // Must be done before the creation, so we migrate old data tables
                        // instead of creating new empty tables

                        migrateDatabase();

                        // Check if our tables exists //////////////////////////

                        createDatabase();

                        // Sanitize database ///////////////////////////////////

                        if (QDate::currentDate().year() >= 2021)
                        {
                            // DATETIME: YYY-MM-JJ HH:MM:SS

                            // Delete everything 90+ days old
                            QSqlQuery sanitizePlantDataPast;
                            sanitizePlantDataPast.prepare("DELETE FROM plantData WHERE ts < DATE('now', '-90 days')");
                            if (sanitizePlantDataPast.exec() == false)
                                qWarning() << "> sanitizeDataPast.exec() ERROR" << sanitizePlantDataPast.lastError().type() << ":" << sanitizePlantDataPast.lastError().text();

                            // Delete everything that's in the future
                            QSqlQuery sanitizePlantDataFuture;
                            sanitizePlantDataFuture.prepare("DELETE FROM plantData WHERE ts > DATE('now', '+1 days')");
                            if (sanitizePlantDataFuture.exec() == false)
                                qWarning() << "> sanitizeDataFuture.exec() ERROR" << sanitizePlantDataFuture.lastError().type() << ":" << sanitizePlantDataFuture.lastError().text();
                        }
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
        m_dbInternalAvailable = false;
    }

    return m_dbInternalOpen;
}

/* ************************************************************************** */

bool DatabaseManager::openDatabase_mysql()
{
    if (QSqlDatabase::isDriverAvailable("QMYSQL"))
    {
        m_dbExternalAvailable = true;

        if (m_dbExternalOpen)
        {
            closeDatabase();
        }

        SettingsManager *sm = SettingsManager::getInstance();

        if (sm->getExternalDb())
        {
            QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
            db.setHostName(sm->getExternalDbHost());
            db.setPort(sm->getExternalDbPort());
            db.setDatabaseName(sm->getExternalDbName());
            db.setUserName(sm->getExternalDbUser());
            db.setPassword(sm->getExternalDbPassword());

            if (db.isOpen())
            {
                m_dbExternalOpen = true;
            }
            else
            {
                if (db.open())
                {
                    m_dbExternalOpen = true;

                    // Migrations ///////////////////////////////////////////////////

                    // Must be done before the creation, so we migrate old data tables
                    // instead of creating new empty tables

                    migrateDatabase();

                    // Check if our tables exists //////////////////////////////////

                    createDatabase();

                    // Delete everything that's in the future //////////////////////

                    // TODO

                    // Sanitize database ///////////////////////////////////////////

                    // We don't sanetize MySQL databases
                }
                else
                {
                    qWarning() << "Cannot open database... Error:" << db.lastError();
                }
            }
        }
    }
    else
    {
        qWarning() << "> MySQL is NOT available";
        m_dbExternalAvailable = false;
    }

    return m_dbExternalOpen;
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

        m_dbInternalOpen = false;
        m_dbExternalOpen = false;
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

        m_dbInternalOpen = false;
        m_dbExternalOpen = false;

        // remove db file
        QFile dbFile(dbName);
        dbFile.remove();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::tableExists(const QString &tableName)
{
    bool result = false;

    if (tableName.isEmpty())
    {
        qWarning() << "tableExists() with empty table name!";
    }
    else
    {
        QSqlQuery checkTable;
        if (m_dbInternalOpen) // sqlite
        {
            checkTable.exec("PRAGMA table_info(" + tableName + ");");
        }
        else if (m_dbExternalOpen) // mysql
        {
            checkTable.exec("SELECT * FROM information_schema.tables WHERE table_schema = 'watchflower' AND table_name = '" + tableName + "' LIMIT 1;");
            //checkTable.exec("SELECT * FROM information_schema.TABLES WHERE TABLE_NAME = '" + tableName + "' AND TABLE_SCHEMA in (SELECT DATABASE());");
        }
        if (checkTable.next())
        {
            result = true;
        }
    }

    return result;
}

void DatabaseManager::createDatabase()
{
    if (!tableExists("version"))
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

    if (!tableExists("devices"))
    {
        qDebug() << "+ Adding 'devices' table to local database";

        QSqlQuery createDevices;
        createDevices.prepare("CREATE TABLE devices (" \
                              "deviceAddr CHAR(38) PRIMARY KEY," \
                              "deviceModel VARCHAR(255)," \
                              "deviceName VARCHAR(255)," \
                              "deviceFirmware VARCHAR(255)," \
                              "deviceBattery INT," \
                              "associatedName VARCHAR(255)," \
                              "locationName VARCHAR(255)," \
                              "lastSync DATETIME," \
                              "manualOrderIndex INT," \
                              "isOutside BOOLEAN," \
                              "settings VARCHAR(255)" \
                              ");");

        if (createDevices.exec() == false)
            qWarning() << "> createDevices.exec() ERROR" << createDevices.lastError().type() << ":" << createDevices.lastError().text();
    }

    if (!tableExists("plantData"))
    {
        qDebug() << "+ Adding 'plantData' table to local database";

        QSqlQuery createData;
        createData.prepare("CREATE TABLE plantData (" \
                           "deviceAddr CHAR(38)," \
                           "ts DATETIME," \
                           "ts_full DATETIME," \
                             "soilMoisture INT," \
                             "soilConductivity INT," \
                             "soilTemperature FLOAT," \
                             "soilPH FLOAT," \
                             "temperature FLOAT," \
                             "humidity FLOAT," \
                             "luminosity INT," \
                             "watertank FLOAT," \
                           " PRIMARY KEY(deviceAddr, ts), " \
                           " FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE CASCADE ON UPDATE NO ACTION " \
                           ");");

        if (createData.exec() == false)
            qWarning() << "> createData.exec() ERROR" << createData.lastError().type() << ":" << createData.lastError().text();
    }

    if (!tableExists("plantLimits"))
    {
        qDebug() << "+ Adding 'plantLimits' table to local database";
        QSqlQuery createLimits;
        createLimits.prepare("CREATE TABLE plantLimits (" \
                             "deviceAddr CHAR(38)," \
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
                             " PRIMARY KEY(deviceAddr), " \
                             " FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE CASCADE ON UPDATE NO ACTION " \
                             ");");

        if (createLimits.exec() == false)
            qWarning() << "> createLimits.exec() ERROR" << createLimits.lastError().type() << ":" << createLimits.lastError().text();
    }

    if (!tableExists("sensorData"))
    {
        qDebug() << "+ Adding 'sensorData' table to local database";
        QSqlQuery createSensorData;
        createSensorData.prepare("CREATE TABLE sensorData (" \
                                 "deviceID INT," \
                                 "deviceAddr CHAR(38)," \
                                   "timestamp DATETIME," \
                                   "temperature FLOAT," \
                                   "humidity FLOAT," \
                                   "pressure FLOAT," \
                                   "luminosity INT," \
                                   "uv FLOAT," \
                                   "sound FLOAT," \
                                   "water FLOAT," \
                                   "windDirection FLOAT," \
                                   "windSpeed FLOAT," \
                                   "pm1 FLOAT," \
                                   "pm25 FLOAT," \
                                   "pm10 FLOAT," \
                                   "o2 FLOAT," \
                                   "o3 FLOAT," \
                                   "co FLOAT," \
                                   "co2 FLOAT," \
                                   "no2 FLOAT," \
                                   "so2 FLOAT," \
                                   "voc FLOAT," \
                                   "hcho FLOAT," \
                                   "geiger FLOAT," \
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

    // TABLE devices
    // FIELD add deviceAddrMAC
    // FIELD add deviceModel
    // FIELD plantName > associatedName
    // FIELD add (DATETIME) lastSync
    // FIELD add (bool) isOutside
    // FIELD add (int) manualOrderIndex
    // FIELD add (str) settings
    QSqlQuery qmDev1("ALTER TABLE devices ADD deviceModel VARCHAR(255)");
    QSqlQuery qmDev2("ALTER TABLE devices RENAME COLUMN plantName TO associatedName");
    QSqlQuery qmDev3("ALTER TABLE devices ADD lastSync DATETIME");
    QSqlQuery qmDev4("ALTER TABLE devices ADD manualOrderIndex INT");
    QSqlQuery qmDev5("ALTER TABLE devices ADD isOutside BOOLEAN");
    QSqlQuery qmDev6("ALTER TABLE devices ADD settings VARCHAR(255)");

    // TABLE datas > plantData
    // FIELD hygro > soilMoisture (change type??)
    // FIELD conductivity > soilConductivity
    // FIELD temp > temperature
    // FIELD add soilTemperature
    // FIELD add soilPH
    // FIELD add humidity
    // FIELD add watertank
    QSqlQuery qmDat1("ALTER TABLE datas RENAME TO plantData");
    QSqlQuery qmDat2("ALTER TABLE plantData RENAME COLUMN hygro TO soilMoisture");
    QSqlQuery qmDat3("ALTER TABLE plantData RENAME COLUMN conductivity TO soilConductivity");
    QSqlQuery qmDat4("ALTER TABLE plantData RENAME COLUMN temp TO temperature");
    QSqlQuery qmDat5("ALTER TABLE plantData ADD soilTemperature FLOAT");
    QSqlQuery qmDat6("ALTER TABLE plantData ADD soilPH FLOAT");
    QSqlQuery qmDat7("ALTER TABLE plantData ADD humidity FLOAT");
    QSqlQuery qmDat8("ALTER TABLE plantData ADD watertank FLOAT");

    // TABLE limits > plantLimits
    // FIELD lumiMin > luxMin
    // FIELD add mmolMin & mmolMax
    QSqlQuery qmLim1("ALTER TABLE limits RENAME TO plantLimits");
    QSqlQuery qmLim2("ALTER TABLE plantLimits RENAME COLUMN lumiMin TO luxMin");
    QSqlQuery qmLim3("ALTER TABLE plantLimits RENAME COLUMN lumiMax TO luxMax");
    QSqlQuery qmLim4("ALTER TABLE plantLimits ADD phMin FLOAT");
    QSqlQuery qmLim5("ALTER TABLE plantLimits ADD phMax FLOAT");
    QSqlQuery qmLim6("ALTER TABLE plantLimits ADD humiMin INT");
    QSqlQuery qmLim7("ALTER TABLE plantLimits ADD humiMax INT");
    QSqlQuery qmLim8("ALTER TABLE plantLimits ADD mmolMin INT");
    QSqlQuery qmLim9("ALTER TABLE plantLimits ADD mmolMax INT");

    // TABLE sensorData

    return true;
}

/* ************************************************************************** */

bool DatabaseManager::migrate_v2v3()
{
    qWarning() << "DatabaseManager::migrate_v2v3()";

    return false;
}

/* ************************************************************************** */
