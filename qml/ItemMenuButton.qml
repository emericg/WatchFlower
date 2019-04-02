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
            fadeIn.start()
            itemMenuButton.highlighted = true
        }
        onExited: {
            fadeIn.stop()
            fadeOut.start()
            itemMenuButton.highlighted = false
        }
    }

    Rectangle {
        id: bgFocus
        visible: highlighted
        anchors.fill: parent

        color: "#25B298"
        opacity: 0

        PropertyAnimation {
            id: fadeIn;
            targets: [bgFocus];
            property: "opacity";
            from: 0;
            to: 1;
            duration: 333
            running: false
        }
        PropertyAnimation {
            id: fadeOut;
            targets: [bgFocus];
            property: "opacity";
            from: 1;
            to: 0;
            duration: 333
            running: false
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        visible: selected
        color: Theme.colorDarkGreen
    }

    Image {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: itemMenuButton.verticalCenter

        opacity: itemMenuButton.enabled ? 1.0 : 0.3
        source: itemMenuButton.source
        sourceSize: Qt.size(width, height)

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Theme.colorTitles
        }
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
        color: Theme.colorTitles
        verticalAlignment: Text.AlignVCenter
    }
}
