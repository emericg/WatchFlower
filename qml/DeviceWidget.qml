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

import com.watchflower.theme 1.0

Item {
    implicitWidth: 640
    implicitHeight: 100
    anchors.fill: parent.width

    property var boxDevice: null

    property bool mobileMode: (Qt.platform.os === "android" || Qt.platform.os === "ios")
    property bool wideMode: (width > 350)
    property bool singleColumn: true

    Connections {
        target: boxDevice
        onStatusUpdated: updateBoxDatas()
        onLimitsUpdated: updateBoxDatas()
        onDatasUpdated: updateBoxDatas()
    }

    Component.onCompleted: initBoxDatas()

    function normalize(value, min, max) {
        if (value <= 0) return 0
        return Math.min(((value - min) / (max - min)), 1)
    }

    function initBoxDatas() {

        // Device picture
        if (boxDevice.deviceName === "MJ_HT_V1") {
            imageDevice.source = "qrc:/assets/devices/hygrotemp.svg"
        } else if (boxDevice.deviceName === "ropot") {
            imageDevice.source = "qrc:/assets/devices/ropot.svg"
        } else {
            imageDevice.source = "qrc:/assets/devices/flowercare.svg"
        }

        // Sensor battery level
        if (boxDevice.hasBatteryLevel()) {
            imageBattery.visible = true

            if (boxDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (boxDevice.deviceBattery > 90) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (boxDevice.deviceBattery > 70) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (boxDevice.deviceBattery > 60) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (boxDevice.deviceBattery > 40) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (boxDevice.deviceBattery > 30) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (boxDevice.deviceBattery > 20) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (boxDevice.deviceBattery > 1) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_alert-24px.svg";
            } else {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }

        updateBoxDatas()
    }

    function updateBoxDatas() {

        rectangleSensors.visible = false
        rectangleHygroTemp.visible = false
        water.visible = false

        // Texts
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

        // Status
        if (boxDevice.updating) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Connecting...")
        } else if (boxDevice.available) {
            textStatus.color = Theme.colorGreen
            textStatus.text = qsTr("Synced")
        } else if (boxDevice.lastUpdateMin >= 0 && boxDevice.lastUpdateMin <= 12*60) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Synced") /* + " " + boxDevice.lastUpdateMin + " " + qsTr("min. ago") */
        } else {
            textStatus.color = Theme.colorRed
            textStatus.text = qsTr("Offline")
        }

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
            } else {
                // otherwise, fullsize
                imageStatus.visible = true;
                imageStatus.source = "qrc:/assets/ble.svg";
                refreshAnimation.running = true;
            }
        } else {
            refreshAnimation.running = false;

            if (boxDevice.isAvailable()) {
                imageStatus.visible = false;
            } else {
                if (boxDevice.lastUpdateMin >= 0 && boxDevice.lastUpdateMin <= 720) {
                    // if we have data cached, used the little indicator
                    imageStatus.visible = false;
                } else {
                    // otherwise big one
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
                hygro_data.height = normalize(boxDevice.deviceHygro, boxDevice.limitHygroMin - 1, boxDevice.limitHygroMax) * dataArea.height
                temp_data.height = normalize(boxDevice.deviceTempC, boxDevice.limitTempMin - 1, boxDevice.limitTempMax) * dataArea.height
                lumi_data.height = normalize(boxDevice.deviceLuminosity, boxDevice.limitLumiMin, boxDevice.limitLumiMax) * dataArea.height
                cond_data.height = normalize(boxDevice.deviceConductivity, boxDevice.limitConduMin, boxDevice.limitConduMax) * dataArea.height

                hygro_bg.visible = (boxDevice.deviceHygro > 0 || boxDevice.deviceConductivity > 0)
                lumi_bg.visible = boxDevice.hasLuminositySensor()
                cond_bg.visible = (boxDevice.deviceHygro > 0 || boxDevice.deviceConductivity > 0)
            }
        }
    }

    Rectangle {
        id: deviceWidget
        radius: 2
        anchors.rightMargin: 6
        anchors.leftMargin: 6
        anchors.bottomMargin: 6
        anchors.topMargin: 6
        anchors.fill: parent

        color: "transparent"
        border.width: 2
        border.color: (singleColumn) ? "transparent" : Theme.colorMaterialDarkGrey

        MouseArea {
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

        ////////////////////////////////////////////////////////////////////////////

        Row {
            id: rowLeft
            width: 298
            spacing: 24
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: singleColumn ? 8 : 12

            ImageSvg {
                id: imageDevice
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                color: "black"
                visible: wideMode
                fillMode: Image.PreserveAspectFit
            }

            Column {
                id: column
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: textPlant
                    anchors.rightMargin: 8

                    color: Theme.colorText
                    text: boxDevice.deviceLocationName
                    font.capitalization: Font.Capitalize
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left
                    font.pixelSize: 20
                }

                Text {
                    id: textLocation
                    anchors.rightMargin: 8

                    color: Theme.colorSubText
                    text: boxDevice.deviceAddress
                    font.capitalization: Font.Capitalize
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left
                    font.pixelSize: 18
                }

                Row {
                    id: row
                    width: 256
                    height: 22
                    spacing: 8
                    anchors.left: parent.left

                    ImageSvg {
                        id: imageBattery
                        width: 30
                        height: 32

                        color: Theme.colorIcons
                        anchors.verticalCenter: parent.verticalCenter
                        rotation: 90
                        source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        id: textStatus
                        text: qsTr("Synced")
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////////

        Row {
            id: rowRight
            spacing: 8
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: singleColumn ? 0 : 10

            Row {
                id: lilIcons
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                layoutDirection: Qt.RightToLeft
                spacing: 8

                ImageSvg {
                    id: water
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-opacity-24px.svg"
                    color: Theme.colorBlue
                }
            }

            Item {
                id: dataArea
                width: 80
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Image {
                    id: imageStatus
                    width: 32
                    height: 32
                    anchors.right: parent.right
                    anchors.rightMargin: 12
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
                    property int sensorWidth: mobileMode ? 8 : 10
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
                }

                Column {
                    id: rectangleHygroTemp
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.left: parent.left

                    Connections {
                        target: settingsManager
                        onTempunitChanged: textTemp.text = boxDevice.getTemp().toFixed(1) + "°"
                    }

                    Text {
                        id: textTemp
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0

                        text: qsTr("25.0°")
                        color: "#333333"
                        font.wordSpacing: -1.2
                        font.letterSpacing: -1.4
                        font.pixelSize: 30
                        font.family: "Tahoma"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        id: textHygro
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0

                        text: qsTr("55%")
                        color: "#666666"
                        font.pixelSize: 24
                        font.family: "Tahoma"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            Image {
                id: imageForward
                width: 32
                height: 32
                anchors.verticalCenterOffset: 0
                visible: singleColumn
                z: 1
                sourceSize: Qt.size(width, height)
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
            }
        }
    }

    Rectangle {
        id: bottomSeparator
        color: Theme.colorMaterialDarkGrey
        visible: singleColumn
        height: 2

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.leftMargin: -6
        anchors.rightMargin: -6
        anchors.left: parent.left
    }
}
