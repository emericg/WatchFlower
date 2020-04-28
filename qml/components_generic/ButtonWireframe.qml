import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Button {
    id: control
    width: contentText.width + (contentText.width / 3)
    implicitHeight: Theme.componentHeight
    font.pixelSize: Theme.fontSizeComponent
    font.bold: false

    property bool fullColor: false
    property string fullfextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorBackground

    contentItem: Item {
        Text {
            id: contentText
            height: parent.height

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            text: control.text
            font: control.font
            opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33
            color: fullColor ? fullfextColor : control.primaryColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    background: Rectangle {
        radius: Theme.componentRadius
        opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33
        color: fullColor ? control.primaryColor : control.secondaryColor
        border.width: 1
        border.color: fullColor ? control.primaryColor : Theme.colorComponentBorder
    }
}
