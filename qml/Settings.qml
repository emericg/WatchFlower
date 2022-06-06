import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: settingsScreen
    width: 480
    height: 720
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: column.height

        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar { visible: false }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right

            topPadding: 12
            bottomPadding: 12
            spacing: 8

            ////////////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                color: Theme.colorForeground

                IconSvg {
                    id: image_appsettings
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                Text {
                    id: text_appsettings
                    anchors.left: image_appsettings.right
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Application")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////////////

            Item {
                id: element_appTheme
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_appTheme
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/duotone-style-24px.svg"
                }

                Text {
                    id: text_appTheme
                    height: 40
                    anchors.left: image_appTheme.right
                    anchors.leftMargin: 24
                    anchors.right: appTheme_selector.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Theme")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                Row {
                    id: appTheme_selector
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    z: 1
                    spacing: 10

                    Rectangle {
                        id: rectangleSnow
                        width: wideWideMode ? 80 : 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        radius: 2
                        color: "white"
                        border.color: (settingsManager.appTheme === "THEME_SNOW") ? Theme.colorSubText : "#ccc"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            visible: wideWideMode
                            text: qsTr("snow")
                            textFormat: Text.PlainText
                            color: (settingsManager.appTheme === "THEME_SNOW") ? Theme.colorSubText : "#ccc"
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: settingsManager.appTheme = "THEME_SNOW"
                        }
                    }
                    Rectangle {
                        id: rectangleGreen
                        width: wideWideMode ? 80 : 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        radius: 2
                        color: "#09debc" // green theme colorSecondary
                        border.color: Theme.colorPrimary
                        border.width: (settingsManager.appTheme === "THEME_PLANT") ? 2 : 0

                        Text {
                            anchors.centerIn: parent
                            visible: wideWideMode
                            text: qsTr("plant")
                            textFormat: Text.PlainText
                            color: "white"
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: settingsManager.appTheme = "THEME_PLANT"
                        }
                    }
                    Rectangle {
                        id: rectangleDay
                        width: wideWideMode ? 80 : 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        radius: 2
                        color: "#FFE400" // day theme colorSecondary
                        border.color: Theme.colorPrimary
                        border.width: (settingsManager.appTheme === "THEME_DAY") ? 2 : 0

                        Text {
                            anchors.centerIn: parent
                            visible: wideWideMode
                            text: qsTr("day")
                            textFormat: Text.PlainText
                            color: "white"
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: settingsManager.appTheme = "THEME_DAY"
                        }
                    }
                    Rectangle {
                        id: rectangleNight
                        width: wideWideMode ? 80 : 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        radius: 2
                        color: "#555151"
                        border.color: Theme.colorPrimary
                        border.width: (settingsManager.appTheme === "THEME_NIGHT") ? 2 : 0

                        Text {
                            anchors.centerIn: parent
                            visible: wideWideMode
                            text: qsTr("night")
                            textFormat: Text.PlainText
                            color: (settingsManager.appTheme === "THEME_NIGHT") ? Theme.colorPrimary : "#ececec"
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentSmall
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: settingsManager.appTheme = "THEME_NIGHT"
                        }
                    }
                }
            }

            ////////

            Item {
                id: element_appThemeAuto
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_appThemeAuto
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/duotone-brightness_4-24px.svg"
                }

                Text {
                    id: text_appThemeAuto
                    height: 40
                    anchors.left: image_appThemeAuto.right
                    anchors.leftMargin: 24
                    anchors.right: switch_appThemeAuto.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Automatic dark mode")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_appThemeAuto
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.appThemeAuto
                    onClicked: {
                        settingsManager.appThemeAuto = checked
                        Theme.loadTheme(settingsManager.appTheme)
                    }
                }
            }
            Text {
                id: legend_appThemeAuto
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 64
                anchors.right: parent.right
                anchors.rightMargin: 12

                topPadding: -12
                bottomPadding: isMobile ? 12 : 0
                visible: element_appThemeAuto.visible

                text: qsTr("Dark mode will switch on automatically between 9 PM and 9 AM.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Rectangle {
                height: 1
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorSeparator
            }

            ////////

            Item {
                id: element_language
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_language
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/duotone-translate-24px.svg"
                }

                Text {
                    id: text_language
                    height: 40
                    anchors.left: image_language.right
                    anchors.leftMargin: 24
                    anchors.right: combobox_language.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Language")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBoxThemed {
                    id: combobox_language
                    width: wideMode ? 256 : 160
                    height: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    z: 1
                    wheelEnabled: false

                    model: ListModel {
                        id: cbAppLanguage
                        ListElement {
                            text: qsTr("auto", "short for automatic");
                        }
                        ListElement { text: "Chinese (traditional)"; }
                        ListElement { text: "Chinese (simplified)"; }
                        ListElement { text: "Dansk"; }
                        ListElement { text: "Deutsch"; }
                        ListElement { text: "English"; }
                        ListElement { text: "Español"; }
                        ListElement { text: "Français"; }
                        ListElement { text: "Frysk"; }
                        ListElement { text: "Nederlands"; }
                        ListElement { text: "Norsk (Bokmål)"; }
                        ListElement { text: "Norsk (Nynorsk)"; }
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
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorSeparator
            }

            ////////

            Item {
                id: element_bluetoothControl
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                // Android only
                visible: (Qt.platform.os === "android")

                IconSvg {
                    id: image_bluetoothControl
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                }

                Text {
                    id: text_bluetoothControl
                    height: 40
                    anchors.left: image_bluetoothControl.right
                    anchors.leftMargin: 24
                    anchors.right: switch_bluetoothControl.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Bluetooth control")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_bluetoothControl
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.bluetoothControl
                    onClicked: settingsManager.bluetoothControl = checked
                }
            }
            Text {
                id: legend_bluetoothControl
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 64
                anchors.right: parent.right
                anchors.rightMargin: 12

                topPadding: -12
                bottomPadding: 0
                visible: element_bluetoothControl.visible

                text: qsTr("WatchFlower can activate your device's Bluetooth in order to operate.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item {
                id: element_bluetoothRange
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_bluetoothRange
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-radar-24px.svg"
                }

                Text {
                    id: text_bluetoothRange
                    height: 40
                    anchors.left: image_bluetoothRange.right
                    anchors.leftMargin: 24
                    anchors.right: switch_bluetoothRange.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Limit Bluetooth scanning range")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_bluetoothRange
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.bluetoothLimitScanningRange
                    onClicked: settingsManager.bluetoothLimitScanningRange = checked
                }
            }
            Text {
                id: legend_bluetoothRange
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 64
                anchors.right: parent.right
                anchors.rightMargin: 12

                topPadding: -12
                bottomPadding: 0
                visible: element_bluetoothRange.visible

                text: qsTr("Will only scan for sensors ~2m around you.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item {
                id: element_bluetoothSimUpdate
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_bluetoothSimUpdate
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                }

                Text {
                    id: text_bluetoothSimUpdate
                    height: 40
                    anchors.left: image_bluetoothSimUpdate.right
                    anchors.leftMargin: 24
                    anchors.right: isDesktop ? undefined : spinBox_bluetoothSimUpdate.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Simultaneous updates")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                    verticalAlignment: Text.AlignVCenter
                }

                SliderValueSolid {
                    id: slider_bluetoothSimUpdate
                    anchors.left: text_bluetoothSimUpdate.right
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isDesktop
                    z: 1

                    from: 1
                    to: 6
                    stepSize: 1
                    wheelEnabled: false

                    value: settingsManager.bluetoothSimUpdates
                    onMoved: settingsManager.bluetoothSimUpdates = value
                }
                SpinBoxThemed {
                    id: spinBox_bluetoothSimUpdate
                    width: 128
                    height: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isMobile
                    z: 1

                    from: 1
                    to: 6
                    stepSize: 1
                    editable: false

                    value: settingsManager.bluetoothSimUpdates
                    onValueModified: settingsManager.bluetoothSimUpdates = value
                }
            }
            Text {
                id: legend_bluetoothSimUpdate
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 64
                anchors.right: parent.right
                anchors.rightMargin: 12
                topPadding: -12
                bottomPadding: 12

                visible: element_bluetoothSimUpdate.visible

                text: qsTr("How many sensors should be updated at once.") + "<br>" +
                      qsTr("A lower number improves Bluetooth synchronization reliability, at the expense of speed.")
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Rectangle {
                height: 1
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorSeparator
                visible: isDesktop
            }

            ////////

            Item {
                id: element_minimized
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                visible: isDesktop

                IconSvg {
                    id: image_minimized
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/duotone-minimize-24px.svg"
                }

                Text {
                    id: text_minimized
                    height: 40
                    anchors.left: image_minimized.right
                    anchors.leftMargin: 24
                    anchors.right: switch_minimized.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Start application minimized")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_minimized
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.minimized
                    onClicked: settingsManager.minimized = checked
                }
            }

            ////////////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                color: Theme.colorForeground
                visible: (Qt.platform.os === "android")

                IconSvg {
                    id: image_androidservice
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-android-24px.svg"
                }

                Text {
                    id: text_androidservice
                    anchors.left: image_androidservice.right
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Background updates")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                ButtonExperimental {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    height: 32

                    visible: (Qt.platform.os === "android")

                    text: qsTr("experimental")
                    primaryColor: Theme.colorRed
                    borderColor: Theme.colorRed

                    onClicked: popupBackgroundData.open()
                }
            }

            ////////

            Item {
                id: element_worker
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                // every platforms except iOS
                visible: (Qt.platform.os !== "ios")

                IconSvg {
                    id: image_worker
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                }

                Text {
                    id: text_worker
                    height: 40
                    anchors.left: image_worker.right
                    anchors.leftMargin: 24
                    anchors.right: switch_worker.left
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Enable background updates")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_worker
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.systray
                    onClicked: {
                        settingsManager.systray = checked

                        if (isMobile) {
                            if (settingsManager.systray) {
                                popupBackgroundData.open()
                                utilsApp.getMobileBackgroundLocationPermission()
                            }
                        }
                    }
                }
            }
            Text {
                id: legend_worker_mobile
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 64
                anchors.right: parent.right
                anchors.rightMargin: 12
                topPadding: -12
                bottomPadding: 0

                visible: (element_worker.visible && Qt.platform.os === "android")

                text: qsTr("Wake up at a predefined interval to refresh sensor data. Only if Bluetooth (or Bluetooth control) is enabled.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }
            Text {
                id: legend_worker_desktop
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 64
                anchors.right: parent.right
                anchors.rightMargin: 12
                topPadding: -12
                bottomPadding: 12

                visible: (element_worker.visible && isDesktop)

                text: qsTr("WatchFlower will remain active in the system tray, and will wake up at a regular interval to refresh sensor data.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item {
                id: element_notifications
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                // every platforms except iOS // also, need the systray
                visible: (Qt.platform.os !== "ios") && settingsManager.systray

                IconSvg {
                    id: image_notifications
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-notifications_none-24px.svg"
                }

                Text {
                    id: text_notifications
                    height: 40
                    anchors.left: image_notifications.right
                    anchors.leftMargin: 24
                    anchors.right: switch_notifications.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Enable notifications")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_notifications
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.notifications
                    onClicked: settingsManager.notifications = checked
                }
            }
            Text {
                id: legend_notifications
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 64
                anchors.right: parent.right
                anchors.rightMargin: 12
                topPadding: -12
                bottomPadding: 12

                visible: (element_notifications.visible)

                text: qsTr("If a plant needs water, WatchFlower will bring it to your attention!")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorForeground

                IconSvg {
                    id: image_plantsensor
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/outline-local_florist-24px.svg"
                }

                Text {
                    id: text_plantsensor
                    anchors.left: image_plantsensor.right
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Plant sensors")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////////////

            Item {
                id: element_update
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_update
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/duotone-timer-24px.svg"
                }

                Text {
                    id: text_update
                    height: 40
                    anchors.left: image_update.right
                    anchors.leftMargin: 24
                    anchors.right: spinBox_update.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Update interval")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SpinBoxThemed {
                    id: spinBox_update
                    width: 128
                    height: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    legend: " " + qsTr("h.", "short for hours")
                    from: 1
                    to: 24
                    stepSize: 1
                    editable: false
                    wheelEnabled: isDesktop

                    value: (settingsManager.updateIntervalPlant / 60)
                    onValueModified: settingsManager.updateIntervalPlant = (value * 60)
                }
            }

            ////////

            Item {
                id: element_bigindicators
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_bigindicators
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_custom/indicators-24px.svg"
                }

                Text {
                    id: text_bigindicators
                    height: 40
                    anchors.left: image_bigindicators.right
                    anchors.leftMargin: 24
                    anchors.right: row_bigindicators.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Data indicators style")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                Row {
                    id: row_bigindicators
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: text_bigindicators.verticalCenter
                    spacing: 12

                    RadioButtonThemed {
                        text: qsTr("thin")

                        checked: !settingsManager.bigIndicator
                        onClicked: settingsManager.bigIndicator = false
                    }

                    RadioButtonThemed {
                        text: qsTr("solid")

                        checked: settingsManager.bigIndicator
                        onClicked: settingsManager.bigIndicator = true
                    }
                }
            }

            ////////

            Item {
                id: element_dynascale
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_dynascale
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-straighten-24px.svg"
                }

                Text {
                    id: text_dynascale
                    height: 40
                    anchors.left: image_dynascale.right
                    anchors.leftMargin: 24
                    anchors.right: switch_dynascale.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Dynamic scale for indicators")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_dynascale
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.dynaScale
                    onClicked: settingsManager.dynaScale = checked
                }
            }

            ////////////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorForeground

                IconSvg {
                    id: image_thermometer
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_custom/thermometer_big-24px.svg"
                }

                Text {
                    id: text_thermometer
                    anchors.left: image_thermometer.right
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Thermometers")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////////////

            Item {
                id: element_thermometer_update
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_thermometer_update
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/duotone-timer-24px.svg"
                }

                Text {
                    id: text_thermometer_update
                    height: 40
                    anchors.left: image_thermometer_update.right
                    anchors.leftMargin: 24
                    anchors.right: spinBox_thermometer_update.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Update interval")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SpinBoxThemed {
                    id: spinBox_thermometer_update
                    width: 128
                    height: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    legend: " " + qsTr("h.", "short for hours")
                    from: 1
                    to: 24
                    stepSize: 1
                    editable: false
                    wheelEnabled: isDesktop

                    value: (settingsManager.updateIntervalThermo / 60)
                    onValueModified: settingsManager.updateIntervalThermo = (value * 60)
                }
            }

            ////////

            Item {
                id: element_thermometer_unit
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                IconSvg {
                    id: image_thermometer_unit
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                }

                Text {
                    id: text_thermometer_unit
                    height: 40
                    anchors.left: image_thermometer_unit.right
                    anchors.leftMargin: 24
                    anchors.right: row_thermometer_unit.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Temperature unit")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                Row {
                    id: row_thermometer_unit
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: text_thermometer_unit.verticalCenter
                    spacing: 12

                    RadioButtonThemed {
                        id: radioDelegateCelsius
                        text: qsTr("°C")

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
                        text: qsTr("°F")

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

            ////////////////
/*
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 48

                visible: isDesktop
                color: Theme.colorForeground

                IconSvg {
                    id: image_database
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                }

                Text {
                    id: text_database
                    anchors.left: image_database.right
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("External database")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedDesktop {
                    id: switch_database_enabled
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    checked: settingsManager.externalDb
                    onClicked: settingsManager.externalDb = checked
                }
            }

            ////////////////

            Item {
                anchors.left: parent.left
                anchors.leftMargin: 40 + 24
                anchors.right: parent.right
                anchors.rightMargin: 12
                height: UtilsNumber.alignTo(legend_database.contentHeight, 16)

                visible: isDesktop

                Text {
                    id: legend_database
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Connects to a remote MySQL compatible database, instead of the embedded database. Allows multiple instances of the application to share data. Database setup is at your own charge.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                    verticalAlignment: Text.AlignBottom
                }
            }

            ////////

            Loader {
                anchors.left: parent.left
                anchors.right: parent.right

                active: false
                asynchronous: true
                sourceComponent: dbSettingsScalable
            }
*/
            ////////////////

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                visible: deviceManager.hasDevices
                color: Theme.colorForeground

                IconSvg {
                    id: image_export
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: "qrc:/assets/icons_material/baseline-archive-24px.svg"
                }

                Text {
                    id: text_export
                    anchors.left: image_export.right
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Data archiving")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    font.bold: false
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ////////////////

            Column {
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 16 + 48
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight + 16

                topPadding: 8

                visible: deviceManager.hasDevices

                Text {
                    id: legend_export1
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Export up to 90 days of data into a CSV file.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                    verticalAlignment: Text.AlignBottom
                }
                Text {
                    id: legend_export2
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: isDesktop

                    text: qsTr("Saved in your documents, under the 'WatchFlower' directory.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                    verticalAlignment: Text.AlignBottom
                }
            }

            ////////

            Row {
                id: element_export
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + 16 + 48
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight + 16
                height: 48
                spacing: 16

                visible: deviceManager.hasDevices

                ButtonWireframe {
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    visible: isDesktop
                    fullColor: false
                    primaryColor: Theme.colorPrimary
                    secondaryColor: Theme.colorBackground

                    text: qsTr("Export file")
                    onClicked: {
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
                    primaryColor: Theme.colorPrimary
                    secondaryColor: Theme.colorBackground

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
                    primaryColor: Theme.colorPrimary
                    secondaryColor: Theme.colorBackground

                    text: qsTr("Send file")
                    onClicked: {
                        var file = deviceManager.exportDataOpen()
                        utilsShare.sendFile(file, "Send file", "text/csv", 0)
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: dbSettingsScalable

        Grid {
            id: grid
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16

            rows: 4
            columns: singleColumn ? 1 : 2
            spacing: 12

            property int sz: singleColumn ? grid.width : Math.min((grid.width / 2), 512) - 4

            TextFieldThemed {
                id: tf_database_host
                anchors.verticalCenter: parent.verticalCenter
                width: grid.sz
                height: 36

                placeholderText: qsTr("Host")
                text: settingsManager.externalDbHost
                onEditingFinished: settingsManager.externalDbHost = text
                selectByMouse: true

                IconSvg {
                    width: 20; height: 20;
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorSubText
                    source: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                }
            }

            TextFieldThemed {
                id: tf_database_port
                anchors.verticalCenter: parent.verticalCenter
                width: grid.sz
                height: 36

                placeholderText: qsTr("Port")
                text: settingsManager.externalDbPort
                onEditingFinished: settingsManager.externalDbPort = parseInt(text, 10)
                validator: IntValidator { bottom: 1; top: 65535; }
                selectByMouse: true

                IconSvg {
                    width: 20; height: 20;
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorSubText
                    source: "qrc:/assets/icons_material/baseline-pin-24px.svg"
                }
            }

            TextFieldThemed {
                id: tf_database_user
                anchors.verticalCenter: parent.verticalCenter
                width: grid.sz
                height: 36

                placeholderText: qsTr("User")
                text: settingsManager.externalDbUser
                onEditingFinished: settingsManager.externalDbUser = text
                selectByMouse: true

                IconSvg {
                    width: 20; height: 20;
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorSubText
                    source: "qrc:/assets/icons_material/duotone-manage_accounts-24px.svg"
                }
            }

            TextFieldThemed {
                id: tf_database_pwd
                anchors.verticalCenter: parent.verticalCenter
                width: grid.sz
                height: 36

                placeholderText: qsTr("Password")
                text: settingsManager.externalDbPassword
                onEditingFinished: settingsManager.externalDbPassword = text
                selectByMouse: true
                echoMode: TextInput.PasswordEchoOnEdit

                IconSvg {
                    width: 20; height: 20;
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorSubText
                    source: "qrc:/assets/icons_material/baseline-password-24px.svg"
                }
            }
        }
    }

    ////////
}
