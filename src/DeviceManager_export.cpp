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

#include "DeviceManager.h"
#include "DatabaseManager.h"

#include "utils/utils_app.h"

#include <QList>
#include <QDateTime>
#include <QDebug>

#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QTextStream>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

/* ************************************************************************** */

bool DeviceManager::exportDataSave()
{
    bool status = false;

    if (!m_devices_model->hasDevices()) return status;

    QString exportDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/WatchFlower";

    // Create exportDirectory
    if (!exportDirectoryPath.isEmpty())
    {
        QDir exportDirectory(exportDirectoryPath);

        // check if directory creation is needed
        if (!exportDirectory.exists())
        {
            exportDirectory.mkpath(exportDirectoryPath);
        }
        // retry
        if (exportDirectory.exists())
        {
            // Get file name
            QString exportFilePath = exportDirectoryPath;
            exportFilePath += "/watchflower_";
            exportFilePath += QDateTime::currentDateTime().toString("yyyy-MM-dd");
            exportFilePath += ".csv";

            if (exportData(exportFilePath))
            {
                status = true;
            }
            else
            {
                status = false;
            }
        }
        else
        {
            qWarning() << "DeviceManager::exportDataSave() cannot create export directory";
            status = false;
        }
    }
    else
    {
        qWarning() << "DeviceManager::exportDataSave() invalid export directory";
        status = false;
    }

    return status;
}

/* ************************************************************************** */

QString DeviceManager::exportDataOpen()
{
    QString exportFilePath;

    if (!m_devices_model->hasDevices()) return exportFilePath;

    // Get temp directory path
    QString exportDirectoryPath = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);

    QDir exportDirectory(exportDirectoryPath + "/export");
    if (!exportDirectory.exists()) exportDirectory.mkpath(exportDirectoryPath + "/export");

    // Get temp file path
    exportFilePath = exportDirectoryPath + "/export/watchflower_" + QDateTime::currentDateTime().toString("yyyy-MM-dd") + ".csv";

    if (exportData(exportFilePath))
    {
        return exportFilePath;
    }

    return QString();
}

QString DeviceManager::exportDataFolder()
{
    // Get temp directory path
    QString exportDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/WatchFlower";

    // check if directory exist
    QDir exportDirectory(exportDirectoryPath);
    if (exportDirectory.exists())
    {
        return exportDirectoryPath;
    }

    return QString();
}

/* ************************************************************************** */

bool DeviceManager::exportData(const QString &exportFilePath)
{
    bool status = false;

    if (!m_devices_model->hasDevices()) return status;
    if (!m_dbInternal && !m_dbExternal) return status;

    SettingsManager *sm = SettingsManager::getInstance();
    bool isCelcius = (sm->getTempUnit() == "C");

    QFile efile;
    efile.setFileName(exportFilePath);
    if (efile.open(QIODevice::WriteOnly))
    {
        status = true;
        QTextStream eout(&efile);

        QString legend = "Timestamp (YYYY-MM-DD hh:mm:ss), Soil moisture (%), Soil conductivity (μs/cm), Temperature (";
        legend += (isCelcius ? "℃" : "℉");
        legend += "), Humidity (%RH), Luminosity (lux)";
        eout << legend << Qt::endl;

        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            Device *dd = qobject_cast<Device*>(d);
            if (dd)
            {
                QString l = "> " + dd->getName() + " (" + dd->getAddress() + ")";
                eout << l << Qt::endl;

                QSqlQuery data;
                if (m_dbInternal) // sqlite
                {
                    data.prepare("SELECT timestamp, soilMoisture, soilConductivity, soilTemperature, temperature, humidity, luminosity " \
                                 "FROM plantData " \
                                 "WHERE deviceAddr = :deviceAddr AND timestamp >= datetime('now', 'localtime', '-" + QString::number(90) + " days');");
                }
                else if (m_dbExternal) // mysql
                {
                    data.prepare("SELECT timestamp, soilMoisture, soilConductivity, soilTemperature, temperature, humidity, luminosity " \
                                 "FROM plantData " \
                                 "WHERE deviceAddr = :deviceAddr AND timestamp >= DATE_SUB(NOW(), INTERVAL " + QString::number(90) + " DAY);");
                }
                data.bindValue(":deviceAddr", dd->getAddress());

                if (data.exec() == true)
                {
                    while (data.next())
                    {
                        eout << data.value(0).toString() << ",";

                        if (dd->hasSoilMoistureSensor()) eout<< data.value(1).toString();
                        eout << ",";

                        if (dd->hasSoilConductivitySensor()) eout << data.value(2).toString();
                        eout << ",";

                        if (isCelcius) eout << QString::number(data.value(4).toReal(), 'f', 1);
                        else eout << QString::number(data.value(4).toReal()* 1.8 + 32.0, 'f', 1);
                        eout << ",";

                        if (dd->hasHumiditySensor()) eout << data.value(5).toString();
                        eout << ",";

                        if (dd->hasLuminositySensor()) eout << data.value(6).toString();
                        eout << ",";

                        eout << Qt::endl;
                    }
                }
            }
        }

        efile.close();
    }
    else
    {
        qWarning() << "DeviceManager::exportData() cannot open export file: " << exportFilePath;
        status = false;
    }

    return status;
}

/* ************************************************************************** */
