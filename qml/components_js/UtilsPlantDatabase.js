// UtilsPlantDatabase.js
// Version 1
.pragma library

//.import PlantUtils 1.0 as PlantUtils
.import ThemeEngine 1.0 as ThemeEngine

/* ************************************************************************** */

function getPlantTagText(tag) {
    if (tag === "air purifying") return qsTr("air purifying")
    if (tag === "medicinal") return qsTr("medicinal")
    if (tag === "edible") return qsTr("edible")
    if (tag === "poisonous") return qsTr("poisonous")
    if (tag === "blooms once") return qsTr("blooms once")
    if (tag === "night bloomer") return qsTr("night bloomer")
    if (tag === "carnivorous") return qsTr("carnivorous")

    if (tag === "succulent") return qsTr("succulent")
    if (tag === "aquatic plant") return qsTr("aquatic plant")
    if (tag === "bonsai") return qsTr("bonsai")
    if (tag === "fungus") return qsTr("fungus")
    if (tag === "fern") return qsTr("fern")
    if (tag === "climbing plant") return qsTr("climbing plant")
    if (tag === "vanilla") return qsTr("vanilla")
    if (tag === "vegetable") return qsTr("vegetable")
    if (tag === "crops") return qsTr("crops")
    if (tag === "foliage") return qsTr("foliage")
    if (tag === "bryophyte") return qsTr("bryophyte")

    return ""
}

function getPlantTagColor(tag) {
    if (tag === "poisonous") return ThemeEngine.Theme.colorRed
    if (tag === "air purifying") return ThemeEngine.Theme.colorBlue
    return ThemeEngine.Theme.colorGreen
}

/* ************************************************************************** */
