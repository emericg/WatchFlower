import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Item {
    anchors.fill: parent

    Column {
        id: column
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -12
        spacing: -8

        IconSvg {
            width: (isDesktop || isTablet) ? 128 : (parent.width*0.333)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-timeline-24px.svg"
            color: Theme.colorSubText
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Not enough data")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorSubText
        }
    }
}
