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
import QtCharts 2.2 // Qt 5.10 needed here...

// You can change v2.2 into 2.1 but you'll need to comment the
// ChartView / "legend.visible" line at the bottom of this file

Rectangle {
    id: chartBox
    //color: "red" // FIXME too much borders !!!

    property string graphViewSelected: settingsManager.graphview
    property string graphDataSelected: settingsManager.graphdata

    width: parent.width
    anchors.margins: 0

    Connections {
        target: myDevice
        onDatasUpdated: updateGraph()
    }

    Rectangle {
        id: rectangleSettings
        width: parent.width
        height: 32

        anchors.bottom: parent.bottom

        Rectangle {
            id: rectangleSettingsDatas
            width: parent.width * 0.70
            height: parent.height

            Rectangle {
                id: dH
                color: "#f2f2f2"
                width: parent.width / 4
                height: parent.height
                anchors.left: parent.left

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
                color: "#f2f2f2"
                width: parent.width / 4
                height: parent.height
                anchors.left: dH.right

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
                color: "#f2f2f2"
                width: parent.width / 4
                height: parent.height
                anchors.left: dT.right

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
                color: "#f2f2f2"
                width: parent.width / 4
                height: parent.height
                anchors.left: dL.right

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

            Rectangle {
                id: rectangleDays
                width: parent.width * 0.5
                height: parent.height
                color: "#e8e9e8"

                anchors.top: parent.top
                anchors.left: parent.left

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
                color: "#e8e9e8"

                anchors.top: parent.top
                anchors.right: parent.right

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

        if (graphViewSelected == "hourly") {
            textDays.font.bold = false
            textHours.font.bold = true

            axisX0.categories = myDevice.getHours()
            myBarSet.values = myDevice.getDatasHourly(graphDataSelected)

            backgroundDayBars.color = "#f9f9f9"
            backgroundDayBars.values = myDevice.getBackgroundHourly()
            backgroundNightBars.color = "#E4E4E4"
            backgroundNightBars.values = myDevice.getBackgroundNightly()
        } else {
            textDays.font.bold = true
            textHours.font.bold = false

            axisX0.categories = myDevice.getDays()
            myBarSet.values = myDevice.getDatasDaily(graphDataSelected)

            backgroundDayBars.color = "#f9f9f9"
            backgroundDayBars.values = [30000, 30000, 30000, 30000, 30000, 30000, 30000]
            backgroundNightBars.values = [0]
        }

        // Min axis
        //var min_of_array = Math.min.apply(Math, myBarSet.values);
        axisY0.min = 0;

        // Max axis
        var max_of_array = Math.max.apply(Math, myBarSet.values);
        axisY0.max = max_of_array*1.20;
    }

    ChartView {
        id: myBarGraph
        anchors.top: parent.top
        anchors.bottom: rectangleSettings.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: -12
        anchors.bottomMargin: -8
        anchors.leftMargin: -16
        anchors.rightMargin: -16

        antialiasing: true
        legend.visible: false // this will only work with Qt 5.10+
        backgroundRoundness: 0

        Component.onCompleted: updateGraph()

        //animationOptions: ChartView.SeriesAnimations
        //theme: ChartView.ChartThemeBrownSand

        StackedBarSeries {
            id: myBarSeries
            barWidth: 0.90
            labelsVisible: false

            axisY: ValueAxis { id: axisY0; visible: true; max: 40; gridVisible: false; }
            axisX: BarCategoryAxis { id: axisX0; visible:true; gridVisible: true; }

            BarSet { id: myBarSet; }
            BarSet { id: backgroundDayBars; }
            BarSet { id: backgroundNightBars; }
        }

        LineSeries {
            id: lowLimitSeries
            color: "#ffbf66"
            width: 2
            axisX: ValueAxis { visible:false; }
            visible:false
        }
        LineSeries {
            id: highLimitSeries
            color: "#ffbf66"
            width: 2
            axisX: ValueAxis { visible:false; }
            visible:false
        }
    }
}
