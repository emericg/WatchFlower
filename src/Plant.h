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

#ifndef PLANT_H
#define PLANT_H
/* ************************************************************************** */

#include <QObject>
#include <QList>
#include <QString>

#include <QJsonObject>

/* ************************************************************************** */

class Plant: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(QString nameBotanical READ getNameBotanical CONSTANT)
    Q_PROPERTY(QString nameBotanical_url READ getNameBotanical_url CONSTANT)
    Q_PROPERTY(QString nameVariety READ getNameVariety CONSTANT)
    Q_PROPERTY(QString nameCommon READ getNameCommon CONSTANT)

    Q_PROPERTY(QString origin READ getOrigin CONSTANT)
    Q_PROPERTY(QString category READ getCategory CONSTANT)
    Q_PROPERTY(QString taxonomy READ getTaxonomy CONSTANT)
    Q_PROPERTY(QString type READ getType CONSTANT)

    Q_PROPERTY(QString hardiness READ getHardiness CONSTANT)
    Q_PROPERTY(QString careLevel READ getCareLevel CONSTANT)
    Q_PROPERTY(QString growthRate READ getGrowthRate CONSTANT)
    Q_PROPERTY(QString foliage READ getFoliage CONSTANT)
    Q_PROPERTY(QStringList tags READ getTags CONSTANT)

    Q_PROPERTY(QString diameter READ getSizeDiameter CONSTANT)
    Q_PROPERTY(QString height READ getSizeHeight CONSTANT)
    Q_PROPERTY(QStringList colorsLeaf READ getColorsLeaf CONSTANT)
    Q_PROPERTY(QStringList colorsBract READ getColorsBract CONSTANT)
    Q_PROPERTY(QStringList colorsFlower READ getColorsFlower CONSTANT)
    Q_PROPERTY(QStringList colorsFruit READ getColorsFruit CONSTANT)

    Q_PROPERTY(QString calendarPlanting READ getCalendarPlanting CONSTANT)
    Q_PROPERTY(QString calendarGrowing READ getCalendarGrowth CONSTANT)
    Q_PROPERTY(QString calendarBlooming READ getCalendarBlooming CONSTANT)
    Q_PROPERTY(QString calendarFruiting READ getCalendarFruiting CONSTANT)

    Q_PROPERTY(QString soil READ getSoil CONSTANT)
    Q_PROPERTY(QString sunlight READ getSunlight CONSTANT)
    Q_PROPERTY(QString watering READ getWatering CONSTANT)
    Q_PROPERTY(QString fertilization READ getFertilization CONSTANT)
    Q_PROPERTY(QString pruning READ getPruning CONSTANT)

    Q_PROPERTY(int soilMoist_min READ getSoilMoist_min CONSTANT)
    Q_PROPERTY(int soilMoist_max READ getSoilMoist_max CONSTANT)
    Q_PROPERTY(int soilCondu_min READ getSoilCondu_min CONSTANT)
    Q_PROPERTY(int soilCondu_max READ getSoilCondu_max CONSTANT)
    Q_PROPERTY(float soilPH_min READ getSoilPH_min CONSTANT)
    Q_PROPERTY(float soilPH_max READ getSoilPH_max CONSTANT)
    Q_PROPERTY(float envTemp_min READ getEnvTemp_min CONSTANT)
    Q_PROPERTY(float envTemp_max READ getEnvTemp_max CONSTANT)
    Q_PROPERTY(float envTempIdeal_min READ getEnvTempIdeal_min CONSTANT)
    Q_PROPERTY(float envTempIdeal_max READ getEnvTempIdeal_max CONSTANT)
    Q_PROPERTY(float envHumi_min READ getEnvHumi_min CONSTANT)
    Q_PROPERTY(float envHumi_max READ getEnvHumi_max CONSTANT)
    Q_PROPERTY(int lightLux_min READ getLightLux_min CONSTANT)
    Q_PROPERTY(int lightLux_max READ getLightLux_max CONSTANT)
    Q_PROPERTY(int lightMmol_min READ getLightMmol_min CONSTANT)
    Q_PROPERTY(int lightMmol_max READ getLightMmol_max CONSTANT)

    int cache_version = 0;

    // names
    QString name;
    QString name_botanical;
    QString name_botanical_url;
    QString name_variety;
    QString name_common;

    // infos
    QString origin;
    QString category;
    QString taxonomy;

    QString careLevel;
    QString growthRate;
    QString hardiness;
    QString foliage;

    QString type;

    QStringList tags;

    QString size_diameter;
    QString size_height;

    QStringList colors_leaf;
    QStringList colors_bract;
    QStringList colors_flower;
    QStringList colors_fruit;

    QString period_planting;
    QString period_growth;
    QString period_blooming;
    QString period_fruiting;

    // maintenance infos
    QString soil;
    QString sunlight;
    QString watering;
    QString fertilizing;
    QString pruning;

    // sensor limits
    int soilRH_min = -99;
    int soilRH_max = -99;
    int soilEC_min = -99;
    int soilEC_max = -99;
    float soilPH_min = -99.f;
    float soilPH_max = -99.f;
    int envTemp_min = -99;
    int envTemp_max = -99;
    int envTempIdeal_min = -99;
    int envTempIdeal_max = -99;
    int envHumi_min = -99;
    int envHumi_max = -99;
    int lightLux_min = -99;
    int lightLux_max = -99;
    int lightMmol_min = -99;
    int lightMmol_max = -99;

    void computeNames();
    const QString &getNameBotanical() { return name_botanical; }
    const QString &getNameBotanical_url() { return name_botanical_url; }
    const QString &getNameVariety() { return name_variety; }
    const QString &getNameCommon() { return name_common; }

    const QString &getOrigin() { return origin; }
    const QString &getCategory() { return category; }
    const QString &getTaxonomy() { return taxonomy; }
    const QString &getType() { return type; }
    QStringList getTags() { return tags; }

    const QString &getCareLevel() { return careLevel; }
    const QString &getGrowthRate() { return growthRate; }
    const QString &getHardiness() { return hardiness; }
    const QString &getFoliage() { return foliage; }

    QStringList getColorsLeaf() { return colors_leaf; }
    QStringList getColorsBract() { return colors_bract; } // unused?
    QStringList getColorsFlower() { return colors_flower; }
    QStringList getColorsFruit() { return colors_fruit; }

    QString getSizeDiameter() { return size_diameter; }
    QString getSizeHeight() { return size_height; }

    QString getCalendarPlanting() { return period_planting; }
    QString getCalendarGrowth() { return period_growth; }
    QString getCalendarBlooming() { return period_blooming; }
    QString getCalendarFruiting() { return period_fruiting; }

    QString getSoil() { return soil; }
    QString getSunlight() { return sunlight; }
    QString getWatering() { return watering; }
    QString getFertilization() { return fertilizing; }
    QString getPruning() { return pruning; }

