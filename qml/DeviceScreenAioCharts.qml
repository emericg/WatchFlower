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
    }

    function updateGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return

        console.log("updateGraph()")

        hygroDatas.clear()
        tempDatas.clear()
        lumiDatas.clear()
        condDatas.clear()

        myDevice.getTempDatas(axisTime, hygroDatas, tempDatas, lumiDatas, condDatas);

        axisY0.min = 0
        axisY0.max = 40
        axisY1.min = 0
        axisY1.max = 3000
        axisY2.min = 0
        axisY2.max = 500
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
        backgroundColor: "#00000000"

        Component.onCompleted: updateGraph()

        ValueAxis { id: axisY0; visible: false; gridVisible: true; }
        ValueAxis { id: axisY1; visible: false; gridVisible: true; }
        ValueAxis { id: axisY2; visible: false; gridVisible: true; }
        DateTimeAxis { id: axisTime; visible: true; }

        LineSeries {
            id: lumiDatas
            color: Theme.colorYellow; width: 2;
            visible: false
            axisY: axisY1; axisX: axisTime;
        }
        LineSeries {
            id: condDatas
            color: Theme.colorRed; width: 2;
            axisY: axisY2; axisX: axisTime;
        }
        LineSeries {
            id: tempDatas
            color: Theme.colorGreen; width: 2;
            axisY: axisY0; axisX: axisTime;

            onClicked: console.log("temp: " + point.x + ", " + point.y);
        }
        LineSeries {
            id: hygroDatas
            color: Theme.colorBlue; width: 3;
            axisY: axisY0; axisX: axisTime;

            onClicked: console.log("hygro: " + point.x + ", " + point.y);
        }
    }
}
