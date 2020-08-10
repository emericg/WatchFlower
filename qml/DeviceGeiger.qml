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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: deviceGeiger
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
        //return deviceScreenChart.isIndicator()
    }
    function resetHistoryMode() {
        //deviceScreenChart.resetIndicator()
    }

    function loadDevice(clickedDevice) {
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.hasGeigerCounter()) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        console.log("DeviceGeiger // loadDevice() >> " + currentDevice)

        loadGraph()
        updateHeader()
        updateData()
    }

    function loadGraph() {
        //
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasGeigerCounter()) return
        //console.log("DeviceGeiger // updateHeader() >> " + currentDevice)

        // Status
        updateStatusText()
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasGeigerCounter()) return
        //console.log("DeviceGeiger // updateData() >> " + currentDevice)

        //sensorRadioactivity.text = currentDevice.deviceRadioactivityH.toFixed(3) + " µSv/m"

        //deviceScreenChart.updateGraph()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasGeigerCounter()) return
        //console.log("DeviceGeiger // updateStatusText() >> " + currentDevice)

        if (currentDevice.status === 1) {
            textStatus.text = qsTr("Update queued.") + " "
        } else if (currentDevice.status === 2) {
            textStatus.text = qsTr("Connecting...") + " "
        } else if (currentDevice.status === 3) {
            textStatus.text = qsTr("Working...") + " "
        } else if (currentDevice.status === 4 || currentDevice.status === 5) {
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
        anchors.top: radBox.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: radBox
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: Math.max(deviceGeiger.height * 0.333, isPhone ? 96 : 256)
        color: Theme.colorHeader

        MouseArea { anchors.fill: parent } // prevent clicks below this area

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -8
            spacing: 8

            Image {
                width: 180; height: 180;
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/assets/icons_custom/nuclear.png"
                sourceSize: Qt.size(width, height)
            }

            Text {
                id: sensorRadioactivity
                anchors.horizontalCenter: parent.horizontalCenter

                text: currentDevice.deviceRadioactivityM.toFixed(3) + " µSv/m"
                font.bold: false
                font.pixelSize: isPhone ? 28 : 32
                color: Theme.colorHeaderContent
            }

            ImageSvg {
                id: imageBattery
                width: isPhone ? 20 : 24
                height: isPhone ? 32 : 36
                rotation: 90
                anchors.horizontalCenter: parent.horizontalCenter

                visible: currentDevice.hasBatteryLevel()
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
