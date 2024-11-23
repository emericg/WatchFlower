import QtQuick
import QtQuick.Controls

import ComponentLibrary

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

    function setPermissionWarning() {
        textBluetoothStatus.text = qsTr("Bluetooth permission is missing...")
        actionbarBluetoothStatus.height = 52
    }
    function setAdapterWarning() {
        textBluetoothStatus.text = qsTr("Bluetooth adapter not found...")
        actionbarBluetoothStatus.height = 52
    }
    function setBluetoothWarning() {
        textBluetoothStatus.text = qsTr("Bluetooth is disabled...")
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
        font.pixelSize: Theme.componentFontSize
    }

    ButtonFlat {
        id: buttonBluetoothStatus
        height: 32
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        color: Theme.colorActionbarHighlight

        text: {
            if (!deviceManager.bluetoothPermissions) return qsTr("Request")
            if (Qt.platform.os === "android") {
                if (!deviceManager.bluetoothEnabled) return qsTr("Enable")
            }
            return qsTr("Retry")
        }
        onClicked: {
            if (!deviceManager.bluetoothPermissions) {
                deviceManager.requestBluetoothPermissions()
            }
            if (!deviceManager.bluetoothEnabled) {
                deviceManager.enableBluetooth(settingsManager.bluetoothControl)
            }
            deviceManager.checkBluetooth()
        }
    }

    ////////////////
}
