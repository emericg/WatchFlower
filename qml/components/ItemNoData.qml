import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: itemNoData
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -32

    width: singleColumn ? (parent.width*0.4) : (parent.height*0.33)
    height: width
    radius: width
    color: Theme.colorForeground
    opacity: 0.8

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.8
        height: width

        source: "qrc:/assets/icons_material/baseline-timeline-24px.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorSubText
        smooth: true
    }

    Text {
        anchors.top: parent.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("Not enough data...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorText
    }
}
