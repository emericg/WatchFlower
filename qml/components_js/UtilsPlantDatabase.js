// UtilsPlantDatabase.js
// Version 2
.pragma library

.import PlantUtils 1.0 as PlantUtils
.import ThemeEngine 1.0 as ThemeEngine

/* ************************************************************************** */

function getPlantTagsText(tag) {
    if (tag == PlantUtils.PlantUtils.PLANT_FUNGUS) return qsTr("fungus")
    if (tag == PlantUtils.PlantUtils.PLANT_BRYOPHYTE) return qsTr("bryophyte")
    if (tag == PlantUtils.PlantUtils.PLANT_ANGIOSPERMS) return qsTr("angiosperms")
    if (tag == PlantUtils.PlantUtils.PLANT_GYMNOSPERMS) return qsTr("gymnosperms")

    if (tag == PlantUtils.PlantUtils.PLANT_AQUATIC) return qsTr("aquatic plant")
    if (tag == PlantUtils.PlantUtils.PLANT_CLIMBING) return qsTr("climbing plant")
    if (tag == PlantUtils.PlantUtils.PLANT_SUCCULENT) return qsTr("succulent")
    if (tag == PlantUtils.PlantUtils.PLANT_CACTI) return qsTr("cacti")
    if (tag == PlantUtils.PlantUtils.PLANT_BAMBOO) return qsTr("bamboo")
    if (tag == PlantUtils.PlantUtils.PLANT_BONSAI) return qsTr("bonsai")
    if (tag == PlantUtils.PlantUtils.PLANT_ORCHID) return qsTr("orchid")
    if (tag == PlantUtils.PlantUtils.PLANT_ROSE) return qsTr("rose")
    if (tag == PlantUtils.PlantUtils.PLANT_VANILLA) return qsTr("vanilla")
    if (tag == PlantUtils.PlantUtils.PLANT_VEGETABLE) return qsTr("vegetable")
    if (tag == PlantUtils.PlantUtils.PLANT_BULB) return qsTr("bulb")
    if (tag == PlantUtils.PlantUtils.PLANT_CROPS) return qsTr("crops")
    if (tag == PlantUtils.PlantUtils.PLANT_FERN) return qsTr("fern")
    if (tag == PlantUtils.PlantUtils.PLANT_SHRUB) return qsTr("shrub")
    if (tag == PlantUtils.PlantUtils.PLANT_FOLIAGE) return qsTr("foliage")
    if (tag == PlantUtils.PlantUtils.PLANT_TREE) return qsTr("tree")

    if (tag == PlantUtils.PlantUtils.TAG_AIR_PURIFYING) return qsTr("air purifying")
    if (tag == PlantUtils.PlantUtils.TAG_MEDICINAL) return qsTr("medicinal")
    if (tag == PlantUtils.PlantUtils.TAG_EDIBLE) return qsTr("edible")
    if (tag == PlantUtils.PlantUtils.TAG_POISONOUS) return qsTr("poisonous")
    if (tag == PlantUtils.PlantUtils.TAG_BLOOMS_ONCE) return qsTr("blooms once")
    if (tag == PlantUtils.PlantUtils.TAG_NIGHT_BLOOMER) return qsTr("night bloomer")
    if (tag == PlantUtils.PlantUtils.TAG_CARNIVOROUS) return qsTr("carnivorous")

    return ""
}

function getPlantTagsColor(tag) {
    if (tag < 32) return ThemeEngine.Theme.colorGreen

    if (tag == PlantUtils.PlantUtils.TAG_POISONOUS) return ThemeEngine.Theme.colorRed
    if (tag == PlantUtils.PlantUtils.TAG_AIR_PURIFYING) return ThemeEngine.Theme.colorBlue
    if (tag == PlantUtils.PlantUtils.TAG_NIGHT_BLOOMER) return ThemeEngine.Theme.colorGrey

    return ThemeEngine.Theme.colorGreen
}

/* ************************************************************************** */

function getWateringText(watering) {
    var txt = ""

    var total = watering.split(',')
    var parts = total[0].split('-')

    for (var i = 0; i < total.length; i++) {
        if (i === 0) {
            for (var j = 0; j <= parts.length; j++) {
                if (txt.length > 0 && parts[j]) txt += " " + "to" + " "
                if (parts[j] === "1") txt += qsTr("low")
                if (parts[j] === "2") txt += qsTr("medium")
                if (parts[j] === "3") txt += qsTr("high")
            }
            if (txt.length > 0) txt += " " + qsTr("water needs")

            if (parts[0] === "4") txt = qsTr("keep moist")
        } else {
            if (total[i] === "5")  {
                if (txt.length > 0) txt += "<br>"
                txt += qsTr("spray water on leaves")
            }
            if (total[i] === "6") {
                if (txt.length > 0) txt += "<br>"
                txt += qsTr("water when soil is dry")
            }
        }
    }

    return txt
}

