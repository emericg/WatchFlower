import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

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

    background: Rectangle {
        radius: Theme.componentRadius
        z: 2

        color: "transparent"
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorComponentBorder
    }

    contentItem: TextInput {
        text: control.textFromValue(control.value, control.locale) + legend
        font: control.font

        color: Theme.colorComponentText
        selectionColor: Theme.colorText
        selectedTextColor: "white"
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly

        Rectangle {
            anchors.fill: parent
            anchors.margins: -32
            z: -1
            radius: Theme.componentRadius
            color: Theme.colorComponentBackground
        }
    }

    up.indicator: Rectangle {
        width: Theme.componentHeight
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        x: control.mirrored ? 0 : parent.width - width
        z: 1

        color: control.up.pressed ? Theme.colorComponentDown : Theme.colorComponent

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

    down.indicator: Rectangle {
        width: Theme.componentHeight
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        x: control.mirrored ? parent.width - width : 0
        z: 1

        color: control.down.pressed ? Theme.colorComponentDown : Theme.colorComponent

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
