import QtQuick

import ComponentLibrary

Rectangle {
    id: control

    implicitWidth: 64
    implicitHeight: 20
    radius: 2

    required property string text

    color: "grey"

    Text {
        anchors.fill: parent
        text: control.text
        textFormat: Text.PlainText
        color: "white"
        font.pixelSize: Theme.fontSizeContentVerySmall
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: Theme.fontSizeContentVeryVerySmall
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
