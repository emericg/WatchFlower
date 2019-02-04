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
    height: 80
    radius: 0
    color: "#ddffffff"

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
            content.state = "DeviceDetails"
        }

        Image {
            id: imageForward
            width: 32
            height: 32
            z: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 6

            source: "qrc:/assets/menu_front.svg"
            sourceSize: Qt.size(width, height)
        }
    }

    Rectangle {
        id: background
        height: 64
        color: "#aaf3f3f3"
        anchors.right: parent.right
        anchors.rightMargin: 44
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
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

    Rectangle {
        id: dataArea
        width: 64
        height: 64
        color: "#f3f3f3"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 44

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
            x: 0
            y: 4
            width: 64
            height: 64
            color: "#f3f3f3"
            anchors.verticalCenter: parent.verticalCenter
            visible: true
            Rectangle {
                id: hygro_bg
                width: 12
                color: "#331389e8"
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
            }

            Rectangle {
                id: temp_bg
                width: 12
                color: "#335dc948"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: hygro_bg.right
                anchors.leftMargin: 1
            }

            Rectangle {
                id: lumi_bg
                width: 12
                color: "#33f8ef50"
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: temp_bg.right
                anchors.leftMargin: 1
            }
            Rectangle {
                id: cond_bg
                width: 12
                color: "#33fc7203"
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: lumi_bg.right
                anchors.leftMargin: 1
            }
            Rectangle {
                id: bat_bg
                x: 65
                width: 12
                color: "#33797979"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: cond_bg.right
                anchors.leftMargin: 1
            }

            Rectangle {
                id: hygro_data
                width: 12
                height: 0
                color: "#1389e8"
                anchors.bottomMargin: 0
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 0
            }
            Rectangle {
                id: temp_data
                width: 12
                height: 0
                color: "#5dc948"
                visible: true
                anchors.bottomMargin: 0
                anchors.bottom: parent.bottom
                anchors.left: hygro_bg.right
                anchors.leftMargin: 1
            }
            Rectangle {
                id: lumi_data
                width: 12
                height: 0
                color: "#f8ef50"
                anchors.bottomMargin: 0
                anchors.bottom: parent.bottom
                anchors.left: temp_bg.right
                anchors.leftMargin: 1
                border.color: "#00000000"
            }
            Rectangle {
                id: cond_data
                width: 12
                height: 0
                color: "#fc7203"
                anchors.bottomMargin: 0
                anchors.bottom: parent.bottom
                anchors.left: lumi_bg.right
                anchors.leftMargin: 1
            }
            Rectangle {
                id: bat_data
                width: 12
                height: 0
                color: "#797979"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: cond_bg.right
                anchors.leftMargin: 1
            }
        }

        Rectangle {
            id: rectangleHygroTemp
            color: "#f3f3f3"
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
