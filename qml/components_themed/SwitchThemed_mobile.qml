import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Switch {
    id: control

    font.pixelSize: Theme.fontSizeComponent

    indicator: Rectangle {
        x: control.leftPadding
        y: (parent.height / 2) - (height / 2)
        width: 40
        height: 16
        radius: 16

        color: control.checked ? Theme.colorSecondary : Theme.colorComponentDown
        //border.color: control.checked ? Theme.colorSecondary : Theme.colorComponentBackground

        Rectangle {
            x: control.checked ? (parent.width - width) : 0
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: width
            radius: (width / 2)

            color: control.checked ? Theme.colorPrimary : Theme.colorComponent
            border.color: control.checked ? Theme.colorPrimary : Theme.colorComponent

            Behavior on x { NumberAnimation { duration: 133 } }
        }
    }

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing

        text: control.text
        font: control.font
        color: Theme.colorText
        opacity: enabled ? 1.0 : 0.33
    }
}
