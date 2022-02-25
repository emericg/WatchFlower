import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Button {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    property string colorHighlighted: Theme.colorPrimary
    property string colorHovered: Theme.colorHeader

    font.pixelSize: Theme.fontSizeComponent
    font.bold: true

    flat: true
    focusPolicy: Qt.NoFocus

    background: Rectangle {
        radius: 2
        color: {
            if (control.highlighted)
                return control.colorHighlighted
            else if (control.hovered)
                return control.colorHovered
            else
                return "transparent"
        }
        opacity: (control.hovered && !control.highlighted) ? 0.3 : 1
    }

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.highlighted ? "white" : Theme.colorText
        opacity: 1

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
