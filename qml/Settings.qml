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
import QtQuick.Controls 2.0

Rectangle {
    id: settingsRectangle
    color: "#eefbdb"
    width: 400
    height: 640

    property var mySettings

    Header {
        id: header
        anchors.top: parent.top

        backAvailable.visible: true
        scanAvailable.visible: false

        onBackClicked: {
            pageLoader.source = "main.qml"
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

        MouseArea {
            id: mouseArea // so the underlying stuff doesn't hijack clicks
            anchors.fill: parent

            Rectangle {
                id: rectangleReset
                height: 58
                color: "#f75a5a"

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16

                Text {
                    id: textReset
                    anchors.fill: parent
                    color: "#ffffff"
                    text: qsTr("Reset everything")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 20
                }
                MouseArea {
                    anchors.fill: parent

                    onPressed: {
                        rectangleReset.anchors.bottomMargin = rectangleReset.anchors.bottomMargin + 4
                        rectangleReset.anchors.leftMargin = rectangleReset.anchors.leftMargin + 4
                        rectangleReset.anchors.rightMargin = rectangleReset.anchors.rightMargin + 4
                        rectangleReset.width = rectangleReset.width - 8
                        rectangleReset.height = rectangleReset.height - 8
                    }
                    onReleased: {
                        rectangleReset.anchors.bottomMargin = rectangleReset.anchors.bottomMargin - 4
                        rectangleReset.anchors.leftMargin = rectangleReset.anchors.leftMargin - 4
                        rectangleReset.anchors.rightMargin = rectangleReset.anchors.rightMargin - 4
                        rectangleReset.width = rectangleReset.width + 8
                        rectangleReset.height = rectangleReset.height + 8
                    }
                    onClicked: {
                        mySettings.reset()
                    }
                }
            }
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
                width: 375
                height: 16
                text: "Change persistent settings here"
                anchors.left: parent.left
                anchors.leftMargin: 13
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
            }

            Text {
                id: text1
                height: 32
                color: "#454b54"
                text: qsTr("Settings")
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.top: parent.top
                anchors.topMargin: 12
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 26
            }
        }

        Rectangle {
            id: rectangleSettings
            y: 41
            width: 368
            height: 180
            color: "#f2f2f2"
            border.width: 0
            anchors.top:rectangleHeader.bottom
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Image {
                id: image_systray
                width: 32
                height: 32
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 12
                source: "../assets/app/watchflower_tray.svg"
            }

            CheckBox {
                id: checkBox_systray
                width: 332
                height: 40
                text: qsTr("Enable system tray icon")
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 8
                checked: mySettings.systray

                onCheckStateChanged: {
                    mySettings.systray = checked
                }
            }

            SpinBox {
                id: spinBox_update
                width: 128
                height: 40
                anchors.top: checkBox_systray.bottom
                anchors.topMargin: 16
                from: 30
                stepSize: 30
                to: 120
                anchors.left: parent.left
                anchors.leftMargin: 12
                value: mySettings.interval

                onValueChanged: {
                    mySettings.interval = value
                }
            }

            Text {
                id: text2
                width: 234
                height: 40
                anchors.top: spinBox_update.top
                anchors.topMargin: 0
                anchors.left: spinBox_update.right
                anchors.leftMargin: 16

                font.pointSize: 12
                verticalAlignment: Text.AlignVCenter

                text: qsTr("Update interval in minutes")
            }

            Text {
                id: text3
                x: 3
                y: 128
                height: 40
                text: qsTr("Temperature unit:")
                font.pointSize: 12
                anchors.top: spinBox_update.bottom
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 12
                verticalAlignment: Text.AlignVCenter
            }

            RadioDelegate {
                id: radioDelegateCelsius
                height: 40
                text: qsTr("°C")
                anchors.left: text3.right
                anchors.leftMargin: 8
                anchors.top: text3.top
                anchors.topMargin: 0

                checked: {
                    if (mySettings.tempunit === 'C') {
                        radioDelegateCelsius.checked = true;
                        radioDelegateFahrenheit.checked = false;
                    } else {
                        radioDelegateCelsius.checked = false;
                        radioDelegateFahrenheit.checked = true;
                    }
                }

                onCheckedChanged: {
                    if (checked == true)
                        mySettings.tempunit = 'C';
                }
            }

            RadioDelegate {
                id: radioDelegateFahrenheit
                height: 40
                text: qsTr("°F")
                anchors.left: radioDelegateCelsius.right
                anchors.leftMargin: 0
                anchors.top: text3.top
                anchors.topMargin: 0

                checked: {
                    if (mySettings.tempunit === 'F') {
                        radioDelegateCelsius.checked = false;
                        radioDelegateFahrenheit.checked = true;
                    } else {
                        radioDelegateFahrenheit.checked = false;
                        radioDelegateCelsius.checked = true;
                    }
                }

                onCheckedChanged: {
                    if (checked === true)
                        mySettings.tempunit = 'F';
                }
            }
        }
    }
}
