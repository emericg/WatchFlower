import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Item {
    id: screenDeviceList
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: {
        checkStatus()
        loadList()
    }

    function backAction() {
        if (isSelected()) exitSelectionMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    property bool splitView: settingsManager.splitView
    property bool deviceAvailable: deviceManager.hasDevices
    property bool bluetoothAvailable: deviceManager.bluetooth
    property bool bluetoothPermissionsAvailable: deviceManager.bluetoothPermissions

    onBluetoothAvailableChanged: checkStatus()
    onBluetoothPermissionsAvailableChanged: checkStatus()
    onDeviceAvailableChanged: { checkStatus(); exitSelectionMode(); }
    onSplitViewChanged: loadList()

    function loadList() {
        exitSelectionMode()

        if (splitView) {
            loaderDeviceList.source = "DeviceListSplit.qml"
        } else {
            loaderDeviceList.source = "DeviceListUnified.qml"
        }

        selectionCount = Qt.binding(function() { return loaderDeviceList.item.selectionCount })
    }

    function checkStatus() {
        if (!utilsApp.checkMobileBleLocationPermission()) {
            //utilsApp.getMobileBleLocationPermission()
        }

        if (deviceManager.hasDevices) {
            // The sensor list is shown
            loaderStatus.source = ""

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

            if (!deviceManager.bluetooth) {
                loaderStatus.source = "ItemNoBluetooth.qml"
            } else {
                loaderStatus.source = "ItemNoDevice.qml"
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

    Loader {
        id: loaderStatus
        anchors.fill: parent
        asynchronous: true
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: loaderDeviceList
        anchors.fill: parent
        anchors.topMargin: rowbar.height
        asynchronous: false
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12

        active: isDesktop
        asynchronous: true

        sourceComponent: Row {
            spacing: 12

            ButtonWireframe {
                text: qsTr("devices")
                fullColor: true
                primaryColor: Theme.colorSecondary
                onClicked: screenDeviceBrowser.loadScreen()
                enabled: (deviceManager.bluetooth && deviceManager.bluetoothPermissions)
            }
            ButtonWireframe {
                text: qsTr("plants")
                fullColor: true
                primaryColor: Theme.colorPrimary
                onClicked: screenPlantBrowser.loadScreenFrom("DeviceList")
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
