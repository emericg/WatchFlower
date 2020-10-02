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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import ThemeEngine 1.0

Item {
    id: deviceScreenData
    width: 400
    height: 300

    property var dataIndicators: null
    property var dataCharts: null

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateHeader() >> " + currentDevice)

        // Sensor battery level
        if (currentDevice.hasBatteryLevel()) {
            imageBattery.visible = true
            imageBattery.color = Theme.colorIcon

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
                if (currentDevice.deviceBattery <= 10) imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                if (currentDevice.deviceBattery === 0) imageBattery.color = Theme.colorRed
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }

        // Plant
        if (currentDevice.hasSoilMoistureSensor()) {
            itemPlant.visible = true
        } else {
            itemPlant.visible = false
        }

        // Status
        updateStatusText()
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateStatusText() >> " + currentDevice)

        textStatus.color = Theme.colorHighContrast
        textStatus.font.bold = false

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
                textStatus.color = Theme.colorRed
            }
        }
    }

    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // loadData() >> " + currentDevice)

        updateHeader()

        if (indicatorsLoader.status != Loader.Ready) {
            if (settingsManager.bigIndicator)
                indicatorsLoader.source = "ItemIndicatorsFilled.qml"
            else
                indicatorsLoader.source = "ItemIndicatorsCompact.qml"
            dataIndicators = indicatorsLoader.item
        }

        if (graphLoader.status != Loader.Ready) {
            graphLoader.source = "ItemAioLineCharts.qml"
            dataCharts = graphLoader.item
        }
        dataCharts.loadGraph()

        updateData()
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateData() >> " + currentDevice)

        resetHistoryMode()
        dataIndicators.updateData()
        dataCharts.updateGraph()
    }

    function isHistoryMode() {
        return dataCharts.isIndicator()
    }
    function resetHistoryMode() {
        dataCharts.resetIndicator()
    }

    Connections {
        target: settingsManager
        onTempUnitChanged: {
            updateData()
        }
        onBigIndicatorChanged: {
            if (settingsManager.bigIndicator)
                indicatorsLoader.source = "ItemIndicatorsFilled.qml"
            else
                indicatorsLoader.source = "ItemIndicatorsCompact.qml"
            dataIndicators = indicatorsLoader.item
            updateData()
        }
        onAppLanguageChanged: {
            updateStatusText()
        }
    }
