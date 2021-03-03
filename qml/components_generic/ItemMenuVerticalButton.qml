import QtQuick 2.12
import QtGraphicalEffects 1.0

import ThemeEngine 1.0

Item {
    id: itemMenuButton
    implicitWidth: 80
    implicitHeight: 48

    property int imgSize: 32

    signal clicked()
    property bool selected: false
    property bool highlighted: false

    property string colorContent: Theme.colorHeaderContent
    property string colorBackground: Theme.colorForeground
    property string highlightMode: "background" // available: background & text

    property string menuText: ""
    property url source: ""

    MouseArea {
        anchors.fill: parent
        onClicked: itemMenuButton.clicked()

        hoverEnabled: true
        onEntered: {
            bgFocus.opacity = 0.5
            itemMenuButton.highlighted = true
        }
        onExited: {
            bgFocus.opacity = 0
            itemMenuButton.highlighted = false
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent

        visible: (selected && highlightMode === "background")
        color: parent.colorBackground
    }
    Rectangle {
        id: bgFocus
        anchors.fill: parent

        visible: (highlightMode === "background")
        color: itemMenuButton.colorBackground
        opacity: 0
        Behavior on opacity { OpacityAnimator { duration: 250 } }
    }

    ImageSvg {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.horizontalCenter: itemMenuButton.horizontalCenter
        anchors.verticalCenter: itemMenuButton.verticalCenter
        anchors.verticalCenterOffset: -8

        source: itemMenuButton.source
        color: (!selected && highlightMode === "text") ? itemMenuButton.colorBackground : itemMenuButton.colorContent
        opacity: itemMenuButton.enabled ? 1.0 : 0.3
    }

    Text {
        id: contentText
        height: parent.height
        anchors.top: contentImage.bottom
        anchors.topMargin: -4
        anchors.verticalCenter: itemMenuButton.verticalCenter

        text: menuText
        font.pixelSize: 14
        font.bold: true
        color: (!selected && highlightMode === "text") ? itemMenuButton.colorBackground : itemMenuButton.colorContent
        verticalAlignment: Text.AlignVCenter
    }
}
