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
import QtQuick.Layouts 1.12

import ThemeEngine 1.0

Item {
    id: deviceScreenHistory
    width: 400
    height: 300

    property string graphMode: settingsManager.graphHistory

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("DeviceScreenHistory // updateHeader() >> " + currentDevice)

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
    }

    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
/*
        console.log("DeviceScreenHistory // loadData() >> " + currentDevice)

        console.log("hasSoilMoistureSensor(): " + currentDevice.hasSoilMoistureSensor())
        console.log("hasSoilConductivitySensor(): " + currentDevice.hasSoilConductivitySensor())
        console.log("hasSoilTemperatureSensor(): " + currentDevice.hasSoilTemperatureSensor())
        console.log("hasTemperatureSensor(): " + currentDevice.hasTemperatureSensor())
        console.log("hasHumiditySensor(): " + currentDevice.hasHumiditySensor())
        console.log("hasLuminositySensor(): " + currentDevice.hasLuminositySensor())

        console.log("hasData(soilMoisture): " + currentDevice.hasData("soilMoisture"))
        console.log("hasData(soilConductivity): " + currentDevice.hasData("soilConductivity"))
        console.log("hasData(soilTemperature): " + currentDevice.hasData("soilTemperature"))
        console.log("hasData(temperature): " + currentDevice.hasData("temperature"))
        console.log("hasData(humidity): " + currentDevice.hasData("humidity"))
        console.log("hasData(luminosity): " + currentDevice.hasData("luminosity"))
*/
        graphCount = 0

        if (currentDevice.hasTemperatureSensor()) {
            tempGraph.visible = true
            tempGraph.loadGraph()
            graphCount += 1
        } else {
            tempGraph.visible = false
        }
        if (currentDevice.hasHumiditySensor() || currentDevice.hasSoilMoistureSensor()) {
            if (currentDevice.deviceSoilMoisture > 0 || currentDevice.countData("soilMoisture") > 0) {
                hygroGraph.visible = true
                hygroGraph.loadGraph()
                graphCount += 1
            } else {
                hygroGraph.visible = false
            }
        } else {
            hygroGraph.visible = false
        }
        if (currentDevice.hasLuminositySensor()) {
            lumiGraph.visible = true
            lumiGraph.loadGraph()
            graphCount += 1
        } else {
            lumiGraph.visible = false
        }
        if (currentDevice.hasSoilConductivitySensor()) {
            if (currentDevice.deviceSoilConductivity > 0 || currentDevice.countData("soilConductivity") > 0) {
                conduGraph.visible = true
                conduGraph.loadGraph()
                graphCount += 1
            } else {
                conduGraph.visible = false
            }
        } else {
            conduGraph.visible = false
        }

        updateSize()
        updateData()
    }

    function updateColors() {
        tempGraph.updateColors()
        hygroGraph.updateColors()
        lumiGraph.updateColors()
        conduGraph.updateColors()
    }

    function updateSize() {
        //console.log("width: " + graphGrid.width)
        //console.log("height: " + graphGrid.height)

        if (isMobile) {
            if (isPhone) {
                if (screenOrientation === Qt.PortraitOrientation) {
                    graphGrid.columns = 1
                    rectangleHeader.visible = true
                    rectangleHeader.height = 48
                } else {
                    graphGrid.columns = 2
                    rectangleHeader.visible = false
                    rectangleHeader.height = 0
                }
            }
            if (isTablet) {
                if (screenOrientation === Qt.PortraitOrientation || width < 480) {
                    graphGrid.columns = 1
                } else {
                    graphGrid.columns = 2
                }
            }
        } else {
            if (graphGrid.width < 1080) {
                graphGrid.columns = 1
            } else {
                graphGrid.columns = 2
            }
            if (graphGrid.width < 575) {
                buttonPanel.anchors.topMargin = 52
                buttonPanel.anchors.rightMargin = 0
                buttonPanel.anchors.right = undefined
                buttonPanel.anchors.horizontalCenter = rectangleHeader.horizontalCenter
                rectangleHeader.height = 96
            } else {
                buttonPanel.anchors.topMargin = 8
                buttonPanel.anchors.rightMargin = 8
                buttonPanel.anchors.horizontalCenter = undefined
                buttonPanel.anchors.right = rectangleHeader.right
                rectangleHeader.height = 48
            }
        }

        graphWidth = (graphGrid.width) / graphGrid.columns
        graphHeight = (graphGrid.height) / Math.ceil(graphCount / graphGrid.columns)

        if (graphCount === 3 && graphGrid.columns === 2) {
            if (currentDevice.hasSoilMoistureSensor() && currentDevice.hasData("soilMoisture")) {
                hygroGraph.width = (graphWidth*2)
                lumiGraph.width = graphWidth
            } else if (currentDevice.hasLuminositySensor() && currentDevice.hasData("luminosity")) {
                hygroGraph.width = graphWidth
                lumiGraph.width = (graphWidth*2)
            }
        } else {
            hygroGraph.width = graphWidth
            lumiGraph.width = graphWidth
        }
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("ItemDeviceHistory // updateData() >> " + currentDevice)

        if (currentDevice.hasTemperatureSensor()) { tempGraph.updateGraph() }
        if (currentDevice.hasHumiditySensor() || currentDevice.hasSoilMoistureSensor()) { hygroGraph.updateGraph() }
        if (currentDevice.hasLuminositySensor()) { lumiGraph.updateGraph() }
        if (currentDevice.hasSoilConductivitySensor()) { conduGraph.updateGraph() }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: Theme.colorForeground
        height: isMobile ? 48 : 96
        z: 5

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Row {
            id: buttonPanel
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            anchors.top: parent.top
            anchors.topMargin: isMobile ? 8 : 52

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (graphMode === "monthly")
                primaryColor: fullColor ? Theme.colorPrimary : Theme.colorHeaderHighlight
                secondaryColor: Theme.colorBackground

                text: qsTr("Month")
                onClicked: {
                    settingsManager.graphHistory = "monthly"
                    updateData()
                }
            }

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (graphMode === "weekly")
                primaryColor: fullColor ? Theme.colorPrimary : Theme.colorHeaderHighlight
                secondaryColor: Theme.colorBackground

                text: qsTr("Week")
                onClicked: {
                    settingsManager.graphHistory = "weekly"
                    updateData()
                }
            }

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (graphMode === "daily")
                primaryColor: fullColor ? Theme.colorPrimary : Theme.colorHeaderHighlight
                secondaryColor: Theme.colorBackground

                text: qsTr("Day")
                onClicked: {
                    settingsManager.graphHistory = "daily"
                    updateData()
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
    }

    ////////////////////////////////////////////////////////////////////////////

    property int graphHeight: 256
    property int graphWidth: 256
    property int graphCount: 4

    Flow {
        id: graphGrid
        property var columns: 1

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        onWidthChanged: updateSize()
        onHeightChanged: updateSize()

        ItemDataChart {
            id: hygroGraph
            height: graphHeight
            width: graphWidth
            graphDataSelected: "soilMoisture"
            graphViewSelected: graphMode

            Text {
                id: hygroLegend
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: qsTr("Moisture")
                color: Theme.colorIcon
                font.bold: true
                font.pixelSize: 14
                font.capitalization: Font.AllUppercase
            }
        }

        ItemDataChart {
            id: tempGraph
            height: graphHeight
            width: graphWidth
            graphDataSelected: "temperature"
            graphViewSelected: graphMode

            Text {
                id: tempLegend
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: qsTr("Temperature")
                color: Theme.colorIcon
                font.bold: true
                font.pixelSize: 14
                font.capitalization: Font.AllUppercase
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
                color: Theme.colorIcon
                font.bold: true
                font.pixelSize: 14
                font.capitalization: Font.AllUppercase
            }
        }

        ItemDataChart {
            id: conduGraph
            height: graphHeight
            width: graphWidth
            graphDataSelected: "soilConductivity"
            graphViewSelected: graphMode

            Text {
                id: conduLegend
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: qsTr("Fertility")
                color: Theme.colorIcon
                font.bold: true
                font.pixelSize: 14
                font.capitalization: Font.AllUppercase
            }
        }
    }
}
