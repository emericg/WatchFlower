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
        if (typeof myDevice === "undefined") return

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

    property var aioLineCharts: null

    function updateStatusText() {
        if (typeof myDevice === "undefined") return
        //console.log("DeviceScreen // updateStatusText() >> " + myDevice)

        textStatus.color = "black"
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
            pageLoader.source = "ItemAioBarCharts.qml"
        else
            pageLoader.source = "ItemAioLineCharts.qml"

        aioLineCharts = pageLoader.item
        aioLineCharts.loadGraph()

        updateHeader()
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
        if (myDevice.lastUpdateMin >= 0 && myDevice.lastUpdateMin <= 720) {
            humi.visible = (myDevice.deviceConductivity > 0 || myDevice.deviceHygro > 0)
            lumi.visible = (myDevice.deviceLuminosity >= 0)
            condu.visible = (myDevice.deviceConductivity > 0 || myDevice.deviceHygro > 0)
        } else {
            humi.visible = true
            temp.visible = true
            lumi.visible = ((myDevice.deviceCapabilities & 8) != 0)
            condu.visible = true
        }

        //
        aioLineCharts.updateGraph()
    }

    onWidthChanged: {
        if (typeof myDevice === "undefined") return

        updateDatas()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Theme.colorMaterialLightGrey : Theme.colorMaterialDarkGrey
        height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 96 : 132

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Column {
            id: plantPanel
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.left: parent.left

            Text {
                id: textDeviceName
                height: 36
                anchors.left: parent.left
                anchors.leftMargin: 12

                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                font.pixelSize: 24
                text: myDevice.deviceName
                verticalAlignment: Text.AlignVCenter
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
                    width: 72
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
                    color: "black"
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
                        width: 20
                        height: 20
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
                    width: 72
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
                    color: "black"
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
                        width: 20
                        height: 20
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
                    width: 72
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
                    color: "black"
                    padding: 4
                    font.pixelSize: 16
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: element // ScrollView {
        clip: true

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        //Item { anchors.fill: parent } // HACK // so the scrollview content resizes?

        ImageSvg {
            id: imageOffline
            width: 96
            height: 96
            anchors.top: element.top
            anchors.horizontalCenter: element.horizontalCenter

            visible: !(myDevice.available || (myDevice.lastUpdateMin >= 0 && myDevice.lastUpdateMin <= 720))

            source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcons
        }

        Column {
            id: datasColumns
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            visible: (myDevice.available || (myDevice.lastUpdateMin >= 0 && myDevice.lastUpdateMin <= 720))

            ItemDataBar {
                id: humi
                legend: qsTr("Hygrometry")
                unit: "%"
                color: Theme.colorBlue
                value: myDevice.deviceHygro
                valueMin: 0
                valueMax: 50
                limitMin: myDevice.limitHygroMin
                limitMax: myDevice.limitHygroMax
            }
            ItemDataBar {
                id: temp
                legend: qsTr("Temperature")
                unit: "°" + settingsManager.tempunit
                color: Theme.colorGreen
                value: myDevice.deviceTempC
                valueMin: 0
                valueMax: 40
                limitMin: myDevice.limitTempMin
                limitMax: myDevice.limitTempMax
            }
            ItemDataBar {
                id: lumi
                legend: qsTr("Luminosity")
                unit: " lumens"
                color: Theme.colorYellow
                value: myDevice.deviceLuminosity
                valueMin: 0
                valueMax: 10000
                limitMin: myDevice.limitLumiMin
                limitMax: myDevice.limitLumiMax
            }
            ItemDataBar {
                id: condu
                legend: qsTr("Conductivity")
                unit: " µS/cm"
                color: Theme.colorRed
                value: myDevice.deviceConductivity
                valueMin: 0
                valueMax: 750
                limitMin: myDevice.limitConduMin
                limitMax: myDevice.limitConduMax
            }
        }

        Loader {
            id: pageLoader
            anchors.top: datasColumns.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: myDevice.hasDatas()
        }
    }
}
