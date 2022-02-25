import QtQuick 2.15
import QtGraphicalEffects 1.15

import ThemeEngine 1.0

Item {
    z: -1

    property string color: "#666"
    property alias radius: shadowarea.radius
    property bool filled: true

    Rectangle {
        id: shadowarea
        anchors.fill: parent

        visible: false
        color: parent.filled ? parent.color : "transparent"

        border.width: parent.filled ? 0 : 1
        border.color: parent.color
    }
    DropShadow {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 8

        source: shadowarea
        cached: true
        radius: 12.0
        samples: 25 // (radius*2 + 1)
        color: parent.color
        horizontalOffset: 0
        verticalOffset: 0
    }
}
