import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import ThemeEngine 1.0

Item {
    id: itemLilMenuButton
    implicitWidth: 64
    implicitHeight: 32

    width: 16 + contentText.width + sourceSize + 16

    signal clicked()
    property bool selected: false
    property bool highlighted: false

    property string colorBackground: Theme.colorComponent
    property string colorHighlight: Theme.colorHighContrast
    property string colorContent: Theme.colorComponentContent

    property string text: ""
    property url source: ""
    property int sourceSize: source.isEmpty() ? 0 : implicitHeight

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()

        hoverEnabled: true
        onEntered: {
            bgFocus.opacity = 0.1
            parent.highlighted = true
        }
        onExited: {
            bgFocus.opacity = 0
            parent.highlighted = false
        }
    }
/*
    Rectangle {
        id: bgRect
        anchors.fill: parent

        color: parent.colorBackground
        radius: Theme.componentRadius
    }
*/
    Rectangle {
        id: bgHightlight
        anchors.fill: parent

        visible: parent.selected
        opacity: 0.1
        color: parent.colorContent
        radius: Theme.componentRadius
    }
    Rectangle {
        id: bgFocus
        anchors.fill: parent

        opacity: 0
        color: parent.colorHighlight
        radius: Theme.componentRadius
        Behavior on opacity { OpacityAnimator { duration: 233 } }
    }

    ImageSvg {
        id: contentImage
        width: parent.sourceSize
        height: parent.sourceSize
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        source: parent.source
        color: parent.colorContent
        opacity: (parent.selected) ? 1 : 0.5
    }
    Text {
        id: contentText
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        text: parent.text
        font.pixelSize: 15
        color: parent.colorContent
        opacity: (parent.selected) ? 1 : 0.5
        verticalAlignment: Text.AlignVCenter
    }
}