/*
    onWidthChanged: {
        if (isPhone) {
            if (screenOrientation === Qt.PortraitOrientation) {
                contentGrid_lvl1.columns = 1
                contentGrid_lvl1.rows = 2
                rectangleHeader.color = Theme.colorForeground
            } else {
                contentGrid_lvl1.columns = 2
                contentGrid_lvl1.rows = 1
                rectangleHeader.color = "transparent"
            }
        }
        if (isDesktop) {
            if (deviceScreenData.width < deviceScreenData.height) {
                contentGrid_lvl2.columns = 1
                contentGrid_lvl2.rows = 2
                rectangleHeader.color = Theme.colorForeground
            } else {
                contentGrid_lvl2.columns = 2
                contentGrid_lvl2.rows = 1
                rectangleHeader.color = "transparent"
            }
        }
    }
*/
    ////////////////////////////////////////////////////////////////////////////

    Grid {
        id: contentGrid_lvl1
        columns: (isPhone && screenOrientation === Qt.LandscapeOrientation) ? 2 : 1
        rows: (isPhone && screenOrientation === Qt.LandscapeOrientation) ? 1 : 2
        spacing: (rows > 1) ? 12 : 0

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Grid {
            id: contentGrid_lvl2
            width: contentGrid_lvl1.width / contentGrid_lvl1.columns
            columns: 1
            rows: 2
            spacing: 6

            ////////

            Rectangle {
                id: rectangleHeader
                color: (isPhone && screenOrientation === Qt.LandscapeOrientation) ? "transparent" : Theme.colorForeground
                width: parent.width / parent.columns
                height: columnHeader.height + 12
                z: 5

                Column {
                    id: columnHeader
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 2
                    spacing: 2

                    Text {
                        id: textDeviceName
                        height: 36
                        anchors.left: parent.left

                        visible: isDesktop

                        text: currentDevice.deviceName
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeTitle
                        font.capitalization: Font.AllUppercase
                        verticalAlignment: Text.AlignVCenter

                        ImageSvg {
                            id: imageBattery
                            width: 32
                            height: 32
                            rotation: 90
                            anchors.verticalCenter: textDeviceName.verticalCenter
                            anchors.left: textDeviceName.right
                            anchors.leftMargin: 16

                            source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                            color: Theme.colorIcon
                        }
                    }

                    Item {
                        id: itemPlant
                        height: 28
                        width: parent.width

                        Text {
                            id: labelPlant
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Plant")
                            font.bold: true
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        TextInput {
                            id: textInputPlant
                            anchors.left: labelPlant.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            padding: 4
                            font.pixelSize: 18
                            font.bold: false
                            color: Theme.colorHighContrast

                            text: currentDevice ? currentDevice.devicePlantName : ""
                            onEditingFinished: {
                                currentDevice.setPlantName(text)
                                focus = false
                            }

                            MouseArea {
                                id: textInputPlantArea
                                anchors.fill: parent
                                anchors.topMargin: -4
                                anchors.leftMargin: -4
                                anchors.rightMargin: -24
                                anchors.bottomMargin: -4

                                hoverEnabled: true
                                propagateComposedEvents: true

                                onClicked: {
                                    textInputPlant.forceActiveFocus()
                                    mouse.accepted = false
                                }
                                onPressed: {
                                    textInputPlant.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        ImageSvg {
                            id: imageEditPlant
                            width: 20
                            height: 20
                            anchors.left: textInputPlant.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                            color: Theme.colorSubText

                            //visible: (isMobile || !textInputPlant.text || textInputPlant.focus || textInputPlantArea.containsMouse)
                            opacity: (isMobile || !textInputPlant.text || textInputPlant.focus || textInputPlantArea.containsMouse) ? 0.9 : 0
                            Behavior on opacity { OpacityAnimator { duration: 133 } }
                        }
                    }

                    Item {
                        id: itemLocation
                        height: 28
                        width: parent.width

                        Text {
                            id: labelLocation
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Location")
                            font.bold: true
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        TextInput {
                            id: textInputLocation
                            anchors.left: labelLocation.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            padding: 4
                            font.pixelSize: 18
                            font.bold: false
                            color: Theme.colorHighContrast

                            text: currentDevice ? currentDevice.deviceLocationName : ""
                            onEditingFinished: {
                                currentDevice.setLocationName(text)
                                focus = false
                            }

                            MouseArea {
                                id: textInputLocationArea
                                anchors.fill: parent
                                anchors.topMargin: -4
                                anchors.leftMargin: -4
                                anchors.rightMargin: -24
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
                            id: imageEditLocation
                            width: 20
                            height: 20
                            anchors.left: textInputLocation.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                            color: Theme.colorSubText

                            //visible: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputArea.containsMouse)
                            opacity: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputLocationArea.containsMouse) ? 0.9 : 0
                            Behavior on opacity { OpacityAnimator { duration: 133 } }
                        }
                    }

                    Item {
                        id: status
                        height: 28
                        width: parent.width

                        Text {
                            id: labelStatus
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Status")
                            font.bold: true
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            id: textStatus
                            anchors.left: labelStatus.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            padding: 4

                            text: qsTr("Loading...")
                            color: Theme.colorHighContrast
                            font.pixelSize: 18
                            font.bold: false
                        }
                    }
                }
            }

            ////////

            Loader {
                id: indicatorsLoader
                width: parent.width / parent.columns
                //height: columnData.height + 16
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Loader {
            id: graphLoader
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            height: (contentGrid_lvl1.columns === 1) ? (contentGrid_lvl1.height - rectangleHeader.height - indicatorsLoader.height - (contentGrid_lvl1.rows > 1 ? contentGrid_lvl1.spacing : 0)) : contentGrid_lvl1.height
        }
    }
}
