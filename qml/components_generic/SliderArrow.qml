import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Slider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight
    padding: 4
    topPadding: 10

    value: 0.5
    snapMode: RangeSlider.SnapAlways

    // colors
    property string colorBg: Theme.colorForeground
    property string colorFg: Theme.colorPrimary
    property string colorTxt: "white"

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: colorBg
        clip: true

        property int ticksCount: ((to - from) / stepSize)

        Repeater {
            width: control.availableWidth
            model: (background.ticksCount-1)
            Rectangle {
                x: (((control.availableWidth) / background.ticksCount) * (index+1))
                width: 1; height: 4;
                color: Theme.colorComponentBorder
            }
        }

        Rectangle {
            width: (control.visualPosition * control.availableWidth) + 1
            height: parent.height
            radius: 2
            color: colorFg
            clip: true

            Repeater {
                width: control.availableWidth
                model: (background.ticksCount-1)
                Rectangle {
                    x: (((control.availableWidth) / background.ticksCount) * (index+1))
                    width: 1; height: 4;
                    color: Theme.colorComponentBackground
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    handle: Rectangle {
        x: control.leftPadding + Math.round(control.visualPosition * control.availableWidth - width/2)
        y: 0
        width: 16
        height: 12

        color: control.pressed ? Theme.colorSecondary : Theme.colorPrimary

        Text {
            anchors.fill: parent
            y: 2

            text: control.value
            font.pixelSize: 10
            font.bold: true
            color: colorTxt
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
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
