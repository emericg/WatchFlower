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

import QtQuick 2.9

// Qt 5.10 needed here...
// You can change v2.2 into 2.1 but you'll need to comment the
// ChartView / "legend.visible" line at the bottom of this file
import QtCharts 2.2

import com.watchflower.theme 1.0

Item {
    id: deviceScreenBarCharts
    width: parent.width
    anchors.margins: 0

    property string graphViewSelected: settingsManager.graphHistory
    property string graphDataSelected: "hygro"

    property string bgDayGraphColor: "#F1F1F1"
    property string bgNightGraphColor: "#E1E1E1"

    property string buttonLightColor: "#F0F0F0"
    property string buttonDarkColor: "#E5E5E5"

    function loadGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreenBarCharts // loadGraph() >> " + myDevice)

        graphViewSelected = settingsManager.graphHistory
        graphDataSelected = "hygro"
        if (graphDataSelected === "hygro") {
            if (myDevice.deviceName === "MJ_HT_V1")
                graphDataSelected = "temp"
            else if (myDevice.deviceHygro <= 0 && myDevice.deviceConductivity <= 0)
                graphDataSelected = "temp"
        }

        dT.visible = myDevice.hasTemperatureSensor()
        dH.visible = myDevice.hasHygrometrySensor()
        dL.visible = myDevice.hasLuminositySensor()
        dC.visible = myDevice.hasConductivitySensor()
    }

    function updateGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return

        //console.log("DeviceScreenBarCharts // updateGraph() >> " + myDevice)

        lowLimitSeries.clear()
        highLimitSeries.clear()

        if (graphDataSelected === "hygro") {
            axisY0.max = 66
            myBarSet.color = Theme.colorBlue
            textHygro.font.bold = true
            textTemp.font.bold = false
            textLumi.font.bold = false
            textCondu.font.bold = false
            lowLimitSeries.append(0, myDevice.limitHygroMin);
            lowLimitSeries.append(1, myDevice.limitHygroMin);
            highLimitSeries.append(0, myDevice.limitHygroMax);
            highLimitSeries.append(1, myDevice.limitHygroMax);
        } else if (graphDataSelected === "temp") {
            axisY0.max = 40
            myBarSet.color = Theme.colorGreen
            textHygro.font.bold = false
            textTemp.font.bold = true
            textLumi.font.bold = false
            textCondu.font.bold = false
            lowLimitSeries.append(0, myDevice.limitTempMin);
            lowLimitSeries.append(1, myDevice.limitTempMin);
            highLimitSeries.append(0, myDevice.limitTempMax);
            highLimitSeries.append(1, myDevice.limitTempMax);
        } else if (graphDataSelected === "luminosity") {
            axisY0.max = 2000
            myBarSet.color = Theme.colorYellow
            textHygro.font.bold = false
            textTemp.font.bold = false
            textLumi.font.bold = true
            textCondu.font.bold = false
            lowLimitSeries.append(0, myDevice.limitLumiMin);
            lowLimitSeries.append(1, myDevice.limitLumiMin);
            highLimitSeries.append(0, myDevice.limitLumiMax);
            highLimitSeries.append(1, myDevice.limitLumiMax);
        } else if (graphDataSelected === "conductivity") {
            axisY0.max = 750
            myBarSet.color = Theme.colorRed
            textHygro.font.bold = false
            textTemp.font.bold = false
            textLumi.font.bold = false
            textCondu.font.bold = true
            lowLimitSeries.append(0, myDevice.limitConduMin);
            lowLimitSeries.append(1, myDevice.limitConduMin);
            highLimitSeries.append(0, myDevice.limitConduMax);
            highLimitSeries.append(1, myDevice.limitConduMax);
        }

        // Get datas
        if (graphViewSelected === "hourly") {
            myBarSeries.barWidth = 0.90
            axisX0.categories = myDevice.getHours()
            myBarSet.values = myDevice.getDatasHourly(graphDataSelected)
        } else {
            if (graphViewSelected === "daily")
                myBarSeries.barWidth = 0.80
            else
                myBarSeries.barWidth = 0.90
            axisX0.categories = myDevice.getDays()
            myBarSet.values = myDevice.getDatasDaily(graphDataSelected)
        }

        // Min axis
        //var min_of_array = Math.min.apply(Math, myBarSet.values);
        axisY0.min = 0;

        // Max axis
        var max_of_array = Math.max.apply(Math, myBarSet.values);
        var max_of_legend = max_of_array*1.20;
        if (graphDataSelected === "hygro" && max_of_legend > 100.0) {
            max_of_legend = 100.0; // no need to go higher than 100% hygrometry
        }
        axisY0.max = max_of_legend;

        // Decorations
        if (graphViewSelected === "hourly") {
            textDays.font.bold = false
            textHours.font.bold = true
            backgroundDayBars.color = bgDayGraphColor
            backgroundDayBars.values = myDevice.getBackgroundHourly(max_of_legend)
            backgroundNightBars.color = bgNightGraphColor
            backgroundNightBars.values = myDevice.getBackgroundNightly(max_of_legend)
        } else {
            textDays.font.bold = true
            textHours.font.bold = false
            backgroundDayBars.color = bgDayGraphColor
            backgroundDayBars.values = myDevice.getBackgroundDaily(max_of_legend)
            backgroundNightBars.values = [0]
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleSettings
        width: parent.width
        height: 32
        anchors.bottom: parent.bottom
        z: 1 // so the graph, overlapping with buttons, doesn't prevent clicks

        Rectangle {
            id: rectangleSettingsDatas
            width: parent.width * 0.70
            height: parent.height
            color: buttonLightColor

            Rectangle {
                id: dH
                width: parent.width / 4
                height: parent.height
                anchors.left: parent.left
                color: buttonLightColor

                Text {
                    id: textHygro
                    x: 21
                    y: 9
                    text: qsTr("Hygro")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphDataSelected = "hygro"
                        updateGraph()
                    }
                }
            }
            Rectangle {
                id: dT
                width: parent.width / 4
                height: parent.height
                anchors.left: dH.right
                color: buttonLightColor

                Text {
                    id: textTemp
                    x: 21
                    y: 9
                    text: qsTr("Temp")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphDataSelected = "temp"
                        updateGraph()
                    }
                }
            }
            Rectangle {
                id: dL
                width: parent.width / 4
                height: parent.height
                anchors.left: dT.right
                color: buttonLightColor

                Text {
                    id: textLumi
                    x: 27
                    y: 9
                    text: qsTr("Lumi")
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphDataSelected = "luminosity"
                        updateGraph()
                    }
                }
            }
            Rectangle {
                id: dC
                width: parent.width / 4
                height: parent.height
                anchors.left: dL.right
                color: buttonLightColor

                Text {
                    id: textCondu
                    x: 26
                    y: 9
                    text: qsTr("Fertility")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphDataSelected = "conductivity"
                        updateGraph()
                    }
                }
            }
        }

        Rectangle {
            id: rectangleSettingsMode
            width: parent.width * 0.30
            height: parent.height
            anchors.left: rectangleSettingsDatas.right
            color: buttonDarkColor

            Rectangle {
                id: rectangleDays
                width: parent.width * 0.5
                height: parent.height
                anchors.top: parent.top
                anchors.left: parent.left
                color: buttonDarkColor

                Text {
                    id: textDays
                    x: 19
                    y: 9
                    text: qsTr("Days")
                    verticalAlignment: Text.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphViewSelected = "daily"
                        updateGraph()
                    }
                }
            }

            Rectangle {
                id: rectangleHours
                width: parent.width * 0.5
                height: parent.height
                anchors.top: parent.top
                anchors.right: parent.right
                color: buttonDarkColor

                Text {
                    id: textHours
                    x: 11
                    y: 9
                    text: qsTr("Hours")
                    verticalAlignment: Text.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphViewSelected = "hourly"
                        updateGraph()
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ChartView {
        id: myBarGraph
        anchors.top: parent.top
        anchors.bottom: rectangleSettings.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: -20
        anchors.bottomMargin: -20
        anchors.leftMargin: -20
        anchors.rightMargin: -20

        antialiasing: true
        legend.visible: false // this will only work with Qt 5.10+
        backgroundRoundness: 0
        backgroundColor: "transparent"

        //animationOptions: ChartView.SeriesAnimations

        StackedBarSeries {
            id: myBarSeries
            barWidth: 0.90
            labelsVisible: false

            axisY: ValueAxis { id: axisY0; visible: false; gridVisible: false; }
            axisX: BarCategoryAxis { id: axisX0; visible: true; gridVisible: false; labelsFont.pixelSize: 12; }

            BarSet { id: myBarSet; }
            BarSet { id: backgroundDayBars; }
            BarSet { id: backgroundNightBars; }
        }

        LineSeries {
            id: lowLimitSeries
            color: Theme.colorBad
            width: 2
            axisX: ValueAxis { visible:false; }
            visible:false
        }
        LineSeries {
            id: highLimitSeries
            color: Theme.colorBad
            width: 2
            axisX: ValueAxis { visible:false; }
            visible:false
        }
    }
}