public:
    int getSoilMoist_min() { return soilRH_min; }
    int getSoilMoist_max() { return soilRH_max; }
    int getSoilCondu_min() { return soilEC_min; }
    int getSoilCondu_max() { return soilEC_max; }
    float getSoilPH_min() { return soilPH_min; }
    float getSoilPH_max() { return soilPH_max; }
    float getEnvTemp_min() { return envTemp_min; }
    float getEnvTemp_max() { return envTemp_max; }
    float getEnvTempIdeal_min() { return envTempIdeal_min; }
    float getEnvTempIdeal_max() { return envTempIdeal_max; }
    float getEnvHumi_min() { return envHumi_min; }
    float getEnvHumi_max() { return envHumi_max; }
    int getLightLux_min() { return lightLux_min; }
    int getLightLux_max() { return lightLux_max; }
    int getLightMmol_min() { return lightMmol_min; }
    int getLightMmol_max() { return lightMmol_max; }

public:
    Plant(const QString &name, QObject *parent = nullptr);
    Plant(QObject *parent = nullptr);
    ~Plant();

    const QString &getName() { return name; }
    QString getNameFilter() { return name + " - " + name_common; }

    void read_csv_watchflower(const QStringList &plantSections);
    bool read_json_watchflower(QJsonObject &json);
    void write_json_watchflower(QJsonObject &json) const;

    void print() const;
    bool stats() const;
};

/* ************************************************************************** */
#endif // PLANT_H
