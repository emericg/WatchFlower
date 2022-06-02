import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Item {
    id: chartThermometerMinMax
    anchors.fill: parent

    property int widgetWidthTarget: (isPhone ? 48 : 64)
    property int widgetWidth: 48
    property int graphMin: currentDevice.tempMin
    property int graphMax: currentDevice.tempMax

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // loadGraph() >> " + currentDevice)
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // updateGraph() >> " + currentDevice)

        var daysVisible = Math.floor(width / widgetWidthTarget)
        var daysMax = daysVisible
        widgetWidth = Math.floor(width / daysVisible)
        currentDevice.updateChartData_thermometerMinMax(daysMax)

        mmGraph.visible = (currentDevice.countDataNamed("temperature", daysMax) > 1)
        //mmGraphFlick.contentX = mmGraphFlick.width // WIP
    }

    onWidthChanged: updateGraph()

    function isIndicator() { return false }
    function resetHistoryMode() { }

    ////////////////////////////////////////////////////////////////////////////

/*
    Flickable {
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
            //layoutDirection: Qt.RightToLeft

            Repeater {
                model: currentDevice.aioMinMaxData
                ChartThermometerMinMaxBar { width: widgetWidth; height: mmGraph.height; }
            }
        }
    //}
}
