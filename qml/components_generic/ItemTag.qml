import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: control
    implicitWidth: 80
    implicitHeight: 28

    width: txt.contentWidth + 24

    radius: Theme.componentRadius
    color: backgroundColor

    property string backgroundColor: Theme.colorForeground
    property string textColor: Theme.colorText

    property string text: "TAG"
    property int textSize: Theme.fontSizeComponent

    Text {
        id: txt
        anchors.centerIn: parent

        text: control.text
        textFormat: Text.PlainText

        color: control.textColor
        font.bold: true
        font.pixelSize: control.textSize
        font.capitalization: Font.AllUppercase
    }
}
