/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
#include "systraymanager.h"

#include <QStandardPaths>
#include <QLocale>
#include <QDir>
#include <QSettings>
#include <QDebug>

#include <QSqlQuery>
#include <QSqlError>

#if defined(Q_OS_IOS)
#include <QtGui/qpa/qplatformwindow.h>
#endif

#include <QScreen>
#include <cmath>

/* ************************************************************************** */

SettingsManager *SettingsManager::instance = nullptr;

SettingsManager *SettingsManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new SettingsManager();
        return instance;
    }

    return instance;
}

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
/* ************************************************************************** */

bool SettingsManager::readSettings()
{
    bool status = false;

    QSettings settings("WatchFlower", "WatchFlower");
    settings.sync();

    if (settings.status() == QSettings::NoError)
    {
        if (settings.contains("settings/appTheme"))
            m_appTheme = settings.value("settings/appTheme").toString();

        if (settings.contains("settings/autoDark"))
            m_autoDark = settings.value("settings/autoDark").toBool();

        if (settings.contains("settings/bluetoothControl"))
            m_bluetoothControl = settings.value("settings/bluetoothControl").toBool();

        if (settings.contains("settings/bluetoothCompat"))
            m_bluetoothCompat = settings.value("settings/bluetoothCompat").toBool();
        else
        {
#if defined(Q_OS_ANDROID)
            // bluetooth compat is default true on Android, too many weak devices
            m_bluetoothCompat = true;
#endif
        }

        if (settings.contains("settings/trayEnabled"))
            m_systrayEnabled = settings.value("settings/trayEnabled").toBool();

        if (settings.contains("settings/notifsEnabled"))
            m_notificationsEnabled = settings.value("settings/notifsEnabled").toBool();

        if (settings.contains("settings/updateInterval"))
            m_updateInterval = settings.value("settings/updateInterval").toInt();

        if (settings.contains("settings/startMinimized"))
            m_startMinimized = settings.value("settings/startMinimized").toBool();

        if (settings.contains("settings/tempUnit"))
            m_tempUnit = settings.value("settings/tempUnit").toString();
        else
        {
            // If we have no measurement system saved, use system's one
            QLocale lo;
            if (lo.measurementSystem() == QLocale::MetricSystem)
                m_tempUnit = "C";
            else
                m_tempUnit = "F";
        }

        if (settings.contains("settings/graphHistory"))
            m_graphHistory = settings.value("settings/graphHistory").toString();

        if (settings.contains("settings/bigWidget"))
            m_bigWidget = settings.value("settings/bigWidget").toBool();

        status = true;
    }
    else
    {
        qWarning() << "SettingsManager::readSettings() error:" << settings.status();
    }

    return status;
}

/* ************************************************************************** */

bool SettingsManager::writeSettings()
{
    bool status = false;

    QSettings settings("WatchFlower", "WatchFlower");

    if (settings.isWritable())
    {
        settings.setValue("settings/appTheme", m_appTheme);
        settings.setValue("settings/autoDark", m_autoDark);
        settings.setValue("settings/bluetoothControl", m_bluetoothControl);
        settings.setValue("settings/bluetoothCompat", m_bluetoothCompat);
        settings.setValue("settings/trayEnabled", m_systrayEnabled);
        settings.setValue("settings/notifsEnabled", m_notificationsEnabled);
        settings.setValue("settings/updateInterval", m_updateInterval);
        settings.setValue("settings/startMinimized", m_startMinimized);
        settings.setValue("settings/graphHistory", m_graphHistory);
        settings.setValue("settings/bigWidget", m_bigWidget);
        settings.setValue("settings/tempUnit", m_tempUnit);

        settings.sync();

        if (settings.status() == QSettings::NoError)
        {
            status = true;
        }
        else
        {
            qWarning() << "SettingsManager::writeSettings() error:" << settings.status();
        }
    }

    return status;
}

