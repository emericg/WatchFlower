import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Button {
    id: control
    width: contentRow.width + 16 + (source && !text ? 0 : 16)
    implicitHeight: Theme.componentHeight

    font.pixelSize: Theme.fontSizeComponent
    font.bold: false

    focusPolicy: Qt.NoFocus

    property url source: ""
    property int imgSize: UtilsNumber.alignTo(height * 0.666, 2)

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        opacity: enabled ? 1 : 0.33
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
    }

    contentItem: Item {
        Row {
            id: contentRow
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            ImageSvg {
                id: contentImage
                width: imgSize
                height: imgSize
                anchors.verticalCenter: parent.verticalCenter

                visible: source
                opacity: enabled ? 1.0 : 0.33
                source: control.source
                color: Theme.colorIcon
            }

            Text {
                id: contentText
                anchors.verticalCenter: parent.verticalCenter

                text: control.text
                textFormat: Text.PlainText
                font: control.font
                opacity: enabled ? 1.0 : 0.33
                color: control.down ? Theme.colorComponentContent : Theme.colorComponentContent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
}
