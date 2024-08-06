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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_environmental.h"

#include <QObject>
#include <QString>
#include <QByteArray>

#include <QSqlQuery>
#include <QSqlError>

/* ************************************************************************** */

DeviceEnvironmental::DeviceEnvironmental(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    // Load device infos, bias, limits and initial data
    if (m_dbInternal || m_dbExternal)
    {
        getSqlDeviceInfos();

        getSqlSensorBias();
        getSqlSensorLimits();

        if (!m_additionalSettings.value("primary").isUndefined())
        {
            m_primary = m_additionalSettings.value("primary").toString();
        }

        // Load initial data into the GUI (if they are no more than 12h old)
        getSqlSensorData(12*60);
    }

    // Device infos
    DeviceInfosLoader *devloader = DeviceInfosLoader::getInstance();
    m_deviceInfos = devloader->getDeviceInfos(m_deviceName, m_deviceModel, m_deviceModelID);
}

DeviceEnvironmental::DeviceEnvironmental(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    // Load device infos, bias, limits and initial data
    if (m_dbInternal || m_dbExternal)
    {
        getSqlDeviceInfos();

        getSqlSensorBias();
        getSqlSensorLimits();

        if (!m_additionalSettings.value("primary").isUndefined())
        {
            m_primary = m_additionalSettings.value("primary").toString();
        }

        // Load initial data into the GUI (if they are no more than 12h old)
        getSqlSensorData(12*60);
    }

    // Device infos
    DeviceInfosLoader *devloader = DeviceInfosLoader::getInstance();
    m_deviceInfos = devloader->getDeviceInfos(m_deviceName, m_deviceModel, m_deviceModelID);
}

