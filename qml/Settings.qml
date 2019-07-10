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

import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

Item {
    id: settingsScreen
    width: 480
    height: 640
    anchors.fill: parent

    Rectangle {
        id: rectangleHeader
        color: Theme.colorForeground
        height: 80
        z: 5

        visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Text {
            id: textTitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 12

            text: qsTr("Settings")
            font.bold: true
            font.pixelSize: 24
            color: Theme.colorText
        }

        Text {
            id: textSubtitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14

            text: qsTr("Change persistent settings here!")
            font.pixelSize: 18
            color: Theme.colorSubText
        }
    }

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") ? rectangleHeader.bottom : parent.top
        anchors.topMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            id: column
            anchors.fill: parent
            spacing: 8

            ////////

            Item {
                id: element_theme
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                ImageSvg {
                    id: image_theme
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-style-24px.svg"
                }

                Text {
                    id: text_theme
                    height: 40
                    anchors.right: theme_selector.left
                    anchors.rightMargin: 16
                    anchors.left: image_theme.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Application theme")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                Row {
                    id: theme_selector
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter

                    z: 1
                    spacing: 8

                    Rectangle {
                        id: rectangle1
                        width: 32
                        height: 32
                        color: "#09debc"
                        anchors.verticalCenter: parent.verticalCenter

                        border.color: Theme.colorHighlight
                        border.width: (settingsManager.appTheme === "green") ? 2 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.appTheme = "green"
                                Theme.loadTheme(settingsManager.appTheme)
                            }
                        }
                    }
                    Rectangle {
                        id: rectangle2
                        width: 32
                        height: 32
                        color: "#e4e4e4"
                        anchors.verticalCenter: parent.verticalCenter

                        border.color: Theme.colorHighlight
                        border.width: (settingsManager.appTheme === "day") ? 2 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.appTheme = "day"
                                Theme.loadTheme(settingsManager.appTheme)
                            }
                        }
                    }
                    Rectangle {
                        id: rectangle3
                        width: 32
                        height: 32
                        color: "#555151"
                        anchors.verticalCenter: parent.verticalCenter

                        border.color: Theme.colorHighlight
                        border.width: (settingsManager.appTheme === "night") ? 2 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.appTheme = "night"
                                Theme.loadTheme(settingsManager.appTheme)
                            }
                        }
                    }
                }
            }

            ////////

            Item {
                id: element_autoDarkmode
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                visible: (settingsManager.appTheme !== "night")

                Text {
                    id: text_autoDarkmode
                    height: 40
                    anchors.right: switch_autoDarkmode.left
                    anchors.rightMargin: 16
                    anchors.left: image_autoDarkmode.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Automatique dark mode")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemed {
                    id: switch_autoDarkmode
                    z: 1
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Component.onCompleted: checked = settingsManager.autoDark
                    onCheckedChanged: {
                        settingsManager.autoDark = checked
                        Theme.loadTheme(settingsManager.appTheme)
                    }
                }

                ImageSvg {
                    id: image_autoDarkmode
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-brightness_2-24px.svg"
                }
            }
            Text {
                id: legend_autoDarkmode
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 8

                visible: (element_autoDarkmode.visible)

                text: qsTr("Dark mode enables between 21 PM and 8 AM.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Rectangle {
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorSeparator
            }

            ////////

            Item {
                id: element_bluetoothControl
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                // mobile only
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                Text {
                    id: text_bluetoothControl
                    height: 40
                    anchors.left: image_bluetoothControl.right
                    anchors.leftMargin: 16
                    anchors.right: switch_bluetoothControl.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Bluetooth control")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemed {
                    id: switch_bluetoothControl
                    z: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    Component.onCompleted: checked = settingsManager.bluetoothControl
                    onCheckedChanged: settingsManager.bluetoothControl = checked
                }

                ImageSvg {
                    id: image_bluetoothControl
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-bluetooth_connected-24px.svg"
                }
            }
            Text {
                id: legend_bluetoothControl
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12

                visible: element_bluetoothControl.visible

                text: qsTr("WatchFlower can enable your device's Bluetooth in order to operate.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: element_bluetoothCompat
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                // mobile only
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                Text {
                    id: text_bluetoothCompat
                    height: 40
                    anchors.left: image_bluetoothCompat.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Bluetooth compatibility")
                    wrapMode: Text.WordWrap
                    anchors.right: switch_bluetoothCompat.left
                    anchors.rightMargin: 16
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemed {
                    id: switch_bluetoothCompat
                    z: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    Component.onCompleted: checked = settingsManager.bluetoothCompat
                    onCheckedChanged: settingsManager.bluetoothCompat = checked
                }

                ImageSvg {
                    id: image_bluetoothCompat
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-settings_bluetooth-24px.svg"
                }
            }
            Text {
                id: legend_bluetoothCompat
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 8

                visible: element_bluetoothCompat.visible

                text: qsTr("Improve Bluetooth reliability if your device has trouble connecting to sensors, at the expanse of sync speed.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Rectangle {
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorSeparator
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")
            }

            ////////

            Item {
                id: element_worker
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.leftMargin: 0

                // desktop only // for now...
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                SwitchThemed {
                    id: switch_worker
                    z: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    Component.onCompleted: checked = settingsManager.systray
                    onCheckedChanged: settingsManager.systray = checked
                    anchors.rightMargin: 12
                }

                Text {
                    id: text_worker
                    height: 40
                    anchors.leftMargin: 16
                    anchors.left: image_worker.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: switch_worker.left
                    anchors.rightMargin: 16

                    text: qsTr("Enable background updates")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                ImageSvg {
                    id: image_worker
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    anchors.left: parent.left

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                }
            }
            Text {
                id: legend_worker_mobile
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 8

                visible: (element_worker.visible && (Qt.platform.os === "android" || Qt.platform.os === "ios"))

                text: qsTr("Wake up at a predefined intervals to refresh sensor datas. Only if Bluetooth (or Bluetooth control) is enabled.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }
            Text {
                id: legend_worker_desktop
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12

                visible: (element_worker.visible && (Qt.platform.os !== "android" && Qt.platform.os !== "ios"))

                text: qsTr("WatchFlower stays active in the system tray and will wake up at a predefined intervals to refresh sensor datas.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: element_notifiations
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.leftMargin: 0

                // desktop only // for now... // also, need the systray
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") && settingsManager.systray

                SwitchThemed {
                    id: switch_notifiations
                    z: 1
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
                    anchors.right: switch_notifiations.left
                    anchors.rightMargin: 16

                    text: qsTr("Enable notifications")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
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
            Text {
                id: legend_notifications
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12

                visible: element_notifiations.visible

                text: qsTr("If a plant needs water, we'll be sure to bring it to your attention!")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: element_update
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.leftMargin: 0

                SpinBoxThemed {
                    id: spinBox_update
                    width: 128
                    height: 34
                    z: 1
                    Component.onCompleted: value = settingsManager.updateInterval
                    onValueChanged: settingsManager.updateInterval = value
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
                    anchors.right: spinBox_update.left
                    anchors.rightMargin: 16

                    text: qsTr("Update interval")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
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

            ////////

            Rectangle {
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorSeparator
            }

            ////////

            Item {
                id: element_minimized
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
                    anchors.right: switch_minimized.left
                    anchors.rightMargin: 16
                    anchors.left: image_minimized.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Start application minimized")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemed {
                    id: switch_minimized
                    z: 1
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

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-minimize-24px.svg"
                }
            }

            ////////

            Item {
                id: element_bigwidget
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                // desktop (or tablet)
                visible: (settingsManager.getScreenSize() > 7.0)

                Text {
                    id: text_bigwidget
                    height: 40
                    anchors.right: switch_bigwidget.left
                    anchors.rightMargin: 16
                    anchors.left: image_bigwidget.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Use bigger widgets")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemed {
                    id: switch_bigwidget
                    z: 1
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Component.onCompleted: checked = settingsManager.bigWidget
                    onCheckedChanged: settingsManager.bigWidget = checked
                }

                ImageSvg {
                    id: image_bigwidget
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-format_size-24px.svg"
                }
            }

            ////////

            Item {
                id: element_unit
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
                    anchors.right: radioDelegateCelsius.left
                    anchors.rightMargin: 16

                    text: qsTr("Temperature unit")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                RadioButtonThemed {
                    id: radioDelegateCelsius
                    height: 40
                    anchors.verticalCenter: text_unit.verticalCenter
                    anchors.right: radioDelegateFahrenheit.left

                    z: 1
                    text: qsTr("°C")
                    font.pixelSize: 14

                    checked: {
                        if (settingsManager.tempUnit === 'C') {
                            radioDelegateCelsius.checked = true
                            radioDelegateFahrenheit.checked = false
                        } else {
                            radioDelegateCelsius.checked = false
                            radioDelegateFahrenheit.checked = true
                        }
                    }
                    onCheckedChanged: {
                        if (checked === true)
                            settingsManager.tempUnit = 'C'
                    }
                }

                RadioButtonThemed {
                    id: radioDelegateFahrenheit
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    z: 1
                    text: qsTr("°F")
                    font.pixelSize: 14

                    checked: {
                        if (settingsManager.tempUnit === 'F') {
                            radioDelegateCelsius.checked = false
                            radioDelegateFahrenheit.checked = true
                        } else {
                            radioDelegateFahrenheit.checked = false
                            radioDelegateCelsius.checked = true
                        }
                    }
                    onCheckedChanged: {
                        if (checked === true)
                            settingsManager.tempUnit = 'F'
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

            ////////

            Item {
                id: element_graph
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

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                }

                Text {
                    id: text_graph
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: image_graph.right
                    anchors.leftMargin: 16
                    anchors.right: radioDelegateGraphMonthly.left
                    anchors.rightMargin: 16

                    text: qsTr("Histograms")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                RadioButtonThemed {
                    id: radioDelegateGraphMonthly
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: radioDelegateGraphWeekly.left

                    z: 1
                    text: qsTr("Monthly")
                    font.pixelSize: 14

                    checked: {
                        if (settingsManager.graphHistory === "monthly") {
                            radioDelegateGraphMonthly.checked = true
                            radioDelegateGraphWeekly.checked = false
                        } else {
                            radioDelegateGraphMonthly.checked = false
                            radioDelegateGraphWeekly.checked = true
                        }
                    }
                    onCheckedChanged: {
                        if (checked === true)
                            settingsManager.graphHistory = "monthly"
                    }
                }
                RadioButtonThemed {
                    id: radioDelegateGraphWeekly
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    z: 1
                    text: qsTr("Weekly")
                    font.pixelSize: 14

                    checked: {
                        if (settingsManager.graphHistory === "weekly") {
                            radioDelegateGraphMonthly.checked = false
                            radioDelegateGraphWeekly.checked = true
                        } else {
                            radioDelegateGraphWeekly.checked = false
                            radioDelegateGraphMonthly.checked = true
                        }
                    }
                    onCheckedChanged: {
                        if (checked === true)
                            settingsManager.graphHistory = "weekly"
                    }
                }
            }

            Item { // spacer
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
            }

            ////////
/*
            Item {
                id: element_reset
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                // desktop only // we keep this button here ONLY for debugging
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                Rectangle {
                    id: rectangleReset
                    height: 40
                    width: 320
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
                        font.pixelSize: 16
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: rectangleReset.startTheBlink()
                    }
                }
            }
*/
        }
    }
}
