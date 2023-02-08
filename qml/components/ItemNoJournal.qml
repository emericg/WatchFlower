import QtQuick

import ThemeEngine 1.0

Rectangle {
    id: itemNoJournal
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -48

    width: singleColumn ? (parent.width*0.5) : (parent.height*0.4)
    height: width
    radius: width
    color: Theme.colorForeground

    signal clicked()

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.66
        height: width

        source: "qrc:/assets/icons_material/baseline-import_contacts-24px.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorSubText
        opacity: 0.9
        smooth: true
    }

    Text {
        anchors.top: parent.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("No log entry...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContentBig
        color: Theme.colorText

        ButtonWireframe {
            anchors.top: parent.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter

            fullColor: true
            text: qsTr("Let's start!")
            onClicked: itemNoJournal.clicked()
        }
    }
}
