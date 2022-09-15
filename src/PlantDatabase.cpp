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

#include "PlantDatabase.h"
#include "Plant.h"

#include <QDir>
#include <QFile>
#include <QStringList>

#include <QDebug>

/* ************************************************************************** */

PlantDatabase *PlantDatabase::instance = nullptr;

PlantDatabase *PlantDatabase::getInstance()
{
    if (instance == nullptr)
    {
        instance = new PlantDatabase();
    }

    return instance;
}

PlantDatabase::PlantDatabase()
{
    //
}

PlantDatabase::~PlantDatabase()
{
    m_plantsFiltered.clear();

    qDeleteAll(m_plants);
    m_plants.clear();
}

/* ************************************************************************** */

bool PlantDatabase::load()
{
    bool status = true;

    if (!m_isLoaded)
    {
        status = readDB_csv(":/plants/watchflower_plantdb.csv");
        stats();
    }

    return status;
}

void PlantDatabase::stats()
{
    qDebug() << "PlantDatabase::readDB()" << m_plants.count() << "items in DB";
}

void PlantDatabase::filter(const QString &filter)
{
    //qDebug() << "PlantDatabase::filter()" << filter;

    m_plantsFiltered.clear();

    for (auto pp: qAsConst(m_plants))
    {
        Plant *p = qobject_cast<Plant*>(pp);

        if (p->getNameFilter().toLower().contains(filter.toLower()))
        {
            m_plantsFiltered.push_back(p);
        }
    }

    Q_EMIT plantsFilteredChanged();
}

/* ************************************************************************** */

Plant *PlantDatabase::getPlant_p(const QString &name)
{
    load();

    for (auto pp: qAsConst(m_plants))
    {
        Plant *p = qobject_cast<Plant *>(pp);
        if (p->getName() == name)
        {
            return p;
        }
    }

    return nullptr;
}

QVariant PlantDatabase::getPlant_v(const QString &name)
{
    return QVariant::fromValue(getPlant_p(name));
}

/* ************************************************************************** */

bool PlantDatabase::readDB_csv(const QString &path)
{
    //qDebug() << "PlantDatabase::readDB_csv()";
    bool status = true;

    QFile plantDB(path);
    if (plantDB.open(QFile::ReadOnly))
    {
        QTextStream plants(&plantDB);
        plants.readLine(); // ignore first line, its the legend

        while (!plants.atEnd())
        {
            QString line = plants.readLine();
            if (!line.isEmpty())
            {
                QStringList sections = line.split(';');
                //qDebug() << "> readDB_csv() sections:" << sections.count() << sections;

                if (sections.size() > 1)
                {
                    Plant *ppp = new Plant(sections.at(0));
                    if (ppp)
                    {
                        ppp->read_csv_watchflower(sections);
                        //ppp->print();
                        m_plants.push_back(ppp);
                    }
                }
            }
        }

        m_isLoaded = true;
        Q_EMIT plantsChanged();
    }
    else
    {
        qWarning() << "PlantDatabase::readDB_csv() file do not exists";
    }

    return status;
}

/* ************************************************************************** */
