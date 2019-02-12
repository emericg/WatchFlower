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

import QtGraphicalEffects 1.0
import com.watchflower.theme 1.0

Item {
    id: deviceScreenRectangle
    width: 450
    height: 700

    property var myDevice: curentlySelectedDevice
    property var content: rectangleContent

    Component.onCompleted: loadDevice()

    Connections {
        target: myDevice
        onStatusUpdated: updateHeader()
        onDatasUpdated: rectangleDeviceDatas.updateDatas()
    }

    Rectangle {
        id: rectangleHeader
        height: 134
        color: Theme.colorMaterialDarkGrey

        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Text {
            id: textDeviceName
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12

            font.pixelSize: 24
            text: myDevice.deviceName
            font.capitalization: Font.AllUppercase
            color: Theme.colorText

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                onClicked: {
                    if (plantPanel.visible) {
                        plantPanel.visible = false
                        devicePanel. visible = true
                    } else {
                        plantPanel.visible = true
                        devicePanel. visible = false
                    }
                }
            }
        }
        Image {
            id: imageBattery
            width: 32
            height: 32
            rotation: 90
            anchors.verticalCenter: textDeviceName.verticalCenter
            anchors.left: textDeviceName.right
            anchors.leftMargin: 16

            source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
            sourceSize: Qt.size(width, height)

            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: Theme.colorIcons
            }
        }

        Item {
            id: desktopButtons
            width: 112
            height: 80
            z: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 12
            anchors.right: parent.right

            Rectangle {
                id: buttonRefresh
                width: 112
                height: 32
                color: "#e0e0e0"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: buttonRefreshText
                    height: 32
                    color: "#202020"
                    text: qsTr("Refresh")
                    verticalAlignment: Text.AlignVCenter
                    anchors.right: parent.right
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: imageRefresh.right
                    anchors.rightMargin: 0
                    anchors.leftMargin: 8
                }

                Image {
                    id: imageRefresh
                    width: 22
                    height: 22
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
                    sourceSize: Qt.size(width, height)

                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Theme.colorIcons
                    }

                    NumberAnimation on rotation {
                        id: refreshRotation
                        duration: 3000;
                        from: 0;
                        to: 360;
                        loops: Animation.Infinite
                        running: false
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: buttonRefresh.color = "#eaeaea"
                    onExited: buttonRefresh.color = "#e0e0e0"

                    onClicked: {
                        refreshRotation.start()
                        myDevice.refreshDatas()
                    }
                }
            }

            Rectangle {
                id: buttonLimits
                width: 112
                height: 32
                color: "#e0e0e0"
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter

                function initButton() {
                    if (rectangleContent.state === "limits") {
                        textLimits.text = qsTr("Datas")
                        imageLimits.source = "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                    } else {
                        textLimits.text = qsTr("Limits")
                        imageLimits.source = "qrc:/assets/icons_material/baseline-iso-24px.svg"
                    }
                }

                Text {
                    id: textLimits
                    height: 32
                    color: "#202020"
                    text: qsTr("Limits")
                    verticalAlignment: Text.AlignVCenter
                    anchors.right: parent.right
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: imageLimits.right
                    anchors.rightMargin: 0
                    anchors.leftMargin: 8
                }

                Image {
                    id: imageLimits
                    width: 22
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    source: "qrc:/assets/icons_material/baseline-iso-24px.svg"
                    sourceSize: Qt.size(width, height)

                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Theme.colorIcons
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: buttonLimits.color = "#eaeaea"
                    onExited: buttonLimits.color = "#e0e0e0"

                    onClicked: {
                        if (rectangleContent.state === "datas") {
                            rectangleContent.state = "limits"
                            textLimits.text = qsTr("Datas")
                            imageLimits.source = "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                        } else {
                            rectangleContent.state = "datas"
                            textLimits.text = qsTr("Limits")
                            imageLimits.source = "qrc:/assets/icons_material/baseline-iso-24px.svg"

                            // Update color bars with new limits
                            rectangleDeviceDatas.updateDatas()
                        }
                    }
                }
            }
        }

        Column {
            id: plantPanel

            anchors.top: textDeviceName.bottom
            anchors.topMargin: 4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Item {
                id: itemPlant
                height: 28
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: labelPlant
                    width: 70
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Plant")
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }
                TextInput {
                    id: textInputPlant
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelPlant.right
                    anchors.leftMargin: 8
                    padding: 4

                    font.pixelSize: 16
                    onEditingFinished: {
                        myDevice.setPlantName(text)
                        focus = false
                        imageEditPlant.visible = false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        //propagateComposedEvents: true

                        onEntered: { imageEditPlant.visible = true; }
                        onExited: { imageEditPlant.visible = false; }

                        onClicked: {
                            imageEditPlant.visible = true;
                            mouse.accepted = false;
                        }
                        onPressed: {
                            imageEditPlant.visible = true;
                            mouse.accepted = false;
                        }
                        onReleased: mouse.accepted = false;
                        onDoubleClicked: mouse.accepted = false;
                        onPositionChanged: mouse.accepted = false;
                        onPressAndHold: mouse.accepted = false;
                    }

                    Image {
                        id: imageEditPlant
                        x: 456
                        y: 4
                        width: 24
                        height: 24
                        anchors.left: parent.right
                        anchors.leftMargin: 6
                        anchors.verticalCenterOffset: 0
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                        sourceSize: Qt.size(width, height)

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: Theme.colorIcons
                        }
                    }
                }
            }

            Item {
                id: itemLocation
                height: 28
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: labelLocation
                    width: 70
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Location")
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }
                TextInput {
                    id: textInputLocation
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelLocation.right
                    anchors.leftMargin: 8
                    padding: 4

                    font.pixelSize: 16
                    onEditingFinished: {
                        myDevice.setLocationName(text)
                        focus = false
                        imageEditLocation.visible = false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true

                        onEntered: { imageEditLocation.visible = true; }
                        onExited: { imageEditLocation.visible = false; }

                        onClicked: {
                            imageEditLocation.visible = true;
                            mouse.accepted = false;
                        }
                        onPressed: {
                            imageEditLocation.visible = true;
                            mouse.accepted = false;
                        }
                        onReleased: mouse.accepted = false;
                        onDoubleClicked: mouse.accepted = false;
                        onPositionChanged: mouse.accepted = false;
                        onPressAndHold: mouse.accepted = false;
                    }

                    Image {
                        id: imageEditLocation
                        width: 24
                        height: 24
                        anchors.left: parent.right
                        anchors.leftMargin: 6
                        anchors.verticalCenterOffset: 0
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                        sourceSize: Qt.size(width, height)

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: Theme.colorIcons
                        }
                    }
                }
            }

            Item {
                id: status
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelStatus
                    width: 70
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Status")
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }
                Text {
                    id: textStatus
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelStatus.right
                    anchors.leftMargin: 8

                    text: qsTr("Loading...")
                    padding: 4
                    font.pixelSize: 16
                }
            }
        }

        Column {
            id: devicePanel
            anchors.top: textDeviceName.bottom
            anchors.topMargin: 4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Item {
                id: address
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelAddress
                    width: 70
                    anchors.leftMargin: 12
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Address")
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 15
                }

                Text {
                    id: textAddr
                    text: myDevice.deviceAddress
                    anchors.left: labelAddress.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 16
                }
            }

            Item {
                id: firmware
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelFirmware
                    width: 70
                    color: Theme.colorText
                    text: qsTr("Firmware")
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 15
                    anchors.leftMargin: 12
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    id: textFirmware
                    anchors.left: labelFirmware.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Update available!")
                    font.pixelSize: 16
                }
                Image {
                    id: imageFwUpdate
                    width: 24
                    height: 24
                    anchors.left: textFirmware.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-new_releases-24px.svg"
                    sourceSize: Qt.size(width, height)

                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Theme.colorIcons
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            textFwUpdate.text = qsTr("Use official app to upgrade")
                        }
                        onExited: {
                            textFwUpdate.text = qsTr("Update available!")
                        }
                    }
                }

                Text {
                    id: textFwUpdate
                    height: 26
                    text: myDevice.deviceFirmware
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: imageFwUpdate.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 15
                }
            }

            Item {
                id: battery
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: textBattery
                    anchors.left: labelBattery.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    text: myDevice.deviceBattery + "%"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 15
                }

                Text {
                    id: labelBattery
                    width: 70
                    horizontalAlignment: Text.AlignRight
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Battery")
                    color: Theme.colorText
                    font.pixelSize: 15
                }
            }
        }
    }

    Rectangle {
        id: rectangleContent
        color: Theme.colorMaterialLightGrey
        anchors.topMargin: 0
        anchors.bottom: parent.bottom

        anchors.top: rectangleHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        DeviceScreenDatas {
            anchors.fill: parent
            id: rectangleDeviceDatas
        }
        DeviceScreenLimits {
            anchors.fill: parent
            id: rectangleDeviceLimits
        }

        state: "datas"
        states: [
            State {
                name: "datas"
                PropertyChanges {
                    target: rectangleDeviceDatas
                    visible: true
                }
                PropertyChanges {
                    target: rectangleDeviceLimits
                    visible: false
                }
            },
            State {
                name: "limits"
                PropertyChanges {
                    target: rectangleDeviceDatas
                    visible: false
                }
                PropertyChanges {
                    target: rectangleDeviceLimits
                    visible: true
                }
            }
        ]
    }

    Rectangle {
        id: miniMenu
        width: 160
        height: 120
        color: "#ffffff"
        anchors.top: parent.top
        anchors.topMargin: -8
        anchors.right: parent.right
        anchors.rightMargin: 8

        function showMiniMenu() {
            menuRefresh.color = "#ffffff"
            menuLimits.color = "#ffffff"
            menuInfos.color = "#ffffff"

            if (rectangleContent.state === "datas")
                menuLimitsText.text = qsTr("Edit limits")
            else
                menuLimitsText.text = qsTr("Show datas")

            if (plantPanel.visible)
                menuInfosText.text = qsTr("Device infos")
            else
                menuInfosText.text = qsTr("Plant infos")

            if (!visible) {
                visible = true
                opacity = 0
                fadeIn.start()
            }
        }
        function hideMiniMenu() {
            if (visible) {
                opacity = 1
                fadeOut.start()
            }
        }

        OpacityAnimator {
            id: fadeIn
            target: miniMenu
            from: 0
            to: 1
            duration: 250
            running: true
        }
        OpacityAnimator {
            id: fadeOut
            target: miniMenu
            from: 1
            to: 0
            duration: 250
            running: true

            onStopped: {
                miniMenu.visible = false
            }
        }

        Column {
            id: rows
            anchors.fill: parent

            Rectangle {
                id: menuRefresh
                height: 40
                color: "#ffffff"
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: element
                    text: qsTr("Refresh")
                    verticalAlignment: Text.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    font.pixelSize: 18
                }

                MouseArea {
                    id: mouseAreaRefresh
                    anchors.fill: parent

                    onClicked: {
                        menuRefresh.color = Theme.colorMaterialDarkGrey
                        myDevice.refreshDatas()
                        miniMenu.hideMiniMenu()
                    }
                }
            }

            Rectangle {
                id: menuLimits
                height: 40
                color: "#ffffff"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: menuLimitsText
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Edit limits")
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: mouseAreaLimits
                    anchors.fill: parent

                    onClicked: {
                        menuLimits.color = Theme.colorMaterialDarkGrey
                        miniMenu.hideMiniMenu()

                        if (rectangleContent.state === "datas") {
                            rectangleContent.state = "limits"
                        } else {
                            rectangleContent.state = "datas"

                            // Update color bars with new limits
                            rectangleDeviceDatas.updateDatas()
                        }
                    }
                }
            }

            Rectangle {
                id: menuInfos
                height: 40
                color: "#ffffff"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: menuInfosText
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Device infos")
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 18
                }

                MouseArea {
                    id: mouseAreaDeviceInfos
                    anchors.fill: parent

                    onClicked: {
                        menuInfos.color = Theme.colorMaterialDarkGrey
                        miniMenu.hideMiniMenu()

                        if (plantPanel.visible) {
                            plantPanel.visible = false
                            devicePanel.visible = true
                        } else {
                            plantPanel.visible = true
                            devicePanel.visible = false
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    Connections {
        target: header
        onRightMenuClicked: {
            if (!miniMenu.visible)
                miniMenu.showMiniMenu()
            else
                miniMenu.hideMiniMenu()
        }
    }

    function updateStatusText() {
        if (typeof myDevice === "undefined") return
        //console.log("DeviceScreen // updateStatusText() >> " + myDevice)

        textStatus.color = "#000"
        textStatus.font.bold = false

        if (myDevice) {
            textStatus.text = ""
            if (myDevice.updating) {
                textStatus.text = qsTr("Updating... ")
                buttonRefreshText.text = qsTr("Refresh")
            } else {
                if (!myDevice.available) {
                    textStatus.text = qsTr("Offline! ")
                    textStatus.color = Theme.colorOrange
                    textStatus.font.bold = true
                    buttonRefreshText.text = qsTr("Retry")
                }
            }

            if (myDevice.lastUpdateMin >= 0) {
                if (myDevice.lastUpdateMin <= 1)
                    textStatus.text += qsTr("Just updated!")
                else if (myDevice.available)
                    textStatus.text += qsTr("Updated") + " " + myDevice.lastUpdateStr + " " + qsTr("ago")
                else
                    textStatus.text += qsTr("Last update") + " " + myDevice.lastUpdateStr + " " + qsTr("ago")
            }
        }
    }

    function loadDevice() {
        if (typeof myDevice === "undefined") return
        //console.log("DeviceScreen // loadDevice() >> " + myDevice)

        rectangleContent.state = "datas"
        miniMenu.visible = false
        plantPanel.visible = true
        devicePanel.visible = false

        updateHeader()

        buttonLimits.initButton()
        rectangleDeviceDatas.loadDatas()
        rectangleDeviceLimits.updateLimits()
        rectangleDeviceLimits.updateLimitsVisibility()
    }

    function updateHeader() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreen // updateHeader() >> " + myDevice)

        // Sensor address
        if (myDevice.deviceAddress.charAt(0) !== '{')
            textAddr.text = "[" + myDevice.deviceAddress + "]"

        // Sensor location
        if (myDevice.deviceLocationName !== "")
            textInputLocation.text = myDevice.deviceLocationName
        else
            textInputLocation.text = qsTr("Location")

        // Firmware
        textFirmware.text = myDevice.deviceFirmware
        if (!myDevice.deviceFirmwareUpToDate) {
            imageFwUpdate.visible = true
            textFwUpdate.visible = true
        } else {
            imageFwUpdate.visible = false
            textFwUpdate.visible = false
        }

        // Plant sensor?
        if ((myDevice.deviceCapabilities & 64) != 0) {
            itemPlant.visible = true

            if (myDevice.devicePlantName !== "")
                textInputPlant.text = myDevice.devicePlantName
            else
                textInputPlant.text = qsTr("Plant")
        } else {
            itemPlant.visible = false
        }

        // Sensor battery level
        if ((myDevice.deviceCapabilities & 1) == 1) {
            imageBattery.visible = true
            battery.visible = true

            if (myDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (myDevice.deviceBattery > 90) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (myDevice.deviceBattery > 70) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (myDevice.deviceBattery > 60) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (myDevice.deviceBattery > 40) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (myDevice.deviceBattery > 30) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (myDevice.deviceBattery > 20) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (myDevice.deviceBattery > 1) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_alert-24px.svg";
            } else {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
            battery.visible = false
        }

        // Status
        updateStatusText()

        // Update desktop buttons
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
            desktopButtons.visible = false
        } else {
            desktopButtons.visible = true

            if (myDevice.updating) {
                refreshRotation.start()
            } else {
                refreshRotation.stop()
            }
        }
    }
}
