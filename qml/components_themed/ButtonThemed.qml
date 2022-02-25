import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Button {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    width: contentItem.contentWidth + 24

    leftPadding: 12
    rightPadding: 12

    font.pixelSize: Theme.fontSizeComponent

    focusPolicy: Qt.NoFocus

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: enabled ? 1 : 0.33
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
    }

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        opacity: enabled ? 1.0 : 0.33
        color: control.down ? Theme.colorComponentContent : Theme.colorComponentContent
    }
}
