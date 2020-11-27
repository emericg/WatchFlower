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

#ifndef DATABASE_MANAGER_H
#define DATABASE_MANAGER_H
/* ************************************************************************** */

#include <QObject>

/* ************************************************************************** */

/*!
 * \brief The DatabaseManager class
 */
class DatabaseManager: public QObject
{
    Q_OBJECT

    // Singleton
    static DatabaseManager *instance;
    DatabaseManager();
    ~DatabaseManager();

    bool m_dbAvailable = false;
    bool m_dbOpen = false;

    bool openDatabase();
    void closeDatabase();

    void createDatabase();
    void resetDatabase();
    void deleteDatabase();

    void migrateDatabase();
    void migrate_v1v2();

public:
    static DatabaseManager *getInstance();

    Q_INVOKABLE bool hasDatabase() const { return m_dbOpen; }
};

/* ************************************************************************** */
#endif // DATABASE_MANAGER_H
