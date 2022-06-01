import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Rectangle {
    id: itemNoDeviceNearby
    anchors.centerIn: parent
    anchors.verticalCenterOffset: 0

    width: singleColumn ? (parent.width*0.5) : (parent.height*0.4)
    height: width
    radius: width
    color: Theme.colorForeground

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.8
        height: width

        source: "qrc:/assets/icons_material/baseline-radar-24px.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorSubText
        opacity: 0.9
        smooth: true

        NumberAnimation on rotation {
            loops: Animation.Infinite
            running: visible

            duration: 2000
            from: 0
            to: 360
        }
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: visible

            PropertyAnimation { to: 0.66; duration: 1000; }
            PropertyAnimation { to: 1; duration: 1000; }
        }
    }

    Text {
        anchors.top: parent.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("Looking for nearby devices...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContentBig
        color: Theme.colorText
    }
}
