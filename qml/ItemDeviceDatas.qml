/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.7
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

Item {
    id: deviceDatas
    width: 400
    height: 300

    function updateHeader() {
        if (myDevice) {
            // Sensor battery level
            if ((myDevice.deviceCapabilities & 1) == 1) {
                imageBattery.visible = true

                if (myDevice.deviceBattery > 95) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
                } else if (myDevice.deviceBattery > 90) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
                } else if (myDevice.deviceBattery > 70) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
                } else if (myDevice.deviceBattery > 60) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
                } else if (myDevice.deviceBattery > 40) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
                } else if (myDevice.deviceBattery > 30) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
                } else if (myDevice.deviceBattery > 20) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
                } else if (myDevice.deviceBattery > 1) {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_alert-24px.svg";
                } else {
                    imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
                }
            } else {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
                imageBattery.visible = false
            }

            // Plant
            if ((myDevice.deviceCapabilities & 64) != 0) {
                itemPlant.visible = true

                if (myDevice.devicePlantName === "")
                    imageEditPlant.visible = true
                else
                    imageEditPlant.visible = false

                textInputPlant.text = myDevice.devicePlantName
            } else {
                itemPlant.visible = false
            }

            // Location
            if (myDevice.deviceLocationName === "")
                imageEditLocation.visible = true
            else
                imageEditLocation.visible = false

            textInputLocation.text = myDevice.deviceLocationName

            // Status
            updateStatusText()
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    property var deviceScreenCharts: pageLoader.item

    function updateStatusText() {
        if (typeof myDevice === "undefined") return
        //console.log("DeviceScreen // updateStatusText() >> " + myDevice)

        textStatus.color = "#000"
        textStatus.font.bold = false

        if (myDevice) {
            textStatus.text = ""
            if (myDevice.updating) {
                textStatus.text = qsTr("Updating... ")
            } else {
                if (!myDevice.available) {
                    textStatus.text = qsTr("Offline! ")
                    textStatus.color = Theme.colorRed
                    textStatus.font.bold = true
                }
            }

            if (myDevice.lastUpdateMin >= 0) {
                if (myDevice.lastUpdateMin <= 1)
                    textStatus.text += qsTr("Just updated!")
                else if (myDevice.available)
                    textStatus.text += qsTr("Updated") + " " + myDevice.lastUpdateStr + " " + qsTr("ago")
                else
                    textStatus.text += qsTr("Last update") + " " + myDevice.lastUpdateStr + " " + qsTr("ago")
            }
        }
    }

    function normalize(value, min, max) {
        if (value <= 0) return 0
        return Math.min(((value - min) / (max - min)), 1)
    }

    function loadDatas() {
        if (typeof myDevice === "undefined") return

        if (settingsManager.graph === 'bar')
            pageLoader.source = "DeviceScreenBarCharts.qml"
        else
            pageLoader.source = "DeviceScreenAioCharts.qml"
        deviceScreenCharts.loadGraph()

        updateDatas()
    }

    function updateDatas() {
        if (typeof myDevice === 'undefined' || !myDevice) return

        if (myDevice.deviceName === "MJ_HT_V1") {
            //
        } else {
            //
        }

        // Has datas? always display them
        if (myDevice.deviceTempC > 0) {

            humi.visible = (myDevice.deviceHygro > 0) ? true : false
            humi_indicator.text = myDevice.deviceHygro + "%"
            humi_data.width = normalize(myDevice.deviceHygro, 0, 50) * humi_bg.width

            temp_indicator.text = myDevice.getTempString()
            temp_data.width = normalize(myDevice.deviceTempC, 0, 40) * temp_bg.width

            lumi.visible = (myDevice.deviceLuminosity > 0) ? true : false
            lumi_indicator.text = myDevice.deviceLuminosity + " lumens"
            lumi_data.width = normalize(myDevice.deviceLuminosity, 0, 10000) * lumi_bg.width

            condu.visible = (myDevice.deviceConductivity > 0) ? true : false
            condu_indicator.text = myDevice.deviceConductivity + " µS/cm"
            condu_data.width = normalize(myDevice.deviceConductivity, 0, 750) * condu_bg.width
        }
    }

    onWidthChanged: {
        if (typeof myDevice === "undefined") return

        updateDatas()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Theme.colorMaterialLightGrey : Theme.colorMaterialDarkGrey
        height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 96 : 128

        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Column {
            id: plantPanel

            anchors.fill: parent
            anchors.topMargin: 8

            Text {
                id: textDeviceName
                anchors.left: parent.left
                anchors.leftMargin: 12

                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                font.pixelSize: 24
                text: myDevice.deviceName
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
                    color: Theme.colorIcons
                }
            }

            Item {
                id: itemPlant
                height: 28
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: labelPlant
                    width: 70
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Plant")
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }
                TextInput {
                    id: textInputPlant
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelPlant.right
                    anchors.leftMargin: 8
                    padding: 4

                    font.pixelSize: 16
                    onEditingFinished: {
                        if (text) {
                            imageEditPlant.visible = false
                        } else {
                            imageEditPlant.visible = true
                        }
                        myDevice.setPlantName(text)
                        focus = false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        //propagateComposedEvents: true

                        onEntered: { imageEditPlant.visible = true; }
                        onExited: {
                            if (textInputPlant.text) {
                                imageEditPlant.visible = false
                            } else {
                                imageEditPlant.visible = true
                            }
                        }

                        onClicked: {
                            imageEditPlant.visible = true;
                            mouse.accepted = false;
                        }
                        onPressed: {
                            imageEditPlant.visible = true;
                            mouse.accepted = false;
                        }
                        onReleased: mouse.accepted = false;
                        onDoubleClicked: mouse.accepted = false;
                        onPositionChanged: mouse.accepted = false;
                        onPressAndHold: mouse.accepted = false;
                    }

                    ImageSvg {
                        id: imageEditPlant
                        width: 24
                        height: 24
                        anchors.left: parent.right
                        anchors.leftMargin: 6
                        anchors.verticalCenterOffset: 0
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                        color: Theme.colorIcons
                    }
                }
            }

            Item {
                id: itemLocation
                height: 28
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: labelLocation
                    width: 70
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Location")
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }
                TextInput {
                    id: textInputLocation
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelLocation.right
                    anchors.leftMargin: 8
                    padding: 4

                    font.pixelSize: 16
                    onEditingFinished: {
                        if (text) {
                            imageEditLocation.visible = false
                        } else {
                            imageEditLocation.visible = true
                        }

                        myDevice.setLocationName(text)
                        focus = false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true

                        onEntered: { imageEditLocation.visible = true; }
                        onExited: {
                            if (textInputLocation.text) {
                                imageEditLocation.visible = false
                            } else {
                                imageEditLocation.visible = true
                            }
                        }

                        onClicked: {
                            imageEditLocation.visible = true;
                            mouse.accepted = false;
                        }
                        onPressed: {
                            imageEditLocation.visible = true;
                            mouse.accepted = false;
                        }
                        onReleased: mouse.accepted = false;
                        onDoubleClicked: mouse.accepted = false;
                        onPositionChanged: mouse.accepted = false;
                        onPressAndHold: mouse.accepted = false;
                    }

                    ImageSvg {
                        id: imageEditLocation
                        width: 24
                        height: 24
                        anchors.left: parent.right
                        anchors.leftMargin: 6
                        anchors.verticalCenterOffset: 0
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                        color: Theme.colorIcons
                    }
                }
            }

            Item {
                id: status
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelStatus
                    width: 70
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Status")
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }
                Text {
                    id: textStatus
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelStatus.right
                    anchors.leftMargin: 8

                    text: qsTr("Loading...")
                    padding: 4
                    font.pixelSize: 16
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        clip: true

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Column {
            id: column
            spacing: 0
            anchors.fill: parent

            Item { //////
                id: humi
                height: 38
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: humi_legend
                    width: 96
                    color: Theme.colorText
                    text: qsTr("Humidity")
                    horizontalAlignment: Text.AlignRight
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: humi_bg.verticalCenter
                    font.pixelSize: 14
                }

                Rectangle {
                    id: humi_bg
                    color: Theme.colorSeparators
                    height: 8
                    radius: 3
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.left: humi_legend.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    Rectangle {
                        id: humi_data
                        width: 150
                        color: Theme.colorBlue
                        radius: 3
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                    }

                    Text {
                        id: humi_indicator
                        x: {
                            if (humi_data.width < width/2) { // left
                                humi_indicator_triangle.anchors.horizontalCenterOffset = -width/2 + 4
                                return 4
                            } else if ((humi_bg.width - humi_data.width) < width/2) { // right
                                humi_indicator_triangle.anchors.horizontalCenterOffset = width/2 - 4
                                return humi_bg.width - width - 4
                            } else { //whatever
                                humi_indicator_triangle.anchors.horizontalCenterOffset = 0
                                return humi_data.width - width/2 - 4
                            }
                        }
                        y: -22
                        height: 15
                        color: "white"
                        text: qsTr("21%")
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.pixelSize: 12

                        Rectangle {
                            height: 18
                            color: Theme.colorBlue
                            radius: 1
                            anchors.left: parent.left
                            anchors.leftMargin: -4
                            anchors.right: parent.right
                            anchors.rightMargin: -4
                            anchors.verticalCenter: parent.verticalCenter
                            z: -1
                            Rectangle {
                                id: humi_indicator_triangle
                                width: 6
                                height: 6
                                radius: 1
                                rotation: 45
                                color: Theme.colorBlue
                                anchors.top: parent.bottom
                                anchors.topMargin: -3
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: 0
                            }
                        }
                    }
                }
            }

            Item { //////
                id: temp
                height: 38
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: temp_legend
                    width: 96
                    color: Theme.colorText
                    text: qsTr("Temperature")
                    horizontalAlignment: Text.AlignRight
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: temp_bg.verticalCenter
                    font.pixelSize: 14
                }

                Rectangle {
                    id: temp_bg
                    color: Theme.colorSeparators
                    height: 8
                    radius: 3
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.left: temp_legend.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    Rectangle {
                        id: temp_data
                        width: 150
                        color: Theme.colorGreen
                        radius: 3
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                    }

                    Text {
                        id: temp_indicator
                        x: {
                            if (temp_data.width < width/2) { // left
                                temp_indicator_triangle.anchors.horizontalCenterOffset = -width/2 + 4
                                return 4
                            } else if ((temp_bg.width - temp_data.width) < width/2) { // right
                                temp_indicator_triangle.anchors.horizontalCenterOffset = width/2 - 4
                                return temp_bg.width - width - 4
                            } else { //whatever
                                temp_indicator_triangle.anchors.horizontalCenterOffset = 0
                                return temp_data.width - width/2 - 4
                            }
                        }
                        y: -22
                        height: 15
                        color: "white"
                        text: qsTr("21%")
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.pixelSize: 12

                        Rectangle {
                            height: 18
                            color: Theme.colorGreen
                            radius: 1
                            anchors.left: parent.left
                            anchors.leftMargin: -4
                            anchors.right: parent.right
                            anchors.rightMargin: -4
                            anchors.verticalCenter: parent.verticalCenter
                            z: -1
                            Rectangle {
                                id: temp_indicator_triangle
                                width: 6
                                height: 6
                                radius: 1
                                rotation: 45
                                color: Theme.colorGreen
                                anchors.top: parent.bottom
                                anchors.topMargin: -3
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: 0
                            }
                        }
                    }
                }
            }

            Item { //////
                id: lumi
                height: 38
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: lumi_legend
                    width: 96
                    color: Theme.colorText
                    text: qsTr("Luminosity")
                    horizontalAlignment: Text.AlignRight
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: lumi_bg.verticalCenter
                    font.pixelSize: 14
                }

                Rectangle {
                    id: lumi_bg
                    color: Theme.colorSeparators
                    height: 8
                    radius: 3
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.left: lumi_legend.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    Rectangle {
                        id: lumi_data
                        width: 150
                        color: Theme.colorYellow
                        radius: 3
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                    }

                    Text {
                        id: lumi_indicator
                        x: {
                            if (lumi_data.width < width/2) { // left
                                lumi_indicator_triangle.anchors.horizontalCenterOffset = -width/2 + 4
                                return 4
                            } else if ((lumi_bg.width - lumi_data.width) < width/2) { // right
                                lumi_indicator_triangle.anchors.horizontalCenterOffset = width/2 - 4
                                return lumi_bg.width - width - 4
                            } else { //whatever
                                lumi_indicator_triangle.anchors.horizontalCenterOffset = 0
                                return lumi_data.width - width/2 - 4
                            }
                        }
                        y: -22
                        height: 15
                        color: "white"
                        text: qsTr("21%")
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.pixelSize: 12

                        Rectangle {
                            height: 18
                            color: Theme.colorYellow
                            radius: 1
                            anchors.left: parent.left
                            anchors.leftMargin: -4
                            anchors.right: parent.right
                            anchors.rightMargin: -4
                            anchors.verticalCenter: parent.verticalCenter
                            z: -1
                            Rectangle {
                                id: lumi_indicator_triangle
                                width: 6
                                height: 6
                                radius: 1
                                rotation: 45
                                color: Theme.colorYellow
                                anchors.top: parent.bottom
                                anchors.topMargin: -3
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: 0
                            }
                        }
                    }
                }
            }

            Item { //////
                id: condu
                height: 38
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: condu_legend
                    width: 96
                    color: Theme.colorText
                    text: qsTr("Conductivity")
                    horizontalAlignment: Text.AlignRight
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: condu_bg.verticalCenter
                    font.pixelSize: 14
                }

                Rectangle {
                    id: condu_bg
                    color: Theme.colorSeparators
                    height: 8
                    radius: 3
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.left: condu_legend.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    Rectangle {
                        id: condu_data
                        width: 150
                        color: Theme.colorRed
                        radius: 3
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                    }

                    Text {
                        id: condu_indicator
                        x: {
                            if (condu_data.width < width/2) { // left
                                condu_indicator_triangle.anchors.horizontalCenterOffset = -width/2 + 4
                                return 4
                            } else if ((lumi_bg.width - condu_data.width) < width/2) { // right
                                condu_indicator_triangle.anchors.horizontalCenterOffset = width/2 - 4
                                return lumi_bg.width - width - 4
                            } else { //whatever
                                condu_indicator_triangle.anchors.horizontalCenterOffset = 0
                                return condu_data.width - width/2 - 4
                            }
                        }
                        y: -22
                        height: 15
                        color: "white"
                        text: qsTr("21%")
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.pixelSize: 12

                        Rectangle {
                            height: 18
                            color: Theme.colorRed
                            radius: 1
                            anchors.left: parent.left
                            anchors.leftMargin: -4
                            anchors.right: parent.right
                            anchors.rightMargin: -4
                            anchors.verticalCenter: parent.verticalCenter
                            z: -1
                            Rectangle {
                                id: condu_indicator_triangle
                                width: 6
                                height: 6
                                radius: 1
                                rotation: 45
                                color: Theme.colorRed
                                anchors.top: parent.bottom
                                anchors.topMargin: -3
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: 0
                            }
                        }
                    }
                }
            }

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Loader {
                id: pageLoader
                height: 256
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }
}
