import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

RangeSlider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight

    first.value: 0.25
    second.value: 0.75
    snapMode: RangeSlider.SnapAlways

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.colorForeground

        Rectangle {
            x: (control.first.visualPosition * parent.width)
            width: (control.second.visualPosition * parent.width) - x
            height: parent.height
            radius: 2
            color: Theme.colorPrimary
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + (first.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 18
        height: width
        radius: (width / 2)
        color: first.pressed ? Theme.colorPrimary : Theme.colorPrimary
        border.color: Theme.colorPrimary
    }

    second.handle: Rectangle {
        x: control.leftPadding + (second.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 18
        height: width
        radius: (width / 2)
        color: second.pressed ? Theme.colorPrimary : Theme.colorPrimary
        border.color: Theme.colorPrimary
    }
}
