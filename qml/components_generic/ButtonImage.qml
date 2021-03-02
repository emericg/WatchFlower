import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Button {
    id: control
    width: contentText.width + imgSize*3
    implicitHeight: Theme.componentHeight

    font.pixelSize: Theme.fontSizeComponent

    focusPolicy: Qt.NoFocus

    property url source: ""
    property int imgSize: UtilsNumber.alignTo(height * 0.666, 2)

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: 40
        opacity: enabled ? 1 : 0.33
        color: control.down ? "#c1c1c1" : "#DBDBDB"
    }

    contentItem: Item {
        Text {
            id: contentText
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: ((imgSize / 2) + (imgSize / 6))

            text: control.text
            textFormat: Text.PlainText
            font: control.font
            opacity: enabled ? 1.0 : 0.33
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
            anchors.rightMargin: (imgSize / 3)
            anchors.verticalCenter: parent.verticalCenter

            opacity: enabled ? 1.0 : 0.33
            source: control.source
            color: control.down ? "black" : "black"
        }
    }
}
