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
    id: deviceBoxDesktop
    width: parent.width
    height: 120
    radius: 8
    color: "#ddffffff"

    property var myDevice

    Connections {
        target: myDevice
        onStatusUpdated: updateBoxDatas()
    }

    Component.onCompleted: updateBoxDatas();

    function updateBoxDatas() {
        if (myDevice.devicePlantName !== "") {
            textName.text = myDevice.devicePlantName
            textAddr.text = myDevice.deviceLocationName + " (" + myDevice.deviceAddress + ")"
        }
        if (myDevice.deviceName === "MJ_HT_V1") {
            textName.text = qsTr("BLE temperature sensor");
            textAddr.text = myDevice.deviceLocationName + " (" + myDevice.deviceAddress + ")"
        }

        imageDevice.visible = false
        if (myDevice.deviceName === "MJ_HT_V1") {
            imageDevice.source = "qrc:/assets/devices/hygrotemp.svg";
        } else if (myDevice.deviceName === "ropot") {
            imageDevice.source = "qrc:/assets/devices/ropot.svg";
        } else {
            imageDevice.source = "qrc:/assets/devices/flowercare.svg";
        }

        if (myDevice.isUpdating()) {
            imageStatus.source = "qrc:/assets/ble.svg";
            refreshAnimation.running = true;

            imageStatus.visible = true;
            imageDatas.visible = false;
            textDatas.visible = false;
            imageBattery.visible = false;
            textBattery.visible = false;
        } else {
            refreshAnimation.running = false;

            if (myDevice.isAvailable()) {
                imageStatus.visible = false;
                imageDatas.visible = true;
                textDatas.visible = true;
                textDatas.text = myDevice.dataString;

                if ((myDevice.deviceCapabilities & 0x01) == 1) {
                    imageBattery.visible = true;
                    textBattery.visible = true;

                    if (myDevice.deviceBattery < 15) {
                        imageBattery.source = "qrc:/assets/battery_low.svg";
                    } else if (myDevice.deviceBattery > 75) {
                        imageBattery.source = "qrc:/assets/battery_full.svg";
                    } else {
                        imageBattery.source = "qrc:/assets/battery_mid.svg";
                    }
                    textBattery.text = myDevice.deviceBattery + "%"
                } else {
                    imageBattery.visible = false;
                    textBattery.visible = false;
                }

            } else {
                imageStatus.source = "qrc:/assets/ble_err.svg";
                imageStatus.opacity = 1;

                imageStatus.visible = true;
                imageDatas.visible = false;
                textDatas.visible = false;
                imageBattery.visible = false;
                textBattery.visible = false;
            }
        }
    }

    Text {
        id: textName
        height: 32
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.topMargin: 12
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 8

        color: "#454B54"
        text: myDevice.deviceLocationName
        font.bold: true
        font.pixelSize: 24
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: textAddr
        height: 22
        color: "#454b54"
        anchors.top: textName.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 9

        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        text: myDevice.deviceAddress
    }

    Image {
        id: imageDevice
        width: 56
        height: 56
        visible: false
        opacity: 0.5

        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
    }

    Rectangle {
        id: dataArea
        height: 44
        color: "#aaf3f3f3"
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Image {
            id: imageDatas
            width: 22
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            source: "qrc:/assets/stats.svg"
        }
        Text {
            id: textDatas
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: imageDatas.right
            anchors.leftMargin: 8
            text: myDevice.dataString
            verticalAlignment: Text.AlignBottom
            font.family: "Arial"
            font.pixelSize: 16
        }

        Image {
            id: imageBattery
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: textDatas.right
            anchors.leftMargin: 16

            source: {
                if (myDevice.deviceBattery < 15) {
                    source = "qrc:/assets/battery_low.svg";
                } else if (myDevice.deviceBattery > 75) {
                    source = "qrc:/assets/battery_full.svg";
                } else {
                    source = "qrc:/assets/battery_mid.svg";
                }
            }
        }
        Text {
            id: textBattery
            width: 48
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            anchors.left: imageBattery.right

            text: myDevice.deviceBattery + "%"
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 16
        }

        Image {
            id: imageStatus
            width: 32
            height: 32

            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/assets/ble.svg"
            visible: true

            SequentialAnimation on opacity {
                id: refreshAnimation
                loops: Animation.Infinite
                running: true
                OpacityAnimator { from: 0; to: 1; duration: 600 }
                OpacityAnimator { from: 1; to: 0;  duration: 600 }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onClicked: {
            pageLoader.setSource("DeviceScreen.qml",
                                 { myDevice: myDevice });
        }
    }
}
