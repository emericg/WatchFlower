import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.0

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: chartHistory

    property string title: ""
    property string suffix: ""
    property int floatprecision: 0
    property string color: Theme.colorBlue
    property bool animated: false

    property real valueMin: limitMin - (25 * ((limitMax-limitMin) / 50))
    property real valueMax: limitMax + (25 * ((limitMax-limitMin) / 50))
    property real limitMin: -1
    property real limitMax: -1

    property var ddd
    property var uuu

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

    Text { // title
        id: titleArea
        anchors.top: chartHistory.top
        anchors.topMargin: singleColumn ? 8 : 16
        anchors.left: chartArea.left
        anchors.leftMargin: singleColumn ? 8 : 0

        text: title
        color: Theme.colorIcon
        font.bold: true
        font.pixelSize: Theme.fontSizeContentSmall
        font.capitalization: Font.AllUppercase
        verticalAlignment: Text.AlignBottom
    }

    Text {
        id: dataArea
        anchors.top: chartHistory.top
        anchors.topMargin: singleColumn ? 8 : 16
        anchors.left: titleArea.right
        anchors.leftMargin: 16

        text: ""
        color: Theme.colorIcon
        font.bold: false
        font.pixelSize: Theme.fontSizeContentSmall
        verticalAlignment: Text.AlignBottom

        Connections {
            target: graphGrid
            function onBarSelectionIndexChanged() {
                var txt = ""
                if (graphGrid.barSelectionIndex >= 0) {
                    if (graphRepeater.itemAt(graphGrid.barSelectionIndex).value > -99) {
                        txt = graphRepeater.itemAt(graphGrid.barSelectionIndex).value.toFixed(floatprecision)
                        txt += suffix.replace("<br>", "")
                    }
                }
                dataArea.text = txt
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item { // chart area
        id: chartArea
        width: parent.width - (singleColumn ? 8 : 32)

        anchors.top: titleArea.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: isPhone ? 12 : 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: singleColumn ? 0 : 12

        ////////////////

        Shape {
            id: legendMaxBar
            y: parent.height - (UtilsNumber.normalize(limitMax, valueMin, valueMax) * parent.height)
            z: graphRow.z+1
            opacity: 0.33
            visible: (limitMax > valueMin && limitMax < valueMax)

            ShapePath {
                strokeColor: Theme.colorSubText
                strokeWidth: isPhone ? 1 : 2
                strokeStyle: ShapePath.DashLine
                dashPattern: [ 1, 4 ]
                startX: 0
                startY: 0
                PathLine { x: chartArea.width; y: 0; }
            }
            Text {
                anchors.right: parent.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("max")
                color: Theme.colorSubText
                font.pixelSize: 10
            }
        }
        Shape {
            id: legendMinBar
            y: parent.height - (UtilsNumber.normalize(limitMin, valueMin, valueMax) * parent.height)
            z: graphRow.z+1
            opacity: 0.33
            visible: (limitMin > valueMin && limitMin < valueMax)

            ShapePath {
                strokeColor: Theme.colorSubText
                strokeWidth: isPhone ? 1 : 2
                strokeStyle: ShapePath.DashLine
                dashPattern: [ 1, 4 ]
                startX: 0
                startY: 0
                PathLine { x: chartArea.width; y: 0; }
            }
            Text {
                anchors.right: parent.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("min")
                color: Theme.colorSubText
                font.pixelSize: 10
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
            property int barRadius: isPhone ? 0 : 4
            property int barSpacing: {
                if (ddd === ChartHistory.Span.Daily) return 1
                if (ddd === ChartHistory.Span.Weekly) return 4
                if (ddd === ChartHistory.Span.Monthly) return 1
            }

            Repeater {
                id: graphRepeater

                model: {
                    if (ddd === ChartHistory.Span.Daily) return currentDevice.aioHistoryData_day
                    if (ddd === ChartHistory.Span.Weekly) return currentDevice.aioHistoryData_week
                    if (ddd === ChartHistory.Span.Monthly) return currentDevice.aioHistoryData_month
                    return null
                }

                Item { ////////////////
                    id: graphBar
                    width: graphRow.barWidth
                    height: graphRow.barHeight

                    property real value: {
                        if (uuu === ChartHistory.Data.SoilMoisture) return modelData.soilMoisture
                        if (uuu === ChartHistory.Data.SoilConductivity) return modelData.soilConductivity
                        if (uuu === ChartHistory.Data.SoilTemperature) return modelData.soilTemperature
                        if (uuu === ChartHistory.Data.SoilPH) return modelData.soilPH
                        if (uuu === ChartHistory.Data.Temperature) return modelData.temperature
                        if (uuu === ChartHistory.Data.Humidity) return modelData.humidity
                        if (uuu === ChartHistory.Data.LuminosityLux) return modelData.luminosityLux
                        if (uuu === ChartHistory.Data.LuminosityMmol) return modelData.luminosityMmol
                        return -99
                    }
                    property real value2: {
                        if (uuu === ChartHistory.Data.Temperature) return modelData.temperatureMax
                        if (uuu === ChartHistory.Data.LuminosityLux) return modelData.luminosityLuxMax
                        return -99
                    }

                    ////

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (ddd === ChartHistory.Span.Daily) {
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
                            if (ddd === ChartHistory.Span.Daily) {
                                return (graphGrid.barSelectionHours === modelData.hour) ? "#fcea32" : Theme.colorForeground
                            } else {
                                return (graphGrid.barSelectionDays === modelData.day) ? "#fcea32" : Theme.colorForeground
                            }
                        }
                        Behavior on color { ColorAnimation { duration: animated ? 233 : 0 } }

                        border.width: (graphRow.barSpacing/2)
                        border.color: Theme.colorBackground
                    }

                    ////

                    Rectangle {
                        id: graphBarFg2
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: parent.width
                        height: UtilsNumber.normalize(value2, valueMin, valueMax) * parent.height

                        border.width: (graphRow.barSpacing/2)
                        border.color: Theme.colorBackground

                        clip: false
                        visible: (value2 > -80 && value2 > value+1)
                        radius: graphRow.barRadius
                        color: chartHistory.color
                        opacity: 0.33
                    }

                    Rectangle {
                        id: graphBarFg
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: parent.width
                        height: UtilsNumber.normalize(value, valueMin, valueMax) * parent.height

                        border.width: (graphRow.barSpacing / 2)
                        border.color: Theme.colorBackground

                        clip: false
                        visible: (value > -80)
                        radius: graphRow.barRadius
                        color: chartHistory.color

                        Loader {
                            id: legendLoader
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter

                            asynchronous: true
                            sourceComponent: {
                                if (value > -80) {
                                    if (ddd === ChartHistory.Span.Weekly)
                                        return legendHorizontal
                                    if (ddd !== ChartHistory.Span.Weekly && !isPhone)
                                        return legendVertical
                                }
                            }

                            property real _value: value
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

                        enabled: {
                            if (isPhone) return false
                            //if (value < -40) return true
                            else if ((value < limitMin || value > limitMax) && (graphBarFg.height > height*1.5)) return true
                            else return false
                        }

                        sourceComponent: (enabled) ? legendImage : null
                        asynchronous: true

                        property real _value: value
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
                        anchors.topMargin: isPhone ? 3 : 6
                        anchors.horizontalCenter: parent.horizontalCenter

                        rotation: (ddd === ChartHistory.Span.Weekly) ? 0 : -40
                        visible: true
                        text: {
                            if (ddd === ChartHistory.Span.Monthly) {
                                return modelData.day
                            } else if (ddd === ChartHistory.Span.Weekly) {
                                return modelData.datetime.toLocaleString(Qt.locale(), "ddd")
                            } else if (ddd === ChartHistory.Span.Daily) {
                                return modelData.datetime.toLocaleString(Qt.locale(), "HH")
                            }
                        }
                        color: Theme.colorSubText
                        opacity: 0.66
                        font.pixelSize: (ddd === ChartHistory.Span.Weekly) ? (isPhone ? 10 : 12) : (isPhone ? 8 : 10)
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
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

            property real value: _value
            property int barHeight: _barHeight

            visible: (barHeight > contentHeight+8)

            text: {
                if (uuu === ChartHistory.Data.Temperature || uuu === ChartHistory.Data.SoilTemperature)
                    if (settingsManager.tempUnit === "F")
                        return UtilsNumber.tempCelsiusToFahrenheit(value).toFixed(floatprecision) + suffix
                return value.toFixed(floatprecision) + suffix
            }
            color: "white"
            font.bold: true
            font.pixelSize: isPhone ? 13 : 14
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // vertical legend /////////////////////////////////////////////////////////

    Component {
        id: legendVertical

        Text {
            anchors.top: parent.top
            anchors.topMargin: (contentWidth/2)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 0

            property real value: _value
            property int barHeight: _barHeight

            visible: (barHeight > contentWidth*1.5)

            rotation: 90
            color: "white"
            text: {
                if (uuu === ChartHistory.Data.Temperature || uuu === ChartHistory.Data.SoilTemperature)
                    if (settingsManager.tempUnit === "F")
                        return UtilsNumber.tempCelsiusToFahrenheit(value).toFixed(floatprecision) + suffix.replace("<br>", "")
                return value.toFixed(floatprecision) + suffix.replace("<br>", "")
            }
            font.bold: true
            font.pixelSize: 10
        }
    }

    // image legend ////////////////////////////////////////////////////////////

    Component {
        id: legendImage

        IconSvg {
            width: 20
            height: 20

            property real value: _value

            color: "white"
            opacity: 0.66
            source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
/*
            source: {
                if (value < -40) return "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                else "qrc:/assets/icons_material/baseline-warning-24px.svg"
            }
            color: {
                if (value < -40) return Theme.colorSubText
                else return "white"
            }
*/
        }
    }
}
