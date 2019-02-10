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
        if (typeof myDevice === 'undefined' || !myDevice) return

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
                barHygro_low.color = Theme.colorBad
                barHygro_good.color = Theme.colorBad
                barHygro_high.color = Theme.colorBad
            } else {
                textHygro.text = myDevice.deviceHygro + "% " + qsTr("humidity")

                if (myDevice.deviceHygro < myDevice.limitHygroMin) {
                    barHygro_low.color = Theme.colorBad
                    barHygro_good.color = Theme.colorNeutralDay
                    barHygro_high.color = Theme.colorNeutralDay
                } else if (myDevice.deviceHygro > myDevice.limitHygroMax) {
                    barHygro_low.color = Theme.colorNeutralDay
                    barHygro_good.color = Theme.colorNeutralDay
                    barHygro_high.color = Theme.colorBad
                } else {
                    barHygro_low.color = Theme.colorNeutralDay
                    barHygro_good.color = Theme.colorGood
                    barHygro_high.color = Theme.colorNeutralDay
                }
            }
        }

        // Temp
        if ((myDevice.deviceCapabilities & 2) == 0) {
            rectangleTemp.visible = false
        } else {
            rectangleTemp.visible = true

            if (myDevice.deviceTempC < -100) {
                textTemp.text = qsTr("No datas...")
                barTemp_low.color = Theme.colorBad
                barTemp_good.color = Theme.colorBad
                barTemp_high.color = Theme.colorBad
            } else {
                textTemp.text = myDevice.getTempString()

                if (myDevice.deviceTempC < myDevice.limitTempMin) {
                    barTemp_low.color = Theme.colorBad
                    barTemp_good.color = Theme.colorNeutralDay
                    barTemp_high.color = Theme.colorNeutralDay
                } else if (myDevice.deviceTempC > myDevice.limitTempMax) {
                    barTemp_low.color = Theme.colorNeutralDay
                    barTemp_good.color = Theme.colorNeutralDay
                    barTemp_high.color = Theme.colorBad
                } else {
                    barTemp_low.color = Theme.colorNeutralDay
                    barTemp_good.color = Theme.colorGood
                    barTemp_high.color = Theme.colorNeutralDay
                }
            }
        }

        // Luminosity
        if ((myDevice.deviceCapabilities & 8) == 0) {
            rectangleLuminosity.visible = false
        } else {
            rectangleLuminosity.visible = true

            var hours = Qt.formatDateTime (new Date(), "hh")
            if (hours >= 21 || hours <= 8) {
                imageLuminosity.source = "qrc:/assets/icons_material/baseline-brightness_2-24px.svg"
            } else {
                imageLuminosity.source = "qrc:/assets/icons_material/baseline-wb_sunny-24px.svg"
            }

            if (myDevice.deviceLuminosity < 0) {
                textLuminosity.text = qsTr("No datas...")
                barLux_low.color = Theme.colorBad
                barLux_good.color = Theme.colorBad
                barLux_high.color = Theme.colorBad
            } else {
                textLuminosity.text = myDevice.deviceLuminosity + " lumens"

                if (myDevice.deviceLuminosity < myDevice.limitLumiMin) {
                    barLux_low.color = Theme.colorBad
                    barLux_good.color = Theme.colorNeutralDay
                    barLux_high.color = Theme.colorNeutralDay
                } else if (myDevice.deviceLuminosity > myDevice.limitLumiMax) {
                    barLux_low.color = Theme.colorNeutralDay
                    barLux_good.color = Theme.colorNeutralDay
                    barLux_high.color = Theme.colorBad
                } else {
                    barLux_low.color = Theme.colorNeutralDay
                    barLux_good.color = Theme.colorGood
                    barLux_high.color = Theme.colorNeutralDay
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
                barCond_low.color = Theme.colorBad
                barCond_good.color = Theme.colorBad
                barCond_high.color = Theme.colorBad
            } else {
                textConductivity.text = myDevice.deviceConductivity + " µS/cm"

                if (myDevice.deviceConductivity < myDevice.limitConduMin) {
                    barCond_low.color = Theme.colorBad
                    barCond_good.color = Theme.colorNeutralDay
                    barCond_high.color = Theme.colorNeutralDay
                } else if (myDevice.deviceConductivity > myDevice.limitConduMax) {
                    barCond_low.color = Theme.colorNeutralDay
                    barCond_good.color = Theme.colorNeutralDay
                    barCond_high.color = Theme.colorBad
                } else {
                    barCond_low.color = Theme.colorNeutralDay
                    barCond_good.color = Theme.colorGood
                    barCond_high.color = Theme.colorNeutralDay
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
            color: "#00000000"

            Image {
                id: imageHygro
                x: 8
                y: 8
                width: 32
                height: 32
                source: "qrc:/assets/icons_material/baseline-opacity-24px.svg"
                sourceSize: Qt.size(width, height)

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Text {
                id: textHygro
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.deviceHygro + "%"
                color: Theme.colorIcons
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
                color: Theme.colorNeutralDay
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
                color: Theme.colorNeutralDay
            }
            Rectangle {
                id: barHygro_high
                y: 27
                width: 28
                height: 8
                color: Theme.colorNeutralDay
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
            color: "#00000000"

            Image {
                id: imageTemp
                x: 8
                y: 8
                width: 32
                height: 32
                source: "qrc:/assets/icons_material/baseline-pin_drop-24px.svg"
                sourceSize: Qt.size(width, height)

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Text {
                id: textTemp
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.getTempString()
                color: Theme.colorIcons
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
                color: Theme.colorNeutralDay
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
                color: Theme.colorNeutralDay
            }
            Rectangle {
                id: barTemp_high
                y: 27
                width: 28
                height: 8
                color: Theme.colorNeutralDay
                anchors.left: barTemp_good.right
                anchors.leftMargin: 4
                anchors.verticalCenter: barTemp_good.verticalCenter
            }
        }

        Rectangle {
            id: rectangleLuminosity
            width: 173
            height: 48
            color: "#00000000"

            Image {
                id: imageLuminosity
                x: 8
                y: 8
                width: 32
                height: 32
                source: "qrc:/assets/icons_material/baseline-wb_sunny-24px.svg"
                sourceSize: Qt.size(width, height)

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Text {
                id: textLuminosity
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.deviceLuminosity + " lumens"
                color: Theme.colorIcons
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
                color: Theme.colorNeutralDay
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
                color: Theme.colorNeutralDay
            }
            Rectangle {
                id: barLux_high
                y: 30
                width: 28
                height: 8
                anchors.left: barLux_good.right
                anchors.leftMargin: 4
                anchors.verticalCenter: barLux_good.verticalCenter
                color: Theme.colorNeutralDay
            }
        }

        Rectangle {
            id: rectangleConductivity
            width: 173
            height: 48
            color: "#00000000"

            Image {
                id: imageConductivity
                x: 8
                y: 8
                width: 32
                height: 32
                source: "qrc:/assets/icons_material/baseline-flash_on-24px.svg"
                sourceSize: Qt.size(width, height)

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Text {
                id: textConductivity
                x: 50
                y: 8
                width: 120
                height: 18
                text: myDevice.deviceConductivity + " µS/cm"
                color: Theme.colorIcons
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
                color: Theme.colorNeutralDay
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
                color: Theme.colorNeutralDay
            }
            Rectangle {
                id: barCond_high
                y: 27
                width: 28
                height: 8
                color: Theme.colorNeutralDay
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
