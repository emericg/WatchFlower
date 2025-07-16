/*!
 * This file is part of SmartCare.
 * Copyright (c) 2020 Emeric Grange - All Rights Reserved
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
 * \date      2023
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef PLANT_UTILS_H
#define PLANT_UTILS_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QVariant>
#include <QQmlContext>
#include <QQmlApplicationEngine>

/* ************************************************************************** */

static const QString colorsSvg[147][3] = {
    // nb    // name                // hex code
    {   "1", "aliceblue",           "#f0f8ff" },
    {   "2", "antiquewhite",        "#faebd7" },
    {   "3", "aqua",                "#00ffff" },
    {   "4", "aquamarine",          "#7fffd4" },
    {   "5", "azure",               "#f0ffff" },
    {   "6", "beige",               "#f5f5dc" },
    {   "7", "bisque",              "#ffe4c4" },
    {   "8", "black",               "#000000" },
    {   "9", "blanchedalmond",      "#ffebcd" },
    {  "10", "blue",                "#0000ff" },
    {  "11", "blueviolet",          "#8a2be2" },
    {  "12", "brown",               "#a52a2a" },
    {  "13", "burlywood",           "#deb887" },
    {  "14", "cadetblue",           "#5f9ea0" },
    {  "15", "chartreuse",          "#7fff00" },
    {  "16", "chocolate",           "#d2691e" },
    {  "17", "coral",               "#ff7f50" },
    {  "18", "cornflowerblue",      "#6495ed" },
    {  "19", "cornsilk",            "#fff8dc" },
    {  "20", "crimson",             "#dc143c" },
    {  "21", "cyan",                "#00ffff" },
    {  "22", "darkblue",            "#00008b" },
    {  "23", "darkcyan",            "#008b8b" },
    {  "24", "darkgoldenrod",       "#b8860b" },
    {  "25", "darkgray",            "#a9a9a9" },
    {  "26", "darkgreen",           "#006400" },
    {  "27", "darkgrey",            "#a9a9a9" },
    {  "28", "darkkhaki",           "#bdb76b" },
    {  "29", "darkmagenta",         "#8b008b" },
    {  "30", "darkolivegreen",      "#556b2f" },
    {  "31", "darkorange",          "#ff8c00" },
    {  "32", "darkorchid",          "#9932cc" },
    {  "33", "darkred",             "#8b0000" },
    {  "34", "darksalmon",          "#e9967a" },
    {  "35", "darkseagreen",        "#8fbc8f" },
    {  "36", "darkslateblue",       "#483d8b" },
    {  "37", "darkslategray",       "#2f4f4f" },
    {  "38", "darkslategrey",       "#2f4f4f" },
    {  "39", "darkturquoise",       "#00ced1" },
    {  "40", "darkviolet",          "#9400d3" },
    {  "41", "deeppink",            "#ff1493" },
    {  "42", "deepskyblue",         "#00bfff" },
    {  "43", "dimgray",             "#696969" },
    {  "44", "dimgrey",             "#696969" },
    {  "45", "dodgerblue",          "#1e90ff" },
    {  "46", "firebrick",           "#b22222" },
    {  "47", "floralwhite",         "#fffaf0" },
    {  "48", "forestgreen",         "#228b22" },
    {  "49", "fuchsia",             "#ff00ff" },
    {  "50", "gainsboro",           "#dcdcdc" },
    {  "51", "ghostwhite",          "#f8f8ff" },
    {  "52", "gold",                "#ffd700" },
    {  "53", "goldenrod",           "#daa520" },
    {  "54", "gray",                "#808080" },
    {  "55", "grey",                "#808080" },
    {  "56", "green",               "#008000" },
    {  "57", "greenyellow",         "#adff2f" },
    {  "58", "honeydew",            "#f0fff0" },
    {  "59", "hotpink",             "#ff69b4" },
    {  "60", "indianred",           "#cd5c5c" },
    {  "61", "indigo",              "#4b0082" },
    {  "62", "ivory",               "#fffff0" },
    {  "63", "khaki",               "#f0e68c" },
    {  "64", "lavender",            "#e6e6fa" },
    {  "65", "lavenderblush",       "#fff0f5" },
    {  "66", "lawngreen",           "#7cfc00" },
    {  "67", "lemonchiffon",        "#fffacd" },
    {  "68", "lightblue",           "#add8e6" },
    {  "69", "lightcoral",          "#f08080" },
    {  "70", "lightcyan",           "#e0ffff" },
    {  "71", "lightgoldenrodyellow","#fafad2" },
    {  "72", "lightgray",           "#d3d3d3" },
    {  "73", "lightgreen",          "#90ee90" },
    {  "74", "lightgrey",           "#d3d3d3" },
    {  "75", "lightpink",           "#ffb6c1" },
    {  "76", "lightsalmon",         "#ffa07a" },
    {  "77", "lightseagreen",       "#20b2aa" },
    {  "78", "lightskyblue",        "#87cefa" },
    {  "79", "lightslategray",      "#778899" },
    {  "80", "lightslategrey",      "#778899" },
    {  "81", "lightsteelblue",      "#b0c4de" },
    {  "82", "lightyellow",         "#ffffe0" },
    {  "83", "lime",                "#00ff00" },
    {  "84", "limegreen",           "#32cd32" },
    {  "85", "linen",               "#faf0e6" },
    {  "86", "magenta",             "#ff00ff" },
    {  "87", "maroon",              "#800000" },
    {  "88", "mediumaquamarine",    "#66cdaa" },
    {  "89", "mediumblue",          "#0000cd" },
    {  "90", "mediumorchid",        "#ba55d3" },
    {  "91", "mediumpurple",        "#9370db" },
    {  "92", "mediumseagreen",      "#3cb371" },
    {  "93", "mediumslateblue",     "#7b68ee" },
    {  "94", "mediumspringgreen",   "#00fa9a" },
    {  "95", "mediumturquoise",     "#48d1cc" },
    {  "96", "mediumvioletred",     "#c71585" },
    {  "97", "midnightblue",        "#191970" },
    {  "98", "mintcream",           "#f5fffa" },
    {  "99", "mistyrose",           "#ffe4e1" },
    { "100", "moccasin",            "#ffe4b5" },
    { "101", "navajowhite",         "#ffdead" },
    { "102", "navy",                "#000080" },
    { "103", "oldlace",             "#fdf5e6" },
    { "104", "olive",               "#808000" },
    { "105", "olivedrab",           "#6b8e23" },
    { "106", "orange",              "#ffa500" },
    { "107", "orangered",           "#ff4500" },
    { "108", "orchid",              "#da70d6" },
    { "109", "palegoldenrod",       "#eee8aa" },
    { "110", "palegreen",           "#98fb98" },
    { "111", "paleturquoise",       "#afeeee" },
    { "112", "palevioletred",       "#db7093" },
    { "113", "papayawhip",          "#ffefd5" },
    { "114", "peachpuff",           "#ffdab9" },
    { "115", "peru",                "#cd853f" },
    { "116", "pink",                "#ffc0cb" },
    { "117", "plum",                "#dda0dd" },
    { "118", "powderblue",          "#b0e0e6" },
    { "119", "purple",              "#800080" },
    { "120", "red",                 "#ff0000" },
    { "121", "rosybrown",           "#bc8f8f" },
    { "122", "royalblue",           "#4169e1" },
    { "123", "saddlebrown",         "#8b4513" },
    { "124", "salmon",              "#fa8072" },
    { "125", "sandybrown",          "#f4a460" },
    { "126", "seagreen",            "#2e8b57" },
    { "127", "seashell",            "#fff5ee" },
    { "128", "sienna",              "#a0522d" },
    { "129", "silver",              "#c0c0c0" },
    { "130", "skyblue",             "#87ceeb" },
    { "131", "slateblue",           "#6a5acd" },
    { "132", "slategray",           "#708090" },
    { "133", "slategrey",           "#708090" },
    { "134", "snow",                "#fffafa" },
    { "135", "springgreen",         "#00ff7f" },
    { "136", "steelblue",           "#4682b4" },
    { "137", "tan",                 "#d2b48c" },
    { "138", "teal",                "#008080" },
    { "139", "thistle",             "#d8bfd8" },
    { "140", "tomato",              "#ff6347" },
    { "141", "turquoise",           "#40e0d0" },
    { "142", "violet",              "#ee82ee" },
    { "143", "wheat",               "#f5deb3" },
    { "144", "white",               "#ffffff" },
    { "145", "whitesmoke",          "#f5f5f5" },
    { "146", "yellow",             "#ffff00" },
    { "147", "yellowgreen",         "#9acd32" },
};

