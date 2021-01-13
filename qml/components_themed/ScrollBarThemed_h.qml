import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

ScrollBar {
    id: control
    width: parent.width
    anchors.bottom: parent.bottom

    //size: 0.3
    //position: 0.2
    active: true
    orientation: Qt.Horizontal
    policy: ScrollBar.AsNeeded

    opacity: 1
    Behavior on opacity { OpacityAnimator { duration: 333; } }

    ////////

    contentItem: Rectangle {
        height: control.height
        implicitWidth: 100
        implicitHeight: 6

        radius: 0
        color: control.pressed ? Theme.colorPrimary : Theme.colorSecondary
    }

    background: Rectangle {
        height: control.height
        implicitWidth: 100
        implicitHeight: 6
        color: Theme.colorForeground
    }
}
