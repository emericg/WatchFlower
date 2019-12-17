import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

RadioButton {
    id: control

    text: "Radio Button"
    checked: false

    indicator: Rectangle {
        x: control.leftPadding
        y: (parent.height / 2) - (height / 2)
        width: 24
        height: 24
        radius: (width / 2)

        color: Theme.colorComponentBackground
        border.width: 1
        border.color: control.down ? Theme.colorSecondary : Theme.colorComponentBorder

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: 14
            height: 14
            radius: (width / 2)

            visible: control.checked
            color: Theme.colorSecondary
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        leftPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter

        color: control.down ? Theme.colorSubText : Theme.colorText
        opacity: enabled ? 1.0 : 0.3
    }
}