/* ************************************************************************** */

static const QString hardinessZones[28][4] = {
    // zone         from        to
    {  "0", "a",    "-53.9",    "-53.9" },
    {  "0", "b",    "-53.9",    "-51.1" },
    {  "1", "a",    "-51.1",    "-48.3" },
    {  "1", "b",    "-48.3",    "-45.6" },
    {  "2", "a",    "-45.6",    "-42.8" },
    {  "2", "b",    "-42.8",    "-40" },
    {  "3", "a",    "-40",      "-37.2" },
    {  "3", "b",    "-37.2",    "-34.4" },
    {  "4", "a",    "-34.4",    "-31.7" },
    {  "4", "b",    "-31.7",    "-28.9" },
    {  "5", "a",    "-28.9",    "-26.1" },
    {  "5", "b",    "-26.1",    "-23.3" },
    {  "6", "a",    "-23.3",    "-20.6" },
    {  "6", "b",    "-20.6",    "-17.8" },
    {  "7", "a",    "-17.8",    "-15" },
    {  "7", "b",    "-15",      "-12.2" },
    {  "8", "a",    "-12.2",    "-9.4" },
    {  "8", "b",    "-9.4",     "-6.7" },
    {  "9", "a",    "-6.7",     "-3.9" },
    {  "9", "b",    "-3.9",     "-1.1" },
    { "10", "a",    "-1.1",     "1.7" },
    { "10", "b",    "1.7",      "4.4" },
    { "11", "a",    "4.4",      "7.2" },
    { "11", "b",    "7.2",      "10" },
    { "12", "a",    "10",       "12.8" },
    { "12", "b",    "12.8",     "15.6" },
    { "13", "a",    "15.6",     "18.3" },
    { "13", "b",    "18.3",     "18.3" },
};

