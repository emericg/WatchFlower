import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Item {
    anchors.fill: parent

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -20
        spacing: 16

        IconSvg {
            width: (isDesktop || isTablet || (isPhone && appWindow.screenOrientation === Qt.LandscapeOrientation)) ? 256 : (parent.width*0.666)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcon
        }

        ButtonWireframe {
            anchors.horizontalCenter: parent.horizontalCenter
            fullColor: true
            text: (Qt.platform.os === "android") ? qsTr("Enable Bluetooth") : qsTr("Retry detection")
            onClicked: (Qt.platform.os === "android") ? deviceManager.enableBluetooth() : deviceManager.checkBluetooth()
        }
    }
}
