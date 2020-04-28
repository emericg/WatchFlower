import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Button {
    id: control
    width: contentText.width + contentImage.width*3
    implicitHeight: Theme.componentHeight
    font.pixelSize: Theme.fontSizeComponent

    property url source: ""
    property int imgSize: 28

    contentItem: Item {
        ImageSvg {
            id: contentImage
            width: imgSize
            height: imgSize

            anchors.right: contentText.left
            anchors.rightMargin: (imgSize / 3)
            anchors.verticalCenter: parent.verticalCenter

            opacity: enabled ? 1.0 : 0.33
            source: control.source
            color: Theme.colorIcon
        }

        Text {
            id: contentText

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: (imgSize / 2)

            text: control.text
            font: control.font
            opacity: enabled ? 1.0 : 0.33
            color: control.down ? Theme.colorComponentContent : Theme.colorComponentContent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    background: Rectangle {
        radius: Theme.componentRadius
        opacity: enabled ? 1 : 0.33
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
    }
}
