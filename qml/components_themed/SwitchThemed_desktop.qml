import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Switch {
    id: control

    indicator: Rectangle {
        x: control.leftPadding
        y: (parent.height / 2) - (height / 2)
        width: 48
        height: 24
        radius: 24

        color: Theme.colorComponentBackground
        border.color: Theme.colorComponentBorder

        Rectangle {
            x: control.checked ? parent.width - width : 0
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: width
            radius: width/2

            color: control.checked ? Theme.colorPrimary : Theme.colorComponentDown
            border.color: control.checked ? Theme.colorPrimary : Theme.colorComponentDown

            Behavior on x { NumberAnimation { duration: 100 } }
        }
    }

    contentItem: Text {
        leftPadding: control.indicator.width + control.spacing

        text: control.text
        verticalAlignment: Text.AlignVCenter

        opacity: enabled ? 1.0 : 0.3
        color: Theme.colorText
        //font: control.font
        //font.bold: false
    }
}
