import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine
import PlantUtils
import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase

Grid {
    id: plantScreen

    // 1: single column (single column view or portrait tablet)
    // 2: wide mode (wide view)
    property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

    rows: 3
    columns: (uiMode === 1) ? 1 : 3
    spacing: Theme.componentMargin
    padding: Theme.componentMargin

    property int parentWidth: appContent.width // default
    property int parentHeight: parent.height // default

    property int www1: (uiMode === 1) ? (parentWidth - plantScreen.padding*2) : (parentWidth - plantScreen.spacing*4) / 3
    property int www2: (uiMode === 1) ? (parentWidth - plantScreen.padding*2) : (parentWidth - plantScreen.spacing*4) / 3
    property int insidemargins: (uiMode === 1) ? 12 : 16

    ////////

    property var currentPlant: null

    onCurrentPlantChanged: {
        if (typeof currentPlant === "undefined" || !currentPlant) return
/*
        console.log("> onCurrentPlantChanged()")

        console.log("full name: " + currentPlant.name)
        console.log("botanical name: " + currentPlant.nameBotanical)
        console.log("variety name: " + currentPlant.nameVariety)
        console.log("common name: " + currentPlant.nameCommon)

        console.log("diameter: " + currentPlant.diameter)
        console.log("height: " + currentPlant.height)

        console.log("tags: " + currentPlant.tags)

        console.log("calendarPlanting: " + currentPlant.calendarPlanting)
        console.log("calendarGrowing: " + currentPlant.calendarGrowing)
        console.log("calendarBlooming: " + currentPlant.calendarBlooming)
        console.log("calendarFruiting: " + currentPlant.calendarFruiting)

        console.log("colors1: " + currentPlant.colorsLeaf)
        console.log("colors2: " + currentPlant.colorsBract)
        console.log("colors3: " + currentPlant.colorsFlower)
        console.log("colors4: " + currentPlant.colorsFruit)

        console.log("watering: " + currentPlant.watering)

        console.log("soil Moisture m/m: " + currentPlant.soilMoist_min + " / " + currentPlant.soilMoist_max)
        console.log("mmol m/m: " + currentPlant.lightMmol_min + " / " + currentPlant.lightMmol_max)
*/
        col1.contentY = 0
        col2.contentY = 0
        col3.contentY = 0

        plantNameBotanical.text = currentPlant.nameBotanical
        plantNameVariety.text = "" + currentPlant.nameVariety + ""
        plantNameCommon.text = "« " + currentPlant.nameCommon + " »"
        plantCategory.text = currentPlant.category
        plantOrigin.text = currentPlant.origin

        // tags
        plantTags.model = currentPlant.tags

        // colors
        itemColorLeaf.visible = (currentPlant.colorsLeaf.length > 0)
        plantColorLeaf.model = currentPlant.colorsLeaf
        itemColorBract.visible = (currentPlant.colorsBract.length > 0)
        plantColorBract.model = currentPlant.colorsBract
        itemColorFlower.visible = (currentPlant.colorsFlower.length > 0)
        plantColorFlower.model = currentPlant.colorsFlower
        itemColorFruit.visible = (currentPlant.colorsFruit.length > 0)
        plantColorFruit.model = currentPlant.colorsFruit

        // sizes
        if (currentPlant.diameter) {
            plantDiameterTxt.text = currentPlant.diameter + " cm"
            //if (currentPlant.diameter.startsWith("≥ ")) {
            //    plantDiameter.first.value = 0
            //    plantDiameter.second.value = currentPlant.diameter.slice(2)
            //} else {
            //    var d = currentPlant.diameter.split('-');
            //    plantDiameter.first.value = d[0]
            //    plantDiameter.second.value = d[1]
            //}
        }
        if (currentPlant.height) {
            plantHeightTxt.text = currentPlant.height + " cm"
            //if (currentPlant.height.startsWith("≥ ")) {
            //    plantHeight.first.value = 0
            //    plantHeight.second.value = currentPlant.height.slice(2)
            //} else {
            //    var h = currentPlant.height.split('-');
            //    plantHeight.first.value = h[0]
            //    plantHeight.second.value = h[1]
            //}
        }

        var colorDisabled = Theme.colorLowContrast

        // sunlight
        rectangleSunlight.visible = currentPlant.sunlight
        if (currentPlant.sunlight) {
            plantSunlight.text = UtilsPlantDatabase.getSunlightText(currentPlant.sunlight)

            sunlight1.color = colorDisabled
            sunlight2.color = colorDisabled
            sunlight3.color = colorDisabled
            sunlight4.color = colorDisabled

            var parts = currentPlant.sunlight.split('-')
            for (var i = parts[0]; i <= (parts[1] || parts[0]); i++) {
                if (i == 1 || currentPlant.sunlight === "4") sunlight1.color = Theme.colorYellow
                if (i == 2 || currentPlant.sunlight === "4") sunlight2.color = Theme.colorYellow
                if (i == 3 || currentPlant.sunlight === "4") sunlight3.color = Theme.colorYellow
                if (i == 4 || currentPlant.sunlight === "4") sunlight4.color = Theme.colorYellow
            }
        }

        // watering
        rectangleWatering.visible = currentPlant.watering
        if (currentPlant.watering) {
            plantWatering.text = UtilsPlantDatabase.getWateringText(currentPlant.watering)

            water2.color = colorDisabled
            water3.color = colorDisabled
            water4.color = colorDisabled

            var total = currentPlant.watering.split(',')
            var parts = total[0].split('-')
            if (parts.length > 1) {
                for (var i = parts[0]; i <= (parts[1] || parts[0]); i++) {
                    if (i == 2) water2.color = Theme.colorBlue
                    if (i == 3) water3.color = Theme.colorBlue
                    if (i == 4) water4.color = Theme.colorBlue
                }
            } else {
                water2.color = (parts[0] >= 2) ? Theme.colorBlue : colorDisabled
                water3.color = (parts[0] >= 3) ? Theme.colorBlue : colorDisabled
                water4.color = (parts[0] >= 4) ? Theme.colorBlue : colorDisabled
            }
        }

        // Fertilization
        plantFertilization.text = UtilsPlantDatabase.getFertilizationText(currentPlant.fertilization)
        plantFertilizationTags.text = UtilsPlantDatabase.getFertilizationTagsText(currentPlant.fertilization)
        rectangleFertilization.visible = plantFertilization.text

        // Pruning
        plantPruning.text = UtilsPlantDatabase.getPruningText(currentPlant.pruning)
        rectanglePruning.visible = plantPruning.text

        // Soil
        plantSoil.text = UtilsPlantDatabase.getSoilText(currentPlant.soil)
        rectangleSoil.visible = plantSoil.text

        // limit sliders
        rangeSlider_soilMoist.setValues(currentPlant.soilMoist_min, currentPlant.soilMoist_max)
        rangeSlider_soilCondu.setValues(currentPlant.soilCondu_min, currentPlant.soilCondu_max)
        itemSoilPH.visible = (currentPlant.soilPH_min > 0)
        rangeSlider_soilPH.setValues(currentPlant.soilPH_min, currentPlant.soilPH_max)
        rangeSlider_temp.setValues(currentPlant.envTemp_min, currentPlant.envTemp_max)
        rangeSlider_humi.setValues(currentPlant.envHumi_min, currentPlant.envHumi_max)
        rangeSlider_lumi_lux.setValues(currentPlant.lightLux_min, currentPlant.lightLux_max)

        itemLumiMmol.visible = (currentPlant.lightMmol_min > 0)
        rangeSlider_lumi_mmol.setValues(currentPlant.lightMmol_min, Math.max(currentPlant.lightMmol_min, currentPlant.lightMmol_max))
    }

    Flickable { ////////////////////////////////////////////////////////////////
        id: col1
        width: plantScreen.www1
        height: (uiMode === 1) ? columnPlant.height + Theme.componentMargin : plantScreen.parentHeight
        contentWidth: columnPlant.width
        contentHeight: columnPlant.height + Theme.componentMargin
        interactive: (uiMode !== 1)

        Column {
            id: columnPlant
            width: plantScreen.www1
            spacing: Theme.componentMarginL

            topPadding: (uiMode === 1) ? -plantScreen.padding : 0

            ListTitle {
                anchors.leftMargin: singleColumn ? -Theme.componentMargin : -2
                anchors.rightMargin: singleColumn ? -Theme.componentMargin : -2
                visible: (uiMode === 2)

                text: qsTr("Plant infos")
            }
/*
            Image {
                id: plantPicture
                anchors.left: parent.left
                anchors.leftMargin: (uiMode === 1) ? -plantScreen.padding : 0
                anchors.right: parent.right
                anchors.rightMargin: (uiMode === 1) ? -plantScreen.padding : 0
                height: width * 0.75

                source: "file:/home/emeric/Dev/perso/WatchFlower/stash/plants_db/aloe.jpg"
                sourceSize: Qt.size(width, width)
                fillMode: Image.PreserveAspectCrop

                ////

                Rectangle {
                    id: rectangleHeader
                    //anchors.top: parent.top // top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: columnHeader.height
                    anchors.bottom: parent.bottom // bottom

                    color: "white"
                    opacity: 0.33
                }

                Column {
                    id: columnHeader
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    anchors.verticalCenter: rectangleHeader.verticalCenter

                    topPadding: Theme.componentMargin
                    bottomPadding: Theme.componentMargin
                    spacing: Theme.componentMargin

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: plantNameBotanical.text

                        Text {
                            text: qsTr("plant")
                            textFormat: Text.PlainText

                            color: "white"
                            opacity: 0.8
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantNameBotanical
                            anchors.left: parent.left
                            anchors.right: parent.right

                            font.pixelSize: Theme.fontSizeContentVeryBig + 8
                            wrapMode: Text.WordWrap
                            color: "white"
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: currentPlant.nameVariety

                        Text {
                            text: qsTr("variety")
                            textFormat: Text.PlainText

                            color: "white"
                            opacity: 0.8
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantNameVariety
                            anchors.left: parent.left
                            anchors.right: parent.right

                            font.pixelSize: Theme.fontSizeContentVeryBig + 4
                            wrapMode: Text.WordWrap
                            color: "white"
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: plantNameCommon.text

                        Text {
                            text: qsTr("common name")
                            textFormat: Text.PlainText

                            color: "white"
                            opacity: 0.8
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantNameCommon
                            anchors.left: parent.left
                            anchors.right: parent.right

                            font.pixelSize: Theme.fontSizeContentVeryBig + 2
                            wrapMode: Text.WordWrap
                            color: "white"
                        }
                    }
                }
            }
*/
            ////////

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: (uiMode === 1) ? -plantScreen.padding : 0
                anchors.right: parent.right
                anchors.rightMargin: (uiMode === 1) ? -plantScreen.padding : 0
                height: columnHeader.height

                color: (uiMode === 1) ? Theme.colorForeground : Theme.colorBackground

                Column {
                    id: columnHeader
                    anchors.left: parent.left
                    anchors.leftMargin: (uiMode === 1) ? plantScreen.padding : 0
                    anchors.right: parent.right
                    anchors.rightMargin: (uiMode === 1) ? plantScreen.padding : 0

                    topPadding: (uiMode === 1) ? Theme.componentMargin : -(Theme.componentMargin / 2)
                    bottomPadding: (uiMode === 1) ? Theme.componentMargin : 0
                    spacing: Theme.componentMargin

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: plantNameBotanical.text
                        spacing: 2

                        Text {
                            text: qsTr("plant")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantNameBotanical
                            anchors.left: parent.left
                            anchors.right: parent.right

                            font.pixelSize: Theme.fontSizeContentVeryBig + 4
                            wrapMode: Text.WordWrap
                            color: Theme.colorText
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: currentPlant && currentPlant.nameVariety
                        spacing: 2

                        Text {
                            text: qsTr("variety")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantNameVariety
                            anchors.left: parent.left
                            anchors.right: parent.right

                            font.pixelSize: Theme.fontSizeContentVeryBig + 2
                            wrapMode: Text.WordWrap
                            color: Theme.colorText
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: currentPlant && currentPlant.nameCommon
                        spacing: 2

                        Text {
                            text: qsTr("common name")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantNameCommon
                            anchors.left: parent.left
                            anchors.right: parent.right

                            font.pixelSize: Theme.fontSizeContentVeryBig + 2
                            wrapMode: Text.WordWrap
                            color: Theme.colorText
                        }
                    }

                    Flow {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Theme.componentMargin

                        Column {
                            spacing: 2

                            Text {
                                text: qsTr("category")
                                textFormat: Text.PlainText
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                id: plantCategory
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorText
                            }
                        }

                        Column {
                            spacing: 2

                            Text {
                                text: qsTr("origin")
                                textFormat: Text.PlainText
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                id: plantOrigin
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorText
                            }
                        }
                    }
                }
            }

            ////////

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMargin

                visible: (appContent.state === "DevicePlantSensor")

                ButtonFlat {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 999
                    Layout.maximumHeight: 36

                    text: qsTr("Swap plant")
                    source: "qrc:/IconLibrary/material-symbols/swap_horiz.svg"

                    onClicked: screenPlantBrowser.loadScreenFrom("DevicePlantSensor")
                }
                ButtonFlat {
                    color: Theme.colorSubText
                    Layout.fillWidth: false
                    Layout.fillHeight: false
                    Layout.maximumHeight: 36

                    text: qsTr("Remove")

                    onClicked: currentDevice.resetPlant()
                }
            }

            ////////

            Flow {
                id: itemTags
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMargin

                Repeater {
                    id: plantTags

                    TagFlat {
                        text: UtilsPlantDatabase.getPlantTagsText(modelData)
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentSmall
                        color: UtilsPlantDatabase.getPlantTagsColor(modelData)
                    }
                }
            }
/*
            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 4

                Text {
                    text: qsTr("COLORS TEST")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 8

                    Repeater {
                        id: plantColors
                        model: ["HotPink", "White", "Tomato", "Yellow", "Red", "Orange", "Gold", "LimeGreen", "Green", "MediumOrchid", "Purple", "YellowGreen", "LightYellow", "MediumVioletRed", "PeachPuff", "DodgerBlue", "Indigo", "Ivory", "DeepSkyBlue", "MistyRose", "DarkBlue", "MintCream", "Black", "OrangeRed", "PaleGreen", "Gainsboro", "PaleVioletRed", "Lavender", "Cyan", "MidnightBlue", "LightPink", "FireBrick", "Crimson", "DarkMagenta", "SteelBlue", "GreenYellow", "Brown", "DarkOrange", "Goldenrod", "DarkSeaGreen", "DarkRed", "LavenderBlush", "Violet", "Maroon", "Khaki", "WhiteSmoke", "Salmon", "Olive", "Orchid", "Fuchsia", "Pink", "LawnGreen", "Peru", "Grey", "Moccasin", "Beige", "Magenta", "DarkOrchid", "LightCyan", "RosyBrown", "GhostWhite", "MediumSeaGreen", "LemonChiffon", "Chocolate", "BurlyWood"]

                        Rectangle {
                            width: 64
                            height: 64
                            radius: 3
                            border.width: 3
                            border.color: Qt.darker(modelData, 1.1)
                            color: modelData

                            Text {
                                text: modelData
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                            }
                        }
                    }
                }
            }
*/
            Flow { // colors
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginL

                Column {
                    id: itemColorLeaf
                    spacing: 4

                    Text {
                        text: qsTr("leaf color")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentSmall
                        font.capitalization: Font.AllUppercase
                    }

                    Flow {
                        anchors.left: parent.left
                        spacing: 8

                        Repeater {
                            id: plantColorLeaf

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 3
                                border.width: 3
                                border.color: Qt.darker(modelData, 1.1)
                                color: modelData
                            }
                        }
                    }
                }

                Column {
                    id: itemColorBract
                    spacing: 4

                    Text {
                        text: qsTr("bract color")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentSmall
                        font.capitalization: Font.AllUppercase
                    }

                    Flow {
                        anchors.left: parent.left
                        spacing: 8

                        Repeater {
                            id: plantColorBract

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 3
                                border.width: 3
                                border.color: Qt.darker(modelData, 1.1)
                                color: modelData
                            }
                        }
                    }
                }

                Column {
                    id: itemColorFlower
                    spacing: 4

                    Text {
                        text: qsTr("flower color")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentSmall
                        font.capitalization: Font.AllUppercase
                    }

                    Flow {
                        anchors.left: parent.left
                        spacing: 8

                        Repeater {
                            id: plantColorFlower

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 3
                                border.width: 3
                                border.color: Qt.darker(modelData, 1.1)
                                color: modelData
                            }
                        }
                    }
                }

                Column {
                    id: itemColorFruit
                    spacing: 4

                    Text {
                        text: qsTr("fruit color")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentSmall
                        font.capitalization: Font.AllUppercase
                    }

                    Flow {
                        anchors.left: parent.left
                        spacing: 8

                        Repeater {
                            id: plantColorFruit

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 3
                                border.width: 3
                                border.color: Qt.darker(modelData, 1.1)
                                color: modelData
                            }
                        }
                    }
                }
            }

            ////////

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginL

                Column {
                    spacing: 4
                    width: plantHeightTxt.contentWidth

                    Text {
                        text: qsTr("height")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentSmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: plantHeightTxt
                        width: 64
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }

                Column {
                    spacing: 4
                    width: plantDiameterTxt.contentWidth

                    Text {
                        text: qsTr("diameter")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentSmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: plantDiameterTxt
                        width: 64
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }
            }
/*
            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 4

                Text {
                    text: qsTr("size")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 24
                    spacing: 8

                    IconSvg {
                        width: 24
                        height: 24
                        color: Theme.colorSubText
                        source: "qrc:/IconLibrary/material-symbols/diameter.svg"
                    }
                    Text {
                        id: plantDiameterTxt
                        width: 64
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                    PlantSizeWidget {
                        id: plantDiameter
                        width: parent.width - 128
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        enabled: false
                        from: 0
                        to: 66
                        stepSize: 1
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 24
                    spacing: 8

                    IconSvg {
                        width: 24
                        height: 24
                        color: Theme.colorSubText
                        source: "qrc:/IconLibrary/material-symbols/height.svg"
                    }
                    Text {
                        id: plantHeightTxt
                        width: 64
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                    PlantSizeWidget {
                        id: plantHeight
                        width: parent.width - 128
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        enabled: false
                        from: 0
                        to: 66
                        stepSize: 1
                    }
                }
            }
*/
            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 4

                visible: currentPlant && currentPlant.hardiness

                Text {
                    text: qsTr("hardiness")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                PlantHardinessWidget {
                    id: hw

                    plant: currentPlant
                }
            }

            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                visible: currentPlant && (currentPlant.calendarPlanting.length > 0 || currentPlant.calendarFertilizing.length > 0 ||
                                          currentPlant.calendarGrowing.length > 0 || currentPlant.calendarBlooming.length > 0 ||
                                          currentPlant.calendarFruiting.length > 0)

                Text {
                    text: qsTr("calendar")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                PlantCalendarWidget {
                    id: plantCalendarWidget

                    plant: currentPlant
                }
            }

            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                Text {
                    text: qsTr("Learn more")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                Row {
                    spacing: 12

                    ButtonFlat {
                        layoutDirection: Qt.RightToLeft

                        text: "Wikipedia"
                        source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                        sourceSize: 16

                        onClicked: Qt.openUrlExternally("https://wikipedia.org/wiki/" + currentPlant.nameBotanical_url)
                    }

                    ButtonFlat {
                        layoutDirection: Qt.RightToLeft

                        text: "Hortipedia"
                        source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                        sourceSize: 16

                        onClicked: Qt.openUrlExternally("https://hortipedia.com/" + currentPlant.nameBotanical_url)
                    }

                    ButtonFlat {
                        layoutDirection: Qt.RightToLeft

                        text: "RHS"
                        source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                        sourceSize: 16

                        onClicked: Qt.openUrlExternally("https://www.rhs.org.uk/plants/search-results?query=" + currentPlant.nameBotanical)
                    }
                }
            }

            ////////
        }
    }

    Flickable { ////////////////////////////////////////////////////////////////
        id: col2
        width: plantScreen.www2
        height: (uiMode === 1) ? columnCare.height + Theme.componentMargin : plantScreen.parentHeight
        contentWidth: columnCare.width
        contentHeight: columnCare.height + Theme.componentMargin
        interactive: (uiMode !== 1)

        Column {
            id: columnCare
            width: plantScreen.www2
            spacing: Theme.componentMargin

            ListTitle {
                anchors.leftMargin: singleColumn ? -Theme.componentMargin : -2
                anchors.rightMargin: singleColumn ? -Theme.componentMargin : -2

                text: qsTr("Plant care")
            }

            Row {
                spacing: Theme.componentMargin

                Rectangle {
                    id: rectangleSunlight
                    width: ((plantScreen.www2 - Theme.componentMargin) / 2)
                    height: width

                    radius: Theme.componentRadius
                    color: Theme.colorForeground
                    border.width: 2
                    border.color: Qt.darker(color, 1.03)

                    Item {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        width: parent.width - 8
                        height: parent.height - 8

                        IconSvg {
                            id: sunlight1
                            anchors.fill: parent
                            opacity: 0.16
                            color: Theme.colorYellow
                            source: "qrc:/assets/gfx/icons/sunlight4.svg"
                        }
                        IconSvg {
                            id: sunlight2
                            anchors.fill: parent
                            opacity: 0.4
                            color: Theme.colorYellow
                            source: "qrc:/assets/gfx/icons/sunlight3.svg"
                        }
                        IconSvg {
                            id: sunlight3
                            anchors.fill: parent
                            opacity: 0.6
                            color: Theme.colorYellow
                            source: "qrc:/assets/gfx/icons/sunlight2.svg"
                        }
                        IconSvg {
                            id: sunlight4
                            anchors.fill: parent
                            opacity: 1
                            color: Theme.colorYellow
                            source: "qrc:/assets/gfx/icons/sunlight1.svg"
                        }
                        IconSvg {
                            id: sunlight_borders
                            anchors.fill: parent
                            opacity: 1
                            color: Theme.colorLowContrast
                            source: "qrc:/assets/gfx/icons/sunlight_borders.svg"
                        }
                    }

                    Column {
                        anchors.top: parent.top
                        anchors.topMargin: plantScreen.insidemargins
                        anchors.left: parent.left
                        anchors.leftMargin: plantScreen.insidemargins
                        anchors.right: parent.right
                        anchors.rightMargin: plantScreen.insidemargins
                        spacing: 4

                        Text {
                            text: qsTr("sunlight")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantSunlight
                            anchors.left: parent.left
                            anchors.right: parent.right

                            fontSizeMode: Text.Fit
                            font.pixelSize: Theme.fontSizeContentBig
                            minimumPixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorText
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                ////

                Rectangle {
                    id: rectangleWatering
                    width: ((plantScreen.www2 - Theme.componentMargin) / 2)
                    height: width

                    radius: Theme.componentRadius
                    color: Theme.colorForeground
                    border.width: 2
                    border.color: Qt.darker(color, 1.03)

                    Item {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        width: parent.width - 8
                        height: parent.height - 8

                        IconSvg {
                            id: water4
                            anchors.fill: parent
                            opacity: 0.2
                            color: Theme.colorBlue
                            source: "qrc:/assets/gfx/icons/droplet4.svg"
                        }
                        IconSvg {
                            id: water3
                            anchors.fill: parent
                            opacity: 0.5
                            color: Theme.colorBlue
                            source: "qrc:/assets/gfx/icons/droplet3.svg"
                        }
                        IconSvg {
                            id: water2
                            anchors.fill: parent
                            opacity: 0.66
                            color: Theme.colorBlue
                            source: "qrc:/assets/gfx/icons/droplet2.svg"
                        }
                        IconSvg {
                            id: water1
                            anchors.fill: parent
                            opacity: 1
                            color: Theme.colorBlue
                            source: "qrc:/assets/gfx/icons/droplet1.svg"
                        }
                        IconSvg {
                            id: water_borders
                            anchors.fill: parent
                            opacity: 1
                            color: Theme.colorLowContrast
                            source: "qrc:/assets/gfx/icons/droplet_borders.svg"
                        }
                    }

                    Column {
                        anchors.top: parent.top
                        anchors.topMargin: plantScreen.insidemargins
                        anchors.left: parent.left
                        anchors.leftMargin: plantScreen.insidemargins
                        anchors.right: parent.right
                        anchors.rightMargin: plantScreen.insidemargins
                        spacing: 4

                        Text {
                            text: qsTr("watering")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: plantWatering
                            anchors.left: parent.left
                            anchors.right: parent.right

                            fontSizeMode: Text.Fit
                            font.pixelSize: Theme.fontSizeContentBig
                            minimumPixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorText
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            Rectangle {
                id: rectangleFertilization
                width: plantScreen.www2
                height: colFert.height + plantScreen.insidemargins*2

                radius: Theme.componentRadius
                color: Theme.colorForeground
                border.width: 2
                border.color: Qt.darker(color, 1.03)

                Column {
                    id: colFert
                    anchors.top: parent.top
                    anchors.topMargin: plantScreen.insidemargins
                    anchors.left: parent.left
                    anchors.leftMargin: plantScreen.insidemargins
                    anchors.right: parent.right
                    anchors.rightMargin: plantScreen.insidemargins
                    spacing: 4

                    Text {
                        text: qsTr("fertilization")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: plantFertilization
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: text
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        id: plantFertilizationTags
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: text
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Rectangle {
                id: rectanglePruning
                width: plantScreen.www2
                height: colPrun.height + plantScreen.insidemargins*2

                radius: Theme.componentRadius
                color: Theme.colorForeground
                border.width: 2
                border.color: Qt.darker(color, 1.03)

                Column {
                    id: colPrun
                    anchors.top: parent.top
                    anchors.topMargin: plantScreen.insidemargins
                    anchors.left: parent.left
                    anchors.leftMargin: plantScreen.insidemargins
                    anchors.right: parent.right
                    anchors.rightMargin: plantScreen.insidemargins
                    spacing: 4

                    Text {
                        text: qsTr("pruning")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: plantPruning
                        anchors.left: parent.left
                        anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Rectangle {
                id: rectangleSoil
                width: plantScreen.www2
                height: colSoil.height + plantScreen.insidemargins*2

                radius: Theme.componentRadius
                color: Theme.colorForeground
                border.width: 2
                border.color: Qt.darker(color, 1.03)

                Column {
                    id: colSoil
                    anchors.top: parent.top
                    anchors.topMargin: plantScreen.insidemargins
                    anchors.left: parent.left
                    anchors.leftMargin: plantScreen.insidemargins
                    anchors.right: parent.right
                    anchors.rightMargin: plantScreen.insidemargins
                    spacing: 4

                    Text {
                        text: qsTr("soil")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: plantSoil
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: text
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }/*
                    Image {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/assets/plants/soil_triangle.png"
                    }*/
                }
            }

            Rectangle {
                id: infoBox
                anchors.left: parent.left
                anchors.right: parent.right

                height: infoText.contentHeight + Theme.componentMargin
                radius: Theme.componentRadius
                z: 2

                color: Theme.colorComponentBackground
                border.width: 2
                border.color: Qt.darker(color, 1.03)

                IconSvg {
                    width: 28
                    height: 28
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 8

                    opacity: 0.66
                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
                }

                Text {
                    id: infoText
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 42
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    text: qsTr("Please note that WatchFlower should not be your definitive source of information about plant care.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContent
                }
            }
        }
    }

    Flickable { ////////////////////////////////////////////////////////////////
        id: col3
        width: plantScreen.www2
        height: (uiMode === 1) ? columnLimits.height + Theme.componentMargin : plantScreen.parentHeight
        contentWidth: columnLimits.width
        contentHeight: columnLimits.height + Theme.componentMargin
        interactive: (uiMode !== 1)

        Column {
            id: columnLimits
            width: plantScreen.www2
            spacing: Theme.componentMarginL

            ListTitle {
                anchors.leftMargin: singleColumn ? -Theme.componentMargin : -2
                anchors.rightMargin: singleColumn ? -Theme.componentMargin : -2

                text: qsTr("Sensor metrics")
            }

            Item {
                id: itemHygro
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: imageHygro
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-icons/duotone/water_mid.svg"
                }
                Text {
                    anchors.left: imageHygro.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageHygro.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Soil moisture")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_soilMoist
                    anchors.top: imageHygro.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    height: 22
                    hhh: 22

                    enabled: false
                    colorBackground: Theme.colorYellow
                    colorForeground: Theme.colorGreen
                    unit: "%"
                    from: 0
                    to: 100
                    stepSize: 1
                }
            }

            Item {
                id: itemCondu
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: imageCondu
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-symbols/sensors/tonality.svg"
                }
                Text {
                    anchors.left: imageCondu.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageCondu.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Soil conductivity")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_soilCondu
                    anchors.top: imageCondu.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    height: 22
                    hhh: 22

                    enabled: false
                    colorBackground: Theme.colorYellow
                    colorForeground: Theme.colorGreen
                    from: 0
                    to: 5000
                    stepSize: 50
                }
            }

            Item {
                id: itemSoilPH
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: imageSoilPH
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-symbols/sensors/tonality.svg"
                }
                Text {
                    anchors.left: imageSoilPH.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageSoilPH.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Soil PH")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_soilPH
                    anchors.top: imageSoilPH.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    height: 22
                    hhh: 22

                    enabled: false
                    colorBackground: Theme.colorYellow
                    colorForeground: Theme.colorGreen
                    from: 4
                    to: 10
                    stepSize: 0.1
                    floatprecision: 1

                    Row {
                        id: phScale // 4 to 10
                        anchors.top: rangeSlider_soilPH.bottom
                        anchors.topMargin: 8
                        anchors.horizontalCenter: rangeSlider_soilPH.horizontalCenter

                        spacing: 3
                        property int phsz: (rangeSlider_soilPH.width - 2*rangeSlider_soilPH.padding - 4 - 5*spacing) / 6

                        Rectangle { // 4
                            width: parent.phsz
                            height: 20
                            radius: Theme.componentRadius
                            color: "#ff914d"

                            Text {
                                anchors.centerIn: parent
                                text: "4"
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                            }
                        }
                        Rectangle { // 5
                            width: parent.phsz
                            height: 20
                            radius: Theme.componentRadius
                            color: "#ffbd59"

                            Text {
                                anchors.centerIn: parent
                                text: "5"
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                            }
                        }
                        Rectangle { // 6
                            width: parent.phsz
                            height: 20
                            radius: Theme.componentRadius
                            color: "#ffde59"

                            Text {
                                anchors.centerIn: parent
                                text: "6"
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                            }
                        }
                        Rectangle { // 7
                            width: parent.phsz
                            height: 20
                            radius: Theme.componentRadius
                            color: "#c9e265"

                            Text {
                                anchors.centerIn: parent
                                text: "7"
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                            }
                        }
                        Rectangle { // 8
                            width: parent.phsz
                            height: 20
                            radius: Theme.componentRadius
                            color: "#03989e"

                            Text {
                                anchors.centerIn: parent
                                text: "8"
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                            }
                        }
                        Rectangle { // 9
                            width: parent.phsz
                            height: 20
                            radius: Theme.componentRadius
                            color: "#2163bb"

                            Text {
                                anchors.centerIn: parent
                                text: "9"
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                            }
                        }
                    }
                }
            }

            Item {
                id: itemTemp
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                IconSvg {
                    id: imageTemp
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-symbols/sensors/airware.svg"
                }
                Text {
                    anchors.left: imageTemp.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageTemp.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Temperature")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_temp
                    anchors.top: imageTemp.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    height: 22
                    hhh: 22

                    enabled: false
                    colorBackground: Theme.colorYellow
                    colorForeground: Theme.colorGreen
                    unit: "°"
                    from: 0
                    to: 40
                    stepSize: 1
                }
            }

            Item {
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: imageHygro2
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-icons/duotone/water_mid.svg"
                }
                Text {
                    anchors.left: imageHygro2.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageHygro2.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Humidity")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_humi
                    anchors.top: imageHygro2.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    height: 22
                    hhh: 22

                    enabled: false
                    colorBackground: Theme.colorYellow
                    colorForeground: Theme.colorGreen
                    unit: "%"
                    from: 0
                    to: 100
                    stepSize: 1
                }
            }

            Item {
                id: itemLumi
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: imageLumi
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    color: Theme.colorText
                    source: "qrc:/IconLibrary/material-icons/duotone/wb_sunny.svg"
                }
                Text {
                    anchors.left: imageLumi.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageLumi.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Luminosity") +  " (lux)"
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_lumi_lux
                    anchors.top: imageLumi.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    height: 24
                    hhh: 22

                    enabled: false
                    colorBackground: Theme.colorYellow
                    colorForeground: Theme.colorGreen
                    unit: "k"
                    kshort: true
                    from: 0
                    to: 10000
                    stepSize: 1000

                    Row {
                        id: lumiScale
                        anchors.top: rangeSlider_lumi_lux.bottom
                        anchors.topMargin: 8
                        anchors.horizontalCenter: rangeSlider_lumi_lux.horizontalCenter

                        width: rangeSlider_lumi_lux.width - 2*rangeSlider_lumi_lux.padding - 4
                        spacing: 3

                        Rectangle {
                            id: lux_1
                            height: 20
                            width: (lumiScale.width - 3*parent.spacing) * 0.1 // 0 to 1k
                            radius: 2
                            visible: true
                            color: Theme.colorGrey

                            Text {
                                anchors.fill: parent
                                text: qsTr("low")
                                textFormat: Text.PlainText
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_2
                            height: 20
                            width: (lumiScale.width - 3*parent.spacing) * 0.2 // 1k to 3k
                            radius: 2
                            visible: true
                            color: "grey"

                            Text {
                                anchors.fill: parent
                                text: qsTr("indirect")
                                textFormat: Text.PlainText
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_3
                            height: 20
                            width: (lumiScale.width - 3*parent.spacing) * 0.5 // 3k to 8k
                            radius: 2
                            visible: true
                            color: Theme.colorYellow

                            Text {
                                anchors.fill: parent
                                text: qsTr("direct light (indoor)")
                                textFormat: Text.PlainText
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_4
                            height: 20
                            width: (lumiScale.width - 3*parent.spacing) * 0.2 // 8k+
                            radius: 2
                            visible: true
                            color: "orange"

                            Text {
                                anchors.fill: parent
                                text: qsTr("sunlight")
                                textFormat: Text.PlainText
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            id: lux_5
                            height: 20
                            width: (lumiScale.width - 3*parent.spacing) * 0.16 // 0-15k
                            radius: 2
                            visible: false
                            color: "grey"

                            Text {
                                anchors.fill: parent
                                text: qsTr("indirect")
                                textFormat: Text.PlainText
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_6
                            height: 20
                            width: (lumiScale.width - 3*parent.spacing) * 0.84 // 15k+
                            radius: 2
                            visible: false
                            color: Theme.colorYellow

                            Text {
                                anchors.fill: parent
                                text: qsTr("sunlight")
                                textFormat: Text.PlainText
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            Item {
                id: itemLumiMmol
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: imageLumiMmol
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    color: Theme.colorText
                    source: "qrc:/IconLibrary/material-icons/duotone/wb_sunny.svg"
                }
                Text {
                    anchors.left: imageLumiMmol.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageLumiMmol.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Luminosity")+ " (mmol)"
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_lumi_mmol
                    anchors.top: imageLumiMmol.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    height: 22
                    hhh: 22

                    enabled: false
                    colorBackground: Theme.colorYellow
                    colorForeground: Theme.colorGreen
                    unit: "k"
                    kshort: true
                    from: 0
                    to: 25000
                    stepSize: 100
                }
            }

            ////
        }
    }
}
