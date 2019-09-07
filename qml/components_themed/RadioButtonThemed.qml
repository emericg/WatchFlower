import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

RadioButton {
    id: control
    text: "RadioButton"
    checked: false

    indicator: Rectangle {
        implicitWidth: 24
        implicitHeight: 24
        x: control.leftPadding
        y: parent.height / 2 - height / 2

        radius: 12
        color: "white"
        border.color: control.down ? Theme.colorHighlight : Theme.colorComponentBorder

        Rectangle {
            width: 14
            height: 14
            x: 5
            y: 5

            radius: 7
            visible: control.checked
            color: control.down ? Theme.colorHighlight : Theme.colorHighlight
        }
    }

    contentItem: Text {
        leftPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter

        text: control.text
        font: control.font
        color: Theme.colorSubText
        opacity: enabled ? 1.0 : 0.3
    }
}
