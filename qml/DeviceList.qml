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

    Connections {
        target: DeviceManager
        function onBluetoothChanged() { checkBluetoothStatus() }
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
        for (var i = 0; i < DeviceManager.deviceCount; i++) {
            if (DeviceManager.getDeviceByProxyIndex(i).selected) {
                DeviceManager.updateDevice(DeviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function syncSelectedDevice() {
        for (var i = 0; i < DeviceManager.deviceCount; i++) {
            if (DeviceManager.getDeviceByProxyIndex(i).selected) {
                DeviceManager.syncDevice(DeviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function removeSelectedDevice() {
        var devicesAddr = []
        for (var i = 0; i < DeviceManager.deviceCount; i++) {
            if (DeviceManager.getDeviceByProxyIndex(i).selected) {
                devicesAddr.push(DeviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
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
