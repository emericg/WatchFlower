import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

ProgressBar {
    id: control
    height: 6

    value: 0.5

    property var colorBackground: Theme.colorForeground
    property var colorForeground: Theme.colorPrimary

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 6
        color: control.colorBackground
    }

    contentItem: Item {
        implicitWidth: 200
        implicitHeight: 6

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.colorForeground
        }
    }
}
