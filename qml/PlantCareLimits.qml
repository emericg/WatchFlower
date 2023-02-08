import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Flickable {
    id: plantCareLimits

    contentWidth: -1
    contentHeight: column.height

    function updateLimits() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("PlantCareLimits // updateLimits() >> " + currentDevice)

        plantCareLimits.contentY = 0

        itemHygro.visible = currentDevice.hasSoilMoistureSensor
        itemCondu.visible = currentDevice.hasSoilConductivitySensor
        itemTemp.visible = currentDevice.hasTemperatureSensor
        itemLumi.visible = currentDevice.hasLuminositySensor

        rangeSlider_hygro.setValues(currentDevice.soilMoisture_limitMin, currentDevice.soilMoisture_limitMax)
        rangeSlider_condu.setValues(currentDevice.soilConductivity_limitMin, currentDevice.soilConductivity_limitMax)
        rangeSlider_temp.setValues(currentDevice.temperature_limitMin, currentDevice.temperature_limitMax)
        rangeSlider_lumi.setValues(currentDevice.luminosityLux_limitMin, currentDevice.luminosityLux_limitMax)
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right

        topPadding: 0 // isPhone ? 12 : 16
        bottomPadding: 16
        spacing: 16

        ////////////////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right

            height: 40
            opacity: 0.66
            color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground
            layer.enabled: true

            IconSvg {
                width: 20
                height: 20
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                color: Theme.colorSubText
                source: "qrc:/assets/icons_material/baseline-info-24px.svg"
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Drag sliders to change values")
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContentSmall
            }
        }

        ////////////////

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
                anchors.left: parent.left
                anchors.leftMargin: 8

                color: Theme.colorText
                source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
            }
            Text {
                anchors.left: imageHygro.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageHygro.verticalCenter
                anchors.verticalCenterOffset: isDesktop ? 1 : 0

                text: qsTr("Soil moisture")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_hygro
                height: 32
                anchors.top: imageHygro.bottom
                anchors.topMargin: -2
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                hhh: isMobile ? 22 : 20
                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                unit: "%"
                from: 0
                to: 66
                stepSize: 1

                first.onPressedChanged: plantSensorPages.interactive = !first.pressed
                first.onMoved: if (currentDevice) currentDevice.soilMoisture_limitMin = first.value.toFixed(0)

                second.onPressedChanged: plantSensorPages.interactive = !second.pressed
                second.onMoved: if (currentDevice) currentDevice.soilMoisture_limitMax = second.value.toFixed(0)
            }
        }
        Text {
            id: legendHygro
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 16

            visible: itemHygro.visible

            text: qsTr("Ideal soil moisture for indoor plants is usually 15 to 50%. Cacti and succulents can go as low as 7%. Tropical plants like to have more water.") +
                  qsTr("<br><b>Tip: </b>") + qsTr("Be careful, too much water over long periods of time can be just as lethal as not enough!") +
                  qsTr("<br><b>Tip: </b>") + qsTr("Water your plants more frequently during their growth period.")
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
        }

        ////////

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
                anchors.left: parent.left
                anchors.leftMargin: 8

                rotation: 90
                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-tonality-24px.svg"
            }
            Text {
                anchors.left: imageCondu.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageCondu.verticalCenter
                anchors.verticalCenterOffset: isDesktop ? 1 : 0

                text: qsTr("Soil conductivity")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_condu
                height: 32
                anchors.top: imageCondu.bottom
                anchors.topMargin: -2
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                hhh: isMobile ? 22 : 20
                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                from: 0
                to: 2000
                stepSize: 50

                first.onPressedChanged: plantSensorPages.interactive = !first.pressed
                first.onMoved: if (currentDevice) currentDevice.soilConductivity_limitMin = first.value.toFixed(0)

                second.onPressedChanged: plantSensorPages.interactive = !second.pressed
                second.onMoved: if (currentDevice) currentDevice.soilConductivity_limitMax = second.value.toFixed(0)
            }
        }
        Text {
            id: legendCondu
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 16

            visible: itemCondu.visible

            text: qsTr("Soil 'Electrical Conductivity' value is an indication of the availability of nutrients in the soil. Use fertilizer (with moderation) to keep this value up.") +
                  qsTr("<br><b>Tip: </b>") + qsTr("Be sure to use the right soil composition for your plants.")
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
        }

        ////////

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
                anchors.left: parent.left
                anchors.leftMargin: 8

                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
            }
            Text {
                anchors.left: imageTemp.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageTemp.verticalCenter
                anchors.verticalCenterOffset: isDesktop ? 1 : 0

                text: qsTr("Temperature")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_temp
                height: 32
                anchors.top: imageTemp.bottom
                anchors.topMargin: -2
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                hhh: isMobile ? 22 : 20
                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                unit: "°"
                from: currentDevice.deviceIsOutside ? 0 : 12
                to: currentDevice.deviceIsOutside ? 50 : 32
                stepSize: 1

                first.onPressedChanged: plantSensorPages.interactive = !first.pressed
                first.onMoved: {
                    if (currentDevice) {
                        if ((first.value > rangeSlider_temp.from && first.value < rangeSlider_temp.to) ||
                            (first.value >= rangeSlider_temp.from && first.value <= rangeSlider_temp.to &&
                             currentDevice.temperature_limitMin >= rangeSlider_temp.from && currentDevice.temperature_limitMin <= rangeSlider_temp.to)) {
                            currentDevice.temperature_limitMin = first.value.toFixed(0)
                        }
                    }
                }

                second.onPressedChanged: plantSensorPages.interactive = !second.pressed
                second.onMoved: {
                    if (currentDevice) {
                        if ((second.value > rangeSlider_temp.from && second.value < rangeSlider_temp.to) ||
                            (second.value >= rangeSlider_temp.from && second.value <= rangeSlider_temp.to &&
                             currentDevice.temperature_limitMax >= rangeSlider_temp.from && currentDevice.temperature_limitMax <= rangeSlider_temp.to)) {
                            currentDevice.temperature_limitMax = second.value.toFixed(0)
                        }
                    }
                }
            }
        }
        Text {
            id: legendTemp
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 16

            visible: itemTemp.visible

            text: qsTr("Most indoor plants thrive between 15 and 25°C (59 to 77°F). Not many plants can tolerate -2°C (28°F) and below.") +
                  qsTr("<br><b>Tip: </b>") + qsTr("Having constant temperature is important for indoor plants.") +
                  qsTr("<br><b>Tip: </b>") + qsTr("If you have an hygrometer, you can monitor the air humidity so it stays between 40 and 60% (and even above for tropical plants).")
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
        }

        ////////

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
                anchors.left: parent.left
                anchors.leftMargin: 8

                color: Theme.colorText
                source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
            }
            Text {
                anchors.left: imageLumi.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageLumi.verticalCenter
                anchors.verticalCenterOffset: isDesktop ? 1 : 0

                text: qsTr("Luminosity")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_lumi
                height: 32
                anchors.top: imageLumi.bottom
                anchors.topMargin: -2
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                hhh: isMobile ? 22 : 20
                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                unit: "k"
                kshort: true
                from: 0
                to: currentDevice.deviceIsOutside ? 100000 : 10000
                stepSize: currentDevice.deviceIsOutside ? 5000 : 1000

                first.onPressedChanged: plantSensorPages.interactive = !first.pressed
                first.onMoved: {
                    if (currentDevice) {
                        if (first.value < rangeSlider_lumi.to ||
                            (first.value <= rangeSlider_lumi.to && currentDevice.luminosityLux_limitMin <= rangeSlider_lumi.to)) {
                            currentDevice.luminosityLux_limitMin = first.value.toFixed(0)
                        }
                    }
                }

                second.onPressedChanged: plantSensorPages.interactive = !second.pressed
                second.onMoved: {
                    if (currentDevice) {
                        if (second.value < rangeSlider_lumi.to ||
                            (second.value <= rangeSlider_lumi.to && currentDevice.luminosityLux_limitMax <= rangeSlider_lumi.to)) {
                            currentDevice.luminosityLux_limitMax = second.value.toFixed(0)
                        }
                    }
                }

                Row {
                    id: lumiScale
                    anchors.top: rangeSlider_lumi.bottom
                    anchors.topMargin: 2
                    anchors.horizontalCenter: rangeSlider_lumi.horizontalCenter

                    width: rangeSlider_lumi.width - 2*rangeSlider_lumi.padding - 4
                    spacing: 3

                    Rectangle {
                        id: lux_1
                        height: 20
                        width: (lumiScale.width - 3*parent.spacing) * 0.1 // 0 to 1k
                        visible: currentDevice.deviceIsInside
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
                        visible: currentDevice.deviceIsInside
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
                        visible: currentDevice.deviceIsInside
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
                        visible: currentDevice.deviceIsInside
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
                        width: (lumiScale.width - 2*parent.spacing) * 0.16 // 0-15k
                        visible: currentDevice.deviceIsOutside
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
                        width: (lumiScale.width - 2*parent.spacing) * 0.84 // 15k+
                        visible: currentDevice.deviceIsOutside
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
        Text {
            id: legendLumi
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 16

            visible: itemLumi.visible

            text: qsTr("Some plants like direct sun exposition, all day long or just for part of the day. But many indoor plants don't like direct sunlight: place them away from south oriented windows!")
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
        }

        ////////

        Item {
            id: itemOther
            height: 256
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            IconSvg {
                id: imageOther
                width: 24
                height: 24
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 8

                color: Theme.colorText
                source: "qrc:/assets/icons_material/duotone-tune-24px.svg"
            }
            Text {
                anchors.left: imageOther.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageOther.verticalCenter
                anchors.verticalCenterOffset: isDesktop ? 1 : 0

                text: qsTr("Other settings")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: 32
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 12
                spacing: isPhone ? 12 : 16

                ButtonWireframeIcon {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: currentDevice.hasPlant
                    primaryColor: Theme.colorPrimary
                    secondaryColor: Theme.colorBackground

                    text: qsTr("Reset limits from the associated plant")
                    source: "qrc:/assets/icons_material/baseline-flaky-24px.svg"

                    onClicked: currentDevice.resetLimits()
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: isPhone ? 12 : 16

                    property int www: singleColumn ? ((width - spacing) / 2) : 256
                    property int hhh: Math.min(www, 140)

                    Rectangle {
                        id: rectangleInside
                        width: parent.www
                        height: parent.hhh
                        radius: Theme.componentRadius

                        color: currentDevice.deviceIsInside ? Theme.colorForeground : Theme.colorBackground
                        Behavior on color { ColorAnimation { duration: 133 } }

                        border.width: currentDevice.deviceIsInside ? 2 : 1
                        border.color: Theme.colorSeparator

                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentDevice.deviceIsInside = true
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            opacity: currentDevice.deviceIsInside ? 0.85 : 0.33
                            Behavior on opacity { OpacityAnimator { duration: 133 } }

                            IconSvg {
                                id: insideImage
                                width: 72; height: 72;
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Theme.colorText
                                source: "qrc:/assets/icons_custom/inside-24px.svg"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("inside")
                                textFormat: Text.PlainText
                                color: Theme.colorText
                                font.pixelSize: Theme.fontSizeContent
                            }
                        }
                    }

                    Rectangle {
                        id: rectangleOutside
                        width: parent.www
                        height: parent.hhh
                        radius: Theme.componentRadius

                        color: currentDevice.deviceIsOutside ? Theme.colorForeground : Theme.colorBackground
                        Behavior on color { ColorAnimation { duration: 133 } }

                        border.width: currentDevice.deviceIsOutside ? 2 : 1
                        border.color: Theme.colorSeparator

                        //opacity: currentDevice.deviceIsOutside ? 0.8 : 0.25
                        //Behavior on opacity { OpacityAnimator { duration: 133 } }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentDevice.deviceIsOutside = true
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            opacity: currentDevice.deviceIsOutside ? 0.85 : 0.33
                            Behavior on opacity { OpacityAnimator { duration: 133 } }

                            IconSvg {
                                id: outsideImage
                                width: 72; height: 72;
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "qrc:/assets/icons_custom/outside-24px.svg"
                                color: Theme.colorText
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("outside")
                                textFormat: Text.PlainText
                                color: Theme.colorText
                                font.pixelSize: Theme.fontSizeContent
                            }
                        }
                    }
                }
            }
        }

        ////////
    }
}
