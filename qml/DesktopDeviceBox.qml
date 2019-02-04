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

Rectangle {
    id: deviceBoxMobile
    width: parent.width
    height: 96
    color: "#ffffff"
    radius: 0

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
            textPlant.text = qsTr("BLE temperature sensor")
            textLocation.text = boxDevice.deviceLocationName
        }

        rectangleSensors.visible = false
        rectangleHygroTemp.visible = false

        if (boxDevice.isUpdating()) {
            refreshAnimation.running = true;
            imageStatus.visible = true;
            imageStatus.source = "qrc:/assets/ble.svg";
        } else {
            refreshAnimation.running = false;

            if (boxDevice.isAvailable()) {
                imageStatus.visible = false;

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
                    bat_data.height = (boxDevice.deviceBattery / 100)*64
                }
            } else {
                imageStatus.visible = true;
                imageStatus.source = "qrc:/assets/ble_err.svg";
                imageStatus.opacity = 1;
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            curentlySelectedDevice = boxDevice
            deviceScreen.loadDevice()
        }
    }

    Rectangle {
        id: background
        height: 88
        color: "#f9f9f9"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: textPlant
        color: Theme.colorTitles
        text: boxDevice.deviceLocationName
        font.capitalization: Font.AllUppercase
        anchors.right: parent.right
        anchors.rightMargin: 12
        clip: true
        font.bold: false
        anchors.topMargin: 14
        anchors.top: parent.top
        anchors.left: dataArea.right
        anchors.leftMargin: 12

        font.pixelSize: 24
        verticalAlignment: Text.AlignBottom
    }

    Text {
        id: textLocation
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        text: boxDevice.deviceAddress
        anchors.right: parent.right
        anchors.rightMargin: 12
        clip: true
        font.weight: Font.Thin
        font.capitalization: Font.AllUppercase
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        anchors.left: dataArea.right
        anchors.leftMargin: 12
    }

    Rectangle {
        id: dataArea
        width: 83
        height: 88
        color: "#00000000"
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

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

        Rectangle {
            id: rectangleSensors
            color: "#00000000"
            anchors.fill: parent
            visible: true

            Rectangle {
                id: hygro_bg
                width: 12
                color: "#e2e6e5"
                radius: 6
                clip: true

                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Rectangle {
                    id: hygro_data
                    height: 50
                    color: "#289de1"
                    radius: 5
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    border.width: 0
                }
            }

            Rectangle {
                id: temp_bg
                width: 12
                color: "#e2e6e5"
                radius: 6
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: hygro_bg.right
                anchors.leftMargin: 6

                Rectangle {
                    id: temp_data
                    height: 20
                    color: "#1abc9c"
                    radius: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    border.width: 0
                    visible: true
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
            }

            Rectangle {
                id: lumi_bg
                width: 12
                color: "#e2e6e5"
                radius: 6
                border.width: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: temp_bg.right
                anchors.leftMargin: 6

                Rectangle {
                    id: lumi_data
                    height: 10
                    color: "#ffba5a"
                    radius: 6
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    border.width: 0
                }
            }
            Rectangle {
                id: cond_bg
                width: 12
                color: "#e2e6e5"
                radius: 6
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: lumi_bg.right
                anchors.leftMargin: 6

                Rectangle {
                    id: cond_data
                    height: 16
                    color: "#ff7657"
                    radius: 6
                    border.width: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
            }
            Rectangle {
                id: bat_bg
                width: 12
                color: "#e2e6e5"
                radius: 6
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: cond_bg.right
                anchors.leftMargin: 6

                Rectangle {
                    id: bat_data
                    y: 80
                    height: 0
                    color: "#555151"
                    radius: 6
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    border.width: 0
                }
            }
        }

        Rectangle {
            id: rectangleHygroTemp
            color: "#f3f3f3"
            anchors.fill: parent

            Text {
                id: textTemp
                y: 18
                color: "#393939"
                text: qsTr("25.0°")
                font.wordSpacing: -1.2
                font.letterSpacing: -1.4
                renderType: Text.NativeRendering
                font.weight: Font.Normal
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 24
            }

            Text {
                id: textHygro
                color: "#393939"
                text: qsTr("55%")
                anchors.top: textTemp.bottom
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
            }
        }
    }
}
