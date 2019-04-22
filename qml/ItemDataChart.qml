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

import QtQuick 2.7

// Qt 5.10 needed here...
// You can change v2.2 into 2.1 but you'll need to comment the
// ChartView / "legend.visible" line at the bottom of this file
import QtCharts 2.2

import com.watchflower.theme 1.0

Item {
    id: deviceScreenBarCharts
    width: parent.width
    anchors.margins: 0

    property string graphViewSelected
    property string graphDataSelected

    property string bgDayGraphColor: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Theme.colorMaterialLightGrey : Theme.colorMaterialDarkGrey
    property string bgNightGraphColor: "#E1E1E1"

    function loadGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreenBarCharts // loadGraph() >> " + myDevice)

        axisY0.min = 0;
        if (graphDataSelected === "hygro") {
            axisY0.max = 66
            myBarSet.color = Theme.colorBlue
        } else if (graphDataSelected === "temp") {
            axisY0.max = 40
            myBarSet.color = Theme.colorGreen
        } else if (graphDataSelected === "luminosity") {
            axisY0.max = 2000
            myBarSet.color = Theme.colorYellow
        } else if (graphDataSelected === "conductivity") {
            axisY0.max = 750
            myBarSet.color = Theme.colorRed
        }

        loadAxis()
    }

    property string lastMode: ""
    function loadAxis() {
        if (lastMode != graphViewSelected) {
            lastMode = graphViewSelected

            // Decorations
            if (graphViewSelected === "daily") {
                backgroundDayBars.borderColor = "transparent"
                backgroundDayBars.color = bgDayGraphColor
                backgroundNightBars.borderColor = "transparent"
                backgroundNightBars.color = bgNightGraphColor
            } else {
                backgroundDayBars.borderColor = "transparent"
                backgroundDayBars.color = bgDayGraphColor
                backgroundNightBars.borderColor = "transparent"
                backgroundNightBars.values = [0]
            }

            //
            if (graphViewSelected === "daily") {
                myBarSeries.barWidth = 0.90
                axisX0.labelsFont.pixelSize = 8
                axisX0.categories = myDevice.getHours()
            } else if (graphViewSelected === "weekly") {
                myBarSeries.barWidth = 0.60
                axisX0.labelsFont.pixelSize = 12
                axisX0.categories = myDevice.getDays()
            } else {
                myBarSeries.barWidth = 0.80
                axisX0.labelsFont.pixelSize = 6
                axisX0.categories = myDevice.getMonth()
            }
        }
    }

    function updateGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreenBarCharts // updateGraph() >> " + myDevice)

        loadAxis()

        // Get datas
        if (graphViewSelected === "daily") {
            myBarSet.values = myDevice.getDatasHourly(graphDataSelected)
        } else if (graphViewSelected === "weekly") {
            myBarSet.values = myDevice.getDatasDaily(graphDataSelected)
        } else {
            myBarSet.values = myDevice.getMonthDatas(graphDataSelected)
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
        if (graphViewSelected === "daily") {
            backgroundDayBars.values = myDevice.getBackgroundHourly(max_of_legend)
            backgroundNightBars.values = myDevice.getBackgroundNightly(max_of_legend)
        } else if (graphViewSelected === "weekly") {
            backgroundDayBars.values = myDevice.getBackgroundDaily(max_of_legend)
        } else {
            backgroundDayBars.values = myDevice.getMonthBackground(max_of_legend)
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ChartView {
        id: myBarGraph
        anchors.fill: parent
        anchors.topMargin: 0
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
            axisX: BarCategoryAxis { id: axisX0; visible: true; gridVisible: false; labelsFont.pixelSize: 8; }

            BarSet { id: myBarSet; }
            BarSet { id: backgroundDayBars; }
            BarSet { id: backgroundNightBars; }
        }
    }
}
