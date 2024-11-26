import QtQuick

import ComponentLibrary

Rectangle {
    id: control

    width: duo ? sz*2 : sz
    height: contentColumn.height + (isDesktop ? 24 : 22)
    radius: 4

    property string title: ""
    property string legend: ""
    property string icon: ""

    property int sz: 96
    property bool duo: false

    property real value
    property real limit_mid
    property real limit_high
    property int precision: 1

    signal sensorSelection()

    color: Theme.colorForeground
    border.color: Theme.colorSeparator
    border.width: 2

    ////////

    MouseArea {
        anchors.fill: parent
        onPressAndHold: sensorSelection()
    }

    ////////

    IconSvg {
        anchors.right: parent.right
        anchors.rightMargin: isDesktop ? 6 : 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: isDesktop ? 6 : 4
        width: isDesktop ? 48 : 32
        height: isDesktop ? 48 : 32

        source: icon
        color: Theme.colorIcon
        opacity: 0.1
    }

    ////////

    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.leftMargin: isDesktop ? 12 : 10
        anchors.right: parent.right
        anchors.rightMargin: isDesktop ? 6 : 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 2
        spacing: isDesktop ? 4 : 0

        Text {
            anchors.left: parent.left
            anchors.right: parent.right

            text: control.title
            wrapMode: Text.WordWrap
            color: Theme.colorSubText
            font.bold: true
            font.pixelSize: isDesktop ? Theme.fontSizeContentVerySmall+1 : Theme.fontSizeContentVerySmall
            font.capitalization: Font.AllUppercase
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 0
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: (control.value > -99) ? control.value.toFixed(control.precision) : "?"
                color: Theme.colorText
                font.bold: false
                font.pixelSize: {
                    if (control.value >= 10000)
                        return isDesktop ? 20 : 18
                    else if (control.value >= 1000)
                        return isDesktop ? 22 : 20
                    else if (control.precision > 1)
                        return isDesktop ? 24 : 22
                    else
                        return isDesktop ? 26 : 24
                }

                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.left: parent.right
                    anchors.rightMargin: 2

                    text: control.legend
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: false
                    font.pixelSize: isDesktop ? Theme.fontSizeContent : Theme.fontSizeContentSmall
                }
            }
        }
    }

    ////////
}
