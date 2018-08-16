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
    id: rectangleDeviceDatas

    anchors.rightMargin: 0
    anchors.leftMargin: 0
    anchors.topMargin: 0
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: parent.bottom

    Component.onCompleted: updateDatas()

    function updateDatas() {

        if ((myDevice.deviceCapabilities & 1) == 1) {
            if (myDevice.deviceBattery < 15) {
                imageBatt.source = "qrc:/assets/battery_low.svg";
            } else if (myDevice.deviceBattery > 75) {
                imageBatt.source = "qrc:/assets/battery_full.svg";
            } else {
                imageBatt.source = "qrc:/assets/battery_mid.svg";
            }
        } else {
            imageBatt.visible = false;
            textBatt.visible = false;
        }

        var hours = Qt.formatDateTime (new Date(), "hh");
        if (hours > 22 || hours < 8) {
            imageLuminosity.source = "qrc:/assets/night.svg";
        } else {
            imageLuminosity.source = "qrc:/assets/day.svg";
        }

        if ((myDevice.deviceCapabilities & 2) == 0) {
            rectangleTemp.visible = false
        }
        if ((myDevice.deviceCapabilities & 4) == 0) {
            rectangleHygro.visible = false
        }
        if ((myDevice.deviceCapabilities & 8) == 0) {
            rectangleLuminosity.visible = false
        }
        if ((myDevice.deviceCapabilities & 16) == 0) {
            rectangleConductivity.visible = false
        }

        // Hygro
        if (myDevice.deviceHygro < 0) {
            textHygro.text = qsTr("No datas...")
            barHygro_low.color = badColor
            barHygro_good.color = badColor
            barHygro_high.color = badColor
        } else {
            textHygro.text = myDevice.deviceHygro + "%"

            if (myDevice.deviceHygro < myDevice.limitHygroMin) {
                barHygro_low.color = badColor
                barHygro_good.color = neutralColor
                barHygro_high.color = neutralColor
            } else if (myDevice.deviceHygro > myDevice.limitHygroMax) {
                barHygro_low.color = neutralColor
                barHygro_good.color = neutralColor
                barHygro_high.color = badColor
            } else {
                barHygro_low.color = neutralColor
                barHygro_good.color = goodColor
                barHygro_high.color = neutralColor
            }
        }

        // Temp
        if (myDevice.deviceTempC < 0) {
            textTemp.text = qsTr("No datas...")
            barTemp_low.color = badColor
            barTemp_good.color = badColor
            barTemp_high.color = badColor
        } else {
            textTemp.text = myDevice.getTempString();

            if (myDevice.deviceTempC < myDevice.limitTempMin) {
                barTemp_low.color = badColor
                barTemp_good.color = neutralColor
                barTemp_high.color = neutralColor
            } else if (myDevice.deviceTempC > myDevice.limitTempMax) {
                barTemp_low.color = neutralColor
                barTemp_good.color = neutralColor
                barTemp_high.color = badColor
            } else {
                barTemp_low.color = neutralColor
                barTemp_good.color = goodColor
                barTemp_high.color = neutralColor
            }
        }
        
        // Luminosity
        if (myDevice.deviceLuminosity < 0) {
            textLuminosity.text = qsTr("No datas...")
            barLux_low.color = badColor
            barLux_good.color = badColor
            barLux_high.color = badColor
        } else {
            textLuminosity.text = myDevice.deviceLuminosity + " lumens"

            if (myDevice.deviceLuminosity < myDevice.limitLumiMin) {
                barLux_low.color = badColor
                barLux_good.color = neutralColor
                barLux_high.color = neutralColor
            } else if (myDevice.deviceLuminosity > myDevice.limitLumiMax) {
                barLux_low.color = neutralColor
                barLux_good.color = neutralColor
                barLux_high.color = badColor
            } else {
                barLux_low.color = neutralColor
                barLux_good.color = goodColor
                barLux_high.color = neutralColor
            }
        }

        // Conductivity
        if (myDevice.deviceConductivity < 0) {
            textConductivity.text = qsTr("No datas...")
            barCond_low.color = badColor
            barCond_good.color = badColor
            barCond_high.color = badColor
        } else {
            textConductivity.text = myDevice.deviceConductivity + " µS/cm"

            if (myDevice.deviceConductivity < myDevice.limitConduMin) {
                barCond_low.color = badColor
                barCond_good.color = neutralColor
                barCond_high.color = neutralColor
            } else if (myDevice.deviceConductivity > myDevice.limitConduMax) {
                barCond_low.color = neutralColor
                barCond_good.color = neutralColor
                barCond_high.color = badColor
            } else {
                barCond_low.color = neutralColor
                barCond_good.color = goodColor
                barCond_high.color = neutralColor
            }
        }

        deviceScreenCharts.updateGraph()
    }

    Flow {
        id: flow1
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top

        Rectangle {
            id: rectangleHygro
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
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barHygro_good
                x: 93
                y: 27
                width: 48
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barHygro_high
                x: 147
                y: 27
                width: 23
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
        }

        Rectangle {
            id: rectangleTemp
            width: 200
            height: 48
            color: "#ffffff"

            Image {
                id: imageTemp
                x: 8
                y: 6
                width: 40
                height: 40
                source: "qrc:/assets/temp.svg"
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
                color: neutralColor
                border.color: "#00000000"
                border.width: 0
            }
            Rectangle {
                id: barTemp_good
                x: 84
                y: 27
                width: 48
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
            Rectangle {
                id: barTemp_high
                x: 138
                y: 27
                width: 23
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
        }

        Rectangle {
            id: rectangleLuminosity
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
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
            Rectangle {
                id: barLux_good
                x: 92
                y: 27
                width: 48
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
            Rectangle {
                id: barLux_high
                x: 146
                y: 27
                width: 23
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
        }

        Rectangle {
            id: rectangleConductivity
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
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
            Rectangle {
                id: barCond_good
                x: 85
                y: 27
                width: 48
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
            Rectangle {
                id: barCond_high
                x: 139
                y: 27
                width: 23
                height: 8
                color: neutralColor
                border.width: 0
                border.color: "#00000000"
            }
        }
    }

    DeviceScreenCharts {
        id: deviceScreenCharts
        x: 0
        y: 0
        anchors.top: flow1.bottom
        anchors.bottom: parent.bottom
    }
}
