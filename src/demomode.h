/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEMO_MODE_H
#define DEMO_MODE_H
/* ************************************************************************** */

#include <QFile>
#include <QDebug>
#include <QString>
#include <QStandardPaths>

void setup_demo_mode()
{
    QString confPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + ".conf";
    qDebug() << "confPath DEMO : " + confPath;

    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/datas.db";
    qDebug() << "dbPath DEMO : " + dbPath;

    QFile::setPermissions(confPath, QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    QFile::remove(confPath);
    QFile::copy(":/demo/demo_settings.conf", confPath); // Stay RO

    QFile::setPermissions(dbPath, QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    QFile::remove(dbPath);
    QFile::copy(":/demo/demo_bdd.db", dbPath); // Needs RW
    QFile::setPermissions(dbPath, QFileDevice::ReadOwner | QFileDevice::WriteOwner);
}

/* ************************************************************************** */
#endif // DEMO_MODE_H
