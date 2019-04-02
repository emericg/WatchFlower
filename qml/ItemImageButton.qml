import QtQuick 2.7
import QtQuick.Controls 2.0
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
    property string highlightColor: "#25B298"
    property string iconColor: Theme.iconColor
    property bool background: false
    property string tooltipText: ""

    // image
    property url source: ""

    MouseArea {
        anchors.fill: parent
        onClicked: itemImageButton.clicked()

        hoverEnabled: highlightMode !== "off"
        onEntered: {
            fadeIn.start()
            itemImageButton.highlighted = true
        }
        onExited: {
            fadeIn.stop()
            fadeOut.start()
            itemImageButton.highlighted = false
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: 50
        color: parent.highlightColor
        opacity: background ? 0.66 : 0

        PropertyAnimation {
            id: fadeIn;
            targets: [bgRect, tooltip];
            property: "opacity";
            from: background ? 0.66 : 0;
            to: 1;
            duration: 333;
            running: false;
        }
        PropertyAnimation {
            id: fadeOut;
            targets: [bgRect, tooltip];
            property: "opacity";
            from: 1;
            to: background ? 0.66 : 0;
            duration: 333;
            running: false;
        }
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
        font.pointSize: 12
    }
}
