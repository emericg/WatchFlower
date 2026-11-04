import QtQuick
import QtQuick.Controls

import ComponentLibrary

Item {
    id: screenDeviceList
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // check BLE status
        checkBluetoothStatus()

        // change screen
        appContent.state = "DeviceList"
    }

    function backAction() {
        if (isSelected()) exitSelectionMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    property bool filterView: false

    property bool splitView: SettingsManager.splitView
    onSplitViewChanged: loadList()

    property bool deviceAvailable: DeviceManager.hasDevices
    onDeviceAvailableChanged: loadList()

    function loadList() {
        exitSelectionMode()

        if (splitView && DeviceManager.deviceCount > 1) {
            loaderDeviceList.source = "DeviceListSplit.qml"
        } else {
            loaderDeviceList.source = "DeviceListUnified.qml"
        }

        selectionCount = Qt.binding(function() { return loaderDeviceList.item.selectionCount })
    }

    readonly property string noMatchText: qsTr("No sensors match your search")

    Connections {
        target: DeviceManager
        function onBluetoothChanged() { checkBluetoothStatus() }
        function onFilterChanged() { if (isSelected()) exitSelectionMode() }
    }

    function checkBluetoothStatus() {
        if (DeviceManager.hasDevices) {
            // The device list is shown
            loaderItemStatus.source = ""

            if (!DeviceManager.bluetoothPermissions) {
                actionbarBluetoothStatus.setPermissionWarning()
            } else if (!DeviceManager.bluetoothAdapter) {
                actionbarBluetoothStatus.setAdapterWarning()
            } else if (!DeviceManager.bluetoothEnabled) {
                actionbarBluetoothStatus.setBluetoothWarning()
            } else {
                actionbarBluetoothStatus.hide()
            }
        } else {
            // The sensor list is not populated
            actionbarBluetoothStatus.hide()

            if (!DeviceManager.bluetoothPermissions) {
                loaderItemStatus.source = "components/ItemNoPermissions.qml"
            } else if (!DeviceManager.bluetoothAdapter || !DeviceManager.bluetoothEnabled) {
                loaderItemStatus.source = "components/ItemNoBluetooth.qml"
            } else {
                loaderItemStatus.source = "components/ItemNoDevice.qml"
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    property int selectionCount: 0

    function isSelected() {
        if (loaderDeviceList.status !== Loader.Ready) return false
        return loaderDeviceList.item.isSelected()
    }
    function exitSelectionMode() {
        if (loaderDeviceList.status !== Loader.Ready) return
        loaderDeviceList.item.exitSelectionMode()
    }

    function updateSelectedDevice() {
        var devicesAddr = DeviceManager.getSelectedDeviceAddresses()
        for (var i = 0; i < devicesAddr.length; i++) {
            DeviceManager.updateDevice(devicesAddr[i])
        }
        exitSelectionMode()
    }
    function syncSelectedDevice() {
        var devicesAddr = DeviceManager.getSelectedDeviceAddresses()
        for (var i = 0; i < devicesAddr.length; i++) {
            DeviceManager.syncDevice(devicesAddr[i])
        }
        exitSelectionMode()
    }
    function removeSelectedDevice() {
        var devicesAddr = DeviceManager.getSelectedDeviceAddresses()
        for (var count = 0; count < devicesAddr.length; count++) {
            DeviceManager.removeDevice(devicesAddr[count])
        }
        exitSelectionMode()
    }

    PopupDeleteDevice {
        id: confirmDeleteDevice
        onConfirmed: removeSelectedDevice()
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: rowbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 2

        ////////

        ActionbarBluetooth {
            id: actionbarBluetoothStatus
            anchors.left: parent.left
            anchors.right: parent.right
        }

        ////////

        ActionbarSelection {
            id: actionbarSelection
            anchors.left: parent.left
            anchors.right: parent.right
        }

        ////////

        ActionbarFilter {
            id: actionbarFilter
            anchors.left: parent.left
            anchors.right: parent.right
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: loaderDeviceList
        anchors.fill: parent
        anchors.topMargin: rowbar.height

        visible: DeviceManager.hasDevices
        asynchronous: false
    }

    ////////

    Loader {
        id: loaderItemStatus
        anchors.fill: parent

        visible: !DeviceManager.hasDevices
        asynchronous: true
    }

    ////////////////////////////////////////////////////////////////////////////
}
