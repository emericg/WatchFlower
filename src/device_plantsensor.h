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

#ifndef DEVICE_PLANT_SENSOR_H
#define DEVICE_PLANT_SENSOR_H
/* ************************************************************************** */

#include "device_sensor.h"

#include <QObject>
#include <QString>
#include <QVariant>

#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

class Plant;

/* ************************************************************************** */

/*!
 * \brief The DevicePlantSensor class
 */
class DevicePlantSensor: public DeviceSensor
{
    Q_OBJECT

    Q_PROPERTY(QVariant journalEntries READ getJournalEntries NOTIFY journalUpdated)

    // plant
    int m_plantId = -1;
    QString m_plantName;
    QString m_plantCache;
    QDateTime m_plantStart;
    Plant *m_plant = nullptr;

    // journal entries
    QList <QObject *> m_journal_entries;
    bool loadPlant();
    bool loadJournalEntries();
    QVariant getJournalEntries() const { return QVariant::fromValue(m_journal_entries); }

Q_SIGNALS:
    void journalUpdated();

protected:
    bool areValuesValid(const int sm, const int sc, const float st, const float w,
                        const float t, const float h, const int l) const;
    bool addDatabaseRecord(const int64_t timestamp,
                           const int sm, const int sc, const float st, const float w,
                           const float t, const float h, const int l);

public:
    DevicePlantSensor(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DevicePlantSensor(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DevicePlantSensor();

    // Journal
    Q_INVOKABLE bool addJournalEntry(const int type, const QDateTime &date, const QString &comment);
    Q_INVOKABLE bool removeJournalEntry(const int id);

    // Chart history
    Q_INVOKABLE void updateChartData_history_month(int maxDays);
    Q_INVOKABLE void updateChartData_history_month(const QDateTime &f, const QDateTime &l);
    Q_INVOKABLE void updateChartData_history_day();
    Q_INVOKABLE void updateChartData_history_day(const QDateTime &d);

    // Chart plant AIO
    Q_INVOKABLE void getChartData_plantAIO(int maxDays, QDateTimeAxis *axis,
                                           QLineSeries *hygro, QLineSeries *condu,
                                           QLineSeries *temp, QLineSeries *lumi);
};

/* ************************************************************************** */
#endif // DEVICE_PLANT_SENSOR_H
