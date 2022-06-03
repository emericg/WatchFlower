import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import ThemeEngine 1.0
//import PlantUtils 1.0
//import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase

Grid {
    id: plantScreen

    rows: singleColumn ? 3 : 1
    columns: singleColumn ? 1 : 3
    spacing: isPhone ? 12 : 16
    padding: isPhone ? 12 : 16

    property int parentWidth: appContent.width // default
    property int parentHeight: parent.height // default

    property int www1: singleColumn ? (parentWidth - plantScreen.padding*2) : 480
    property int www2: singleColumn ? (parentWidth - plantScreen.padding*2) : 600
    property int insidemargins: singleColumn ? 8 : 16

    ////////

    property var currentPlant: null
    property string currentPlantNameClean

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
        currentPlantNameClean = currentPlant.nameBotanical_url

        plantNameBotanical.text = currentPlant.nameBotanical
        plantNameVariety.text = currentPlant.nameVariety
        plantNameCommon.text = currentPlant.nameCommon
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

        // calendar
        //plantBlooming.text = currentPlant.calendarPlanting
        //currentPlant.calendarGrowing
        //currentPlant.calendarBlooming
        //currentPlant.calendarFruiting

        // sunlight
        rectangleSunlight.visible = currentPlant.sunlight
        if (currentPlant.sunlight) {
            plantSunlight.text = currentPlant.sunlight

            sunlight4.color = currentPlant.sunlight.includes("full sun") ? Theme.colorYellow : Qt.lighter(Theme.colorYellow, 1.8)
            sunlight3.color = currentPlant.sunlight.includes("part sun") ? Qt.lighter(Theme.colorYellow, 1.25) : Qt.lighter(Theme.colorYellow, 1.8)
            sunlight2.color = currentPlant.sunlight.includes("part shade") ? Qt.lighter(Theme.colorYellow, 1.45) : Qt.lighter(Theme.colorYellow, 1.85)
            sunlight1.color = currentPlant.sunlight.includes("shade to") ||
                              currentPlant.sunlight.includes("to shade") ? Qt.lighter(Theme.colorYellow, 1.55) : Qt.lighter(Theme.colorYellow, 1.9)

            if (currentPlant.sunlight === "full sun") {
                sunlight4.color = Theme.colorYellow
                sunlight3.color = Qt.lighter(Theme.colorYellow, 1.25)
                sunlight2.color = Qt.lighter(Theme.colorYellow, 1.45)
                sunlight1.color = Qt.lighter(Theme.colorYellow, 1.55)
            }
            if (currentPlant.sunlight === "full sun to part shade") {
                sunlight3.color = Qt.lighter(Theme.colorYellow, 1.25)
            }
        }

        // watering
        rectangleWatering.visible = currentPlant.watering
        if (currentPlant.watering) {
            //plantWatering.text = currentPlant.watering
            var watwat = currentPlant.watering.charAt(0)
            var watStr = ""
            if (watwat == 1) watStr = qsTr("low water needs") + "<br>"
            else if (watwat == 2) watStr = qsTr("medium water needs") + "<br>"
            else if (watwat == 3) watStr = qsTr("high water needs") + "<br>"
            else if (watwat == 4) watStr = qsTr("keep moist") + "<br>"
            if (currentPlant.watering.includes("dry")) watStr += qsTr("water when soil is dry")
            if (currentPlant.watering.includes("spay")) watStr += qsTr("spray water on leaves")

            var colorWaterDisabled = Theme.colorLowContrast // Qt.lighter(Theme.colorBlue, 1.6)
            water2.color = watwat >= 2 ? Theme.colorBlue : colorWaterDisabled
            water3.color = watwat >= 3 ? Theme.colorBlue : colorWaterDisabled
            water4.color = watwat >= 4 ? Theme.colorBlue : colorWaterDisabled
            plantWatering.text = watStr
        }

        // Fertilization
        rectangleFertilization.visible = currentPlant.fertilization
        plantFertilization.text = currentPlant.fertilization

        // Pruning
        rectanglePruning.visible = currentPlant.pruning
        plantPruning.text = currentPlant.pruning

        // Soil
        rectangleSoil.visible = currentPlant.soil
        plantSoil.text = currentPlant.soil

        // limit sliders
        rangeSlider_soilMoist.setValues(currentPlant.soilMoist_min, currentPlant.soilMoist_max)
        rangeSlider_soilCondu.setValues(currentPlant.soilCondu_min, currentPlant.soilCondu_max)
        itemSoilPH.visible = (currentPlant.soilPH_min > 0)
        rangeSlider_soilPH.setValues(currentPlant.soilPH_min, currentPlant.soilPH_max)
        rangeSlider_temp.setValues(currentPlant.envTemp_min, currentPlant.envTemp_max)
        rangeSlider_humi.setValues(currentPlant.envHumi_min, currentPlant.envHumi_max)
        rangeSlider_lumi_lux.setValues(currentPlant.lightLux_min, currentPlant.lightLux_max)
        itemLumiMmol.visible = (currentPlant.lightMmol_min > 0)
        rangeSlider_lumi_mmol.setValues(currentPlant.lightMmol_min, currentPlant.lightMmol_max)
    }

    Flickable { ////////////////////////////////////////////////////////
        width: plantScreen.www1
        height: singleColumn ? columnPlant.height + 24 : plantScreen.parentHeight
        contentWidth: columnPlant.width
        contentHeight: columnPlant.height + 32
        interactive: !singleColumn

        Column {
            id: columnPlant
            width: plantScreen.www1
            spacing: 24

            topPadding: singleColumn ? -plantScreen.padding : 0
/*
            Image {
                id: plantPicture
                anchors.left: parent.left
                anchors.leftMargin: singleColumn ? -plantScreen.padding : 0
                anchors.right: parent.right
                anchors.rightMargin: singleColumn ? -plantScreen.padding : 0
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
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: rectangleHeader.verticalCenter

                    topPadding: 16
                    bottomPadding: 16
                    spacing: 16

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
                        visible: plantNameVariety.text

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
                anchors.leftMargin: singleColumn ? -plantScreen.padding : 0
                anchors.right: parent.right
                anchors.rightMargin: singleColumn ? -plantScreen.padding : 0
                height: columnHeader.height

                color: singleColumn ? Theme.colorForeground : Theme.colorBackground

                Column {
                    id: columnHeader
                    anchors.left: parent.left
                    anchors.leftMargin: singleColumn ? plantScreen.padding : 0
                    anchors.right: parent.right
                    anchors.rightMargin: singleColumn ? plantScreen.padding : 0

                    topPadding: singleColumn ? 16 : 0
                    bottomPadding: singleColumn ? 16 : 0
                    spacing: 16

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: plantNameBotanical.text

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
                        visible: plantNameVariety.text

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
                        visible: plantNameCommon.text

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
                        spacing: 16

                        Column {
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
                spacing: 16

                visible: (appContent.state === "DevicePlantSensor")

                ButtonWireframeIcon {
                    fullColor: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 999

                    text: qsTr("Change the associated plant")
                    source: "qrc:/assets/icons_material/duotone-touch_app-24px.svg"

                    onClicked: {
                        screenPlantBrowser.loadScreenFrom("DevicePlantSensor")
                    }
                }
                ButtonWireframeIcon {
                    fullColor: true
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground
                    Layout.fillWidth: false

                    text: qsTr("Reset")

                    onClicked: currentDevice.resetPlant()
                }
            }

            ////////

            Flow {
                id: itemTags
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4
                spacing: 20

                Repeater {
                    id: plantTags

                    Text {
                        text: modelData
                        color: "white"
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: -4
                            anchors.leftMargin: -8
                            anchors.rightMargin: -8
                            anchors.bottomMargin: -4
                            z: -1

                            color: Theme.colorBlue
                            radius: Theme.componentRadius
                        }
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
                spacing: 16

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

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 16

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
                        source: "qrc:/assets/icons_material/outline-diameter-24px.svg"
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
                        source: "qrc:/assets/icons_material/baseline-height-24px.svg"
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

                    ButtonWireframeIcon {
                        layoutDirection: Qt.RightToLeft
                        primaryColor: Theme.colorPrimary
                        secondaryColor: Theme.colorBackground

                        text: qsTr("wikipedia")
                        source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                        sourceSize: 16

                        onClicked: Qt.openUrlExternally("https://wikipedia.org/wiki/" + plantScreen.currentPlantNameClean)
                    }

                    ButtonWireframeIcon {
                        layoutDirection: Qt.RightToLeft
                        primaryColor: Theme.colorPrimary
                        secondaryColor: Theme.colorBackground

                        text: qsTr("hortipedia")
                        source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                        sourceSize: 16

                        onClicked: Qt.openUrlExternally("https://hortipedia.com/" + plantScreen.currentPlantNameClean)
                    }
                }
            }
        }
    }

    Flickable { ////////////////////////////////////////////////////////
        width: plantScreen.www2
        height: singleColumn ? columnCare.height + 24 : plantScreen.parentHeight
        contentWidth: columnCare.width
        contentHeight: columnCare.height + 32
        interactive: !singleColumn

        Column  {
            id: columnCare
            width: plantScreen.www2
            spacing: 16

            Text {
                text: qsTr("Plant care")
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            Rectangle {
                id: infoBox
                anchors.left: parent.left
                anchors.right: parent.right

                width: (parent.width / 2) - 24
                height: infoText.contentHeight + 16
                radius: 4
                z: 2

                color: Theme.colorComponentBackground
                border.color: Theme.colorSeparator
                border.width: 1

                IconSvg {
                    width: 32
                    height: 32
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    color: Theme.colorSubText
                }

                Text {
                    id: infoText
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 52
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    text: qsTr("Please note that WatchFlower should not be your definitive source of information about plant care.")
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContent
                }
            }

            Row {
                spacing: 16

                Rectangle {
                    id: rectangleSunlight
                    width: ((plantScreen.www2 - 16) / 2)
                    height: width
                    radius: 8
                    clip: true
                    color: Theme.colorForeground
                    border.width: 2
                    border.color: Theme.colorSeparator

                    Item {
                        anchors.fill: parent
                        anchors.margins: 2
                        clip: true

                        Rectangle {
                            id: sunlight1
                            anchors.verticalCenter: parent.bottom
                            anchors.horizontalCenter: parent.right
                            width: plantScreen.www2 * 0.95 - 4 - 8
                            height: width
                            radius: width
                            //opacity: 0.8
                            color: Theme.colorYellow
                            border.width: 2
                            border.color: "white"
                        }
                        Rectangle {
                            id: sunlight2
                            anchors.verticalCenter: parent.bottom
                            anchors.horizontalCenter: parent.right
                            width: plantScreen.www2 * 0.68
                            height: width
                            radius: width
                            //opacity: 0.33
                            color: Theme.colorYellow
                            border.width: 2
                            border.color: "white"
                        }
                        Rectangle {
                            id: sunlight3
                            anchors.verticalCenter: parent.bottom
                            anchors.horizontalCenter: parent.right
                            width: plantScreen.www2 * 0.45
                            height: width
                            radius: width
                            //opacity: 0.5
                            color: Theme.colorYellow
                            border.width: 2
                            border.color: "white"
                        }
                        Rectangle {
                            id: sunlight4
                            anchors.verticalCenter: parent.bottom
                            anchors.horizontalCenter: parent.right
                            width: plantScreen.www2 * 0.25
                            height: width
                            radius: width
                            color: Theme.colorYellow
                            border.width: 2
                            border.color: "white"
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
                    width: ((plantScreen.www2 - 16) / 2)
                    height: width
                    radius: 8
                    clip: true
                    color: Theme.colorForeground
                    border.width: 2
                    border.color: Theme.colorSeparator

                    IconSvg {
                        id: water4
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: plantScreen.www2 * 0.38
                        height: width
                        opacity: 0.5
                        color: Theme.colorBlue
                        source: "qrc:/assets/icons_custom/droplet-24px.svg"

                        IconSvg {
                            anchors.fill: parent
                            color: "white"
                            source: "qrc:/assets/icons_custom/dropletborder-24px.svg"
                        }
                    }
                    IconSvg {
                        id: water3
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: plantScreen.www2 * 0.28
                        height: width
                        opacity: 0.66
                        color: Theme.colorBlue
                        source: "qrc:/assets/icons_custom/droplet-24px.svg"

                        IconSvg {
                            anchors.fill: parent
                            color: "white"
                            source: "qrc:/assets/icons_custom/dropletborder-24px.svg"
                        }
                    }
                    IconSvg {
                        id: water2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: plantScreen.www2 * 0.18
                        height: width
                        opacity: 0.8
                        color: Theme.colorBlue
                        source: "qrc:/assets/icons_custom/droplet-24px.svg"

                        IconSvg {
                            anchors.fill: parent
                            color: "white"
                            source: "qrc:/assets/icons_custom/dropletborder-24px.svg"
                        }
                    }
                    IconSvg {
                        id: water1
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: plantScreen.www2 * 0.1
                        height: width
                        color: Theme.colorBlue
                        source: "qrc:/assets/icons_custom/droplet-24px.svg"

                        IconSvg {
                            anchors.fill: parent
                            color: "white"
                            source: "qrc:/assets/icons_custom/dropletborder-24px.svg"
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
                radius: 8
                color: Theme.colorForeground
                border.width: 2
                border.color: Theme.colorSeparator

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
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: plantFertilization
                        anchors.left: parent.left
                        anchors.right: parent.right
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
                radius: 8
                color: Theme.colorForeground
                border.width: 2
                border.color: Theme.colorSeparator

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
                radius: 8
                color: Theme.colorForeground
                border.width: 2
                border.color: Theme.colorSeparator

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
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: plantSoil
                        anchors.left: parent.left
                        anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }
                }
            }
/*
            Column {
                anchors.left: parent.left
                anchors.right: parent.right

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
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
*/
        }
    }

    Flickable { ////////////////////////////////////////////////////////
        width: plantScreen.www2
        height: singleColumn ? columnLimits.height + 24 : plantScreen.parentHeight
        contentWidth: columnLimits.width
        contentHeight: columnLimits.height + 32
        interactive: !singleColumn

        Column {
            id: columnLimits
            width: plantScreen.www2
            spacing: 24

            Text {
                text: qsTr("sensor metrics")
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
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
                    source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                }
                Text {
                    anchors.left: imageHygro.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageHygro.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Soil moisture")
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
                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
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
                    source: "qrc:/assets/icons_material/baseline-tonality-24px.svg"
                }
                Text {
                    anchors.left: imageCondu.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageCondu.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Soil conductivity")
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
                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    from: 0
                    to: 5000
                    stepSize: 50
                }
            }

            Item {
                id: itemSoilPH
                height: 40
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
                    source: "qrc:/assets/icons_material/baseline-tonality-24px.svg"
                }
                Text {
                    anchors.left: imageSoilPH.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageSoilPH.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Soil PH")
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
                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    from: 0
                    to: 12
                    stepSize: 0.1
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
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                }
                Text {
                    anchors.left: imageTemp.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageTemp.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Temperature")
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
                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
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
                    source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                }
                Text {
                    anchors.left: imageHygro2.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageHygro2.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Humidity")
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
                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
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
                    source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                }
                Text {
                    anchors.left: imageLumi.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageLumi.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Luminosity (lux)")
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
                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    unit: "k"
                    kshort: true
                    from: 0
                    to: 10000
                    stepSize: 1000

                    Row {
                        id: lumiScale
                        anchors.top: rangeSlider_lumi_lux.bottom
                        anchors.topMargin: 8
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.right: parent.right
                        anchors.rightMargin: 8

                        spacing: 2

                        Rectangle {
                            id: lux_1
                            height: 18
                            width: (lumiScale.width - 4) * 0.1 // 0 to 1k
                            visible: true
                            color: Theme.colorGrey
                            Text {
                                anchors.fill: parent
                                text: qsTr("low")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_2
                            height: 18
                            width: (lumiScale.width - 8) * 0.2 // 1k to 3k
                            visible: true
                            color: "grey"
                            Text {
                                anchors.fill: parent
                                text: qsTr("indirect")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_3
                            height: 18
                            width: (lumiScale.width - 16) * 0.5 // 3k to 8k
                            visible: true
                            color: Theme.colorYellow
                            Text {
                                anchors.fill: parent
                                text: qsTr("direct light (indoor)")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_4
                            height: 18
                            width: (lumiScale.width - 0) * 0.2 // 8k+
                            visible: true
                            color: "orange"
                            Text {
                                anchors.fill: parent
                                text: qsTr("sunlight")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            id: lux_5
                            height: 18
                            width: (lumiScale.width - 6) * 0.16 // 0-15k
                            visible: false
                            color: "grey"
                            Text {
                                anchors.fill: parent
                                text: qsTr("indirect")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_6
                            height: 18
                            width: (lumiScale.width - 6) * 0.84 // 15k+
                            visible: false
                            color: Theme.colorYellow
                            Text {
                                anchors.fill: parent
                                text: qsTr("sunlight")
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
                    source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                }
                Text {
                    anchors.left: imageLumiMmol.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageLumiMmol.verticalCenter
                    anchors.verticalCenterOffset: isDesktop ? 1 : 0

                    text: qsTr("Luminosity (mmol)")
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
                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    unit: "k"
                    kshort: true
                    from: 0
                    to: 10000
                    stepSize: 1000
                }
            }

            ////
        }
    }
}
