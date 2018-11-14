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
    anchors.fill: parent

    Component.onCompleted: updateDatas()

    function loadDatas() {
        if (typeof myDevice === "undefined") return

        //console.log("DeviceScreenDatas // loadDatas() >> " + myDevice)

        deviceScreenCharts.loadGraph()
        updateDatas()
    }

    function updateDatas() {
        if (myDevice === 'undefined') return

        //console.log("DeviceScreenDatas // updateDatas() >> " + myDevice)

        // Update graph
        deviceScreenCharts.updateGraph()

        // Hygro
        if ((myDevice.deviceCapabilities & 4) == 0) {
            rectangleHygro.visible = false
        } else {
            rectangleHygro.visible = true

            if (myDevice.deviceHygro < 0) {
                textHygro.text = qsTr("No datas...")
                barHygro_low.color = badColor
                barHygro_good.color = badColor
                barHygro_high.color = badColor
            } else {
                textHygro.text = myDevice.deviceHygro + "% " + qsTr("humidity")

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
        }

        // Temp
        if ((myDevice.deviceCapabilities & 2) == 0) {
            rectangleTemp.visible = false
        } else {
            rectangleTemp.visible = true

            if (myDevice.deviceTempC < 0) {
                textTemp.text = qsTr("No datas...")
                barTemp_low.color = badColor
                barTemp_good.color = badColor
                barTemp_high.color = badColor
            } else {
                textTemp.text = myDevice.getTempString()

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
        }

        // Luminosity
        if ((myDevice.deviceCapabilities & 8) == 0) {
            rectangleLuminosity.visible = false
        } else {
            rectangleLuminosity.visible = true

            var hours = Qt.formatDateTime (new Date(), "hh")
            if (hours > 22 || hours < 8) {
                imageLuminosity.source = "qrc:/assets/night.svg"
            } else {
                imageLuminosity.source = "qrc:/assets/day.svg"
            }

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
        }

        // Conductivity
        if ((myDevice.deviceCapabilities & 16) == 0) {
            rectangleConductivity.visible = false
        } else {
            rectangleConductivity.visible = true

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
        }
    }

    Flow {
        id: flowData
        anchors.leftMargin: 4
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top

        Rectangle {
            id: rectangleHygro
            width: 173
            height: 48
            color: "#ffffff"

            Image {
                id: imageHygro
                x: 0
                y: 0
                width: 48
                height: 48
                source: "qrc:/assets/hygro.svg"
            }
            Text {
                id: textHygro
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.deviceHygro + "%"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
            }

            Rectangle {
                id: barHygro_low
                x: 57
                y: 27
                width: 28
                height: 8
                color: neutralColor
                anchors.verticalCenterOffset: 0
                anchors.right: barHygro_good.left
                anchors.rightMargin: 4
                anchors.verticalCenter: barHygro_good.verticalCenter
            }
            Rectangle {
                id: barHygro_good
                x: 82
                y: 31
                width: 56
                height: 8
                color: neutralColor
            }
            Rectangle {
                id: barHygro_high
                y: 27
                width: 28
                height: 8
                color: neutralColor
                anchors.verticalCenterOffset: 0
                anchors.left: barHygro_good.right
                anchors.leftMargin: 4
                anchors.verticalCenter: barHygro_good.verticalCenter
            }
        }

        Rectangle {
            id: rectangleTemp
            width: 173
            height: 48
            color: "#ffffff"

            Image {
                id: imageTemp
                x: 0
                y: 0
                width: 48
                height: 48
                source: "qrc:/assets/temp.svg"
            }
            Text {
                id: textTemp
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.getTempString()
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
            }

            Rectangle {
                id: barTemp_low
                x: 48
                y: 27
                width: 28
                height: 8
                color: neutralColor
                anchors.right: barTemp_good.left
                anchors.rightMargin: 4
                anchors.verticalCenterOffset: 0
                anchors.verticalCenter: barTemp_good.verticalCenter
            }
            Rectangle {
                id: barTemp_good
                x: 82
                y: 31
                width: 56
                height: 8
                color: neutralColor
            }
            Rectangle {
                id: barTemp_high
                y: 27
                width: 28
                height: 8
                color: neutralColor
                anchors.left: barTemp_good.right
                anchors.leftMargin: 4
                anchors.verticalCenter: barTemp_good.verticalCenter
            }
        }

        Rectangle {
            id: rectangleLuminosity
            width: 173
            height: 48
            color: "#ffffff"

            Image {
                id: imageLuminosity
                x: 0
                y: 0
                width: 48
                height: 48
                source: "qrc:/assets/day.svg"
            }
            Text {
                id: textLuminosity
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.deviceLuminosity + " lumens"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
            }

            Rectangle {
                id: barLux_low
                x: 48
                y: 32
                width: 28
                height: 8
                color: neutralColor
                anchors.right: barLux_good.left
                anchors.rightMargin: 4
                anchors.verticalCenter: barLux_good.verticalCenter
            }
            Rectangle {
                id: barLux_good
                x: 82
                y: 31
                width: 56
                height: 8
                color: neutralColor
            }
            Rectangle {
                id: barLux_high
                y: 30
                width: 28
                height: 8
                anchors.left: barLux_good.right
                anchors.leftMargin: 4
                anchors.verticalCenter: barLux_good.verticalCenter
                color: neutralColor
            }
        }

        Rectangle {
            id: rectangleConductivity
            width: 173
            height: 48
            color: "#ffffff"

            Image {
                id: imageConductivity
                x: 0
                y: 0
                width: 48
                height: 48
                source: "qrc:/assets/conductivity.svg"
            }
            Text {
                id: textConductivity
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.deviceConductivity + " µS/cm"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
            }

            Rectangle {
                id: barCond_low
                x: 48
                y: 27
                width: 28
                height: 8
                color: neutralColor
                anchors.right: barCond_good.left
                anchors.rightMargin: 4
                anchors.verticalCenter: barCond_good.verticalCenter
            }
            Rectangle {
                id: barCond_good
                x: 82
                y: 31
                width: 56
                height: 8
                color: neutralColor
            }
            Rectangle {
                id: barCond_high
                y: 27
                width: 28
                height: 8
                color: neutralColor
                anchors.left: barCond_good.right
                anchors.leftMargin: 4
                anchors.verticalCenter: barCond_good.verticalCenter
            }
        }
    }

    DeviceScreenCharts {
        id: deviceScreenCharts
        anchors.top: flowData.bottom
        anchors.bottom: parent.bottom
    }
}
