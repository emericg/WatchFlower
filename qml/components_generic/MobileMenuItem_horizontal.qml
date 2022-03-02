import QtQuick 2.15
import QtQuick.Layouts 1.15

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 48
    implicitHeight: 48

    width: Math.max(parent.height, content.width + 24)
    height: parent.height

    // actions
    signal clicked()
    signal pressAndHold()

    // states
    property bool pressed: false
    property bool selected: false

    // settings
    property string text
    property url source
    property int sourceSize: 24

    // colors
    property string colorContent: Theme.colorTabletmenuContent
    property string colorHighlight: Theme.colorTabletmenuHighlight

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: false

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()
    }

    ////////////////////////////////////////////////////////////////////////////

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: appWindow.isPhone ? 6 : 12

        IconSvg {
            id: contentImage
            width: control.sourceSize
            height: control.sourceSize

            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize

            visible: source.toString().length

            source: control.source
            color: control.selected ? control.colorHighlight : control.colorContent
            opacity: control.enabled ? 1.0 : 0.33
        }

        Text {
            id: contentText
            height: parent.height

            visible: text

            text: control.text
            textFormat: Text.PlainText
            color: control.selected ? control.colorHighlight : control.colorContent
            font.pixelSize: Theme.fontSizeComponent
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
