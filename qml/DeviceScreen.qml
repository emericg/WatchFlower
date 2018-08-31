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
    id: deviceScreenRectangle
    width: 450
    height: 700

    property var myDevice: curentlySelectedDevice

    property string badColor: "#ffbf66"
    property string neutralColor: "#e4e4e4"
    property string goodColor: "#87d241"

    Component.onCompleted: loadDevice()

    function loadDevice() {
        if (typeof myDevice === "undefined") return

        //console.log("DeviceScreen // loadDevice() >> " + myDevice)

        updateStatus()
        rectangleDeviceDatas.loadDatas()
    }

    function updateStatus() {
        if (typeof myDevice === "undefined") return

        //console.log("DeviceScreen // updateStatus() >> " + myDevice)

        // Update header
        if ((myDevice.deviceCapabilities & 1) == 1) {
            if (myDevice.deviceBattery < 15) {
                imageBattery.source = "qrc:/assets/battery_low.svg"
            } else if (myDevice.deviceBattery > 75) {
                imageBattery.source = "qrc:/assets/battery_full.svg"
            } else {
                imageBattery.source = "qrc:/assets/battery_mid.svg"
            }
        } else {
            labelBattery.visible = false
            textBattery.visible = false
            imageBattery.visible = false
        }

        if (myDevice.deviceLocationName !== "")
            textInputLocation.text = myDevice.deviceLocationName
        else
            textInputLocation.text = qsTr("Location")

        // Plant sensor?
        if ((myDevice.deviceCapabilities & 64) != 0) {
            labelPlant.visible = true
            textInputPlant.visible = true

            if (myDevice.devicePlantName !== "")
                textInputPlant.text = myDevice.devicePlantName
            else
                textInputPlant.text = qsTr("Plant")

            rectangleHeader.height = 133
        } else {
            labelPlant.visible = false
            textInputPlant.visible = false
            rectangleHeader.height = 104
        }

        if (!myDevice.deviceFirmwareUpToDate) {
            imageFw.visible = true
        } else {
            imageFw.visible = false
        }
    }

    Rectangle {
        id: rectangleBody
        anchors.fill: parent

        Connections {
            target: myDevice
            onStatusUpdated: updateStatus()
            onDatasUpdated: rectangleDeviceDatas.updateDatas()
        }

        Rectangle {
            id: rectangleHeader
            height: 133
            //color: "#E0FAE7" // green
            //color: "#E8E9E8" // dark grey
            //color: "#F1F1F1" // light
            color: "#E8E9E8"

            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            Rectangle {
                id: rectangleB2
                x: 410
                y: 78
                width: 32
                height: 32
                color: "#00000000"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8

                Image {
                    id: imageB2
                    width: 28
                    height: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/limits.svg"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: imageB2.opacity = 0.5
                        onExited: imageB2.opacity = 1

                        onPressed: {
                            imageB2.anchors.topMargin += 2
                            imageB2.anchors.rightMargin += 2
                            imageB2.width -= 4
                            imageB2.height -= 4
                        }
                        onReleased: {
                            imageB2.anchors.topMargin -= 2
                            imageB2.anchors.rightMargin -= 2
                            imageB2.width += 4
                            imageB2.height += 4
                        }
                        onClicked: {
                            if (rectangleContent.state === "datas") {
                                rectangleContent.state = "limits"
                                imageB2.source = "qrc:/assets/graph.svg"
                            } else {
                                rectangleContent.state = "datas"
                                // Update color bars with new limits
                                rectangleDeviceDatas.updateDatas()
                                imageB2.source = "qrc:/assets/limits.svg"
                            }
                        }
                    }
                }
            }

            Text {
                id: textDeviceName
                x: 12
                y: 12
                color: "#454b54"
                anchors.left: parent.left
                anchors.leftMargin: 12
                font.pixelSize: 22
                text: myDevice.deviceName
                font.capitalization: Font.AllUppercase
                anchors.top: parent.top
                anchors.topMargin: 12
            }
            Text {
                id: textAddr
                color: "#454b54"
                text: myDevice.deviceAddress
                anchors.bottom: textDeviceName.bottom
                anchors.bottomMargin: 2
                anchors.left: textDeviceName.right
                anchors.leftMargin: 8
                font.pixelSize: 16
            }

            Text {
                id: labelFw
                anchors.topMargin: 8
                anchors.leftMargin: 12
                anchors.left: parent.left
                anchors.top: textDeviceName.bottom

                text: qsTr("Firmware")
                font.pixelSize: 15
            }
            Text {
                id: textFw
                color: "#454b54"
                text: myDevice.deviceFirmware
                anchors.left: labelFw.right
                anchors.leftMargin: 8
                anchors.verticalCenter: labelFw.verticalCenter
                font.pixelSize: 18
            }
            Image {
                id: imageFw
                width: 26
                height: 26
                anchors.verticalCenter: textFw.verticalCenter
                anchors.left: textFw.right
                anchors.leftMargin: 8

                visible: false
                source: "qrc:/assets/update.svg"
            }

            Text {
                id: labelBattery
                anchors.verticalCenter: textFw.verticalCenter
                anchors.leftMargin: 8
                anchors.left: imageFw.right

                text: qsTr("Battery")
                font.pixelSize: 15
            }
            Text {
                id: textBattery
                anchors.verticalCenter: labelBattery.verticalCenter
                anchors.left: labelBattery.right
                anchors.leftMargin: 8
                color: "#454b54"
                text: myDevice.deviceBattery + "%"
                anchors.verticalCenterOffset: 0
                font.pixelSize: 18
            }
            Image {
                id: imageBattery
                width: 26
                height: 26
                anchors.verticalCenter: textBattery.verticalCenter
                anchors.left: textBattery.right
                anchors.leftMargin: 8

                visible: false
                source: "qrc:/assets/battery_full.svg"
            }

            Text {
                id: labelPlant
                anchors.top: labelLocation.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 12

                text: qsTr("Plant")
                font.pixelSize: 15
            }
            TextInput {
                id: textInputPlant
                anchors.verticalCenter: labelPlant.verticalCenter
                anchors.left: labelPlant.right
                anchors.leftMargin: 8

                text: ""
                color: "#454b54"
                font.pixelSize: 18
                onEditingFinished: myDevice.setPlantName(text)

                Image {
                    id: imageEditPlant
                    width: 24
                    height: 24
                    anchors.left: parent.right
                    anchors.leftMargin: 6
                    anchors.verticalCenterOffset: 0
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/edit_button.svg"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true

                    onEntered: { imageEditPlant.visible = true; }
                    onExited: { imageEditPlant.visible = false; }

                    onClicked: mouse.accepted = false;
                    onPressed: mouse.accepted = false;
                    onReleased: mouse.accepted = false;
                    onDoubleClicked: mouse.accepted = false;
                    onPositionChanged: mouse.accepted = false;
                    onPressAndHold: mouse.accepted = false;
                }
            }

            Text {
                id: labelLocation
                text: qsTr("Location")
                anchors.top: labelFw.bottom
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 12
                font.pixelSize: 15
            }
            TextInput {
                id: textInputLocation
                anchors.verticalCenter: labelLocation.verticalCenter
                anchors.left: labelLocation.right
                anchors.leftMargin: 8

                text: ""
                color: "#454b54"
                font.pixelSize: 18
                onEditingFinished: myDevice.setLocationName(text)

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true

                    onEntered: { imageEditLocation.visible = true; }
                    onExited: { imageEditLocation.visible = false; }

                    onClicked: mouse.accepted = false;
                    onPressed: mouse.accepted = false;
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
                    source: "qrc:/assets/edit_button.svg"
                }
            }
        }

        Rectangle {
            id: rectangleContent
            color: "#ffffff"
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
    }
}
