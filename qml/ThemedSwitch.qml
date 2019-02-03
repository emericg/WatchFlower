import QtQuick 2.7
import QtQuick.Controls 2.0

import app.watchflower.theme 1.0

Switch {
    id: control
    font.bold: true

    indicator: Rectangle {
        implicitWidth: 48
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: "#fff"
        border.color: "#e0e0e0"

        Rectangle {
            x: control.checked ? parent.width - width : 0
            width: 26
            height: 26
            radius: 13
            color: control.checked ? Theme.colorMaterialLightGreen : "#e0e0e0"
            border.color: control.checked ? Theme.colorMaterialLightGreen : "#e0e0e0"
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
