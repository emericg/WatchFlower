/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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

import ThemeEngine 1.0

Item {
    id: settingsScreen
    width: 480
    height: 640
    anchors.fill: parent
    anchors.leftMargin: screenLeftPadding
    anchors.rightMargin: screenRightPadding

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

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") ? rectangleHeader.bottom : parent.top
        anchors.topMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            id: column
            spacing: 8
            anchors.fill: parent
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            property int leftPad: 24

            ////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorForeground
                visible: isMobile

                ImageSvg {
                    id: image_appsettings
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                Text {
                    id: text_appsettings
                    anchors.left: image_appsettings.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Application")
                    font.pixelSize: 16
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////

            Item {
                id: element_theme
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                ImageSvg {
                    id: image_theme
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-style-24px.svg"
                }

                Text {
                    id: text_theme
                    height: 40
                    anchors.right: theme_selector.left
                    anchors.rightMargin: 16
                    anchors.left: image_theme.right
                    anchors.leftMargin: column.leftPad
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
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    z: 1
                    spacing: 10

                    Rectangle {
                        id: rectangleGreen
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        radius: 2
                        color: "#09debc" // green theme colorSecondary
                        border.color: Theme.colorPrimary
                        border.width: (settingsManager.appTheme === "green") ? 2 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.appTheme = "green"
                            }
                        }
                    }
                    Rectangle {
                        id: rectangleDay
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        radius: 2
                        color: "#FFE400" // day theme colorSecondary
                        border.color: Theme.colorPrimary
                        border.width: (settingsManager.appTheme === "day") ? 2 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.appTheme = "day"
                            }
                        }
                    }
                    Rectangle {
                        id: rectangleNight
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        radius: 2
                        color: "#555151"
                        border.color: Theme.colorPrimary
                        border.width: (settingsManager.appTheme === "night") ? 2 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.appTheme = "night"
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
                anchors.left: parent.left

                ImageSvg {
                    id: image_autoDarkmode
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-brightness_4-24px.svg"
                }

                Text {
                    id: text_autoDarkmode
                    height: 40
                    anchors.right: switch_autoDarkmode.left
                    anchors.rightMargin: 16
                    anchors.left: image_autoDarkmode.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Automatic dark mode")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_autoDarkmode
                    z: 1
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    Component.onCompleted: checked = settingsManager.autoDark
                    onCheckedChanged: {
                        settingsManager.autoDark = checked
                        Theme.loadTheme(settingsManager.appTheme)
                    }
                }
            }
            Text {
                id: legend_autoDarkmode
                topPadding: -12
                bottomPadding: isMobile ? 12 : 0
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16

                visible: (element_autoDarkmode.visible)

                text: qsTr("Dark mode will switch on automatically between 9 PM and 9 AM.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: element_bigwidget
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                // desktop (or tablet)
                visible: isDesktop

                ImageSvg {
                    id: image_bigwidget
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-format_size-24px.svg"
                }

                Text {
                    id: text_bigwidget
                    height: 40
                    anchors.right: switch_bigwidget.left
                    anchors.rightMargin: 16
                    anchors.left: image_bigwidget.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Use bigger widgets")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_bigwidget
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    Component.onCompleted: checked = settingsManager.bigWidget
                    onCheckedChanged: settingsManager.bigWidget = checked
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
                id: element_language
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                ImageSvg {
                    id: image_language
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-translate-24px.svg"
                }

                Text {
                    id: text_language
                    height: 40
                    anchors.right: combobox_language.left
                    anchors.rightMargin: 16
                    anchors.left: image_language.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Language")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBoxThemed {
                    id: combobox_language
                    width: 160
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    model: ListModel {
                        id: cbAppLanguage
                        ListElement {
                            //: Short for automatic
                            text: qsTr("auto");
                        }
                        ListElement { text: "Dansk"; }
                        ListElement { text: "Deutsch"; }
                        ListElement { text: "English"; }
                        ListElement { text: "Espanol"; }
                        ListElement { text: "Français"; }
                        ListElement { text: "Frisk"; }
                        ListElement { text: "Nederlands"; }
                        ListElement { text: "Pусский"; }
                    }

                    Component.onCompleted: {
                        for (var i = 0; i < cbAppLanguage.count; i++) {
                            if (cbAppLanguage.get(i).text === settingsManager.appLanguage)
                                currentIndex = i
                        }
                    }
                    property bool cbinit: false
                    onCurrentIndexChanged: {
                        if (cbinit) {
                            settingsManager.appLanguage = cbAppLanguage.get(currentIndex).text
                            utilsLanguage.loadLanguage(cbAppLanguage.get(currentIndex).text)
                        } else {
                            cbinit = true
                        }
                    }
                }
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
                id: element_bluetoothControl
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                // Android only
                visible: (Qt.platform.os === "android")

                ImageSvg {
                    id: image_bluetoothControl
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                }

                Text {
                    id: text_bluetoothControl
                    height: 40
                    anchors.left: image_bluetoothControl.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_bluetoothControl.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Bluetooth control")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_bluetoothControl
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    z: 1

                    Component.onCompleted: checked = settingsManager.bluetoothControl
                    onCheckedChanged: settingsManager.bluetoothControl = checked
                }
            }
            Text {
                id: legend_bluetoothControl
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 0

                visible: element_bluetoothControl.visible

                text: qsTr("WatchFlower can activate your device's Bluetooth in order to operate.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Item {
                id: element_bluetoothCompat
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                // mobile only
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                ImageSvg {
                    id: image_bluetoothCompat
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                }

                Text {
                    id: text_bluetoothCompat
                    height: 40
                    anchors.left: image_bluetoothCompat.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Bluetooth compatibility")
                    wrapMode: Text.WordWrap
                    anchors.right: switch_bluetoothCompat.left
                    anchors.rightMargin: 16
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_bluetoothCompat
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    z: 1

                    Component.onCompleted: checked = settingsManager.bluetoothCompat
                    onCheckedChanged: settingsManager.bluetoothCompat = checked
                }
            }
            Text {
                id: legend_bluetoothCompat
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 12

                visible: element_bluetoothCompat.visible

                text: qsTr("Sensors will be updated sequentially instead of simultaneously. Improve Bluetooth communication reliability, at the expense of synchronization speed.")
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
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
            }

            ////////

            Item {
                id: element_minimized
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                // desktop only
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                Text {
                    id: text_minimized
                    height: 40
                    anchors.right: switch_minimized.left
                    anchors.rightMargin: 16
                    anchors.left: image_minimized.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Start application minimized")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_minimized
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

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
                    source: "qrc:/assets/icons_material/duotone-minimize-24px.svg"
                }
            }

            ////////

            Item {
                id: element_worker
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                // desktop only // for now...
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

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

                Text {
                    id: text_worker
                    height: 40
                    anchors.leftMargin: column.leftPad
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

                SwitchThemedMobile {
                    id: switch_worker
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    z: 1

                    Component.onCompleted: checked = settingsManager.systray
                    onCheckedChanged: settingsManager.systray = checked
                }
            }
            Text {
                id: legend_worker_mobile
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 12

                visible: (element_worker.visible && (Qt.platform.os === "android" || Qt.platform.os === "ios"))

                text: qsTr("Wake up at a predefined intervals to refresh sensor data. Only if Bluetooth (or Bluetooth control) is enabled.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }
            Text {
                id: legend_worker_desktop
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 12

                visible: (element_worker.visible && (Qt.platform.os !== "android" && Qt.platform.os !== "ios"))

                text: qsTr("WatchFlower will remain active in the system tray, and will wake up at a regular intervals to refresh sensor data.")
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

                // desktop only // for now... // also, need the systray
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") && settingsManager.systray

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

                Text {
                    id: text_notifications
                    height: 40
                    anchors.left: image_notifications.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_notifiations.left
                    anchors.rightMargin: 16

                    text: qsTr("Enable notifications")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_notifiations
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    z: 1

                    Component.onCompleted: checked = settingsManager.notifications
                    onCheckedChanged: settingsManager.notifications = checked
                }
            }
            Text {
                id: legend_notifications
                topPadding: -12
                bottomPadding: 12
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16

                visible: element_notifiations.visible

                text: qsTr("If a plant needs water, WatchFlower will bring it to your attention!")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorForeground

                ImageSvg {
                    id: image_plantsensor
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/outline-local_florist-24px.svg"
                }

                Text {
                    id: text_plantsensor
                    anchors.left: image_plantsensor.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Plant sensors")
                    font.pixelSize: 16
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////

            Item {
                id: element_update
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

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

                Text {
                    id: text_update
                    height: 40
                    anchors.leftMargin: column.leftPad
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

                SpinBoxThemed {
                    id: spinBox_update
                    width: 128
                    height: 34
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    legend: qsTr(" h.")
                    from: 1
                    to: 6
                    stepSize: 1
                    editable: false

                    property bool sb_inited: false
                    Component.onCompleted: {
                        value = (settingsManager.updateIntervalPlant / 60)
                        sb_inited = true
                    }
                    onValueChanged: {
                        if (sb_inited) {
                            settingsManager.updateIntervalPlant = (value * 60)
                        }
                    }
                }
            }

            ////////

            Item {
                id: element_bigindicators
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                ImageSvg {
                    id: image_bigindicators
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-format_size-24px.svg"
                }

                Text {
                    id: text_bigindicators
                    height: 40
                    anchors.right: switch_bigindicators.left
                    anchors.rightMargin: 16
                    anchors.left: image_bigindicators.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Use bigger indicators")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_bigindicators
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    Component.onCompleted: checked = settingsManager.bigIndicator
                    onCheckedChanged: settingsManager.bigIndicator = checked
                }
            }

            Item {
                id: element_dynascale
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                ImageSvg {
                    id: image_dynascale
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-straighten-24px.svg"
                }

                Text {
                    id: text_dynascale
                    height: 40
                    anchors.right: switch_dynascale.left
                    anchors.rightMargin: 16
                    anchors.left: image_dynascale.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Dynamic scale for indicators")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_dynascale
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    Component.onCompleted: checked = settingsManager.dynaScale
                    onCheckedChanged: settingsManager.dynaScale = checked
                }
            }

            ////////

            Item {
                id: element_showdots
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                ImageSvg {
                    id: image_showdots
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-timeline-24px.svg"
                }

                Text {
                    id: text_showdots
                    height: 40
                    anchors.right: switch_showdots.left
                    anchors.rightMargin: 16
                    anchors.left: image_showdots.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Show graph dots")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_showdots
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    Component.onCompleted: checked = settingsManager.graphShowDots
                    onCheckedChanged: settingsManager.graphShowDots = checked
                }
            }

            ////////

            Item {
                id: element_plant_graph
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                ImageSvg {
                    id: image_plant_graph
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-insert_chart_outlined-24px.svg"
                }

                Text {
                    id: text_graph
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: image_plant_graph.right
                    anchors.leftMargin: column.leftPad
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
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

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

            ////////

            Rectangle {
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorForeground

                ImageSvg {
                    id: image_thermometer
                    width: 24
                    height: 24
                    anchors.leftMargin: 16
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-trip_origin-24px.svg"
                }

                Text {
                    id: text_thermometer
                    anchors.leftMargin: column.leftPad
                    anchors.left: image_thermometer.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Thermometers")
                    font.pixelSize: 16
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////

            Item {
                id: element_thermometer_update
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                ImageSvg {
                    id: image_thermometer_update
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    anchors.left: parent.left

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-timer-24px.svg"
                }

                Text {
                    id: text_thermometer_update
                    height: 40
                    anchors.leftMargin: column.leftPad
                    anchors.left: image_thermometer_update.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: spinBox_thermometer_update.left
                    anchors.rightMargin: 16

                    text: qsTr("Update interval")
                    font.pixelSize: 16
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SpinBoxThemed {
                    id: spinBox_thermometer_update
                    width: 128
                    height: 34
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    legend: qsTr(" h.")
                    from: 1
                    to: 6
                    stepSize: 1
                    editable: false

                    property bool sb_inited: false
                    Component.onCompleted: {
                        value = (settingsManager.updateIntervalThermo / 60)
                        sb_inited = true
                    }
                    onValueChanged: {
                        if (sb_inited) {
                            settingsManager.updateIntervalThermo = (value * 60)
                        }
                    }
                }
            }

            ////////

            Item {
                id: element_thermometer_unit
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                ImageSvg {
                    id: image_thermometer_unit
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    anchors.left: parent.left

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                }

                Text {
                    id: text_thermometer_unit
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: image_thermometer_unit.right
                    anchors.leftMargin: column.leftPad
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
                    anchors.verticalCenter: text_thermometer_unit.verticalCenter
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
            }
        }
    }
}
