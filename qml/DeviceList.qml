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

import QtQuick 2.7
import QtQuick.Controls 2.0

import com.watchflower.theme 1.0

Item {
    id: background
    anchors.fill: parent
    clip: true

    property bool deviceScanning: deviceManager.scanning
    property bool deviceAvailable: deviceManager.devices
    property bool bluetoothAvailable: deviceManager.bluetooth

    onDeviceScanningChanged: {
        //
    }
    onDeviceAvailableChanged: {
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
    onBluetoothAvailableChanged: {
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

    Rectangle {
        id: rectangleStatus
        height: 52
        color: Theme.colorYellow
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

        Text {
            id: textStatus
            color: "white"
            text: ""
            anchors.rightMargin: 16
            anchors.leftMargin: 16
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            anchors.fill: parent
            font.pixelSize: 20
        }

        ThemedButton {
            id: buttonBluetooth
            width: 128
            height: 30
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Try again")
            color: "white"
            opacity: 0.9

            onClicked: {
                deviceManager.enableBluetooth()
                deviceManager.checkBluetooth()
            }
        }
        ThemedButton {
            id: buttonSearch
            width: 128
            height: 30
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Scan devices")
            color: "white"
            opacity: 0.9

            onClicked: {
                deviceManager.scanDevices()
            }
        }

        function hide() {
            rectangleStatus.visible = false;
            rectangleStatus.height = 0;

            itemStatus.source = ""
        }
        function setBluetoothWarning() {
            rectangleStatus.visible = true;
            rectangleStatus.height = 52;

            itemStatus.source = "ItemNoBluetooth.qml"
            textStatus.text = qsTr("No bluetooth :-(");
            buttonBluetooth.visible = true
            buttonSearch.visible = false
        }
        function setDeviceWarning() {
            rectangleStatus.visible = true;
            rectangleStatus.height = 52;

            itemStatus.source = "ItemNoDevice.qml"
            textStatus.text = qsTr("No devices :-(");
            buttonBluetooth.visible = false
            buttonSearch.visible = true
        }
    }

    Loader {
        id: itemStatus
        width: 256
        height: 256
        anchors.verticalCenterOffset: 26
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    GridView {
        id: devicesview

        anchors.fill: parent
        anchors.topMargin: rectangleStatus.height + 6
        anchors.bottomMargin: 6
        anchors.leftMargin: 6
        anchors.rightMargin: 6

        property int boxHeight: 100
        property bool singleColumn: true

        property int cellSizeTarget: 300
        property int cellSize: 300
        property int cellMarginTarget: 0
        property int cellMargin: 0
        cellWidth: cellSizeTarget + cellMarginTarget
        cellHeight: boxHeight + cellMarginTarget

        function computeCellSize() {
            var availableWidth = devicesview.width - cellMarginTarget
            var cellColumnsTarget = Math.trunc(availableWidth / cellSizeTarget)
            singleColumn = (cellColumnsTarget === 1)
            // 1 // Adjust only cellSize
            cellSize = (availableWidth - cellMarginTarget * cellColumnsTarget) / cellColumnsTarget
            // Recompute
            cellWidth = cellSize + cellMargin
            cellHeight = boxHeight + cellMarginTarget
        }

        onWidthChanged: computeCellSize()
        model: deviceManager.devicesList
        delegate: DeviceWidget { boxDevice: modelData; width: devicesview.cellSize; singleColumn: devicesview.singleColumn }
    }
}
