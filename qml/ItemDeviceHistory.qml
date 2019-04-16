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

// Qt 5.10 needed here...
// You can change v2.2 into 2.1 but you'll need to comment the
// ChartView / "legend.visible" line at the bottom of this file
import QtCharts 2.2

import com.watchflower.theme 1.0

Item {
    id: deviceDatas
    width: 400
    height: 300

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
        height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 48 : 76

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Column {
            id: plantPanel
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.left: parent.left

            Text {
                id: textDeviceName
                height: 32
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

            Item {
                id: status
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelStatus
                    width: 72
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Status")
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }
                Text {
                    id: textStatus
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelStatus.right
                    anchors.leftMargin: 12

                    text: qsTr("Loading...")
                    color: Theme.colorText
                    font.pixelSize: 16
                }
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
            graphViewSelected: "monthly"
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
            graphViewSelected: "monthly"
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
            graphViewSelected: "monthly"
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
            graphViewSelected: "monthly"
        }
    }
}
