import QtQuick 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0

Item {
    property string color: "#eee"
    property int radius: 0

    Rectangle {
        id: rect
        anchors.fill: parent

        visible: false
        color: "transparent"
        radius: parent.radius

        border.width: 1
        border.color: parent.color
    }
    DropShadow {
        anchors.fill: rect
        source: rect

        cached: true
        radius: 8.0
        samples: 16
        color: "#60000000"
        horizontalOffset: 0
        verticalOffset: 0
    }
}
