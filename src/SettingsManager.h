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

#define PLANT_UPDATE_INTERVAL   240 // minutes
#define THERMO_UPDATE_INTERVAL  120 // minutes
#define ERROR_UPDATE_INTERVAL    60 // minutes

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

    Q_PROPERTY(bool firstLaunch READ isFirstLaunch NOTIFY firstLaunchChanged)

    Q_PROPERTY(QSize initialSize READ getInitialSize NOTIFY initialSizeChanged)
    Q_PROPERTY(QSize initialPosition READ getInitialPosition NOTIFY initialSizeChanged)
    Q_PROPERTY(uint initialVisibility READ getInitialVisibility NOTIFY initialSizeChanged)

    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appThemeChanged)
    Q_PROPERTY(bool appThemeAuto READ getAppThemeAuto WRITE setAppThemeAuto NOTIFY appThemeAutoChanged)
    Q_PROPERTY(bool appThemeCSD READ getAppThemeCSD WRITE setAppThemeCSD NOTIFY appThemeCSDChanged)
    Q_PROPERTY(uint appUnits READ getAppUnits WRITE setAppUnits NOTIFY appUnitsChanged)
    Q_PROPERTY(QString appLanguage READ getAppLanguage WRITE setAppLanguage NOTIFY appLanguageChanged)

    Q_PROPERTY(bool systray READ getSysTray WRITE setSysTray NOTIFY systrayChanged)
    Q_PROPERTY(bool notifications READ getNotifs WRITE setNotifs NOTIFY notifsChanged)
    Q_PROPERTY(bool minimized READ getMinimized WRITE setMinimized NOTIFY minimizedChanged)
    Q_PROPERTY(bool bluetoothControl READ getBluetoothControl WRITE setBluetoothControl NOTIFY bluetoothControlChanged)
    Q_PROPERTY(bool bluetoothLimitScanningRange READ getBluetoothLimitScanningRange WRITE setBluetoothLimitScanningRange NOTIFY bluetoothLimitScanningRangeChanged)
    Q_PROPERTY(uint bluetoothSimUpdates READ getBluetoothSimUpdates WRITE setBluetoothSimUpdates NOTIFY bluetoothSimUpdatesChanged)
    Q_PROPERTY(uint updateIntervalPlant READ getUpdateIntervalPlant WRITE setUpdateIntervalPlant NOTIFY updateIntervalPlantChanged)
    Q_PROPERTY(uint updateIntervalThermo READ getUpdateIntervalThermo WRITE setUpdateIntervalThermo NOTIFY updateIntervalThermoChanged)
    Q_PROPERTY(QString orderBy READ getOrderBy WRITE setOrderBy NOTIFY orderByChanged)
    Q_PROPERTY(QString tempUnit READ getTempUnit WRITE setTempUnit NOTIFY tempUnitChanged)
    Q_PROPERTY(QString graphHistory READ getGraphHistogram WRITE setGraphHistogram NOTIFY graphHistogramChanged)
    Q_PROPERTY(QString graphThermometer READ getGraphThermometer WRITE setGraphThermometer NOTIFY graphThermometerChanged)
    Q_PROPERTY(bool graphShowDots READ getGraphShowDots WRITE setGraphShowDots NOTIFY graphShowDotsChanged)
    Q_PROPERTY(bool compactView READ getCompactView WRITE setCompactView NOTIFY compactViewChanged)
    Q_PROPERTY(bool bigIndicator READ getBigIndicator WRITE setBigIndicator NOTIFY bigIndicatorChanged)
    Q_PROPERTY(bool dynaScale READ getDynaScale WRITE setDynaScale NOTIFY dynaScaleChanged)
    Q_PROPERTY(bool externalDb READ getExternalDb WRITE setExternalDb NOTIFY externalDbChanged)
    Q_PROPERTY(QString externalDbHost READ getExternalDbHost WRITE setExternalDbHost NOTIFY externalDbChanged)
    Q_PROPERTY(uint externalDbPort READ getExternalDbPort WRITE setExternalDbPort NOTIFY externalDbChanged)
    Q_PROPERTY(QString externalDbUser READ getExternalDbUser WRITE setExternalDbUser NOTIFY externalDbChanged)
    Q_PROPERTY(QString externalDbPassword READ getExternalDbPassword WRITE setExternalDbPassword NOTIFY externalDbChanged)

    bool m_firstlaunch = true;

    // Application window
    QSize m_appSize;
    QSize m_appPosition;
    unsigned m_appVisibility = 1;               //!< QWindow::Visibility

    // Application generic
    QString m_appTheme = "THEME_PLANT";
    bool m_appThemeAuto = false;
    bool m_appThemeCSD = false;
    unsigned m_appUnits = 0;                    //!< QLocale::MeasurementSystem
    QString m_appLanguage = "auto";

    // Application specific
    bool m_startMinimized = false;
    bool m_systrayEnabled = true;
    bool m_notificationsEnabled = true;

    bool m_bluetoothControl = false;
    bool m_bluetoothLimitScanningRange = true;
    unsigned m_bluetoothSimUpdates = 2;

    unsigned m_updateIntervalPlant = PLANT_UPDATE_INTERVAL;
    unsigned m_updateIntervalThermo = THERMO_UPDATE_INTERVAL;
    QString m_tempUnit = "C";
    QString m_graphHistogram = "weekly";
    QString m_graphThermometer = "minmax";
    bool m_graphShowDots = true;
    bool m_compactView = true;
    bool m_bigIndicator = true;
    bool m_dynaScale = true;
    QString m_orderBy = "model";

    bool m_externalDb = false;
    QString m_externalDbHost;
    int m_externalDbPort = 3306;
    QString m_externalDbName = "watchflower";
    QString m_externalDbUser = "watchflower";
    QString m_externalDbPassword = "watchflower";

    // Singleton
    static SettingsManager *instance;
    SettingsManager();
    ~SettingsManager();

    bool readSettings();
    bool writeSettings();

