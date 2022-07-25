// UtilsPlantDatabase.js
// Version 1
.pragma library

//.import PlantUtils 1.0 as PlantUtils
.import ThemeEngine 1.0 as ThemeEngine

/* ************************************************************************** */

function getPlantTypeText(type) {
    if (type === "succulent") return qsTr("succulent")
    if (type === "aquatic plant") return qsTr("aquatic plant")
    if (type === "bonsai") return qsTr("bonsai")
    if (type === "fungus") return qsTr("fungus")
    if (type === "fern") return qsTr("fern")
    if (type === "climbing plant") return qsTr("climbing plant")
    if (type === "vanilla") return qsTr("vanilla")
    if (type === "vegetable") return qsTr("vegetable")
    if (type === "crops") return qsTr("crops")
    if (type === "foliage") return qsTr("foliage")
    if (type === "bryophyte") return qsTr("bryophyte")

    return type
}

function getPlantTypeColor(type) {
    return ThemeEngine.Theme.colorGreen
}

/* ************************************************************************** */

function getPlantTagText(tag) {
    if (tag === "air purifying") return qsTr("air purifying")
    if (tag === "medicinal") return qsTr("medicinal")
    if (tag === "edible") return qsTr("edible")
    if (tag === "poisonous") return qsTr("poisonous")
    if (tag === "blooms once") return qsTr("blooms once")
    if (tag === "night bloomer") return qsTr("night bloomer")
    if (tag === "carnivorous") return qsTr("carnivorous")

    return tag
}

function getPlantTagColor(tag) {
    if (tag === "poisonous") return ThemeEngine.Theme.colorRed
    if (tag === "air purifying") return ThemeEngine.Theme.colorBlue
    if (tag === "night bloomer") return ThemeEngine.Theme.colorGrey
    return ThemeEngine.Theme.colorGreen
}

/* ************************************************************************** */
