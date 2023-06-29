import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Loader {
    id: settingsScreen

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        settingsScreen.active = true

        // change screen
        appContent.state = "Settings"
    }

    function backAction() {
        if (settingsScreen.status === Loader.Ready)
            settingsScreen.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: false

    sourceComponent: Item {
        anchors.fill: parent

        function backAction() {
            screenDeviceList.loadScreen()
        }

        ////////////////

        PopupBackgroundUpdates {
            id: popupBackgroundUpdates

            onClosed: {
                settingsManager.systray = utilsApp.checkMobileBackgroundLocationPermission()
                switch_worker.checked = settingsManager.systray
            }
        }

        ////////////////

        Flickable {
            anchors.fill: parent
            contentWidth: -1
            contentHeight: contentColumn.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: Theme.componentMargin
                bottomPadding: Theme.componentMargin
                spacing: 8

                property int padIcon: singleColumn ? Theme.componentMarginL : Theme.componentMarginL
                property int padText: appHeader.headerPosition

                ////////////////

                ListTitle {
                    text: qsTr("Application")
                    icon: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                ////////////////

                Item {
                    id: element_appTheme
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-style-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: appTheme_selector.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Theme")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    Row {
                        id: appTheme_selector
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        z: 1
                        spacing: Theme.componentMargin / 2

                        Rectangle {
                            id: rectangleSnow
                            width: wideWideMode ? 80 : 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: "white"
                            border.color: (settingsManager.appTheme === "THEME_SNOW") ? Theme.colorSubText : "#ddd"
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
                            id: rectangleRain
                            width: wideWideMode ? 80 : 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: "#476cae"
                            border.color: "#06307a"
                            border.width: (settingsManager.appTheme === "THEME_RAIN") ? 2 : 0

                            Text {
                                anchors.centerIn: parent
                                visible: wideWideMode
                                text: qsTr("rain")
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: settingsManager.appTheme = "THEME_RAIN"
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
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-brightness_4-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_appThemeAuto.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Automatic dark mode")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        id: switch_appThemeAuto
                        anchors.right: parent.right
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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    topPadding: -12
                    bottomPadding: 0
                    visible: element_appThemeAuto.visible

                    text: settingsManager.appThemeAuto ?
                              qsTr("Dark mode will switch on automatically between 9 PM and 9 AM.") :
                              qsTr("Dark mode schedule is disabled.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item {
                    id: element_splitView
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_splitView.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Split sensor list in categories")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        lineHeight: 0.8
                    }

                    SwitchThemed {
                        id: switch_splitView
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.splitView
                        onClicked: settingsManager.splitView = checked
                    }
                }
                Text {
                    id: legend_splitView
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    topPadding: -12
                    bottomPadding: isDesktop ? 12 : 0
                    visible: element_splitView.visible

                    text: settingsManager.splitView ?
                              qsTr("Devices will be split into categories (plant sensors, thermometers, air quality monitors)") :
                              qsTr("Devices will be shown together.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                ListSeparator { }

                ////////

                Item {
                    id: element_language
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-translate-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: combobox_language.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Language")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    ComboBoxThemed {
                        id: combobox_language
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        height: 36

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
                        onActivated: {
                            utilsLanguage.loadLanguage(cbAppLanguage.get(currentIndex).text)
                            settingsManager.appLanguage = cbAppLanguage.get(currentIndex).text
                        }
                    }
                }

                ListSeparator { visible: isDesktop }

                ////////

                Item {
                    id: element_minimized
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    visible: isDesktop

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-minimize-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_minimized.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Start application minimized")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        lineHeight: 0.8
                    }

                    SwitchThemed {
                        id: switch_minimized
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.startMinimized
                        onClicked: settingsManager.startMinimized = checked
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("Background updates")
                    icon: "qrc:/assets/icons_material/baseline-android-24px.svg"

                    visible: (Qt.platform.os === "android")

                    ButtonExperimental {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        height: 32

                        text: qsTr("experimental")
                        primaryColor: Theme.colorRed
                        borderColor: Theme.colorRed

                        onClicked: popupBackgroundUpdates.open()
                    }
                }

                ////////////////

                Item {
                    id: element_worker
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    // every platforms except iOS
                    visible: (Qt.platform.os !== "ios")

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_worker.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Enable background updates")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        lineHeight: 0.8
                    }

                    SwitchThemed {
                        id: switch_worker
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.systray
                        onClicked: {
                            if (isMobile) {
                                if (checked) {
                                    checked = false
                                    popupBackgroundUpdates.open()
                                } else {
                                    settingsManager.systray = false
                                }
                            } else {
                                settingsManager.systray = checked
                            }
                        }
                    }
                }
                Text {
                    id: legend_worker_mobile
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    topPadding: -12
                    bottomPadding: element_notifications.visible ? 0 : 12

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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    topPadding: -12
                    bottomPadding: element_notifications.visible ? 0 : 12

                    visible: (element_worker.visible && isDesktop)

                    text: settingsManager.systray ?
                              qsTr("WatchFlower will remain active in the notification area after the window is closed, and will automatically refresh sensors data at regular interval.") :
                              qsTr("WatchFlower is only active while the window is open.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item {
                    id: element_notifications
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    // every platforms except iOS // also, need the systray
                    visible: (Qt.platform.os !== "ios")
                    enabled: settingsManager.systray
                    opacity: settingsManager.systray ? 1 : 0.4

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/baseline-notifications_none-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_notifications.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Enable notifications")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        lineHeight: 0.8
                    }

                    SwitchThemed {
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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    topPadding: -12
                    bottomPadding: settingsManager.notifications ? 0 : 12

                    visible: (element_notifications.visible && !settingsManager.notifications)
                    opacity: settingsManager.systray ? 1 : 0.4

                    text: settingsManager.notifications ?
                              qsTr("If a plant needs water, WatchFlower will bring it to your attention!") :
                              qsTr("If a plant needs water, WatchFlower can bring it to your attention.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

                    topPadding: -12
                    visible: settingsManager.systray && settingsManager.notifications

                    Item {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 32

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: contentColumn.padText
                            anchors.right: switch_notif_battery.left
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: "- " + qsTr("battery level")
                            textFormat: Text.PlainText
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                        }
                        SwitchThemed {
                            id: switch_notif_battery
                            anchors.right: parent.right
                            anchors.rightMargin: screenPaddingRight
                            anchors.verticalCenter: parent.verticalCenter
                            z: 1

                            checked: settingsManager.notif_battery
                            onClicked: settingsManager.notif_battery = checked
                        }
                    }
                    Item {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 32

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: contentColumn.padText
                            anchors.right: switch_notif_water.left
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: "- " + qsTr("water level")
                            textFormat: Text.PlainText
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                        }
                        SwitchThemed {
                            id: switch_notif_water
                            anchors.right: parent.right
                            anchors.rightMargin: screenPaddingRight
                            anchors.verticalCenter: parent.verticalCenter
                            z: 1

                            checked: settingsManager.notif_water
                            onClicked: settingsManager.notif_water = checked
                        }
                    }
                    Item {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 32

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: contentColumn.padText
                            anchors.right: switch_notif_subzero.left
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: "- " + qsTr("freeze warnings")
                            textFormat: Text.PlainText
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                            lineHeight: 0.8
                        }
                        SwitchThemed {
                            id: switch_notif_subzero
                            anchors.right: parent.right
                            anchors.rightMargin: screenPaddingRight
                            anchors.verticalCenter: parent.verticalCenter
                            z: 1

                            checked: settingsManager.notif_subzero
                            onClicked: settingsManager.notif_subzero = checked
                        }
                    }
                    Item {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 32

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: contentColumn.padText
                            anchors.right: switch_notif_env.left
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: "- " + qsTr("environmental warnings")
                            textFormat: Text.PlainText
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                            lineHeight: 0.8
                        }
                        SwitchThemed {
                            id: switch_notif_env
                            anchors.right: parent.right
                            anchors.rightMargin: screenPaddingRight
                            anchors.verticalCenter: parent.verticalCenter
                            z: 1

                            checked: settingsManager.notif_env
                            onClicked: settingsManager.notif_env = checked
                        }
                    }
                }

                ////////

                ListTitle {
                    text: qsTr("Bluetooth")
                    icon: "qrc:/assets/icons_material/baseline-bluetooth-24px.svg"
                }

                ////////

                Item {
                    id: element_bluetoothControl
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    // Android only
                    visible: (Qt.platform.os === "android")

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_bluetoothControl.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Bluetooth control")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        lineHeight: 0.8
                    }

                    SwitchThemed {
                        id: switch_bluetoothControl
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.bluetoothControl
                        onClicked: settingsManager.bluetoothControl = checked
                    }
                }
                Text {
                    id: legend_bluetoothControl
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    topPadding: -12
                    bottomPadding: 0
                    visible: element_bluetoothControl.visible

                    text: settingsManager.bluetoothControl ? qsTr("WatchFlower will enable your device's Bluetooth in order to operate.") :
                                                             qsTr("WatchFlower will only operate if your device's Bluetooth is already enabled.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item {
                    id: element_bluetoothRange
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/baseline-radar-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_bluetoothRange.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Limit Bluetooth scanning range")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        lineHeight: 0.8
                    }

                    SwitchThemed {
                        id: switch_bluetoothRange
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.bluetoothLimitScanningRange
                        onClicked: settingsManager.bluetoothLimitScanningRange = checked
                    }
                }
                Text {
                    id: legend_bluetoothRange
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    topPadding: -12
                    bottomPadding: 0
                    visible: element_bluetoothRange.visible

                    text: settingsManager.bluetoothLimitScanningRange ?
                              qsTr("Will only scan for sensors approximately 2 meters around you.") :
                              qsTr("Sensor scanning range is not limited.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item {
                    id: element_bluetoothSimUpdate
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                    }

                    Text {
                        id: text_bluetoothSimUpdate
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: isDesktop ? undefined : spinBox_bluetoothSimUpdate.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Simultaneous updates")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        lineHeight: 0.8
                    }

                    SliderValueSolid {
                        id: slider_bluetoothSimUpdate
                        anchors.left: text_bluetoothSimUpdate.right
                        anchors.leftMargin: Theme.componentMargin
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
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
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        visible: isMobile
                        width: 128
                        height: 36
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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
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

                ////////////////

                ListTitle {
                    text: qsTr("Plant sensors")
                    icon: "qrc:/assets/icons_material/outline-local_florist-24px.svg"
                }

                ////////////////

                Item {
                    id: element_plant_update
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-timer-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: spinBox_plant_update.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Update interval")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        lineHeight: 0.8
                    }

                    SpinBoxThemed {
                        id: spinBox_plant_update
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        width: 128
                        height: 36
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

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    spacing: 0

                    Item {
                        id: element_plant_indicators
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: Theme.componentHeightL

                        IconSvg {
                            anchors.left: parent.left
                            anchors.leftMargin: contentColumn.padIcon
                            anchors.verticalCenter: parent.verticalCenter

                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/assets/icons_material/baseline-straighten-24px.svg"
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: contentColumn.padText
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Data indicators")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorText
                            wrapMode: Text.WordWrap
                            lineHeight: 0.8
                        }
                    }

                    Row {
                        id: element_plant_indicators_selector
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText

                        height: Theme.componentHeightL
                        spacing: Theme.componentMargin

                        SelectorMenu {
                            id: row_plant_bigindicators2
                            height: 32

                            model: ListModel {
                                ListElement { idx: 1; txt: qsTr("thin"); src: ""; sz: 16; }
                                ListElement { idx: 2; txt: qsTr("solid"); src: ""; sz: 16; }
                            }

                            currentSelection: (settingsManager.bigIndicator) ? 2 : 1
                            onMenuSelected: (index) => {
                                currentSelection = index
                                settingsManager.bigIndicator = (index === 2)
                            }
                        }

                        SelectorMenu {
                            id: row_plant_dynascale2
                            height: 32

                            model: ListModel {
                                ListElement { idx: 1; txt: qsTr("static"); src: ""; sz: 16; }
                                ListElement { idx: 2; txt: qsTr("dynamic"); src: ""; sz: 16; }
                            }

                            currentSelection: (settingsManager.dynaScale) ? 2 : 1
                            onMenuSelected: (index) => {
                                currentSelection = index
                                settingsManager.dynaScale = (index === 2)
                            }
                        }
                    }

                    Item {
                        id: element_plant_indicators_preview
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        height: Theme.componentHeight

                        DataBarCompact {
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -8

                            visible: !settingsManager.bigIndicator
                            width: singleColumn ? parent.width : element_plant_indicators_selector.width

                            animated: false
                            legend: qsTr("preview")
                            suffix: "°" + settingsManager.tempUnit
                            colorForeground: Theme.colorLightGrey

                            value: 24
                            valueMin: settingsManager.dynaScale ? 16 : 0
                            valueMax: settingsManager.dynaScale ? 32 : 40
                            limitMin: 20
                            limitMax: 28
                        }

                        DataBarSolid {
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -8

                            visible: settingsManager.bigIndicator
                            width: singleColumn ? parent.width : element_plant_indicators_selector.width

                            animated: false
                            legend: qsTr("preview")
                            suffix: "°" + settingsManager.tempUnit
                            colorForeground: Theme.colorLightGrey

                            value: 24
                            valueMin: settingsManager.dynaScale ? 16 : 0
                            valueMax: settingsManager.dynaScale ? 32 : 40
                            limitMin: 20
                            limitMax: 28
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("Thermometers")
                    icon: "qrc:/assets/icons_custom/thermometer_big-24px.svg"
                }

                ////////////////

                Item {
                    id: element_thermometer_update
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-timer-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: spinBox_thermometer_update.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Update interval")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        lineHeight: 0.8
                    }

                    SpinBoxThemed {
                        id: spinBox_thermometer_update
                        width: 128
                        height: 36
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
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
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    height: Theme.componentHeightL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: row_thermometer_unit.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Temperature unit")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }

                    SelectorMenu {
                        id: row_thermometer_unit
                        height: 32
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        model: ListModel {
                            ListElement { idx: 1; txt: qsTr("°C"); src: ""; sz: 16; }
                            ListElement { idx: 2; txt: qsTr("°F"); src: ""; sz: 16; }
                        }

                        currentSelection: (settingsManager.tempUnit === 'C') ? 1 : 2
                        onMenuSelected: (index) => {
                            currentSelection = index
                            settingsManager.tempUnit = (index === 1) ? 'C' : 'F'
                        }
                    }
                }

                ////////////////
/*
                ListTitle {
                    text: qsTr("External database")
                    icon: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                    visible: isDesktop
                }

                ////////////////

                Item {
                    id: element_mysql
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

                    visible: isDesktop
                    height: UtilsNumber.alignTo(legend_mysql.contentHeight, 16)

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-style-24px.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: appTheme_selector.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Connects to a remote MySQL compatible database, instead of the embedded database. Allows multiple instances of the application to share data. Database setup is at your own charge.")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContentSmall
                    }

                    SwitchThemed {
                        id: switch_mysql
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.mysql
                        onClicked: settingsManager.mysql = checked
                    }
                }

                ////////

                Loader {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: appTheme_selector.left
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin

                    active: settingsManager.mysql
                    asynchronous: true
                    sourceComponent: dbSettingsScalable
                }
*/
                ////////////////

                ListTitle {
                    text: qsTr("Data archiving")
                    icon: "qrc:/assets/icons_material/baseline-archive-24px.svg"
                    visible: deviceManager.hasDevices
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin

                    topPadding: 8
                    visible: deviceManager.hasDevices

                    Text {
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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin

                    height: Theme.componentHeightXL
                    spacing: Theme.componentMargin
                    visible: deviceManager.hasDevices

                    ButtonWireframe {
                        height: 36
                        anchors.verticalCenter: parent.verticalCenter

                        visible: isDesktop
                        fullColor: false
                        primaryColor: Theme.colorPrimary
                        secondaryColor: Theme.colorBackground

                        text: qsTr("Export data")
                        onClicked: {
                            if (deviceManager.exportDataSave()) {
                                text = qsTr("Exported")
                                primaryColor = Theme.colorPrimary
                                fullColor = true
                                if (isDesktop) openFolderButton.visible = true
                            } else {
                                text = qsTr("Export data")
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

                        text: qsTr("Export file")
                        onClicked: {
                            var file = deviceManager.exportDataOpen()
                            utilsShare.sendFile(file, qsTr("Export file"), "text/csv", 0)
                        }
                    }
                }
            }
        }

        ////////////////

        Component {
            id: dbSettingsScalable

            Grid {
                id: grid
                anchors.left: parent.left
                anchors.right: parent.right

                rows: 4
                columns: singleColumn ? 1 : 2
                spacing: 12

                property int sz: singleColumn ? grid.width : Math.min((grid.width / 2), 512) - 4

                TextFieldThemed {
                    id: tf_database_host
                    width: grid.sz
                    height: 36

                    placeholderText: qsTr("Host")
                    text: settingsManager.mysqlHost
                    onEditingFinished: settingsManager.mysqlHost = text
                    selectByMouse: true

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                    }
                }

                TextFieldThemed {
                    id: tf_database_port
                    width: grid.sz
                    height: 36

                    placeholderText: qsTr("Port")
                    text: settingsManager.mysqlPort
                    onEditingFinished: settingsManager.mysqlPort = parseInt(text, 10)
                    validator: IntValidator { bottom: 1; top: 65535; }
                    selectByMouse: true

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons_material/baseline-pin-24px.svg"
                    }
                }

                TextFieldThemed {
                    id: tf_database_user
                    width: grid.sz
                    height: 36

                    placeholderText: qsTr("User")
                    text: settingsManager.mysqlUser
                    onEditingFinished: settingsManager.mysqlUser = text
                    selectByMouse: true

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons_material/duotone-manage_accounts-24px.svg"
                    }
                }

                TextFieldThemed {
                    id: tf_database_pwd
                    width: grid.sz
                    height: 36

                    placeholderText: qsTr("Password")
                    text: settingsManager.mysqlPassword
                    onEditingFinished: settingsManager.mysqlPassword = text
                    selectByMouse: true
                    echoMode: TextInput.PasswordEchoOnEdit

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons_material/baseline-password-24px.svg"
                    }
                }
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
