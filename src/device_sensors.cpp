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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_sensors.h"
#include "settingsmanager.h"
#include "devicemanager.h"
#include "notificationmanager.h"
#include "utils/utils_versionchecker.h"

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

DeviceSensors::DeviceSensors(QString &deviceAddr, QString &deviceName, QObject *parent) :
    Device(deviceAddr, deviceName, parent)
{
    // Load device infos and limits
    getSqlInfos();
    getSqlLimits();
    // Load initial data into the GUI (if they are no more than 12h old)
    getSqlData(12*60);

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensors::refreshDataCanceled);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &DeviceSensors::refreshStart);
}

DeviceSensors::DeviceSensors(const QBluetoothDeviceInfo &d, QObject *parent) :
    Device(d, parent)
{
    // Load device infos and limits
    getSqlInfos();
    getSqlLimits();
    // Load initial data into the GUI (if they are no more than 12h old)
    getSqlData(12*60);

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensors::refreshDataCanceled);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &DeviceSensors::refreshStart);
}

DeviceSensors::~DeviceSensors()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensors::refreshDataFinished(bool status, bool cached)
{
    //qDebug() << "DeviceSensors::refreshDataFinished()" << getAddress() << getName();

    Device::refreshDataFinished(status, cached);

    if (status == true)
    {
        // Plant sensor?
        if (hasSoilMoistureSensor())
        {
            SettingsManager *sm = SettingsManager::getInstance();

            // Reorder the device list by water level, if needed
            if (sm->getOrderBy() == "waterlevel")
            {
                if (parent()) static_cast<DeviceManager *>(parent())->invalidate();
            }

            // 'Water me' notification, if enabled
            if (sm->getNotifs())
            {
                // Only if the sensor has a plant
                if (m_soil_moisture > 0 && m_soil_moisture < m_limitHygroMin)
                {
                    NotificationManager *nm = NotificationManager::getInstance();
                    if (nm)
                    {
                        QString message;
                        if (!m_plantName.isEmpty())
                            message = tr("You need to water your '%1' now!").arg(m_plantName);
                        else if (!m_locationName.isEmpty())
                            message = tr("You need to water the plant near '%1'").arg(m_locationName);
                        else
                            message = tr("You need to water one of your (unnamed) plants!");

                        nm->setNotification(message);
                    }
                }
            }
        }
    }
}

/* ************************************************************************** */

bool DeviceSensors::getSqlInfos()
{
    //qDebug() << "DeviceSensors::getSqlInfos(" << m_deviceAddress << ")";
    bool status = Device::getSqlInfos();

    if ((m_deviceName == "Flower care" || m_deviceName == "Flower mate") && (m_firmware.size() == 5))
    {
        if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERCARE))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName.startsWith("Flower power")) && (m_firmware.size() == 5))
    {
        if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_FLOWERPOWER))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "ropot") && (m_firmware.size() == 5))
    {
        if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_ROPOT))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "MJ_HT_V1") && (m_firmware.size() == 8))
    {
        if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_LCD))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "ClearGrass Temp & RH") && (m_firmware.size() == 10))
    {
        if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_EINK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "LYWSD02") && (m_firmware.size() == 10))
    {
        if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_CLOCK))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }
    else if ((m_deviceName == "LYWSD03MMC") && (m_firmware.size() == 10))
    {
        if (Version(m_firmware) >= Version(LATEST_KNOWN_FIRMWARE_HYGROTEMP_SQUARE))
        {
            m_firmware_uptodate = true;
            Q_EMIT sensorUpdated();
        }
    }

    return status;
}

bool DeviceSensors::getSqlLimits()
{
    //qDebug() << "DeviceSensors::getSqlLimits(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery getLimits;
    getLimits.prepare("SELECT hygroMin, hygroMax, tempMin, tempMax, lumiMin, lumiMax, conduMin, conduMax "
                      "FROM limits WHERE deviceAddr = :deviceAddr");
    getLimits.bindValue(":deviceAddr", getAddress());
    getLimits.exec();
    while (getLimits.next())
    {
        m_limitHygroMin = getLimits.value(0).toInt();
        m_limitHygroMax = getLimits.value(1).toInt();
        m_limitTempMin = getLimits.value(2).toInt();
        m_limitTempMax = getLimits.value(3).toInt();
        m_limitLumiMin = getLimits.value(4).toInt();
        m_limitLumiMax = getLimits.value(5).toInt();
        m_limitConduMin = getLimits.value(6).toInt();
        m_limitConduMax = getLimits.value(7).toInt();

        status = true;
        Q_EMIT limitsUpdated();
    }

    return status;
}

