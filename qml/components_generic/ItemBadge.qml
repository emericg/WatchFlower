import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Item {
    id: badge
    implicitWidth: 128
    implicitHeight: 24
    clip: true

    signal clicked()
    property string legend: "legend"
    property string text: "text"

    Rectangle {
        id: leftRect
        color: "#555555"
        anchors.right: leftText.right
        anchors.rightMargin: -6
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }

    Rectangle {
        id: rightRect
        color: "#97ca00"
        anchors.left: leftRect.right
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
    }

    Text {
        id: leftText
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        color: "white"
        text: badge.legend
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 12
    }

    Text {
        id: rightText
        anchors.right: rightRect.right
        anchors.rightMargin: 6
        anchors.left: rightRect.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        color: "white"
        text: badge.text
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 12
        font.bold: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: badge.clicked()
    }
}
