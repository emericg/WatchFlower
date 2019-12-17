import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import ThemeEngine 1.0

Item {
    id: itemImageButton
    implicitWidth: 40
    implicitHeight: 40

    // states
    signal clicked()
    property bool highlighted: false
    property bool selected: false

    // settings
    property string highlightMode: "circle" // circle / color / both / off
    property bool background: false

    property string iconColor: Theme.colorIcon
    property string highlightColor: Theme.colorPrimary
    property string backgroundColor: Theme.colorComponent

    property string tooltipText: ""

    // image
    property url source: ""

    MouseArea {
        anchors.fill: parent
        onClicked: itemImageButton.clicked()

        hoverEnabled: true
        onEntered: {
            bgRect.opacity = (highlightMode === "circle" || highlightMode === "both") ? 0.9 : 0.50
            itemImageButton.highlighted = true
        }
        onExited: {
            itemImageButton.highlighted = false
            bgRect.opacity = background ? 0.50 : 0
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: 50
        color: parent.backgroundColor
        opacity: background ? 0.50 : 0
        visible: (highlightMode === "circle" || highlightMode === "both" ||background)

        Behavior on opacity { OpacityAnimator { duration: 333 } }
    }

    Image {
        id: contentImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        width: Math.round(itemImageButton.width * 0.666)
        height: Math.round(itemImageButton.height * 0.666)
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

        color: {
            if (selected === true) {
                itemImageButton.highlightColor
            } else if (highlightMode === "color" || highlightMode === "both") {
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