bool DeviceSensors::getSqlData(int minutes)
{
    //qDebug() << "DeviceSensors::getSqlData(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedData;
    cachedData.prepare("SELECT temp, hygro, luminosity, conductivity, ts_full " \
                       "FROM datas " \
                       "WHERE deviceAddr = :deviceAddr AND ts_full >= datetime('now', 'localtime', '-" + QString::number(minutes) + " minutes');");
    cachedData.bindValue(":deviceAddr", getAddress());

    if (cachedData.exec() == false)
        qWarning() << "> cachedData.exec() ERROR" << cachedData.lastError().type() << ":" << cachedData.lastError().text();
    else
    {
#ifndef QT_NO_DEBUG
        qDebug() << "* Device update:" << getAddress();
        qDebug() << "> SQL data available...";
#endif
    }

    while (cachedData.next())
    {
        m_temperature = cachedData.value(0).toFloat();
        m_humidity =  cachedData.value(1).toInt();
        m_luminosity = cachedData.value(2).toInt();
        m_soil_moisture =  cachedData.value(1).toInt();
        m_soil_conductivity = cachedData.value(3).toInt();

        QString datetime = cachedData.value(4).toString();
        m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");

        status = true;
    }

    refreshDataFinished(status, true);
    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceSensors::hasData() const
{
    // If we have immediate data (<12h old)
    if (m_humidity > 0 || m_temperature > -20.f || m_luminosity > 0 || m_soil_moisture > 0 || m_soil_conductivity > 0)
        return true;

    // Otherwise, check if we have stored data
    QSqlQuery hasData;
    hasData.prepare("SELECT COUNT(*) FROM datas WHERE deviceAddr = :deviceAddr;");
    hasData.bindValue(":deviceAddr", getAddress());

    if (hasData.exec() == false)
        qWarning() << "> hasData.exec() ERROR" << hasData.lastError().type() << ":" << hasData.lastError().text();

    while (hasData.next())
    {
        if (hasData.value(0).toInt() > 0) // data count
            return true;
    }

    return false;
}

bool DeviceSensors::hasData(const QString &dataName) const
{
    // If we have immediate data (<12h old)
    if (dataName == "hygro" && m_humidity > 0)
        return true;
    if (dataName == "temp" && m_temperature > -20.f)
        return true;
    if (dataName == "luminosity" && m_luminosity > 0)
        return true;
    if (dataName == "hygro" && m_soil_moisture > 0)
        return true;
    if (dataName == "conductivity" && m_soil_conductivity > 0)
        return true;

    // Otherwise, check if we have stored data
    QSqlQuery hasData;
    hasData.prepare("SELECT COUNT(" + dataName + ") FROM datas WHERE deviceAddr = :deviceAddr AND " + dataName + " > 0;");
    hasData.bindValue(":deviceAddr", getAddress());

    if (hasData.exec() == false)
        qWarning() << "> hasData.exec() ERROR" << hasData.lastError().type() << ":" << hasData.lastError().text();

    while (hasData.next())
    {
        if (hasData.value(0).toInt() > 0) // data count
            return true;
    }

    return false;
}

int DeviceSensors::countData(const QString &dataName, int days) const
{
    // Count stored data
    QSqlQuery dataCount;
    dataCount.prepare("SELECT COUNT(" + dataName + ")" \
                      "FROM datas " \
                      "WHERE deviceAddr = :deviceAddr " \
                        "AND " + dataName + " > 0 AND ts >= datetime('now','-" + QString::number(days) + " day');");
    dataCount.bindValue(":deviceAddr", getAddress());

    if (dataCount.exec() == false)
        qWarning() << "> dataCount.exec() ERROR" << dataCount.lastError().type() << ":" << dataCount.lastError().text();

    while (dataCount.next())
    {
        return dataCount.value(0).toInt();
    }

    return 0;
}

/* ************************************************************************** */
/* ************************************************************************** */

float DeviceSensors::getTemp() const
{
    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        return getTempF();

    return getTempC();
}

QString DeviceSensors::getTempString() const
{
    QString tempString;

    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        tempString = QString::number(getTempF(), 'f', 1) + "°F";
    else
        tempString = QString::number(getTempC(), 'f', 1) + "°C";

    return tempString;
}

/* ************************************************************************** */

bool DeviceSensors::setDbLimits()
{
    bool status = false;

    QSqlQuery updateLimits;
    updateLimits.prepare("REPLACE INTO limits (deviceAddr, hygroMin, hygroMax, tempMin, tempMax, lumiMin, lumiMax, conduMin, conduMax)"
                         " VALUES (:deviceAddr, :hygroMin, :hygroMax, :tempMin, :tempMax, :lumiMin, :lumiMax, :conduMin, :conduMax)");
    updateLimits.bindValue(":deviceAddr", getAddress());
    updateLimits.bindValue(":hygroMin", m_limitHygroMin);
    updateLimits.bindValue(":hygroMax", m_limitHygroMax);
    updateLimits.bindValue(":tempMin", m_limitTempMin);
    updateLimits.bindValue(":tempMax", m_limitTempMax);
    updateLimits.bindValue(":lumiMin", m_limitLumiMin);
    updateLimits.bindValue(":lumiMax", m_limitLumiMax);
    updateLimits.bindValue(":conduMin", m_limitConduMin);
    updateLimits.bindValue(":conduMax", m_limitConduMax);

    status = updateLimits.exec();
    if (status == false)
        qWarning() << "> updateLimits.exec() ERROR" << updateLimits.lastError().type() << ":" << updateLimits.lastError().text();

    Q_EMIT limitsUpdated();

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

QVariantList DeviceSensors::getBackgroundDays(float maxValue, int maxDays)
{
    QVariantList background;

    while (background.size() < maxDays)
    {
        background.append(maxValue);
    }

    return background;
}

/*!
 * \return Last 30 days
 *
 * First day is always xxx
 */
QVariantList DeviceSensors::getLegendDays(int maxDays)
{
    QVariantList legend;
    QString legendFormat = "dd";
    if (maxDays <= 7) legendFormat = "dddd";

    // first day is always today
    QDate currentDay = QDate::currentDate();
    QString d = currentDay.toString(legendFormat);
    if (maxDays <= 7)
    {
        d.truncate(3);
        d += ".";
    }
    legend.push_front(d);

    // then fill the days before that
    while (legend.size() < maxDays)
    {
        currentDay = currentDay.addDays(-1);
        d = currentDay.toString(legendFormat);
        if (maxDays <= 7)
        {
            d.truncate(3);
            d += ".";
        }
        legend.push_front(d);
    }

    return legend;
}

QVariantList DeviceSensors::getDataDays(const QString &dataName, int maxDays)
{
    QVariantList graphData;
    QDate currentDay = QDate::currentDate(); // today
    QDate previousDay;
    QDate firstDay;

    QSqlQuery sqlData;
    sqlData.prepare("SELECT strftime('%Y-%m-%d', ts), avg(" + dataName + ") as 'avg'" \
                    "FROM datas " \
                    "WHERE deviceAddr = :deviceAddr " \
                    "GROUP BY strftime('%Y-%m-%d', ts) " \
                    "ORDER BY ts DESC;");
    sqlData.bindValue(":deviceAddr", getAddress());

    if (sqlData.exec() == false)
    {
        qWarning() << "> dataPerMonth.exec() ERROR" << sqlData.lastError().type() << ":" << sqlData.lastError().text();
    }

    while (sqlData.next())
    {
        QDate datefromsql = sqlData.value(0).toDate();

        // missing day(s)?
        if (previousDay.isValid())
        {
            int diff = datefromsql.daysTo(previousDay);
            for (int i = diff; i > 1; i--)
            {
                //qDebug() << "> filling hole for day" << datefromsql.daysTo(previousDay);
                graphData.push_front(0);
            }
        }

        // data
        graphData.push_front(sqlData.value(1));
        previousDay = datefromsql;
        if (!firstDay.isValid()) firstDay = datefromsql;
        //qDebug() << "> we have data (" << sqlData.value(1) << ") for date" << datefromsql;

        // max days reached?
        if (graphData.size() >= maxDays) break;
    }

    // missing day(s) front?
    while (graphData.size() < maxDays)
    {
        graphData.push_front(0);
    }
    // missing day(s) back?
    int missing = maxDays;
    if (firstDay.isValid()) missing = firstDay.daysTo(currentDay);
    for (int i = missing; i > 0; i--)
    {
        if (graphData.size() >= maxDays) graphData.pop_front();
        graphData.push_back(0);
    }
/*
    // debug
    qDebug() << "Data (" << dataName << "/" << graphData.size() << ") : ";
    for (auto d: graphData) qDebug() << d;
*/
    return graphData;
}

/* ************************************************************************** */
/* ************************************************************************** */

QVariantList DeviceSensors::getDataHours(const QString &dataName)
{
    QVariantList graphData;
    QDateTime currentTime = QDateTime::currentDateTime(); // right now
    QDateTime previousTime;
    QDateTime firstTime;

    QSqlQuery sqlData;
    sqlData.prepare("SELECT strftime('%Y-%m-%d %H:%m:%s', ts), avg(" + dataName + ") as 'avg'" \
                    "FROM datas " \
                    "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day') " \
                    "GROUP BY strftime('%d-%H', ts) " \
                    "ORDER BY ts DESC;");
    sqlData.bindValue(":deviceAddr", getAddress());

    if (sqlData.exec() == false)
    {
        qWarning() << "> dataPerHour.exec() ERROR" << sqlData.lastError().type() << ":" << sqlData.lastError().text();
    }

    while (sqlData.next())
    {
        QDateTime timefromsql = sqlData.value(0).toDateTime();

        // missing hour(s)?
        if (previousTime.isValid())
        {
            int diff = timefromsql.secsTo(previousTime) / 3600;
            for (int i = diff; i > 1; i--)
            {
                //qDebug() << "> filling hole for hour" << diff;
                graphData.push_front(0);
            }
        }

        // data
        graphData.push_front(sqlData.value(1));
        previousTime = timefromsql;
        if (!firstTime.isValid()) firstTime = timefromsql;
        //qDebug() << "> we have data (" << sqlData.value(1) << ") for hour" << timefromsql;

        // max hours reached?
        if (graphData.size() >= 24) break;
    }

    // missing hour(s) front?
    while (graphData.size() < 24)
    {
        graphData.push_front(0);
    }
    // missing hour(s) back?
    int missing = 24;
    if (firstTime.isValid()) missing = firstTime.secsTo(currentTime) / 3600;
    for (int i = missing; i > 0; i--)
    {
        if (graphData.size() >= 24) graphData.pop_front();
        graphData.push_back(0);
    }
/*
    // debug
    qDebug() << "Data (" << dataName << "/" << graphData.size() << ") : ";
    for (auto d: graphData) qDebug() << d;
*/
    return graphData;
}

/*!
 * \return List of hours
 *
 * Two possibilities:
 * - We have data, so we go from last data available +24
 * - We don't have data, so we go from current hour to +24
 */
QVariantList DeviceSensors::getLegendHours()
{
    QVariantList legend;

    QTime now = QTime::currentTime();
    while (legend.size() < 24)
    {
        legend.push_front(now.hour());
        now = now.addSecs(-3600);
    }
/*
    // debug
    qDebug() << "Hours (" << legend.size() << ") : ";
    for (auto h: legend) qDebug() << h;
*/
    return legend;
}

QVariantList DeviceSensors::getBackgroundDaytime(float maxValue)
{
    QVariantList bgDaytime;

    QTime now = QTime::currentTime();
    while (bgDaytime.size() < 24)
    {
        if (now.hour() >= 21 || now.hour() <= 8)
            bgDaytime.push_front(0);
        else
            bgDaytime.push_front(maxValue);

        now = now.addSecs(-3600);
    }

    return bgDaytime;
}

QVariantList DeviceSensors::getBackgroundNighttime(float maxValue)
{
    QVariantList bgNighttime;

    QTime now = QTime::currentTime();
    while (bgNighttime.size() < 24)
    {
        if (now.hour() >= 21 || now.hour() <= 8)
            bgNighttime.push_front(maxValue);
        else
            bgNighttime.push_front(0);
        now = now.addSecs(-3600);
    }

    return bgNighttime;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensors::updateAioMinMaxData(int maxDays)
{
    qDeleteAll(m_aio_minmax_data);
    m_aio_minmax_data.clear();
    m_tempMin = 999.f;
    m_tempMax = -99.f;
    AioMinMax *previousdata = nullptr;

    QSqlQuery graphData;
    graphData.prepare("SELECT strftime('%Y-%m-%d', ts), min(temp), avg(temp), max(temp), min(hygro), max(hygro) " \
                      "FROM datas " \
                      "WHERE deviceAddr = :deviceAddr " \
                      "GROUP BY strftime('%Y-%m-%d', ts)" \
                      "ORDER BY ts DESC;");
    graphData.bindValue(":deviceAddr", getAddress());

    if (graphData.exec() == false)
    {
        qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
        return;
    }

    while (graphData.next())
    {
        // missing day(s)?
        if (previousdata)
        {
            QDate datefromsql = graphData.value(0).toDate();
            int diff = datefromsql.daysTo(previousdata->getDate());
            for (int i = diff; i > 1; i--)
            {
                QDate fakedate(datefromsql.addDays(i-1));
                m_aio_minmax_data.push_front(new AioMinMax(fakedate, -99, -99, -99, -99, -99, this));
            }
        }

        // data
        if (graphData.value(1).toFloat() < m_tempMin) { m_tempMin = graphData.value(1).toFloat(); }
        if (graphData.value(3).toFloat() > m_tempMax) { m_tempMax = graphData.value(3).toFloat(); }
        if (graphData.value(4).toInt() < m_hygroMin) { m_hygroMin = graphData.value(4).toInt(); }
        if (graphData.value(5).toInt() > m_hygroMax) { m_hygroMax = graphData.value(5).toInt(); }

        AioMinMax *d = new AioMinMax(graphData.value(0).toDate(),
                                     graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                     graphData.value(4).toInt(), graphData.value(5).toInt(), this);
        m_aio_minmax_data.push_front(d);
        previousdata = d;

        // max days reached?
        if (m_aio_minmax_data.size() >= maxDays) break;
    }

    // missing day(s)?
    {
        QDate today = QDate::currentDate();
        int missing = maxDays;
        if (previousdata) missing = static_cast<AioMinMax *>(m_aio_minmax_data.last())->getDate().daysTo(today);

        for (int i = missing - 1; i >= 0; i--)
        {
            QDate fakedate(today.addDays(-i));
            m_aio_minmax_data.push_back(new AioMinMax(fakedate, -99, -99, -99, -99, -99, this));
        }
    }

    Q_EMIT minmaxUpdated();
    Q_EMIT aioMinMaxDataUpdated();
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensors::getAioLinesData(int maxDays,
                             QtCharts::QDateTimeAxis *axis,
                             QtCharts::QLineSeries *hygro, QtCharts::QLineSeries *temp,
                             QtCharts::QLineSeries *lumi, QtCharts::QLineSeries *cond)
{
    if (!axis || !hygro || !temp || !lumi || !cond)
        return;

    QSqlQuery graphData;
    graphData.prepare("SELECT temp, hygro, luminosity, conductivity, ts_full " \
                      "FROM datas " \
                      "WHERE deviceAddr = :deviceAddr AND ts_full >= datetime('now', 'localtime', '-" + QString::number(maxDays) + " days');");
    graphData.bindValue(":deviceAddr", getAddress());

    if (graphData.exec() == false)
    {
        qWarning() << "> graphData.exec() ERROR" << graphData.lastError().type() << ":" << graphData.lastError().text();
        return;
    }

    axis->setFormat("dd MMM");
    axis->setMax(QDateTime::currentDateTime());
    bool minSet = false;
    bool minmaxChanged = false;

    while (graphData.next())
    {
        QDateTime date = QDateTime::fromString(graphData.value(4).toString(), "yyyy-MM-dd hh:mm:ss");
        if (!minSet) {
            axis->setMin(date);
            minSet = true;
        }
        qint64 timecode = date.toMSecsSinceEpoch();

        temp->append(timecode, graphData.value(0).toReal());
        hygro->append(timecode, graphData.value(1).toReal());
        lumi->append(timecode, graphData.value(2).toReal());
        cond->append(timecode, graphData.value(3).toReal());

        if (graphData.value(0).toFloat() < m_tempMin) { m_tempMin = graphData.value(0).toFloat(); minmaxChanged = true; }
        if (graphData.value(1).toInt() < m_hygroMin) { m_hygroMin = graphData.value(1).toInt(); minmaxChanged = true; }
        if (graphData.value(2).toInt() < m_luminosityMin) { m_luminosityMin = graphData.value(2).toInt(); minmaxChanged = true; }
        if (graphData.value(3).toInt() < m_conductivityMin) { m_conductivityMin = graphData.value(3).toInt(); minmaxChanged = true; }

        if (graphData.value(0).toFloat() > m_tempMax) { m_tempMax = graphData.value(0).toFloat(); minmaxChanged = true; }
        if (graphData.value(1).toInt() > m_hygroMax) { m_hygroMax = graphData.value(1).toInt(); minmaxChanged = true; }
        if (graphData.value(2).toInt() > m_luminosityMax) { m_luminosityMax = graphData.value(2).toInt(); minmaxChanged = true; }
        if (graphData.value(3).toInt() > m_conductivityMax) { m_conductivityMax = graphData.value(3).toInt(); minmaxChanged = true; }
    }

    if (minmaxChanged) { Q_EMIT minmaxUpdated(); }
}

/* ************************************************************************** */
