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

import QtQuick 2.12
import QtQuick.Controls 2.12

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

        visible: isDesktop

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        // prevent clicks into this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        Text {
            id: textTitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 12

            text: qsTr("Settings")
            font.bold: true
            font.pixelSize: Theme.fontSizeTitle
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

        anchors.top: (rectangleHeader.visible) ? rectangleHeader.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            id: column
            anchors.fill: parent

            topPadding: 12
            bottomPadding: 12
            spacing: 8

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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-style-24px.svg"
                }

                Text {
                    id: text_theme
                    height: 40
                    anchors.left: image_theme.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: theme_selector.left
                    anchors.rightMargin: 16
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-brightness_4-24px.svg"
                }

                Text {
                    id: text_autoDarkmode
                    height: 40
                    anchors.left: image_autoDarkmode.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_autoDarkmode.left
                    anchors.rightMargin: 16
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-translate-24px.svg"
                }

                Text {
                    id: text_language
                    height: 40
                    anchors.left: image_language.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: combobox_language.left
                    anchors.rightMargin: 16
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
                    height: 36
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
                        ListElement { text: "Español"; }
                        ListElement { text: "Français"; }
                        ListElement { text: "Frysk"; }
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
                            utilsLanguage.loadLanguage(cbAppLanguage.get(currentIndex).text)
                            settingsManager.appLanguage = cbAppLanguage.get(currentIndex).text
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

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
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
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
                id: element_bluetoothSimUpdate
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                ImageSvg {
                    id: image_bluetoothSimUpdate
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                }

                Text {
                    id: text_bluetoothSimUpdate1
                    height: 40
                    anchors.left: image_bluetoothSimUpdate.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isDesktop

                    text: qsTr("Simultaneous updates") + " (" + settingsManager.bluetoothSimUpdates + ")"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }
                SliderThemed {
                    id: slider_bluetoothSimUpdate
                    anchors.left: text_bluetoothSimUpdate1.right
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isDesktop
                    z: 1

                    from: 1
                    to: 6
                    stepSize: 1

                    value: settingsManager.bluetoothSimUpdates
                    onValueChanged: settingsManager.bluetoothSimUpdates = value
                }

                Text {
                    id: text_bluetoothSimUpdate2
                    height: 40
                    anchors.left: image_bluetoothSimUpdate.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: spinBox_bluetoothSimUpdate.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isMobile

                    text: qsTr("Simultaneous updates")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }
                SpinBoxThemed {
                    id: spinBox_bluetoothSimUpdate
                    width: 128
                    height: 34
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isMobile
                    z: 1

                    from: 1
                    to: 6
                    stepSize: 1
                    editable: false

                    value: settingsManager.bluetoothSimUpdates
                    onValueChanged: settingsManager.bluetoothSimUpdates = value
                }
            }
            Text {
                id: legend_bluetoothSimUpdate
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16
                topPadding: -12
                bottomPadding: 12

                visible: element_bluetoothSimUpdate.visible

                text: qsTr("How many sensors should be updated simultaneously. A lower number improves Bluetooth synchronization reliability, at the expense of speed.")
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
                    anchors.left: image_minimized.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_minimized.left
                    anchors.rightMargin: 16
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                }

                Text {
                    id: text_worker
                    height: 40
                    anchors.left: image_worker.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_worker.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Enable background updates")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_worker
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
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
                id: element_notifications
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                // desktop only // for now... // also, need the systray
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") && settingsManager.systray

                ImageSvg {
                    id: image_notifications
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-notifications_none-24px.svg"
                }

                Text {
                    id: text_notifications
                    height: 40
                    anchors.left: image_notifications.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_notifications.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Enable notifications")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_notifications
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
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

                visible: element_notifications.visible

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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-timer-24px.svg"
                }

                Text {
                    id: text_update
                    height: 40
                    anchors.left: image_update.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: spinBox_update.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

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
                    to: 12
                    stepSize: 1
                    editable: false

                    value: (settingsManager.updateIntervalPlant / 60)
                    onValueChanged: settingsManager.updateIntervalPlant = (value * 60)
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-format_size-24px.svg"
                }

                Text {
                    id: text_bigindicators
                    height: 40
                    anchors.left: image_bigindicators.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_bigindicators.left
                    anchors.rightMargin: 16
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-straighten-24px.svg"
                }

                Text {
                    id: text_dynascale
                    height: 40
                    anchors.left: image_dynascale.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_dynascale.left
                    anchors.rightMargin: 16
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-timeline-24px.svg"
                }

                Text {
                    id: text_showdots
                    height: 40
                    anchors.left: image_showdots.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: switch_showdots.left
                    anchors.rightMargin: 16
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

            Rectangle {
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorForeground

                ImageSvg {
                    id: image_thermometer
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-trip_origin-24px.svg"
                }

                Text {
                    id: text_thermometer
                    anchors.left: image_thermometer.right
                    anchors.leftMargin: column.leftPad
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-timer-24px.svg"
                }

                Text {
                    id: text_thermometer_update
                    height: 40
                    anchors.left: image_thermometer_update.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: spinBox_thermometer_update.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

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
                    to: 12
                    stepSize: 1
                    editable: false

                    value: (settingsManager.updateIntervalThermo / 60)
                    onValueChanged: settingsManager.updateIntervalThermo = (value * 60)
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
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                }

                Text {
                    id: text_thermometer_unit
                    height: 40
                    anchors.left: image_thermometer_unit.right
                    anchors.leftMargin: column.leftPad
                    anchors.right: radioDelegateCelsius.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Temperature unit")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                RadioButtonThemed {
                    id: radioDelegateCelsius
                    height: 40
                    anchors.right: radioDelegateFahrenheit.left
                    anchors.verticalCenter: text_thermometer_unit.verticalCenter

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
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

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

            ////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                color: Theme.colorForeground

                visible: deviceManager.hasDevices

                ImageSvg {
                    id: image_export
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    rotation: 270
                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
                }

                Text {
                    id: text_export
                    anchors.left: image_export.right
                    anchors.leftMargin: column.leftPad
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Data archiving")
                    font.pixelSize: 16
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 40 + column.leftPad
                anchors.right: parent.right
                anchors.rightMargin: 16

                topPadding: 8

                visible: deviceManager.hasDevices

                Text {
                    id: legend_export1
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Export up to 30 days of data into a CSV file.")
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignBottom
                }
                Text {
                    id: legend_export2
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: (Qt.platform.os !== "ios")

                    text: qsTr("Saved in your documents, under the 'WatchFlower' directory.")
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignBottom
                }
            }

            Row {
                id: element_export
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                height: 48
                spacing: 16

                visible: deviceManager.hasDevices

                ButtonWireframe {
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    visible: (Qt.platform.os !== "ios")

                    fullColor: false
                    text: qsTr("Export file")
                    onClicked: {
                        utilsApp.checkMobileStoragePermissions()

                        if (deviceManager.exportDataSave()) {
                            text = qsTr("Exported")
                            primaryColor = Theme.colorPrimary
                            fullColor = true
                            if (isDesktop) openFolderButton.visible = true
                        } else {
                            text = qsTr("Export file")
                            primaryColor = Theme.colorWarning
                            fullColor = false
                        }
                    }
                }

                ButtonWireframe {
                    id: openFolderButton
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    visible: false

                    fullColor: false
                    text: qsTr("Open folder")
                    onClicked: {
                        utilsApp.openWith(deviceManager.exportDataFolder())
                    }
                }

                ButtonWireframe {
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isMobile

                    fullColor: false
                    text: qsTr("Open with")
                    onClicked: {
                        var file = deviceManager.exportDataOpen()
                        utilsShare.sendFile(file, "Send file", "text/csv", 0)
                    }
                }
            }
        }
    }
}
