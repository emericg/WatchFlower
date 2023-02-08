import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Loader {
    id: settingsScreen

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

                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("Application")
                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
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
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

                    IconSvg {
                        id: image_splitView
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                    }

                    Text {
                        id: text_splitView
                        height: 40
                        anchors.left: image_splitView.right
                        anchors.leftMargin: 24
                        anchors.right: switch_splitView.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Split sensor list in categories")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    SwitchThemedDesktop {
                        id: switch_splitView
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.splitView
                        onClicked: settingsManager.splitView = checked
                    }
                }
                Text {
                    id: legend_splitView
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 64
                    anchors.right: parent.right
                    anchors.rightMargin: 12

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

                Rectangle { // separator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    visible: isDesktop
                    color: Theme.colorSeparator
                }

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

                Rectangle { // separator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    visible: isDesktop
                    color: Theme.colorSeparator
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

                        checked: settingsManager.startMinimized
                        onClicked: settingsManager.startMinimized = checked
                    }
                }

                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("Background updates")
                    source: "qrc:/assets/icons_material/baseline-android-24px.svg"
                    visible: (Qt.platform.os === "android")

                    ButtonExperimental {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
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
                    anchors.leftMargin: screenPaddingLeft + 64
                    anchors.right: parent.right
                    anchors.rightMargin: 12
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
                    anchors.leftMargin: screenPaddingLeft + 64
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    topPadding: -12
                    bottomPadding: element_notifications.visible ? 0 : 12

                    visible: (element_worker.visible && isDesktop)

                    text: settingsManager.systray ?
                              qsTr("WatchFlower will remain active in the notification area after the window is closed, and will automatically refresh sensor data at regular interval.") :
                              qsTr("WatchFlower is only active while the window is open.")
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
                    visible: (Qt.platform.os !== "ios")
                    enabled: settingsManager.systray
                    opacity: settingsManager.systray ? 1 : 0.4

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

                Item {
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

                    visible: settingsManager.systray && settingsManager.notifications

                    Text {
                        height: 32
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.right: switch_notif_battery.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: "- " + qsTr("battery level")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        verticalAlignment: Text.AlignVCenter
                    }
                    SwitchThemedDesktop {
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
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

                    visible: settingsManager.systray && settingsManager.notifications

                    Text {
                        height: 32
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.right: switch_notif_water.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: "- " + qsTr("water level")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        verticalAlignment: Text.AlignVCenter
                    }
                    SwitchThemedDesktop {
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
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

                    visible: settingsManager.systray && settingsManager.notifications

                    Text {
                        height: 32
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.right: switch_notif_subzero.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: "- " + qsTr("freeze warnings")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        verticalAlignment: Text.AlignVCenter
                    }
                    SwitchThemedDesktop {
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
                    height: settingsManager.notifications ? 44 : 32
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

                    visible: settingsManager.systray && settingsManager.notifications

                    Text {
                        height: 32
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.right: switch_notif_env.left
                        anchors.rightMargin: 16

                        text: "- " + qsTr("environmental warnings")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        verticalAlignment: Text.AlignVCenter
                    }
                    SwitchThemedDesktop {
                        id: switch_notif_env
                        height: 32
                        anchors.right: parent.right
                        anchors.rightMargin: screenPaddingRight
                        z: 1

                        checked: settingsManager.notif_env
                        onClicked: settingsManager.notif_env = checked
                    }
                }

                ////////

                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("Bluetooth")
                    source: "qrc:/assets/icons_material/baseline-bluetooth-24px.svg"
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

                    text: settingsManager.bluetoothControl ?
                              qsTr("WatchFlower will only operate if your device's Bluetooth is already enabled.") :
                              qsTr("WatchFlower will enable your device's Bluetooth in order to operate.")
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

                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("Plant sensors")
                    source: "qrc:/assets/icons_material/outline-local_florist-24px.svg"
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
                        anchors.right: row_dynascale.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Data indicators scale")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    Row {
                        id: row_dynascale
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: text_dynascale.verticalCenter
                        spacing: 12

                        RadioButtonThemed {
                            text: qsTr("static")

                            checked: !settingsManager.dynaScale
                            onClicked: settingsManager.dynaScale = false
                        }

                        RadioButtonThemed {
                            text: qsTr("dynamic")

                            checked: settingsManager.dynaScale
                            onClicked: settingsManager.dynaScale = true
                        }
                    }
                }

                ////////

                Row { // indicators preview
                    height: 56
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + (isDesktop ? 72 : 24)
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + 12

                    spacing: isDesktop ? 32 : 16

                    DataBarCompact {
                        width: ((parent.width - parent.spacing) / 2)
                        height: 32
                        anchors.top: parent.top
                        anchors.topMargin: 8

                        animated: false
                        legend: isDesktop ? qsTr("thin") : ""
                        legendWidth: 48
                        suffix: "°" + settingsManager.tempUnit
                        colorForeground: Theme.colorYellow

                        value: 24
                        valueMin: settingsManager.dynaScale ? 16 : 0
                        valueMax: settingsManager.dynaScale ? 32 : 40
                        limitMin: 20
                        limitMax: 28

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -8
                            z: -1

                            radius: 6
                            color: Theme.colorComponentBackground
                            border.width: (!settingsManager.bigIndicator) ? 2 : 0
                            border.color: Theme.colorSeparator

                            opacity: (!settingsManager.bigIndicator) ? 0.66 : 0.2
                            Behavior on opacity { OpacityAnimator { duration: 133 } }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: settingsManager.bigIndicator = false
                            }
                        }
                    }

                    DataBarSolid {
                        width: ((parent.width - parent.spacing) / 2)
                        height: 32
                        anchors.top: parent.top
                        anchors.topMargin: 8

                        animated: false
                        legend: isDesktop ? qsTr("solid") : ""
                        legendWidth: 64
                        suffix: "°" + settingsManager.tempUnit
                        colorForeground: Theme.colorYellow

                        value: 24
                        valueMin: settingsManager.dynaScale ? 16 : 0
                        valueMax: settingsManager.dynaScale ? 32 : 40
                        limitMin: 20
                        limitMax: 28

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -8
                            z: -1

                            radius: 6
                            color: Theme.colorComponentBackground
                            border.width: (settingsManager.bigIndicator) ? 2 : 0
                            border.color: Theme.colorSeparator

                            opacity: (settingsManager.bigIndicator) ? 0.66 : 0.2
                            Behavior on opacity { OpacityAnimator { duration: 133 } }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: settingsManager.bigIndicator = true
                            }
                        }
                    }
                }

                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("Thermometers")
                    source: "qrc:/assets/icons_custom/thermometer_big-24px.svg"
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

                        SelectorMenu {
                            height: 32
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
                }

                ////////////////
