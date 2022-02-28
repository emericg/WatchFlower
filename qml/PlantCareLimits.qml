import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Flickable {
    id: plantCareLimits

    contentWidth: -1
    contentHeight: column.height

    function updateLimits() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("PlantCareLimits // updateLimits() >> " + currentDevice)

        itemHygro.visible = currentDevice.hasHumiditySensor || currentDevice.hasSoilMoistureSensor
        itemCondu.visible = currentDevice.hasSoilConductivitySensor
        itemTemp.visible = currentDevice.hasTemperatureSensor
        itemLumi.visible = currentDevice.hasLuminositySensor

        rangeSlider_hygro.setValues(currentDevice.limitHygroMin, currentDevice.limitHygroMax)
        rangeSlider_condu.setValues(currentDevice.limitConduMin, currentDevice.limitConduMax)
        rangeSlider_temp.setValues(currentDevice.limitTempMin, currentDevice.limitTempMax)
        rangeSlider_lumi.setValues(currentDevice.limitLuxMin, currentDevice.limitLuxMax)
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right

        topPadding: 16
        bottomPadding: 16
        spacing: 16

        ////////

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
                anchors.leftMargin: 8

                color: Theme.colorText
                source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
            }
            Text {
                anchors.left: imageHygro.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageHygro.verticalCenter
                anchors.verticalCenterOffset: 2

                text: currentDevice.hasSoilMoistureSensor ? qsTr("Moisture") : qsTr("Humidity")
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_hygro
                height: 20
                anchors.top: imageHygro.bottom
                anchors.topMargin: 2
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                unit: "%"
                from: 0
                to: 66
                stepSize: 1
                first.onMoved: if (currentDevice) currentDevice.limitHygroMin = first.value.toFixed(0)
                second.onMoved: if (currentDevice) currentDevice.limitHygroMax = second.value.toFixed(0)
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
                anchors.leftMargin: 8

                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
            }
            Text {
                anchors.left: imageTemp.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageTemp.verticalCenter
                anchors.verticalCenterOffset: 1

                text: qsTr("Temperature")
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_temp
                height: 20
                anchors.top: imageTemp.bottom
                anchors.topMargin: 2
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                unit: "°"
                from: outsideMode ? 0 : 12
                to: outsideMode ? 50 : 32
                stepSize: 1

                first.onMoved: {
                    if (currentDevice) {
                        if ((first.value > rangeSlider_temp.from && first.value < rangeSlider_temp.to) ||
                            (first.value >= rangeSlider_temp.from && first.value <= rangeSlider_temp.to &&
                             currentDevice.limitTempMin >= rangeSlider_temp.from && currentDevice.limitTempMin <= rangeSlider_temp.to)) {
                            currentDevice.limitTempMin = first.value.toFixed(0)
                        }
                    }
                }
                second.onMoved: {
                    if (currentDevice) {
                        if ((second.value > rangeSlider_temp.from && second.value < rangeSlider_temp.to) ||
                            (second.value >= rangeSlider_temp.from && second.value <= rangeSlider_temp.to &&
                             currentDevice.limitTempMax >= rangeSlider_temp.from && currentDevice.limitTempMax <= rangeSlider_temp.to)) {
                            currentDevice.limitTempMax = second.value.toFixed(0)
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
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 8

                color: Theme.colorText
                source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
            }
            Text {
                anchors.left: imageLumi.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageLumi.verticalCenter
                anchors.verticalCenterOffset: 1

                text: qsTr("Luminosity")
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_lumi
                height: 20
                anchors.top: imageLumi.bottom
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                unit: "k"
                kshort: true
                from: 0
                to: outsideMode ? 100000 : 10000
                stepSize: outsideMode ? 5000 : 1000

                first.onMoved: {
                    if (currentDevice) {
                        if (first.value < rangeSlider_lumi.to ||
                            (first.value <= rangeSlider_lumi.to && currentDevice.limitLuxMin <= rangeSlider_lumi.to)) {
                            currentDevice.limitLuxMin = first.value.toFixed(0)
                        }
                    }
                }
                second.onMoved: {
                    if (currentDevice) {
                        if (second.value < rangeSlider_lumi.to ||
                            (second.value <= rangeSlider_lumi.to && currentDevice.limitLuxMax <= rangeSlider_lumi.to)) {
                            currentDevice.limitLuxMax = second.value.toFixed(0)
                        }
                    }
                }

                Row {
                    id: lumiScale
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 24

                    spacing: 2

                    Rectangle {
                        id: lux_1
                        height: 16
                        width: (lumiScale.width - 4) * 0.1 // 0 to 1k
                        visible: !outsideMode
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
                        height: 16
                        width: (lumiScale.width - 8) * 0.2 // 1k to 3k
                        visible: !outsideMode
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
                        height: 16
                        width: (lumiScale.width - 16) * 0.5 // 3k to 8k
                        visible: !outsideMode
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
                        height: 16
                        width: (lumiScale.width - 0) * 0.2 // 8k+
                        visible: !outsideMode
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
                        height: 16
                        width: (lumiScale.width - 6) * 0.16 // 0-15k
                        visible: outsideMode
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
                        height: 16
                        width: (lumiScale.width - 6) * 0.84 // 15k+
                        visible: outsideMode
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
                anchors.leftMargin: 8

                rotation: 90
                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-tonality-24px.svg"
            }
            Text {
                anchors.left: imageCondu.right
                anchors.leftMargin: 8
                anchors.verticalCenter: imageCondu.verticalCenter
                anchors.verticalCenterOffset: 0

                text: qsTr("Fertility")
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContentSmall
                font.capitalization: Font.AllUppercase
            }

            RangeSliderValueSolid {
                id: rangeSlider_condu
                height: 20
                anchors.top: imageCondu.bottom
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 8

                colorBg: Theme.colorYellow
                colorFg: Theme.colorGreen
                from: 0
                to: 2000
                stepSize: 50
                first.onMoved: {
                    if (currentDevice) {
                        currentDevice.limitConduMin = first.value.toFixed(0)
                    }
                }
                second.onMoved: {
                    if (currentDevice) {
                        currentDevice.limitConduMax = second.value.toFixed(0)
                    }
                }
            }
        }
        Text {
            id: legendCondu
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 16

            visible: itemCondu.visible

            text: qsTr("Soil fertility value is an indication of the availability of nutrients in the soil. Use fertilizer (with moderation) to keep this value up.") +
                  qsTr("<br><b>Tip: </b>") + qsTr("Be sure to use the right soil composition for your plants.")
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
        }
    }
}
