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
    id: deviceExtendedRectangle
    color: "#eefbdb"
    width: 450
    height: 700

    property var myDevice
    property bool myDeviceUpdating: myDevice.updating

    onMyDeviceUpdatingChanged: {
        if (myDevice.updating) {
            header.scanAnimation.start();
        } else {
            header.scanAnimation.stop();
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

        Component.onCompleted: rectangleDeviceDatas.setDatas();

        Connections {
            target: myDevice
            onDatasUpdated: rectangleDeviceDatas.setDatas()
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
                width: 72
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
                width: 32
                height: 32
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
                anchors.right: parent.right
                anchors.rightMargin: 8
                horizontalAlignment: Text.AlignLeft
                anchors.left: parent.left
                anchors.leftMargin: 44
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
        }

        Rectangle {
            id: rectangleDeviceDatas
            height: 100
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0
            border.width: 0

            anchors.top: rectanglePlant.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            function setDatas() {

                if (myDevice.deviceBattery < 15) {
                    imageBatt.source = "qrc:/assets/battery_low.svg";
                } else if (myDevice.deviceBattery > 75) {
                    imageBatt.source = "qrc:/assets/battery_full.svg";
                } else {
                    imageBatt.source = "qrc:/assets/battery_mid.svg";
                }

                var hours = Qt.formatDateTime (new Date(), "hh");
                if (hours > 22 || hours < 8) {
                    imageLuminosity.source = "qrc:/assets/night.svg";
                } else {
                    imageLuminosity.source = "qrc:/assets/day.svg";
                }

                // Temp
                if (myDevice.deviceTempC < 8)
                {
                    barTemp_low.color = "#ffbf66"
                    barTemp_good.color = "#e4e4e4"
                    barTemp_high.color = "#e4e4e4"
                }
                else if (myDevice.deviceTempC > 32)
                {
                    barTemp_low.color = "#e4e4e4"
                    barTemp_good.color = "#e4e4e4"
                    barTemp_high.color = "#ffbf66"
                }
                else
                {
                    barTemp_low.color = "#e4e4e4"
                    barTemp_good.color = "#87d241"
                    barTemp_high.color = "#e4e4e4"
                }

                // Hygro
                if (myDevice.deviceHygro < 15)
                {
                    barHygro_low.color = "#ffbf66"
                    barHygro_good.color = "#e4e4e4"
                    barHygro_high.color = "#e4e4e4"
                }
                else if (myDevice.deviceHygro > 60)
                {
                    barHygro_low.color = "#e4e4e4"
                    barHygro_good.color = "#e4e4e4"
                    barHygro_high.color = "#ffbf66"
                }
                else
                {
                    barHygro_low.color = "#e4e4e4"
                    barHygro_good.color = "#87d241"
                    barHygro_high.color = "#e4e4e4"
                }

                // Luminosity
                if (myDevice.deviceLuminosity < 500)
                {
                    barLux_low.color = "#ffbf66"
                    barLux_good.color = "#e4e4e4"
                    barLux_high.color = "#e4e4e4"
                }
                else if (myDevice.deviceLuminosity > 3000)
                {
                    barLux_low.color = "#e4e4e4"
                    barLux_good.color = "#e4e4e4"
                    barLux_high.color = "#ffbf66"
                }
                else
                {
                    barLux_low.color = "#e4e4e4"
                    barLux_good.color = "#87d241"
                    barLux_high.color = "#e4e4e4"
                }

                // Conductivity
                if (myDevice.deviceConductivity < 350)
                {
                    barCond_low.color = "#ffbf66"
                    barCond_good.color = "#e4e4e4"
                    barCond_high.color = "#e4e4e4"
                }
                else if (myDevice.deviceConductivity > 2000)
                {
                    barCond_low.color = "#e4e4e4"
                    barCond_good.color = "#e4e4e4"
                    barCond_high.color = "#ffbf66"
                }
                else
                {
                    barCond_low.color = "#e4e4e4"
                    barCond_good.color = "#87d241"
                    barCond_high.color = "#e4e4e4"
                }
            }

            Flow {
                id: flow1
                anchors.fill: parent

                Rectangle {
                    id: rectangle
                    width: 200
                    height: 48
                    color: "#ffffff"

                    Image {
                        id: imageHygro
                        x: 16
                        y: 3
                        width: 40
                        height: 40
                        source: "qrc:/assets/hygro.svg"
                    }

                    Text {
                        id: textHygro
                        x: 63
                        y: 8
                        width: 69
                        height: 15
                        text: myDevice.deviceHygro + "%"
                        font.pixelSize: 13
                    }

                    Rectangle {
                        id: barHygro_low
                        x: 63
                        y: 27
                        width: 24
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }

                    Rectangle {
                        id: barHygro_good
                        x: 93
                        y: 27
                        width: 48
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }

                    Rectangle {
                        id: barHygro_high
                        x: 147
                        y: 27
                        width: 23
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }
                }

                Rectangle {
                    id: rectangle1
                    width: 200
                    height: 48
                    color: "#ffffff"

                    Image {
                        id: imageTemp
                        x: 8
                        y: 6
                        width: 40
                        height: 40
                        source: "qrc:/assets/temp.svg" // FIXME svg error
                    }

                    Text {
                        id: textTemp
                        x: 54
                        y: 8
                        width: 108
                        height: 15
                        text: myDevice.getTempString()
                        font.pixelSize: 13
                    }

                    Rectangle {
                        id: barTemp_low
                        x: 54
                        y: 27
                        width: 24
                        height: 8
                        color: "#e4e4e4"
                        border.color: "#00000000"
                        border.width: 0
                    }

                    Rectangle {
                        id: barTemp_good
                        x: 84
                        y: 27
                        width: 48
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }

                    Rectangle {
                        id: barTemp_high
                        x: 138
                        y: 27
                        width: 23
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }
                }

                Rectangle {
                    id: rectangle2
                    width: 200
                    height: 48
                    color: "#ffffff"

                    Image {
                        id: imageLuminosity
                        x: 16
                        y: 4
                        width: 40
                        height: 40
                        source: "qrc:/assets/day.svg"
                    }

                    Text {
                        id: textLuminosity
                        x: 62
                        y: 8
                        text: myDevice.deviceLuminosity + " lumens"
                        font.pixelSize: 13
                    }

                    Rectangle {
                        id: barLux_low
                        x: 62
                        y: 27
                        width: 24
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }

                    Rectangle {
                        id: barLux_good
                        x: 92
                        y: 27
                        width: 48
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }

                    Rectangle {
                        id: barLux_high
                        x: 146
                        y: 27
                        width: 23
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }
                }

                Rectangle {
                    id: rectangle3
                    width: 200
                    height: 48
                    color: "#ffffff"

                    Image {
                        id: imageConductivity
                        x: 8
                        y: 4
                        width: 40
                        height: 40
                        source: "qrc:/assets/conductivity.svg"
                    }

                    Text {
                        id: textConductivity
                        x: 55
                        y: 8
                        text: myDevice.deviceConductivity + " µS/cm"
                        font.pixelSize: 13
                    }

                    Rectangle {
                        id: barCond_low
                        x: 55
                        y: 27
                        width: 24
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }

                    Rectangle {
                        id: barCond_good
                        x: 85
                        y: 27
                        width: 48
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }

                    Rectangle {
                        id: barCond_high
                        x: 139
                        y: 27
                        width: 23
                        height: 8
                        color: "#e4e4e4"
                        border.width: 0
                        border.color: "#00000000"
                    }
                }
            }
        }

        ChartBox {
            id: chartBox
            x: 0
            y: 0
            anchors.top: rectangleDeviceDatas.bottom
            anchors.bottom: parent.bottom
        }
    }
}
