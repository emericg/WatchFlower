import QtQuick

import ThemeEngine 1.0

Item {
    id: itemNoPermission
    anchors.fill: parent

    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -32

        width: appWindow.singleColumn ? (parent.width*0.5) : (parent.height*0.4)
        height: width
        radius: width
        color: Theme.colorForeground

        signal clicked()

        IconSvg {
            anchors.centerIn: parent
            width: parent.width*0.8
            height: width

            source: "qrc:/assets/icons_material/outline-lock-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorSubText
            opacity: 0.9
            smooth: true
        }

        Text {
            anchors.top: parent.bottom
            anchors.topMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Bluetooth permission is missing...")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentBig
            color: Theme.colorText

            ButtonWireframe {
                anchors.top: parent.bottom
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter

                fullColor: true
                text: (Qt.platform.os === "android") ? qsTr("Get permission") : qsTr("Check permission")
                onClicked: (Qt.platform.os === "android") ? utilsApp.getMobileBleLocationPermission() : deviceManager.checkBluetooth()
            }
        }
    }
}
