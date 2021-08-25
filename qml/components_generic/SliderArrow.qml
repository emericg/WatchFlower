import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Slider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight
    padding: 4

    value: 0.5

    snapMode: RangeSlider.SnapAlways
    property int ticksCount: ((to - from) / stepSize)

    ////////

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.colorForeground
        clip: true

        Repeater {
            width: control.availableWidth
            model: (control.ticksCount-1)
            Rectangle {
                x: (((control.availableWidth) / control.ticksCount) * (index+1))
                width: 1; height: 4;
                color: Theme.colorComponentBorder
            }
        }

        Rectangle {
            width: control.visualPosition * control.availableWidth + 1
            height: parent.height
            radius: 2
            color: Theme.colorPrimary
            clip: true

            Repeater {
                width: control.availableWidth
                model: (control.ticksCount-1)
                Rectangle {
                    x: (((control.availableWidth) / control.ticksCount) * (index+1))
                    width: 1; height: 4;
                    color: Theme.colorComponentBackground
                }
            }
        }
    }

    ////////

    handle: Rectangle {
        x: control.leftPadding + Math.round(control.visualPosition * control.availableWidth - width/2)
        y: 0
        width: 14
        height: 10

        color: control.pressed ? Theme.colorSecondary : Theme.colorPrimary

        Rectangle {
            width: 10
            height: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom

            z: -1
            rotation: 45
            color: parent.color
        }
    }
}
