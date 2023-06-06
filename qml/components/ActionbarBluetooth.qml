import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: actionbarBluetoothStatus
    anchors.left: parent.left
    anchors.right: parent.right

    height: 0
    Behavior on height { NumberAnimation { duration: 133 } }

    clip: true
    visible: (height > 0)
    color: Theme.colorActionbar

    function hide() {
        actionbarBluetoothStatus.height = 0
    }
    function setBluetoothWarning() {
        textBluetoothStatus.text = qsTr("Bluetooth is disabled...")
        actionbarBluetoothStatus.height = 52
    }
    function setPermissionWarning() {
        textBluetoothStatus.text = qsTr("Bluetooth permission is missing...")
        actionbarBluetoothStatus.height = 52
    }

    ////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////

    Text {
        id: textBluetoothStatus
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        color: Theme.colorActionbarContent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.bold: isDesktop ? true : false
        font.pixelSize: Theme.fontSizeComponent
    }

    ButtonWireframe {
        id: buttonBluetoothStatus
        height: 32
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        fullColor: true
        primaryColor: Theme.colorActionbarHighlight

        text: {
            if (Qt.platform.os === "android") {
                if (!deviceManager.bluetoothEnabled) return qsTr("Enable")
                else if (!deviceManager.bluetoothPermissions) return qsTr("About")
            }
            return qsTr("Retry")
        }
        onClicked: {
            if (Qt.platform.os === "android" && !deviceManager.bluetoothPermissions) {
                //utilsApp.getMobileBleLocationPermission()
                //deviceManager.checkBluetoothPermissions()

                // someone clicked 'never ask again'?
                screenPermissions.loadScreenFrom("DeviceList")
            } else {
                deviceManager.enableBluetooth(settingsManager.bluetoothControl)
            }
        }
    }

    ////////////////
}
