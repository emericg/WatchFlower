import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import ThemeEngine 1.0

Item {
    id: toolsDeviceBrowser
    implicitWidth: 480
    implicitHeight: 128

    property bool bigAssMode: false
    property bool singleColumn: true

    ////////////////

    Item {
        id: widgetExterior
        anchors.fill: parent
        anchors.margins: 6

        ////

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: singleColumn ? -12 : 0
            anchors.rightMargin: singleColumn ? -12 : 0
            anchors.topMargin: singleColumn ? -6 : 0
            anchors.bottomMargin: singleColumn ? -6 : 0

            radius: Math.min(Theme.componentRadius, 8)
            border.width: Theme.componentBorderWidth
            border.color: {
                if (singleColumn) return "transparent"
                if (mousearea.containsPress) return Qt.lighter(Theme.colorSecondary, 1.1)
                return Theme.colorSeparator
            }

            color: Theme.colorDeviceWidget
            Behavior on color { ColorAnimation { duration: 133 } }

            opacity: (singleColumn ? 0 : 1)
            Behavior on opacity { OpacityAnimator { duration: 133 } }

            MouseArea {
                id: mousearea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                enabled: deviceManager.bluetooth
                onClicked: screenDeviceBrowser.loadScreen()
            }
        }

        ////

        Item {
            id: radar
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.right: parent.right
            anchors.rightMargin: singleColumn ? -4 : 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2

            clip: true
            opacity: 1
            width: (parent.width / 2)

            Rectangle {
                anchors.centerIn: cc
                width: (parent.width * 1.6)
                height: width
                radius: width
                color: Theme.colorForeground
                opacity: 0.4
                border.width: 2
                border.color: Theme.colorLowContrast
            }
            Rectangle {
                anchors.centerIn: cc
                width: (parent.width * 1.19)
                height: width
                radius: width
                color: Theme.colorForeground
                opacity: 0.6
                border.width: 2
                border.color: Theme.colorLowContrast
            }
            Rectangle {
                anchors.centerIn: cc
                width: (parent.width * 0.80)
                height: width
                radius: width
                color: Theme.colorForeground
                opacity: 0.8
                border.width: 2
                border.color: Theme.colorLowContrast
            }
            Rectangle {
                anchors.centerIn: cc
                width: (parent.width * 0.48)
                height: width
                radius: width
                color: Theme.colorForeground
                opacity: 1
                border.width: 2
                border.color: Theme.colorLowContrast
            }

            Rectangle {
                id: cc
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 72
                height: 72
                radius: 72
                color: Theme.colorBackground
                border.width: 2
                border.color: Theme.colorSeparator

                IconSvg {
                    anchors.centerIn: parent
                    source: "qrc:/assets/icons_material/duotone-devices-24px.svg"
                    color: Theme.colorIcon
                }
            }
        }

        ////

        Column {
            id: widgetInterior
            anchors.fill: parent
            anchors.margins: singleColumn ? 6 : 12
            spacing: 8

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Device browser")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorText
                font.pixelSize: bigAssMode ? 22 : 20
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("See Bluetooth sensors and devices around you.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Use it to do stuff. And stuff.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
        }

        ////
    }

    ////////////////

    Rectangle { // bottomSeparator
        height: 1
        anchors.left: parent.left
        anchors.leftMargin: -6
        anchors.right: parent.right
        anchors.rightMargin: -6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        visible: singleColumn
        color: Theme.colorSeparator
    }
}
