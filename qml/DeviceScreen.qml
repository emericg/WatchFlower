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
    color: "#eefbdb"
    width: 450
    height: 700

    property var myDevice

    function updateStatus() {
        if (myDevice.updating) {
            header.scanAnimation.start();
        } else {
            header.scanAnimation.stop();
        }

        if (!myDevice.available && !myDevice.updating) {
            textOffline.visible = true
            if (myDevice.lastUpdate) {
                textLastUpdate.visible = true
                textLastUpdate.text = qsTr("Last update ") + myDevice.lastUpdate + qsTr("min ago")
            } else {
                textLastUpdate.visible = false
            }
        } else {
            textOffline.visible = false
            textLastUpdate.visible = false
        }
    }

    Header {
        id: header
        anchors.top: parent.top

        backAvailable.visible: true
        scanAvailable.visible: true

        onBackClicked: {
            pageLoader.source = "main.qml"
        }
        onRefreshClicked: {
            myDevice.refreshDatas();
        }
    }

    Rectangle {
        id: rectangleBody
        color: "#ccffffff"
        border.width: 0

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        Component.onCompleted: {
            updateStatus()
            rectangleDeviceDatas.setDatas()
        }

        Connections {
            target: myDevice
            onDatasUpdated: rectangleDeviceDatas.setDatas()
            onStatusUpdated: updateStatus()
        }

        MouseArea {
            id: mouseArea // so the underlying stuff doesn't hijack clicks
            anchors.fill: parent
        }

        Rectangle {
            id: rectangleHeader
            height: 80
            color: "#e8e9e8"
            border.width: 0

            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            Text {
                id: textAddr
                y: 46
                height: 16
                anchors.left: parent.left
                anchors.leftMargin: 13
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
                text: myDevice.deviceName + " (" + myDevice.deviceAddress + ")"
            }

            TextInput {
                id: textInputName
                height: 32
                color: "#454b54"
                text: myDevice.deviceCustomName
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.top: parent.top
                anchors.topMargin: 12
                font.bold: true
                font.pixelSize: 26

                onEditingFinished: {
                    myDevice.setCustomName(text);
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true

                    onEntered: { imageEditName.visible = true; }
                    onExited: { imageEditName.visible = false; }

                    onClicked: mouse.accepted = false;
                    onPressed: mouse.accepted = false;
                    onReleased: mouse.accepted = false;
                    onDoubleClicked: mouse.accepted = false;
                    onPositionChanged: mouse.accepted = false;
                    onPressAndHold: mouse.accepted = false;
                }

                Image {
                    id: imageEditName
                    x: 197
                    y: 0
                    width: 28
                    height: 28
                    anchors.verticalCenterOffset: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/edit_button.svg"
                }
            }

            Text {
                id: textOffline
                x: 335
                y: 53
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                color: "#ff671b"
                text: qsTr("Device is OFFLINE")
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
                font.bold: true
            }

//            Rectangle {
//                id: rectangleDevice
//                x: 349
//                width: 101
//                color: "#00000000"
//                anchors.bottom: parent.bottom
//                anchors.bottomMargin: 0
//                anchors.top: parent.top
//                anchors.topMargin: 0
//                anchors.right: parent.right
//                anchors.rightMargin: 0
//                border.width: 0

//                Image {
//                    id: imageFw
//                    x: 399
//                    width: 30
//                    height: 30
//                    anchors.verticalCenterOffset: -16
//                    anchors.verticalCenter: parent.verticalCenter
//                    anchors.right: parent.right
//                    anchors.rightMargin: 8
//                    source: "qrc:/assets/fw.svg"
//                }
//                Text {
//                    id: textFw
//                    y: 13
//                    width: 64
//                    height: 30
//                    text: "v" + myDevice.deviceFirmware
//                    horizontalAlignment: Text.AlignRight
//                    anchors.right: imageFw.left
//                    anchors.rightMargin: 8
//                    verticalAlignment: Text.AlignVCenter
//                    anchors.verticalCenter: parent.verticalCenter
//                    anchors.verticalCenterOffset: -16
//                    font.pixelSize: 14
//                }

//                Image {
//                    id: imageBatt
//                    x: 205
//                    width: 30
//                    height: 30
//                    anchors.right: parent.right
//                    anchors.rightMargin: 8
//                    anchors.verticalCenter: parent.verticalCenter
//                    anchors.verticalCenterOffset: 16
//                    source: {
//                        if (myDevice.deviceBattery < 15) {
//                            source = "qrc:/assets/battery_low.svg";
//                        } else if (myDevice.deviceBattery > 75) {
//                            source = "qrc:/assets/battery_full.svg";
//                        } else {
//                            source = "qrc:/assets/battery_mid.svg";
//                        }
//                    }
//                }
//                Text {
//                    id: textBatt
//                    x: 260
//                    y: 10
//                    width: 64
//                    height: 30
//                    text: myDevice.deviceBattery + "%"
//                    horizontalAlignment: Text.AlignRight
//                    anchors.right: imageBatt.left
//                    anchors.rightMargin: 8
//                    verticalAlignment: Text.AlignVCenter
//                    anchors.verticalCenterOffset: 16
//                    anchors.verticalCenter: parent.verticalCenter
//                    font.pixelSize: 14
//                }
//            }
        }

        Rectangle {
            id: rectangleDevice
            height: 40
            color: "#f1f1f1"
            border.width: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: rectangleHeader.bottom
            anchors.topMargin: 0

            Image {
                id: imageFw
                width: 30
                height: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                source: "qrc:/assets/fw.svg"
            }
            Text {
                id: textFw
                y: 13
                height: 30

                text: "v" + myDevice.deviceFirmware
                verticalAlignment: Text.AlignVCenter
                anchors.left: imageFw.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                font.pixelSize: 14
            }
            Image {
                id: imageBatt
                x: 205
                width: 28
                height: 28
                anchors.left: textFw.right
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                source: {
                    if (myDevice.deviceBattery < 15) {
                        source = "qrc:/assets/battery_low.svg";
                    } else if (myDevice.deviceBattery > 75) {
                        source = "qrc:/assets/battery_full.svg";
                    } else {
                        source = "qrc:/assets/battery_mid.svg";
                    }
                }
            }
            Text {
                id: textBatt
                x: 260
                y: 10
                height: 30
                text: myDevice.deviceBattery + "%"
                verticalAlignment: Text.AlignVCenter
                anchors.left: imageBatt.right
                anchors.leftMargin: 4
                anchors.verticalCenterOffset: 0
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 14
            }

            Text {
                id: textLastUpdate
                x: 359
                y: 13
                text: qsTr("Last update: x min ago")
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: rectanglePlant
            y: 41
            width: 368
            height: 40
            color: "#f9f9f9"
            border.width: 0
            anchors.top:rectangleDevice.bottom
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Image {
                id: imagePlant
                width: 30
                height: 30
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/plant.svg"
            }

            TextInput {
                id: textInputPlant
                y: 12
                height: 20
                text: myDevice.devicePlantName
                anchors.right: imageLimits.left
                anchors.rightMargin: 4
                horizontalAlignment: Text.AlignLeft
                anchors.left: imagePlant.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16

                Image {
                    id: imageEditPlant
                    x: 197
                    y: 0
                    width: 20
                    height: 20
                    anchors.verticalCenterOffset: 0
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/edit_button.svg"
                    anchors.rightMargin: 0
                    anchors.right: parent.right
                }

                onEditingFinished: {
                    myDevice.setPlantName(text);
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

            Image {
                id: imageLimits
                x: 416
                y: 8
                width: 30
                height: 30
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/stats.svg"

                MouseArea {
                    anchors.fill: parent

                    onPressed: {
                        imageLimits.anchors.topMargin += 2
                        imageLimits.anchors.rightMargin += 2
                        imageLimits.width -= 4
                        imageLimits.height -= 4
                    }
                    onReleased: {
                        imageLimits.anchors.topMargin -= 2
                        imageLimits.anchors.rightMargin -= 2
                        imageLimits.width += 4
                        imageLimits.height += 4
                    }
                    onClicked: {
                        if (rectangleContent.state === "datas")
                            rectangleContent.state = "limits";
                        else {
                            rectangleContent.state = "datas";
                            // Update color bars with new limits
                            rectangleDeviceDatas.setDatas();
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rectangleContent

            anchors.top: rectanglePlant.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            DeviceScreenDatas {
                anchors.fill: parent
                id: rectangleDeviceDatas
            }
            DeviceScreenLimits {
                anchors.fill: parent
                id: rectangleLimits
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
                        target: rectangleLimits
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
                        target: rectangleLimits
                        visible: true
                    }
                }
            ]
        }
    }
}
