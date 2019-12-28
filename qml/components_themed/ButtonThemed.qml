import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Button {
    id: control
    width: contentText.width + contentText.width/3
    implicitHeight: Theme.componentHeight

    property bool embedded: false

    contentItem: Item {
        Text {
            id: contentText
            height: parent.height

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            text: control.text
            font: control.font
            opacity: enabled ? 1.0 : 0.3
            color: control.down ? Theme.colorComponentContent : Theme.colorComponentContent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    background: Rectangle {
        radius: embedded ? 0 : Theme.componentRadius
        opacity: enabled ? 1 : 0.3
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
    }
}
