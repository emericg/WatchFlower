/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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
    height: 80
    radius: 2
    color: "#ddffffff"

    property var myDevice
    width: parent.width

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onClicked: {
            pageLoader.setSource("DeviceScreen.qml",
                                 { myDevice: myDevice });
        }

        Image {
            id: imageForward
            x: 320
            y: 32
            width: 32
            height: 32
            z: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            source: "qrc:/assets/menu_front.svg"
        }
    }

    Rectangle {
        id: background
        y: -78
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
        y: 8
        height: 24
        color: "#454B54"
        text: myDevice.deviceCustomName
        font.bold: false
        anchors.topMargin: 18
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 12

        font.pixelSize: 22
        verticalAlignment: Text.AlignBottom
    }

    Connections {
        target: myDevice
        onStatusUpdated: updateBoxDatas()
    }

    Component.onCompleted: updateBoxDatas()

    function normalize(value, min, max) {
        if (value <= 0) return 0
        return Math.min(((value - min) / (max - min)), 1)
    }

    function updateBoxDatas() {
        if (myDevice.devicePlantName !== "") {
            textPlant.text = myDevice.devicePlantName;
            textLocation.text = myDevice.deviceCustomName
        }

        if (myDevice.deviceName === "MJ_HT_V1") {
            if (myDevice.deviceCustomName !== "MJ_HT_V1") {
                textPlant.text = myDevice.devicePlantName;
            } else {
                textPlant.text = qsTr("Temp & hygro sensor");
            }
            textLocation.text = myDevice.deviceName;
            imageDevice.source = "qrc:/assets/devices/hygrotemp.svg";
        } else if (myDevice.deviceName === "ropot") {
            imageDevice.source = "qrc:/assets/devices/ropot.svg";
        } else {
            imageDevice.source = "qrc:/assets/devices/flowercare.svg";
        }

        rectangleSensors.visible = false
        rectangleHygroTemp.visible = false

        if (myDevice.isUpdating()) {
            refreshAnimation.running = true;
            imageStatus.visible = true;
            imageStatus.source = "qrc:/assets/ble.svg";
        } else {
            refreshAnimation.running = false;

            if (myDevice.isAvailable()) {
                imageStatus.visible = false;

                if (myDevice.deviceName === "MJ_HT_V1") {
                    rectangleHygroTemp.visible = true
                    textTemp.text = myDevice.deviceTempC.toFixed(1) + "°"
                    textHygro.text = myDevice.deviceHygro + "%"
                } else {
                    rectangleSensors.visible = true
                    hygro_data.height = normalize(myDevice.deviceHygro, myDevice.limitHygroMin, myDevice.limitHygroMax) * 64
                    temp_data.height = normalize(myDevice.deviceTempC, myDevice.limitTempMin, myDevice.limitTempMax) * 64
                    lumi_data.height = normalize(myDevice.deviceLuminosity, myDevice.limitLumiMin, myDevice.limitLumiMax) * 64
                    cond_data.height = normalize(myDevice.deviceConductivity, myDevice.limitConduMin, myDevice.limitConduMax) * 64
                    bat_data.height = (myDevice.deviceBattery / 100)*64
                }
            } else {
                imageStatus.visible = true;
                imageStatus.source = "qrc:/assets/ble_err.svg";
                imageStatus.opacity = 1;
            }
        }
    }

    Text {
        id: textLocation
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        text: myDevice.deviceAddress
        font.weight: Font.Thin
        font.capitalization: Font.AllUppercase
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 12
    }

    Rectangle {
        id: dataArea
        x: 0
        y: 80
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
            visible: false

            SequentialAnimation on opacity {
                id: refreshAnimation
                loops: Animation.Infinite
                running: true
                OpacityAnimator { from: 0; to: 1; duration: 600 }
                OpacityAnimator { from: 1; to: 0;  duration: 600 }
            }
        }

        Image {
            id: imageDevice
            visible: false
            anchors.fill: parent
            opacity: 0.5
        }
        /*
        Rectangle {
            id: rectangleDatas
            color: "#ffffff"
            anchors.rightMargin: -134
            anchors.bottomMargin: 94
            anchors.leftMargin: 134
            anchors.topMargin: -93
            anchors.fill: parent

            Rectangle {
                id: hygro_bg
                y: 0
                width: 14
                height: 64
                color: "#551389e8"
                anchors.left: parent.left
                anchors.leftMargin: 1
            }
            Rectangle {
                id: temp_bg
                y: 0
                width: 14
                height: 64
                color: "#555dc948"
                anchors.left: hygro_bg.right
                anchors.leftMargin: 2
            }
            Rectangle {
                id: lumi_bg
                y: 0
                width: 14
                height: 64
                color: "#55f8ef50"
                anchors.left: temp_bg.right
                anchors.leftMargin: 2
            }
            Rectangle {
                id: cond_bg
                y: 0
                width: 14
                height: 64
                color: "#55fc7203"
                anchors.left: lumi_bg.right
                anchors.leftMargin: 2
            }

            Rectangle {
                id: hygro_data
                width: 14
                height: 0
                color: "#1389e8"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 1
            }Rectangle {
                id: temp_data
                width: 14
                height: 0
                color: "#5dc948"
                visible: true
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: hygro_bg.right
                anchors.leftMargin: 2
            }
            Rectangle {
                id: lumi_data
                width: 14
                height: 0
                color: "#f8ef50"
                border.color: "#00000000"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: temp_bg.right
                anchors.leftMargin: 2
            }
            Rectangle {
                id: cond_data
                width: 14
                height: 0
                color: "#fc7203"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: lumi_bg.right
                anchors.leftMargin: 2
            }
        }
*/
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
