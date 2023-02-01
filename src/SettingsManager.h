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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H
/* ************************************************************************** */

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

    Q_PROPERTY(bool startMinimized READ getMinimized WRITE setMinimized NOTIFY minimizedChanged)
    Q_PROPERTY(bool systray READ getSysTray WRITE setSysTray NOTIFY systrayChanged)
    Q_PROPERTY(bool notifications READ getNotifs WRITE setNotifs NOTIFY notifsChanged)
    Q_PROPERTY(bool notif_battery READ getNotifBatt WRITE setNotifBatt NOTIFY notifsChanged)
    Q_PROPERTY(bool notif_water READ getNotifWater WRITE setNotifWater NOTIFY notifsChanged)
    Q_PROPERTY(bool notif_subzero READ getNotifSubzero WRITE setNotifSubzero NOTIFY notifsChanged)
    Q_PROPERTY(bool notif_env READ getNotifEnv WRITE setNotifEnv NOTIFY notifsChanged)

    Q_PROPERTY(bool bluetoothControl READ getBluetoothControl WRITE setBluetoothControl NOTIFY bluetoothControlChanged)
    Q_PROPERTY(bool bluetoothLimitScanningRange READ getBluetoothLimitScanningRange WRITE setBluetoothLimitScanningRange NOTIFY bluetoothLimitScanningRangeChanged)
    Q_PROPERTY(uint bluetoothSimUpdates READ getBluetoothSimUpdates WRITE setBluetoothSimUpdates NOTIFY bluetoothSimUpdatesChanged)
    Q_PROPERTY(uint updateIntervalBackground READ getUpdateIntervalBackground WRITE setUpdateIntervalBackground NOTIFY updateIntervalBackgroundChanged)
    Q_PROPERTY(uint updateIntervalPlant READ getUpdateIntervalPlant WRITE setUpdateIntervalPlant NOTIFY updateIntervalPlantChanged)
    Q_PROPERTY(uint updateIntervalThermo READ getUpdateIntervalThermo WRITE setUpdateIntervalThermo NOTIFY updateIntervalThermoChanged)
    Q_PROPERTY(uint updateIntervalEnv READ getUpdateIntervalEnv WRITE setUpdateIntervalEnv NOTIFY updateIntervalEnvChanged)
    Q_PROPERTY(bool splitView READ getSplitView WRITE setSplitView NOTIFY splitViewChanged)
    Q_PROPERTY(QString orderBy READ getOrderBy WRITE setOrderBy NOTIFY orderByChanged)
    Q_PROPERTY(QString tempUnit READ getTempUnit WRITE setTempUnit NOTIFY tempUnitChanged)
    Q_PROPERTY(QString graphHistory READ getGraphHistogram WRITE setGraphHistogram NOTIFY graphHistogramChanged)
    Q_PROPERTY(QString graphThermometer READ getGraphThermometer WRITE setGraphThermometer NOTIFY graphThermometerChanged)
    Q_PROPERTY(int graphAioDays READ getGraphAioDays WRITE setGraphAioDays NOTIFY graphAioChanged)
    Q_PROPERTY(bool graphAioShowDots READ getGraphAioShowDots WRITE setGraphAioShowDots NOTIFY graphAioChanged)
    Q_PROPERTY(bool bigIndicator READ getBigIndicator WRITE setBigIndicator NOTIFY bigIndicatorChanged)
    Q_PROPERTY(bool dynaScale READ getDynaScale WRITE setDynaScale NOTIFY dynaScaleChanged)

    Q_PROPERTY(bool mysql READ getMySQL WRITE setMySQL NOTIFY mysqlChanged)
    Q_PROPERTY(QString mysqlHost READ getMysqlHost WRITE setMysqlHost NOTIFY mysqlChanged)
    Q_PROPERTY(uint mysqlPort READ getMysqlPort WRITE setMysqlPort NOTIFY mysqlChanged)
    Q_PROPERTY(QString mysqlUser READ getMysqlUser WRITE setMysqlUser NOTIFY mysqlChanged)
    Q_PROPERTY(QString mysqlPassword READ getMysqlPassword WRITE setMysqlPassword NOTIFY mysqlChanged)

    Q_PROPERTY(bool mqtt READ getMQTT WRITE setMQTT NOTIFY mqttChanged)
    Q_PROPERTY(QString mqttHost READ getMqttHost WRITE setMqttHost NOTIFY mqttChanged)
    Q_PROPERTY(uint mqttPort READ getMqttPort WRITE setMqttPort NOTIFY mqttChanged)
    Q_PROPERTY(QString mqttUser READ getMqttUser WRITE setMqttUser NOTIFY mqttChanged)
    Q_PROPERTY(QString mqttPassword READ getMqttPassword WRITE setMqttPassword NOTIFY mqttChanged)
    Q_PROPERTY(QString mqttTopics READ getMqttTopics WRITE setMqttTopics NOTIFY mqttChanged)

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
    bool m_systrayEnabled = false;
    bool m_notificationsEnabled = false;
    bool m_notif_batt = true;
    bool m_notif_water = true;
    bool m_notif_subzero = true;
    bool m_notif_env = true;

    bool m_bluetoothControl = true;
    bool m_bluetoothLimitScanningRange = false;
    unsigned m_bluetoothSimUpdates = 2;

    unsigned m_updateIntervalBackground = s_intervalBackgroundUpdate;
    unsigned m_updateIntervalPlant = s_intervalPlantUpdate;
    unsigned m_updateIntervalThermometer = s_intervalThermometerUpdate;
    unsigned m_updateIntervalEnvironmental = s_intervalEnvironmentalUpdate;

    unsigned m_dataRetentionDays = 90;

    QString m_tempUnit = "C";
    QString m_graphHistogram = "weekly";
    QString m_graphThermometer = "minmax";
    int m_graphAioDays = 14;
    bool m_graphAioShowDots = true;
    bool m_bigIndicator = true;
    bool m_dynaScale = true;

    bool m_splitView = false;
    QString m_orderBy = "model";

    bool m_mysql = false;
    QString m_mysqlHost;
    int m_mysqlPort = 3306;
    QString m_mysqlName = "watchflower";
    QString m_mysqlUser = "watchflower";
    QString m_mysqlPassword = "watchflower";

    bool m_mqtt = false;
    QString m_mqttHost;
    int m_mqttPort = 1883;
    QString m_mqttName = "watchflower";
    QString m_mqttUser = "watchflower";
    QString m_mqttPassword = "watchflower";
    QString m_mqttTopics = "watchflower";

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
    void updateIntervalBackgroundChanged();
    void updateIntervalPlantChanged();
    void updateIntervalThermoChanged();
    void updateIntervalEnvChanged();
    void tempUnitChanged();
    void graphHistogramChanged();
    void graphThermometerChanged();
    void graphAioChanged();
    void bigIndicatorChanged();
    void dynaScaleChanged();
    void splitViewChanged();
    void orderByChanged();
    void mysqlChanged();
    void mqttChanged();

