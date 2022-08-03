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

#include "Plant.h"

#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

/* ************************************************************************** */

Plant::Plant(QObject *parent) : QObject(parent)
{
    //
}

Plant::Plant(const QString &n, QObject *parent): QObject(parent)
{
    name = n;
}

Plant::~Plant()
{
    //
}

/* ************************************************************************** */

void Plant::computeNames()
{
    name_botanical = name;

    if (name.indexOf('\'') > 0)
    {
        name_botanical = name.left(name.indexOf('\'') - 1);
        name_variety = name.mid(name.indexOf('\''));
        name_botanical_url = name.chopped(name.indexOf('\'') - 1);
    }

    name_botanical_url = name_botanical;
    name_botanical_url = name_botanical_url.replace(' ', '_');
}

/* ************************************************************************** */

void Plant::read_csv_watchflower(const QStringList &plantSections)
{
    //qDebug() << "Plant::read_csv_watchflower(" << pid_display << ")";

    //if (plantSections.size() == 24)
    {
        int i = 0;
        // name
        name = plantSections.at(i++),
        name_common = plantSections.at(i++);
        computeNames();

        // basic infos
        origin = plantSections.at(i++);
        category = plantSections.at(i++);
        //taxonomy = plantSections.at(i++);

        //size_diameter = plantSections.at(i++);
        //size_height = plantSections.at(i++);

        colors_leaf = plantSections.at(i++).split(", ", Qt::SkipEmptyParts);
        colors_bract = plantSections.at(i++).split(", ", Qt::SkipEmptyParts);
        colors_flower = plantSections.at(i++).split(", ", Qt::SkipEmptyParts);
        colors_fruit = plantSections.at(i++).split(", ", Qt::SkipEmptyParts);

        //period_planting = plantSections.at(i++);
        //period_growth = plantSections.at(i++);
        //period_blooming = plantSections.at(i++);
        //period_fruiting = plantSections.at(i++);

        // tags
        tags = plantSections.at(i++).split(", ", Qt::SkipEmptyParts);

        // maintenance infos
        sunlight = plantSections.at(i++);
        watering = plantSections.at(i++);
        //fertilizing = plantSections.at(i++);
        //pruning = plantSections.at(i++);
        //soil = plantSections.at(i++);

        // sensor parameters
        soilRH_min = plantSections.at(i++).toInt();
        soilRH_max = plantSections.at(i++).toInt();
        soilEC_min = plantSections.at(i++).toInt();
        soilEC_max = plantSections.at(i++).toInt();
        soilPH_min = plantSections.at(i++).toFloat();
        soilPH_max = plantSections.at(i++).toFloat();
        envTemp_min = plantSections.at(i++).toInt();
        envTemp_max = plantSections.at(i++).toInt();
        //envTempIdeal_min = plantSections.at(i++).toInt();
        //envTempIdeal_max = plantSections.at(i++).toInt();
        envHumi_min = plantSections.at(i++).toInt();
        envHumi_max = plantSections.at(i++).toInt();
        lightLux_min = plantSections.at(i++).toInt();
        lightLux_max = plantSections.at(i++).toInt();
        lightMmol_min = plantSections.at(i++).toInt();
        lightMmol_max = plantSections.at(i++).toInt();
    }
}

/* ************************************************************************** */

