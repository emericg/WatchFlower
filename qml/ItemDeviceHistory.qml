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
    id: deviceDatas
    width: 400
    height: 300

    property string graphMode: settingsManager.graphview

    function updateHeader() {
        if (typeof myDevice === "undefined") return

        // Sensor battery level
        if ((myDevice.deviceCapabilities & 1) == 1) {
            imageBattery.visible = true

            if (myDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (myDevice.deviceBattery > 90) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (myDevice.deviceBattery > 70) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (myDevice.deviceBattery > 60) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (myDevice.deviceBattery > 40) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (myDevice.deviceBattery > 30) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (myDevice.deviceBattery > 20) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (myDevice.deviceBattery > 1) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_alert-24px.svg";
            } else {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }
    }

    function loadDatas() {
        if (typeof myDevice === "undefined") return
        //console.log("ItemDeviceHistory // loadDatas() >> " + myDevice)

        graphCount = 0

        if ((myDevice.deviceCapabilities & 2) == 0) {
            tempLegend.visible = false
            tempGraph.visible = false
        } else {
            tempLegend.visible = true
            tempGraph.visible = true
            tempGraph.loadGraph()
            graphCount += 1
        }
        if ((myDevice.deviceCapabilities & 4) == 0) {
            hygroLegend.visible = false
            hygroGraph.visible = false
        } else {
            hygroLegend.visible = true
            hygroGraph.visible = true
            hygroGraph.loadGraph()
            graphCount += 1
        }
        if ((myDevice.deviceCapabilities & 8) == 0) {
            lumiLegend.visible = false
            lumiGraph.visible = false
        } else {
            lumiLegend.visible = true
            lumiGraph.visible = true
            lumiGraph.loadGraph()
            graphCount += 1
        }
        if ((myDevice.deviceCapabilities & 16) == 0) {
            conduLegend.visible = false
            conduGraph.visible = false
        } else {
            conduLegend.visible = true
            conduGraph.visible = true
            conduGraph.loadGraph()
            graphCount += 1
        }
        graphHeight = (column.height - graphCount*hygroLegend.height) / graphCount

        updateDatas()
    }

    function updateDatas() {
        if (typeof myDevice === 'undefined' || !myDevice) return
        //console.log("ItemDeviceHistory // updateDatas() >> " + myDevice)

        if ((myDevice.deviceCapabilities & 2) != 0) {
            tempGraph.updateGraph()
        }
        if ((myDevice.deviceCapabilities & 4) != 0) {
            hygroGraph.updateGraph()
        }
        if ((myDevice.deviceCapabilities & 8) != 0) {
            lumiGraph.updateGraph()
        }
        if ((myDevice.deviceCapabilities & 16) != 0) {
            conduGraph.updateGraph()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Theme.colorMaterialLightGrey : Theme.colorMaterialDarkGrey
        height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 56 : 96

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Row {
            id: buttonPanel
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            anchors.top: parent.top
            anchors.topMargin: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 12 : 52

            ThemedButton {
                id: buttonDone
                width: 96
                height: 32
                text: qsTr("Month")
                font.pointSize: 14
                selected: (graphMode === "monthly")

                onClicked: {
                    graphMode = "monthly"
                    updateDatas()
                }
            }

            ThemedButton {
                id: buttonDone1
                width: 96
                height: 32
                text: qsTr("Week")
                font.pointSize: 14
                selected: (graphMode === "weekly")

                onClicked: {
                    graphMode = "weekly"
                    updateDatas()
                }
            }

            ThemedButton {
                id: buttonDone2
                width: 96
                height: 32
                text: qsTr("Day")
                font.pointSize: 14
                selected: (graphMode === "daily")

                onClicked: {
                    graphMode = "daily"
                    updateDatas()
                }
            }
        }

        Text {
            id: textDeviceName
            height: 32
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12

            visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

            font.pixelSize: 24
            text: myDevice.deviceName
            verticalAlignment: Text.AlignVCenter
            font.capitalization: Font.AllUppercase
            color: Theme.colorText

            ImageSvg {
                id: imageBattery
                width: 32
                height: 32
                rotation: 90
                anchors.verticalCenter: textDeviceName.verticalCenter
                anchors.left: textDeviceName.right
                anchors.leftMargin: 16

                source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                color: Theme.colorIcons
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    property int graphHeight: 256
    property int graphCount: 4

    Column {
        id: column
        clip: true

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        onHeightChanged: {
            graphHeight = (height - graphCount*hygroLegend.height) / graphCount
        }

        Text {
            id: hygroLegend
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: "Hygrometry"
            color: Theme.colorIcons
            font.bold: true
            font.pointSize: 16
        }
        ItemBarCharts {
            id: hygroGraph
            height: graphHeight
            graphDataSelected: "hygro"
            graphViewSelected: graphMode
        }

        Text {
            id: tempLegend
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: qsTr("Temperature")
            color: Theme.colorIcons
            font.bold: true
            font.pointSize: 16
        }
        ItemBarCharts {
            id: tempGraph
            height: graphHeight
            graphDataSelected: "temp"
            graphViewSelected: graphMode
        }

        Text {
            id: lumiLegend
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: qsTr("Luminosity")
            color: Theme.colorIcons
            font.bold: true
            font.pointSize: 16
        }
        ItemBarCharts {
            id: lumiGraph
            height: graphHeight
            graphDataSelected: "luminosity"
            graphViewSelected: graphMode
        }

        Text {
            id: conduLegend
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: qsTr("Conductivity")
            color: Theme.colorIcons
            font.bold: true
            font.pointSize: 16
        }
        ItemBarCharts {
            id: conduGraph
            height: graphHeight
            graphDataSelected: "conductivity"
            graphViewSelected: graphMode
        }
    }
}
