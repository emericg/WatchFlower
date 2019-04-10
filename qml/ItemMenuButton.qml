import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

import com.watchflower.theme 1.0

Item {
    id: itemMenuButton
    implicitWidth: 64
    implicitHeight: 64

    signal clicked()
    property bool selected: false
    property bool highlighted: false

    property string menuText: ""
    property string tooltipText: ""
    property url source: ""
    property int imgSize: 32

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
        visible: selected
        color: Theme.colorDarkGreen
    }

    Rectangle {
        id: bgFocus
        anchors.fill: parent

        color: Theme.colorDarkGreen
        opacity: 0

        Behavior on opacity {
            OpacityAnimator {
                duration: 250
            }
        }
    }

    ImageSvg {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: itemMenuButton.verticalCenter

        opacity: itemMenuButton.enabled ? 1.0 : 0.3
        source: itemMenuButton.source
        color: "white"
    }

    Text {
        id: contentText
        height: parent.height
        anchors.left: contentImage.right
        anchors.leftMargin: 16
        anchors.verticalCenter: itemMenuButton.verticalCenter

        text: menuText
        font.pixelSize: 16
        font.bold: true
        color: "white"
        verticalAlignment: Text.AlignVCenter
    }
}