bool Plant::read_json_watchflower(QJsonObject &json)
{
    ///
    if (json.contains("cache") && json["cache"].isString())
        cache_version = json["cache"].toInt();

    ///
    if (json.contains("name") && json["name"].isString())
        name = json["name"].toString();
    if (json.contains("name_common") && json["name_common"].isString())
        name_common = json["name_common"].toString();

    computeNames();

    ///
    if (json.contains("infos") && json["infos"].isObject())
    {
        QJsonObject infos = json["infos"].toObject();

        if (infos.contains("origin") && infos["origin"].isString())
            origin = infos["origin"].toString();
        if (infos.contains("category") && infos["category"].isString())
            category = infos["category"].toString();
        if (infos.contains("type") && infos["type"].isString())
            type = infos["type"].toString();

        if (infos.contains("size_height") && infos["size_height"].isString())
            size_height = infos["size_height"].toString();
        if (infos.contains("size_diameter") && infos["size_diameter"].isString())
            size_diameter = infos["size_diameter"].toString();

        // TODO // periods

        if (infos.contains("colors_leaf") && infos["colors_leaf"].isArray())
        {
            for (const auto &c: infos["colors_leaf"].toArray().toVariantList())
            {
                colors_leaf.push_back(c.toString());
            }
        }
        if (infos.contains("colors_bract") && infos["colors_bract"].isArray())
        {
            for (const auto &c: infos["colors_bract"].toArray().toVariantList())
            {
                colors_bract.push_back(c.toString());
            }
        }
        if (infos.contains("colors_flower") && infos["colors_flower"].isArray())
        {
            for (const auto &c: infos["colors_flower"].toArray().toVariantList())
            {
                colors_flower.push_back(c.toString());
            }
        }
        if (infos.contains("colors_fruit") && infos["colors_fruit"].isArray())
        {
            for (const auto &c: infos["colors_fruit"].toArray().toVariantList())
            {
                colors_fruit.push_back(c.toString());
            }
        }

        if (infos.contains("tags") && infos["tags"].isArray())
        {
            for (const auto &t:infos["tags"].toArray().toVariantList())
            {
                tags.push_back(t.toString());
            }
        }
    }

    ///
    if (json.contains("care") && json["care"].isObject())
    {
        QJsonObject care = json["care"].toObject();

        if (care.contains("sunlight") && care["sunlight"].isString())
            sunlight = care["sunlight"].toString();
        if (care.contains("watering") && care["watering"].isString())
            watering = care["watering"].toString();
        if (care.contains("fertilizing") && care["fertilizing"].isString())
            fertilizing = care["fertilizing"].toString();
        if (care.contains("pruning") && care["pruning"].isString())
            pruning = care["pruning"].toString();
        if (care.contains("soil") && care["soil"].isString())
            soil = care["soil"].toString();
    }

    ///
    if (json.contains("metrics") && json["metrics"].isObject())
    {
        QJsonObject metrics = json["metrics"].toObject();

        if (metrics.contains("soil_rh_min")) soilRH_min = metrics["soil_rh_min"].toInt();
        if (metrics.contains("soil_rh_max")) soilRH_max = metrics["soil_rh_max"].toInt();
        if (metrics.contains("soil_ec_min")) soilEC_min = metrics["soil_ec_min"].toInt();
        if (metrics.contains("soil_ec_max")) soilEC_max = metrics["soil_ec_max"].toInt();
        if (metrics.contains("soil_ph_min")) soilPH_min = metrics["soil_ph_min"].toDouble();
        if (metrics.contains("soil_ph_max")) soilPH_max = metrics["soil_ph_max"].toDouble();

        if (metrics.contains("env_temperature_min")) envTemp_min = metrics["env_temperature_min"].toInt();
        if (metrics.contains("env_temperature_max")) envTemp_max = metrics["env_temperature_max"].toInt();
        if (metrics.contains("env_temperature_ideal_min")) envTempIdeal_min = metrics["env_temperature_ideal_min"].toInt();
        if (metrics.contains("env_temperature_ideal_max")) envTempIdeal_max = metrics["env_temperature_ideal_max"].toInt();
        if (metrics.contains("env_humidity_min")) envHumi_min = metrics["env_humidity_min"].toInt();
        if (metrics.contains("env_humidity_max")) envHumi_max = metrics["env_humidity_max"].toInt();

        if (metrics.contains("light_lux_min")) lightLux_min = metrics["light_lux_min"].toInt();
        if (metrics.contains("light_lux_max")) lightLux_max = metrics["light_lux_max"].toInt();
        if (metrics.contains("light_mmol_min")) lightMmol_min = metrics["light_mmol_min"].toInt();
        if (metrics.contains("light_mmol_max")) lightMmol_max = metrics["light_mmol_max"].toInt();
    }

    return true;
}

/* ************************************************************************** */

