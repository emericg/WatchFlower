import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Button {
    id: control
    implicitHeight: Theme.componentHeight

    property bool fullColor: false
    property string primaryColor: "#5483EF"
    property string secondaryColor: "#D0D0D0"

    font.pixelSize: 16 // fullColor ? 16 : 15

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? (control.down ? 0.9 : 1.0) : 0.3
        color: fullColor ? "white" : control.primaryColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: Theme.componentRadius
        border.width: 1
        border.color: fullColor ? control.primaryColor : control.secondaryColor
        opacity: enabled ? (control.down ? 0.5 : 1.0) : 0.3
        color: fullColor ? control.primaryColor : Theme.colorComponentBackground
    }
}
