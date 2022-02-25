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
    width: contentText.contentWidth + 16

    focusPolicy: Qt.NoFocus

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

        Rectangle { // mouseBackground
            width: mousearea.pressed ? control.width*2 : 0
            height: width
            radius: width

            x: mousearea.mouseX + 4 - (width / 2)
            y: mousearea.mouseY + 4 - (width / 2)

            color: control.primaryColor
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
        Text {
            id: contentText
            anchors.centerIn: parent

            text: control.text
            textFormat: Text.PlainText
            font.bold: false
            font.pixelSize: Theme.fontSizeComponent
            font.capitalization: Font.AllUppercase

            color: control.primaryColor
            opacity: enabled ? 1.0 : 0.33
        }
    }
}
