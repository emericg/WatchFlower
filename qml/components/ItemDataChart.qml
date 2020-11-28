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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.12
import QtCharts 2.3

import ThemeEngine 1.0

Item {
    id: itemDataCharts
    width: parent.width
    anchors.margins: 0

    property string graphViewSelected
    property string graphDataSelected

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("itemDataCharts // loadGraph() >> " + currentDevice)

        axisY0.min = 0;
        if (graphDataSelected === "soilMoisture") {
            axisY0.max = 66
            myBarSet.color = Theme.colorBlue
        } else if (graphDataSelected === "soilConductivity") {
            axisY0.max = 2000
            myBarSet.color = Theme.colorRed
        } if (graphDataSelected === "soilTemperature") {
            axisY0.max = 40
            myBarSet.color = Theme.colorGreen
        } else if (graphDataSelected === "temperature") {
            axisY0.max = 40
            myBarSet.color = Theme.colorGreen
        }  else if (graphDataSelected === "humidity") {
            axisY0.max = 100
            myBarSet.color = Theme.colorBlue
        } else if (graphDataSelected === "luminosity") {
            axisY0.max = 3000
            myBarSet.color = Theme.colorYellow
        }
        myBarSet.borderColor = "transparent"

        loadAxis()
    }

    property string lastMode: ""
    function loadAxis() {
        if (lastMode != graphViewSelected) {
            lastMode = graphViewSelected

            // Decorations
            if (graphViewSelected === "daily") {
                backgroundDayBars.borderColor = "transparent"
                backgroundDayBars.color = Theme.colorForeground
                backgroundNightBars.borderColor = "transparent"
                backgroundNightBars.color = (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? "#111111": "#dddddd"
            } else {
                backgroundDayBars.borderColor = "transparent"
                backgroundDayBars.color = Theme.colorForeground
                backgroundNightBars.borderColor = "transparent"
                backgroundNightBars.values = [0]
            }

            //
            if (graphViewSelected === "daily") {
                myBarSeries.barWidth = 0.90
                axisX0.labelsFont.pixelSize = 8
                axisX0.categories = currentDevice.getLegendHours()
            } else if (graphViewSelected === "weekly") {
                myBarSeries.barWidth = 0.75
                axisX0.labelsFont.pixelSize = 12
                axisX0.categories = currentDevice.getLegendDays(7)
            } else {
                myBarSeries.barWidth = 0.94
                axisX0.labelsFont.pixelSize = 6
                axisX0.categories = currentDevice.getLegendDays(30)
            }
        }
    }

    function updateColors() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("itemDataCharts // updateColors() >> " + currentDevice)

        // Bars
        if (graphDataSelected === "soilMoisture") {
            myBarSet.color = Theme.colorBlue
        } else if (graphDataSelected === "soilConductivity") {
            myBarSet.color = Theme.colorRed
        } else if (graphDataSelected === "soilTemperature") {
            myBarSet.color = Theme.colorGreen
        } else if (graphDataSelected === "temperature") {
            myBarSet.color = Theme.colorGreen
        } else if (graphDataSelected === "humidity") {
            myBarSet.color = Theme.colorBlue
        } else if (graphDataSelected === "luminosity") {
            myBarSet.color = Theme.colorYellow
        }
        myBarSet.borderColor = "transparent"

        // Decorations
        if (graphViewSelected === "daily") {
            backgroundDayBars.borderColor = "transparent"
            backgroundDayBars.color = Theme.colorForeground
            backgroundNightBars.borderColor = "transparent"
            backgroundNightBars.color = (settingsManager.theme === "appTheme") ? "#111111": "#dddddd"
        } else {
            backgroundDayBars.borderColor = "transparent"
            backgroundDayBars.color = Theme.colorForeground
            backgroundNightBars.borderColor = "transparent"
            backgroundNightBars.values = [0]
        }
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("itemDataCharts // updateGraph() >> " + currentDevice)

        loadAxis()

        // Get data
        if (graphViewSelected === "daily") {
            myBarSet.values = currentDevice.getDataHours(graphDataSelected)
        } else if (graphViewSelected === "weekly") {
            myBarSet.values = currentDevice.getDataDays(graphDataSelected, 7)
        } else {
            myBarSet.values = currentDevice.getDataDays(graphDataSelected, 30)
        }

        // Min axis
        //var min_of_array = Math.min.apply(Math, myBarSet.values);
        axisY0.min = 0;

        // Max axis
        var max_of_array = Math.max.apply(Math, myBarSet.values);
        var max_of_legend = max_of_array*1.20;
        if ((graphDataSelected === "soilMoisture" || graphDataSelected === "humidity") && max_of_legend > 100.0) {
            max_of_legend = 100.0; // no need to go higher than 100% humidity
        }
        if (max_of_legend <= 0) max_of_legend = 1 // if we have no data
        axisY0.max = max_of_legend;

        // Decorations
        if (graphViewSelected === "daily") {
            backgroundDayBars.values = currentDevice.getBackgroundDaytime(max_of_legend)
            backgroundNightBars.values = currentDevice.getBackgroundNighttime(max_of_legend)
        } else if (graphViewSelected === "weekly") {
            backgroundDayBars.values = currentDevice.getBackgroundDays(max_of_legend, 7)
        } else {
            backgroundDayBars.values = currentDevice.getBackgroundDays(max_of_legend, 30)
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ChartView {
        id: myBarGraph
        anchors.fill: parent
        anchors.topMargin: -5
        anchors.bottomMargin: -20
        anchors.leftMargin: -20
        anchors.rightMargin: -20

        antialiasing: false
        legend.visible: false
        backgroundColor: "transparent"

        //animationOptions: ChartView.SeriesAnimations

        StackedBarSeries {
            id: myBarSeries
            barWidth: 0.90

            labelsVisible: false

            axisY: ValueAxis { id: axisY0; visible: false; gridVisible: false; }
            axisX: BarCategoryAxis { id: axisX0; visible: true; gridVisible: false;
                                     labelsFont.pixelSize: 8; labelsColor: Theme.colorText; }

            BarSet { id: myBarSet; }
            BarSet { id: backgroundDayBars; }
            BarSet { id: backgroundNightBars; }
        }
    }
}
