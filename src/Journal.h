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

        JOURNAL_COMMENT,
        JOURNAL_PHOTO,

        JOURNAL_WATER,
        JOURNAL_FERTILIZE,
        JOURNAL_PRUNE,
        JOURNAL_ROTATE,
        JOURNAL_MOVE,
        JOURNAL_REPOT,
    };
    Q_ENUM(JournalType)
};

/* ************************************************************************** */

class JournalEntry: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int type READ getType CONSTANT)
    Q_PROPERTY(QDateTime date READ getDateTime CONSTANT)
    Q_PROPERTY(QString comment READ getComment CONSTANT)

    int m_type = -1;
    QDateTime m_date;
    QString m_comment;

    int getType() { return m_type; }
    QDateTime getDateTime() { return m_date; }
    QString getComment() { return m_comment; }

public:
    JournalEntry(const int type, const QDateTime &date, const QString &comment, QObject *parent);
    ~JournalEntry() = default;
};

/* ************************************************************************** */
#endif // JOURNAL_H
