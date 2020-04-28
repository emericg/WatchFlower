import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

TextField {
    id: textFieldThemed
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    property string colorText: Theme.colorComponentText
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorComponentBackground

    text: "Text Field"
    color: colorText
    font.pixelSize: Theme.fontSizeComponent

    background: Rectangle {
        border.width: 2
        border.color: textFieldThemed.activeFocus ? Theme.colorPrimary : colorBorder
        color: colorBackground
    }
}
