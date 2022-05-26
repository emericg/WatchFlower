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

#include "device_plantsensor.h"
#include "Journal.h"

#include <QSqlQuery>
#include <QSqlError>

#include <QString>
#include <QByteArray>

/* ************************************************************************** */

DevicePlantSensor::DevicePlantSensor(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    DeviceSensor(deviceAddr, deviceName, parent)
{
    // Load device infos, bias, limits and initial data
    if (m_dbInternal || m_dbExternal)
    {
        getSqlDeviceInfos();

        getSqlPlantBias();
        getSqlPlantLimits();

        // Load initial data into the GUI (if they are no more than 12h old)
        getSqlPlantData(12*60);

        // Load journal entries
        loadJournalEntries();
    }

    // Device infos
    m_deviceInfos = new DeviceInfos(this);
    m_deviceInfos->load(m_deviceName);
}

DevicePlantSensor::DevicePlantSensor(const QBluetoothDeviceInfo &d, QObject *parent):
    DeviceSensor(d, parent)
{
    // Load device infos, bias, limits and initial data
    if (m_dbInternal || m_dbExternal)
    {
        getSqlDeviceInfos();

        getSqlPlantBias();
        getSqlPlantLimits();

        // Load initial data into the GUI (if they are no more than 12h old)
        getSqlPlantData(12*60);

        // Load journal entries
        loadJournalEntries();
    }

    // Device infos
    m_deviceInfos = new DeviceInfos(this);
    m_deviceInfos->load(m_deviceName);
}

DevicePlantSensor::~DevicePlantSensor()
{
    qDeleteAll(m_journal_entries);
    m_journal_entries.clear();
}

/* ************************************************************************** */

bool DevicePlantSensor::loadJournalEntries()
{
    //qDebug() << "DevicePlantSensor::loadJournalEntries()";
    bool status = false;

    m_journal_entries.clear();

    QSqlQuery queryJournalEntries;
    queryJournalEntries.prepare("SELECT plantId, entryId," \
                                " entryType, entryTimestamp, entryComment" \
                                " FROM plantJournal WHERE deviceAddr = :deviceAddr");
    queryJournalEntries.bindValue(":deviceAddr", m_deviceAddress);
    status = queryJournalEntries.exec();

    if (status)
    {
        while (queryJournalEntries.next())
        {
            int plantId = queryJournalEntries.value(0).toInt();
            int entryId = queryJournalEntries.value(1).toInt();
            int entryType = queryJournalEntries.value(2).toInt();
            QDateTime entryDate = queryJournalEntries.value(3).toDateTime();
            QString entryComment = queryJournalEntries.value(4).toString();

            JournalEntry *j = new JournalEntry(m_deviceAddress, plantId, entryId,
                                               entryType, entryDate, entryComment, this);
            if (j)
            {
                // add product
                m_journal_entries.push_back(j);
            }
        }
    }
    else
    {
        qWarning() << "DevicePlantSensor::loadJournalEntries() ERROR querying products";
    }

    if (m_journal_entries.size() > 0) Q_EMIT journalUpdated();
    return status;
}

bool DevicePlantSensor::addJournalEntry(const int type, const QDateTime &date, const QString &comment)
{
    qDebug() << "DevicePlantSensor::addJournalEntry()" << m_deviceAddress << type << date << comment;
    bool status = false;

    JournalEntry *j = new JournalEntry(this);
    if (j)
    {
        if (j->addEntry(m_deviceAddress, type, date, comment))
        {
            m_journal_entries.push_back(j);
            Q_EMIT journalUpdated();
            status = true;
        }
        else
        {
            delete j;
        }
    }

    return status;
}

bool DevicePlantSensor::removeJournalEntry(const int id)
{
    qDebug() << "DevicePlantSensor::removeJournalEntry() id:" << id;
    bool status = false;

    for (auto jj: qAsConst(m_journal_entries))
    {
        JournalEntry *j = qobject_cast<JournalEntry*>(jj);
        if (j && j->getEntryId() == id)
        {
            if (j->removeEntry())
            {
                m_journal_entries.removeOne(j);
                Q_EMIT journalUpdated();
                status = true;
            }

            break;
        }
    }

    return status;
}

/* ************************************************************************** */

void DevicePlantSensor::getChartData_plantAIO(int maxDays, QDateTimeAxis *axis,
                                              QLineSeries *hygro, QLineSeries *condu,
                                              QLineSeries *temp, QLineSeries *lumi)
{
    if (!axis || !hygro || !condu || !temp || !lumi) return;

    if (m_dbInternal || m_dbExternal)
    {
        QString time = "datetime('now', 'localtime', '-" + QString::number(maxDays) + " days')";
        if (m_dbExternal) time = "DATE_SUB(NOW(), INTERVAL " + QString::number(maxDays) + " DAY)";

        QSqlQuery graphData;
        graphData.prepare("SELECT ts_full, soilMoisture, soilConductivity, temperature, luminosity " \
                          "FROM plantData " \
                          "WHERE deviceAddr = :deviceAddr AND ts_full >= " + time + ";");
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
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

            // data
            hygro->append(timecode, graphData.value(1).toReal());
            condu->append(timecode, graphData.value(2).toReal());
            temp->append(timecode, graphData.value(3).toReal());
            lumi->append(timecode, graphData.value(4).toReal());

            // min/max
            if (graphData.value(1).toInt() < m_soilMoistureMin) { m_soilMoistureMin = graphData.value(1).toInt(); minmaxChanged = true; }
            if (graphData.value(2).toInt() < m_soilConduMin) { m_soilConduMin = graphData.value(2).toInt(); minmaxChanged = true; }
            if (graphData.value(3).toFloat() < m_tempMin) { m_tempMin = graphData.value(3).toFloat(); minmaxChanged = true; }
            if (graphData.value(4).toInt() < m_luxMin) { m_luxMin = graphData.value(4).toInt(); minmaxChanged = true; }

            if (graphData.value(1).toInt() > m_soilMoistureMax) { m_soilMoistureMax = graphData.value(1).toInt(); minmaxChanged = true; }
            if (graphData.value(2).toInt() > m_soilConduMax) { m_soilConduMax = graphData.value(2).toInt(); minmaxChanged = true; }
            if (graphData.value(3).toFloat() > m_tempMax) { m_tempMax = graphData.value(3).toFloat(); minmaxChanged = true; }
            if (graphData.value(4).toInt() > m_luxMax) { m_luxMax = graphData.value(4).toInt(); minmaxChanged = true; }
        }

        if (minmaxChanged) { Q_EMIT minmaxUpdated(); }
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

void DevicePlantSensor::updateChartData_history_day()
{
    int maxHours = 24;

    qDeleteAll(m_chartData_history_day);
    m_chartData_history_day.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d %H:%M', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-1 day') " \
                              "GROUP BY strftime('%d-%H', ts) " \
                              "ORDER BY ts DESC " \
                              "LIMIT 24;");
        }
        else if (m_dbExternal) // mysql
        {
            graphData.prepare("SELECT DATE_FORMAT(ts, '%Y-%m-%d %H:%M'), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= DATE_SUB(NOW(), INTERVAL -1 DAY) " \
                              "GROUP BY DATE_FORMAT(ts, '%d-%H') " \
                              "ORDER BY ts DESC " \
                              "LIMIT 24;");
        }
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            if (m_chartData_history_day.size() < maxHours)
            {
                // missing hours(s)?
                if (previousdata)
                {
                    QDateTime timefromsql = graphData.value(0).toDateTime();
                    int diff = timefromsql.secsTo(previousdata->getDateTime()) / 3600;
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_history_day.size() < (maxHours-1))
                        {
                            QDateTime fakedate(timefromsql.addSecs((i-1) * 3600));
                            m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // data
                ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                           graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                           graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                           this);
                m_chartData_history_day.push_front(d);
                previousdata = d;
            }
        }

        // missing hour(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxHours;
            if (previousdata) missing = (static_cast<ChartDataHistory *>(m_chartData_history_day.last())->getDateTime().secsTo(today)) / 3600;
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addSecs((-i)*3600));
                m_chartData_history_day.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_history_day.size(); i < maxHours; i++)
            {
                QDateTime fakedate(today.addSecs((-i)*3600));
                m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        // first vs last
        if (m_chartData_history_day.size() > 1)
        {
            while (!m_chartData_history_day.isEmpty() &&
                   static_cast<ChartDataHistory *>(m_chartData_history_day.first())->getHour() ==
                   static_cast<ChartDataHistory *>(m_chartData_history_day.last())->getHour())
            {
                m_chartData_history_day.pop_front();
            }
        }

        Q_EMIT chartDataHistoryDaysUpdated();
    }
}

