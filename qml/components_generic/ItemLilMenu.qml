import QtQuick 2.15
import QtGraphicalEffects 1.15 // Qt5
//import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

Rectangle {
    id: itemLilMenu
    implicitWidth: 256
    implicitHeight: 32

    radius: Theme.componentRadius
    color: Theme.colorComponentBackground

    border.width: 1
    border.color: Theme.colorComponentBorder

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            x: itemLilMenu.x
            y: itemLilMenu.y
            width: itemLilMenu.width
            height: itemLilMenu.height
            radius: itemLilMenu.radius
        }
    }
}
