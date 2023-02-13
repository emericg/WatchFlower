import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Item {
    id: chartThermometerMinMax
    anchors.fill: parent

    property int widgetWidthTarget: (isPhone ? 48 : 64)
    property int widgetWidth: 48

    property int graphMin: currentDevice.tempMin
    property int graphMax: currentDevice.tempMax

    property int daysTarget: 14
    property int daysVisible: 0

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // loadGraph() >> " + currentDevice)

        daysVisible = 0
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // updateGraph() >> " + currentDevice)

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

    onWidthChanged: updateGraph()

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
            height: parent.height
            anchors.right: parent.right

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