/*
                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("External database")
                    source: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                    visible: isDesktop
                }

                ////////////////

                Item {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16 + 48
                    anchors.right: parent.right
                    height: UtilsNumber.alignTo(legend_mysql.contentHeight, 16)

                    visible: isDesktop

                    Text {
                        id: legend_mysql
                        anchors.left: parent.left
                        anchors.right: switch_mysql.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Connects to a remote MySQL compatible database, instead of the embedded database. Allows multiple instances of the application to share data. Database setup is at your own charge.")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContentSmall
                        verticalAlignment: Text.AlignBottom
                    }

                    SwitchThemedDesktop {
                        id: switch_mysql
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.mysql
                        onClicked: settingsManager.mysql = checked
                    }
                }

                ////////

                Loader {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 16 + 48
                    anchors.right: parent.right
                    anchors.rightMargin: 16

                    active: settingsManager.mysql
                    asynchronous: true
                    sourceComponent: dbSettingsScalable
                }
*/
                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("Data archiving")
                    source: "qrc:/assets/icons_material/baseline-archive-24px.svg"
                    visible: deviceManager.hasDevices
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

                        text: qsTr("Export file")
                        onClicked: {
                            var file = deviceManager.exportDataOpen()
                            utilsShare.sendFile(file, "Export file", "text/csv", 0)
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
                        anchors.rightMargin: 12
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
                        anchors.rightMargin: 12
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
                        anchors.rightMargin: 12
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
                        anchors.rightMargin: 12
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
