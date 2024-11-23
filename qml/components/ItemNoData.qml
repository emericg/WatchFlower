import QtQuick

import ComponentLibrary

Rectangle {
    id: itemNoData
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -(appHeader.height/3)

    width: singleColumn ? (parent.width*0.4) : (parent.height*0.33)
    height: width
    radius: width
    color: Theme.colorForeground
    opacity: 0.8

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.8
        height: width

        source: "qrc:/IconLibrary/material-symbols/timeline.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorIcon
        smooth: true
    }

    Text {
        anchors.top: parent.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("Not enough data...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorText
    }
}
