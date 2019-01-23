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

Rectangle {
    id: background
    anchors.fill: parent
    color: "#00000000"

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
            bluetooth_img.visible = false

            if (deviceManager.areDevicesAvailable() === false) {
                rectangleStatus.setStatus(qsTr("No devices :-("))
            } else {
                rectangleStatus.hide()
            }
        } else {
            bluetooth_img.visible = true
            rectangleStatus.setError(qsTr("No bluetooth :-("))
        }
    }

    Rectangle {
        id: rectangleStatus
        height: 48
        color: "#ffb854"
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
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.pixelSize: 20
        }

        function hide() {
            rectangleStatus.visible = false;
            rectangleStatus.height = 0;
        }
        function setError(message) {
            rectangleStatus.visible = true;
            rectangleStatus.height = 48;
            textStatus.text = message;
        }
        function setStatus(message) {
            rectangleStatus.visible = true;
            rectangleStatus.height = 48;
            textStatus.text = message;
        }
    }

    Image {
        id: background_img
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
        sourceSize.width: width
        sourceSize.height: height
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
            sourceSize.width: width
            sourceSize.height: height
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
        //topPad: rectangleStatus.width

        anchors.fill: parent
        anchors.topMargin: rectangleStatus.height + 12
        anchors.bottomMargin: 10
        spacing: 10

        topMargin: rectangleStatus.height

        model: deviceManager.devicesList

        delegate: DesktopDeviceBox { boxDevice: modelData }
        anchors.leftMargin: 10
        anchors.rightMargin: 10
/*
        delegate: MobileDeviceBox { boxDevice: modelData }
        anchors.leftMargin: 0
        anchors.rightMargin: 0
*/
    }
}
