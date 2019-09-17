import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

TextField {
    id: textFieldThemed
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    text: "Text Field"
    color: Theme.colorComponentText

    background: Rectangle {
        border.width: 2
        border.color: textFieldThemed.activeFocus ? Theme.colorPrimary : Theme.colorComponentBorder
        color: textFieldThemed.activeFocus ? Theme.colorComponentBackground : Theme.colorComponentBackground
    }
}
