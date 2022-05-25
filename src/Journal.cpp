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

#include "Journal.h"

#include <QSqlQuery>
#include <QSqlError>

#include <QDebug>
#include <QString>

/* ************************************************************************** */

JournalEntry::JournalEntry(QObject *parent) : QObject(parent)
{
    //
}

JournalEntry::JournalEntry(const QString &deviceAddr, const int plantId, const int entryId,
                           const int type, const QDateTime &date, const QString &comment,
                           QObject *parent) : QObject(parent)
{
    //qDebug() << "JournalEntry : " << type << date << comment;

    m_deviceId = deviceAddr;
    m_plantId = plantId;

    m_entryType = type;
    m_entryDate = date;
    m_entryComment = comment;
}

/* ************************************************************************** */

bool JournalEntry::addEntry(const QString &addr, const int type, const QDateTime &date, const QString &comment)
{
    qDebug() << "JournalEntry::addEntry()";
    bool status = false;

    if (m_entryId < 0)
    {
        // Add in database
        QSqlQuery addEntry;
        addEntry.prepare("INSERT INTO plantJournal (deviceAddr, entryType, entryTimestamp, entryComment)"
                         " VALUES (:addr, :type, :date, :comment)");
        addEntry.bindValue(":addr", addr);
        addEntry.bindValue(":type", type);
        addEntry.bindValue(":date", date.toString("yyyy-MM-dd hh:mm:ss"));
        addEntry.bindValue(":comment", comment);

        if (addEntry.exec())
        {
            // Link back product id
            m_entryId = addEntry.lastInsertId().toInt();

            m_deviceId = addr;
            m_entryType = type;
            m_entryDate = date;
            m_entryComment = comment;

            Q_EMIT entryChanged();
            status = true;
        }
        else
        {
            qWarning() << "> addEntry.exec() ERROR"
                       << addEntry.lastError().type() << ":" << addEntry.lastError().text();
        }
    }
    else
    {
        qWarning() << "> addEntry.exec() ERROR this product already has an ID";
    }

    return status;
}

/* ************************************************************************** */

bool JournalEntry::editEntry(const int type, const QDateTime &date, const QString &comment)
{
    qDebug() << "JournalEntry::editEntry() id:" << m_entryId;
    bool status = false;

    if (m_entryId >= 0)
    {
        // Edit in database
        QSqlQuery editEntry;
        editEntry.prepare("UPDATE plantJournal"
                          " SET entryType = :type, entryTimestamp = :date, entryComment = :comment"
                          " WHERE id = :id");
        editEntry.bindValue(":type", type);
        editEntry.bindValue(":date", date.toString("yyyy-MM-dd hh:mm:ss"));
        editEntry.bindValue(":comment", comment);
        editEntry.bindValue(":id", m_entryId);

        if (editEntry.exec())
        {
            // Edit in cpp
            m_entryType = type;
            m_entryDate = date;
            m_entryComment = comment;

            Q_EMIT entryChanged();
            status = true;
        }
        else
        {
            qWarning() << "> editEntry.exec() ERROR"
                       << editEntry.lastError().type() << ":" << editEntry.lastError().text();
        }
    }
    else
    {
        qWarning() << "> addEntry.exec() ERROR this product already has no ID";
    }

    return status;
}

/* ************************************************************************** */

bool JournalEntry::removeEntry()
{
    qDebug() << "JournalEntry::removeEntry() id:" << m_entryId;
    bool status = false;

    if (m_entryId >= 0)
    {
        // Remove from database
        QSqlQuery removeEntry;
        removeEntry.prepare("DELETE FROM plantJournal WHERE journalId = :id");
        removeEntry.bindValue(":id", m_entryId);

        if (removeEntry.exec())
        {
            m_entryId = -1;
            status = true;
        }
        else
        {
            qWarning() << "> removeEntry.exec() ERROR"
                       << removeEntry.lastError().type() << ":" << removeEntry.lastError().text();
        }
    }

    return status;
}
