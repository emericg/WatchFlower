import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import ThemeEngine 1.0

Item {
    id: weatherWidget
    implicitWidth: 480
    implicitHeight: 128

    property bool hugeMode: false
    property bool listMode: true

    property int margin: Theme.componentMargin
    property int halfmargin: Theme.componentMargin / 2

    ////////////////

    Rectangle { // contentRectangle
        anchors.fill: widgetExterior
        anchors.leftMargin: listMode ? -margin : 0
        anchors.rightMargin: listMode ? -margin : 0
        anchors.topMargin: listMode ? -halfmargin : 0
        anchors.bottomMargin: listMode ? -halfmargin : 0

        radius: 4
        border.width: 2
        border.color: listMode ? "transparent" : Theme.colorSeparator

        color: Theme.colorDeviceWidget
        Behavior on color { ColorAnimation { duration: 133 } }

        opacity: (listMode ? 0 : 1)
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////

    Item { // contentItem
        id: widgetExterior
        anchors.fill: parent
        anchors.margins: halfmargin

        Item {
            id: widgetInterior
            anchors.fill: parent
            anchors.margins: listMode ? halfmargin : margin

            ////

            Text {
                id: title
                text: qsTr("Weather")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: hugeMode ? 22 : 20
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: title.verticalCenter
                text: "Chambéry"
                textFormat: Text.PlainText
                font.pixelSize: Theme.componentFontSize
                color: Theme.colorSubText
            }

            ////

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: margin
                spacing: margin

                Repeater {
                    model: 5

                    Column {
                        IconSvg {
                            width: widgetInterior.width / 7
                            height: width
                            source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                            color: Theme.colorIcon
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "sunny"
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.componentFontSize
                            color: Theme.colorSubText
                        }
                    }
                }
            }

            ////
        }
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

    ////////////////
}