void DevicePlantSensor::updateChartData_history_day(const QDateTime &d)
{
    qDeleteAll(m_chartData_history_day);
    m_chartData_history_day.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d %H:%M', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND ts BETWEEN '" + d.toString("yyyy-MM-dd 00:00:00") + "' AND '" + d.toString("yyyy-MM-dd 23:59:59") + "' " \
                              "GROUP BY strftime('%d-%H', ts) " \
                              "ORDER BY ts DESC;");
        }
        else if (m_dbExternal) // mysql
        {
            // TODO
        }
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            if (m_chartData_history_day.size() < 24)
            {
                // missing hours(s)?
                if (previousdata)
                {
                    QDateTime timefromsql = graphData.value(0).toDateTime();
                    int diff = timefromsql.secsTo(previousdata->getDateTime()) / 3600;
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_history_day.size() < 23)
                        {
                            QDateTime fakedate(timefromsql.addSecs((i-1) * 3600));
                            m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // data
                ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                           graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                           graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                           this);
                m_chartData_history_day.push_front(d);
                previousdata = d;
            }
        }

        // missing hour(s)?
        if (previousdata)
        {
            QDateTime first = static_cast<ChartDataHistory *>(m_chartData_history_day.first())->getDateTime();
            QDateTime last = static_cast<ChartDataHistory *>(m_chartData_history_day.last())->getDateTime();

            for (int i = first.time().hour(), h = 1; i > 0; i--, h++)
            {
                QDateTime fakedate(first.addSecs((-h)*3600));
                m_chartData_history_day.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
            for (int i = last.time().hour(), h = 1; i < 23; i++, h++)
            {
                QDateTime fakedate(last.addSecs((h)*3600));
                m_chartData_history_day.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }
        else
        {
            for (int i = 0; i < 24; i++)
            {
                QDateTime fakedate(d.date(), QTime(i, 0, 0));
                m_chartData_history_day.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        Q_EMIT chartDataHistoryDaysUpdated();
    }
}

/* ************************************************************************** */

void DevicePlantSensor::updateChartData_history_month(int maxDays)
{
    if (maxDays <= 0) return;
    int maxMonths = 1;

    qDeleteAll(m_chartData_history_month);
    m_chartData_history_month.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity), " \
                              " max(temperature), max(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= datetime('now','-" + QString::number(maxMonths) + " month') " \
                              "GROUP BY strftime('%Y-%m-%d', ts) " \
                              "ORDER BY ts DESC "
                              "LIMIT :maxDays;");
        }
        else if (m_dbExternal) // mysql
        {
            graphData.prepare("SELECT DATE_FORMAT(ts, '%Y-%m-%d'), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity), " \
                              " max(temperature), max(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr AND ts >= DATE_SUB(NOW(), INTERVAL -" + QString::number(maxMonths) + " MONTH) " \
                              "GROUP BY DATE_FORMAT(ts, '%Y-%m-%d') " \
                              "ORDER BY ts DESC "
                              "LIMIT :maxDays;");
        }
        graphData.bindValue(":deviceAddr", getAddress());
        graphData.bindValue(":maxDays", maxDays);

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        bool minmaxChanged = false;

        while (graphData.next())
        {
            if (m_chartData_history_month.size() < maxDays)
            {
                // missing day(s)?
                if (previousdata)
                {
                    QDateTime datefromsql = graphData.value(0).toDateTime();
                    int diff = datefromsql.daysTo(previousdata->getDateTime());
                    for (int i = diff; i > 1; i--)
                    {
                        if (m_chartData_history_month.size() < (maxDays-1))
                        {
                            QDateTime fakedate(datefromsql.addDays(i-1));
                            m_chartData_history_month.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                        }
                    }
                }

                // min/max
                if (graphData.value(1).toInt() < m_soilMoistureMin) { m_soilMoistureMin = graphData.value(1).toInt(); minmaxChanged = true; }
                if (graphData.value(2).toInt() < m_soilConduMin) { m_soilConduMin = graphData.value(2).toInt(); minmaxChanged = true; }
                if (graphData.value(3).toFloat() < m_soilTempMin) { m_soilTempMin = graphData.value(3).toFloat(); minmaxChanged = true; }
                if (graphData.value(4).toFloat() < m_tempMin) { m_tempMin = graphData.value(4).toFloat(); minmaxChanged = true; }
                if (graphData.value(5).toInt() < m_humiMin) { m_humiMin = graphData.value(5).toInt(); minmaxChanged = true; }
                if (graphData.value(6).toInt() < m_luxMin) { m_luxMin = graphData.value(6).toInt(); minmaxChanged = true; }

                if (graphData.value(1).toInt() > m_soilMoistureMax) { m_soilMoistureMax = graphData.value(1).toInt(); minmaxChanged = true; }
                if (graphData.value(2).toInt() > m_soilConduMax) { m_soilConduMax = graphData.value(2).toInt(); minmaxChanged = true; }
                if (graphData.value(3).toFloat() > m_soilTempMax) { m_soilTempMax = graphData.value(3).toFloat(); minmaxChanged = true; }
                if (graphData.value(4).toFloat() > m_tempMax) { m_tempMax = graphData.value(4).toFloat(); minmaxChanged = true; }
                if (graphData.value(5).toInt() > m_humiMax) { m_humiMax = graphData.value(5).toInt(); minmaxChanged = true; }
                if (graphData.value(6).toInt() > m_luxMax) { m_luxMax = graphData.value(6).toInt(); minmaxChanged = true; }

                // data
                ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                           graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                           graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                           graphData.value(7).toFloat(), graphData.value(8).toFloat(),
                                                           this);
                m_chartData_history_month.push_front(d);
                previousdata = d;
            }
        }

        if (minmaxChanged) { Q_EMIT minmaxUpdated(); }

        // missing day(s)?
        {
            // after
            QDateTime today = QDateTime::currentDateTime();
            int missing = maxDays;
            if (previousdata) missing = static_cast<ChartDataHistory *>(m_chartData_history_month.last())->getDateTime().daysTo(today);
            for (int i = missing - 1; i >= 0; i--)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_history_month.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }

            // before
            today = QDateTime::currentDateTime();
            for (int i = m_chartData_history_month.size(); i < maxDays; i++)
            {
                QDateTime fakedate(today.addDays(-i));
                m_chartData_history_month.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        // first vs last (for months less than 31 days long)
        if (m_chartData_history_month.size() > 1)
        {
            while (!m_chartData_history_month.isEmpty() &&
                   static_cast<ChartDataHistory *>(m_chartData_history_month.first())->getDay() ==
                   static_cast<ChartDataHistory *>(m_chartData_history_month.last())->getDay())
            {
                m_chartData_history_month.pop_front();
            }
        }

        // weekly graph
        {
            //qDeleteAll(m_chartData_history_week); // we only stores refs
            m_chartData_history_week.clear();

            int sz = m_chartData_history_month.size() - 1;
            for (int j = sz; j > 0; j--)
            {
                m_chartData_history_week.push_front(m_chartData_history_month.at(j));
                if (m_chartData_history_week.size() >= 7) break;
            }

            Q_EMIT chartDataHistoryWeeksUpdated();
        }

        Q_EMIT chartDataHistoryMonthsUpdated();
    }
}

