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
    id: deviceScreenAioCharts
    width: parent.width
    anchors.margins: 0

    function loadGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("loadGraph()")

        if ((myDevice.deviceCapabilities & 2) == 0) {
            tempDatas.visible = false // temp
        }
        if ((myDevice.deviceCapabilities & 4) == 0) {
            hygroDatas.visible = false
        }
        if ((myDevice.deviceCapabilities & 8) == 0) {
            lumiDatas.visible = false
        }
        if ((myDevice.deviceCapabilities & 16) == 0) {
            conduDatas.visible = false
        }
    }

    function updateGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        console.log("updateGraph()")

        //// DATAS
        hygroDatas.clear()
        tempDatas.clear()
        lumiDatas.clear()
        conduDatas.clear()

        myDevice.getTempDatas(axisTime, hygroDatas, tempDatas, lumiDatas, conduDatas);

        //// AXIS
        axisHygro.min = 0
        axisHygro.max = 100
        axisTemp.min = 0
        axisTemp.max = 60
        axisCondu.min = 0
        axisCondu.max = 500
        axisLumi.min = 0
        axisLumi.max = 3000

        var i = 0
        var minmax_of_array = 0

        // Max axis
        i = 0
        minmax_of_array = 0
        for (;i < hygroDatas.count; i++)
            if (hygroDatas.at(i).y > minmax_of_array)
                minmax_of_array = hygroDatas.at(i).y
        var minmax_of_legend = minmax_of_array*1.20;
        if (minmax_of_legend > 100.0)
            minmax_of_legend = 100.0; // no need to go higher than 100% hygrometry
        else
            axisHygro.max = minmax_of_legend;

        // Max axis
        i = 0
        minmax_of_array = 0
        for (;i < tempDatas.count; i++)
            if (tempDatas.at(i).y > minmax_of_array)
                minmax_of_array = tempDatas.at(i).y
        minmax_of_legend = minmax_of_array*1.20;
        axisTemp.max = minmax_of_legend;

        hygroDatas.width = 2
        tempDatas.width = 2

        if (myDevice.deviceName === "MJ_HT_V1") {
            // Temp is primary
            tempDatas.width = 3
            // Min axis
            i = 0
            minmax_of_array = 100
            for (;i < hygroDatas.count; i++)
                if (hygroDatas.at(i).y < minmax_of_array)
                    minmax_of_array = hygroDatas.at(i).y
            minmax_of_legend = minmax_of_array*0.80;
            axisHygro.min = minmax_of_legend;
            // Min axis
            i = 0
            minmax_of_array = 100
            for (;i < tempDatas.count; i++)
                if (tempDatas.at(i).y < minmax_of_array)
                    minmax_of_array = tempDatas.at(i).y
            minmax_of_legend = minmax_of_array*0.80;
            axisTemp.min = minmax_of_legend;
        }

        //// VISIBILITY
        hygroDatas.visible = (myDevice.deviceHygro > 0)
        conduDatas.visible = (myDevice.deviceConductivity > 0)

        if (myDevice.deviceName === "Flower care" && myDevice.deviceHygro <= 0) {
            // Temp is primary
            tempDatas.width = 3
            // Show lumi when only have it and temp
            lumiDatas.visible = true

            i = 0
            minmax_of_array = 0
            for (;i < lumiDatas.count; i++)
                if (lumiDatas.at(i).y > minmax_of_array)
                    minmax_of_array = lumiDatas.at(i).y
            minmax_of_legend = minmax_of_array*1.20;
            axisLumi.max = minmax_of_legend;
        }
        else
            lumiDatas.visible = false
    }

    ////////////////////////////////////////////////////////////////////////////

    ChartView {
        id: aioGraph
        anchors.top: parent.top
        anchors.bottom: parent.bottom
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

        Component.onCompleted: updateGraph()

        ValueAxis { id: axisHygro; visible: false; gridVisible: true; }
        ValueAxis { id: axisTemp; visible: false; gridVisible: true; }
        ValueAxis { id: axisLumi; visible: false; gridVisible: true; }
        ValueAxis { id: axisCondu; visible: false; gridVisible: true; }
        DateTimeAxis { id: axisTime; visible: true; }

        LineSeries {
            id: lumiDatas
            color: Theme.colorYellow; width: 2;
            visible: false
            axisY: axisLumi; axisX: axisTime;
        }
        LineSeries {
            id: conduDatas
            color: Theme.colorRed; width: 2;
            axisY: axisCondu; axisX: axisTime;
        }
        LineSeries {
            id: tempDatas
            color: Theme.colorGreen; width: 2;
            axisY: axisTemp; axisX: axisTime;

            onClicked: console.log("temp: " + point.x + ", " + point.y);
        }
        LineSeries {
            id: hygroDatas
            color: Theme.colorBlue; width: 2;
            axisY: axisHygro; axisX: axisTime;

            onClicked: console.log("hygro: " + point.x + ", " + point.y);
        }
    }
}