/* ************************************************************************** */

class PlantUtils: public QObject
{
    Q_OBJECT

public:
    static void registerQML()
    {
        qRegisterMetaType<PlantUtils::PlantTags>("PlantUtils::PlantTags");
        qRegisterMetaType<PlantUtils::Sunlight>("PlantUtils::Sunlight");
        qRegisterMetaType<PlantUtils::Watering>("PlantUtils::Watering");
        qRegisterMetaType<PlantUtils::Pruning>("PlantUtils::Pruning");
        qRegisterMetaType<PlantUtils::FertilizerFreq>("PlantUtils::FertilizerFreq");
        qRegisterMetaType<PlantUtils::FertilizerTags>("PlantUtils::FertilizerTags");
        qRegisterMetaType<PlantUtils::Soils>("PlantUtils::Soils");

        qmlRegisterType<PlantUtils>("PlantUtils", 1, 0, "PlantUtils");
    }

    ////////////////////////////////////////////////////////////////////////////

    enum PlantTags {
        TAG_UNKNOWN = 0,

        PLANT_FUNGUS = 1,               // Mushroom and stuff
        PLANT_BRYOPHYTE,                // Mosses and stuff
        PLANT_ANGIOSPERMS,              // Flowering plants?
        PLANT_GYMNOSPERMS,              // Seed plants? trees?

        PLANT_AQUATIC = 32,
        PLANT_CLIMBING,
        PLANT_SUCCULENT,
        PLANT_CACTI,
        PLANT_BAMBOO,
        PLANT_BONSAI,
        PLANT_ORCHID,
        PLANT_ROSE,
        PLANT_VANILLA,
        PLANT_VEGETABLE,
        PLANT_BULB,
        PLANT_CROPS,
        PLANT_FERN,
        PLANT_SHRUB,
        PLANT_FOLIAGE,
        PLANT_TREE,

        // tags
        TAG_AIR_PURIFYING       = 64,
        TAG_MEDICINAL,
        TAG_EDIBLE,
        TAG_POISONOUS,
        TAG_BLOOMS_ONCE,
        TAG_NIGHT_BLOOMER,
        TAG_CARNIVOROUS,

        // TODO // more tags?
    };
    Q_ENUM(PlantTags)

    ////////////////////////////////////////////////////////////////////////////

    enum Sunlight {
        SHADE           = 1,
        PART_SHADE      = 2,
        PART_SUN        = 3,
        FULL_SUN        = 4,
    };
    Q_ENUM(Sunlight)

    enum Watering {
        LOW_NEED        = 1,
        MEDIUM_NEED     = 2,
        HIGH_NEED       = 3,
        KEEP_MOIST      = 4,

        SPRAY           = 5,
        WHEN_NEEDED     = 6,
    };
    Q_ENUM(Watering)

    enum Pruning {
        NO_PRUNING_NEEDED               = (1 << 0),

