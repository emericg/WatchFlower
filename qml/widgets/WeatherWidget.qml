import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import ThemeEngine 1.0

Item {
    id: weatherWidget
    implicitWidth: 480
    implicitHeight: 128

    property bool wideAssMode: (width >= 380) || (isTablet && width >= 480)
    property bool bigAssMode: false
    property bool singleColumn: true

    ////////////////

    Rectangle { // contentRectangle
        anchors.fill: widgetExterior
        anchors.leftMargin: singleColumn ? -12 : 0
        anchors.rightMargin: singleColumn ? -12 : 0
        anchors.topMargin: singleColumn ? -6 : 0
        anchors.bottomMargin: singleColumn ? -6 : 0

        radius: 4
        border.width: 2
        border.color: singleColumn ? "transparent" : Theme.colorSeparator

        color: Theme.colorDeviceWidget
        Behavior on color { ColorAnimation { duration: 133 } }

        opacity: (singleColumn ? 0 : 1)
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////

    Item { // contentItem
        id: widgetExterior
        anchors.fill: parent
        anchors.margins: 6

        Item {
            id: widgetInterior
            anchors.fill: parent
            anchors.margins: singleColumn ? 6 : 12

            ////

            Text {
                id: title
                text: qsTr("Weather")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: bigAssMode ? 22 : 20
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
                anchors.verticalCenterOffset: 16
                spacing: 16

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
        anchors.leftMargin: -6
        anchors.right: parent.right
        anchors.rightMargin: -6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        visible: singleColumn
        color: Theme.colorSeparator
    }
}
