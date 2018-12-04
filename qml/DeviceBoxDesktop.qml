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
    height: 111
    color: "#ddffffff"
    radius: 8

    property var boxDevice

    Connections {
        target: boxDevice
        onStatusUpdated: updateBoxDatas()
        onLimitsUpdated: updateBoxDatas()
        onDatasUpdated: updateBoxDatas()
    }

    Component.onCompleted: updateBoxDatas();

    function updateBoxDatas() {
        if (boxDevice.devicePlantName !== "") {
            textName.text = boxDevice.devicePlantName
        }
        if (boxDevice.deviceName === "MJ_HT_V1") {
            textName.text = qsTr("BLE temperature sensor");
        }

        textAddr.text = boxDevice.deviceLocationName
        if (boxDevice.deviceLocationName === boxDevice.deviceName) {
            if (boxDevice.deviceAddress.charAt(0) === '{')
                textAddr.text += " " + boxDevice.deviceAddress
            else
                textAddr.text += " [" + boxDevice.deviceAddress + "]"
        }

        imageDevice.visible = false
        if (boxDevice.deviceName === "MJ_HT_V1") {
            imageDevice.source = "qrc:/assets/devices/hygrotemp.svg";
        } else if (boxDevice.deviceName === "ropot") {
            imageDevice.source = "qrc:/assets/devices/ropot.svg";
        } else {
            imageDevice.source = "qrc:/assets/devices/flowercare.svg";
        }

        if (boxDevice.isUpdating()) {
            imageStatus.source = "qrc:/assets/ble.svg";
            refreshAnimation.running = true;

            deviceBoxDesktop.color = "#ddffffff"
            dataArea.color = "#aaf3f3f3"

            imageStatus.visible = true;
            imageDatas.visible = false;
            textDatas.visible = false;
            imageBattery.visible = false;
            textBattery.visible = false;
        } else {
            refreshAnimation.running = false;

            if (boxDevice.isAvailable()) {
                imageStatus.visible = false;
                imageDatas.visible = true;
                textDatas.visible = true;
                textDatas.text = boxDevice.dataString;

                if (boxDevice.deviceHygro > 0 &&
                    (boxDevice.deviceHygro < boxDevice.limitHygroMin ||
                    boxDevice.deviceHygro > boxDevice.limitHygroMax)) {
                    deviceBoxDesktop.color = "#ddfff9e4"
                    dataArea.color = "#aafff2c8"
                } else {
                    deviceBoxDesktop.color = "#ddffffff"
                    dataArea.color = "#aaf3f3f3"
                }

                if ((boxDevice.deviceCapabilities & 0x01) == 1) {
                    imageBattery.visible = true;
                    textBattery.visible = true;

                    if (boxDevice.deviceBattery < 15) {
                        imageBattery.source = "qrc:/assets/battery_low.svg";
                    } else if (boxDevice.deviceBattery > 75) {
                        imageBattery.source = "qrc:/assets/battery_full.svg";
                    } else {
                        imageBattery.source = "qrc:/assets/battery_mid.svg";
                    }
                    textBattery.text = boxDevice.deviceBattery + "%"
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

    MouseArea {
        anchors.fill: parent

        onClicked: {
            curentlySelectedDevice = boxDevice
            content.state = "DeviceDetails"
        }
    }

    Text {
        id: textName
        height: 32
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.topMargin: 8
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 8

        color: "#454B54"
        text: boxDevice.deviceLocationName
        font.bold: true
        font.pixelSize: 23
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: textAddr
        height: 22
        color: "#454b54"
        anchors.top: textName.bottom
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 9

        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        text: boxDevice.deviceAddress
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
        height: 42
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
            text: boxDevice.dataString
            verticalAlignment: Text.AlignVCenter
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
                if (boxDevice.deviceBattery < 15) {
                    source = "qrc:/assets/battery_low.svg";
                } else if (boxDevice.deviceBattery > 75) {
                    source = "qrc:/assets/battery_full.svg";
                } else {
                    source = "qrc:/assets/battery_mid.svg";
                }
            }
        }
        Text {
            id: textBattery
            width: 48
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            anchors.left: imageBattery.right

            text: boxDevice.deviceBattery + "%"
            font.family: "Arial"
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
}
