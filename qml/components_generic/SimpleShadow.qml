import QtQuick 2.12
import QtGraphicalEffects 1.12 // Qt5
//import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

Item {
    z: -1

    property string color: "#666"
    property alias radius: rect.radius
    property bool filled: true

    Rectangle {
        id: rect
        anchors.fill: parent

        visible: false
        color: filled ? parent.color : "transparent"

        border.width: filled ? 0 : 1
        border.color: parent.color
    }
    DropShadow {
        anchors.fill: rect
        source: rect

        cached: true
        radius: 12.0
        samples: 25 // (radius*2 + 1)
        color: parent.color
        horizontalOffset: 0
        verticalOffset: 0
    }
}
