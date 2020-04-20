import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

ProgressBar {
    id: control
    value: 0.5
    height: 6

    property var colorBackground: Theme.colorForeground
    property var colorForeground: Theme.colorPrimary

    // theming
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
