import QtQuick 2.12

import ThemeEngine 1.0

Item {
    id: itemEnvBox
    width: 144
    height: 72

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

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        color: itemEnvBox.color
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 4
        radius: 1
    }

    Row {
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 16
        spacing: 8

        Text {
            text: itemEnvBox.title
            color: Theme.colorText
            font.bold: true
            font.pixelSize: Theme.fontSizeContent
        }
        Text {
            text: itemEnvBox.legend
            color: Theme.colorSubText
            font.bold: false
            font.pixelSize: Theme.fontSizeContent
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8

        text: (itemEnvBox.value > -99) ? itemEnvBox.value.toFixed(itemEnvBox.precision) : "?"
        color: Theme.colorSubText
        font.bold: false
        font.pixelSize: 26
    }
}
