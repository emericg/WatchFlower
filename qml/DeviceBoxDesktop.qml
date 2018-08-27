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
    height: 128
    radius: 8
    color: "#ddffffff"

    property var myDevice

    Text {
        id: textName
        y: 8
        height: 32
        color: "#454B54"
        text: myDevice.deviceCustomName
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.topMargin: 12
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 8

        font.bold: true
        font.pixelSize: 26
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
    }

    Connections {
        target: myDevice
        onStatusUpdated: updateBoxDatas()
    }

    Component.onCompleted: updateBoxDatas();

    function updateBoxDatas() {
        if (myDevice.devicePlantName !== "") {
            textName.text = myDevice.devicePlantName;
            textAddr.text = myDevice.deviceCustomName + " (" + myDevice.deviceAddress + ")";
        }
        if (myDevice.deviceName === "MJ_HT_V1") {
            if (myDevice.deviceCustomName !== "MJ_HT_V1") {
                textName.text = myDevice.devicePlantName;
            } else {
                textName.text = qsTr("Temperature sensor");
            }
            textAddr.text = myDevice.deviceName + " (" + myDevice.deviceAddress + ")";
        }

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
        id: textAddr
        width: 166
        height: 21
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
        text: myDevice.deviceAddress
        anchors.top: textName.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 8
    }

    Image {
        id: imageDevice
        opacity: 0.5
        x: 290
        width: 64
        height: 64
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
    }

    Rectangle {
        id: dataArea
        x: 0
        y: 80
        height: 48
        color: "#aaf3f3f3"
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Image {
            id: imageDatas
            x: 8
            y: 8
            width: 30
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            source: "qrc:/assets/stats.svg"
        }
        Text {
            id: textDatas
            x: 46
            y: 8
            height: 30

            text: myDevice.dataString
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: imageDatas.right
            anchors.leftMargin: 8
        }

        Image {
            id: imageBattery
            x: 268
            y: 10
            width: 30
            height: 30

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
            x: 304
            y: 8
            width: 48
            height: 30

            text: myDevice.deviceBattery + "%"
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter

            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            anchors.left: imageBattery.right
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
