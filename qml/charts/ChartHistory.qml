import QtQuick
import QtQuick.Shapes

import ComponentLibrary

Item {
    id: chartHistory

    property string title: ""
    property string suffix: ""
    property int floatprecision: 0
    property color color: Theme.colorBlue
    property bool animated: true

    property real valueMin: limitMin - (25 * ((limitMax-limitMin) / 50))
    property real valueMax: limitMax + (25 * ((limitMax-limitMin) / 50))
    property real limitMin: -1
    property real limitMax: -1

    property int hhh // history mode
    property int ddd // data mode

    enum Span {
        Daily = 0,
        Weekly,
        Monthly
    }
    enum Data {
        SoilMoisture = 0,
        SoilConductivity,
        SoilTemperature,
        SoilPH,
        Temperature,
        Humidity,
        LuminosityLux,
        LuminosityMmol
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        id: titleArea
        anchors.top: chartHistory.top
        anchors.topMargin: Theme.singleColumn ? 6 : 12
        anchors.left: chartArea.left
        anchors.leftMargin: Theme.singleColumn ? 2 : 3
        spacing: 12

        Text { // textTitle
            text: chartHistory.title
            color: Theme.colorText
            font.bold: true
            font.pixelSize: Theme.fontSizeContentSmall
            font.capitalization: Font.AllUppercase
            verticalAlignment: Text.AlignBottom
        }

        Text { // textLegend
            text: {
                var txt = ""
                if (graphGrid.barSelectionIndex >= 0) {
                    if (graphRepeater.itemAt(graphGrid.barSelectionIndex).value > -99) {
                        txt = graphRepeater.itemAt(graphGrid.barSelectionIndex).value.toFixed(chartHistory.floatprecision)
                        txt += chartHistory.suffix.replace("<br>", "")
                    }
                    if (graphRepeater.itemAt(graphGrid.barSelectionIndex).value_max > -99 &&
                        graphRepeater.itemAt(graphGrid.barSelectionIndex).value_max !== graphRepeater.itemAt(graphGrid.barSelectionIndex).value) {
                        txt += "  (max " + graphRepeater.itemAt(graphGrid.barSelectionIndex).value_max.toFixed(chartHistory.floatprecision)
                        txt += chartHistory.suffix.replace("<br>", "")
                        txt += ")"
                    }
                }
                return txt
            }
            color: Theme.colorIcon
            font.bold: false
            font.pixelSize: Theme.singleColumn ? Theme.fontSizeContentSmall - 1 : Theme.fontSizeContentSmall
            verticalAlignment: Text.AlignBottom
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item { // chart area
        id: chartArea
        width: parent.width - (Theme.singleColumn ? 8 : 24)

        anchors.top: titleArea.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.isPhone ? 12 : 24
        anchors.right: parent.right
        anchors.rightMargin: 4

        ////////////////

        Shape {
            id: legendMaxBar
            y: parent.height - (UtilsNumber.normalize(chartHistory.limitMax, chartHistory.valueMin, chartHistory.valueMax) * parent.height)
            z: graphRow.z+1
            opacity: 0.33
            visible: (chartHistory.limitMax > chartHistory.valueMin && chartHistory.limitMax < chartHistory.valueMax)

            ShapePath {
                strokeColor: Theme.colorSubText
                strokeWidth: Theme.singleColumn ? 1 : 2
                strokeStyle: ShapePath.DashLine
                dashPattern: [ 1, 4 ]
                startX: 0
                startY: 0
                PathLine { x: chartArea.width; y: 0; }
            }
            Text {
                anchors.right: parent.left
                anchors.rightMargin: Theme.singleColumn ? -contentWidth : 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: Theme.singleColumn ? +6 : 0

                text: qsTr("max", "short for maximum")
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.pixelSize: 11
                rotation: Theme.singleColumn ? 0 : -90
            }
        }
        Shape {
            id: legendMinBar
            y: parent.height - (UtilsNumber.normalize(chartHistory.limitMin, chartHistory.valueMin, chartHistory.valueMax) * parent.height)
            z: graphRow.z+1
            opacity: 0.33
            visible: (chartHistory.limitMin > chartHistory.valueMin && chartHistory.limitMin < chartHistory.valueMax)

            ShapePath {
                strokeColor: Theme.colorSubText
                strokeWidth: Theme.singleColumn ? 1 : 2
                strokeStyle: ShapePath.DashLine
                dashPattern: [ 1, 4 ]
                startX: 0
                startY: 0
                PathLine { x: chartArea.width; y: 0; }
            }
            Text {
                anchors.right: parent.left
                anchors.rightMargin: Theme.singleColumn ? -contentWidth : 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: Theme.singleColumn ? -6 : 0

                text: qsTr("min", "short for minimum")
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.pixelSize: 11
                rotation: Theme.singleColumn ? 0 : -90
            }
        }

        ////////////////

        Row {
            id: graphRow
            anchors.fill: parent
            spacing: 0

            property int barCount: graphRepeater.count

            property real barWidth: ((width - ((barCount-1) * spacing)) / (barCount))
            property int barHeight: height
            property int barRadius: Theme.singleColumn ? 2 : 4
            property int barSpacing: {
                if (chartHistory.hhh === ChartHistory.Span.Daily) return 1
                if (chartHistory.hhh === ChartHistory.Span.Weekly) return 4
                if (chartHistory.hhh === ChartHistory.Span.Monthly) return 1
            }

            Repeater {
                id: graphRepeater

                model: {
                    if (chartHistory.hhh === ChartHistory.Span.Daily) return currentDevice.aioHistoryData_day
                    if (chartHistory.hhh === ChartHistory.Span.Weekly) return currentDevice.aioHistoryData_week
                    if (chartHistory.hhh === ChartHistory.Span.Monthly) return currentDevice.aioHistoryData_month
                    return null
                }

                Item { ////////////////
                    id: graphBar
                    width: graphRow.barWidth
                    height: graphRow.barHeight

                    property real value: {
                        if (chartHistory.ddd === ChartHistory.Data.SoilMoisture) return modelData.soilMoisture
                        if (chartHistory.ddd === ChartHistory.Data.SoilConductivity) return modelData.soilConductivity
                        if (chartHistory.ddd === ChartHistory.Data.SoilTemperature) return modelData.soilTemperature
                        if (chartHistory.ddd === ChartHistory.Data.SoilPH) return modelData.soilPH
                        if (chartHistory.ddd === ChartHistory.Data.Temperature) return modelData.temperature
                        if (chartHistory.ddd === ChartHistory.Data.Humidity) return modelData.humidity
                        if (chartHistory.ddd === ChartHistory.Data.LuminosityLux) return modelData.luminosityLux
                        if (chartHistory.ddd === ChartHistory.Data.LuminosityMmol) return modelData.luminosityMmol
                        return -99
                    }
                    property real value_max: {
                        if (chartHistory.ddd === ChartHistory.Data.Temperature) return modelData.temperatureMax
                        if (chartHistory.ddd === ChartHistory.Data.LuminosityLux) return modelData.luminosityLuxMax
                        return -99
                    }

                    ////

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (chartHistory.hhh === ChartHistory.Span.Daily) {
                                if (graphGrid.barSelectionHours === modelData.hour) {
                                    graphGrid.barSelectionHours = -1
                                    graphGrid.barSelectionIndex = -1
                                } else {
                                    graphGrid.barSelectionHours = modelData.hour
                                    graphGrid.barSelectionIndex = index
                                }
                            } else {
                                if (graphGrid.barSelectionDays === modelData.day) {
                                    graphGrid.barSelectionDays = -1
                                    graphGrid.barSelectionIndex = -1
                                } else {
                                    graphGrid.barSelectionDays = modelData.day
                                    graphGrid.barSelectionIndex = index
                                }
                            }
                        }
                    }

                    ////

                    Rectangle {
                        id: graphBarBg
                        anchors.fill: parent

                        color: {
                            if (chartHistory.hhh === ChartHistory.Span.Daily) {
                                return (graphGrid.barSelectionHours === modelData.hour) ? "#fcea32" : Theme.colorForeground
                            } else {
                                return (graphGrid.barSelectionDays === modelData.day) ? "#fcea32" : Theme.colorForeground
                            }
                        }
                        Behavior on color { ColorAnimation { duration: chartHistory.animated ? 133 : 0 } }

                        border.width: (graphRow.barSpacing / 2)
                        border.color: Theme.colorBackground
                    }

                    ////

                    Rectangle {
                        id: graphBarFg2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: UtilsNumber.normalize(graphBar.value_max, chartHistory.valueMin, chartHistory.valueMax) * parent.height

                        border.width: (graphRow.barSpacing / 2)
                        border.color: Theme.colorBackground

                        clip: false
                        visible: (graphBar.value_max > -80 && graphBar.value_max > graphBar.value+1)
                        radius: graphRow.barRadius
                        color: chartHistory.color
                        opacity: 0.33
                    }

                    Rectangle {
                        id: graphBarFg
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: UtilsNumber.normalize(graphBar.value, chartHistory.valueMin, chartHistory.valueMax) * parent.height

                        border.width: (graphRow.barSpacing / 2)
                        border.color: Theme.colorBackground

                        clip: false
                        visible: (graphBar.value > -80)
                        radius: graphRow.barRadius
                        color: chartHistory.color

                        Loader {
                            id: legendLoader
                            anchors.top: (chartHistory.hhh === ChartHistory.Span.Weekly) ? undefined : parent.top
                            anchors.bottom: (chartHistory.hhh === ChartHistory.Span.Weekly) ? parent.bottom : undefined
                            anchors.horizontalCenter: parent.horizontalCenter

                            active: (graphBar.value > -80)
                            asynchronous: true

                            sourceComponent: {
                                if (chartHistory.hhh === ChartHistory.Span.Weekly)
                                    return legendHorizontal
                                if (chartHistory.hhh !== ChartHistory.Span.Weekly && !Theme.isPhone)
                                    return legendVertical
                            }

                            property real _value: graphBar.value
                            property int _barHeight: graphBarFg.height
                        }
                    }

                    ////
/*
                    Loader {
                        id: imgLoader
                        height: width
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter

                        active: {
                            if (isPhone) return false
                            //if (value < -40) return true
                            else if ((value < limitMin || value > limitMax) && (graphBarFg.height > height*1.5)) return true
                            else return false
                        }

                        asynchronous: true
                        sourceComponent: legendImage

                        property real _value: graphBar.value
                    }
*/
                    ////

                    Rectangle {
                        anchors.top: parent.bottom
                        anchors.left: parent.left
                        width: 1
                        height: 4
                        color: Theme.colorSubText
                        opacity: 0.66
                    }
                    Rectangle {
                        anchors.top: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Theme.colorSubText
                        opacity: 0.66
                    }
                    Rectangle {
                        anchors.top: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: -1
                        width: 1
                        height: 4
                        color: Theme.colorSubText
                        opacity: 0.66
                    }

                    ////

                    Text { // bottom legend
                        id: legendBottom
                        anchors.top: parent.bottom
                        anchors.topMargin: Theme.isPhone ? 3 : 6
                        anchors.horizontalCenter: parent.horizontalCenter

                        rotation: (chartHistory.hhh === ChartHistory.Span.Weekly) ? 0 : -40
                        visible: true
                        text: {
                            if (chartHistory.hhh === ChartHistory.Span.Monthly) {
                                return modelData.day
                            } else if (chartHistory.hhh === ChartHistory.Span.Weekly) {
                                return modelData.datetime.toLocaleString(Qt.locale(), "ddd")
                            } else if (chartHistory.hhh === ChartHistory.Span.Daily) {
                                return modelData.datetime.toLocaleString(Qt.locale(), "HH")
                            }
                        }
                        color: Theme.colorSubText
                        opacity: 0.66
                        font.pixelSize: (chartHistory.hhh === ChartHistory.Span.Weekly) ? (Theme.isPhone ? 10 : 12) : (Theme.isPhone ? 8 : 10)
                        font.bold: false
                        horizontalAlignment: Text.AlignHCenter
                    }

                } ////////////////
            }
        }
    }

    // horizontal legend ///////////////////////////////////////////////////////

    Component {
        id: legendHorizontal

        Text {
            //anchors.top: parent.top // at the top
            //anchors.topMargin: 8
            anchors.bottom: parent.bottom // at the bottom
            anchors.bottomMargin: Theme.isPhone ? 4 : 8
            anchors.horizontalCenter: parent.horizontalCenter

            property real value: _value
            property int barHeight: _barHeight

            visible: (barHeight > contentHeight+8)

            text: {
                if (chartHistory.ddd === ChartHistory.Data.Temperature || chartHistory.ddd === ChartHistory.Data.SoilTemperature)
                    if (SettingsManager.tempUnit === "F")
                        return UtilsNumber.tempCelsiusToFahrenheit(value).toFixed(chartHistory.floatprecision) + chartHistory.suffix
                return value.toFixed(chartHistory.floatprecision) + chartHistory.suffix
            }
            color: "white"
            font.bold: true
            font.pixelSize: Theme.fontSizeContentVerySmall
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // vertical legend /////////////////////////////////////////////////////////

    Component {
        id: legendVertical

        Text {
            anchors.top: parent.top
            anchors.topMargin: (contentWidth / 2)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 0

            property real value: _value
            property int barHeight: _barHeight

            visible: (barHeight > contentWidth*1.5)

            rotation: 90
            color: "white"
            text: {
                if (chartHistory.ddd === ChartHistory.Data.Temperature || chartHistory.ddd === ChartHistory.Data.SoilTemperature)
                    if (SettingsManager.tempUnit === "F")
                        return UtilsNumber.tempCelsiusToFahrenheit(value).toFixed(chartHistory.floatprecision) + chartHistory.suffix.replace("<br>", "")
                return value.toFixed(chartHistory.floatprecision) + chartHistory.suffix.replace("<br>", "")
            }
            font.bold: true
            font.pixelSize: Theme.fontSizeContentVeryVerySmall
        }
    }

    // image legend ////////////////////////////////////////////////////////////

    Component {
        id: legendImage

        IconSvg {
            width: 20
            height: 20

            color: "white"
            opacity: 0.66
            source: "qrc:/IconLibrary/material-symbols/warning.svg"
        }
    }
}
