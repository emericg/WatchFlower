import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Item {
    id: screenDeviceList
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // change screen
        appContent.state = "DeviceList"
    }

    function backAction() {
        if (isSelected()) exitSelectionMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    property bool splitView: settingsManager.splitView
    onSplitViewChanged: loadList()

    property bool deviceAvailable: deviceManager.hasDevices
    onDeviceAvailableChanged: loadList()

    function loadList() {
        exitSelectionMode()

        if (splitView && deviceManager.deviceCount > 1) {
            loaderDeviceList.source = "DeviceListSplit.qml"
        } else {
            loaderDeviceList.source = "DeviceListUnified.qml"
        }

        selectionCount = Qt.binding(function() { return loaderDeviceList.item.selectionCount })
    }

    Connections {
        target: deviceManager
        function onBluetoothChanged() {
            if (deviceManager.hasDevices) {
                if (!deviceManager.bluetooth) {
                    rectangleBluetoothStatus.setBluetoothWarning()
                } else if (!deviceManager.bluetoothPermissions) {
                    rectangleBluetoothStatus.setPermissionWarning()
                } else {
                    rectangleBluetoothStatus.hide()
                }
            } else {
                // The sensor list is not populated
                rectangleBluetoothStatus.hide()
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
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                deviceManager.updateDevice(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function syncSelectedDevice() {
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                deviceManager.syncDevice(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function removeSelectedDevice() {
        var devicesAddr = []
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                devicesAddr.push(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        for (var count = 0; count < devicesAddr.length; count++) {
            deviceManager.removeDevice(devicesAddr[count])
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

        ////////////////

        ActionbarBluetooth {
            id: rectangleBluetoothStatus
            anchors.left: parent.left
            anchors.right: parent.right
        }

        ////////////////

        ActionbarSelection {
            id: rectangleSelections
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ItemNoDevice {
        id: itemNoDevice
        anchors.fill: parent
        visible: !deviceManager.hasDevices
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: loaderDeviceList
        anchors.fill: parent
        anchors.topMargin: rowbar.height
        asynchronous: false
    }

    ////////////////////////////////////////////////////////////////////////////
}
