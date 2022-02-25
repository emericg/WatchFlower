import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: itemWeatherBox
    width: (duo) ? size*2 : size
    height: column.height + column.anchors.topMargin*2
    radius: 10

    property string title: ""
    property string legend: ""
    property string icon: ""

    property int size: 96
    property bool duo: false

    property real value
    property real limit_mid
    property real limit_high
    property int precision: 1

    signal sensorSelection()

    color: Theme.colorForeground
    border.color: Theme.colorSeparator
    border.width: 2

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        onPressAndHold: sensorSelection()
    }

    ////////

    Column {
        id: column
        anchors.top: parent.top
        anchors.topMargin: isDesktop ? 12 : 10
        anchors.left: parent.left
        anchors.leftMargin: isDesktop ? 12 : 10
        anchors.right: parent.right
        anchors.rightMargin: 6
        spacing: 6

        IconSvg {
            width: isDesktop ? 32 : 24
            height: isDesktop ? 32 : 24
            source: icon
            color: Theme.colorIcon
        }

        Text {
            width: parent.width
            text: itemWeatherBox.title
            wrapMode: Text.WordWrap
            color: Theme.colorText
            font.bold: false
            font.pixelSize: isDesktop ? Theme.fontSizeContent : Theme.fontSizeContentSmall
        }

        Row {
            spacing: 2

            Text {
                text: (itemWeatherBox.value > -99) ? itemWeatherBox.value.toFixed(itemWeatherBox.precision) : "?"
                color: Theme.colorText
                font.bold: false
                font.pixelSize: {
                    if (itemWeatherBox.value >= 10000)
                        return 20
                    else if (itemWeatherBox.value >= 1000)
                        return 22
                    else if (itemWeatherBox.precision > 1)
                        return 24
                    else
                        return 26
                }
            }

            Text {
                text: itemWeatherBox.legend
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.bold: false
                font.pixelSize: Theme.fontSizeContent
            }
        }
    }
}