function getSunlightText(sunlight) {
    var txt = ""

    var parts = sunlight.split('-')
    for (var i = 0; i < parts.length; i++) {
        if (txt.length > 0 && parts[i]) txt += " " + "to" + " "
        if (parts[i] === "1") txt += qsTr("shade")
        if (parts[i] === "2") txt += qsTr("part shade")
        if (parts[i] === "3") txt += qsTr("part sun")
        if (parts[i] === "4") txt += qsTr("full sun")
    }

    return txt
}

function getFertilizationTagsText(fert) {
    var txt = ""

    var tags = fert[1].split('-')

    if (tags & PlantUtils.PlantUtils.LOW_NEEDS) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("low needs")
    }
    if (tags & PlantUtils.PlantUtils.HIGH_NEEDS) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("high needs")
    }

    if (tags & PlantUtils.PlantUtils.LOW_CONCENTRATION) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("low concentration")
    }
    if (tags & PlantUtils.PlantUtils.HIGH_CONCENTRATION) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("high concentration")
    }

    if (tags & PlantUtils.PlantUtils.DURING_GROWTH) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("during growth stage")
    }
    if (tags & PlantUtils.PlantUtils.DURING_VEGETATIVE_STATE) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("during vegetative state")
    }

    if (tags & PlantUtils.PlantUtils.USE_BASE_FERTILIZER) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("use base fertilizer")
    }
    if (tags & PlantUtils.PlantUtils.USE_TOPDRESSING_FERTILIZER) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("use topdressing fertilizer")
    }
    if (tags & PlantUtils.PlantUtils.USE_LIQUID_FERTILIZER) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("use liquid fertilizer")
    }
    if (tags & PlantUtils.PlantUtils.USE_FOLIAR_FERTILIZER) {
        if (txt.length > 0) txt += ", "
        txt += qsTr("use foliar fertilizer")
    }

    return txt
}

function getFertilizationText(fert) {
    var txt = ""

    var freq = fert[0].split('-')

    if (freq == PlantUtils.PlantUtils.FERT_NONE) txt = qsTr("no extra fertilization needed")
    else if (freq == PlantUtils.PlantUtils.FERT_THREEWEEKLY) txt = qsTr("every 2-3 days")
    else if (freq == PlantUtils.PlantUtils.FERT_BIWEEKLY) txt = qsTr("twice a week")
    else if (freq == PlantUtils.PlantUtils.FERT_WEEKLY) txt = qsTr("once a week")
    else if (freq == PlantUtils.PlantUtils.FERT_THREEMONTHLY) txt = qsTr("every 10-15 days")
    else if (freq == PlantUtils.PlantUtils.FERT_BIMONTHLY) txt = qsTr("twice a month")
    else if (freq == PlantUtils.PlantUtils.FERT_MONTHLY) txt = qsTr("once a month")
    else if (freq == PlantUtils.PlantUtils.FERT_SIXYEARLY) txt = qsTr("every 2 months")
    else if (freq == PlantUtils.PlantUtils.FERT_FOURYEARLY) txt = qsTr("every 3 months")
    else if (freq == PlantUtils.PlantUtils.FERT_THREEYEARLY) txt = qsTr("every 4 months")
    else if (freq == PlantUtils.PlantUtils.FERT_BIYEARLY) txt = qsTr("every 6 months")
    else if (freq == PlantUtils.PlantUtils.FERT_YEARLY) txt = qsTr("once a year")

    return txt
}

function getSoilTypeText(soil) {
    var txt = ""

    if (soil >= PlantUtils.PlantUtils.SOIL_CLAY &&
        soil <= PlantUtils.PlantUtils.SOIL_SANDY_CLAY) {
        txt = qsTr("heavy soil")
    } else if (soil >= PlantUtils.PlantUtils.SOIL_SANDY_CLAY_LOAM &&
               soil <= PlantUtils.PlantUtils.SOIL_SILTY_CLAY_LOAM) {
        txt = qsTr("medium soil")
    } else if (soil >= PlantUtils.PlantUtils.SOIL_SAND &&
               soil <= PlantUtils.PlantUtils.SOIL_SILT) {
        txt = qsTr("light soil")
    }

    return txt
}

