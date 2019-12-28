import QtQuick 2.9
import QtQuick.Controls 2.2

Button {
    id: control
    width: contentText.width + imgSize*3

    property url source: ""
    property int imgSize: 28

    contentItem: Item {
        Text {
            id: contentText
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: (imgSize/2 + imgSize/6)

            text: control.text
            font: control.font
            opacity: enabled ? 1.0 : 0.3
            color: control.down ? "black" : "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        ImageSvg {
            id: contentImage
            width: imgSize
            height: imgSize

            anchors.right: contentText.left
            anchors.rightMargin: imgSize/3
            anchors.verticalCenter: parent.verticalCenter

            opacity: enabled ? 1.0 : 0.3
            source: control.source
            color: Theme.colorIcon
        }
    }

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        color: control.down ? "#c1c1c1" : "#DBDBDB"
    }
}
