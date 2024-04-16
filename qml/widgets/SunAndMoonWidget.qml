import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

Item {
    id: sunAndMoonWidget
    implicitWidth: 480
    implicitHeight: 128

    property bool hugeMode: false
    property bool listMode: true

    property int margin: Theme.componentMargin
    property int halfmargin: Theme.componentMargin / 2

    ////////////////

    Rectangle { // contentRectangle
        anchors.fill: widgetExterior
        anchors.leftMargin: listMode ? -margin : 0
        anchors.rightMargin: listMode ? -margin : 0
        anchors.topMargin: listMode ? -halfmargin : 0
        anchors.bottomMargin: listMode ? -halfmargin : 0

        radius: 4
        border.width: 2
        border.color: listMode ? "transparent" : Theme.colorSeparator

        color: Theme.colorDeviceWidget
        Behavior on color { ColorAnimation { duration: 133 } }

        opacity: (listMode ? 0 : 1)
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////

    Item { // contentItem
        id: widgetExterior
        anchors.fill: parent
        anchors.margins: halfmargin

        Item {
            id: widgetInterior
            anchors.fill: parent
            anchors.margins: listMode ? halfmargin : margin

            ////

            Text {
                id: title
                text: qsTr("Sun & Moon")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: hugeMode ? 22 : 20
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: title.verticalCenter
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: sunAndMoon.moonphaseName
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorSubText
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "(" + sunAndMoon.moonfraction + "%)"
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorSubText
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (sunAndMoon.moonphase > 0.5) ? "↓" : "↑"
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorSubText
                }

                IconSvg {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24

                    rotation: (sunAndMoon.moonphase < 0.5) ? 180 : 0
/*
                    //transform: Matrix4x4 { matrix: Qt.matrix4x4( -1, 0, 0, 24, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) }
                    rotation: {
                        if (sunAndMoon.moonphaseName === "Evening Crescent") return 180
                        if (sunAndMoon.moonphaseName === "First Quarter") return 180
                        if (sunAndMoon.moonphaseName === "Waxing Gibbous") return 180
                        return 0
                    }
*/
                    source: {
                        if (sunAndMoon.moonphaseName === "New") return "qrc:/assets/icons/material-symbols/weather/brightness_1-fill.svg"
                        if (sunAndMoon.moonphaseName === "Evening Crescent") return "qrc:/assets/icons/material-symbols/weather/brightness_3.svg"
                        if (sunAndMoon.moonphaseName === "First Quarter") return "qrc:/assets/icons/material-symbols/weather/brightness_2.svg"
                        if (sunAndMoon.moonphaseName === "Waxing Gibbous") return "qrc:/assets/icons/material-symbols/weather/brightness_2.svg"
                        if (sunAndMoon.moonphaseName === "Full") return "qrc:/assets/icons/material-symbols/weather/brightness_1.svg"
                        if (sunAndMoon.moonphaseName === "Waning Gibbous") return "qrc:/assets/icons/material-symbols/weather/brightness_2.svg"
                        if (sunAndMoon.moonphaseName === "Last Quarter") return "qrc:/assets/icons/material-symbols/weather/brightness_3.svg"
                        if (sunAndMoon.moonphaseName === "Morning Crescent") return "qrc:/assets/icons/material-symbols/weather/brightness_2.svg"
                    }
                    color: Theme.colorIcon
                }
            }

            ////

            Shape {
                id: shapes
                anchors.fill: parent
                anchors.margins: 0

                // multisample
                layer.enabled: true
                layer.samples: 4

                property real centerX: (widgetInterior.width / 2)
                property real centerY: (widgetInterior.height - 28)
                property real radiusX: (widgetInterior.width / 2)
                property real radiusY: (widgetInterior.height * (listMode ? 0.6 : 0.66))
                property real sunsunsun: UtilsNumber.mapNumber(sunAndMoon.sunpath, 0, 100, 0, 160)
                property real moonmoonmoon: UtilsNumber.mapNumber(sunAndMoon.moonpath, 0, 100, 0, 160)
/*
                Rectangle { // shapes area
                    anchors.fill: parent
                    color: "blue"
                    opacity: 0.1
                }
                Rectangle { // center point
                    width: 8
                    height: 8
                    radius: 8
                    color: "red"
                    opacity: 0.5
                    x: shapes.centerX - width/2
                    y: shapes.centerY - height/2
                }
*/
                ShapePath { // background
                    id: shape_bg
                    fillColor: Theme.colorDeviceWidget
                    strokeColor: Theme.colorSeparator
                    strokeWidth: 4
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: shapes.centerX
                        centerY: shapes.centerY
                        radiusX: shapes.radiusX
                        radiusY: shapes.radiusY
                        startAngle: -170
                        sweepAngle: 160
                    }
                }
                ShapePath { // moon path
                    fillColor: Theme.colorDeviceWidget
                    strokeColor: Theme.colorBlue
                    strokeWidth: 4
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: shapes.centerX
                        centerY: shapes.centerY
                        radiusX: shapes.radiusX
                        radiusY: shapes.radiusY
                        startAngle: -170
                        sweepAngle: shapes.moonmoonmoon
                    }
                }
                ShapePath { // sun path
                    fillColor: Theme.colorDeviceWidget
                    strokeColor: Theme.colorYellow
                    strokeWidth: 4
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: shapes.centerX
                        centerY: shapes.centerY
                        radiusX: shapes.radiusX
                        radiusY: shapes.radiusY
                        startAngle: -170
                        sweepAngle: shapes.sunsunsun
                    }
                }
            }

            Rectangle { // sun background and rotating icon
                width: 32
                height: 32
                radius: 32
                //opacity: 0.66
                color: Theme.colorBackground
                border.width: 2
                border.color: Theme.colorSeparator

                visible: (sunAndMoon.sunpath > 0 && sunAndMoon.sunpath < 100)
                x: (shapes.centerX + shapes.radiusX * -Math.cos((UtilsNumber.mapNumber(sunAndMoon.sunpath, 0, 100, 10, 170) / 180) * Math.PI)) - (width/2)
                y: (shapes.centerY + shapes.radiusY * -Math.sin((UtilsNumber.mapNumber(sunAndMoon.sunpath, 0, 100, 10, 170) / 180) * Math.PI)) - (width/2)

                IconSvg {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    source: "qrc:/assets/icons/material-symbols/weather/brightness_5.svg"
                    color: Theme.colorOrange

                    NumberAnimation on rotation {
                        from: 0; to: 360;
                        duration: 10000
                        loops: Animation.Infinite
                        running: (appContent.state === "DeviceList")
                    }
                }
            }
            Rectangle { // moon background and icon
                width: 32
                height: 32
                radius: 32
                //opacity: 0.66
                color: Theme.colorBackground
                border.width: 2
                border.color: Theme.colorSeparator

                visible: (sunAndMoon.moonpath > 0 && sunAndMoon.moonpath < 100)
                x: (shapes.centerX + shapes.radiusX * -Math.cos((UtilsNumber.mapNumber(sunAndMoon.moonpath, 0, 100, 10, 170) / 180) * Math.PI)) - (width/2)
                y: (shapes.centerY + shapes.radiusY * -Math.sin((UtilsNumber.mapNumber(sunAndMoon.moonpath, 0, 100, 10, 170) / 180) * Math.PI)) - (width/2)

                IconSvg {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    source: "qrc:/assets/icons/material-symbols/weather/brightness_2.svg"
                    color: Theme.colorBlue
                }
            }

            ////

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                IconSvg {
                    width: 40
                    height: 40
                    source: "qrc:/assets/icons/material-symbols/weather/sunny.svg"
                    color: Theme.colorIcon
                }
                Column {
                    Row {
                        anchors.left: parent.left
                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            rotation: 90
                            source: "qrc:/assets/icons/material-symbols/arrow_back.svg"
                            color: Theme.colorSubText
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: sunAndMoon.sunrise.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                        }
                    }
                    Row {
                        anchors.left: parent.left
                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            rotation: -90
                            source: "qrc:/assets/icons/material-symbols/arrow_back.svg"
                            color: Theme.colorSubText
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: sunAndMoon.sunset.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                        }
                    }
                }
            }

            ////

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Column {
                    Row {
                        anchors.right: parent.right
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: sunAndMoon.moonrise.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                            color: Theme.colorSubText
                        }
                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            rotation: 90
                            source: "qrc:/assets/icons/material-symbols/arrow_back.svg"
                            color: Theme.colorSubText
                        }
                    }
                    Row {
                        anchors.right: parent.right
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: sunAndMoon.moonset.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                            color: Theme.colorSubText
                        }
                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            rotation: -90
                            source: "qrc:/assets/icons/material-symbols/arrow_back.svg"
                            color: Theme.colorSubText
                        }
                    }
                }

                IconSvg {
                    width: 36
                    height: 36
                    source: "qrc:/assets/icons/material-symbols/weather/brightness_2.svg"
                    color: Theme.colorIcon
                }
            }
        }

        ////
    }

    ////////////////

    Rectangle { // bottom separator
        height: 1
        anchors.left: parent.left
        anchors.leftMargin: -halfmargin
        anchors.right: parent.right
        anchors.rightMargin: -halfmargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        visible: listMode
        color: Theme.colorSeparator
    }

    ////////////////
}
