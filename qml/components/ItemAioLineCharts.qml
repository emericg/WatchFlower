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
import "qrc:/qml/UtilsNumber.js" as UtilsNumber

Item {
    id: itemAioLineCharts
    width: parent.width
    anchors.margins: 0

    function loadGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("itemAioLineCharts // loadGraph() >> " + myDevice)

        tempDatas.visible = myDevice.hasTemperatureSensor()
        hygroDatas.visible = myDevice.hasHumiditySensor() || myDevice.hasSoilMoistureSensor()
        lumiDatas.visible = false
        conduDatas.visible = myDevice.hasConductivitySensor()

        dateIndicator.visible = false
        datasIndicator.visible = false
        verticalIndicator.visible = false
    }

    function updateGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("itemAioLineCharts // updateGraph() >> " + myDevice)

        if (dateIndicator.visible)
            resetIndicator()

        if (myDevice.countDatas("temp", 14) > 0) {
            itemAioLineCharts.visible = true
        } else {
            itemAioLineCharts.visible = false
        }

        //// DATAS
        hygroDatas.clear()
        tempDatas.clear()
        lumiDatas.clear()
        conduDatas.clear()

        myDevice.getAioDatas(axisTime, hygroDatas, tempDatas, lumiDatas, conduDatas);

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
            minmax_of_legend = 100.0; // no need to go higher than 100% soil moisture
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

        // Min axis computation, only for thermometers
        if (!myDevice.hasSoilMoistureSensor()) {
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

        //// ADJUSTMENTS
        hygroDatas.width = 2
        tempDatas.width = 2

        if (myDevice.deviceName === "ropot") {
            hygroDatas.width = 3 // Humidity is primary
        }

        if (!myDevice.hasSoilMoistureSensor()) {
            tempDatas.width = 3 // Temperature is primary
        }

        if (myDevice.deviceName === "Flower care") {
            // not planted? don't show hygro and condu
            hygroDatas.visible = (myDevice.hasHumiditySensor() || myDevice.hasSoilMoistureSensor()) && (myDevice.hasDatas("hygro") || myDevice.hasDatas("conductivity"))
            conduDatas.visible = myDevice.hasConductivitySensor() && (myDevice.hasDatas("hygro") || myDevice.hasDatas("conductivity"))

            // Flower Care without hygro & conductivity datas
            if (!hygroDatas.visible && !conduDatas.visible) {
                // Show luminosity and make temperature primary
                lumiDatas.visible = true
                tempDatas.width = 3

                // Luminosity can have min/max, cause values have a very wide range
                i = 0
                minmax_of_array = 0
                for (;i < lumiDatas.count; i++)
                    if (lumiDatas.at(i).y > minmax_of_array)
                        minmax_of_array = lumiDatas.at(i).y
                minmax_of_legend = minmax_of_array*1.20;
                axisLumi.max = minmax_of_legend;
            } else {
                hygroDatas.width = 3 // Soil moisture is primary
            }
        }
    }

    function qpoint_lerp(p0, p1, x) { return (p0.y + (x - p0.x) * ((p1.y - p0.y) / (p1.x - p0.x))) }

    ////////////////////////////////////////////////////////////////////////////

    ChartView {
        id: aioGraph
        anchors.fill: parent
        anchors.margins: -20

        antialiasing: true
        legend.visible: false // works only with Qt 5.10+
        backgroundRoundness: 0
        backgroundColor: "transparent"
        //animationOptions: ChartView.SeriesAnimations

        ValueAxis { id: axisHygro; visible: false; gridVisible: true; }
        ValueAxis { id: axisTemp; visible: false; gridVisible: true; }
        ValueAxis { id: axisLumi; visible: false; gridVisible: true; }
        ValueAxis { id: axisCondu; visible: false; gridVisible: true; }
        DateTimeAxis { id: axisTime; visible: true; labelsFont.pixelSize: 13;
            labelsColor: Theme.colorText; gridLineColor: Theme.colorBordersWidget; }

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
        }
        LineSeries {
            id: hygroDatas
            color: Theme.colorBlue; width: 2;
            axisY: axisHygro; axisX: axisTime;
        }

        MouseArea {
            id: clickableGraphArea
            anchors.fill: aioGraph
            //propagateComposedEvents: true
            //hoverEnabled: true

            onClicked: {
                var mmm = Qt.point(mouse.x, mouse.y)
                mouse.accepted = true

                // we adjust coordinates with graph area margins
                var ppp = Qt.point(mouse.x, mouse.y)
                ppp.x = ppp.x + aioGraph.anchors.rightMargin
                ppp.y = ppp.y - aioGraph.anchors.topMargin

                // map mouse position to graph value // mpmp.x is the timestamp
                var mpmp = aioGraph.mapToValue(mmm, tempDatas)

                //console.log("clicked " + mouse.x + " " + mouse.y)
                //console.log("clicked adjusted " + ppp.x + " " + ppp.y)
                //console.log("clicked mapped " + mpmp.x + " " + mpmp.y)

                // did we actually clicked inside the axis?
                if (mpmp.x >= tempDatas.at(0).x && mpmp.x <= tempDatas.at(tempDatas.count-1).x) {
                    // indicators visible
                    dateIndicator.visible = true
                    verticalIndicator.visible = true
                    verticalIndicator.x = ppp.x
                    // set date
                    var date = new Date(mpmp.x)
                    var date_string = date.getDate() + " " + Qt.locale().monthName(date.getMonth(), Locale.LongFormat) + " " + qsTr("at") + " " + UtilsNumber.padNumber(date.getHours(), 2) + ":" + UtilsNumber.padNumber(date.getMinutes(),2)
                    textTime.text = date_string

                    // search index corresponding to the timestamp
                    var x1 = -1
                    var x2 = -1
                    for (var i = 0; i < tempDatas.count; i++) {
                        var graph_at_x = tempDatas.at(i).x
                        var dist = (graph_at_x - mpmp.x) / 1000000

                        if (Math.abs(dist) < 1) {
                            // nearest neighbor
                            if (content.state === "DeviceSensor") {
                                updateDatasBars(tempDatas.at(i).y, lumiDatas.at(i).y,
                                                hygroDatas.at(i).y, conduDatas.at(i).y)
                            } else if (content.state === "DeviceThermo") {
                                datasIndicator.visible = true
                                textDatas.text = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempDatas.at(i).y).toFixed(1) + "°F" : tempDatas.at(i).y.toFixed(1) + "°C"
                                textDatas.text += " " + hygroDatas.at(i).y.toFixed(0) + "%"
                            }
                            break;
                        } else {
                            if (dist < 0) {
                                if (x1 < i) x1 = i
                            } else {
                                x2 = i
                                break
                            }
                        }
                    }

                    if (x1 >= 0 && x2 > x1) {
                        // linear interpolation
                        if (content.state === "DeviceSensor") {
                            updateDatasBars(qpoint_lerp(tempDatas.at(x1), tempDatas.at(x2), mpmp.x),
                                            qpoint_lerp(lumiDatas.at(x1), lumiDatas.at(x2), mpmp.x),
                                            qpoint_lerp(hygroDatas.at(x1), hygroDatas.at(x2), mpmp.x),
                                            qpoint_lerp(conduDatas.at(x1), conduDatas.at(x2), mpmp.x))
                        } else if (content.state === "DeviceThermo") {
                            datasIndicator.visible = true
                            var temmp = qpoint_lerp(tempDatas.at(x1), tempDatas.at(x2), mpmp.x)
                            textDatas.text = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(temmp).toFixed(1) + "°F" : temmp.toFixed(1) + "°C"
                            textDatas.text += " " + qpoint_lerp(hygroDatas.at(x1), hygroDatas.at(x2), mpmp.x).toFixed(0) + "%"
                        }
                    }
                } else {
                    resetIndicator()
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: verticalIndicator
        x: 0
        width: 1
        visible: false
        color: Theme.colorLightGrey
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32

        Behavior on x { NumberAnimation { duration: 333 } }
    }

    Row {
        id: indicators
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 12

        Rectangle {
            id: dateIndicator
            width: textTime.width + 12
            height: textTime.height + 12

            color: Theme.colorLightGrey
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: false

            Text {
                id: textTime
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 16
                font.bold: true
                color: Theme.colorHeaderContent
            }
        }

        Rectangle {
            id: datasIndicator
            width: textDatas.width + 12
            height: textDatas.height + 12

            color: Theme.colorLightGrey
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: false

            Text {
                id: textDatas
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 16
                font.bold: true
                color: Theme.colorHeaderContent
            }
        }
    }

    MouseArea {
        anchors.fill: indicators
        onClicked: resetIndicator()
    }

    onWidthChanged: resetIndicator()

    function resetIndicator() {
        dateIndicator.visible = false
        datasIndicator.visible = false
        verticalIndicator.visible = false

        if (typeof deviceScreenDatas === "undefined" || !deviceScreenDatas) return
        if (content.state === "DeviceSensor") deviceScreenDatas.resetDatasBars()
    }
}