Q_SIGNALS:
    void firstLaunchChanged();
    void initialSizeChanged();
    void appThemeChanged();
    void appThemeAutoChanged();
    void appThemeCSDChanged();
    void appUnitsChanged();
    void appLanguageChanged();
    void minimizedChanged();
    void systrayChanged();
    void notifsChanged();
    void bluetoothControlChanged();
    void bluetoothSimUpdatesChanged();
    void bluetoothLimitScanningRangeChanged();
    void updateIntervalPlantChanged();
    void updateIntervalThermoChanged();
    void tempUnitChanged();
    void graphHistogramChanged();
    void graphThermometerChanged();
    void graphShowDotsChanged();
    void compactViewChanged();
    void bigIndicatorChanged();
    void dynaScaleChanged();
    void orderByChanged();
    void externalDbChanged();

public:
    static SettingsManager *getInstance();

    bool isFirstLaunch() const { return m_firstlaunch; }

    QSize getInitialSize() { return m_appSize; }
    QSize getInitialPosition() { return m_appPosition; }
    unsigned getInitialVisibility() { return m_appVisibility; }

    QString getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAppThemeAuto() const { return m_appThemeAuto; }
    void setAppThemeAuto(const bool value);

    bool getAppThemeCSD() const { return m_appThemeCSD; }
    void setAppThemeCSD(const bool value);

    unsigned getAppUnits() const { return m_appUnits; }
    void setAppUnits(unsigned value);

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

    bool getBluetoothLimitScanningRange() const { return m_bluetoothLimitScanningRange; }
    void setBluetoothLimitScanningRange(const bool value);

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

    bool getCompactView() const { return m_compactView; }
    void setCompactView(const bool value);

    bool getBigIndicator() const { return m_bigIndicator; }
    void setBigIndicator(const bool value);

    bool getDynaScale() const { return m_dynaScale; }
    void setDynaScale(const bool value);

    QString getOrderBy() const { return m_orderBy; }
    void setOrderBy(const QString &value);

    bool getExternalDb() const { return m_externalDb; }
    void setExternalDb(const bool value);

    QString getExternalDbHost() const { return m_externalDbHost; }
    void setExternalDbHost(const QString &value);

    int getExternalDbPort() const { return m_externalDbPort; }
    void setExternalDbPort(const int value);

    QString getExternalDbName() const { return m_externalDbName; }
    void setExternalDbName(const QString &value);

    QString getExternalDbUser() const { return m_externalDbUser; }
    void setExternalDbUser(const QString &value);


    QString getExternalDbPassword() const { return m_externalDbPassword; }
    void setExternalDbPassword(const QString &value);

    // Utils
    Q_INVOKABLE void resetSettings();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
