import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

TextField {
    id: textFieldThemed
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    property string title: ""
    //property string placeholderText: "" // TODO

    property string colorText: Theme.colorComponentContent
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorBackground

    color: colorText
    font.family: fontText.name
    font.pixelSize: Theme.fontSizeComponent

    background: Rectangle {
        border.width: 1
        border.color: textFieldThemed.activeFocus ? Theme.colorPrimary : colorBorder
        radius: Theme.componentRadius
        color: colorBackground

        Rectangle {
            width: textTitle.width + 8
            height: textTitle.height + 8
            x: 12
            y: (-textTitle.height / 2) - 1
            visible: title
            color: Theme.colorBackground

            Text {
                x: 4
                id: textTitle
                text: textFieldThemed.title
                textFormat: Text.PlainText
                color: textFieldThemed.activeFocus ? Theme.colorPrimary : colorBorder

                font.family: fontText.name
                font.pixelSize: Theme.fontSizeComponent
            }
        }
    }
}
