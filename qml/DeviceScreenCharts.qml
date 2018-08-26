/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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

import QtQuick 2.7

// Qt 5.10 needed here...
// You can change v2.2 into 2.1 but you'll need to comment the
// ChartView / "legend.visible" line at the bottom of this file
import QtCharts 2.2

Rectangle {
    id: deviceScreenCharts
    color: "#000000ff"
    width: parent.width
    anchors.margins: 0

    property string graphViewSelected: settingsManager.graphview
    property string graphDataSelected: settingsManager.graphdata

    Rectangle {
        id: rectangleSettings
        width: parent.width
        height: 32

        anchors.bottom: parent.bottom

        Rectangle {
            id: rectangleSettingsDatas
            width: parent.width * 0.70
            height: parent.height
            color: "#f2f2f2"

            Rectangle {
                id: dH
                width: parent.width / 4
                height: parent.height
                anchors.left: parent.left
                color: "#f2f2f2"

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
                color: "#f2f2f2"

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
                color: "#f2f2f2"

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
                color: "#f2f2f2"

                Text {
                    id: textCondu
                    x: 26
                    y: 9
                    text: qsTr("Condu")
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
            color: "#e8e9e8"

            Rectangle {
                id: rectangleDays
                width: parent.width * 0.5
                height: parent.height
                anchors.top: parent.top
                anchors.left: parent.left
                color: "#e8e9e8"

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
                color: "#e8e9e8"

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

    function updateGraph() {

        if ((myDevice.deviceCapabilities & 2) == 0) {
            dT.visible = false
        }
        if ((myDevice.deviceCapabilities & 4) == 0) {
            dH.visible = false
        }
        if ((myDevice.deviceCapabilities & 8) == 0) {
            dL.visible = false
        }
        if ((myDevice.deviceCapabilities & 16) == 0) {
            dC.visible = false
        }

        lowLimitSeries.clear()
        highLimitSeries.clear()

        if (graphDataSelected == "hygro") {
            axisY0.max = 66
            myBarSet.color = "#31a3ec"
            textHygro.font.bold = true
            textTemp.font.bold = false
            textLumi.font.bold = false
            textCondu.font.bold = false
            lowLimitSeries.append(0, myDevice.limitHygroMin);
            lowLimitSeries.append(1, myDevice.limitHygroMin);
            highLimitSeries.append(0, myDevice.limitHygroMax);
            highLimitSeries.append(1, myDevice.limitHygroMax);
        } else if (graphDataSelected == "temp") {
            axisY0.max = 40
            myBarSet.color = "#87d241"
            textHygro.font.bold = false
            textTemp.font.bold = true
            textLumi.font.bold = false
            textCondu.font.bold = false
            lowLimitSeries.append(0, myDevice.limitTempMin);
            lowLimitSeries.append(1, myDevice.limitTempMin);
            highLimitSeries.append(0, myDevice.limitTempMax);
            highLimitSeries.append(1, myDevice.limitTempMax);
        } else if (graphDataSelected == "luminosity") {
            axisY0.max = 2000
            myBarSet.color = "#f1ec5c"
            textHygro.font.bold = false
            textTemp.font.bold = false
            textLumi.font.bold = true
            textCondu.font.bold = false
            lowLimitSeries.append(0, myDevice.limitLumiMin);
            lowLimitSeries.append(1, myDevice.limitLumiMin);
            highLimitSeries.append(0, myDevice.limitLumiMax);
            highLimitSeries.append(1, myDevice.limitLumiMax);
        } else if (graphDataSelected == "conductivity") {
            axisY0.max = 750
            myBarSet.color = "#e19c2f"
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
        if (graphViewSelected == "hourly") {
            myBarSeries.barWidth = 0.90
            axisX0.categories = myDevice.getHours()
            myBarSet.values = myDevice.getDatasHourly(graphDataSelected)
        } else {
            myBarSeries.barWidth = 0.70
            axisX0.categories = myDevice.getDays()
            myBarSet.values = myDevice.getDatasDaily(graphDataSelected)
        }

        // Min axis
        //var min_of_array = Math.min.apply(Math, myBarSet.values);
        axisY0.min = 0;

        // Max axis
        var max_of_array = Math.max.apply(Math, myBarSet.values);
        var max_of_legend = max_of_array*1.20;
        if (graphDataSelected == "hygro" && max_of_legend > 100.0) {
            max_of_legend = 100.0; // no need to go higher than 100% hygrometry
        }
        axisY0.max = max_of_legend;

        // Decorations
        if (graphViewSelected == "hourly") {
            textDays.font.bold = false
            textHours.font.bold = true
            backgroundDayBars.color = "#F5F5F5"
            backgroundDayBars.values = myDevice.getBackgroundHourly(max_of_legend)
            backgroundNightBars.color = "#E4E4E4"
            backgroundNightBars.values = myDevice.getBackgroundNightly(max_of_legend)
        } else {
            textDays.font.bold = true
            textHours.font.bold = false
            backgroundDayBars.color = "#F5F5F5"
            backgroundDayBars.values = myDevice.getBackgroundDaily(max_of_legend)
            backgroundNightBars.values = [0]
        }
    }

    ChartView {
        id: myBarGraph
        z: -1 // so the graph, overlapping with buttons, doesn't prevent clicks
        anchors.top: parent.top
        anchors.bottom: rectangleSettings.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: -20
        anchors.bottomMargin: -16
        anchors.leftMargin: -20
        anchors.rightMargin: -20

        antialiasing: true
        legend.visible: false // this will only work with Qt 5.10+
        backgroundRoundness: 0
        backgroundColor: "#000000ff"

        //animationOptions: ChartView.SeriesAnimations
        //theme: ChartView.ChartThemeBrownSand

        Component.onCompleted: updateGraph()

        StackedBarSeries {
            id: myBarSeries
            barWidth: 0.90
            labelsVisible: false

            axisY: ValueAxis { id: axisY0; visible: false; gridVisible: false; }
            axisX: BarCategoryAxis { id: axisX0; visible:true; gridVisible: false; labelsFont.pixelSize: 12; }

            BarSet { id: myBarSet; }
            BarSet { id: backgroundDayBars; }
            BarSet { id: backgroundNightBars; }
        }

        LineSeries {
            id: lowLimitSeries
            color: badColor
            width: 2
            axisX: ValueAxis { visible:false; }
            visible:false
        }
        LineSeries {
            id: highLimitSeries
            color: badColor
            width: 2
            axisX: ValueAxis { visible:false; }
            visible:false
        }
    }
}
