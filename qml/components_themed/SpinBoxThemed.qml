import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12 // Qt5
//import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

SpinBox {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    value: 50
    editable: true
    font.pixelSize: Theme.fontSizeComponent

    property string legend

    ////////

    background: Rectangle {
        anchors.fill: parent
        radius: Theme.componentRadius
        color: Theme.colorComponentBackground

        Rectangle {
            width: Theme.componentHeight
            height: control.height
            anchors.verticalCenter: parent.verticalCenter
            x: control.mirrored ? 0 : control.width - width
            color: control.up.pressed ? Theme.colorComponentDown : Theme.colorComponent
        }

        Rectangle {
            width: Theme.componentHeight
            height: control.height
            anchors.verticalCenter: parent.verticalCenter
            x: control.mirrored ? control.width - width : 0

            color: control.down.pressed ? Theme.colorComponentDown : Theme.colorComponent
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.componentRadius
            color: "transparent"
            border.width: Theme.componentBorderWidth
            border.color: Theme.colorComponentBorder
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: control.x
                y: control.y
                width: control.width
                height: control.height
                radius: Theme.componentRadius
            }
        }
    }

    ////////

    contentItem: TextInput {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly

        text: control.textFromValue(control.value, control.locale) + legend
        font: control.font
        color: Theme.colorComponentText
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        selectionColor: Theme.colorText
        selectedTextColor: "white"
    }

    ////////

    up.indicator: Item {
        width: Theme.componentHeight
        height: control.height
        anchors.verticalCenter: parent.verticalCenter
        x: control.mirrored ? 0 : control.width - width
        z: 1

        Item {
            anchors.centerIn: parent
            width: UtilsNumber.round2(parent.height * 0.4)
            height: width

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 2
                color: enabled ? Theme.colorComponentContent : Theme.colorSubText
            }
            Rectangle {
                anchors.centerIn: parent
                width: 2
                height: parent.width
                color: enabled ? Theme.colorComponentContent : Theme.colorSubText
            }
        }
    }

    ////////

    down.indicator: Item {
        width: Theme.componentHeight
        height: control.height
        anchors.verticalCenter: parent.verticalCenter
        x: control.mirrored ? control.width - width : 0
        z: 1

        Item {
            anchors.centerIn: parent
            width: UtilsNumber.round2(parent.height * 0.4)
            height: width

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 2
                color: enabled ? Theme.colorComponentContent : Theme.colorSubText
            }
        }
    }
}
