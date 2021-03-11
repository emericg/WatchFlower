import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

TextArea {
    id: textAreaThemed
    implicitWidth: 128
    implicitHeight: Theme.componentHeight*2

    topPadding: 8
    bottomPadding: 8

    property string colorText: Theme.colorComponentContent
    property string colorPlaceholderText: Theme.colorSubText
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorComponentBackground

    text: ""
    color: colorText

    placeholderText: ""
    placeholderTextColor: colorPlaceholderText
    font.pixelSize: Theme.fontSizeComponent

    onEditingFinished: focus = false

    background: Rectangle {
        border.width: 2
        border.color: textAreaThemed.activeFocus ? Theme.colorPrimary : colorBorder
        radius: Theme.componentRadius
        color: colorBackground
    }
}