void DevicePlantSensor::updateChartData_history_month(const QDateTime &f, const QDateTime &l)
{
    if (!f.isValid() || !l.isValid()) return;
    int maxDays = 7;

    //qDebug() << "updateChartData_history_month > " << f << " - " << l;

    //qDeleteAll(m_chartData_history_week);
    m_chartData_history_week.clear();
    ChartDataHistory *previousdata = nullptr;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery graphData;
        if (m_dbInternal) // sqlite
        {
            graphData.prepare("SELECT strftime('%Y-%m-%d', ts), " \
                              " avg(soilMoisture), avg(soilConductivity), avg(soilTemperature), " \
                              " avg(temperature), avg(humidity), avg(luminosity) " \
                              "FROM plantData " \
                              "WHERE deviceAddr = :deviceAddr " \
                                "AND ts BETWEEN '" + f.toString("yyyy-MM-dd 00:00:00") + "' AND '" + l.toString("yyyy-MM-dd 23:59:59") + "' " \
                              "GROUP BY strftime('%Y-%m-%d', ts) " \
                              "ORDER BY ts DESC;");
        }
        else if (m_dbExternal) // mysql
        {
            // TODO
        }
        graphData.bindValue(":deviceAddr", getAddress());

        if (graphData.exec() == false)
        {
            qWarning() << "> graphData.exec() ERROR"
                       << graphData.lastError().type() << ":" << graphData.lastError().text();
            return;
        }

        while (graphData.next())
        {
            // missing day(s)?
            if (previousdata)
            {
                QDateTime datefromsql = graphData.value(0).toDateTime();
                int diff = datefromsql.daysTo(previousdata->getDateTime());
                for (int i = diff; i > 1; i--)
                {
                    if (m_chartData_history_week.size() < (maxDays-1))
                    {
                        QDateTime fakedate(datefromsql.addDays(i-1));
                        m_chartData_history_week.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
                    }
                }
            }

            // data
            ChartDataHistory *d = new ChartDataHistory(graphData.value(0).toDateTime(),
                                                       graphData.value(1).toFloat(), graphData.value(2).toFloat(), graphData.value(3).toFloat(),
                                                       graphData.value(4).toFloat(), graphData.value(5).toFloat(), graphData.value(6).toFloat(),
                                                       this);
            m_chartData_history_week.push_front(d);
            previousdata = d;
        }

        // missing day(s)?
        if (previousdata)
        {
            QDateTime first = static_cast<ChartDataHistory *>(m_chartData_history_week.first())->getDateTime();
            QDateTime last = static_cast<ChartDataHistory *>(m_chartData_history_week.last())->getDateTime();

            for (int i = first.daysTo(f), d = -1; i < 0; i++, d--)
            {
                QDateTime fakedate(first.addDays(d));
                m_chartData_history_week.push_front(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
            for (int i = 0; i < last.daysTo(l); i++)
            {
                QDateTime fakedate(last.addDays(i+1));
                m_chartData_history_week.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }
        else
        {
            for (int i = 0; i < maxDays; i++)
            {
                QDateTime fakedate(f.addDays(i));
                m_chartData_history_week.push_back(new ChartDataHistory(fakedate, -99, -99, -99, -99, -99, -99, this));
            }
        }

        Q_EMIT chartDataHistoryWeeksUpdated();
    }
}

/* ************************************************************************** */
