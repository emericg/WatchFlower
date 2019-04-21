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
import QtQuick.Layouts 1.12
import QtQuick.Window 2.2

import com.watchflower.theme 1.0

Item {
    id: deviceDatas
    width: 400
    height: 300

    property string graphMode: settingsManager.graphview

    function updateHeader() {
        if (typeof myDevice === "undefined") return

        // Sensor battery level
        if (myDevice.hasBatteryLevel()) {
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

        if (myDevice.hasTemperatureSensor()) {
            tempGraph.visible = true
            tempGraph.loadGraph()
            graphCount += 1
        } else {
            tempGraph.visible = false
        }
        if (myDevice.hasHygrometrySensor())  {
            if (myDevice.deviceHygro > 0 || myDevice.countDatas("hygro") > 0) {
                hygroGraph.visible = true
                hygroGraph.loadGraph()
                graphCount += 1
            } else  {
                hygroGraph.visible = false
            }
        } else {
            hygroGraph.visible = false
        }
        if (myDevice.hasLuminositySensor()) {
            lumiGraph.visible = true
            lumiGraph.loadGraph()
            graphCount += 1
        } else {
            lumiGraph.visible = false
        }
        if (myDevice.hasConductivitySensor())  {
            if (myDevice.deviceConductivity > 0 || myDevice.countDatas("conductivity") > 0) {
                conduGraph.visible = true
                conduGraph.loadGraph()
                graphCount += 1
            } else  {
                conduGraph.visible = false
            }
        } else {
            conduGraph.visible = false
        }

        updateSize()

        updateDatas()
    }

    function updateSize() {
        //console.log("width: " + graphGrid.width)
        //console.log("height: " + graphGrid.height)

        if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
            if (Screen.primaryOrientation === 1 /*Qt::PortraitOrientation*/)
                graphGrid.columns = 1
            else
                graphGrid.columns = 2
        } else {
            if (graphGrid.width < 1080)
                graphGrid.columns = 1
            else
                graphGrid.columns = 2
        }

        graphWidth = (graphGrid.width) / graphGrid.columns
        graphHeight = (graphGrid.height) / (graphCount / graphGrid.columns)
    }

    function updateDatas() {
        if (typeof myDevice === 'undefined' || !myDevice) return
        //console.log("ItemDeviceHistory // updateDatas() >> " + myDevice)

        if (myDevice.hasTemperatureSensor()) {
            tempGraph.updateGraph()
        }
        if (myDevice.hasHygrometrySensor()) {
            hygroGraph.updateGraph()
        }
        if (myDevice.hasLuminositySensor()) {
            lumiGraph.updateGraph()
        }
        if (myDevice.hasConductivitySensor()) {
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
    property int graphWidth: 256
    property int graphCount: 4

    Grid {
        id: graphGrid
        clip: true
        columns: 1

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        onColumnsChanged: updateSize()
        onWidthChanged: updateSize()
        onHeightChanged: updateSize()

        ItemDataChart {
            id: hygroGraph
            height: graphHeight
            width: graphWidth
            graphDataSelected: "hygro"
            graphViewSelected: graphMode

            Text {
                id: hygroLegend
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: "Hygrometry"
                color: Theme.colorIcons
                font.bold: false
                font.pointSize: 16
            }
        }

        ItemDataChart {
            id: tempGraph
            height: graphHeight
            width: graphWidth
            graphDataSelected: "temp"
            graphViewSelected: graphMode

            Text {
                id: tempLegend
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: qsTr("Temperature")
                color: Theme.colorIcons
                font.bold: false
                font.pointSize: 16
            }
        }

        ItemDataChart {
            id: lumiGraph
            height: graphHeight
            width: graphWidth
            graphDataSelected: "luminosity"
            graphViewSelected: graphMode

            Text {
                id: lumiLegend
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: qsTr("Luminosity")
                color: Theme.colorIcons
                font.bold: false
                font.pointSize: 16
            }
        }

        ItemDataChart {
            id: conduGraph
            height: graphHeight
            width: graphWidth
            graphDataSelected: "conductivity"
            graphViewSelected: graphMode

            Text {
                id: conduLegend
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: qsTr("Conductivity")
                color: Theme.colorIcons
                font.bold: false
                font.pointSize: 16
            }
        }
    }
}