void Plant::write_json_watchflower(QJsonObject &jsonObject) const
{
    jsonObject.insert("name", QJsonValue::fromVariant(name));
    if (!name_common.isEmpty()) jsonObject.insert("name_common", QJsonValue::fromVariant(name_common));

    QJsonObject infosObject; ///////////////////////////////////////////////////
    infosObject.insert("origin", QJsonValue::fromVariant(origin));
    infosObject.insert("category", QJsonValue::fromVariant(category));
    infosObject.insert("type", QJsonValue::fromVariant(type));
    infosObject.insert("size_height", QJsonValue::fromVariant(size_height));
    infosObject.insert("size_diameter", QJsonValue::fromVariant(size_diameter));
    infosObject.insert("period_planting", QJsonValue::fromVariant(period_planting));
    infosObject.insert("period_growth", QJsonValue::fromVariant(period_growth));
    infosObject.insert("period_blooming", QJsonValue::fromVariant(period_blooming));
    infosObject.insert("period_fruiting", QJsonValue::fromVariant(period_fruiting));
    infosObject.insert("colors_leaf", QJsonValue::fromVariant(colors_leaf).toArray());
    infosObject.insert("colors_bract", QJsonValue::fromVariant(colors_bract).toArray());
    infosObject.insert("colors_flower", QJsonValue::fromVariant(colors_flower).toArray());
    infosObject.insert("colors_fruit", QJsonValue::fromVariant(colors_fruit).toArray());
    infosObject.insert("tags", QJsonValue::fromVariant(tags).toArray());
    jsonObject.insert("infos", infosObject);

    QJsonObject careObject; ////////////////////////////////////////////////////
    if (!sunlight.isEmpty()) careObject.insert("sunlight", QJsonValue::fromVariant(sunlight));
    if (!watering.isEmpty()) careObject.insert("watering", QJsonValue::fromVariant(watering));
    if (!fertilizing.isEmpty()) careObject.insert("fertilizing", QJsonValue::fromVariant(fertilizing));
    if (!pruning.isEmpty()) careObject.insert("pruning", QJsonValue::fromVariant(pruning));
    if (!soil.isEmpty()) careObject.insert("soil", QJsonValue::fromVariant(soil));
    jsonObject.insert("care", careObject);

    QJsonObject metricsObject; /////////////////////////////////////////////////
    if (soilRH_min > -99 && soilRH_max > -99)
    {
        metricsObject.insert("soil_rh_min", QJsonValue::fromVariant(soilRH_min));
        metricsObject.insert("soil_rh_max", QJsonValue::fromVariant(soilRH_max));
    }
    if (soilEC_min > -99 && soilEC_max > -99)
    {
        metricsObject.insert("soil_ec_min", QJsonValue::fromVariant(soilEC_min));
        metricsObject.insert("soil_ec_max", QJsonValue::fromVariant(soilEC_max));
    }
    if (soilPH_min > -99.f && soilPH_max > -99.f)
    {
        metricsObject.insert("soil_ph_min", QJsonValue::fromVariant(soilPH_min));
        metricsObject.insert("soil_ph_max", QJsonValue::fromVariant(soilPH_max));
    }
    if (envTemp_min > -99 && envTemp_max > -99)
    {
        metricsObject.insert("env_temperature_min", QJsonValue::fromVariant(envTemp_min));
        metricsObject.insert("env_temperature_max", QJsonValue::fromVariant(envTemp_max));
    }
    if (envTempIdeal_min > -99 && envTempIdeal_max > -99)
    {
        metricsObject.insert("env_temperature_ideal_min", QJsonValue::fromVariant(envTempIdeal_min));
        metricsObject.insert("env_temperature_ideal_max", QJsonValue::fromVariant(envTempIdeal_max));
    }
    if (envHumi_min > -99 && envHumi_max > -99)
    {
        metricsObject.insert("env_humidity_min", QJsonValue::fromVariant(envHumi_min));
        metricsObject.insert("env_humidity_max", QJsonValue::fromVariant(envHumi_max));
    }
    if (lightLux_min > -99 && lightLux_max > -99)
    {
        metricsObject.insert("light_lux_min", QJsonValue::fromVariant(lightLux_min));
        metricsObject.insert("light_lux_max", QJsonValue::fromVariant(lightLux_max));
    }
    if (lightMmol_min > -99 && lightMmol_max > -99)
    {
        metricsObject.insert("light_mmol_min", QJsonValue::fromVariant(lightMmol_min));
        metricsObject.insert("light_mmol_max", QJsonValue::fromVariant(lightMmol_max));
    }
    jsonObject.insert("metrics", metricsObject);
}

/* ************************************************************************** */

void Plant::print() const
{
    qDebug() << "Plant::print()";

    qDebug() << ">" << name;
    qDebug() << ">" << name_botanical;
    qDebug() << ">" << name_botanical_url;
    qDebug() << ">" << name_variety;
    qDebug() << ">" << name_common;

    qDebug() << "* basic infos";
    qDebug() << "- origin:  " << origin;
    qDebug() << "- category:" << category;
    qDebug() << "- type:" << type;
    qDebug() << "- diameter:" << size_diameter;
    qDebug() << "- height:  " << size_height;
    qDebug() << "- colors leaf:     " << colors_leaf;
    qDebug() << "- colors bract:    " << colors_bract;
    qDebug() << "- colors flower:   " << colors_flower;
    qDebug() << "- colors fruit:    " << colors_fruit;

    qDebug() << "* tags";
    qDebug() << "-" << tags;

    qDebug() << "* calendar";
    qDebug() << "- planting:    " << period_planting;
    qDebug() << "- growth:      " << period_growth;
    qDebug() << "- blooming:    " << period_blooming;
    qDebug() << "- fruiting:    " << period_fruiting;

    qDebug() << "* maintenance infos";
    qDebug() << "-" << sunlight;
    qDebug() << "-" << watering;
    qDebug() << "-" << fertilizing;
    qDebug() << "-" << pruning;
    qDebug() << "-" << soil;

    qDebug() << "* sensor metrics";
    qDebug() << "- soil RH " << soilRH_min << " -> " << soilRH_max;
    qDebug() << "- soil EC " << soilEC_min << " -> " << soilEC_max;
    qDebug() << "- soil PH " << soilPH_min << " -> " << soilPH_max;
    qDebug() << "- air temp" << envTemp_min << " -> " << envTemp_max;
    qDebug() << "- air temp (ideal)" << envTempIdeal_min << " -> " << envTempIdeal_max;
    qDebug() << "- air RH  " << envHumi_min << " -> " << envHumi_max;
    qDebug() << "- light (lux)  " << lightLux_min << " -> " << lightLux_max;
    qDebug() << "- light (mmol) " << lightMmol_min << " -> " << lightMmol_max;

    qDebug() << Qt::endl;
}

bool Plant::stats() const
{
    return false;
}

/* ************************************************************************** */
