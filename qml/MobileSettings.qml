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

import com.watchflower.theme 1.0

Item {
    id: settingsScreen
    width: 480
    height: 640
    anchors.fill: parent

    Column {
        id: column
        anchors.topMargin: 16
        anchors.fill: parent

        Item {
            id: element
            height: 48
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                id: text_bluetooth
                height: 40
                anchors.left: image_bluetooth.right
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Allow bluetooth control")
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }

            ThemedSwitch {
                id: switch_bluetooth
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12
                onCheckedChanged: settingsManager.bluetooth = checked
                //checked: settingsManager.bluetooth
                Component.onCompleted: checked = settingsManager.bluetooth
            }

            ImageSvg {
                id: image_bluetooth
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16

                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-bluetooth_searching-24px.svg"
            }
        }

        Item {
            id: element1
            height: 48
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            // desktop only
            //visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

            ThemedSwitch {
                id: switch_worker
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                checked: settingsManager.systray
                onCheckedChanged: settingsManager.systray = checked
                anchors.rightMargin: 12
            }

            Text {
                id: text_worker
                height: 40
                text: qsTr("Enable background updates")
                anchors.left: image_worker.right
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: 16
            }

            ImageSvg {
                id: image_worker
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16
                anchors.left: parent.left

                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-notifications_none-24px.svg"
            }
        }

        Item {
            id: element2
            height: 48
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            // desktop only
            //visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

            ThemedSwitch {
                id: switch_notifiations
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12
                onCheckedChanged: settingsManager.notifications = checked
                //checked: settingsManager.notifications
                Component.onCompleted: checked = settingsManager.notifications
            }

            Text {
                id: text_notifications
                height: 40
                text: qsTr("Enable notifications")
                anchors.left: image_notifications.right
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: 16
            }

            ImageSvg {
                id: image_notifications
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16

                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-notifications_none-24px.svg"
            }
        }

        Item {
            id: element3
            height: 48
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            SpinBox {
                id: spinBox_update
                width: 128
                height: 40
                value: 60
                onValueChanged: settingsManager.interval = value
                to: 180
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                stepSize: 30
                anchors.rightMargin: 12
                from: 30
            }

            Text {
                id: text_update
                height: 40
                anchors.leftMargin: 16
                anchors.left: image_update.right
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Update interval")
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }

            ImageSvg {
                id: image_update
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16
                anchors.left: parent.left

                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-timer-24px.svg"
            }
        }

        Item {
            id: element4
            height: 48
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            Text {
                id: text_unit
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: image_unit.right
                anchors.leftMargin: 16

                text: qsTr("Temperature unit")
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }

            ThemedRadioButton {
                id: radioDelegateCelsius
                height: 40
                text: qsTr("°C")
                anchors.verticalCenter: text_unit.verticalCenter
                anchors.right: radioDelegateFahrenheit.left

                font.pixelSize: 16
                checked: {
                    if (settingsManager.tempunit === 'C') {
                        radioDelegateCelsius.checked = true
                        radioDelegateFahrenheit.checked = false
                    } else {
                        radioDelegateCelsius.checked = false
                        radioDelegateFahrenheit.checked = true
                    }
                }
                onCheckedChanged: {
                    if (checked == true)
                        settingsManager.tempunit = 'C'
                }
            }

            ThemedRadioButton {
                id: radioDelegateFahrenheit
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12

                text: qsTr("°F")
                font.pixelSize: 16
                checked: {
                    if (settingsManager.tempunit === 'F') {
                        radioDelegateCelsius.checked = false
                        radioDelegateFahrenheit.checked = true
                    } else {
                        radioDelegateFahrenheit.checked = false
                        radioDelegateCelsius.checked = true
                    }
                }
                onCheckedChanged: {
                    if (checked == true)
                        settingsManager.tempunit = 'F'
                }
            }

            ImageSvg {
                id: image_unit
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16
                anchors.left: parent.left

                color: Theme.colorText
                source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
            }
        }
    }
}
