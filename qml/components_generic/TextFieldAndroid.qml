import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

TextField {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    property string title: ""

    property string colorText: Theme.colorComponentContent
    property string colorPlaceholderText: Theme.colorSubText
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorBackground
    property string colorSelectedText: "white"
    property string colorSelection: Theme.colorPrimary

    placeholderText: ""
    placeholderTextColor: colorPlaceholderText

    text: ""
    color: colorText
    font.pixelSize: Theme.fontSizeComponent

    selectByMouse: false
    selectedTextColor: colorSelectedText
    selectionColor: colorSelection

    onEditingFinished: focus = false

    background: Rectangle {
        border.width: 1
        border.color: control.activeFocus ? Theme.colorPrimary : colorBorder
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
                text: control.title
                textFormat: Text.PlainText
                font: control.font
                color: control.activeFocus ? Theme.colorPrimary : colorBorder
            }
        }
    }
}
