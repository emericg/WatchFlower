import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Item {
    id: codec
    implicitWidth: 80
    implicitHeight: 28
    clip: true

    property string text: "CODEC"
    property string color: Theme.colorBackground
    property string colorText: Theme.colorText

    Rectangle {
        id: codecBackground
        width: parent.width
        height: parent.height
        opacity: 0.8
        radius: 3
        color: codec.color

        Text {
            id: codecText
            anchors.fill: parent

            text: codec.text
            color: codec.colorText
            font.capitalization: Font.AllUppercase
            font.pixelSize: 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
