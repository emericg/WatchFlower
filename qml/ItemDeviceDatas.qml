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
//import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

Item {
    id: deviceDatas
    width: 400
    height: 300

    function normalize(value, min, max) {
        if (value <= 0) return 0
        return Math.min(((value - min) / (max - min)), 1)
    }

    function loadDatas() {
        if (typeof myDevice === "undefined") return

        updateDatas()
    }

    function updateDatas() {
        if (typeof myDevice === 'undefined' || !myDevice) return

        if (myDevice.deviceName === "MJ_HT_V1") {
            //
        } else {
            //
        }

        // Has datas? always display them
        if (myDevice.deviceTempC > 0) {

            humi.visible = (myDevice.deviceHygro > 0) ? true : false
            humi_indicator.text = myDevice.deviceHygro + "%"
            humi_data.width = normalize(myDevice.deviceHygro, 0, 50) * humi_bg.width

            temp_indicator.text = myDevice.getTempString()
            temp_data.width = normalize(myDevice.deviceTempC, 0, 40) * temp_bg.width

            lumi.visible = (myDevice.deviceLuminosity > 0) ? true : false
            lumi_indicator.text = myDevice.deviceLuminosity + " lumen"
            lumi_data.width = normalize(myDevice.deviceLuminosity, 0, 10000) * lumi_bg.width

            condu.visible = (myDevice.deviceConductivity > 0) ? true : false
            condu_indicator.text = myDevice.deviceConductivity + " µS/cm"
            condu_data.width = normalize(myDevice.deviceConductivity, 0, 750) * condu_bg.width
        }
    }

    onWidthChanged: {
        if (typeof myDevice === "undefined") return

        updateDatas()
    }

    Column {
        id: row
        anchors.fill: parent

        Item { //////
            id: humi
            height: 38
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Text {
                id: humi_legend
                width: 96
                color: "#333333"
                text: qsTr("Humidity")
                horizontalAlignment: Text.AlignRight
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: humi_bg.verticalCenter
                font.pixelSize: 14
            }

            Rectangle {
                id: humi_bg
                color: Theme.colorSeparators
                height: 8
                radius: 3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.left: humi_legend.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                Rectangle {
                    id: humi_data
                    width: 150
                    color: Theme.colorBlue
                    radius: 3
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }

                Text {
                    id: humi_indicator
                    y: -22
                    height: 15
                    anchors.right: humi_data.right
                    anchors.rightMargin: -width/2 + 4

                    color: "#ffffff"
                    text: qsTr("21%")
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.pixelSize: 12

                    Rectangle {
                        height: 18
                        color: Theme.colorBlue
                        radius: 1
                        anchors.left: parent.left
                        anchors.leftMargin: -4
                        anchors.right: parent.right
                        anchors.rightMargin: -4
                        anchors.verticalCenter: parent.verticalCenter
                        z: -1
                        Rectangle {
                            width: 6
                            height: 6
                            color: Theme.colorBlue
                            anchors.top: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            rotation: 45
                            anchors.topMargin: -3
                        }
                    }
                }
            }
        }
        Item { //////
            id: temp
            height: 38
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Text {
                id: temp_legend
                width: 96
                color: Theme.colorText
                text: qsTr("Temperature")
                horizontalAlignment: Text.AlignRight
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: temp_bg.verticalCenter
                font.pixelSize: 14
            }

            Rectangle {
                id: temp_bg
                color: Theme.colorSeparators
                height: 8
                radius: 3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.left: temp_legend.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                Rectangle {
                    id: temp_data
                    width: 150
                    color: Theme.colorGreen
                    radius: 3
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }

                Text {
                    id: temp_indicator
                    y: -22
                    height: 15
                    anchors.right: temp_data.right
                    anchors.rightMargin: -width/2 + 4

                    color: "#ffffff"
                    text: qsTr("21%")
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.pixelSize: 12

                    Rectangle {
                        height: 18
                        color: Theme.colorGreen
                        radius: 1
                        anchors.left: parent.left
                        anchors.leftMargin: -4
                        anchors.right: parent.right
                        anchors.rightMargin: -4
                        anchors.verticalCenter: parent.verticalCenter
                        z: -1
                        Rectangle {
                            width: 6
                            height: 6
                            color: Theme.colorGreen
                            anchors.top: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            rotation: 45
                            anchors.topMargin: -3
                        }
                    }
                }
            }
        }
        Item { //////
            id: lumi
            height: 38
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Text {
                id: lumi_legend
                width: 96
                color: Theme.colorText
                text: qsTr("Luminosity")
                horizontalAlignment: Text.AlignRight
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: lumi_bg.verticalCenter
                font.pixelSize: 14
            }

            Rectangle {
                id: lumi_bg
                color: Theme.colorSeparators
                height: 8
                radius: 3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.left: lumi_legend.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                Rectangle {
                    id: lumi_data
                    width: 150
                    color: Theme.colorYellow
                    radius: 3
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }

                Text {
                    id: lumi_indicator
                    y: -22
                    height: 15
                    anchors.right: lumi_data.right
                    anchors.rightMargin: -width/2 + 4

                    color: "#ffffff"
                    text: qsTr("21%")
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.pixelSize: 12

                    Rectangle {
                        height: 18
                        color: Theme.colorYellow
                        radius: 1
                        anchors.left: parent.left
                        anchors.leftMargin: -4
                        anchors.right: parent.right
                        anchors.rightMargin: -4
                        anchors.verticalCenter: parent.verticalCenter
                        z: -1
                        Rectangle {
                            width: 6
                            height: 6
                            color: Theme.colorYellow
                            anchors.top: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            rotation: 45
                            anchors.topMargin: -3
                        }
                    }
                }
            }
        }
        Item { //////
            id: condu
            height: 38
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Text {
                id: condu_legend
                width: 96
                color: Theme.colorText
                text: qsTr("Conductivity")
                horizontalAlignment: Text.AlignRight
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: condu_bg.verticalCenter
                font.pixelSize: 14
            }

            Rectangle {
                id: condu_bg
                color: Theme.colorSeparators
                height: 8
                radius: 3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.left: condu_legend.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                Rectangle {
                    id: condu_data
                    width: 150
                    color: Theme.colorRed
                    radius: 3
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }

                Text {
                    id: condu_indicator
                    y: -22
                    height: 15
                    anchors.right: condu_data.right
                    anchors.rightMargin: -width/2 + 4

                    color: "#ffffff"
                    text: qsTr("21%")
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.pixelSize: 12

                    Rectangle {
                        height: 18
                        color: Theme.colorRed
                        radius: 1
                        anchors.left: parent.left
                        anchors.leftMargin: -4
                        anchors.right: parent.right
                        anchors.rightMargin: -4
                        anchors.verticalCenter: parent.verticalCenter
                        z: -1
                        Rectangle {
                            width: 6
                            height: 6
                            color: Theme.colorRed
                            anchors.top: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            rotation: 45
                            anchors.topMargin: -3
                        }
                    }
                }
            }
        }
    }
}
