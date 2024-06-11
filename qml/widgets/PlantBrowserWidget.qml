import QtQuick
import QtQuick.Effects

import ThemeEngine

Item {
    id: toolsPlantBrowser
    implicitWidth: 480
    implicitHeight: 128

    property bool hugeMode: (!isHdpi || (isTablet && width >= 480))
    property bool listMode: false

    property int margin: Theme.componentMargin
    property int halfmargin: Theme.componentMargin / 2

    ////////////////

    Item {
        id: widgetExterior
        anchors.fill: parent
        anchors.margins: listMode ? 0 : halfmargin

        ////

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: listMode ? -halfmargin : 0
            anchors.leftMargin: listMode ? -margin : 0
            anchors.rightMargin: listMode ? -margin : 0
            anchors.bottomMargin: listMode ? -halfmargin : 0

            radius: Math.min(Theme.componentRadius, 8)
            border.width: Theme.componentBorderWidth
            border.color: {
                if (listMode) return "transparent"
                if (mousearea.containsPress) return Qt.lighter(Theme.colorSecondary, 1.1)
                return Theme.colorSeparator
            }

            color: Theme.colorDeviceWidget
            Behavior on color { ColorAnimation { duration: 133 } }

            opacity: (listMode ? 0 : 1)
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
            source: "qrc:/assets/gfx/tutorial/welcome-plants.svg"
            fillMode: Image.TileHorizontally
        }
        MultiEffect {
            id: overlayImg
            source: sourceImg
            anchors.fill: sourceImg
            brightness: 1.0
            colorization: 1.0
            colorizationColor: Theme.colorIcon
            opacity: 0.2
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
                font.pixelSize: hugeMode ? 22 : 20

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

        visible: listMode
        color: Theme.colorSeparator
    }
}
