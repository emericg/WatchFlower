import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import ThemeEngine

Item {
    id: chartEnvironmentalVoc
    anchors.fill: parent

    property int daysTarget: 30
    property int daysVisible: 0
    property int daysAvailable: 0
    property int daysMax: (isPhone ? 30 : 90)

    property int widgetWidthTarget: 20
    property int widgetWidth: 20

    property int graphMin: 0
    property int graphMax: 1500

    property int limitMin: -1
    property int limitMax: -1

    ////////////////////////////////////////////////////////////////////////////

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartEnvironmentalVoc // loadGraph() >> " + currentDevice + " > " + currentDevice.primary)

        daysVisible = Math.floor(width / widgetWidthTarget)
        widgetWidth = Math.floor(width / daysVisible)
        daysAvailable = currentDevice.historydaysDataNamed(currentDevice.primary, daysMax)
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartEnvironmentalVoc // updateGraph() >> " + currentDevice + " > " + currentDevice.primary)

        if (currentDevice.primary === "voc" ||
            currentDevice.primary === "hcho") {
            limitMin = 500
            limitMax = 1000
            graphMax = 1500
        } else if (currentDevice.primary === "co2") {
            limitMin = 1000
            limitMax = 2000
            graphMax = 2000
        } else if (currentDevice.primary === "pm1" ||
                   currentDevice.primary === "pm25" ||
                   currentDevice.primary === "pm10") {
            limitMin = 250
            limitMax = 750
            graphMax = 1000
        }

        if (currentDevice.hasPM25Sensor || currentDevice.hasPM10Sensor) {
            currentDevice.updateChartData_environmentalEnv(daysAvailable)
        } else if (currentDevice.hasVocSensor || currentDevice.hasHchoSensor || currentDevice.hasCo2Sensor) {
            currentDevice.updateChartData_environmentalVoc(daysAvailable)
        }
        chartEnvironmentalVoc.visible = currentDevice.countDataNamed(currentDevice.primary, daysTarget)
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        anchors.fill: parent
        anchors.topMargin: 0
        anchors.leftMargin: 20
        anchors.rightMargin: 16
        anchors.bottomMargin: 24

        Rectangle { // vocLegendVert left/right borders
            anchors.top: parent.top
            anchors.right: parent.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -24
            width: 20
            z: 5
            color: Theme.colorBackground
        }
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -24
            width: 16
            z: 5
            color: Theme.colorBackground
        }

        Rectangle {
            id: vocLegendVert
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 2
            z: 5

            color: Theme.colorSeparator

            Rectangle { // top
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.top: parent.top
                anchors.right: parent.right
            }
            Rectangle { // limitMin
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (parent.height * (limitMin / graphMax))

                Shape {
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 1
                    ShapePath {
                        strokeColor: Theme.colorSeparator
                        strokeWidth: isPhone ? 1 : 2
                        strokeStyle: ShapePath.DashLine
                        dashPattern: [ 1, 4 ]
                        startX: 0
                        startY: 0
                        PathLine { x: vocGraph.width; y: 0; }
                    }
                }
            }
            Rectangle { // limitMax
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (parent.height * (limitMax / graphMax))

                Shape {
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 1
                    ShapePath {
                        strokeColor: Theme.colorSeparator
                        strokeWidth: isPhone ? 1 : 2
                        strokeStyle: ShapePath.DashLine
                        dashPattern: [ 1, 4 ]
                        startX: 0
                        startY: 0
                        PathLine { x: vocGraph.width; y: 0; }
                    }
                }
            }
            Rectangle { // bottom
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        ////////////////

        Rectangle {
            id: vocLegendHor
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            z: 5

            color: Theme.colorSeparator
        }

        ////////////////

        ListView {
            id: vocGraph
            anchors.fill: parent

            orientation: Qt.Horizontal
            layoutDirection: Qt.RightToLeft
            snapMode: ListView.SnapToItem

            ScrollBar.horizontal: ScrollBarThemed {
                anchors.top: parent.bottom
                height: 4
                radius: 2

                colorMoving: Theme.colorSecondary
                policy: ScrollBar.AsNeeded
            }

            model: currentDevice.aioEnvData
            delegate: ChartEnvironmentalVocBar {
                width: widgetWidth
                height: ListView.view.height

                graphMin: chartEnvironmentalVoc.graphMin
                graphMax: chartEnvironmentalVoc.graphMax
                limitMin: chartEnvironmentalVoc.limitMin
                limitMax: chartEnvironmentalVoc.limitMax
            }
        }

        ///////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
