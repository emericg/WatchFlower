import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

RangeSlider {
    id: control
    first.value: 0.25
    second.value: 0.75

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: Theme.colorYellow
        opacity: 0.6

        Rectangle {
            x: control.first.visualPosition * parent.width
            width: control.second.visualPosition * parent.width - x
            height: parent.height
            color: Theme.colorGreen
            radius: 2
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 24
        implicitHeight: 24
        radius: 12
        opacity: first.pressed ? 0.8 : 1
        color: Theme.colorGreen
        border.color: Theme.colorGreen
    }

    second.handle: Rectangle {
        x: control.leftPadding + second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 24
        implicitHeight: 24
        radius: 12
        opacity: second.pressed ? 0.8 : 1
        color: Theme.colorGreen
        border.color: Theme.colorGreen
    }
}