public:
    static const unsigned s_intervalBackgroundUpdate = 60;
    static const unsigned s_intervalErrorUpdate = 30;

    static const unsigned s_intervalPlantUpdate = 240;
    static const unsigned s_intervalThermometerUpdate = 120;
    static const unsigned s_intervalEnvironmentalUpdate = 60;

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

    bool getNotifBatt() const { return m_notif_batt; }
    void setNotifBatt(const bool value);
    bool getNotifWater() const { return m_notif_water; }
    void setNotifWater(const bool value);
    bool getNotifSubzero() const { return m_notif_subzero; }
    void setNotifSubzero(const bool value);
    bool getNotifEnv() const { return m_notif_env; }
    void setNotifEnv(const bool value);

    bool getBluetoothControl() const { return m_bluetoothControl; }
    void setBluetoothControl(const bool value);

    bool getBluetoothLimitScanningRange() const { return m_bluetoothLimitScanningRange; }
    void setBluetoothLimitScanningRange(const bool value);

    unsigned getBluetoothSimUpdates() const { return m_bluetoothSimUpdates; }
    void setBluetoothSimUpdates(const unsigned value);

    unsigned getUpdateIntervalBackground() const { return m_updateIntervalBackground; }
    void setUpdateIntervalBackground(const unsigned value);

    unsigned getUpdateIntervalPlant() const { return m_updateIntervalPlant; }
    void setUpdateIntervalPlant(const unsigned value);

    unsigned getUpdateIntervalThermo() const { return m_updateIntervalThermometer; }
    void setUpdateIntervalThermo(const unsigned value);

    unsigned getUpdateIntervalEnv() const { return m_updateIntervalEnvironmental; }
    void setUpdateIntervalEnv(const unsigned value);

    QString getTempUnit() const { return m_tempUnit; }
    void setTempUnit(const QString &value);

    QString getGraphHistogram() const { return m_graphHistogram; }
    void setGraphHistogram(const QString &value);

    QString getGraphThermometer() const { return m_graphThermometer; }
    void setGraphThermometer(const QString &value);

    int getGraphAioDays() const { return m_graphAioDays; }
    void setGraphAioDays(const int value);

    bool getGraphAioShowDots() const { return m_graphAioShowDots; }
    void setGraphAioShowDots(const bool value);

    bool getBigIndicator() const { return m_bigIndicator; }
    void setBigIndicator(const bool value);

    bool getDynaScale() const { return m_dynaScale; }
    void setDynaScale(const bool value);

    bool getSplitView() const { return m_splitView; }
    void setSplitView(const bool value);

    QString getOrderBy() const { return m_orderBy; }
    void setOrderBy(const QString &value);

    unsigned getDataRetentionDays() const { return m_dataRetentionDays; }

    bool getMySQL() const { return m_mysql; }
    void setMySQL(const bool value);

    QString getMysqlHost() const { return m_mysqlHost; }
    void setMysqlHost(const QString &value);

    int getMysqlPort() const { return m_mysqlPort; }
    void setMysqlPort(const int value);

    QString getMysqlName() const { return m_mysqlName; }
    void setMysqlName(const QString &value);

    QString getMysqlUser() const { return m_mysqlUser; }
    void setMysqlUser(const QString &value);

    QString getMysqlPassword() const { return m_mysqlPassword; }
    void setMysqlPassword(const QString &value);

    bool getMQTT() const { return m_mqtt; }
    void setMQTT(const bool value);

    QString getMqttHost() const { return m_mqttHost; }
    void setMqttHost(const QString &value);

    int getMqttPort() const { return m_mqttPort; }
    void setMqttPort(const int value);

    QString getMqttName() const { return m_mqttName; }
    void setMqttName(const QString &value);

    QString getMqttUser() const { return m_mqttUser; }
    void setMqttUser(const QString &value);

    QString getMqttPassword() const { return m_mqttPassword; }
    void setMqttPassword(const QString &value);

    QString getMqttTopics() const { return m_mqttTopics; }
    void setMqttTopics(const QString &value);

    // Utils
    Q_INVOKABLE QString getSettingsDirectory();
    Q_INVOKABLE void resetSettings();
    Q_INVOKABLE bool saveSettings();
    Q_INVOKABLE bool restoreSettings();
    void reloadSettings();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
