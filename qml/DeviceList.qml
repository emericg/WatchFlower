import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: screenDeviceList
    anchors.fill: parent

    property bool deviceAvailable: deviceManager.devices
    property bool bluetoothAvailable: deviceManager.bluetooth

    Component.onCompleted: checkStatus()
    onBluetoothAvailableChanged: checkStatus()
    onDeviceAvailableChanged: {
        checkStatus()
        exitSelectionMode()
    }

    function checkStatus() {
        if (deviceManager.bluetooth) {
            if (deviceManager.devices === false) {
                rectangleStatus.setDeviceWarning()
            } else {
                rectangleStatus.hide()
            }
        } else {
            rectangleStatus.setBluetoothWarning()
        }
    }

    property var selectionMode: false
    property var selectionList: []
    property var selectionCount: 0

    function selectDevice(index) {
        // make sure it's not already selected
        if (deviceManager.getDeviceByProxyIndex(index).selected) return;

        // then add
        selectionMode = true;
        selectionList.push(index);
        selectionCount++;

        deviceManager.getDeviceByProxyIndex(index).selected = true;
    }
    function deselectDevice(index) {
        var i = selectionList.indexOf(index);
        if (i > -1) { selectionList.splice(i, 1); selectionCount--; }
        if (selectionList.length <= 0 || selectionCount <= 0) { exitSelectionMode() }

        deviceManager.getDeviceByProxyIndex(index).selected = false;
    }
    function exitSelectionMode() {
        selectionMode = false;
        selectionList = [];
        selectionCount = 0;

        for (var i = 0; i < devicesView.count; i++) {
            deviceManager.getDeviceByProxyIndex(i).selected = false;
        }
    }

    function updateSelectedDevice() {
        for (var i = 0; i < devicesView.count; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                deviceManager.updateDevice(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function removeSelectedDevice() {
        var devicesAddr = [];
        for (var i = 0; i < devicesView.count; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                devicesAddr.push(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        for (var count = 0; count < devicesAddr.length; count++) {
            deviceManager.removeDevice(devicesAddr[count])
        }
        exitSelectionMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    PopupDeleteDevice {
        id: confirmDeleteDevice
        onConfirmed: screenDeviceList.removeSelectedDevice()
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: rowbar
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        z: 2

        ////////////////

        Rectangle {
            id: rectangleStatus
            anchors.left: parent.left
            anchors.right: parent.right

            color: Theme.colorActionbar
            clip: true

            height: 0
            Behavior on height { NumberAnimation { duration: 133 } }

            // prevent clicks below this area
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

            Text {
                id: textStatus
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
                id: buttonBluetooth
                width: 128
                height: 32
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                visible: false
                fullColor: true
                primaryColor: Theme.colorActionbarHighlight

                text: (Qt.platform.os === "android") ? qsTr("Enable") : qsTr("Retry")
                onClicked: (Qt.platform.os === "android") ? deviceManager.enableBluetooth() : deviceManager.checkBluetooth()
            }

            function hide() {
                rectangleStatus.height = 0
                itemStatus.source = ""
            }
            function setBluetoothWarning() {
                if (deviceManager.devices) {
                    rectangleStatus.height = 48

                    textStatus.text = qsTr("Bluetooth disabled...");
                    buttonBluetooth.visible = true
                } else {
                    itemStatus.source = "ItemNoBluetooth.qml"
                }
            }
            function setDeviceWarning() {
                itemStatus.source = "ItemNoDevice.qml"
            }
        }

        ////////////////

        Rectangle {
            id: rectangleActions
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            color: Theme.colorActionbar
            clip: true

            height: (screenDeviceList.selectionCount) ? 48 : 0
            Behavior on height { NumberAnimation { duration: 133 } }

            // prevent clicks below this area
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ItemImageButton {
                    id: buttonClear
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-close-24px.svg"
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: screenDeviceList.exitSelectionMode()
                }

                Text {
                    id: textActions
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("%n device(s) selected", "", screenDeviceList.selectionCount)
                    color: Theme.colorActionbarContent
                    font.bold: true
                    font.pixelSize: Theme.fontSizeComponent
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ButtonCompactable {
                    id: buttonRefresh
                    height: !wideMode ? 36 : 34
                    anchors.verticalCenter: parent.verticalCenter
                    visible: deviceManager.bluetooth

                    compact: !wideMode
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: screenDeviceList.updateSelectedDevice()

                    text: qsTr("Refresh")
                    source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"

                    animation: "rotate"
                    animationRunning: deviceManager.refreshing
                }

                ButtonCompactable {
                    id: buttonDelete
                    height: compact ? 36 : 34
                    anchors.verticalCenter: parent.verticalCenter
                    visible: deviceManager.bluetooth

                    compact: !wideMode
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: confirmDeleteDevice.open()

                    text: qsTr("Delete")
                    source: "qrc:/assets/icons_material/baseline-delete-24px.svg"
                }
            }
        }
    }

    ////////////////

    GridView {
        id: devicesView

        anchors.top: rowbar.bottom
        anchors.topMargin: singleColumn ? 2 : 9
        anchors.left: screenDeviceList.left
        anchors.leftMargin: 6
        anchors.right: screenDeviceList.right
        anchors.rightMargin: 6
        anchors.bottom: screenDeviceList.bottom
        anchors.bottomMargin: 9

        property bool singleColumn: true
        property bool bigWidget: settingsManager.bigWidget || (isTablet && width >= 480)
        property int boxHeight: bigWidget ? 140 : 100

        property int cellSizeTarget: bigWidget ? 400 : 300
        property int cellSize: cellSizeTarget
        property int cellMarginTarget: 0
        property int cellMargin: cellMarginTarget

        cellWidth: cellSizeTarget + cellMarginTarget
        cellHeight: boxHeight + cellMarginTarget

        function computeCellSize() {
            cellSizeTarget = bigWidget ? 400 : 300
            boxHeight = bigWidget ? 140 : 100

            var availableWidth = devicesView.width - cellMarginTarget

            if (isTablet) { // FIXME hacky...
                if (devicesView.width > 350)
                    cellSizeTarget = 350
                else
                    cellSizeTarget = 300
            }

            var cellColumnsTarget = Math.trunc(availableWidth / (cellSizeTarget + cellMarginTarget))
            singleColumn = (cellColumnsTarget === 1)
            // 1 // Adjust only cellSize
            cellSize = ((availableWidth - (cellMarginTarget * cellColumnsTarget)) / cellColumnsTarget)
            // Recompute
            cellWidth = cellSize + cellMargin
            cellHeight = boxHeight + cellMarginTarget
        }

        ScrollBar.vertical: ScrollBar {
            visible: isDesktop
            anchors.right: parent.right
            anchors.rightMargin: -6
            policy: ScrollBar.AsNeeded
        }

        onBigWidgetChanged: computeCellSize()
        onWidthChanged: computeCellSize()

        model: deviceManager.devicesList
        delegate: DeviceWidget {
            width: devicesView.cellSize
            height: devicesView.boxHeight
            singleColumn: devicesView.singleColumn
            bigAssMode: devicesView.bigWidget
        }
    }

    Loader {
        id: itemStatus
        anchors.fill: parent
        asynchronous: true
    }
}
