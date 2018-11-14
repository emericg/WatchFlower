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
import QtQuick.Controls 2.3

Rectangle {
    id: background
    anchors.fill: parent
    color: "#00000000"

    property bool deviceScanning: deviceManager.scanning
    property bool bluetoothAvailable: deviceManager.bluetooth

    Component.onCompleted: {
        if (deviceManager.bluetooth === false) {
            rectangleMenu.setError(qsTr("No bluetooth :-("))
        } else if (deviceManager.areDevicesAvailable() === false) {
            rectangleMenu.setStatus(qsTr("No devices :-("))
        } else {
            rectangleMenu.setMenu()
        }
    }

    onDeviceScanningChanged: {
        if (deviceManager.scanning) {
            header.menuScanImg.start()
        } else {
            header.menuScanImg.stop()

            if (deviceManager.areDevicesAvailable()) {
                rectangleMenu.setMenu()
            } else {
                rectangleMenu.setStatus(qsTr("No devices :-("))
            }
        }
    }

    onBluetoothAvailableChanged: {
        if (deviceManager.bluetooth) {
            bluetooth_img.visible = false

            if (deviceManager.areDevicesAvailable() === false) {
                rectangleMenu.setStatus(qsTr("No devices :-("))
            } else {
                rectangleMenu.setMenu()
            }
        } else {
            bluetooth_img.visible = true
            rectangleMenu.setError(qsTr("No bluetooth :-("))
        }
    }

    Image {
        id: background_img
        y: 314
        width: 256
        height: 256
        opacity: 1
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 64
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter

        source: {
            var a = Math.floor(Math.random() * 2)
            if (a === 2)
                source = "qrc:/assets/background3.png"
            else if (a === 1)
                source = "qrc:/assets/background2.png"
            else
                source = "qrc:/assets/background1.png"
        }
        fillMode: Image.PreserveAspectFit

        Image {
            id: bluetooth_img
            width: 40
            height: 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.horizontalCenter: background_img.horizontalCenter
            anchors.horizontalCenterOffset: 84
            source: "qrc:/assets/ble_err.svg"
            fillMode: Image.PreserveAspectFit

            visible: {
                if (deviceManager.bluetooth)
                    visible = false
                else
                    visible = true
            }
        }
    }

    ListView {
        id: devicesview
        width: parent.width
        clip: true

        anchors.fill: parent
        anchors.topMargin: 12
        anchors.bottomMargin: 10
        spacing: 10

        model: deviceManager.devicesList

        delegate: DeviceBoxDesktop { boxDevice: modelData }
        anchors.leftMargin: 10
        anchors.rightMargin: 10
/*
        delegate: DeviceBoxMobile { boxDevice: modelData }
        anchors.leftMargin: 0
        anchors.rightMargin: 0
*/
    }

    Rectangle {
        id: rectangleMenu
        height: 48
        color: "#00000000"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        property string mode: "menu"

        onWidthChanged: {
            if (mode === "error") {
                //
            } else {
                rectangleScan.width = rectangleMenu.width * 0.5;
                if (mode === "status") {
                    rectangleStatus.width = rectangleMenu.width * 0.5;
                } else {
                    rectangleRefresh.width = rectangleMenu.width * 0.5;
                }
            }
        }

        function setError(message) {
            mode = "error"
            rectangleScan.visible = false;
            rectangleScan.width = 0;
            rectangleRefresh.visible = false;
            rectangleRefresh.width = 0;
            rectangleStatus.visible = true;
            rectangleStatus.width = rectangleMenu.width;
            rectangleStatus.anchors.left = rectangleMenu.left
            rectangleStatus.anchors.right = rectangleMenu.right
            textStatus.text = message;
        }
        function setStatus(message) {
            mode = "status"
            rectangleScan.visible = true;
            rectangleScan.width = rectangleMenu.width * 0.5;
            rectangleRefresh.visible = false;
            rectangleRefresh.width = 0;
            rectangleStatus.visible = true;
            rectangleStatus.width = rectangleMenu.width * 0.5;
            rectangleStatus.anchors.left = rectangleScan.right;
            textStatus.text = message;
        }
        function setMenu() {
            mode = "menu"
            rectangleStatus.visible = false;
            rectangleStatus.width = 0;
            rectangleScan.visible = true;
            rectangleScan.width = rectangleMenu.width * 0.5;
            rectangleRefresh.visible = true;
            rectangleRefresh.width = rectangleMenu.width * 0.5;
            rectangleRefresh.anchors.left = rectangleScan.right;
        }

        Rectangle {
            id: rectangleRefresh
            width: 150
            color: "#1dcb58"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Text {
                id: textRefresh
                color: "#ffffff"
                text: qsTr("Refresh!")
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.fill: parent
                font.pixelSize: 20
            }
            MouseArea {
                id: mouseAreaRefresh
                anchors.fill: parent
                onPressed: textRefresh.font.pixelSize = 18
                onClicked: deviceManager.refreshDevices()
                onReleased: textRefresh.font.pixelSize = 20
            }
        }

        Rectangle {
            id: rectangleScan
            width: 150
            color: "#4287f4"
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                id: textScan
                color: "#ffffff"
                text: qsTr("Rescan?")
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.fill: parent
                font.pixelSize: 20
            }
            MouseArea {
                id: mouseAreaScan
                anchors.fill: parent
                onPressed: textScan.font.pixelSize = 18
                onClicked: deviceManager.startDeviceDiscovery()
                onReleased: textScan.font.pixelSize = 20
            }
        }

        Rectangle {
            id: rectangleStatus
            color: "#ffb854"
            anchors.right: rectangleRefresh.left
            anchors.rightMargin: 0
            anchors.left: rectangleScan.right
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            Text {
                id: textStatus
                color: "#ffffff"
                text: qsTr("Status :-(")
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.fill: parent
                font.pixelSize: 20
            }
        }
    }
}
