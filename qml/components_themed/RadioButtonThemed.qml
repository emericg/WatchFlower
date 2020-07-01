import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

RadioButton {
    id: control

    checked: false
    text: "Radio Button"
    font.pixelSize: Theme.fontSizeComponent

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
            width: 12
            height: 12
            radius: (width / 2)

            color: Theme.colorSecondary
            opacity: control.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 133 } }
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        leftPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter

        color: control.down ? Theme.colorSubText : Theme.colorText
        opacity: enabled ? 1.0 : 0.33
    }
}
