import QtQuick

import ThemeEngine

Rectangle {
    id: itemNoPlant
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -40

    width: singleColumn ? (parent.width*0.5) : (parent.height*0.4)
    height: width
    radius: width
    color: Theme.colorForeground

    signal clicked()

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.66
        height: width

        source: "qrc:/assets/gfx/icons/pot_flower-24px.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorIcon
        opacity: 0.9
    }

    Text {
        anchors.top: parent.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("No plant set...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContentBig
        color: Theme.colorText

        ButtonFlat {
            anchors.top: parent.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Let's find one!")
            onClicked: itemNoPlant.clicked()
        }
    }
}
