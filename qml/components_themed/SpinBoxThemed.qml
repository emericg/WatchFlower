import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

SpinBox {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    clip: true
    value: 50
    editable: true
    font.pixelSize: Theme.fontSizeComponent

    property string legend: ""

    contentItem: TextInput {
        z: 2
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
            z: -1
            anchors.fill: parent
            anchors.margins: -8
            color: Theme.colorComponentBackground
        }
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.up.pressed ? Theme.colorComponentDown : Theme.colorComponent
        //border.color: enabled ? Theme.colorSubText : Theme.colorSubText
        radius: Theme.componentRadius

        Text {
            anchors.fill: parent

            text: "+"
            font.pixelSize: 18
            color: enabled ? Theme.colorComponentContent : Theme.colorSubText
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.down.pressed ? Theme.colorComponentDown : Theme.colorComponent
        //border.color: enabled ? Theme.colorSubText : Theme.colorSubText
        radius: Theme.componentRadius

        Text {
            anchors.fill: parent

            text: "-"
            font.pixelSize: 30
            color: enabled ? Theme.colorComponentContent : Theme.colorSubText
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        radius: Theme.componentRadius
        z: 3

        color: "transparent"
        border.color: Theme.colorComponentBorder
        border.width: 1
    }
}
