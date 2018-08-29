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

    property var myDevice

    property string badColor: "#ffbf66"
    property string neutralColor: "#e4e4e4"
    property string goodColor: "#87d241"

    Component.onCompleted: updateStatus()

    function updateStatus() {

        // Update header
        if ((myDevice.deviceCapabilities & 1) == 1) {
            if (myDevice.deviceBattery < 15) {
                imageBatt.source = "qrc:/assets/battery_low.svg"
            } else if (myDevice.deviceBattery > 75) {
                imageBatt.source = "qrc:/assets/battery_full.svg"
            } else {
                imageBatt.source = "qrc:/assets/battery_mid.svg"
            }
        } else {
            imageBatt.visible = false
            textBatt.visible = false
        }

        // Plant sensor?
        if ((myDevice.deviceCapabilities & 64) != 0) {
            textPlant.visible = true
            textInputPlant.visible = true
        } else {
            textPlant.visible = false
            textInputPlant.visible = false
        }

        if (!myDevice.deviceFirmwareUpToDate) {
            imageFw.visible = true
            imageFw.source = "qrc:/assets/update.svg"
            //textFw.text = qsTr("v") + myDevice.deviceFirmware + qsTr(" (update available!)")
        }
    }

    Header {
        id: header
        anchors.top: parent.top
        onBackClicked: { pageLoader.source = "main.qml" }
    }

    Rectangle {
        id: rectangleBody

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        Connections {
            target: myDevice
            onStatusUpdated: updateStatus()
            onDatasUpdated: rectangleDeviceDatas.updateDatas()
        }

        MouseArea {
            id: mouseArea // so the underlying stuff doesn't hijack clicks
            anchors.fill: parent
        }

        Rectangle {
            id: rectangleHeader
            height: 128
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
                id: rectangleDb
                color: "#00000000"
                anchors.fill: parent

                Text {
                    id: textLocation
                    x: 12
                    y: 12
                    text: qsTr("Location")
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    font.pixelSize: 15
                }

                TextInput {
                    id: textInputLocation
                    height: 28
                    color: "#454b54"
                    text: myDevice.deviceCustomName
                    anchors.top: textLocation.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 11
                    font.bold: false
                    font.pixelSize: 22
                    onEditingFinished: myDevice.setCustomName(text)

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
                        y: 0
                        width: 24
                        height: 24
                        anchors.left: parent.right
                        anchors.leftMargin: 6
                        anchors.verticalCenterOffset: 0
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/edit_button.svg"
                    }
                }

                Text {
                    id: textPlant
                    x: 12
                    y: 62
                    text: qsTr("Plant")
                    anchors.top: textInputLocation.bottom
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    font.pixelSize: 15
                }

                TextInput {
                    id: textInputPlant
                    height: 28
                    color: "#454b54"
                    text: myDevice.devicePlantName
                    anchors.top: textPlant.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 11
                    font.bold: false
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: 22
                    onEditingFinished: myDevice.setPlantName(text)

                    Image {
                        id: imageEditPlant
                        y: 0
                        width: 24
                        height: 24
                        anchors.left: parent.right
                        anchors.leftMargin: 6
                        anchors.verticalCenterOffset: 0
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/edit_button.svg"
                    }

                    MouseArea {
                        anchors.rightMargin: 0
                        anchors.bottomMargin: 0
                        anchors.leftMargin: 0
                        anchors.topMargin: 0
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
            }

            Rectangle {
                id: rectangleHw
                color: "#00000000"
                visible: true
                anchors.fill: parent

                Text {
                    id: labelName
                    text: qsTr("Device name")
                    anchors.topMargin: 16
                    anchors.leftMargin: 12
                    anchors.left: parent.left
                    anchors.top: parent.top
                    font.pixelSize: 15
                }
                Text {
                    id: textName
                    x: 12
                    y: 12
                    height: 28
                    color: "#454b54"
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    font.pixelSize: 22
                    text: myDevice.deviceName
                    anchors.right: parent.right
                    anchors.rightMargin: 294
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors.top: labelName.bottom
                    anchors.topMargin: 0
                }

                Text {
                    id: labelAddr
                    text: qsTr("MAC adress")
                    anchors.topMargin: 8
                    anchors.leftMargin: 12
                    anchors.left: parent.left
                    anchors.top: textName.bottom
                    font.pixelSize: 15
                }
                Text {
                    id: textAddr
                    height: 28
                    color: "#454b54"
                    text: myDevice.deviceAddress
                    horizontalAlignment: Text.AlignLeft
                    anchors.right: parent.right
                    anchors.rightMargin: 235
                    verticalAlignment: Text.AlignVCenter
                    anchors.topMargin: 0
                    anchors.leftMargin: 12
                    anchors.left: parent.left
                    anchors.top: labelAddr.bottom
                    font.pixelSize: 22
                }

                Text {
                    id: labelFw
                    x: 9
                    y: 10
                    text: qsTr("Firmware")
                    anchors.topMargin: 70
                    anchors.leftMargin: 238
                    anchors.left: parent.left
                    anchors.top: parent.top
                    font.pixelSize: 15
                }
                Image {
                    id: imageFw
                    y: 90
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 238
                    source: "qrc:/assets/update.svg"
                }
                Text {
                    id: textFw
                    width: 125
                    color: "#454b54"
                    text: myDevice.deviceFirmware
                    anchors.top: labelFw.bottom
                    anchors.topMargin: 6
                    anchors.left: imageFw.right
                    anchors.leftMargin: 6
                    font.pixelSize: 18
                }
                Image {
                    id: imageBatt
                    y: 36
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 170
                    source: "qrc:/assets/battery_full.svg"
                }
                Text {
                    id: textBatt
                    y: 38
                    color: "#454b54"
                    text: myDevice.deviceBattery + "%"
                    anchors.left: imageBatt.right
                    anchors.leftMargin: 6

                    font.pixelSize: 18
                }
            }

            Rectangle {
                id: rectangleBar
                width: 48
                color: "#E1E1E1"
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Rectangle {
                    id: rectangleB1
                    width: 32
                    height: 32
                    color: "#00000000"
                    anchors.verticalCenterOffset: -24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: imageB1
                        width: 28
                        height: 28
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/hw.svg"

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            onEntered: imageB1.opacity = 0.5
                            onExited: imageB1.opacity = 1

                            onPressed: {
                                imageB1.anchors.topMargin += 2
                                imageB1.anchors.rightMargin += 2
                                imageB1.width -= 4
                                imageB1.height -= 4
                            }
                            onReleased: {
                                imageB1.anchors.topMargin -= 2
                                imageB1.anchors.rightMargin -= 2
                                imageB1.width += 4
                                imageB1.height += 4
                            }
                            onClicked: {
                                if (rectangleHw.visible === true) {
                                    rectangleHw.visible = false
                                    rectangleDb.visible = true
                                    imageB1.source = "qrc:/assets/db.svg"
                                } else {
                                    rectangleHw.visible = true
                                    rectangleDb.visible = false
                                    imageB1.source = "qrc:/assets/hw.svg"
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: rectangleB2
                    x: 8
                    y: 106
                    width: 32
                    height: 32
                    color: "#00000000"
                    anchors.verticalCenterOffset: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

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
