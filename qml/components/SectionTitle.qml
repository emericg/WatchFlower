import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: control
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0

    height: (isDesktop && isHdpi) ? 44 : 48
    radius: singleColumn ? 0 : Theme.componentRadius
    color: Theme.colorForeground

    border.width: singleColumn ? 0 : Theme.componentBorderWidth
    border.color: Qt.darker(color, 1.03)

    property string text
    property string source

    property int fontSize: source ? Theme.fontSizeContentBig :
                                    Theme.fontSizeContentVeryBig

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: singleColumn ? 24 : 16

        IconSvg {
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            source: control.source
            visible: control.source
            color: Theme.colorIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: control.fontSize
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }
    }
}