        SHAPE_FOR_GOOD_APPEARANCE       = (1 << 1),
        SHAPE_TO_PROMOTE_GROWTH         = (1 << 2),

        REMOVE_DEAD_PARTS               = (1 << 4),
        REMOVE_PEDUNCLE_AFTER_FLOWERING = (1 << 5),
        REMOVE_DAUGHTER_PLANTS          = (1 << 6),
        REMOVE_FLOWER_STEM              = (1 << 7),
        REMOVE_WEEDS                    = (1 << 8),
        REMOVE_EXCESSIVE_BRANCHES       = (1 << 9),

        KEEP_BULBS                      = (1 << 20),
        KEEP_TUBERS                     = (1 << 21),
    };
    Q_ENUM(Pruning)

    enum FertilizerFreq {
        FERT_UNKNOWN = 0,

        FERT_NONE,                      // not needed
        FERT_THREEWEEKLY,               // thrice a week
        FERT_BIWEEKLY,                  // twice a week
        FERT_WEEKLY,                    // once a week
        FERT_THREEMONTHLY,              // every 10-15 days
        FERT_BIMONTHLY,                 // every 15 days
        FERT_MONTHLY,                   // once a month
        FERT_SIXYEARLY,                 // every 2 months
        FERT_FOURYEARLY,                // every 3 months
        FERT_THREEYEARLY,               // every 4 months
        FERT_BIYEARLY,                  // every 6 months
        FERT_YEARLY,                    // once a year
    };
    Q_ENUM(FertilizerFreq)

    enum FertilizerTags {
        LOW_NEEDS                       = (1 << 0),
        HIGH_NEEDS                      = (1 << 1),
        LOW_CONCENTRATION               = (1 << 2),
        HIGH_CONCENTRATION              = (1 << 3),
        DURING_GROWTH                   = (1 << 4),
        DURING_VEGETATIVE_STATE         = (1 << 5),
        USE_BASE_FERTILIZER             = (1 << 6),
        USE_TOPDRESSING_FERTILIZER      = (1 << 7),
        USE_LIQUID_FERTILIZER           = (1 << 8),
        USE_FOLIAR_FERTILIZER           = (1 << 9),
    };
    Q_ENUM(FertilizerTags)

    enum Soils {
        SOIL_UNKNOWN = 0,

        SOIL_CLAY,               // heavy soils
        SOIL_SILTY_CLAY,
        SOIL_SANDY_CLAY,
        SOIL_SANDY_CLAY_LOAM,    // medium soils
        SOIL_CLAY_LOAM,
        SOIL_LOAM,
        SOIL_SILTY_CLAY_LOAM,
        SOIL_SAND,               // sandy / light soils
        SOIL_LOAMY_SAND,
        SOIL_SANDY_LOAM,
        SOIL_SANDY_SILT_LOAM,
        SOIL_SILT_LOAM,
        SOIL_SILT,
        SOIL_COARSE_SAND,        // coarse soils

        SOIL_CHALK,
        SOIL_LIMESTONE,
        SOIL_SPHAGNUM_MOSS,
        SOIL_PEAT_PERLITE_MIX,
        SOIL_PEAT,
    };
    Q_ENUM(Soils)

    ////////////////////////////////////////////////////////////////////////////

    /*!
     * \brief colorssvg_fromstring
     * \param str[in] is a svg color name
     * \return the number corresponding to the svg color
     */
    static QString colorssvg_fromstring(const QString &str) {
        for (int i = 0; i < 147; i++) {
            if (str.compare(colorsSvg[i][1], Qt::CaseInsensitive) == 0) {
                return colorsSvg[i][0];
            }
        }
        return QString();
    };

    /*!
     * \brief colorssvg_tostring
     * \param str[in] is a number, corresponding to a svg color
     * \return a svg color name
     */
    static QString colorssvg_tostring(const QString &str) {
        for (int i = 0; i < 147; i++) {
            if (str.compare(colorsSvg[i][0], Qt::CaseInsensitive) == 0) {
                return colorsSvg[i][1];
            }
        }
        return QString();
    };

    ////////

    static QString colorssvg_fromstringlist(const QStringList &lst) {
        QString ret;
        for (auto s: lst) {
            if (s.startsWith(' ')) s = s.remove(0, 1);
            if (s.endsWith(' ')) s.chop(1);
            ret.push_back(colorssvg_fromstring(s) + ',');
        }
        if (ret.endsWith(',')) ret.chop(1);
        return ret;
    }
    static QStringList colorssvg_tostringlist(const QString &str) {
        QStringList ret;
        for (const auto &s: str.split(',', Qt::SkipEmptyParts)) {
            ret.push_back(colorssvg_tostring(s));
        }
        return ret;
    }

