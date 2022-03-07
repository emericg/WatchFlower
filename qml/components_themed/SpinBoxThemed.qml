import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.SpinBox {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    value: 50
    editable: true
    font.pixelSize: Theme.fontSizeComponent

    property string legend

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        color: Theme.colorComponentBackground

        Rectangle {
            width: control.height
            height: control.height
            anchors.verticalCenter: parent.verticalCenter
            x: control.mirrored ? 0 : control.width - width
            color: control.up.pressed ? Theme.colorComponentDown : Theme.colorComponent
        }
        Rectangle {
            width: control.height
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
            border.color: control.focus ? Theme.colorPrimary : Theme.colorComponentBorder
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

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        TextInput {
            width: parent.width - (control.height * 2)
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: control.legend ? -(contentWidth / 2) : 0
            anchors.verticalCenter: parent.verticalCenter

            color: Theme.colorComponentText
            selectionColor: Theme.colorText
            selectedTextColor: "white"

            text: control.textFromValue(control.value, control.locale)
            font: control.font
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            readOnly: !control.editable
            validator: control.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly

            onEditingFinished: {
                control.value = control.valueFromText(text, control.locale)
                control.focus = false
            }

            Text {
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: parent.contentWidth
                anchors.verticalCenter: parent.verticalCenter

                visible: control.legend
                color: Theme.colorComponentText

                text: control.legend
                textFormat: Text.PlainText
                font: control.font
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    up.indicator: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        width: control.height
        height: control.height
        anchors.verticalCenter: control.verticalCenter
        x: control.mirrored ? 0 : control.width - width

        Rectangle {
            anchors.centerIn: parent
            width: UtilsNumber.round2(parent.height * 0.4)
            height: 2
            color: enabled ? Theme.colorComponentContent : Theme.colorSubText
        }
        Rectangle {
            anchors.centerIn: parent
            width: 2
            height: UtilsNumber.round2(parent.height * 0.4)
            color: enabled ? Theme.colorComponentContent : Theme.colorSubText
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    down.indicator: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        width: control.height
        height: control.height
        anchors.verticalCenter: control.verticalCenter
        x: control.mirrored ? control.width - width : 0

        Rectangle {
            anchors.centerIn: parent
            width: UtilsNumber.round2(parent.height * 0.4)
            height: 2
            color: enabled ? Theme.colorComponentContent : Theme.colorSubText
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
