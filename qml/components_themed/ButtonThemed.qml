import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Button {
    id: control
    width: contentText.width + (contentText.width / 3)
    implicitHeight: Theme.componentHeight

    font.pixelSize: Theme.fontSizeComponent

    focusPolicy: Qt.NoFocus

    property bool embedded: false

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: embedded ? 0 : Theme.componentRadius
        opacity: enabled ? 1 : 0.33
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
    }

    contentItem: Item {
        Text {
            id: contentText
            height: parent.height

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            text: control.text
            font: control.font
            opacity: enabled ? 1.0 : 0.33
            color: control.down ? Theme.colorComponentContent : Theme.colorComponentContent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
