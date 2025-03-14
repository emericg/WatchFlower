import QtQuick

import ComponentLibrary

Item {
    id: control

    width: 144
    height: isPhone ? 62 : 72 // (width / 2)

    property string title: ""
    property string legend: ""

    property real value
    property real limit_mid
    property real limit_high
    property int precision: 1

    property string color: {
        if (limit_mid && limit_high) {
            if (value > limit_high)
                return Theme.colorError
            else if (value > limit_mid)
                return Theme.colorWarning
        }
        return Theme.colorGreen
    }

    signal sensorSelection()

    ////////

    MouseArea {
        anchors.fill: parent
        onPressAndHold: sensorSelection()
    }

    ////////

    Rectangle {
        color: control.color
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 4
        radius: 1
    }

    ////////

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 2
        spacing: 2

        Row {
            spacing: 8

            Text {
                text: control.title
                color: Theme.colorText
                font.bold: true
                font.pixelSize: Theme.fontSizeContent
            }

            Text {
                anchors.top: parent.top
                text: control.legend
                color: Theme.colorSubText
                font.bold: false
                font.pixelSize: Theme.fontSizeContentSmall
            }
        }

        Text {
            text: (control.value > -99) ? control.value.toFixed(control.precision) : "?"
            color: Theme.colorSubText
            font.bold: false
            font.pixelSize: isPhone ? 24 : 26
        }
    }

    ////////
}
