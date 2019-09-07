import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import com.watchflower.theme 1.0

Button {
    id: control
    width: contenttext.width + imgSize*3
    implicitWidth: 128
    implicitHeight: 40

    font.pixelSize: Theme.fontSizeContent

    property url source: ""
    property int imgSize: 24

    property string color: Theme.colorText
    property bool selected: false

    contentItem: Item {
        Text {
            id: contenttext
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: (imgSize/2 + imgSize/6)

            text: control.text
            font: control.font
            opacity: enabled ? 1.0 : 0.3
            color: control.color
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        ImageSvg {
            id: contentimage
            width: imgSize
            height: imgSize

            anchors.right: contenttext.left
            anchors.rightMargin: imgSize/3
            anchors.verticalCenter: parent.verticalCenter

            opacity: enabled ? 0.9 : 0.3
            source: control.source
            color: control.color
        }
    }

    background: Rectangle {
        radius: 4
        color: "transparent"
        opacity: enabled ? 0.3 : 0.6

        border.width: 2
        border.color: control.color

        Rectangle {
            radius: 4
            anchors.fill: parent
            opacity: (control.down) ? 0.5 : 0.1
            color: (control.down || control.selected) ? (control.color) : "transparent"
        }
    }
}
