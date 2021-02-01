import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0

Rectangle {
    id: itemLilMenu
    implicitWidth: 256
    implicitHeight: 32

    color: Theme.colorComponent
    radius: Theme.componentRadius

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
