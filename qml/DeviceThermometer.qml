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

import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: deviceThermometer
    width: 450
    height: 700

    property var currentDevice: null
    property alias deviceScreenChart: graphLoader.item

    Connections {
        target: currentDevice
        onStatusUpdated: { updateHeader() }
        onSensorUpdated: { updateHeader() }
        onDataUpdated: { updateData() }
    }

    Connections {
        target: settingsManager
        onTempUnitChanged: { updateData() }
        onAppLanguageChanged: {
            updateData()
            updateStatusText()
        }
        onGraphThermometerChanged: {
            loadGraph()
        }
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

    Keys.onPressed: {
        if (event.key === Qt.Key_Backspace) {
            event.accepted = true;
            appWindow.backAction()
        }
    }

    ////////

    function isHistoryMode() {
        return deviceScreenChart.isIndicator()
    }
    function resetHistoryMode() {
        deviceScreenChart.resetIndicator()
    }

    function loadDevice(clickedDevice) {
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (clickedDevice.hasSoilMoistureSensor()) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        //console.log("DeviceThermometer // loadDevice() >> " + currentDevice)

        loadGraph()
        updateHeader()
        updateData()
    }

    function loadGraph() {
        if (settingsManager.graphThermometer === "lines") {
            graphLoader.source = "ItemAioLineCharts.qml"
        } else {
            graphLoader.source = "ItemThermometerWidget.qml"
        }
        deviceScreenChart.loadGraph()
        deviceScreenChart.updateGraph()
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateHeader() >> " + currentDevice)

        // Sensor battery level
        if (currentDevice.hasBatteryLevel()) {
            //imageBattery.visible = true
            imageBattery.color = Theme.colorHeaderContent

            if (currentDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (currentDevice.deviceBattery > 85) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (currentDevice.deviceBattery > 75) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (currentDevice.deviceBattery > 55) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (currentDevice.deviceBattery > 45) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (currentDevice.deviceBattery > 25) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (currentDevice.deviceBattery > 15) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (currentDevice.deviceBattery > 1) {
                //if (currentDevice.deviceBattery <= 10) imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                if (currentDevice.deviceBattery === 0) imageBattery.color = Theme.colorRed
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            //imageBattery.visible = false
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
        }

        // Status
        updateStatusText()
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateData() >> " + currentDevice)

        if (currentDevice.deviceTempC > -40)
            sensorTemp.text = currentDevice.getTempString()
        else
            sensorTemp.text = "?"
        if (currentDevice.deviceHumidity > 0)
            sensorHygro.text = currentDevice.deviceHumidity + "% " + qsTr("humidity")
        else
            sensorHygro.text = ""

        deviceScreenChart.updateGraph()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateStatusText() >> " + currentDevice)

        if (currentDevice.status === 1) {
            textStatus.text = qsTr("Update queued.") + " "
        } else if (currentDevice.status === 2) {
            textStatus.text = qsTr("Connecting...") + " "
        } else if (currentDevice.status === 3) {
            textStatus.text = qsTr("Connected") + " "
        } else if (currentDevice.status === 8) {
            textStatus.text = qsTr("Working...") + " "
        } else if (currentDevice.status === 9 ||
                   currentDevice.status === 10 ||
                   currentDevice.status === 11) {
            textStatus.text = qsTr("Updating...") + " "
        } else {
            if (currentDevice.isFresh() || currentDevice.isAvailable()) {
                if (currentDevice.getLastUpdateInt() <= 1)
                    textStatus.text = qsTr("Just synced!")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
            } else {
                textStatus.text = qsTr("Offline!") + " "
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

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: tempBox
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: Math.max(deviceThermometer.height * 0.333, isPhone ? 96 : 256)
        color: Theme.colorHeader

        MouseArea { anchors.fill: parent } // prevent clicks below this area

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -(appHeader.height / 2) + (imageBattery.visible ? (imageBattery.width / 2) : 0)
            spacing: 2

            Text {
                id: sensorTemp
                anchors.horizontalCenter: parent.horizontalCenter

                text: "22.0°"
                font.bold: false
                font.pixelSize: isPhone ? 44 : 48
                color: Theme.colorHeaderContent
            }

            Text {
                id: sensorHygro
                anchors.horizontalCenter: parent.horizontalCenter

                text: "50%"
                font.bold: false
                font.pixelSize: isPhone ? 22 : 24
                color: Theme.colorHeaderContent
            }

            ImageSvg {
                id: imageBattery
                width: isPhone ? 20 : 24
                height: isPhone ? 32 : 36
                rotation: 90
                anchors.horizontalCenter: parent.horizontalCenter

                visible: (currentDevice.hasBatteryLevel() && currentDevice.deviceTempC > -40)
                fillMode: Image.PreserveAspectCrop
                color: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
            }
        }

        Row {
            id: status
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: itemLocation.left
            anchors.rightMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8

            clip: true
            height: 24
            spacing: 8

            ImageSvg {
                id: imageStatus
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/duotone-access_time-24px.svg"
                color: Theme.colorHeaderContent
            }
            Text {
                id: textStatus
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Loading...")
                color: Theme.colorHeaderContent
                font.pixelSize: 17
                font.bold: false
            }
        }

        Row {
            id: itemLocation
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8

            height: 24
            spacing: 4

            ImageSvg {
                id: imageEditLocation
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                color: Theme.colorHeaderContent

                //visible: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputLocationArea.containsMouse)
                opacity: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputLocationArea.containsMouse) ? 0.9 : 0
                Behavior on opacity { OpacityAnimator { duration: 133 } }
            }
            TextInput {
                id: textInputLocation
                anchors.verticalCenter: parent.verticalCenter

                padding: 4
                font.pixelSize: 17
                font.bold: false
                color: Theme.colorHeaderContent

                text: currentDevice ? currentDevice.deviceLocationName : ""
                onEditingFinished: {
                    currentDevice.setLocationName(text)
                    focus = false
                }

                MouseArea {
                    id: textInputLocationArea
                    anchors.fill: parent
                    anchors.topMargin: -4
                    anchors.leftMargin: -24
                    anchors.rightMargin: -4
                    anchors.bottomMargin: -4

                    hoverEnabled: true
                    propagateComposedEvents: true

                    onClicked: {
                        textInputLocation.forceActiveFocus()
                        mouse.accepted = false
                    }
                    onPressed: {
                        textInputLocation.forceActiveFocus()
                        mouse.accepted = false
                    }
                }
            }
            ImageSvg {
                id: imageLocation
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                color: Theme.colorHeaderContent
            }
        }
    }
}
