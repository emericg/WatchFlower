import QtQuick
import QtQuick.Controls

import ThemeEngine

Item {
    id: chartThermometerMinMax
    anchors.fill: parent

    property int daysTarget: 14
    property int daysVisible: 0
    property int daysAvailable: 0
    property int daysMax: 30

    property int widgetWidthTarget: (isPhone ? 48 : 64)
    property int widgetWidth: 48

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // loadGraph() >> " + currentDevice)

        daysVisible = Math.floor(width / widgetWidthTarget)
        widgetWidth = Math.floor(width / daysVisible)
        daysAvailable = currentDevice.historydaysDataNamed("temperature", daysMax)
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartThermometerMinMax // updateGraph() >> " + currentDevice)

        currentDevice.updateChartData_thermometerMinMax(daysAvailable)
        chartThermometerMinMax.visible = currentDevice.countDataNamed("temperature", daysVisible)
    }

    function isIndicator() { return false }
    function resetHistoryMode() { }

    ////////////////////////////////////////////////////////////////////////////

    ListView {
        id: mmGraph
        anchors.fill: parent

        orientation: Qt.Horizontal
        layoutDirection: Qt.RightToLeft
        snapMode: ListView.SnapToItem

        ScrollBar.horizontal: ScrollBarThemed {
            leftPadding: 4
            rightPadding: 4
            bottomPadding: 4
            height: 8
            radius: 8

            colorMoving: Theme.colorSecondary
            policy: ScrollBar.AsNeeded
        }

        model: currentDevice.aioMinMaxData
        delegate: ChartThermometerMinMaxBar {
            width: widgetWidth
            height: ListView.view.height
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
