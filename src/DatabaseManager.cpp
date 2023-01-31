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
    bool status = false;

    if (!status)
    {
        status = openDatabase_mysql();
    }
    if (!status)
    {
        status = openDatabase_sqlite();
    }
}

DatabaseManager::~DatabaseManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

QString DatabaseManager::getDatabaseDirectory()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

bool DatabaseManager::saveDatabase()
{
    // database dir
    QString internalPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir internalDir(internalPath);
    if (!internalDir.exists()) return false;

    // save dir
    QString externalPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/WatchFlower";
    QDir externalDir(externalPath);
    if (!externalDir.exists()) externalDir.mkpath(externalPath);

    return QFile::copy(internalPath + "/data.db",
                       externalPath + "/watchflower_database_" + QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss")+ ".db");
}

bool DatabaseManager::restoreDatabase()
{
    return false;
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
                // pre-migration
                QFile::copy(dbPath+"/datas.db", dbPath+"/data_save_v2.db");
                QFile::rename(dbPath+"/datas.db", dbPath+"/data.db");

                dbPath += "/data.db";

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

                        int maxDays = SettingsManager::getInstance()->getDataRetentionDays();
                        if (maxDays < 30) maxDays = 30;

                        // Delete everything xx days old
                        QSqlQuery sanitizePastData1("DELETE FROM plantData WHERE timestamp < DATE('now', '-" + QString::number(maxDays) + " days')");
                        QSqlQuery sanitizePastData2("DELETE FROM thermoData WHERE timestamp < DATE('now', '-" + QString::number(maxDays) + " days')");
                        QSqlQuery sanitizePastData3("DELETE FROM sensorData WHERE timestamp < DATE('now', '-" + QString::number(maxDays) + " days')");

                        // Basic check to see if the device clock is correctly set
                        if (QDate::currentDate().year() >= 2022)
                        {
                            // Delete everything that's in the future
                            QSqlQuery sanitizeFuruteData1("DELETE FROM plantData WHERE timestamp > DATE('now', '+1 days')");
                            QSqlQuery sanitizeFuruteData2("DELETE FROM thermoData WHERE timestamp > DATE('now', '+1 days')");
                            QSqlQuery sanitizeFuruteData3("DELETE FROM sensorData WHERE timestamp > DATE('now', '+1 days')");
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

        if (sm->getMySQL())
        {
            QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
            db.setHostName(sm->getMysqlHost());
            db.setPort(sm->getMysqlPort());
            db.setDatabaseName(sm->getMysqlName());
            db.setUserName(sm->getMysqlUser());
            db.setPassword(sm->getMysqlPassword());

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
        qDebug() << "> MySQL is NOT available";
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
        QFile::remove(dbName);
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
        if (checkTable.first())
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

        QSqlQuery createDbVersion;
        createDbVersion.prepare("CREATE TABLE version (dbVersion INT);");
        if (createDbVersion.exec())
        {
            QSqlQuery writeDbVersion;
            writeDbVersion.prepare("INSERT INTO version (dbVersion) VALUES (:dbVersion)");
            writeDbVersion.bindValue(":dbVersion", s_dbCurrentVersion);
            writeDbVersion.exec();
        }
        else
        {
            qWarning() << "> createDbVersion.exec() ERROR"
                       << createDbVersion.lastError().type() << ":" << createDbVersion.lastError().text();
        }
    }

    if (!tableExists("lastRun"))
    {
        qDebug() << "+ Adding 'lastRun' table to local database";

        QSqlQuery createLastRun;
        createLastRun.prepare("CREATE TABLE lastRun (lastRun DATETIME);");
        if (createLastRun.exec())
        {
            QSqlQuery writeLastRun;
            writeLastRun.prepare("INSERT INTO lastRun (lastRun) VALUES (:lastRun)");
            writeLastRun.bindValue(":lastRun", QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss"));
            writeLastRun.exec();
        }
        else
        {
            qWarning() << "> createLastRun.exec() ERROR"
                       << createLastRun.lastError().type() << ":" << createLastRun.lastError().text();
        }
    }

    if (!tableExists("devices"))
    {
        qDebug() << "+ Adding 'devices' table to local database";

        QSqlQuery createDevices;
        createDevices.prepare("CREATE TABLE devices (" \
                              "deviceAddr VARCHAR(38) PRIMARY KEY," \
                              "deviceAddrMAC VARCHAR(17)," \
                              "deviceName VARCHAR(255)," \
                              "deviceModel VARCHAR(255)," \
                              "deviceFirmware VARCHAR(255)," \
                              "deviceBattery INT," \
                              "associatedName VARCHAR(255)," \
                              "locationName VARCHAR(255)," \
                              "lastSeen DATETIME," \
                              "lastSync DATETIME," \
                              "isEnabled BOOLEAN DEFAULT TRUE," \
                              "isOutside BOOLEAN DEFAULT FALSE," \
                              "manualOrderIndex INT," \
                              "settings VARCHAR(255)" \
                              ");");

        if (createDevices.exec() == false)
        {
            qWarning() << "> createDevices.exec() ERROR"
                       << createDevices.lastError().type() << ":" << createDevices.lastError().text();
        }
    }

    if (!tableExists("devicesBlacklist"))
    {
        qDebug() << "+ Adding 'devicesBlacklist' table to local database";

        QSqlQuery createDevicesBlacklist;
        createDevicesBlacklist.prepare("CREATE TABLE devicesBlacklist (" \
                                       "deviceAddr VARCHAR(38) PRIMARY KEY" \
                                       ");");

        if (createDevicesBlacklist.exec() == false)
        {
            qWarning() << "> createDevicesBlacklist.exec() ERROR"
                       << createDevicesBlacklist.lastError().type() << ":" << createDevicesBlacklist.lastError().text();
        }
    }

    if (!tableExists("plantData"))
    {
        qDebug() << "+ Adding 'plantData' table to local database";

        QSqlQuery createPlantData;
        createPlantData.prepare("CREATE TABLE plantData (" \
                                "deviceAddr VARCHAR(38)," \
                                "timestamp_rounded DATETIME," \
                                "timestamp DATETIME," \
                                  "soilMoisture INT," \
                                  "soilConductivity INT," \
                                  "soilTemperature FLOAT," \
                                  "soilPH FLOAT," \
                                  "temperature FLOAT," \
                                  "humidity FLOAT," \
                                  "luminosity INT," \
                                  "watertank FLOAT," \
                                "PRIMARY KEY(deviceAddr, timestamp_rounded)," \
                                "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                ");");

        if (createPlantData.exec() == false)
        {
            qWarning() << "> createPlantData.exec() ERROR"
                       << createPlantData.lastError().type() << ":" << createPlantData.lastError().text();
        }
    }

    if (!tableExists("plantLimits"))
    {
        qDebug() << "+ Adding 'plantLimits' table to local database";
        QSqlQuery createPlantLimits;
        createPlantLimits.prepare("CREATE TABLE plantLimits (" \
                                  "deviceAddr VARCHAR(38)," \
                                    "soilMoisture_min INT," \
                                    "soilMoisture_max INT," \
                                    "soilConductivity_min INT," \
                                    "soilConductivity_max INT," \
                                    "soilPH_min FLOAT," \
                                    "soilPH_max FLOAT," \
                                    "temperature_min INT," \
                                    "temperature_max INT," \
                                    "humidity_min INT," \
                                    "humidity_max INT," \
                                    "luminosityLux_min INT," \
                                    "luminosityLux_max INT," \
                                    "luminosityMmol_min INT," \
                                    "luminosityMmol_max INT," \
                                  "PRIMARY KEY(deviceAddr)," \
                                  "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                  ");");

        if (createPlantLimits.exec() == false)
        {
            qWarning() << "> createPlantLimits.exec() ERROR"
                       << createPlantLimits.lastError().type() << ":" << createPlantLimits.lastError().text();
        }
    }

    if (!tableExists("plantBias"))
    {
        qDebug() << "+ Adding 'plantBias' table to local database";
        QSqlQuery createPlantBias;
        createPlantBias.prepare("CREATE TABLE plantBias (" \
                                "deviceAddr VARCHAR(38)," \
                                  "soilMoisture_bias FLOAT," \
                                  "soilConductivity_bias FLOAT," \
                                  "soilTemperature_bias FLOAT," \
                                  "soilPH_bias FLOAT," \
                                  "temperature_bias FLOAT," \
                                  "humidity_bias FLOAT," \
                                  "luminosity_bias FLOAT," \
                                "PRIMARY KEY(deviceAddr)," \
                                "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                ");");

        if (createPlantBias.exec() == false)
        {
            qWarning() << "> createPlantBias.exec() ERROR"
                       << createPlantBias.lastError().type() << ":" << createPlantBias.lastError().text();
        }
    }

    if (!tableExists("plants"))
    {
        qDebug() << "+ Adding 'plants' table to local database";
        QSqlQuery createPlants;
        createPlants.prepare("CREATE TABLE plants (" \
                             "plantId INTEGER PRIMARY KEY AUTOINCREMENT," \
                               "plantName VARCHAR(255)," \
                               "plantCache VARCHAR(1024)," \
                               "plantStart DATETIME," \
                             "deviceAddr VARCHAR(38)," \
                             "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr)" \
                             ");");

        if (createPlants.exec() == false)
        {
            qWarning() << "> createPlants.exec() ERROR"
                       << createPlants.lastError().type() << ":" << createPlants.lastError().text();
        }
    }

    if (!tableExists("plantJournal"))
    {
        qDebug() << "+ Adding 'plantJournal' table to local database";
        QSqlQuery createPlantJournal;
        createPlantJournal.prepare("CREATE TABLE plantJournal (" \
                                   "entryId INTEGER PRIMARY KEY AUTOINCREMENT," \
                                     "entryType INT," \
                                     "entryTimestamp DATETIME," \
                                     "entryComment VARCHAR(255)," \
                                   "plantId INT," \
                                   "FOREIGN KEY(plantId) REFERENCES plants(plantId) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                   ");");

        if (createPlantJournal.exec() == false)
        {
            qWarning() << "> createPlantJournal.exec() ERROR"
                       << createPlantJournal.lastError().type() << ":" << createPlantJournal.lastError().text();
        }
    }

    if (!tableExists("thermoData"))
    {
        qDebug() << "+ Adding 'thermoData' table to local database";

        QSqlQuery createThermoData;
        createThermoData.prepare("CREATE TABLE thermoData (" \
                                 "deviceAddr VARCHAR(38)," \
                                 "timestamp_rounded DATETIME," \
                                 "timestamp DATETIME," \
                                   "temperature FLOAT," \
                                   "humidity FLOAT," \
                                   "pressure FLOAT," \
                                 "PRIMARY KEY(deviceAddr, timestamp_rounded)," \
                                 "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                 ");");

        if (createThermoData.exec() == false)
        {
            qWarning() << "> createThermoData.exec() ERROR"
                       << createThermoData.lastError().type() << ":" << createThermoData.lastError().text();
        }
    }

    if (!tableExists("thermoLimits"))
    {
        qDebug() << "+ Adding 'thermoLimits' table to local database";
        QSqlQuery createThermoLimits;
        createThermoLimits.prepare("CREATE TABLE thermoLimits (" \
                                   "deviceAddr VARCHAR(38)," \
                                     "temperature_min INT," \
                                     "temperature_max INT," \
                                     "humidity_min INT," \
                                     "humidity_max INT," \
                                   "PRIMARY KEY(deviceAddr)," \
                                   "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                   ");");

        if (createThermoLimits.exec() == false)
        {
            qWarning() << "> createThermoLimits.exec() ERROR"
                       << createThermoLimits.lastError().type() << ":" << createThermoLimits.lastError().text();
        }
    }

    if (!tableExists("thermoBias"))
    {
        qDebug() << "+ Adding 'thermoBias' table to local database";
        QSqlQuery createThermoBias;
        createThermoBias.prepare("CREATE TABLE thermoBias (" \
                                 "deviceAddr VARCHAR(38)," \
                                   "temperature_bias FLOAT," \
                                   "humidity_bias FLOAT," \
                                   "pressure_bias FLOAT," \
                                 "PRIMARY KEY(deviceAddr)," \
                                 "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                 ");");

        if (createThermoBias.exec() == false)
        {
            qWarning() << "> createThermoBias.exec() ERROR"
                       << createThermoBias.lastError().type() << ":" << createThermoBias.lastError().text();
        }
    }

    if (!tableExists("sensorData"))
    {
        qDebug() << "+ Adding 'sensorData' table to local database";
        QSqlQuery createSensorData;
        createSensorData.prepare("CREATE TABLE sensorData (" \
                                 "deviceAddr VARCHAR(38)," \
                                 "timestamp_rounded DATETIME," \
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
                                   "radioactivity FLOAT," \
                                 "PRIMARY KEY(deviceAddr, timestamp_rounded)," \
                                 "FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE NO ACTION ON UPDATE NO ACTION" \
                                 ");");

        if (createSensorData.exec() == false)
        {
            qWarning() << "> createSensorData.exec() ERROR"
                       << createSensorData.lastError().type() << ":" << createSensorData.lastError().text();
        }
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
    if (readVersion.first())
    {
        dbVersion = readVersion.value(0).toInt();
        //qDebug() << "dbVersion is #" << dbVersion;
    }
    readVersion.finish();

    if (dbVersion > 0 && dbVersion != s_dbCurrentVersion)
    {
        if (dbVersion == 1)
        {
            if (migrate_v1v2())
            {
                QSqlQuery updateDbVersion("UPDATE version SET dbVersion=2");
                dbVersion = 2;
            }
        }

        if (dbVersion == 2)
        {
            if (migrate_v2v3())
            {
                QSqlQuery updateDbVersion("UPDATE version SET dbVersion=3");
                dbVersion = 3;
            }
        }
    }
}

/* ************************************************************************** */

bool DatabaseManager::migrate_v1v2()
{
    qWarning() << "DatabaseManager::migrate_v1v2()";

    // TABLE devices
    QSqlQuery qmDev1("ALTER TABLE devices ADD deviceModel VARCHAR(255)");
    QSqlQuery qmDev2("ALTER TABLE devices RENAME COLUMN plantName TO associatedName");
    QSqlQuery qmDev3("ALTER TABLE devices ADD lastSync DATETIME");
    QSqlQuery qmDev4("ALTER TABLE devices ADD manualOrderIndex INT");
    QSqlQuery qmDev5("ALTER TABLE devices ADD isOutside BOOLEAN");
    QSqlQuery qmDev6("ALTER TABLE devices ADD settings VARCHAR(255)");

    // TABLE datas > plantData
    QSqlQuery qmDat1("ALTER TABLE datas RENAME TO plantData");
    QSqlQuery qmDat2("ALTER TABLE plantData RENAME COLUMN hygro TO soilMoisture");
    QSqlQuery qmDat3("ALTER TABLE plantData RENAME COLUMN conductivity TO soilConductivity");
    QSqlQuery qmDat4("ALTER TABLE plantData RENAME COLUMN temp TO temperature");
    QSqlQuery qmDat5("ALTER TABLE plantData ADD soilTemperature FLOAT");
    QSqlQuery qmDat6("ALTER TABLE plantData ADD soilPH FLOAT");
    QSqlQuery qmDat7("ALTER TABLE plantData ADD humidity FLOAT");
    QSqlQuery qmDat8("ALTER TABLE plantData ADD watertank FLOAT");

    // TABLE limits > plantLimits
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

    // TABLE devices
    QSqlQuery qmDev1("ALTER TABLE devices ADD deviceAddrMAC VARCHAR(17)");
    QSqlQuery qmDev2("ALTER TABLE devices ADD lastSeen DATETIME");
    QSqlQuery qmDev3("ALTER TABLE devices ADD isEnabled BOOLEAN");
    QSqlQuery qmDev4("ALTER TABLE devices ALTER isEnabled SET DEFAULT TRUE");
    QSqlQuery qmDev5("ALTER TABLE devices ALTER isOutside SET DEFAULT FALSE");

    // TABLE plantData
    QSqlQuery qmPlt1("ALTER TABLE plantData RENAME COLUMN ts TO timestamp_rounded");
    QSqlQuery qmPlt2("ALTER TABLE plantData RENAME COLUMN ts_full TO timestamp");

    // TABLE plantLimits
    QSqlQuery qmLim1("ALTER TABLE plantLimits RENAME COLUMN hygroMin TO soilMoisture_min");
    QSqlQuery qmLim2("ALTER TABLE plantLimits RENAME COLUMN hygroMax TO soilMoisture_max");
    QSqlQuery qmLim3("ALTER TABLE plantLimits RENAME COLUMN conduMin TO soilConductivity_min");
    QSqlQuery qmLim4("ALTER TABLE plantLimits RENAME COLUMN conduMax TO soilConductivity_max");
    QSqlQuery qmLim5("ALTER TABLE plantLimits RENAME COLUMN phMin TO soilPH_min");
    QSqlQuery qmLim6("ALTER TABLE plantLimits RENAME COLUMN phMax TO soilPH_max");
    QSqlQuery qmLim7("ALTER TABLE plantLimits RENAME COLUMN tempMin TO temperature_min");
    QSqlQuery qmLim8("ALTER TABLE plantLimits RENAME COLUMN tempMax TO temperature_max");
    QSqlQuery qmLim9("ALTER TABLE plantLimits RENAME COLUMN humiMin TO humidity_min");
    QSqlQuery qmLim10("ALTER TABLE plantLimits RENAME COLUMN humiMax TO humidity_max");
    QSqlQuery qmLim11("ALTER TABLE plantLimits RENAME COLUMN luxMin TO luminosityLux_min");
    QSqlQuery qmLim12("ALTER TABLE plantLimits RENAME COLUMN luxMax TO luminosityLux_max");
    QSqlQuery qmLim13("ALTER TABLE plantLimits RENAME COLUMN mmolMin TO luminosityMmol_min");
    QSqlQuery qmLim14("ALTER TABLE plantLimits RENAME COLUMN mmolMax TO luminosityMmol_max");

    // DROP TABLES
    QSqlQuery dropSensor("DROP TABLE sensorData");

    return true;
}

/* ************************************************************************** */