/* ************************************************************************** */
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

                        // Migrations //////////////////////////////////////////

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
                                addVersion.bindValue(":dbVersion", 1);
                                addVersion.exec();
                            }
                            else
                            {
                                qWarning() << "> createVersion.exec() ERROR" << createVersion.lastError().type() << ":"  << createVersion.lastError().text();
                            }
                        }

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
/*
                            // Migration exemple: correct a typo
                            QSqlQuery renameHygro;
                            renameHygro.prepare("ALTER TABLE limits RENAME COLUMN hyroMin TO hygroMin");
                            migration_status = renameHygro.exec();
                            if (migration_status == false)
                                qDebug() << "> renameHygro.exec() ERROR" << renameHygro.lastError().type() << ":"  << renameHygro.lastError().text();
*/
                            // Then update version
                            if (migration_status)
                            {
                                QSqlQuery updateDbVersion;
                                updateDbVersion.prepare("UPDATE version SET dbVersion=:dbVersion");
                                updateDbVersion.bindValue(":dbVersion", CURRENT_DB_VERSION);
                                if (updateDbVersion.exec() == false)
                                    qWarning() << "> updateDbVersion.exec() ERROR" << updateDbVersion.lastError().type() << ":"  << updateDbVersion.lastError().text();
                            }
                        }

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
                                                  "locationName VARCHAR(255)," \
                                                  "plantName VARCHAR(255)" \
                                                  ");");

                            if (createDevices.exec() == false)
                                qWarning() << "> createDevices.exec() ERROR" << createDevices.lastError().type() << ":"  << createDevices.lastError().text();
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
                                qWarning() << "> createDatas.exec() ERROR" << createDatas.lastError().type() << ":"  << createDatas.lastError().text();
                        }

                        QSqlQuery checkLimits;
                        checkLimits.exec("PRAGMA table_info(limits);");
                        if (!checkLimits.next())
                        {
                            qDebug() << "+ Adding 'limits' table to local database";
                            QSqlQuery createLimits;
                            createLimits.prepare("CREATE TABLE limits (" \
                                                 "deviceAddr CHAR(17)," \
                                                   "hygroMin INT," \
                                                   "hygroMax INT," \
                                                   "tempMin INT," \
                                                   "tempMax INT," \
                                                   "lumiMin INT," \
                                                   "lumiMax INT," \
                                                   "conduMin INT," \
                                                   "conduMax INT," \
                                                 " PRIMARY KEY(deviceAddr) " \
                                                 " FOREIGN KEY(deviceAddr) REFERENCES devices(deviceAddr) ON DELETE CASCADE ON UPDATE NO ACTION " \
                                                 ");");

                            if (createLimits.exec() == false)
                                qWarning() << "> createLimits.exec() ERROR" << createLimits.lastError().type() << ":"  << createLimits.lastError().text();
                        }

                        // Delete everything 30+ days old ///////////////////////
                        // DATETIME: YYY-MM-JJ HH:MM:SS

                        QSqlQuery sanitizeDatas;
                        sanitizeDatas.prepare("DELETE FROM datas WHERE ts <  DATE('now', '-30 days')");

                        if (sanitizeDatas.exec() == false)
                            qWarning() << "> sanitizeDatas.exec() ERROR" << sanitizeDatas.lastError().type() << ":"  << sanitizeDatas.lastError().text();
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

/* ************************************************************************** */

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

/* ************************************************************************** */

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

void SettingsManager::resetSettings()
{
    // Settings
    m_appTheme= "green";
    Q_EMIT appthemeChanged();
    m_autoDark = false;
    Q_EMIT autodarkChanged();

    m_systrayEnabled = false;
    Q_EMIT systrayChanged();
    m_notificationsEnabled = false;
    Q_EMIT notifsChanged();
    m_updateInterval = DEFAULT_UPDATE_INTERVAL;
    Q_EMIT updateIntervalChanged();

    m_bluetoothControl = false;
    Q_EMIT bluetoothControlChanged();
    m_bluetoothCompat = false;
    Q_EMIT bluetoothCompatChanged();

    m_startMinimized = false;
    Q_EMIT minimizedChanged();
    QLocale lo;
    if (lo.measurementSystem() == QLocale::MetricSystem)
        m_tempUnit = "C";
    else
        m_tempUnit = "F";
    Q_EMIT tempUnitChanged();
    m_graphHistory = "monthly";
    Q_EMIT graphHistoryChanged();
    m_bigWidget = false;
    Q_EMIT bigWidgetChanged();

    // Database
    resetDatabase();
    loadDatabase();
}

/* ************************************************************************** */
/* ************************************************************************** */

void SettingsManager::setSysTray(const bool value)
{
    bool trayEnable_saved = m_systrayEnabled;
    m_systrayEnabled = value; writeSettings();

    SystrayManager *st = SystrayManager::getInstance();
    if (st)
    {
        if (trayEnable_saved == true && m_systrayEnabled == false)
        {
            st->removeSystray();
            Q_EMIT systrayChanged();
        }
        else if (trayEnable_saved == false && m_systrayEnabled == true)
        {
            st->installSystray();
            Q_EMIT systrayChanged();
        }
    }
}

void SettingsManager::setAppTheme(const QString &value)
{
    m_appTheme = value;
    writeSettings();
    Q_EMIT appthemeChanged();
}

