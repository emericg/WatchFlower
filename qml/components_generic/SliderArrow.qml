import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Slider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight
    padding: 4

    value: 0.5

    property int ticksCount: ((to - from) / stepSize)

    ////////

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.colorForeground

        Repeater {
            width: control.availableWidth
            model: (control.ticksCount-1)
            Rectangle {
                x: ((control.width / control.ticksCount-0) * (index+1))
                width: 1; height: 4;
                color: Theme.colorComponentBorder
            }
        }

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: Theme.colorPrimary
            clip: true

            Repeater {
                width: control.availableWidth
                model: (control.ticksCount-1)
                Rectangle {
                    x: ((control.width / control.ticksCount) * (index+1))
                    width: 1; height: 4;
                    color: Theme.colorComponentBackground
                }
            }
        }
    }

    ////////

    handle: Rectangle {
        x: Math.round(control.visualPosition * parent.width - width/2)
        y: 0
        width: 14
        height: 10

        color: control.pressed ? Theme.colorPrimary : Theme.colorPrimary
        border.color: Theme.colorPrimary

        Rectangle {
            width: 10
            height: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom

            rotation: 45
            color: control.pressed ? Theme.colorPrimary : Theme.colorPrimary
            border.color: Theme.colorPrimary
        }
    }
}
