import QtQuick
import QtQuick.Controls

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Item {
    id: toolsPlantBrowser
    implicitWidth: 480
    implicitHeight: 128

    property bool bigAssMode: false
    property bool singleColumn: true

    property int margin: Theme.componentMargin
    property int halfmargin: Theme.componentMargin / 2

    ////////////////

    Item {
        id: widgetExterior
        anchors.fill: parent
        anchors.margins: singleColumn ? 0 : halfmargin

        ////

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: singleColumn ? -halfmargin : 0
            anchors.leftMargin: singleColumn ? -margin : 0
            anchors.rightMargin: singleColumn ? -margin : 0
            anchors.bottomMargin: singleColumn ? -halfmargin : 0

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
                onClicked: screenPlantBrowser.loadScreen()
            }
        }

        ////

        Image {
            id: sourceImg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 2

            visible: false
            asynchronous: true
            smooth: true
            source: "qrc:/assets/tutorial/welcome-plants.svg"
            fillMode: Image.TileHorizontally
        }
        ColorOverlay {
            anchors.fill: sourceImg
            source: sourceImg
            cached: true
            opacity: 0.2
            color: Theme.colorIcon
        }

        ////

        Column {
            id: widgetInterior
            anchors.fill: parent
            anchors.margins: margin
            spacing: halfmargin

            Text { // title
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Plant browser")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: bigAssMode ? 22 : 20

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("%1 entries").arg(3403)
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorSubText
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Check out all of our plants!")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
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

        visible: singleColumn
        color: Theme.colorSeparator
    }
}
