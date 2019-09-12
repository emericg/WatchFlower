import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

SpinBox {
    id: control
    value: 0
    editable: true
    clip: true
    font.pixelSize: 14

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)  + " " + qsTr("h")

        font: control.font
        color: Theme.colorSubText
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
            color: Theme.colorForeground
        }
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.up.pressed ? Theme.colorComponentBgDown : Theme.colorComponentBgUp
        //border.color: enabled ? Theme.colorSubText : Theme.colorSubText
        radius: 4

        Text {
            text: "+"
            font.pixelSize: 18
            color: enabled ? Theme.colorText : Theme.colorSubText
            anchors.fill: parent
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
        color: control.down.pressed ? Theme.colorComponentBgDown : Theme.colorComponentBgUp
        //border.color: enabled ? Theme.colorSubText : Theme.colorSubText
        radius: 4

        Text {
            text: "-"
            font.pixelSize: 30
            color: enabled ? Theme.colorText : Theme.colorSubText
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 128
        z: 3
        color: "transparent"
        border.color: Theme.colorComponentBorder
        radius: 4
    }
}
