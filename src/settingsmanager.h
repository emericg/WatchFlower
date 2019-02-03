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

#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H

#define DEFAULT_UPDATE_INTERVAL     60 // minutes
#define ERROR_UPDATE_INTERVAL       10 // minutes

#include <QObject>
#include <QApplication>

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
#include <QQuickWindow>
#include <QtGui/qpa/qplatformwindow.h>
#endif

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool systray READ getSysTray WRITE setSysTray NOTIFY systrayChanged)
    Q_PROPERTY(bool notifications READ getNotifs WRITE setNotifs NOTIFY notifsChanged)
    Q_PROPERTY(bool bluetooth READ getBluetooth WRITE setBluetooth NOTIFY bluetoothChanged)

    Q_PROPERTY(uint interval READ getUpdateInterval WRITE setUpdateInterval NOTIFY intervalChanged)
    Q_PROPERTY(QString tempunit READ getTempUnit WRITE setTempUnit NOTIFY tempunitChanged)
    Q_PROPERTY(QString graphview READ getGraphView WRITE setGraphView NOTIFY graphviewChanged)
    Q_PROPERTY(QString graphdata READ getGraphData WRITE setGraphData NOTIFY graphdataChanged)

    bool m_systrayEnabled = false;
    bool m_notificationsEnabled = false;
    bool m_autoBluetoothEnabled = false;

    int m_updateInterval = DEFAULT_UPDATE_INTERVAL;
    QString m_tempUnit = "C";
    QString m_graphDefaultView = "daily";
    QString m_graphDefaultData = "hygro";

    bool readSettings();
    bool writeSettings();

    bool m_db = false;
    bool loadDatabase();
    void closeDatabase();
    void resetDatabase();

    bool readDevices();

    static SettingsManager *instance;

    SettingsManager();
    ~SettingsManager();

Q_SIGNALS:
    void systrayChanged();
    void notifsChanged();
    void bluetoothChanged();
    void intervalChanged();
    void tempunitChanged();
    void graphviewChanged();
    void graphdataChanged();

public:
    static SettingsManager *getInstance();

    bool hasDatabase() const { return m_db; }

    bool getSysTray() const { return m_systrayEnabled; }
    void setSysTray(bool value);

    bool getNotifs() const { return m_notificationsEnabled; }
    void setNotifs(bool value);

    bool getBluetooth() const { return m_autoBluetoothEnabled; }
    void setBluetooth(bool value);

    int getUpdateInterval() const { return m_updateInterval; }
    void setUpdateInterval(int value) { m_updateInterval = value; writeSettings(); }

    QString getTempUnit() const { return m_tempUnit; }
    void setTempUnit(QString value) { m_tempUnit = value; writeSettings(); }

    QString getGraphView() const { return m_graphDefaultView; }
    void setGraphView(QString value) { m_graphDefaultView = value; writeSettings(); }

    QString getGraphData() const { return m_graphDefaultData; }
    void setGraphData(QString value) { m_graphDefaultData = value; writeSettings(); }

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    Q_INVOKABLE QVariantMap getSafeAreaMargins(QQuickWindow *window);
#endif

public slots:
    static QString getAppVersion();
    void resetSettings();
    void exit() { QApplication::exit(); }
};

#endif // SETTINGS_MANAGER_H
