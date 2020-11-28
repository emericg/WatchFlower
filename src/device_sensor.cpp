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

#include "device_sensor.h"
#include "SettingsManager.h"
#include "DeviceManager.h"
#include "NotificationManager.h"
#include "utils/utils_versionchecker.h"

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

DeviceSensor::DeviceSensor(QString &deviceAddr, QString &deviceName, QObject *parent) :
    Device(deviceAddr, deviceName, parent)
{
    // Load device infos and limits
    getSqlInfos();
    getSqlLimits();
    // Load initial data into the GUI (if they are no more than 12h old)
    getSqlData(12*60);

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensor::refreshDataCanceled);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &DeviceSensor::refreshStart);
}

DeviceSensor::DeviceSensor(const QBluetoothDeviceInfo &d, QObject *parent) :
    Device(d, parent)
{
    // Load device infos and limits
    getSqlInfos();
    getSqlLimits();
    // Load initial data into the GUI (if they are no more than 12h old)
    getSqlData(12*60);

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &DeviceSensor::refreshDataCanceled);

    // Configure update timer (only started on desktop)
    connect(&m_updateTimer, &QTimer::timeout, this, &DeviceSensor::refreshStart);
}

DeviceSensor::~DeviceSensor()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceSensor::refreshDataFinished(bool status, bool cached)
{
    //qDebug() << "DeviceSensor::refreshDataFinished()" << getAddress() << getName();

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
                        if (!m_associatedName.isEmpty())
                            message = tr("You need to water your '%1' now!").arg(m_associatedName);
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

bool DeviceSensor::getSqlInfos()
{
    //qDebug() << "DeviceSensor::getSqlInfos(" << m_deviceAddress << ")";
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

bool DeviceSensor::getSqlLimits()
{
    //qDebug() << "DeviceSensor::getSqlLimits(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery getLimits;
    getLimits.prepare("SELECT hygroMin, hygroMax, conduMin, conduMax, phMin, phMax, " \
                      " tempMin, tempMax, humiMin, humiMax, " \
                      " luxMin, luxMax, mmolMin, mmolMax " \
                      "FROM plantLimits WHERE deviceAddr = :deviceAddr");
    getLimits.bindValue(":deviceAddr", getAddress());
    getLimits.exec();
    while (getLimits.next())
    {
        m_limitHygroMin = getLimits.value(0).toInt();
        m_limitHygroMax = getLimits.value(1).toInt();
        m_limitConduMin = getLimits.value(2).toInt();
        m_limitConduMax = getLimits.value(3).toInt();
        m_limitPhMin = getLimits.value(4).toInt();
        m_limitPhMax = getLimits.value(5).toInt();
        m_limitTempMin = getLimits.value(6).toInt();
        m_limitTempMax = getLimits.value(7).toInt();
        m_limitHumiMin = getLimits.value(8).toInt();
        m_limitHumiMax = getLimits.value(9).toInt();
        m_limitLuxMin = getLimits.value(10).toInt();
        m_limitLuxMax = getLimits.value(11).toInt();
        m_limitMmolMin = getLimits.value(12).toInt();
        m_limitMmolMax = getLimits.value(13).toInt();

        status = true;
        Q_EMIT limitsUpdated();
    }

    return status;
}

bool DeviceSensor::getSqlData(int minutes)
{
    //qDebug() << "DeviceSensor::getSqlData(" << m_deviceAddress << ")";
    bool status = false;

    QSqlQuery cachedData;
    cachedData.prepare("SELECT ts_full, soilMoisture, soilConductivity, soilTemperature, temperature, humidity, luminosity " \
                       "FROM plantData " \
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
        m_soil_moisture =  cachedData.value(1).toInt();
        m_soil_conductivity = cachedData.value(2).toInt();
        m_soil_temperature = cachedData.value(3).toFloat();
        m_temperature = cachedData.value(4).toFloat();
        m_humidity =  cachedData.value(5).toInt();
        m_luminosity = cachedData.value(6).toInt();

        QString datetime = cachedData.value(0).toString();
        m_lastUpdate = QDateTime::fromString(datetime, "yyyy-MM-dd hh:mm:ss");

        status = true;
    }

    refreshDataFinished(status, true);
    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceSensor::hasData() const
{
    // If we have immediate data (<12h old)
    if ( m_soil_moisture > 0 || m_soil_conductivity > 0 || m_soil_temperature > 0 || m_temperature > -20.f || m_humidity > 0 || m_luminosity > 0)
        return true;

    // Otherwise, check if we have stored data
    QSqlQuery hasData;
    hasData.prepare("SELECT COUNT(*) FROM plantData WHERE deviceAddr = :deviceAddr;");
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

bool DeviceSensor::hasData(const QString &dataName) const
{
    // If we have immediate data (<12h old)
    if (dataName == "soilMoisture" && m_soil_moisture > 0)
        return true;
    if (dataName == "soilConductivity" && m_soil_conductivity > 0)
        return true;
    if (dataName == "soilTemperature" && m_soil_temperature > 0)
        return true;
    if (dataName == "temperature" && m_temperature > -20.f)
        return true;
    if (dataName == "humidity" && m_humidity > 0)
        return true;
    if (dataName == "luminosity" && m_luminosity > 0)
        return true;

    // Otherwise, check if we have stored data
    QSqlQuery hasData;
    hasData.prepare("SELECT COUNT(" + dataName + ") FROM plantData WHERE deviceAddr = :deviceAddr AND " + dataName + " > 0;");
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

int DeviceSensor::countData(const QString &dataName, int days) const
{
    // Count stored data
    QSqlQuery dataCount;
    dataCount.prepare("SELECT COUNT(" + dataName + ")" \
                      "FROM plantData " \
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

float DeviceSensor::getTemp() const
{
    SettingsManager *s = SettingsManager::getInstance();
    if (s->getTempUnit() == "F")
        return getTempF();

    return getTempC();
}

QString DeviceSensor::getTempString() const
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

bool DeviceSensor::setDbLimits()
{
    bool status = false;

    QSqlQuery updateLimits;
    updateLimits.prepare("REPLACE INTO plantLimits (deviceAddr, hygroMin, hygroMax, conduMin, conduMax, phMin, phMax, tempMin, tempMax, humiMin, humiMax, luxMin, luxMax, mmolMin, mmolMax)"
                         " VALUES (:deviceAddr, :hygroMin, :hygroMax, :conduMin, :conduMax, :phMin, :phMax, :tempMin, :tempMax, :humiMin, :humiMax, :luxMin, :luxMax, :mmolMin, :mmolMax)");
    updateLimits.bindValue(":deviceAddr", getAddress());
    updateLimits.bindValue(":hygroMin", m_limitHygroMin);
    updateLimits.bindValue(":hygroMax", m_limitHygroMax);
    updateLimits.bindValue(":conduMin", m_limitConduMin);
    updateLimits.bindValue(":conduMax", m_limitConduMax);
    updateLimits.bindValue(":phMin", m_limitPhMin);
    updateLimits.bindValue(":phMax", m_limitPhMax);
    updateLimits.bindValue(":tempMin", m_limitTempMin);
    updateLimits.bindValue(":tempMax", m_limitTempMax);
    updateLimits.bindValue(":humiMin", m_limitHumiMin);
    updateLimits.bindValue(":humiMax", m_limitHumiMax);
    updateLimits.bindValue(":luxMin", m_limitLuxMin);
    updateLimits.bindValue(":luxMax", m_limitLuxMax);
    updateLimits.bindValue(":mmolMin", m_limitMmolMin);
    updateLimits.bindValue(":mmolMax", m_limitMmolMax);

    status = updateLimits.exec();
    if (status == false)
        qWarning() << "> updateLimits.exec() ERROR" << updateLimits.lastError().type() << ":" << updateLimits.lastError().text();

    Q_EMIT limitsUpdated();

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

QVariantList DeviceSensor::getBackgroundDays(float maxValue, int maxDays)
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
QVariantList DeviceSensor::getLegendDays(int maxDays)
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

QVariantList DeviceSensor::getDataDays(const QString &dataName, int maxDays)
{
    QVariantList graphData;
    QDate currentDay = QDate::currentDate(); // today
    QDate previousDay;
    QDate firstDay;

    QSqlQuery sqlData;
    sqlData.prepare("SELECT strftime('%Y-%m-%d', ts), avg(" + dataName + ") as 'avg'" \
                    "FROM plantData " \
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

QVariantList DeviceSensor::getDataHours(const QString &dataName)
{
    QVariantList graphData;
    QDateTime currentTime = QDateTime::currentDateTime(); // right now
    QDateTime previousTime;
    QDateTime firstTime;

    QSqlQuery sqlData;
    sqlData.prepare("SELECT strftime('%Y-%m-%d %H:%m:%s', ts), avg(" + dataName + ") as 'avg'" \
                    "FROM plantData " \
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
QVariantList DeviceSensor::getLegendHours()
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

QVariantList DeviceSensor::getBackgroundDaytime(float maxValue)
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

QVariantList DeviceSensor::getBackgroundNighttime(float maxValue)
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

void DeviceSensor::updateAioMinMaxData(int maxDays)
{
    qDeleteAll(m_aio_minmax_data);
    m_aio_minmax_data.clear();
    m_tempMin = 999.f;
    m_tempMax = -99.f;
    AioMinMax *previousdata = nullptr;

    QSqlQuery graphData;
    graphData.prepare("SELECT strftime('%Y-%m-%d', ts), " \
                      " min(temperature), avg(temperature), max(temperature), " \
                      " min(humidity), max(humidity) " \
                      "FROM plantData " \
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

void DeviceSensor::getAioLinesData(int maxDays,
                                   QtCharts::QDateTimeAxis *axis,
                                   QtCharts::QLineSeries *hygro, QtCharts::QLineSeries *condu,
                                   QtCharts::QLineSeries *temp, QtCharts::QLineSeries *lumi)
{
    if (!axis || !hygro || !condu || !temp || !lumi)
        return;

    QSqlQuery graphData;
    graphData.prepare("SELECT ts_full, soilMoisture, soilConductivity, temperature, luminosity " \
                      "FROM plantData " \
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
        QDateTime date = QDateTime::fromString(graphData.value(0).toString(), "yyyy-MM-dd hh:mm:ss");
        if (!minSet)
        {
            axis->setMin(date);
            minSet = true;
        }
        qint64 timecode = date.toMSecsSinceEpoch();

        hygro->append(timecode, graphData.value(1).toReal());
        condu->append(timecode, graphData.value(2).toReal());
        temp->append(timecode, graphData.value(3).toReal());
        lumi->append(timecode, graphData.value(4).toReal());

        if (graphData.value(1).toInt() < m_hygroMin) { m_hygroMin = graphData.value(1).toInt(); minmaxChanged = true; }
        if (graphData.value(2).toInt() < m_conduMin) { m_conduMin = graphData.value(2).toInt(); minmaxChanged = true; }
        if (graphData.value(3).toFloat() < m_tempMin) { m_tempMin = graphData.value(3).toFloat(); minmaxChanged = true; }
        if (graphData.value(4).toInt() < m_luxMin) { m_luxMin = graphData.value(4).toInt(); minmaxChanged = true; }

        if (graphData.value(1).toInt() > m_hygroMax) { m_hygroMax = graphData.value(1).toInt(); minmaxChanged = true; }
        if (graphData.value(2).toInt() > m_conduMax) { m_conduMax = graphData.value(2).toInt(); minmaxChanged = true; }
        if (graphData.value(3).toFloat() > m_tempMax) { m_tempMax = graphData.value(3).toFloat(); minmaxChanged = true; }
        if (graphData.value(4).toInt() > m_luxMax) { m_luxMax = graphData.value(4).toInt(); minmaxChanged = true; }
    }

    if (minmaxChanged) { Q_EMIT minmaxUpdated(); }
}

/* ************************************************************************** */
