import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

ProgressBar {
    id: control
    implicitWidth: 200
    implicitHeight: 6

    value: 0.5

    property var colorBackground: Theme.colorForeground
    property var colorForeground: Theme.colorPrimary

    background: Rectangle {
        radius: (Theme.componentRadius / 2)
        color: control.colorBackground
    }

    contentItem: Item {
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: (Theme.componentRadius / 2)
            color: control.colorForeground
        }
    }
}
