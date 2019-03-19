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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.7

import QtGraphicalEffects 1.0
import com.watchflower.theme 1.0

Item {
    id: deviceBoxMobile
    width: parent.width
    height: 80

    property var boxDevice

    Connections {
        target: boxDevice
        onStatusUpdated: updateBoxDatas()
        onLimitsUpdated: updateBoxDatas()
        onDatasUpdated: updateBoxDatas()
    }

    Component.onCompleted: updateBoxDatas()

    function normalize(value, min, max) {
        if (value <= 0) return 0
        return Math.min(((value - min) / (max - min)), 1)
    }

    function updateBoxDatas() {
        if (boxDevice.devicePlantName !== "") {
            textPlant.text = boxDevice.devicePlantName
            textLocation.text = boxDevice.deviceLocationName
        }
        if (boxDevice.deviceName === "MJ_HT_V1") {
            textPlant.text = qsTr("Thermometer")
            textLocation.text = boxDevice.deviceLocationName
        }

        rectangleSensors.visible = false
        rectangleHygroTemp.visible = false
        water.visible = false
        ble.visible = false

        // water me notif
        if (boxDevice.deviceHygro > 0) {
            if (boxDevice.deviceHygro < boxDevice.limitHygroMin) {
                water.visible = true
            }
        }

        // Update notif
        if (boxDevice.isUpdating()) {
            if (boxDevice.deviceTempC > 0) {
                // if we have data cached, used the little indicator
                ble.visible = true
                ble.source = "qrc:/assets/icons_material/baseline-bluetooth_searching-24px.svg"
                refreshAnimation2.running = true;
            } else {
                // otherwise, fullsize
                imageStatus.visible = true;
                imageStatus.source = "qrc:/assets/ble.svg";
                refreshAnimation.running = true;
            }
        } else {
            refreshAnimation.running = false;
            refreshAnimation2.running = false;

            if (boxDevice.isAvailable()) {
                imageStatus.visible = false;
                ble.visible = false
            } else {
                if (boxDevice.deviceTempC > 0) {
                    // if we have data cached, used the little indicator
                    imageStatus.visible = false;
                    ble.visible = true
                    ble.source = "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                } else {
                    // otherwise big one
                    ble.visible = false
                    imageStatus.visible = true;
                    imageStatus.source = "qrc:/assets/ble_err.svg";
                    imageStatus.opacity = 1;
                }
            }
        }

        // Has datas? always display them
        if (boxDevice.deviceTempC > 0) {
            if (boxDevice.deviceName === "MJ_HT_V1") {
                rectangleHygroTemp.visible = true
                textTemp.text = boxDevice.deviceTempC.toFixed(1) + "°"
                textHygro.text = boxDevice.deviceHygro + "%"
            } else {
                rectangleSensors.visible = true
                hygro_data.height = normalize(boxDevice.deviceHygro, boxDevice.limitHygroMin, boxDevice.limitHygroMax) * 64
                temp_data.height = normalize(boxDevice.deviceTempC, boxDevice.limitTempMin, boxDevice.limitTempMax) * 64
                lumi_data.height = normalize(boxDevice.deviceLuminosity, boxDevice.limitLumiMin, boxDevice.limitLumiMax) * 64
                cond_data.height = normalize(boxDevice.deviceConductivity, boxDevice.limitConduMin, boxDevice.limitConduMax) * 64
                bat_data.height = (boxDevice.deviceBattery / 100) * 64
            }
        }
    }

    MouseArea {
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.fill: parent

        onClicked: {
            curentlySelectedDevice = boxDevice
            content.state = "DeviceDetails"
        }

        Image {
            id: imageForward
            width: 32
            height: 32
            z: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 4

            source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
            sourceSize: Qt.size(width, height)
        }
    }

    Rectangle {
        id: background
        height: 64
        color: "#99e6e6e6"
        visible: false
        anchors.right: parent.right
        anchors.rightMargin: 44
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: textLocation
        font.pixelSize: 16
        text: boxDevice.deviceAddress
        anchors.right: dataArea.left
        anchors.rightMargin: 8
        clip: true
        font.weight: Font.Thin
        font.capitalization: Font.AllUppercase
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 8
    }

    Text {
        id: textPlant
        color: "#544545"
        text: boxDevice.deviceLocationName
        font.capitalization: Font.AllUppercase
        anchors.right: dataArea.left
        anchors.rightMargin: 8
        clip: true
        font.bold: false
        anchors.topMargin: 16
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 8

        font.pixelSize: 22
    }

    Row {
        id: lilIcons
        width: 60
        height: 20
        layoutDirection: Qt.RightToLeft
        spacing: 8

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.right: dataArea.left
        anchors.rightMargin: 8

        Image {
            id: ble
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-bluetooth_searching-24px.svg"
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            SequentialAnimation on opacity {
                id: refreshAnimation2
                loops: Animation.Infinite
                running: false
                OpacityAnimator { from: 0; to: 1; duration: 600 }
                OpacityAnimator { from: 1; to: 0;  duration: 600 }
                onStopped: { ble.opacity = 1 }
            }
        }

        Image {
            id: water
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-opacity-24px.svg"
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit

            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: Theme.colorBlue
            }
        }
    }

    Rectangle {
        id: rectangle
        height: 1
        color: "#bfbfbf"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
    }

    Rectangle {
        id: dataArea
        width: 72
        height: 70
        color: "#00000000"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 40

        Image {
            id: imageStatus
            width: 32
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/ble.svg"
            sourceSize: Qt.size(width, height)
            visible: false

            SequentialAnimation on opacity {
                id: refreshAnimation
                loops: Animation.Infinite
                running: true
                OpacityAnimator { from: 0; to: 1; duration: 600 }
                OpacityAnimator { from: 1; to: 0;  duration: 600 }
            }
        }

        Item {
            id: rectangleSensors
            anchors.fill: parent
            visible: true

            Item {
                id: hygro_bg
                width: 8
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Rectangle {
                    id: bg1
                    anchors.fill: parent
                    color: Theme.colorBlue
                    opacity: 0.33
                    radius: 3
                }
                Rectangle {
                    id: hygro_data
                    height: 12
                    color: Theme.colorBlue
                    radius: 3
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
            }

            Item {
                id: temp_bg
                width: 8
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: hygro_bg.right
                anchors.leftMargin: 8

                Rectangle {
                    id: bg2
                    anchors.fill: parent
                    color: Theme.colorGreen
                    opacity: 0.33
                    radius: 3
                }
                Rectangle {
                    id: temp_data
                    height: 6
                    color: Theme.colorGreen
                    radius: 3
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    visible: true
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
            }

            Item {
                id: lumi_bg
                width: 8
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: temp_bg.right
                anchors.leftMargin: 8

                Rectangle {
                    id: bg3
                    anchors.fill: parent
                    color: Theme.colorYellow
                    opacity: 0.33
                    radius: 3
                }
                Rectangle {
                    id: lumi_data
                    height: 8
                    color: Theme.colorYellow
                    radius: 3
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    border.color: "#00000000"
                }
            }

            Item {
                id: cond_bg
                width: 8
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: lumi_bg.right
                anchors.leftMargin: 8

                Rectangle {
                    id: bg4
                    anchors.fill: parent
                    color: Theme.colorRed
                    opacity: 0.33
                    radius: 3
                }
                Rectangle {
                    id: cond_data
                    height: 10
                    color: Theme.colorRed
                    radius: 3
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
            }

            Item {
                id: bat_bg
                width: 8
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: cond_bg.right
                anchors.leftMargin: 8

                Rectangle {
                    id: bg5
                    anchors.fill: parent
                    color: Theme.colorGrey
                    opacity: 0.33
                    radius: 3
                }
                Rectangle {
                    id: bat_data
                    height: 6
                    color: Theme.colorGrey
                    radius: 3
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
            }
        }

        Item {
            id: rectangleHygroTemp
            anchors.fill: parent

            Text {
                id: textTemp
                x: 0
                y: 8
                height: 28
                color: "#393939"
                text: qsTr("25.0°")
                font.wordSpacing: -1.2
                font.letterSpacing: -1.4
                renderType: Text.NativeRendering
                font.weight: Font.Bold
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                font.family: "Tahoma"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 22
            }

            Text {
                id: textHygro
                x: 0
                y: 36
                height: 20
                color: "#393939"
                text: qsTr("55%")
                font.family: "Tahoma"
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18
            }
        }
    }
}
