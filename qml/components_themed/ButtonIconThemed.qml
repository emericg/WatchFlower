import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    width: control.sourceSize + contentText.contentWidth + 36

    leftPadding: 12
    rightPadding: 12

    font.pixelSize: Theme.fontSizeComponent

    focusPolicy: Qt.NoFocus

    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: enabled ? 1 : 0.33
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
    }

    contentItem: Row {
        spacing: 8

        IconSvg {
            width: control.sourceSize
            height: control.sourceSize
            anchors.verticalCenter: parent.verticalCenter

            opacity: enabled ? 1.0 : 0.33
            source: control.source
            color: Theme.colorComponentContent
        }

        Text {
            id: contentText
            anchors.verticalCenter: parent.verticalCenter

            text: control.text
            textFormat: Text.PlainText
            font: control.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            opacity: enabled ? 1.0 : 0.33
            color: Theme.colorComponentContent
        }
    }
}
