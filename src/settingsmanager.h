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
    Q_PROPERTY(uint initialVisibility READ getInitialVisibility NOTIFY initialSizeChanged)

    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appThemeChanged)
    Q_PROPERTY(bool autoDark READ getAutoDark WRITE setAutoDark NOTIFY autoDarkChanged)
    Q_PROPERTY(QString appLanguage READ getAppLanguage WRITE setAppLanguage NOTIFY appLanguageChanged)
    Q_PROPERTY(bool systray READ getSysTray WRITE setSysTray NOTIFY systrayChanged)
    Q_PROPERTY(bool notifications READ getNotifs WRITE setNotifs NOTIFY notifsChanged)
    Q_PROPERTY(bool minimized READ getMinimized WRITE setMinimized NOTIFY minimizedChanged)

    Q_PROPERTY(bool bluetoothControl READ getBluetoothControl WRITE setBluetoothControl NOTIFY bluetoothControlChanged)
    Q_PROPERTY(uint bluetoothSimUpdates READ getBluetoothSimUpdates WRITE setBluetoothSimUpdates NOTIFY bluetoothSimUpdatesChanged)

    Q_PROPERTY(uint updateIntervalPlant READ getUpdateIntervalPlant WRITE setUpdateIntervalPlant NOTIFY updateIntervalPlantChanged)
    Q_PROPERTY(uint updateIntervalThermo READ getUpdateIntervalThermo WRITE setUpdateIntervalThermo NOTIFY updateIntervalThermoChanged)
    Q_PROPERTY(QString orderBy READ getOrderBy WRITE setOrderBy NOTIFY orderByChanged)
    Q_PROPERTY(QString tempUnit READ getTempUnit WRITE setTempUnit NOTIFY tempUnitChanged)
    Q_PROPERTY(QString graphHistory READ getGraphHistogram WRITE setGraphHistogram NOTIFY graphHistogramChanged)
    Q_PROPERTY(QString graphThermometer READ getGraphThermometer WRITE setGraphThermometer NOTIFY graphThermometerChanged)
    Q_PROPERTY(bool graphShowDots READ getGraphShowDots WRITE setGraphShowDots NOTIFY graphShowDotsChanged)
    Q_PROPERTY(bool bigWidget READ getBigWidget WRITE setBigWidget NOTIFY bigWidgetChanged)
    Q_PROPERTY(bool bigIndicator READ getBigIndicator WRITE setBigIndicator NOTIFY bigIndicatorChanged)
    Q_PROPERTY(bool dynaScale READ getDynaScale WRITE setDynaScale NOTIFY dynaScaleChanged)

    QSize m_appSize;
    QSize m_appPosition;
    unsigned m_appVisibility = 2;

    QString m_appTheme = "green";
    bool m_autoDark = false;
    QString m_appLanguage = "auto";
    bool m_startMinimized = false;
    bool m_systrayEnabled = true;
    bool m_notificationsEnabled = true;

    bool m_bluetoothControl = false;
    unsigned m_bluetoothSimUpdates = 1;

    unsigned m_updateIntervalPlant = PLANT_UPDATE_INTERVAL;
    unsigned m_updateIntervalThermo = THERMO_UPDATE_INTERVAL;
    QString m_tempUnit = "C";
    QString m_graphHistogram = "monthly";
    QString m_graphThermometer = "minmax";
    bool m_graphShowDots = false;
    bool m_bigWidget = false;
    bool m_bigIndicator = true;
    bool m_dynaScale = true;
    QString m_orderBy = "location";

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
    void appThemeChanged();
    void autoDarkChanged();
    void appLanguageChanged();
    void minimizedChanged();
    void systrayChanged();
    void notifsChanged();
    void bluetoothControlChanged();
    void bluetoothSimUpdatesChanged();
    void updateIntervalPlantChanged();
    void updateIntervalThermoChanged();
    void tempUnitChanged();
    void graphHistogramChanged();
    void graphThermometerChanged();
    void graphShowDotsChanged();
    void bigWidgetChanged();
    void bigIndicatorChanged();
    void dynaScaleChanged();
    void orderByChanged();

public:
    static SettingsManager *getInstance();

    QSize getInitialSize() { return m_appSize; }
    QSize getInitialPosition() { return m_appPosition; }
    unsigned getInitialVisibility() { return m_appVisibility; }

    QString getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAutoDark() const { return m_autoDark; }
    void setAutoDark(const bool value);

    QString getAppLanguage() const { return m_appLanguage; }
    void setAppLanguage(const QString &value);

    bool getMinimized() const { return m_startMinimized; }
    void setMinimized(const bool value);

    bool getSysTray() const { return m_systrayEnabled; }
    void setSysTray(const bool value);

    bool getNotifs() const { return m_notificationsEnabled; }
    void setNotifs(const bool value);

    bool getBluetoothControl() const { return m_bluetoothControl; }
    void setBluetoothControl(const bool value);

    unsigned getBluetoothSimUpdates() const { return m_bluetoothSimUpdates; }
    void setBluetoothSimUpdates(const unsigned value);

    unsigned getUpdateIntervalPlant() const { return m_updateIntervalPlant; }
    void setUpdateIntervalPlant(const unsigned value);

    unsigned getUpdateIntervalThermo() const { return m_updateIntervalThermo; }
    void setUpdateIntervalThermo(const unsigned value);

    QString getTempUnit() const { return m_tempUnit; }
    void setTempUnit(const QString &value);

    QString getGraphHistogram() const { return m_graphHistogram; }
    void setGraphHistogram(const QString &value);

    QString getGraphThermometer() const { return m_graphThermometer; }
    void setGraphThermometer(const QString &value);

    bool getGraphShowDots() const { return m_graphShowDots; }
    void setGraphShowDots(const bool value);

    bool getBigWidget() const { return m_bigWidget; }
    void setBigWidget(const bool value);

    bool getBigIndicator() const { return m_bigIndicator; }
    void setBigIndicator(const bool value);

    bool getDynaScale() const { return m_dynaScale; }
    void setDynaScale(const bool value);

    QString getOrderBy() const { return m_orderBy; }
    void setOrderBy(const QString &value);

    // Utils
    Q_INVOKABLE void resetSettings();
    Q_INVOKABLE bool hasDatabase() const { return m_db; }
    Q_INVOKABLE static bool getDemoMode();
    Q_INVOKABLE static QString getDemoString();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
