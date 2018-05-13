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

Rectangle {
    id: background
    color: "#e5fed8"
    width: 450
    height: 700

    //minimumWidth: 400
    //minimumHeight: 640

    property bool deviceScanning: deviceManager.scanning
    property bool bluetoothAvailable: deviceManager.bluetooth

    onDeviceScanningChanged: {
        if (deviceManager.scanning) {
            header.scanAnimation.start();

            status.statusText = "Scanning...";
            status.visible = true;
        } else {
            header.scanAnimation.stop();

            if (deviceManager.areDevicesAvailable()) {
                status.statusText = "Click on a device for details!"
                status.visible = true;
            } else {
                status.statusText = "Click refresh to scan!"
                status.visible = true;
            }
        }
    }

    onBluetoothAvailableChanged: {
        if (deviceManager.bluetooth) {
            header.scanAvailable.visible = true;
            bluetooth_img.visible = false;
        } else {
            header.scanAvailable.visible = false;

            status.statusText = "No bluetooth :-(";
            status.visible = true;
            bluetooth_img.visible = true;
        }
    }

    Header {
        id: header
        anchors.top: parent.top

        backAvailable.visible: true
        backImg.source: "qrc:/assets/menu_settings.svg"
        scanAvailable.visible: {
            if (deviceManager.bluetooth) {
                header.scanAvailable.visible = true;
                bluetooth_img.visible = false;
            } else {
                header.scanAvailable.visible = false;

                status.statusText = "No bluetooth :-(";
                status.visible = true;
                bluetooth_img.visible = true;
            }
        }

        onBackClicked: {
            pageLoader.setSource("Settings.qml",
                                 { mySettings: settingsManager });
        }
        onRefreshClicked: {
            deviceManager.startDeviceDiscovery();
        }
    }

    Status {
        id: status
        statusText: "Click refresh to scan!"
        visible: true
    }

    Image {
        id: background_img
        y: 314
        width: 256
        height: 256
        opacity: 0.9
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 77
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter

        source: {
            var a = Math.floor(Math.random() * 2);
            if (a === 2)
                source = "qrc:/assets/background3.png";
            else if (a === 1)
                source = "qrc:/assets/background2.png";
            else
                source = "qrc:/assets/background1.png";
        }
        fillMode: Image.PreserveAspectFit

        Image {
            id: bluetooth_img
            x: 108
            y: 191
            width: 40
            height: 40
            anchors.horizontalCenterOffset: 84
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.horizontalCenter: background_img.horizontalCenter
            source: "qrc:/assets/ble_err.svg"
            fillMode: Image.PreserveAspectFit

            visible: {
                if (deviceManager.bluetooth)
                    visible = false;
                else
                    visible = true;
            }
        }
    }

    ListView {
        id: devicesview
        width: parent.width
        clip: true
        model: deviceManager.devicesList

        spacing: 16
        anchors.top: header.bottom
        anchors.topMargin: 16
        anchors.bottom: status.top // FIXME parent.bottom
        anchors.bottomMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16

        delegate: DeviceBox { myDevice: modelData}
    }

    Loader {
        id: pageLoader
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.fill: parent
    }
}

