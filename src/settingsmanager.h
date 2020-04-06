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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H
/* ************************************************************************** */

#define PLANT_UPDATE_INTERVAL   180 // minutes
#define THERMO_UPDATE_INTERVAL   60 // minutes
#define ERROR_UPDATE_INTERVAL    60 // minutes

#define CURRENT_DB_VERSION        1

#include <QObject>
#include <QString>
#include <QSize>

/* ************************************************************************** */

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QSize initialSize READ getInitialSize NOTIFY initialSizeChanged)
    Q_PROPERTY(QSize initialPosition READ getInitialPosition NOTIFY initialSizeChanged)

    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appthemeChanged)
    Q_PROPERTY(bool autoDark READ getAutoDark WRITE setAutoDark NOTIFY autodarkChanged)
    Q_PROPERTY(bool systray READ getSysTray WRITE setSysTray NOTIFY systrayChanged)
    Q_PROPERTY(bool notifications READ getNotifs WRITE setNotifs NOTIFY notifsChanged)
    Q_PROPERTY(bool minimized READ getMinimized WRITE setMinimized NOTIFY minimizedChanged)

    Q_PROPERTY(bool bluetoothControl READ getBluetoothControl WRITE setBluetoothControl NOTIFY bluetoothControlChanged)
    Q_PROPERTY(bool bluetoothCompat READ getBluetoothCompat WRITE setBluetoothCompat NOTIFY bluetoothCompatChanged)

    Q_PROPERTY(uint updateIntervalPlant READ getUpdateIntervalPlant WRITE setUpdateIntervalPlant NOTIFY updateIntervalPlantChanged)
    Q_PROPERTY(uint updateIntervalThermo READ getUpdateIntervalThermo WRITE setUpdateIntervalThermo NOTIFY updateIntervalThermoChanged)
    Q_PROPERTY(QString tempUnit READ getTempUnit WRITE setTempUnit NOTIFY tempUnitChanged)
    Q_PROPERTY(QString graphHistory READ getGraphHistory WRITE setGraphHistory NOTIFY graphHistoryChanged)
    Q_PROPERTY(bool graphShowDots READ getGraphShowDots WRITE setGraphShowDots NOTIFY graphShowDotsChanged)
    Q_PROPERTY(bool bigWidget READ getBigWidget WRITE setBigWidget NOTIFY bigWidgetChanged)
    Q_PROPERTY(bool bigIndicator READ getBigIndicator WRITE setBigIndicator NOTIFY bigIndicatorChanged)

    QSize m_appSize;
    QSize m_appPosition;

    QString m_appTheme = "green";
    bool m_autoDark = false;
    bool m_startMinimized = false;
    bool m_systrayEnabled = false;
    bool m_notificationsEnabled = false;
    bool m_bluetoothControl = false;
    bool m_bluetoothCompat = false;

    int m_updateIntervalPlant = PLANT_UPDATE_INTERVAL;
    int m_updateIntervalThermo = THERMO_UPDATE_INTERVAL;
    QString m_tempUnit = "C";
    QString m_graphHistory = "monthly";
    bool m_graphShowDots = false;
    bool m_bigWidget = false;
    bool m_bigIndicator = false;

    // Singleton
    static SettingsManager *instance;
    SettingsManager();
    ~SettingsManager();

    bool readSettings();
    bool writeSettings();

    bool m_db = false;
    bool loadDatabase();
    void closeDatabase();
    void resetDatabase();

Q_SIGNALS:
    void initialSizeChanged();
    void appthemeChanged();
    void autodarkChanged();
    void minimizedChanged();
    void systrayChanged();
    void notifsChanged();
    void bluetoothControlChanged();
    void bluetoothCompatChanged();
    void updateIntervalPlantChanged();
    void updateIntervalThermoChanged();
    void tempUnitChanged();
    void graphHistoryChanged();
    void graphShowDotsChanged();
    void bigWidgetChanged();
    void bigIndicatorChanged();

public:
    static SettingsManager *getInstance();

    QSize getInitialSize() { return m_appSize; }
    QSize getInitialPosition() { return m_appPosition; }

    QString getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAutoDark() const { return m_autoDark; }
    void setAutoDark(const bool value);

    bool getMinimized() const { return m_startMinimized; }
    void setMinimized(const bool value);

    bool getSysTray() const { return m_systrayEnabled; }
    void setSysTray(const bool value);

    bool getNotifs() const { return m_notificationsEnabled; }
    void setNotifs(const bool value);

    bool getBluetoothControl() const { return m_bluetoothControl; }
    void setBluetoothControl(const bool value);

    bool getBluetoothCompat() const { return m_bluetoothCompat; }
    void setBluetoothCompat(const bool value);

    int getUpdateIntervalPlant() const { return m_updateIntervalPlant; }
    void setUpdateIntervalPlant(const int value);

    int getUpdateIntervalThermo() const { return m_updateIntervalThermo; }
    void setUpdateIntervalThermo(const int value);

    QString getTempUnit() const { return m_tempUnit; }
    void setTempUnit(const QString &value);

    QString getGraphHistory() const { return m_graphHistory; }
    void setGraphHistory(const QString &value);

    bool getGraphShowDots() const { return m_graphShowDots; }
    void setGraphShowDots(const bool value);

    bool getBigWidget() const { return m_bigWidget; }
    void setBigWidget(const bool value);

    bool getBigIndicator() const { return m_bigIndicator; }
    void setBigIndicator(const bool value);

    // Utils
    Q_INVOKABLE void resetSettings();
    Q_INVOKABLE bool hasDatabase() const { return m_db; }
    Q_INVOKABLE static bool getDemoMode();
    Q_INVOKABLE static QString getDemoString();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
