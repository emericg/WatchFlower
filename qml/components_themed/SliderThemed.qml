import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Slider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight
    padding: 4

    value: 0.5

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.colorForeground

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: Theme.colorPrimary
            radius: 2
        }
    }

    handle: Rectangle {
        x: control.leftPadding + (control.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 18
        height: width
        radius: (width / 2)
        color: control.pressed ? Theme.colorSecondary : Theme.colorPrimary
        border.color: (control.pressed) ? Theme.colorPrimary : Theme.colorPrimary
    }
}