DeviceEnvironmental::~DeviceEnvironmental()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEnvironmental::setPrimary(const QString &value)
{
    if (m_primary != value)
    {
        if (setSetting("primary", value))
        {
            m_primary = value;
            Q_EMIT sensorsUpdated();
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceEnvironmental::updateChartData_environmentalVoc(int maxDays)
{
    if (maxDays <= 0) return;
    int maxMonths = 3;

    qDeleteAll(m_chartData_env);
    m_chartData_env.clear();
    ChartDataEnv *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QString strftime_mid = "strftime('%Y-%m-%d', timestamp)"; // sqlite
        if (m_dbExternal) strftime_mid = "DATE_FORMAT(timestamp, '%Y-%m-%d')"; // mysql

        QString datetime_months = "datetime('now','-" + QString::number(maxMonths) + " month')"; // sqlite
        if (m_dbExternal) datetime_months = "DATE_SUB(NOW(), INTERVAL -" + QString::number(maxMonths) + " MONTH)"; // mysql

        QSqlQuery graphData;
        graphData.prepare("SELECT " + strftime_mid + "," \
                            "min(voc), avg(voc), max(voc)," \
                            "min(hcho), avg(hcho), max(hcho)," \
                            "min(co2), avg(co2), max(co2) " \
                          "FROM sensorData " \
                          "WHERE deviceAddr = :deviceAddr AND timestamp >= " + datetime_months + " " \
                          "GROUP BY " + strftime_mid + " " \
                          "ORDER BY timestamp DESC " \
                          "LIMIT :maxDays;");
        graphData.bindValue(":deviceAddr", getAddress());
        graphData.bindValue(":maxDays", maxDays);

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            if (m_chartData_env.size() < maxDays)
            {
                // missing day(s)?
                if (previousdata)
                {
                    QDateTime datefromsql = graphData.value(0).toDateTime();
                    int diff = datefromsql.daysTo(previousdata->getDateTime());
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_env.size() < (maxDays-1))
                        {
                            QDateTime fakedate(datefromsql.addDays(i-1));
                            m_chartData_env.push_back(new ChartDataEnv(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99,
                                                                       -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // data
                ChartDataEnv *d = new ChartDataEnv(graphData.value(0).toDateTime(),
                                                   graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                   graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                   graphData.value(7).toFloat(), graphData.value(8).toFloat(), graphData.value(9).toFloat(),
                                                   -99, -99, -99, -99, -99, -99, this);
                m_chartData_env.push_back(d);
                previousdata = d;
            }
        }

        // missing day(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxDays;
            if (previousdata) missing = static_cast<ChartDataEnv *>(m_chartData_env.first())->getDateTime().daysTo(today);
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_env.push_front(new ChartDataEnv(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99,
                                                           -99, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_env.size(); i < maxDays; i++)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_env.push_back(new ChartDataEnv(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99,
                                                            -99, -99, -99, -99, -99, -99, this));
            }
        }

        Q_EMIT chartDataEnvUpdated();
    }
}

/* ************************************************************************** */

void DeviceEnvironmental::updateChartData_environmentalEnv(int maxDays)
{
    if (maxDays <= 0) return;
    int maxMonths = 3;

    qDeleteAll(m_chartData_env);
    m_chartData_env.clear();
    ChartDataEnv *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QString strftime_mid = "strftime('%Y-%m-%d', timestamp)"; // sqlite
        if (m_dbExternal) strftime_mid = "DATE_FORMAT(timestamp, '%Y-%m-%d')"; // mysql

        QString datetime_months = "datetime('now','-" + QString::number(maxMonths) + " month')"; // sqlite
        if (m_dbExternal) datetime_months = "DATE_SUB(NOW(), INTERVAL -" + QString::number(maxMonths) + " MONTH)"; // mysql

        QSqlQuery graphData;
        graphData.prepare("SELECT " + strftime_mid + "," \
                            "min(voc), avg(voc), max(voc)," \
                            "min(hcho), avg(hcho), max(hcho)," \
                            "min(co2), avg(co2), max(co2)," \
                            "min(pm25), avg(pm25), max(pm25)," \
                            "min(pm10), avg(pm10), max(pm10) " \
                          "FROM sensorData " \
                          "WHERE deviceAddr = :deviceAddr AND timestamp >= " + datetime_months + " " \
                          "GROUP BY " + strftime_mid + " " \
                          "ORDER BY timestamp DESC "
                          "LIMIT :maxDays;");
        graphData.bindValue(":deviceAddr", getAddress());
        graphData.bindValue(":maxDays", maxDays);

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            if (m_chartData_env.size() < maxDays)
            {
                // missing day(s)?
                if (previousdata)
                {
                    QDateTime datefromsql = graphData.value(0).toDateTime();
                    int diff = datefromsql.daysTo(previousdata->getDateTime());
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_env.size() < (maxDays-1))
                        {
                            QDateTime fakedate(datefromsql.addDays(i-1));
                            m_chartData_env.push_back(new ChartDataEnv(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99,
                                                                        -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // data
                ChartDataEnv *d = new ChartDataEnv(graphData.value(0).toDateTime(),
                                                   graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                   graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                   graphData.value(7).toFloat(), graphData.value(8).toFloat(), graphData.value(9).toFloat(),
                                                   graphData.value(10).toFloat(), graphData.value(11).toFloat(), graphData.value(12).toFloat(),
                                                   graphData.value(13).toFloat(), graphData.value(14).toFloat(), graphData.value(15).toFloat(),
                                                   this);
                m_chartData_env.push_back(d);
                previousdata = d;
            }
        }

        // missing day(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxDays;
            if (previousdata) missing = static_cast<ChartDataEnv *>(m_chartData_env.first())->getDateTime().daysTo(today);
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_env.push_back(new ChartDataEnv(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99,
                                                           -99, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_env.size(); i < maxDays; i++)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_env.push_back(new ChartDataEnv(fakedate, -99, -99, -99, -99, -99, -99, -99, -99, -99,
                                                            -99, -99, -99, -99, -99, -99, this));
            }
        }

        Q_EMIT chartDataEnvUpdated();
    }
}

/* ************************************************************************** */

void DeviceEnvironmental::updateChartData_thermometerMinMax(int maxDays)
{
    if (maxDays <= 0) return;
    int maxMonths = 2;

    qDeleteAll(m_chartData_minmax);
    m_chartData_minmax.clear();
    m_tempMin = 999.f;
    m_tempMax = -999.f;
    m_humiMin = 999.f;
    m_humiMax = -999.f;
    ChartDataMinMax *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QString strftime_d = "strftime('%Y-%m-%d', timestamp)"; // sqlite
        if (m_dbExternal) strftime_d = "DATE_FORMAT(timestamp, '%Y-%m-%d')"; // mysql

        QString datetime_months = "datetime('now','-" + QString::number(maxMonths) + " month')"; // sqlite
        if (m_dbExternal) datetime_months = "DATE_SUB(NOW(), INTERVAL -" + QString::number(maxMonths) + " MONTH)"; // mysql

        QSqlQuery graphData;
        graphData.prepare("SELECT " + strftime_d + ", min(temperature), avg(temperature), max(temperature), min(humidity), max(humidity) " \
                          "FROM sensorData " \
                          "WHERE deviceAddr = :deviceAddr AND timestamp >= " + datetime_months + " " \
                          "GROUP BY " + strftime_d + " " \
                          "ORDER BY " + strftime_d + " DESC " \
                          "LIMIT :maxDays;");
        graphData.bindValue(":deviceAddr", getAddress());
        graphData.bindValue(":maxDays", maxDays);

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec(env m/m) ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        bool minmaxChanged = false;

        while (graphData.next())
        {
            if (m_chartData_minmax.size() < maxDays)
            {
                // missing day(s)?
                if (previousdata)
                {
                    QDateTime datefromsql = graphData.value(0).toDateTime();
                    int diff = datefromsql.daysTo(previousdata->getDateTime());
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_minmax.size() < (maxDays-1))
                        {
                            QDateTime fakedate(datefromsql.addDays(i-1));
                            m_chartData_minmax.push_back(new ChartDataMinMax(fakedate, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // min/max
                if (graphData.value(1).toFloat() < m_tempMin) { m_tempMin = graphData.value(1).toFloat(); minmaxChanged = true; }
                if (graphData.value(3).toFloat() > m_tempMax) { m_tempMax = graphData.value(3).toFloat(); minmaxChanged = true; }
                if (graphData.value(4).toInt() < m_humiMin) { m_humiMin = graphData.value(4).toInt(); minmaxChanged = true; }
                if (graphData.value(5).toInt() > m_humiMax) { m_humiMax = graphData.value(5).toInt(); minmaxChanged = true; }

                // data
                ChartDataMinMax *d = new ChartDataMinMax(graphData.value(0).toDateTime(),
                                                         graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                         graphData.value(4).toInt(), graphData.value(5).toInt(), this);
                m_chartData_minmax.push_back(d);
                previousdata = d;
            }
        }

        if (minmaxChanged) { Q_EMIT minmaxUpdated(); }

        // missing day(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxDays;
            if (previousdata) missing = static_cast<ChartDataMinMax *>(m_chartData_minmax.first())->getDateTime().daysTo(today);
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_minmax.push_front(new ChartDataMinMax(fakedate, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_minmax.size(); i < maxDays; i++)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_minmax.push_back(new ChartDataMinMax(fakedate, -99, -99, -99, -99, -99, this));
            }
        }

        Q_EMIT chartDataMinMaxUpdated();
    }
    else
    {
        // No database, use fake values
        m_soilMoistureMin = 0;
        m_soilMoistureMax = 50;
        m_soilConduMin = 0;
        m_soilConduMax = 2000;
        m_soilTempMin = 0.f;
        m_soilTempMax = 36.f;
        m_soilPhMin = 0.f;
        m_soilPhMax = 15.f;
        m_tempMin = 0.f;
        m_tempMax = 36.f;
        m_humiMin = 0;
        m_humiMax = 100;
        m_luxMin = 0;
        m_luxMax = 10000;
        m_mmolMin = 0;
        m_mmolMax = 10000;

        Q_EMIT minmaxUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */
