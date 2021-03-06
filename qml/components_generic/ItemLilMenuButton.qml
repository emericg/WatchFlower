import QtQuick 2.12

import ThemeEngine 1.0

Item {
    id: itemLilMenuButton
    implicitWidth: 96
    implicitHeight: 32

    width: 16 + contentText.width + sourceSize + 16
    height: parent.height

    signal clicked()
    property bool selected: false
    property bool highlighted: false

    property string colorBackground: Theme.colorComponent
    property string colorBackgroundHighlight: Theme.colorHighContrast
    property string colorContent: Theme.colorComponentContent
    property string colorContentHighlight: Theme.colorComponentContent

    property string text: ""
    property url source: ""
    property int sourceSize: (source.length) ? 32 : 0

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: parent.clicked()

        hoverEnabled: true
        onEntered: parent.highlighted = true
        onExited: parent.highlighted = false
    }

    Rectangle {
        id: bgHightlight
        anchors.fill: parent

        visible: parent.selected
        opacity: 0.1
        color: parent.colorContent
    }

    Rectangle {
        id: bgFocus
        anchors.fill: parent

        opacity: mouseArea.isHovered ? 0.1 : 0
        color: parent.colorBackgroundHighlight
        Behavior on opacity { OpacityAnimator { duration: 233 } }
    }

    ImageSvg {
        id: contentImage
        width: parent.sourceSize
        height: parent.sourceSize
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        source: parent.source
        color: (parent.selected) ? parent.colorContentHighlight : parent.colorContent
        opacity: (parent.selected) ? 1 : 0.5
    }

    Text {
        id: contentText
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        text: parent.text
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeComponent
        verticalAlignment: Text.AlignVCenter

        color: (parent.selected) ? parent.colorContentHighlight : parent.colorContent
        opacity: (parent.selected) ? 1 : 0.5
    }
}
