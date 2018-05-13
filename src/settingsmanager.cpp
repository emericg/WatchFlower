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

#include "settingsmanager.h"

#include <QSettings>
#include <QDebug>

#include <QSqlQuery>
#include <QSqlError>

/* ************************************************************************** */

SettingsManager::SettingsManager()
{
    readSettings();
}

SettingsManager::~SettingsManager()
{
    //
}

/* ************************************************************************** */

bool SettingsManager::readSettings()
{
    bool status = false;

    QSettings settings("WatchFlower", "WatchFlower");
    settings.sync();

    if (settings.status() == QSettings::NoError)
    {
        if (settings.contains("settings/trayEnabled"))
            m_trayEnabled = settings.value("settings/trayEnabled").toBool();

        if (settings.contains("settings/updateInterval"))
            m_updateInterval = settings.value("settings/updateInterval").toUInt();

        status = true;
    }
    else
    {
        qDebug() << "QSettings READ error:" << settings.status();
    }

    return status;
}

bool SettingsManager::writeSettings()
{
    bool status = false;

    QSettings settings("WatchFlower", "WatchFlower");

    if (settings.isWritable())
    {
        settings.setValue("settings/trayEnabled", m_trayEnabled);
        settings.setValue("settings/updateInterval", m_updateInterval);
        settings.sync();

        if (settings.status() == QSettings::NoError)
        {
            status = true;
        }
        else
        {
            qDebug() << "QSettings WRITE error:" << settings.status();
        }
    }

    return status;
}

/* ************************************************************************** */

bool SettingsManager::reset()
{
    return false;
}

/* ************************************************************************** */

bool SettingsManager::readDevices()
{
    return false;
}

/* ************************************************************************** */
