import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import QtGraphicalEffects 1.15 // Qt5
//import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control
    implicitWidth: 256
    implicitHeight: 56
    width: contentRow.width + 32

    focusPolicy: Qt.NoFocus

    property url source
    property int sourceSize: 26

    property string primaryColor: Theme.colorPrimary

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mousearea
        anchors.fill: control

        hoverEnabled: false
        propagateComposedEvents: false
        acceptedButtons: Qt.AllButtons

        onClicked: control.clicked()
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Item {
        anchors.fill: control

        ////////

        Rectangle {
            id: shadowarea
            anchors.fill: parent
            border.color: "#eee"
            radius: 8
            border.width: 1
            color: "white"
        }
        DropShadow {
            anchors.fill: shadowarea
            cached: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 4.0
            //samples: 8
            color: "#20000000"
            source: shadowarea
        }

        ////////

        Rectangle { // mouseBackground
            width: mousearea.pressed ? control.width*2 : 0
            height: width
            radius: width

            x: mousearea.mouseX + 4 - (width / 2)
            y: mousearea.mouseY + 4 - (width / 2)

            color: "#222"
            opacity: mousearea.pressed ? 0.1 : 0
            Behavior on opacity { NumberAnimation { duration: 333 } }
            Behavior on width { NumberAnimation { duration: 333 } }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: background.x
                y: background.y
                width: background.width
                height: background.height
                radius: 8
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Row {
            id: contentRow
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            IconSvg { // contentImage
                width: control.sourceSize
                height: control.sourceSize
                anchors.verticalCenter: parent.verticalCenter

                source: control.source
                color: control.primaryColor
                opacity: enabled ? 1.0 : 0.33
            }
            Text { // contentText
                anchors.verticalCenter: parent.verticalCenter

                text: control.text
                textFormat: Text.PlainText
                font.bold: true
                font.pixelSize: Theme.fontSizeComponent

                color: control.primaryColor
                opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
}
