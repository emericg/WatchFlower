import QtQuick 2.7
import QtQuick.Controls 2.0

import app.watchflower.theme 1.0

RadioButton {
    id: control
    text: qsTr("RadioButton")
    checked: false

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        border.color: Theme.colorMaterialDarkGrey

        Rectangle {
            width: 16
            height: 16
            x: 5
            y: 5
            radius: 8
            color: control.down ? Theme.colorMaterialLightGreen : Theme.colorMaterialLightGreen
            visible: control.checked
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: Theme.colorDarkGrey
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
