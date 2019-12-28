/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2

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
        width: (applicationWindow.width < 480) ? applicationWindow.width : 480
        height: 180
        x: (applicationWindow.width / 2) - (confirmDeleteDevice.width / 2)
        y: (applicationWindow.height / 2) - (confirmDeleteDevice.height / 2) - appHeader.height

        onConfirmed: {
            // actual device deletion
            screenDeviceList.removeSelectedDevice()
        }
    }

    Column {
        id: rowbar
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        z: 2

        ////////////////

        Rectangle {
            id: rectangleStatus
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            height: 48
            color: Theme.colorActionbar
            visible: false
            opacity: 0
/*
            Behavior on opacity {
                OpacityAnimator {
                    duration: 333;
                    onStopped: {
                        console.log("opacity on stopped")
                        if (rectangleStatus.opacity === 0)
                            rectangleStatus.visible = false
                    }
                    onFinished: { // Qt 5.12 :(
                        console.log("opacity on finished")
                        if (rectangleStatus.opacity === 0)
                            rectangleStatus.visible = false
                    }
                }
            }
*/
            Text {
                id: textStatus
                anchors.fill: parent
                anchors.rightMargin: 16
                anchors.leftMargin: 16

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
                text: (Qt.platform.os === "android") ? qsTr("Enable") : qsTr("Retry")
                fullColor: true
                primaryColor: Theme.colorActionbarHighlight

                onClicked: (Qt.platform.os === "android") ? deviceManager.enableBluetooth() : deviceManager.checkBluetooth()
            }

            function hide() {
                rectangleStatus.visible = false;
                rectangleStatus.opacity = 0;

                itemStatus.source = ""
            }
            function setBluetoothWarning() {
                if (deviceManager.devices) {
                    rectangleStatus.visible = true;
                    rectangleStatus.opacity = 1;

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
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            height: 48
            color: Theme.colorActionbar
            visible: (screenDeviceList.selectionCount)

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
                    font.bold: true
                    font.pixelSize: 16
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ItemImageButton {
                    id: buttonRefresh
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    visible: deviceManager.bluetooth
                    source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: screenDeviceList.updateSelectedDevice()

                    NumberAnimation on rotation {
                        id: refreshAnimation
                        duration: 2000
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        running: deviceManager.refreshing
                        onStopped: refreshAnimationStop.start()
                    }
                    NumberAnimation on rotation {
                        id: refreshAnimationStop
                        duration: 1000
                        to: 360
                        easing.type: Easing.Linear
                        running: false
                    }
                }
                ItemImageButton {
                    id: buttonDelete
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-delete-24px.svg"
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: confirmDeleteDevice.open()
                }
/*
                ButtonWireframe {
                    id: buttonRefresh
                    width: 96
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    primaryColor: Theme.colorActionbarHighlight
                    text: qsTr("Refresh")
                    onClicked: screenDeviceList.updateSelectedDevice()
                }
                ButtonWireframe {
                    id: buttonDelete
                    width: 96
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    primaryColor: Theme.colorActionbarHighlight
                    text: qsTr("Delete")
                    onClicked: screenDeviceList.removeSelectedDevice()
                }
*/
            }
        }
    }

    ////////////////

    GridView {
        id: devicesView

        anchors.top: rowbar.bottom
        anchors.topMargin: singleColumn ? 2 : 8
        anchors.left: screenDeviceList.left
        anchors.leftMargin: 6
        anchors.right: screenDeviceList.right
        anchors.rightMargin: 6
        anchors.bottom: screenDeviceList.bottom
        anchors.bottomMargin: 6

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

        onBigWidgetChanged: computeCellSize()
        onWidthChanged: computeCellSize()

        model: deviceManager.devicesList
        delegate: DeviceWidget { boxDevice: modelData; width: devicesView.cellSize; singleColumn: devicesView.singleColumn; bigAssMode: devicesView.bigWidget; }
    }

    Loader {
        id: itemStatus
        anchors.fill: parent
    }
}
