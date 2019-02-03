/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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

import app.watchflower.theme 1.0

Rectangle {
    id: background
    anchors.fill: parent
    color: Theme.colorMaterialLightGrey

    property bool deviceScanning: deviceManager.scanning
    property bool bluetoothAvailable: deviceManager.bluetooth

    Component.onCompleted: {
        if (deviceManager.bluetooth === false) {
            rectangleStatus.setError(qsTr("No bluetooth :-("))
        } else if (deviceManager.areDevicesAvailable() === false) {
            rectangleStatus.setStatus(qsTr("No devices :-("))
        } else {
            rectangleStatus.hide()
        }
    }

    onDeviceScanningChanged: {
        if (!deviceManager.scanning) {
            if (deviceManager.areDevicesAvailable()) {
                rectangleStatus.hide()
            } else {
                rectangleStatus.setStatus(qsTr("No devices :-("))
            }
        }
    }

    onBluetoothAvailableChanged: {
        if (deviceManager.bluetooth) {
            if (deviceManager.areDevicesAvailable() === false) {
                rectangleStatus.setStatus(qsTr("No devices :-("))
            } else {
                rectangleStatus.hide()
            }
        } else {
            rectangleStatus.setError(qsTr("No bluetooth :-("))
        }
    }

    Rectangle {
        id: rectangleStatus
        height: 48
        color: Theme.colorMaterialOrange
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

        Text {
            id: textStatus
            color: "#ffffff"
            text: qsTr("Status :-(")
            anchors.rightMargin: 16
            anchors.leftMargin: 16
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            anchors.fill: parent
            font.pixelSize: 20
        }

        Button {
            id: buttonEnables
            width: 128
            height: 30
            text: qsTr("Enables")
            opacity: 0.8
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            onClicked: deviceManager.checkBluetooth()
        }

        function hide() {
            rectangleStatus.visible = false;
            rectangleStatus.height = 0;
        }
        function setError(message) {
            rectangleStatus.visible = true;
            rectangleStatus.height = 48;
            textStatus.text = message;

            if (!deviceManager.hasBluetooth()) {
                buttonEnables.visible = true
            } else {
                buttonEnables.visible = false
            }
        }
        function setStatus(message) {
            rectangleStatus.visible = true;
            rectangleStatus.height = 48;
            textStatus.text = message;

            if (!deviceManager.hasBluetooth()) {
                buttonEnables.visible = true
            } else {
                buttonEnables.visible = false
            }
        }
    }

    ListView {
        id: devicesview
        width: parent.width
        clip: true

        anchors.fill: parent
        anchors.topMargin: rectangleStatus.height + 12
        anchors.bottomMargin: 10
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        spacing: 10

        model: deviceManager.devicesList
        delegate: MobileDeviceBox { boxDevice: modelData }

    }
}
