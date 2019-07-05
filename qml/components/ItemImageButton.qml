import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import com.watchflower.theme 1.0

Item {
    id: itemImageButton
    implicitWidth: 40
    implicitHeight: 40

    signal clicked()
    property bool highlighted: false
    property bool selected: false

    // settings
    property string highlightMode: "circle" // circle / color / off
    property string highlightColor: Theme.colorHighlight2
    property string iconColor: Theme.colorIcons
    property bool background: false
    property string tooltipText: ""

    // image
    property url source: ""

    MouseArea {
        anchors.fill: parent
        onClicked: itemImageButton.clicked()

        hoverEnabled: highlightMode !== "off"
        onEntered: {
            bgRect.opacity = 1
            itemImageButton.highlighted = true
        }
        onExited: {
            bgRect.opacity = background ? 0.66 : 0
            itemImageButton.highlighted = false
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: 50
        color: parent.highlightColor
        opacity: background ? 0.66 : 0

        Behavior on opacity { OpacityAnimator { duration: 333 } }
    }

    Image {
        id: contentImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        width: Math.round(itemImageButton.width * 0.666)
        height: Math.round(itemImageButton.height * 0.666)
        opacity: itemImageButton.enabled ? 1.0 : 0.3
        visible: false

        source: itemImageButton.source
        sourceSize: Qt.size(width, height)
    }

    ColorOverlay {
        anchors.centerIn: parent
        source: contentImage
        width: contentImage.sourceSize.width
        height: contentImage.sourceSize.height
        cached: true
        opacity: itemImageButton.enabled ? 1.0 : 0.3

        //color: selected || (highlightMode === "color" && itemImageButton.highlighted) ? itemImageButton.iconColor : itemImageButton.iconColor

        color: {
            if (selected === true) {
                itemImageButton.highlightColor
            } else if (highlightMode === "color") {
                itemImageButton.highlighted ? itemImageButton.highlightColor : itemImageButton.iconColor
            } else {
                itemImageButton.iconColor
            }
        }
    }

    Text {
        id: tooltip
        anchors.left: contentImage.right
        anchors.leftMargin: (itemImageButton.width / 3)
        anchors.verticalCenter: contentImage.verticalCenter

        text: tooltipText
        color: Theme.colorText
        visible: tooltipText && highlighted
        font.pixelSize: 14
    }
}
