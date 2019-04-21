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

import com.watchflower.theme 1.0

Rectangle {
    id: deviceBoxMobile
    width: parent.width
    height: 96
    radius: 4

    color: "transparent"
    border.width: 2
    border.color: Theme.colorMaterialDarkGrey

    property var boxDevice: null

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
        if (boxDevice.deviceName === "MJ_HT_V1") {
            textPlant.text = qsTr("Thermometer")
        } else if (boxDevice.devicePlantName !== "") {
            textPlant.text = boxDevice.devicePlantName
        } else {
            textPlant.text = boxDevice.deviceName
        }

        if (boxDevice.deviceLocationName !== "") {
            textLocation.text = boxDevice.deviceLocationName
        } else {
            textLocation.text = boxDevice.deviceAddress
        }

        rectangleSensors.visible = false
        rectangleHygroTemp.visible = false
        water.visible = false
        ble.visible = false

        // Water me notif
        if (boxDevice.deviceHygro > 0) {
            if (boxDevice.deviceName !== "MJ_HT_V1") {
                if (boxDevice.deviceHygro < boxDevice.limitHygroMin) {
                    water.visible = true
                }
            }
        }

        // Update notif
        if (boxDevice.isUpdating()) {
            if (boxDevice.lastUpdateMin >= 0 && boxDevice.lastUpdateMin <= 720) {
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
                if (boxDevice.lastUpdateMin >= 0 && boxDevice.lastUpdateMin <= 720) {
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
        if (boxDevice.lastUpdateMin >= 0 && boxDevice.lastUpdateMin <= 720) {
            if (boxDevice.deviceName === "MJ_HT_V1") {
                rectangleHygroTemp.visible = true
                textTemp.text = boxDevice.getTemp().toFixed(1) + "°"
                textHygro.text = boxDevice.deviceHygro + "%"
            } else {
                rectangleSensors.visible = true
                hygro_data.height = normalize(boxDevice.deviceHygro, boxDevice.limitHygroMin, boxDevice.limitHygroMax) * dataArea.height
                temp_data.height = normalize(boxDevice.deviceTempC, boxDevice.limitTempMin, boxDevice.limitTempMax) * dataArea.height
                lumi_data.height = normalize(boxDevice.deviceLuminosity, boxDevice.limitLumiMin, boxDevice.limitLumiMax) * dataArea.height
                cond_data.height = normalize(boxDevice.deviceConductivity, boxDevice.limitConduMin, boxDevice.limitConduMax) * dataArea.height
                bat_data.height = (boxDevice.deviceBattery / 100) * dataArea.height

                hygro_bg.visible = (boxDevice.deviceHygro > 0 || boxDevice.deviceConductivity > 0)
                lumi_bg.visible = boxDevice.hasLuminositySensor()
                cond_bg.visible = (boxDevice.deviceHygro > 0 || boxDevice.deviceConductivity > 0)
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.fill: parent

        onClicked: {
            if (boxDevice.hasDatas()) {
                if (curentlySelectedDevice != boxDevice) {
                    curentlySelectedDevice = boxDevice

                    if (curentlySelectedDevice.deviceName === "MJ_HT_V1")
                        screenDeviceThermometer.loadDevice()
                    else
                        screenDeviceSensor.loadDevice()
                }

                if (curentlySelectedDevice.deviceName === "MJ_HT_V1")
                    content.state = "DeviceThermo"
                else
                    content.state = "DeviceSensor"
            }
        }
    }

    Text {
        id: textLocation
        anchors.right: dataArea.left
        anchors.rightMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 12

        clip: true
        color: Theme.colorSubText
        text: boxDevice.deviceAddress
        font.pixelSize: 18
    }

    Text {
        id: textPlant
        anchors.right: dataArea.left
        anchors.rightMargin: 8
        anchors.topMargin: 20
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 12

        color: Theme.colorText
        text: boxDevice.deviceLocationName
        font.pixelSize: 22
        clip: true
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

        ImageSvg {
            id: ble
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-bluetooth_searching-24px.svg"
            color: Theme.colorText

            SequentialAnimation on opacity {
                id: refreshAnimation2
                loops: Animation.Infinite
                running: false
                OpacityAnimator { from: 0; to: 1; duration: 600 }
                OpacityAnimator { from: 1; to: 0;  duration: 600 }
                onStopped: { ble.opacity = 1 }
            }
        }

        ImageSvg {
            id: water
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-opacity-24px.svg"
            color: Theme.colorBlue
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: dataArea
        width: 82
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8

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

        Row {
            id: rectangleSensors
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top

            visible: true
            spacing: 8
            property int sensorWidth: 10
            property int sensorRadius: 2

            Item {
                id: hygro_bg
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg1
                    anchors.fill: parent
                    color: Theme.colorBlue
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: hygro_data
                    height: 12
                    color: Theme.colorBlue
                    radius: rectangleSensors.sensorRadius
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
                width: rectangleSensors.sensorWidth
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0

                Rectangle {
                    id: bg2
                    anchors.fill: parent
                    color: Theme.colorGreen
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: temp_data
                    height: 6
                    color: Theme.colorGreen
                    radius: rectangleSensors.sensorRadius
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
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg3
                    anchors.fill: parent
                    color: Theme.colorYellow
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: lumi_data
                    height: 8
                    color: Theme.colorYellow
                    radius: rectangleSensors.sensorRadius
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
            }

            Item {
                id: cond_bg
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg4
                    anchors.fill: parent
                    color: Theme.colorRed
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: cond_data
                    height: 10
                    color: Theme.colorRed
                    radius: rectangleSensors.sensorRadius
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
                width: rectangleSensors.sensorWidth
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0

                Rectangle {
                    id: bg5
                    anchors.fill: parent
                    color: Theme.colorGrey
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: bat_data
                    height: 6
                    color: Theme.colorGrey
                    radius: rectangleSensors.sensorRadius
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

            Connections {
                target: settingsManager
                onTempunitChanged: textTemp.text = boxDevice.getTemp().toFixed(1) + "°"
            }

            Text {
                id: textTemp
                y: 8
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                text: qsTr("25.0°")
                color: "#333333"
                font.wordSpacing: -1.2
                font.letterSpacing: -1.4
                renderType: Text.NativeRendering
                font.pixelSize: 30
                font.family: "Tahoma"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: textHygro
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                text: qsTr("55%")
                anchors.top: textTemp.bottom
                anchors.topMargin: 0
                color: "#666666"
                font.pixelSize: 24
                font.family: "Tahoma"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
