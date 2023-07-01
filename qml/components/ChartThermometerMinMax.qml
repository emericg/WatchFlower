import QtQuick
import QtQuick.Controls

import ThemeEngine

Item {
    id: chartThermometerMinMax
    anchors.fill: parent

    property int daysTarget: 14
    property int daysVisible: 0

    property int widgetWidthTarget: (isPhone ? 48 : 64)
    property int widgetWidth: 48

    property int graphMin: currentDevice.tempMin
    property int graphMax: currentDevice.tempMax

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // loadGraph() >> " + currentDevice)

        daysVisible = Math.floor(width / widgetWidthTarget)
        widgetWidth = Math.floor(width / daysVisible)
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // updateGraph() >> " + currentDevice)

        currentDevice.updateChartData_thermometerMinMax(daysVisible)
        mmGraph.visible = currentDevice.countDataNamed("temperature", daysVisible)
    }

    function updateGraph_resize() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // updateGraph_resize() >> " + currentDevice)

        var daysVisibleNew = Math.floor(width / widgetWidthTarget)
        var daysMax = daysVisibleNew
        widgetWidth = Math.floor(width / daysVisibleNew)

        if (daysVisible != daysVisibleNew) {
            daysVisible = daysVisibleNew

            currentDevice.updateChartData_thermometerMinMax(daysMax)

            mmGraph.visible = currentDevice.countDataNamed("temperature", daysMax)
            //mmGraphFlick.contentX = (mmGraph.width - mmGraphFlick.width) // WIP
        }
    }

    onWidthChanged: updateGraph_resize()

    function isIndicator() { return false }
    function resetHistoryMode() { }

    ////////////////////////////////////////////////////////////////////////////
/*
    Flickable { // WIP
        id: mmGraphFlick
        anchors.fill: parent

        contentWidth: mmGraph.width
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
*/
        Row {
            id: mmGraph
            anchors.right: parent.right
            height: parent.height

            spacing: 0
            layoutDirection: Qt.LeftToRight

            //onWidthChanged: mmGraphFlick.contentX = (mmGraph.width - mmGraphFlick.width)

            Repeater {
                model: currentDevice.aioMinMaxData
                ChartThermometerMinMaxBar { width: widgetWidth; height: mmGraph.height; }
            }
        }
    //}
}
