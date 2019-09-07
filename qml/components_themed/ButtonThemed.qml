import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

Button {
    id: control

    property string color: Theme.colorText
    property bool selected: false

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.color
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: 40

        radius: 4
        color: "transparent"
        opacity: enabled ? 0.3 : 0.6

        border.width: 2
        border.color: control.color

        Rectangle {
            anchors.fill: parent
            opacity: (control.down) ? 0.5 : 0.1
            color: (control.down || control.selected) ? (control.color) : "transparent"
        }
    }
}
