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

#ifndef PLANT_DATABASE_H
#define PLANT_DATABASE_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QVariant>
#include <QList>

class Plant;

/* ************************************************************************** */

class PlantDatabase: public QObject
{
    Q_OBJECT

    QList <QObject *> m_plants;
    Q_PROPERTY(QVariant plants READ getPlants NOTIFY plantsChanged)
    Q_PROPERTY(int plantCount READ getPlantCount NOTIFY plantsChanged)

    QList <QObject *> m_plantsFiltered;
    Q_PROPERTY(QVariant plantsFiltered READ getPlantsFiltered NOTIFY plantsFilteredChanged)
    Q_PROPERTY(int plantCountFiltered READ getPlantCountFiltered NOTIFY plantsFilteredChanged)

    int getPlantCount() { return m_plants.size(); }
    QVariant getPlants() { return QVariant::fromValue(m_plants); }

    int getPlantCountFiltered() { return m_plantsFiltered.size(); }
    QVariant getPlantsFiltered() { return QVariant::fromValue(m_plantsFiltered); }

    bool m_isLoaded = false;
    bool readDB_csv(const QString &path);
    void stats();

    // Singleton
    static PlantDatabase *instance;
    PlantDatabase();
    ~PlantDatabase();

Q_SIGNALS:
    void plantsChanged();
    void plantsFilteredChanged();

public:
    static PlantDatabase *getInstance();

    Q_INVOKABLE bool load();
    Q_INVOKABLE void filter(const QString &filter);

    Q_INVOKABLE Plant *getPlant_p(const QString &name);
    Q_INVOKABLE QVariant getPlant_v(const QString &name);
};

/* ************************************************************************** */
#endif // PLANT_DATABASE_H
