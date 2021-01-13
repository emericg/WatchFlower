import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

TextField {
    id: textFieldThemed
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    property string colorText: Theme.colorComponentContent
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorComponentBackground

    //placeholderText: qsTr("TODO")

    text: ""
    color: colorText
    font.pixelSize: Theme.fontSizeComponent

    background: Rectangle {
        border.width: 2
        border.color: textFieldThemed.activeFocus ? Theme.colorPrimary : colorBorder
        radius: Theme.componentRadius
        color: colorBackground
    }
}
