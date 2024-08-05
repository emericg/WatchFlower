import QtQuick
import QtQuick.Controls

import ThemeEngine

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
        height: 12
        radius: 4
        color: "#e1e4e9" // Theme.colorForeground

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            x: (control.first.visualPosition * parent.width)
            width: (control.second.visualPosition * parent.width) - x
            radius: 2
            color: "#ed5565" // Theme.colorPrimary
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + (first.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 4
        height: 20
        //radius: (width / 2)
        color: first.pressed ? "#ed5565" : "#ed5565"
        border.color: first.pressed ? "#ed5565" : "#ed5565"
    }

    second.handle: Rectangle {
        x: control.leftPadding + (second.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 4
        height: 20
        //radius: (width / 2)
        color: second.pressed ? "#ed5565" : "#ed5565"
        border.color: second.pressed ? "#ed5565" : "#ed5565"
    }
}
