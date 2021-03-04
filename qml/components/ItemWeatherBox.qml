import QtQuick 2.12

import ThemeEngine 1.0

Rectangle {
    id: itemWeatherBox
    width: (duo) ? height*2 : height
    height: 128
    radius: 16

    property string title: ""
    property string legend: ""
    property string icon: ""

    property bool duo: false

    property real value
    property int precision: 1

    color: Theme.colorForeground
    border.color: Theme.colorSeparator
    border.width: 2

    ////////////////////////////////////////////////////////////////////////////

    Column {
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: 8

        ImageSvg {
            width: 32
            height: 32
            source: icon
            color: Theme.colorIcon
        }

        Text {
            width: parent.width
            text: itemWeatherBox.title
            wrapMode: Text.WordWrap
            color: Theme.colorText
            font.bold: false
            font.pixelSize: Theme.fontSizeContentSmall
        }

        Row {
            spacing: 2
            Text {
                text: itemWeatherBox.value.toFixed(itemWeatherBox.precision)
                color: Theme.colorText
                font.bold: false
                font.pixelSize: {
                    if (itemWeatherBox.value >= 10000)
                        return 22
                    else if (itemWeatherBox.value >= 1000)
                        return 24
                    else if (itemWeatherBox.precision > 1)
                        return 26
                    else
                        return 28
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
