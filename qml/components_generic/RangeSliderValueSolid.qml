import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

RangeSlider {
    id: control
    implicitWidth: 200
    implicitHeight: 4
    padding: 4

    //first.value: 0.25
    //second.value: 0.75
    snapMode: RangeSlider.SnapAlways

    property string unit: ""
    property bool kshort: false
    property string colorBg: Theme.colorComponent
    property string colorFg: Theme.colorPrimary
    property string colorTxt: "white"

    property int hhh: 18

    ////////

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: 200
        implicitHeight: hhh
        width: control.availableWidth

        height: hhh
        radius: hhh
        color: colorBg
        opacity: 1

        Rectangle {
            x: (h1.x + (h1.width / 3))
            width: ((h2.x + (h2.width / 3)) - (h1.x + (h1.width / 3)))
            height: parent.height
            color: colorFg
            radius: hhh
        }
    }

    ////////

    first.handle: Rectangle {
        id: h1
        x: control.leftPadding + first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: hhh
        implicitHeight: hhh
        width: t1.width + 16

        radius: hhh
        color: colorFg
        border.color: colorFg
        opacity: first.pressed ? 1 : 1

        Text {
            id: t1
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter

            text: {
                var vvalue = first.value
                if (unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(0)
                return ((kshort && first.value > 999) ? (vvalue / 1000) : vvalue) + unit
            }
            textFormat: Text.PlainText
            color: colorTxt
            font.pixelSize: 10
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////

    second.handle: Rectangle {
        id: h2
        x: control.leftPadding + second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: hhh
        implicitHeight: hhh
        width: t2.width + 16

        radius: hhh
        color: colorFg
        border.color: colorFg
        opacity: second.pressed ? 1 : 1

        Text {
            id: t2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter

            text: {
                var vvalue = second.value
                if (unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(0)
                return ((kshort && second.value > 999) ? (vvalue / 1000) : vvalue) + unit
            }
            textFormat: Text.PlainText
            font.pixelSize: 10
            font.bold: true
            color: colorTxt
        }
    }
}
