/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: deviceScreenLimits

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("DeviceScreenLimits // updateHeader() >> " + currentDevice)

        // Sensor battery level
        if (currentDevice.hasBatteryLevel()) {
            imageBattery.visible = true
            imageBattery.color = Theme.colorIcon

            if (currentDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (currentDevice.deviceBattery > 85) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (currentDevice.deviceBattery > 75) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (currentDevice.deviceBattery > 55) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (currentDevice.deviceBattery > 45) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (currentDevice.deviceBattery > 25) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (currentDevice.deviceBattery > 15) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (currentDevice.deviceBattery > 1) {
                if (currentDevice.deviceBattery <= 10) imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                if (currentDevice.deviceBattery === 0) imageBattery.color = Theme.colorRed
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }

        // Sensor address
        if (currentDevice.deviceAddress.charAt(0) !== '{')
            textAddr.text = "[" + currentDevice.deviceAddress + "]"

        // Firmware
        textFirmware.text = currentDevice.deviceFirmware
        if (isDesktop && !currentDevice.deviceFirmwareUpToDate) {
            imageFwUpdate.visible = true
            textFwUpdate.visible = true
        } else {
            imageFwUpdate.visible = false
            textFwUpdate.visible = false
        }
    }

    function updateLimits() {
        if (typeof currentDevice === "undefined" || !currentDevice) return

        rangeSlider_hygro.setValues(currentDevice.limitHygroMin, currentDevice.limitHygroMax)
        rangeSlider_temp.setValues(currentDevice.limitTempMin, currentDevice.limitTempMax)
        rangeSlider_condu.setValues(currentDevice.limitConduMin, currentDevice.limitConduMax)
        rangeSlider_lumi.setValues(currentDevice.limitLumiMin, currentDevice.limitLumiMax)
    }

    function updateLimitsVisibility() {
        if (typeof currentDevice === "undefined" || !currentDevice) return

        itemTemp.visible = currentDevice.hasTemperatureSensor()
        itemHygro.visible = currentDevice.hasHumiditySensor() || currentDevice.hasSoilMoistureSensor()
        itemLumi.visible = currentDevice.hasLuminositySensor()
        itemCondu.visible = currentDevice.hasSoilConductivitySensor()
    }

    property var outsideMode: (currentDevice && currentDevice.limitLumiMax > 10000)

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: Theme.colorForeground
        height: devicePanel.height + 12
        z: 5

        visible: !(isPhone && screenOrientation === Qt.LandscapeOrientation)

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        // prevent clicks into this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        Column {
            id: devicePanel
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 2
            spacing: 2

            Text {
                id: textDeviceName
                height: 36
                anchors.left: parent.left
                anchors.leftMargin: 12

                visible: isDesktop

                text: currentDevice.deviceName
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeTitle
                font.capitalization: Font.AllUppercase
                color: Theme.colorText

                ImageSvg {
                    id: imageBattery
                    width: 32
                    height: 32
                    rotation: 90
                    anchors.verticalCenter: textDeviceName.verticalCenter
                    anchors.left: textDeviceName.right
                    anchors.leftMargin: 16

                    source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                    color: Theme.colorIcon
                }
            }

            Item {
                id: itemAddress
                height: 28
                width: parent.width

                Text {
                    id: labelAddress
                    width: isPhone ? 80 : 96
                    anchors.leftMargin: 12
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Address")
                    font.bold: true
                    font.pixelSize: 12
                    font.capitalization: Font.AllUppercase
                    color: Theme.colorSubText
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    id: textAddr
                    anchors.left: labelAddress.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    text: currentDevice.deviceAddress
                    font.pixelSize: 17
                    color: Theme.colorHighContrast
                }
            }

            Item {
                id: itemFirmware
                height: 28
                width: parent.width

                Text {
                    id: labelFirmware
                    width: isPhone ? 80 : 96
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Firmware")
                    font.bold: true
                    font.pixelSize: 12
                    font.capitalization: Font.AllUppercase
                    color: Theme.colorSubText
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    id: textFirmware
                    anchors.left: labelFirmware.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    text: "1"
                    font.pixelSize: 17
                    color: Theme.colorHighContrast
                }

                ImageSvg {
                    id: imageFwUpdate
                    width: 24
                    height: 24
                    anchors.left: textFirmware.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-new_releases-24px.svg"
                    color: Theme.colorIcon

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: textFwUpdate.text = qsTr("Use official app to upgrade")
                        onExited: textFwUpdate.text = qsTr("Update available!")
                    }
                }
                Text {
                    id: textFwUpdate
                    anchors.left: imageFwUpdate.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Update available!")
                    font.pixelSize: 14
                    color: Theme.colorHighContrast
                }
            }

            Item {
                id: battery
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: textBattery
                    anchors.left: labelBattery.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    text: currentDevice.deviceBattery + "%"
                    font.pixelSize: 17
                    color: Theme.colorHighContrast
                }

                Text {
                    id: labelBattery
                    width: isPhone ? 80 : 96
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Battery")
                    font.bold: true
                    font.pixelSize: 12
                    font.capitalization: Font.AllUppercase
                    color: Theme.colorSubText
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: rectangleHeader.visible ? rectangleHeader.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            anchors.fill: parent

            topPadding: 12
            bottomPadding: 16
            spacing: 12

            ////////
/*
            Rectangle {
                id: itemDevice
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                height: 280
                color: Theme.colorForeground

                ImageSvg {
                    width: 80
                    height: 80
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    color: Theme.colorSubText
                    source: "qrc:/assets/devices/flowercare.svg"
                }

                Column {
                    id: itemDeviceRow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 0

                    Row {
                        height: 32
                        spacing: 12

                        Text {
                            text: currentDevice.deviceName
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontSizeTitle
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorText
                        }

                        ImageSvg {
                            id: imageBattery
                            width: 32; height: 32;
                            rotation: 90
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                            color: Theme.colorIcon
                        }
                    }

                    Row {
                        height: 24
                        spacing: 12

                        Text {
                            width: isPhone ? 80 : 96
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Address")
                            font.bold: true
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            id: textAddr
                            anchors.verticalCenter: parent.verticalCenter

                            text: "[" + currentDevice.deviceAddress + "]"
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }
                    }

                    Row {
                        height: 24
                        spacing: 12

                        Text {
                            width: isPhone ? 80 : 96
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Firmware")
                            font.bold: true
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            id: textFirmware
                            anchors.verticalCenter: parent.verticalCenter

                            text: currentDevice.deviceFirmware
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }

                        ImageSvg {
                            id: imageFwUpdate
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-new_releases-24px.svg"
                            color: Theme.colorIcon

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: textFwUpdate.text = qsTr("Use official app to upgrade")
                                onExited: textFwUpdate.text = qsTr("Update available!")
                            }
                        }
                        Text {
                            id: textFwUpdate
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Update available!")
                            font.pixelSize: 14
                            color: Theme.colorHighContrast
                        }
                    }

                    Row {
                        height: 24
                        spacing: 12

                        Text {
                            width: isPhone ? 80 : 96
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Battery")
                            font.bold: true
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: currentDevice.deviceBattery + "%"
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }
                    }

                    Item { width: 8; height: 8; }

                    Grid {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 12
                        columns: 2
                        rows: 3

                        Row {
                            spacing: 12
                            visible: currentDevice.hasTemperatureSensor()

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "Temperature"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "-15 → 50°C ±0.5°C"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasSoilMoistureSensor()

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "Soil moisture"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "0 → 100% ±1%"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasLuminositySensor()

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "Luminosity"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "0 → 100k lux ±100lux"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasSoilConductivitySensor()

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                rotation: 90
                                source: "qrc:/assets/icons_material/baseline-tonality-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "Soil fertility"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "0 → 100 uc/cm ±1%"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasLED()

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "LED blink"
                                font.pixelSize: 12
                                color: Theme.colorText
                            }
                        }
                        Row {
                            spacing: 12
                            visible: currentDevice.hasHistory()

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Data history"
                                font.pixelSize: 12
                                color: Theme.colorText
                            }
                        }
                    }
                }
            }
*/
            ////////

            Row {
                id: itemInOut
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                spacing: 12

                Rectangle {
                    id: rectangleInside
                    width: parent.width/2 - parent.spacing/2
                    height: isDesktop ? 112 : 96
                    anchors.bottom: parent.bottom

                    // temp: 12 - 32
                    // lumi: 0 - 8k

                    color: Theme.colorForeground
                    opacity: outsideMode ? 0.5 : 1
                    Behavior on opacity { OpacityAnimator { duration: 133 } }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            outsideMode = false
                            rangeSlider_temp.setValues(currentDevice.limitTempMin, currentDevice.limitTempMax)
                            rangeSlider_lumi.setValues(currentDevice.limitLumiMin, currentDevice.limitLumiMax)
                        }
                    }

                    Column {
                        anchors.centerIn: parent

                        ImageSvg {
                            id: insideImage
                            width: 48; height: 48;
                            color: Theme.colorText
                            source: "qrc:/assets/icons_material/inside-24px.svg"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("inside")
                            color: Theme.colorText
                            font.pixelSize: 14
                        }
                    }
                }

                Rectangle {
                    id: rectangleOutside
                    width: parent.width/2 - parent.spacing/2
                    height: isDesktop ? 112 : 96
                    anchors.bottom: parent.bottom

                    // temp: 0 - 50
                    // lumi: 0 - 100k

                    color: Theme.colorForeground
                    opacity: outsideMode ? 1 : 0.5
                    Behavior on opacity { OpacityAnimator { duration: 133 } }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            outsideMode = true
                            rangeSlider_temp.setValues(currentDevice.limitTempMin, currentDevice.limitTempMax)
                            rangeSlider_lumi.setValues(currentDevice.limitLumiMin, currentDevice.limitLumiMax)
                        }
                    }

                    Column {
                        anchors.centerIn: parent

                        ImageSvg {
                            id: outsideImage
                            width: 48; height: 48;
                            source: "qrc:/assets/icons_material/outside-24px.svg"
                            color: Theme.colorText
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("outside")
                            color: Theme.colorText
                            font.pixelSize: 14
                        }
                    }
                }
            }

            ////////

            Item {
                id: itemHygro
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
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

                    text: currentDevice.hasSoilMoistureSensor() ? qsTr("Moisture") : qsTr("Humidity")
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: 14
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueFilled {
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
                    first.onValueChanged: if (currentDevice) currentDevice.limitHygroMin = first.value.toFixed(0);
                    second.onValueChanged: if (currentDevice) currentDevice.limitHygroMax = second.value.toFixed(0);
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
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: itemTemp
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                ImageSvg {
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
                    font.pixelSize: 14
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueFilled {
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

                    first.onValueChanged: {
                        if (currentDevice) {
                            if ((first.value > rangeSlider_temp.from && first.value < rangeSlider_temp.to) ||
                                (first.value >= rangeSlider_temp.from && first.value <= rangeSlider_temp.to &&
                                 currentDevice.limitTempMin >= rangeSlider_temp.from && currentDevice.limitTempMin <= rangeSlider_temp.to)) {
                                currentDevice.limitTempMin = first.value.toFixed(0)
                            }
                        }
                    }
                    second.onValueChanged: {
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
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: itemLumi
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
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
                    font.pixelSize: 14
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueFilled {
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

                    first.onValueChanged: {
                        if (currentDevice) {
                            if (first.value < rangeSlider_lumi.to ||
                                (first.value <= rangeSlider_lumi.to && currentDevice.limitLumiMin <= rangeSlider_lumi.to)) {
                                currentDevice.limitLumiMin = first.value.toFixed(0)
                            }
                        }
                    }
                    second.onValueChanged: {
                        if (currentDevice) {
                            if (second.value < rangeSlider_lumi.to ||
                                (second.value <= rangeSlider_lumi.to && currentDevice.limitLumiMax <= rangeSlider_lumi.to)) {
                                currentDevice.limitLumiMax = second.value.toFixed(0)
                            }
                        }
                    }

                    Row {
                        id: sections
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
                            width: (sections.width - 4) * 0.1 // 0 to 1k
                            visible: !outsideMode
                            color: Theme.colorGrey
                            clip: true
                            Text {
                                text: qsTr("low")
                                font.pixelSize: 12; color: "white";
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        Rectangle {
                            id: lux_2
                            height: 16
                            width: (sections.width - 8) * 0.2 // 1k to 3k
                            visible: !outsideMode
                            color: "grey"
                            clip: true
                            Text {
                                text: qsTr("indirect")
                                font.pixelSize: 12; color: "white";
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        Rectangle {
                            id: lux_3
                            height: 16
                            width: (sections.width - 16) * 0.5 // 3k to 8k
                            visible: !outsideMode
                            color: Theme.colorYellow
                            clip: true
                            Text {
                                text: qsTr("direct light (indoor)")
                                font.pixelSize: 12; color: "white";
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        Rectangle {
                            id: lux_4
                            height: 16
                            width: (sections.width - 0) * 0.2 // 8k+
                            visible: !outsideMode
                            color: "orange"
                            clip: true
                            Text {
                                text: qsTr("sunlight")
                                font.pixelSize: 12; color: "white";
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Rectangle {
                            id: lux_5
                            height: 16
                            width: (sections.width - 6) * 0.16 // 0-15k
                            visible: outsideMode
                            color: "grey"
                            clip: true
                            Text {
                                text: qsTr("indirect")
                                font.pixelSize: 12; color: "white";
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        Rectangle {
                            id: lux_6
                            height: 16
                            width: (sections.width - 6) * 0.84 // 15k+
                            visible: outsideMode
                            color: Theme.colorYellow
                            clip: true
                            Text {
                                text: qsTr("sunlight")
                                font.pixelSize: 12; color: "white";
                                anchors.horizontalCenter: parent.horizontalCenter
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
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: itemCondu
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
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
                    font.pixelSize: 14
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueFilled {
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
                    first.onValueChanged: if (currentDevice) currentDevice.limitConduMin = first.value.toFixed(0);
                    second.onValueChanged: if (currentDevice) currentDevice.limitConduMax = second.value.toFixed(0);
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
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }
        }
    }
}
