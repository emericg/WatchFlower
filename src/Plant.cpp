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

void Plant::read_csv_watchflower(const QStringList &plantSections)
{
    //qDebug() << "Plant::read_csv_watchflower(" << pid_display << ")";

    //if (plantSections.size() == 24)
    {
        // name
        name = plantSections.at(0),
        name_common = plantSections.at(1);
        computeNames();

        // basic infos
        int startAt = 2;
        origin = plantSections.at(startAt + 0);
        category = plantSections.at(startAt + 1);

        size_diameter = plantSections.at(startAt + 2);
        size_height = plantSections.at(startAt + 3);

        colors_leaf = plantSections.at(startAt + 4).split(", ", Qt::SkipEmptyParts);
        colors_bract = plantSections.at(startAt + 5).split(", ", Qt::SkipEmptyParts);
        colors_flower = plantSections.at(startAt + 6).split(", ", Qt::SkipEmptyParts);
        colors_fruit = plantSections.at(startAt + 7).split(", ", Qt::SkipEmptyParts);

        period_planting = plantSections.at(startAt + 8);
        period_growth = plantSections.at(startAt + 9);
        period_blooming = plantSections.at(startAt + 10);
        period_fruiting = plantSections.at(startAt + 11);

        // tags
        tags = plantSections.at(startAt + 12).split(", ", Qt::SkipEmptyParts);

        // maintenance infos
        startAt = 15;
        soil = plantSections.at(startAt + 0);
        sunlight = plantSections.at(startAt + 1);
        watering = plantSections.at(startAt + 2);
        fertilization = plantSections.at(startAt + 3);
        pruning = plantSections.at(startAt + 4);

        // sensor parameters
        startAt = 20;
        soilRH_min = plantSections.at(startAt + 0).toInt();
        soilRH_max = plantSections.at(startAt + 1).toInt();
        soilEC_min = plantSections.at(startAt + 2).toInt();
        soilEC_max = plantSections.at(startAt + 3).toInt();
        soilPH_min = plantSections.at(startAt + 4).toFloat();
        soilPH_max = plantSections.at(startAt + 5).toFloat();
        envTemp_min = plantSections.at(startAt + 6).toInt();
        envTemp_max = plantSections.at(startAt + 7).toInt();
        //envTempIdeal_min = plantSections.at(startAt + 8).toInt();
        //envTempIdeal_max = plantSections.at(startAt + 9).toInt();
        envHumi_min = plantSections.at(startAt + 8).toInt();
        envHumi_max = plantSections.at(startAt + 9).toInt();
        lightLux_min = plantSections.at(startAt + 10).toInt();
        lightLux_max = plantSections.at(startAt + 11).toInt();
        lightMmol_min = plantSections.at(startAt + 12).toInt();
        lightMmol_max = plantSections.at(startAt + 13).toInt();
    }
}

/* ************************************************************************** */

void Plant::read_json_watchflower(QJsonObject &json)
{
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

        if (infos.contains("size_height") && infos["size_height"].isString())
            size_height = infos["size_height"].toString();
        if (infos.contains("size_diameter") && infos["size_diameter"].isString())
            size_diameter = infos["size_diameter"].toString();

        // TODO // periods
        // TODO // colors
        // TODO // tags
    }

    ///
    if (json.contains("care") && json["care"].isObject())
    {
        QJsonObject care = json["care"].toObject();
    }

    ///
    if (json.contains("metrics") && json["metrics"].isObject())
    {
        QJsonObject metrics = json["metrics"].toObject();
    }
}

/* ************************************************************************** */

void Plant::write_json_watchflower(QJsonObject &jsonObject) const
{
    jsonObject.insert("name", QJsonValue::fromVariant(name));
    if (!name_common.isEmpty()) jsonObject.insert("name_common", QJsonValue::fromVariant(name_common));

    QJsonObject infosObject; ///////////////////////////////////////////////////
    infosObject.insert("origin", QJsonValue::fromVariant(origin));
    infosObject.insert("category", QJsonValue::fromVariant(category));
    infosObject.insert("size_height", QJsonValue::fromVariant(size_height));
    infosObject.insert("size_diameter", QJsonValue::fromVariant(size_diameter));
    infosObject.insert("period_planting", QJsonValue::fromVariant(period_planting));
    infosObject.insert("period_growth", QJsonValue::fromVariant(period_growth));
    infosObject.insert("period_blooming", QJsonValue::fromVariant(period_blooming));
    infosObject.insert("period_fruiting", QJsonValue::fromVariant(period_fruiting));
    jsonObject.insert("infos", infosObject);

    // TODO // colors
    // TODO // tags

    QJsonObject careObject; ////////////////////////////////////////////////////
    if (!soil.isEmpty()) careObject.insert("soil", QJsonValue::fromVariant(origin));
    if (!sunlight.isEmpty()) careObject.insert("sunlight", QJsonValue::fromVariant(sunlight));
    if (!watering.isEmpty()) careObject.insert("watering", QJsonValue::fromVariant(watering));
    if (!pruning.isEmpty()) careObject.insert("pruning", QJsonValue::fromVariant(pruning));
    if (!fertilization.isEmpty()) careObject.insert("fertilization", QJsonValue::fromVariant(fertilization));
    jsonObject.insert("care", careObject);

    QJsonObject metricsObject; /////////////////////////////////////////////////
    if (soilRH_min > -99 && soilRH_max > -99)
    {
        metricsObject.insert("soil_moisture_min", QJsonValue::fromVariant(soilRH_min));
        metricsObject.insert("soil_moisture_max", QJsonValue::fromVariant(soilRH_max));
    }
    if (soilEC_min > -99 && soilEC_max > -99)
    {
        metricsObject.insert("soil_conductivity_min", QJsonValue::fromVariant(soilEC_min));
        metricsObject.insert("soil_conductivity_max", QJsonValue::fromVariant(soilEC_max));
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
    qDebug() << "- diameter:" << size_diameter;
    qDebug() << "- height:  " << size_height;
    qDebug() << "- colors leaf:     " << colors_leaf;
    qDebug() << "- colors bract:    " << colors_bract;
    qDebug() << "- colors flower:   " << colors_flower;
    qDebug() << "- colors fruit:    " << colors_fruit;

    qDebug() << "* calendar";
    qDebug() << "- planting:    " << period_planting;
    qDebug() << "- growth:      " << period_growth;
    qDebug() << "- blooming:    " << period_blooming;
    qDebug() << "- fruiting:    " << period_fruiting;

    qDebug() << "* tags";
    qDebug() << "-" << tags;

    qDebug() << "* maintenance infos";
    qDebug() << "-" << soil;
    qDebug() << "-" << sunlight;
    qDebug() << "-" << watering;
    qDebug() << "-" << fertilization;
    qDebug() << "-" << pruning;

    qDebug() << "* metrics";
    qDebug() << "- soil RH " << soilRH_min << " -> " << soilRH_max;
    qDebug() << "- soil EC " << soilEC_min << " -> " << soilEC_max;
    qDebug() << "- soil PH " << soilPH_min << " -> " << soilPH_max;
    qDebug() << "- air temp" << envTemp_min << " -> " << envTemp_max;
    qDebug() << "- air temp (ideal)" << envTempIdeal_min << " -> " << envTempIdeal_max;
    qDebug() << "- air RH  " << envHumi_min << " -> " << envHumi_max;
    qDebug() << "- light (lux)  " << lightLux_min << " -> " << lightLux_max;
    qDebug() << "- light (mmol) " << lightMmol_min << " -> " << lightMmol_max;
}

bool Plant::stats() const
{
    return false;
}

/* ************************************************************************** */
