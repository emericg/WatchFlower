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

#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H
/* ************************************************************************** */

#define DEFAULT_UPDATE_INTERVAL     60 // minutes
#define ERROR_UPDATE_INTERVAL       10 // minutes

#include <QObject>
#include <QApplication>

#if defined(Q_OS_IOS)
#include <QQuickWindow>
#include <QtGui/qpa/qplatformwindow.h>
#endif

/* ************************************************************************** */

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool systray READ getSysTray WRITE setSysTray NOTIFY systrayChanged)
    Q_PROPERTY(bool notifications READ getNotifs WRITE setNotifs NOTIFY notifsChanged)
    Q_PROPERTY(bool minimized READ getMinimized WRITE setMinimized NOTIFY minimizedChanged)

    Q_PROPERTY(bool bluetoothControl READ getBluetoothControl WRITE setBluetoothControl NOTIFY bluetoothControlChanged)
    Q_PROPERTY(bool bluetoothCompat READ getBluetoothCompat WRITE setBluetoothCompat NOTIFY bluetoothCompatChanged)

    Q_PROPERTY(uint updateInterval READ getUpdateInterval WRITE setUpdateInterval NOTIFY updateIntervalChanged)
    Q_PROPERTY(QString tempUnit READ getTempUnit WRITE setTempUnit NOTIFY tempUnitChanged)
    Q_PROPERTY(QString graphHistory READ getGraphHistory WRITE setGraphHistory NOTIFY graphHistoryChanged)
    Q_PROPERTY(bool bigWidget READ getBigWidget WRITE setBigWidget NOTIFY bigWidgetChanged)

    bool m_startMinimized = false;
    bool m_systrayEnabled = false;
    bool m_notificationsEnabled = false;
    bool m_bluetoothControl = false;
    bool m_bluetoothCompat = false;

    int m_updateInterval = DEFAULT_UPDATE_INTERVAL;
    QString m_tempUnit = "C";
    QString m_graphHistory = "monthly";
    bool m_bigWidget = false;

    bool readSettings();
    bool writeSettings();

    bool m_db = false;
    bool loadDatabase();
    void closeDatabase();
    void resetDatabase();

    static SettingsManager *instance;

    SettingsManager();
    ~SettingsManager();

Q_SIGNALS:
    void minimizedChanged();
    void systrayChanged();
    void notifsChanged();
    void bluetoothControlChanged();
    void bluetoothCompatChanged();
    void updateIntervalChanged();
    void tempUnitChanged();
    void graphHistoryChanged();
    void bigWidgetChanged();

public:
    static SettingsManager *getInstance();

    bool hasDatabase() const { return m_db; }

    bool getMinimized() const { return m_startMinimized; }
    void setMinimized(bool value);

    bool getSysTray() const { return m_systrayEnabled; }
    void setSysTray(bool value);

    bool getNotifs() const { return m_notificationsEnabled; }
    void setNotifs(bool value);

    bool getBluetoothControl() const { return m_bluetoothControl; }
    void setBluetoothControl(bool value);

    bool getBluetoothCompat() const { return m_bluetoothCompat; }
    void setBluetoothCompat(bool value);

    int getUpdateInterval() const { return m_updateInterval; }
    void setUpdateInterval(int value);

    QString getTempUnit() const { return m_tempUnit; }
    void setTempUnit(const QString &value);

    QString getGraphHistory() const { return m_graphHistory; }
    void setGraphHistory(const QString &value);

    bool getBigWidget() const { return m_bigWidget; }
    void setBigWidget(bool value);

#if defined(Q_OS_IOS)
    Q_INVOKABLE QVariantMap getSafeAreaMargins(QQuickWindow *window);
#endif

public slots:
    static QString getAppVersion();
    void resetSettings();
    void exit() { QApplication::exit(); }
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