void SettingsManager::setAutoDark(const bool value)
{
    m_autoDark = value;
    writeSettings();
    Q_EMIT autodarkChanged();
}

void SettingsManager::toggleAutoDark()
{
    // when auto dark is toggled, the UI must react to appthemeChanged signal,
    // without an actual m_appTheme value change, so we emit the signal manually
    Q_EMIT appthemeChanged();
}

void SettingsManager::setMinimized(const bool value)
{
    m_startMinimized = value;
    writeSettings();
    Q_EMIT minimizedChanged();
}

void SettingsManager::setNotifs(const bool value)
{
    m_notificationsEnabled = value;
    writeSettings();
    Q_EMIT notifsChanged();
}

void SettingsManager::setBluetoothControl(const bool value)
{
    m_bluetoothControl = value;
    writeSettings();
    Q_EMIT bluetoothControlChanged();
}

void SettingsManager::setBluetoothCompat(const bool value)
{
    m_bluetoothCompat = value;
    writeSettings();
    Q_EMIT bluetoothCompatChanged();
}

void SettingsManager::setUpdateInterval(const int value)
{
    m_updateInterval = value;
    writeSettings();
    Q_EMIT updateIntervalChanged();
}

void SettingsManager::setTempUnit(const QString &value)
{
    m_tempUnit = value;
    writeSettings();
    Q_EMIT tempUnitChanged();
}

void SettingsManager::setGraphHistory(const QString &value)
{
    m_graphHistory = value;
    writeSettings();
    Q_EMIT graphHistoryChanged();
}

void SettingsManager::setBigWidget(const bool value)
{
    m_bigWidget = value;
    writeSettings();
    Q_EMIT bigWidgetChanged();
}

/* ************************************************************************** */

void SettingsManager::getScreenInfos()
{
    qDebug() << "SettingsManager::getScreenInfos()";

    QScreen *scr = qApp->screens().at(0);
    if (scr)
    {
        qDebug() << "- physicalSize (mm) " << scr->physicalSize();
        qDebug() << "- dpi " << scr->physicalDotsPerInch();
        qDebug() << "- pixel ratio " << scr->devicePixelRatio();

        if (scr->devicePixelRatio() == 1.0)
        {
            qDebug() << "- pixel size" << scr->size();
        }
        else
        {
            qDebug() << "- pixel size (hdpi corrected)" << scr->size();
            qDebug() << "- pixel size (physical) " << scr->size() * scr->devicePixelRatio();
        }

        // TODO // On Android, physicalSize().height seems to ignore the buttons and/or status bar
        qDebug() << "- inches count: " << getScreenSize();
    }
    else
    {
        qDebug() << "- Unable to get screen infos :-(";
    }
}

/* ************************************************************************** */

double SettingsManager::getScreenSize()
{
    if (m_screenSize <= 0)
    {
        QScreen *scr = qApp->screens().at(0);
        if (scr)
        {
            // TODO // On Android, physicalSize().height seems to ignore the buttons and/or status bar
            m_screenSize = std::sqrt(std::pow(scr->physicalSize().width(), 2.0) + std::pow(scr->physicalSize().height(), 2.0)) / (2.54 * 10.0);
        }
    }

    return m_screenSize;
}

/* ************************************************************************** */

int SettingsManager::getScreenDpi()
{
    if (m_screenDpi <= 0)
    {
        QScreen *scr = qApp->screens().at(0);
        if (scr)
        {
            m_screenDpi = static_cast<int>(std::round(scr->physicalDotsPerInch()));
        }
    }

    return m_screenDpi;
}

/* ************************************************************************** */

QVariantMap SettingsManager::getSafeAreaMargins(QQuickWindow *window)
{
    QVariantMap map;

    if (window)
    {
#if defined(Q_OS_IOS)
        QPlatformWindow *platformWindow = static_cast<QPlatformWindow *>(window->handle());
        if (platformWindow)
        {
            QMargins margins = platformWindow->safeAreaMargins();
            map["top"] = margins.top();
            map["right"] = margins.right();
            map["bottom"] = margins.bottom();
            map["left"] = margins.left();
            map["total"] = margins.top() + margins.right() + margins.bottom() + margins.left();
        }
        else
        {
            qDebug() << "getSafeAreaMargins() No QPlatformWindow available";
        }
#endif // defined(Q_OS_IOS)
    }
    else
    {
        qDebug() << "getSafeAreaMargins() No QQuickWindow available";
    }

    return map;
}

/* ************************************************************************** */
