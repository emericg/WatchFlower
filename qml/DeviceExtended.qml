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
    width: 400
    height: 640

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
        }

        Rectangle {
            id: rectangleDevice
            height: 40
            color: "#f9f9f9"
            border.width: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: rectanglePlant.bottom
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
            color: "#f2f2f2"
            border.width: 0
            anchors.top:rectangleHeader.bottom
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
            height: 108
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0
            border.width: 0

            anchors.top: rectangleDevice.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle {
                id: barCond_high
                x: 338
                y: 81
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barCond_good
                x: 284
                y: 81
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barCond_low
                x: 254
                y: 81
                width: 24
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barHygro_high
                x: 156
                y: 36
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barHygro_good
                x: 102
                y: 36
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barHygro_low
                x: 72
                y: 36
                width: 24
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barLux_high
                x: 155
                y: 81
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barLux_good
                x: 101
                y: 81
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barLux_low
                x: 71
                y: 81
                width: 24
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barTemp_high
                x: 338
                y: 36
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barTemp_good
                x: 284
                y: 36
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barTemp_low
                x: 254
                y: 36
                width: 24
                height: 8
                color: "#e4e4e4"
                border.color: "#00000000"
                border.width: 0
            }

            Text {
                id: textConductivity
                x: 254
                y: 62
                text: myDevice.deviceConductivity + " µS/cm"
                font.pixelSize: 13
            }

            Text {
                id: textHygro
                x: 72
                y: 17
                width: 69
                height: 15
                text: myDevice.deviceHygro + "%"
                font.pixelSize: 13
            }

            Text {
                id: textLuminosity
                x: 71
                y: 62
                text: myDevice.deviceLuminosity + " lumens"
                font.pixelSize: 13
            }

            Text {
                id: textTemp
                x: 254
                y: 17
                width: 108
                height: 15
                text: myDevice.deviceTemp.toFixed(1) + "°C"
                font.pixelSize: 13
            }

            Image {
                id: imageConductivity
                x: 207
                y: 58
                width: 40
                height: 40
                source: "qrc:/assets/conductivity.svg"
            }

            Image {
                id: imageLuminosity
                x: 25
                y: 58
                width: 40
                height: 40
                source: "qrc:/assets/day.svg"
            }

            Image {
                id: imageHygro
                x: 25
                y: 12
                width: 40
                height: 40
                source: "qrc:/assets/hygro.svg"
            }

            Image {
                id: imageTemp
                x: 208
                y: 12
                width: 40
                height: 40
                source: "qrc:/assets/temp.svg" // FIXME svg error
            }

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
                if (myDevice.deviceTemp < 8)
                {
                    barTemp_low.color = "#ffbf66"
                    barTemp_good.color = "#e4e4e4"
                    barTemp_high.color = "#e4e4e4"
                }
                else if (myDevice.deviceTemp > 32)
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
