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
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

Item {
    id: settingsScreen
    width: 480
    height: 640
    anchors.fill: parent

    Rectangle {
        id: rectangleSettingsTitle
        height: 80
        color: Theme.colorMaterialDarkGrey

        visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Text {
            id: textTitle
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12

            color: Theme.colorText
            text: qsTr("Settings")
            font.bold: true
            font.pixelSize: 26
        }

        Text {
            id: textSubtitle
            text: qsTr("Change persistent settings here!")
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
        }
    }

    ScrollView {
        id: scrollView
        clip: true
        contentWidth: -1

        anchors.top: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") ? rectangleSettingsTitle.bottom : parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            id: column
            anchors.fill: parent
            anchors.topMargin: 12
            spacing: 4

            Item {
                id: element1
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                // desktop only
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                Text {
                    id: text_minimized
                    height: 40
                    text: qsTr("Start application minimized")
                    anchors.left: image_minimized.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                }

                ThemedSwitch {
                    id: switch_minimized
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Component.onCompleted: checked = settingsManager.minimized
                    onCheckedChanged: settingsManager.minimized = checked
                }

                ImageSvg {
                    id: image_minimized
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorIcons
                    source: "qrc:/assets/icons_material/baseline-minimize-24px.svg"
                }
            }

            Item {
                id: element2
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                // mobile only
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

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
                    Component.onCompleted: checked = settingsManager.bluetooth
                    onCheckedChanged: settingsManager.bluetooth = checked
                }

                ImageSvg {
                    id: image_bluetooth
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorIcons
                    source: "qrc:/assets/icons_material/baseline-bluetooth_searching-24px.svg"
                }
            }

            Text {
                id: ledend_bluetooth
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -8

                // mobile only
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                text: qsTr("WatchFlower can enable your device's bluetooth in order to operate")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            Item {
                id: element3
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
                    anchors.leftMargin: 16
                    anchors.left: image_worker.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Enable background updates")
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                }

                ImageSvg {
                    id: image_worker
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    anchors.left: parent.left

                    color: Theme.colorIcons
                    source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                }
            }

            Text {
                id: legend_worker
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -8

                // mobile only
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                text: qsTr("Wake up at a pre-defined intervals to update sensors datas. Only if bluetooth or bluetooth control is enabled.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            Item {
                id: element4
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
                    Component.onCompleted: checked = settingsManager.notifications
                    onCheckedChanged: settingsManager.notifications = checked
                }

                Text {
                    id: text_notifications
                    height: 40
                    anchors.left: image_notifications.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16

                    text: qsTr("Enable notifications")
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                }

                ImageSvg {
                    id: image_notifications
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorIcons
                    source: "qrc:/assets/icons_material/baseline-notifications_none-24px.svg"
                }
            }

            Text {
                id: legend_notifications
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -8

                // mobile only
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                text: qsTr("If a plant needs water, we'll be sure to bring it to your attention")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            Item {
                id: element5
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.leftMargin: 0

                ThemedSpinBox {
                    id: spinBox_update
                    width: 128
                    height: 36
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

                    color: Theme.colorIcons
                    source: "qrc:/assets/icons_material/baseline-timer-24px.svg"
                }
            }

            Item {
                id: element6
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

                    color: Theme.colorIcons
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                }
            }

            Item {
                id: element7
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.leftMargin: 0

                ImageSvg {
                    id: image_graph
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorIcons
                    source: "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                }

                Text {
                    id: text_graph
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: image_graph.right
                    anchors.leftMargin: 16

                    text: qsTr("Default history mode")
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                }

                ThemedRadioButton {
                    id: radioDelegateGraphMonthly
                    height: 40
                    text: qsTr("Monthly")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: radioDelegateGraphWeekly.left

                    font.pixelSize: 16
                    checked: {
                        if (settingsManager.graphview === "monthly") {
                            radioDelegateGraphMonthly.checked = true
                            radioDelegateGraphWeekly.checked = false
                        } else {
                            radioDelegateGraphMonthly.checked = false
                            radioDelegateGraphWeekly.checked = true
                        }
                    }
                    onCheckedChanged: {
                        if (checked == true)
                            settingsManager.graphview = "monthly"
                    }
                }
                ThemedRadioButton {
                    id: radioDelegateGraphWeekly
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    text: qsTr("Weekly")
                    font.pixelSize: 16
                    checked: {
                        if (settingsManager.graphview === "weekly") {
                            radioDelegateGraphMonthly.checked = false
                            radioDelegateGraphWeekly.checked = true
                        } else {
                            radioDelegateGraphWeekly.checked = false
                            radioDelegateGraphMonthly.checked = true
                        }
                    }
                    onCheckedChanged: {
                        if (checked == true)
                            settingsManager.graphview = "weekly"
                    }
                }
            }

            Item {
                id: element9
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                // desktop only
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                Rectangle {
                    id: rectangleReset
                    height: 40
                    width: 300
                    color: Theme.colorRed
                    radius: 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    property bool weAreBlinking: false

                    function startTheBlink() {
                        if (weAreBlinking === true) {
                            settingsManager.resetSettings()
                            stopTheBlink()
                        } else {
                            weAreBlinking = true
                            timerReset.start()
                            blinkReset.start()
                            textReset.text = qsTr("!!! Click again to confirm !!!")
                        }
                    }
                    function stopTheBlink() {
                        weAreBlinking = false
                        timerReset.stop()
                        blinkReset.stop()
                        textReset.text = qsTr("Reset sensors & datas!")
                        rectangleReset.color = Theme.colorRed
                    }

                    SequentialAnimation on color {
                        id: blinkReset
                        running: false
                        loops: Animation.Infinite
                        ColorAnimation { from: Theme.colorRed; to: Theme.colorYellow; duration: 1000 }
                        ColorAnimation { from: Theme.colorYellow; to: Theme.colorRed; duration: 1000 }
                    }

                    Timer {
                        id: timerReset
                        interval: 4000
                        running: false
                        repeat: false
                        onTriggered: rectangleReset.stopTheBlink()
                    }

                    Text {
                        id: textReset
                        anchors.fill: parent
                        color: "white"
                        text: qsTr("Reset sensors & datas!")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: false
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 18
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: rectangleReset.startTheBlink()
                    }
                }
            }
        }
    }
}
