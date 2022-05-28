import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: itemWeatherBox
    width: (duo) ? size*2 : size
    height: columnContent.height + columnContent.anchors.topMargin*2
    radius: Theme.componentRadius

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
        id: columnContent
        anchors.top: parent.top
        anchors.topMargin: isDesktop ? 12 : 10
        anchors.left: parent.left
        anchors.leftMargin: isDesktop ? 12 : 10
        anchors.right: parent.right
        anchors.rightMargin: isDesktop ? 6 : 5
        spacing: isDesktop ? 6 : 5

        Text {
            width: parent.width
            text: itemWeatherBox.title
            wrapMode: Text.WordWrap
            color: Theme.colorSubText
            font.bold: false
            font.pixelSize: isDesktop ? Theme.fontSizeContent : Theme.fontSizeContentSmall
            font.capitalization: Font.AllUppercase
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: -4
            spacing: 4

            IconSvg {
                anchors.verticalCenter: parent.verticalCenter
                width: isDesktop ? 32 : 24
                height: isDesktop ? 32 : 24

                source: icon
                color: Theme.colorIcon
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: (itemWeatherBox.value > -99) ? itemWeatherBox.value.toFixed(itemWeatherBox.precision) : "?"
                color: Theme.colorText
                font.bold: false
                font.pixelSize: {
                    if (itemWeatherBox.value >= 10000)
                        return isDesktop ? 20 : 18
                    else if (itemWeatherBox.value >= 1000)
                        return isDesktop ? 22 : 20
                    else if (itemWeatherBox.precision > 1)
                        return isDesktop ? 24 : 22
                    else
                        return isDesktop ? 26 : 24
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: itemWeatherBox.legend
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.bold: false
                font.pixelSize: isDesktop ? Theme.fontSizeContent : Theme.fontSizeContentSmall
            }
        }
    }
}