function getSoilText(soil) {
    var txt = ""

    if (soil == PlantUtils.PlantUtils.SOIL_CLAY) txt = qsTr("clay")
    else if (soil == PlantUtils.PlantUtils.SOIL_SILTY_CLAY) txt = qsTr("silty clay")
    else if (soil == PlantUtils.PlantUtils.SOIL_SANDY_CLAY) txt = qsTr("sandy clay")

    else if (soil == PlantUtils.PlantUtils.SOIL_SANDY_CLAY_LOAM) txt = qsTr("sandy clay loam")
    else if (soil == PlantUtils.PlantUtils.SOIL_CLAY_LOAM) txt = qsTr("clay loam")
    else if (soil == PlantUtils.PlantUtils.SOIL_LOAM) txt = qsTr("loam")
    else if (soil == PlantUtils.PlantUtils.SOIL_SILTY_CLAY_LOAM) txt = qsTr("silty clay loam")

    else if (soil == PlantUtils.PlantUtils.SOIL_SAND) txt = qsTr("sandy soil")
    else if (soil == PlantUtils.PlantUtils.SOIL_LOAMY_SAND) txt = qsTr("loamy sand")
    else if (soil == PlantUtils.PlantUtils.SOIL_SANDY_LOAM) txt = qsTr("sandy loam")
    else if (soil == PlantUtils.PlantUtils.SOIL_SANDY_SILT_LOAM) txt = qsTr("sandy silt loam")
    else if (soil == PlantUtils.PlantUtils.SOIL_SILT_LOAM) txt = qsTr("silty loam")
    else if (soil == PlantUtils.PlantUtils.SOIL_SILT) txt = qsTr("silty soil")

    else if (soil == PlantUtils.PlantUtils.SOIL_COARSE_SAND) txt = qsTr("coarse sandy soil")

    else if (soil == PlantUtils.PlantUtils.SOIL_CHALK) txt = qsTr("chalk")
    else if (soil == PlantUtils.PlantUtils.SOIL_LIMESTONE) txt = qsTr("limestone")
    else if (soil == PlantUtils.PlantUtils.SOIL_SPHAGNUM_MOSS) txt = qsTr("sphagnum moss")
    else if (soil == PlantUtils.PlantUtils.SOIL_PEAT_PERLIT_MIX) txt = qsTr("peat and perlit mixed")
    else if (soil == PlantUtils.PlantUtils.SOIL_PEAT) txt = qsTr("peat soil")

    // also print soil type?
    var soiltype = getSoilTypeText(soil)
    if (soiltype) txt += " (" + soiltype + ")"

    return txt
}

function getPruningText(pruning) {
    var txt = ""

    if (pruning === PlantUtils.PlantUtils.NONE) {
        txt += qsTr("no pruning needed")
    }
    if (pruning & PlantUtils.PlantUtils.DEAD) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("remove dead parts")
    }
    if (pruning & PlantUtils.PlantUtils.SHAPE_FOR_GOOD_APPEARANCE) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("shape for good appearance")
    }
    if (pruning & PlantUtils.PlantUtils.SHAPE_TO_PROMOTE_GROWTH) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("shape to promote growth")
    }
    if (pruning & PlantUtils.PlantUtils.REMOVE_PEDUNCLE_AFTER_FLOWERING) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("remove peduncle after flowering")
    }
    if (pruning & PlantUtils.PlantUtils.REMOVE_DAUGHTER_PLANTS) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("remove daughter plants")
    }
    if (pruning & PlantUtils.PlantUtils.REMOVE_FLOWER_STEM) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("remove flower stem")
    }
    if (pruning & PlantUtils.PlantUtils.REMOVE_WEEDS) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("remove weeds")
    }
    if (pruning & PlantUtils.PlantUtils.REMOVE_EXCESSIVE_BRANCHES) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("remove excessive branches")
    }
    if (pruning & PlantUtils.PlantUtils.KEEP_BULBS) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("keep bulbs")
    }
    if (pruning & PlantUtils.PlantUtils.KEEP_TUBERS) {
        if (txt.length > 0) txt += "<br>"
        txt += qsTr("keep tubers")
    }

    return txt
}

/* ************************************************************************** */

function getHardinessText(hardiness, unit) {
    var txt = ""
    var minv = -99
    var mintxt = ""

    var parts = hardiness.split('-')
    if (parts[0] === "0a") minv = -53.9
    else if (parts[0] === "0b") minv = -53.9
    else if (parts[0] === "1a") minv = -51.1
    else if (parts[0] === "1b") minv = -48.3
    else if (parts[0] === "2a") minv = -45.6
    else if (parts[0] === "2b") minv = -42.8
    else if (parts[0] === "3a") minv = -40
    else if (parts[0] === "3b") minv = -37.2
    else if (parts[0] === "4a") minv = -34.4
    else if (parts[0] === "4b") minv = -31.7
    else if (parts[0] === "5a") minv = -28.9
    else if (parts[0] === "5b") minv = -26.1
    else if (parts[0] === "6a") minv = -23.3
    else if (parts[0] === "6b") minv = -20.6
    else if (parts[0] === "7a") minv = -17.8
    else if (parts[0] === "7b") minv = -15
    else if (parts[0] === "8a") minv = -12.2
    else if (parts[0] === "8b") minv = -9.4
    else if (parts[0] === "9a") minv = -6.7
    else if (parts[0] === "9b") minv = -3.9
    else if (parts[0] === "10a") minv = -1.1
    else if (parts[0] === "10b") minv = 1.7
    else if (parts[0] === "11a") minv = 4.4
    else if (parts[0] === "11b") minv = 7.2
    else if (parts[0] === "12a") minv = 10
    else if (parts[0] === "12b") minv = 12.8
    else if (parts[0] === "13a") minv = 15.6
    else if (parts[0] === "13b") minv = 18.3

    if (minv > -99) {
        if (unit === "F") {
            mintxt = (minv * 1.8 + 32).toFixed(1) + " " + "°F"
        } else {
            mintxt = minv.toFixed(1) + " " + "°C"
        }

        txt = qsTr("zone %1 to %2 / %3").arg(parts[0]).arg(parts[1]).arg(mintxt)
    }

    return txt
}

/* ************************************************************************** */
