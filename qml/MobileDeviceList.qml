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
        height: 48
        color: Theme.colorYellow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

        Row {
            id: row
            spacing: 32
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: textStatus
                color: "white"
                text: ""
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
                font.pixelSize: 20
            }

            ThemedButton {
                id: buttonEnables
                width: 128
                height: 30
                anchors.verticalCenter: parent.verticalCenter

                text: {
                    if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") {
                        qsTr("Try again")
                    } else {
                        qsTr("Enable it!")
                    }
                }
                color: "white"
                opacity: 0.9

                onClicked: {
                    deviceManager.enableBluetooth()
                    deviceManager.checkBluetooth()
                }
            }
        }

        function hide() {
            rectangleStatus.visible = false;
            rectangleStatus.height = 0;

            itemStatus.source = ""
        }
        function setBluetoothWarning() {
            rectangleStatus.visible = true;
            rectangleStatus.height = 48;

            itemStatus.source = "ItemNoBluetooth.qml"
            textStatus.text = qsTr("Bluetooth disabled :-(");
            buttonBluetooth.visible = true
            buttonSearch.visible = false
        }
        function setDeviceWarning() {
            rectangleStatus.visible = true;
            rectangleStatus.height = 48;

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
        anchors.verticalCenterOffset: 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    ListView {
        id: devicesview
        width: parent.width
        clip: true

        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: rectangleStatus.height + 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        spacing: 0

        model: deviceManager.devicesList
        delegate: MobileDeviceBox { boxDevice: modelData }
    }
}
