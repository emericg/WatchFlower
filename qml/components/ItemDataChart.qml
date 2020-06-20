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

import QtQuick 2.9
import QtCharts 2.2

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
        if (graphDataSelected === "hygro") {
            axisY0.max = 66
            myBarSet.color = Theme.colorBlue
        } else if (graphDataSelected === "temp") {
            axisY0.max = 40
            myBarSet.color = Theme.colorGreen
        } else if (graphDataSelected === "luminosity") {
            axisY0.max = 3000
            myBarSet.color = Theme.colorYellow
        } else if (graphDataSelected === "conductivity") {
            axisY0.max = 2000
            myBarSet.color = Theme.colorRed
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
                axisX0.categories = currentDevice.getHours()
            } else if (graphViewSelected === "weekly") {
                myBarSeries.barWidth = 0.75
                axisX0.labelsFont.pixelSize = 12
                axisX0.categories = currentDevice.getDays()
            } else {
                myBarSeries.barWidth = 0.94
                axisX0.labelsFont.pixelSize = 6
                axisX0.categories = currentDevice.getMonth()
            }
        }
    }

    function updateColors() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("itemDataCharts // updateColors() >> " + currentDevice)

        // Bars
        if (graphDataSelected === "hygro") {
            myBarSet.color = Theme.colorBlue
        } else if (graphDataSelected === "temp") {
            myBarSet.color = Theme.colorGreen
        } else if (graphDataSelected === "luminosity") {
            myBarSet.color = Theme.colorYellow
        } else if (graphDataSelected === "conductivity") {
            myBarSet.color = Theme.colorRed
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
            myBarSet.values = currentDevice.getDataHourly(graphDataSelected)
        } else if (graphViewSelected === "weekly") {
            myBarSet.values = currentDevice.getDataDaily(graphDataSelected)
        } else {
            myBarSet.values = currentDevice.getDataMonthly(graphDataSelected)
        }

        // Min axis
        //var min_of_array = Math.min.apply(Math, myBarSet.values);
        axisY0.min = 0;

        // Max axis
        var max_of_array = Math.max.apply(Math, myBarSet.values);
        var max_of_legend = max_of_array*1.20;
        if (graphDataSelected === "hygro" && max_of_legend > 100.0) {
            max_of_legend = 100.0; // no need to go higher than 100% humidity
        }
        if (max_of_legend <= 0) max_of_legend = 1 // if we have no data
        axisY0.max = max_of_legend;

        // Decorations
        if (graphViewSelected === "daily") {
            backgroundDayBars.values = currentDevice.getBackgroundHourly(max_of_legend)
            backgroundNightBars.values = currentDevice.getBackgroundNightly(max_of_legend)
        } else if (graphViewSelected === "weekly") {
            backgroundDayBars.values = currentDevice.getBackgroundDaily(max_of_legend)
        } else {
            backgroundDayBars.values = currentDevice.getMonthBackground(max_of_legend)
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
        legend.visible: false // this will only work with Qt 5.10+
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