    ////////////////////////////////////////////////////////////////////////////

    static QString tags_fromstring(const QString &str) {

        if (str == "fungus") return QString::number(PLANT_FUNGUS);
        if (str == "bryophyte") return QString::number(PLANT_BRYOPHYTE);
        if (str == "angiosperms") return QString::number(PLANT_ANGIOSPERMS);
        if (str == "gymnosperms") return QString::number(PLANT_GYMNOSPERMS);

        if (str == "aquatic") return QString::number(PLANT_AQUATIC);
        if (str == "aquatic plant") return QString::number(PLANT_AQUATIC);
        if (str == "climbing") return QString::number(PLANT_CLIMBING);
        if (str == "climbing plant") return QString::number(PLANT_CLIMBING);
        if (str == "succulent") return QString::number(PLANT_SUCCULENT);
        if (str == "cacti") return QString::number(PLANT_CACTI);
        if (str == "bamboo") return QString::number(PLANT_BAMBOO);
        if (str == "bonsai") return QString::number(PLANT_BONSAI);
        if (str == "orchid") return QString::number(PLANT_ORCHID);
        if (str == "fern") return QString::number(PLANT_FERN);
        if (str == "shrub") return QString::number(PLANT_SHRUB);
        if (str == "vanilla") return QString::number(PLANT_VANILLA);
        if (str == "vegetable") return QString::number(PLANT_VEGETABLE);
        if (str == "crops") return QString::number(PLANT_CROPS);
        if (str == "foliage") return QString::number(PLANT_FOLIAGE);

        if (str == "air purifying") return QString::number(TAG_AIR_PURIFYING);
        if (str == "medicinal") return QString::number(TAG_MEDICINAL);
        if (str == "edible") return QString::number(TAG_EDIBLE);
        if (str == "poisonous") return QString::number(TAG_POISONOUS);
        if (str == "blooms once") return QString::number(TAG_BLOOMS_ONCE);
        if (str == "night bloomer") return QString::number(TAG_NIGHT_BLOOMER);
        if (str == "carnivorous") return QString::number(TAG_CARNIVOROUS);

        return QString();
    }

    ////////

    static QString tags_fromstringlist(const QStringList &tags) {
        QString ret;
        for (const auto &t: tags) {
            if (!ret.isEmpty()) ret += ',';
            ret += tags_fromstring(t);
        }
        return ret;
    }

    ////////////////////////////////////////////////////////////////////////////

    static QStringList calendar_tostringlist(const QString &cal) {
        QStringList ret;

        if (cal.isEmpty()) return ret;
        for (int i = 1; i <= 12; i++) ret.append("0");

        QPair <int, int> splt1, splt2;

        // go through each interval
        QStringList splt_tmmmp = cal.split(',');
        for (int i = 0; i < splt_tmmmp.length(); i++) {

            QString split_tmmp = splt_tmmmp.at(i);

            // convert seasons into months
            // TODO // adapt to southern hemisphere
            split_tmmp.replace("winter", "1-3");
            split_tmmp.replace("spring", "4-6");
            split_tmmp.replace("summer", "7-9");
            split_tmmp.replace("autumn", "10-12");

            QStringList splt_tmp = split_tmmp.split('-');

            QPair <int, int> *splt = (i == 0) ? &splt1 : &splt2;
            splt->first = splt_tmp.at(0).toInt();
            splt->second = (splt_tmp.size() > 1) ? splt_tmp.at(1).toInt() : splt_tmp.at(0).toInt();

            for (int i = 1; i <= 12; i++) {
                if (splt->first <= splt->second) {
                    if (i >= splt->first && i <= splt->second) ret[i-1] = "1";
                } else {
                    if (i <= splt->first && i >= splt->second) ret[i-1] = "1";
                }
            }
        }

        return ret;
    }

    ////////////////////////////////////////////////////////////////////////////

    static QString hardiness_zonetotemp(const QString &zone) {
        for (int i = 0; i < 28; i++) {
            if (zone.compare(hardinessZones[i][0]+hardinessZones[i][1], Qt::CaseInsensitive) == 0) {
                return hardinessZones[i][2];
            }
        }
        return QString();
    }

    ////////////////////////////////////////////////////////////////////////////
};

/* ************************************************************************** */
#endif // PLANT_UTILS_H
