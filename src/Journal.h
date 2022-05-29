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

#ifndef JOURNAL_H
#define JOURNAL_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QQmlApplicationEngine>

/* ************************************************************************** */

class JournalUtils: public QObject
{
    Q_OBJECT

public:
    static void registerQML()
    {
        qRegisterMetaType<JournalUtils::JournalType>("JournalUtils::JournalType");

        qmlRegisterType<JournalUtils>("JournalUtils", 1, 0, "JournalUtils");
    }

    enum JournalType {
        JOURNAL_UNKNOWN          = 0,

        JOURNAL_WATER,
        JOURNAL_FERTILIZE,
        JOURNAL_PRUNE,
        JOURNAL_ROTATE,
        JOURNAL_MOVE,
        JOURNAL_REPOT,

        JOURNAL_PHOTO,
        JOURNAL_COMMENT,
    };
    Q_ENUM(JournalType)
};

/* ************************************************************************** */

class JournalEntry: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int id READ getEntryId NOTIFY entryChanged)
    Q_PROPERTY(int type READ getEntryType NOTIFY entryChanged)
    Q_PROPERTY(QDateTime date READ getEntryDateTime NOTIFY entryChanged)
    Q_PROPERTY(QString comment READ getEntryComment NOTIFY entryChanged)

    QString m_deviceId;
    int m_plantId = -1;

    int m_entryId = -1;
    int m_entryType = -1;
    QDateTime m_entryDate;
    QString m_entryComment;

Q_SIGNALS:
    void entryChanged();

public:
    JournalEntry(QObject *parent);
    JournalEntry(const int plantId, const int entryId,
                 const int type, const QDateTime &date, const QString &comment, QObject *parent);
    ~JournalEntry() = default;

    bool addEntry(const int plantId,
                  const int type, const QDateTime &date, const QString &comment);
    Q_INVOKABLE bool editEntry(const int type, const QDateTime &date, const QString &comment);
    bool removeEntry();

    int getEntryId() { return m_entryId; }
    int getEntryType() { return m_entryType; }
    QDateTime getEntryDateTime() { return m_entryDate; }
    QString getEntryComment() { return m_entryComment; }

};

/* ************************************************************************** */
#endif // JOURNAL_H
