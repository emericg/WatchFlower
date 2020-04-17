/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Item {
    id: deviceThermometer
    width: 450
    height: 700

    property var myDevice: currentDevice

    function isHistoryMode() {
        return deviceScreenChart.isIndicator()
    }
    function resetHistoryMode() {
        deviceScreenChart.resetIndicator()
    }

    Connections {
        target: myDevice
        onStatusUpdated: updateHeader()
        onSensorUpdated: updateHeader()
        onDataUpdated: updateData()
        onLimitsUpdated: updateData()
    }

    Connections {
        target: settingsManager
        onTempUnitChanged: updateData()
    }

    Connections {
        target: appHeader
        // desktop only
        onDeviceDataButtonClicked: {
            appHeader.setActiveDeviceData()
        }
        onDeviceSettingsButtonClicked: {
            appHeader.setActiveDeviceSettings()
        }
        // mobile only
        onRightMenuClicked: {
            //
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    onHeightChanged: {
        // update tempBox height
        tempBox.height = ((height * 0.33) > 256) ? (height * 0.33) : 256
    }

    property var deviceScreenChart: null

    function loadDevice() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // loadDevice() >> " + myDevice)

        updateHeader()
        if (graphLoader.status != Loader.Ready) {
            graphLoader.source = "ItemAioLineCharts.qml"
            deviceScreenChart = graphLoader.item
        }
        deviceScreenChart.loadGraph()

        updateData()
    }

    function updateHeader() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateHeader() >> " + myDevice)

        // Sensor battery level
        if (myDevice.hasBatteryLevel()) {
            imageBattery.visible = true
            //imageBattery.color = Theme.colorHeaderContent

            if (myDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (myDevice.deviceBattery > 85) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (myDevice.deviceBattery > 75) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (myDevice.deviceBattery > 55) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (myDevice.deviceBattery > 45) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (myDevice.deviceBattery > 25) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (myDevice.deviceBattery > 15) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (myDevice.deviceBattery > 1) {
                //if (myDevice.deviceBattery <= 10) imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                if (myDevice.deviceBattery === 0) imageBattery.color = Theme.colorRed
                //imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }

        // Location
        textInputLocation.text = myDevice.deviceLocationName
        imageEditLocation.visible = !textInputLocation.text || textInputLocation.focus

        // Status
        updateStatusText()
    }

    function updateData() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateData() >> " + myDevice)

        if (myDevice.deviceTempC > -40)
            sensorTemp.text = myDevice.getTempString()
        else
            sensorTemp.text = "?"
        if (myDevice.deviceHumidity > 0)
            sensorHygro.text = myDevice.deviceHumidity + "% " + qsTr("humidity")
        else
            sensorHygro.text = ""

        deviceScreenChart.updateGraph()
    }

    function updateStatusText() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateStatusText() >> " + myDevice)

        if (myDevice.status === 1) {
            textStatus.text = qsTr("Update queued. ")
        } else if (myDevice.status === 2) {
            textStatus.text = qsTr("Connecting... ")
        } else if (myDevice.status === 3) {
            textStatus.text = qsTr("Updating... ")
        } else {
            if (myDevice.isFresh() || myDevice.isAvailable()) {
                if (myDevice.getLastUpdateInt() <= 1)
                    textStatus.text = qsTr("Just synced!")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(myDevice.lastUpdateStr)
            } else {
                textStatus.text = qsTr("Offline! ")
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: tempBox
        height: 256
        color: Theme.colorHeader
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Text {
            id: sensorTemp
            anchors.verticalCenterOffset: -40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            text: "22.0°"
            font.bold: false
            font.pixelSize: 48
            color: Theme.colorHeaderContent
        }

        Text {
            id: sensorHygro
            anchors.top: sensorTemp.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

            text: "50%"
            font.bold: false
            font.pixelSize: 24
            color: Theme.colorHeaderContent
        }

        Item {
            id: status
            height: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 8

            ImageSvg {
                id: imageStatus
                width: 24
                height: 24

                source: "qrc:/assets/icons_material/duotone-access_time-24px.svg"
                color: Theme.colorHeaderContent
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: textStatus
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: imageStatus.right
                anchors.leftMargin: 8

                text: qsTr("Updating...")
                color: Theme.colorHeaderContent
                font.pixelSize: 17
                font.bold: false
            }
        }

        ImageSvg {
            id: imageBattery
            width: 28
            height: 28
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
            color: Theme.colorHeaderContent
        }

        Item {
            id: itemLocation
            height: 24
            width: 96
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8

            ImageSvg {
                id: imageLocation
                width: 24
                height: 24
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                color: Theme.colorHeaderContent
            }

            TextInput {
                id: textInputLocation
                height: 28
                anchors.right: imageLocation.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                padding: 4
                font.pixelSize: 17
                font.bold: false
                color: Theme.colorHeaderContent

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
                    propagateComposedEvents: true

                    hoverEnabled: true
                    onEntered: { imageEditLocation.visible = true; }
                    onExited: {
                        if (textInputLocation.text && !textInputLocation.focus) {
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

                MouseArea {
                    id: mouseArea1
                    width: 26
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: textInputLocation.left
                    anchors.rightMargin: 0

                    hoverEnabled: true
                    onEntered: { imageEditLocation.visible = true; }
                    onExited: {
                        if (textInputLocation.text && !textInputLocation.focus) {
                            imageEditLocation.visible = false
                        } else {
                            imageEditLocation.visible = true
                        }
                    }

                    onClicked: textInputLocation.forceActiveFocus()
                    onPressed: textInputLocation.forceActiveFocus()

                    ImageSvg {
                        id: imageEditLocation
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        visible: false
                        source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                        color: Theme.colorHeaderContent
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: graphLoader
        anchors.top: tempBox.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }
}
