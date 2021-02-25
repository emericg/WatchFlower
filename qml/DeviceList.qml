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
        selectionMode = true;
        selectionList.push(index);
        selectionCount++;
    }
    function deselectDevice(index) {
        var i = selectionList.indexOf(index);
        if (i > -1) { selectionList.splice(i, 1); selectionCount--; }
        if (selectionList.length === 0) selectionMode = false;
    }
    function exitSelectionMode() {
        if (selectionList.length === 0) return;

        for (var child in devicesView.contentItem.children) {
            if (devicesView.contentItem.children[child].selected) {
                devicesView.contentItem.children[child].selected = false;
            }
        }

        selectionMode = false;
        selectionList = [];
        selectionCount = 0;
    }

    function updateSelectedDevice() {
        for (var child in devicesView.contentItem.children) {
            if (devicesView.contentItem.children[child].selected) {
                deviceManager.updateDevice(devicesView.contentItem.children[child].boxDevice.deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function removeSelectedDevice() {
        var devicesAddr = [];
        for (var child in devicesView.contentItem.children) {
            if (devicesView.contentItem.children[child].selected) {
                devicesAddr.push(devicesView.contentItem.children[child].boxDevice.deviceAddress)
            }
        }
        for (var count = 0; count < devicesAddr.length; count++) {
            deviceManager.removeDevice(devicesAddr[count])
        }
        exitSelectionMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    ItemDeletePopup {
        id: confirmDeleteDevice

        onConfirmed: screenDeviceList.removeSelectedDevice()
    }

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
                font.pixelSize: 16
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
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.bold: isDesktop ? true : false
                    font.pixelSize: 16
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                property bool useBigButtons: (!isPhone && rectangleActions.width >= 560)

                ItemImageButton {
                    id: buttonRefresh1
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    visible: !parent.useBigButtons && deviceManager.bluetooth
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: screenDeviceList.updateSelectedDevice()
                    source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"

                    NumberAnimation on rotation {
                        id: refreshAnimation
                        duration: 2000
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        running: deviceManager.refreshing
                        alwaysRunToEnd: true
                        easing.type: Easing.Linear
                    }
                }
                ItemImageButton {
                    id: buttonDelete1
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    visible: !parent.useBigButtons
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: confirmDeleteDevice.open()
                    source: "qrc:/assets/icons_material/baseline-delete-24px.svg"
                }

                ButtonWireframeImage {
                    id: buttonRefresh2
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    visible: parent.useBigButtons && deviceManager.bluetooth
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    text: qsTr("Refresh")
                    onClicked: screenDeviceList.updateSelectedDevice()
                    source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
                }
                ButtonWireframeImage {
                    id: buttonDelete2
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    visible: parent.useBigButtons
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    text: qsTr("Delete")
                    onClicked: confirmDeleteDevice.open()
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
        property int cellSize: bigWidget ? 400 : 300
        property int cellMarginTarget: 0
        property int cellMargin: 0
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

            var cellColumnsTarget = Math.trunc(availableWidth / cellSizeTarget)
            singleColumn = (cellColumnsTarget === 1)
            // 1 // Adjust only cellSize
            cellSize = (availableWidth - cellMarginTarget * cellColumnsTarget) / cellColumnsTarget
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
            width: devicesView.cellSize;
            singleColumn: devicesView.singleColumn;
            bigAssMode: devicesView.bigWidget;
        }
    }

    Loader {
        id: itemStatus
        anchors.fill: parent
        asynchronous: true
    }
}
