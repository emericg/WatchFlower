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

// Qt 5.10 needed here...
import QtQuick 2.10
import QtCharts 2.2

Rectangle {
    id: chartBox
    //color: "red" // FIXME too much borders !!!

    property string graphDataSelected: "temp"
    property string graphModeSelected: "weekly"

    width: parent.width
    anchors.margins: 0

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
                id: dT
                color: "#f2f2f2"
                width: parent.width / 4
                height: parent.height
                anchors.left: parent.left

                Text {
                    id: textTemp
                    x: 21
                    y: 9
                    text: qsTr("Temp")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphDataSelected = "temp"
                        textTemp.font.bold = true
                        textHygro.font.bold = false
                        textLumi.font.bold = false
                        textCondu.font.bold = false

                        updateGraph()
                    }
                }
            }
            Rectangle {
                id: dH
                color: "#f2f2f2"
                width: parent.width / 4
                height: parent.height
                anchors.left: dT.right

                Text {
                    id: textHygro
                    x: 21
                    y: 9
                    text: qsTr("Hygro")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        graphDataSelected = "hygro"
                        textTemp.font.bold = false
                        textHygro.font.bold = true
                        textLumi.font.bold = false
                        textCondu.font.bold = false

                        updateGraph()
                    }
                }
            }
            Rectangle {
                id: dL
                color: "#f2f2f2"
                width: parent.width / 4
                height: parent.height
                anchors.left: dH.right

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
                        textTemp.font.bold = false
                        textHygro.font.bold = false
                        textLumi.font.bold = true
                        textCondu.font.bold = false

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
                        textTemp.font.bold = false
                        textHygro.font.bold = false
                        textLumi.font.bold = false
                        textCondu.font.bold = true

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
                        graphModeSelected = "daily"
                        textDays.font.bold = true
                        textHours.font.bold = false

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
                        graphModeSelected = "hourly"
                        textDays.font.bold = false
                        textHours.font.bold = true

                        updateGraph()
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    function updateGraph() {
        //axisY0.tickCount = 1
        //myBarSet.at(myBarSet.count-1).y
        //console.log("myAxisY.max=", myAxisY.max);
        /// min:  Math.floor(((minCategory + sb.position *
        //                   (maxCategory - minCategory - category)) + 9)/10)*10

        if (graphDataSelected == "temp") {
            axisY0.min = 0
            axisY0.max = 40
            myBarSet.color = "#87d241"
        } else if (graphDataSelected == "hygro") {
            axisY0.min = 0
            axisY0.max = 75
            myBarSet.color = "#31a3ec"
        } else if (graphDataSelected == "luminosity") {
            axisY0.min = 0
            axisY0.max = 3000
            myBarSet.color = "#f1ec5c"
        } else if (graphDataSelected == "conductivity") {
            axisY0.min = 0
            axisY0.max = 1000
            myBarSet.color = "#e19c2f"
        }

        if (graphModeSelected == "daily")
        {
            axisX0.categories = myDevice.getDays()
            myBarSet.values = myDevice.getDatasDaily(graphDataSelected)
        }
        else if (graphModeSelected == "hourly")
        {
            axisX0.categories = myDevice.getHours()
            myBarSet.values = myDevice.getDatasHourly(graphDataSelected)
        }
    }

    ChartView {
        id: myBarGraph
        anchors.top: parent.top
        anchors.bottom: rectangleSettings.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: -16
        anchors.bottomMargin: -8
        anchors.leftMargin: -16
        anchors.rightMargin: -16

        antialiasing: true
        legend.visible: false
        backgroundRoundness: 0

        //animationOptions: ChartView.SeriesAnimations
        //theme: ChartView.ChartThemeBrownSand

        BarSeries {
            id: myBarSeries

            barWidth: 0.9
            labelsVisible: false

            axisY: ValueAxis { id: axisY0; max: 40; visible: true; }
            axisX: BarCategoryAxis { id: axisX0; visible:true; categories: myDevice.getDays(); }

            BarSet {
                id: myBarSet
                color: "#87d241"
                values: myDevice.getDatasDaily("temp")
            }
        }
    }
}
