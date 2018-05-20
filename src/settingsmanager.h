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

#define UPDATE_INTERVAL 60

#include <QObject>

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool systray READ getSysTray WRITE setSysTray NOTIFY systrayChanged)
    Q_PROPERTY(uint interval READ getUpdateInterval WRITE setUpdateInterval NOTIFY intervalChanged)
    Q_PROPERTY(QString tempunit READ getTempUnit WRITE setTempUnit NOTIFY tempunitChanged)

    bool m_trayEnabled = false;
    unsigned m_updateInterval = UPDATE_INTERVAL;
    QString m_tempUnit = "C";

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
    void intervalChanged();
    void tempunitChanged();

public:
    static SettingsManager *getInstance();

    bool hasDatabase() const { return m_db; }

    bool getSysTray() const { return m_trayEnabled; }
    void setSysTray(bool value) { m_trayEnabled = value; writeSettings(); }

    unsigned getUpdateInterval() const { return m_updateInterval; }
    void setUpdateInterval(unsigned value) { m_updateInterval = value; writeSettings(); }

    QString getTempUnit() const { return m_tempUnit; }
    void setTempUnit(QString value) { m_tempUnit = value; writeSettings(); }

public slots:
    void reset();
};

#endif // SETTINGS_MANAGER_H
