import QtQuick
import QtQuick.Controls
import QtPositioning

import ComponentLibrary
import SmartCare

Loader {
    id: screenSettings
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        screenSettings.active = true

        // change screen
        appContent.state = "ScreenSettings"
    }

    function backAction() {
        if (screenSettings.status === Loader.Ready)
            screenSettings.item.backAction()
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

                topPadding: 16
                bottomPadding: 16
                spacing: 8

                property int paddingLeft: (singleColumn ? 0 : 16)
                property int paddingRight: (singleColumn ? 0 : 16)

                property int padIcon: singleColumn ? Theme.componentMarginL : Theme.componentMarginL
                property int padText: appHeader.headerPosition

                ////////////////

                ListTitle {
                    text: qsTr("User interface")
                    source: "qrc:/IconLibrary/material-symbols/settings.svg"
                }

                ////////////////


                ////////

                // Item { // element_appThemeAuto
                //     anchors.left: parent.left
                //     anchors.leftMargin: contentColumn.paddingLeft
                //     anchors.right: parent.right
                //     anchors.rightMargin: contentColumn.paddingRight
                //     height: Theme.componentHeightXL

                //     IconSvg {
                //         anchors.left: parent.left
                //         anchors.leftMargin: contentColumn.padIcon
                //         anchors.verticalCenter: parent.verticalCenter

                //         width: 24
                //         height: 24
                //         color: Theme.colorIcon
                //         source: "qrc:/IconLibrary/material-icons/duotone/brightness_4.svg"
                //     }

                //     Text {
                //         anchors.left: parent.left
                //         anchors.leftMargin: contentColumn.padText
                //         anchors.right: switch_appThemeAuto.left
                //         anchors.rightMargin: Theme.componentMargin
                //         anchors.verticalCenter: parent.verticalCenter

                //         text: qsTr("Automatic dark mode")
                //         textFormat: Text.PlainText
                //         font.pixelSize: Theme.fontSizeContent
                //         color: Theme.colorText
                //         wrapMode: Text.WordWrap
                //     }

                //     SwitchThemed {
                //         id: switch_appThemeAuto
                //         anchors.right: parent.right
                //         anchors.rightMargin: Theme.componentMargin
                //         anchors.verticalCenter: parent.verticalCenter
                //         z: 1

                //         checked: settingsManager.appThemeAuto
                //         onClicked: {
                //             settingsManager.appThemeAuto = checked
                //             Theme.loadTheme(settingsManager.appTheme)
                //         }
                //     }
                // }

                // Text { // legend_appThemeAuto
                //     anchors.left: parent.left
                //     anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                //     anchors.right: parent.right
                //     anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                //     topPadding: -12
                //     bottomPadding: isDesktop ? 6 : 6

                //     property bool osSupport: (Qt.platform.os !== "linux")
                //     property string osName: {
                //         if (Qt.platform.os === "android") return "Android"
                //         if (Qt.platform.os === "ios") return "iOS"
                //         if (Qt.platform.os === "osx") return "macOS"
                //         if (Qt.platform.os === "linux") return "Linux"
                //         if (Qt.platform.os === "windows") return "Windows"
                //         //: fallback string
                //         return qsTr("Operating System")
                //     }

                //     text: {
                //         if (settingsManager.appThemeAuto) {
                //             if (osSupport) return qsTr("Dark mode will follow %1 settings.").arg(osName)
                //             return qsTr("Dark mode will switch on automatically between 9 PM and 9 AM.")
                //         }
                //         return qsTr("Dark mode schedule is disabled.")
                //     }

                //     textFormat: Text.PlainText
                //     wrapMode: Text.WordWrap
                //     color: Theme.colorSubText
                //     font.pixelSize: Theme.fontSizeContentSmall
                // }

                ////////

                Item { // element_splitView
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-symbols/menu.svg"
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
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.splitView
                        onClicked: settingsManager.splitView = checked
                    }
                }
                Text { // legend_splitView
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: -12
                    bottomPadding: isDesktop ? 12 : 6

                    text: settingsManager.splitView ?
                              qsTr("Devices will be split into categories (plant sensors, thermometers, air quality monitors)") :
                              qsTr("Devices will be shown together.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                ListSeparator { visible: isDesktop }

                ////////

                Item {
                    id: element_language
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/translate.svg"
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
                            ListElement { text: "Hungarian"; }
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

                ////////

                ListSeparator { visible: isDesktop }

                ////////

                Item { // element_minimized
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    visible: isDesktop

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/minimize.svg"
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
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.startMinimized
                        onClicked: settingsManager.startMinimized = checked
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("Background updates")
                    source: "qrc:/IconLibrary/material-symbols/android.svg"

                    visible: (Qt.platform.os === "android")

                    ButtonWireframe {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        height: 32

                        text: qsTr("about")
                        colorBackground: Theme.colorBackground
                        colorText: Theme.colorOrange
                        colorBorder: Theme.colorOrange

                        onClicked: popupBackgroundUpdates.open()
                    }
                }

                ////////////////

                Item {
                    id: element_worker
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-symbols/autorenew.svg"
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
                        anchors.rightMargin: Theme.componentMargin
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
                Text { // legend_worker_mobile
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: -12
                    bottomPadding: element_notifications.visible ? 0 : 12
                    visible: (element_worker.visible && Qt.platform.os === "android")

                    text: qsTr("Wake up at a predefined interval to refresh sensor data. Only if Bluetooth is enabled.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }
                Text { // legend_worker_desktop
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: -12
                    bottomPadding: element_notifications.visible ? 0 : 12
                    visible: (element_worker.visible && isDesktop)

                    text: settingsManager.systray ?
                              qsTr("SmartCare will remain active in the notification area after the window is closed, and will automatically refresh sensors data at regular interval.") :
                              qsTr("SmartCare is only active while the window is open.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item {
                    id: element_notifications
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
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
                        source: "qrc:/IconLibrary/material-symbols/notifications.svg"
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
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.notifications
                        onClicked: {
                            settingsManager.notifications = checked
                            if (settingsManager.notifications) {
                                utilsApp.getMobileNotificationPermission()
                            }
                        }
                    }
                }
                Text { // legend_notifications
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: -12
                    bottomPadding: settingsManager.notifications ? 0 : 12
                    visible: (element_notifications.visible && !settingsManager.notifications)
                    opacity: settingsManager.systray ? 1 : 0.4

                    text: settingsManager.notifications ?
                              qsTr("If a plant needs water, SmartCare will bring it to your attention!") :
                              qsTr("If a plant needs water, SmartCare can bring it to your attention.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

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
                            anchors.rightMargin: Theme.componentMargin
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
                            anchors.rightMargin: Theme.componentMargin
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
                            anchors.rightMargin: Theme.componentMargin
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
                            anchors.rightMargin: Theme.componentMargin
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
                    source: "qrc:/IconLibrary/material-symbols/bluetooth.svg"
                }

                ////////

                Item { // element_bluetoothControl
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    visible: (Qt.platform.os === "android")

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorPrimary
                        source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
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
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.bluetoothControl
                        onClicked: settingsManager.bluetoothControl = checked
                    }
                }
                Text { // legend_bluetoothControl
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: -12
                    bottomPadding: 0
                    visible: (Qt.platform.os === "android")

                    text: settingsManager.bluetoothControl ? qsTr("SmartCare will enable your device's Bluetooth in order to operate.") :
                                                             qsTr("SmartCare will only operate if your device's Bluetooth is already enabled.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item { // element_bluetoothRange
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-symbols/sensors/radar.svg"
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
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.bluetoothLimitScanningRange
                        onClicked: settingsManager.bluetoothLimitScanningRange = checked
                    }
                }
                Text { // legend_bluetoothRange
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: -12
                    bottomPadding: 0

                    text: settingsManager.bluetoothLimitScanningRange ?
                              qsTr("Will only scan for sensors approximately 2 meters around you.") :
                              qsTr("Sensor scanning range is not limited.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item { // element_bluetoothSimUpdate
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/settings_bluetooth.svg"
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
                        snapMode: Slider.SnapOnRelease
                        wheelEnabled: false

                        value: settingsManager.bluetoothSimUpdates
                        onMoved: settingsManager.bluetoothSimUpdates = value
                    }
                    SpinBoxThemedMobile {
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
                Text { // legend_bluetoothSimUpdate
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: -12
                    bottomPadding: 12

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
                    source: "qrc:/IconLibrary/material-symbols/sensors/local_florist.svg"
                }

                ////////////////

                Item { // element_plant_update
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/timer.svg"
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

                    SpinBoxThemedMobile {
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
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    spacing: 0

                    Item { // element_plant_indicators
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
                            source: "qrc:/IconLibrary/material-symbols/sliders.svg"
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

                        SelectorMenuColorful {
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

                        SelectorMenuColorful {
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

                    Item { // element_plant_indicators_preview
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
                    source: "qrc:/assets/gfx/icons/thermometer_big-24px.svg"
                }

                ////////////////

                Item { // element_thermometer_update
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/timer.svg"
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

                    SpinBoxThemedMobile {
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

                Item { // element_thermometer_unit
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-symbols/sensors/airware.svg"
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

                    SelectorMenuColorful {
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

                ListTitle {
                    text: qsTr("My location")
                    source: "qrc:/IconLibrary/material-symbols/language.svg"
                }

                ////////////////

                Item {
                    id: element_sunandmoon
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-symbols/routine-fill.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: switch_sunandmoon.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Enable Sun and Moon widget")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        lineHeight: 0.8
                    }

                    SwitchThemed {
                        id: switch_sunandmoon
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.sunandmoon
                        onClicked: {
                            var currentDate = new Date()
                            sunAndMoon.set(settingsManager.latitude, settingsManager.longitude, currentDate)
                            settingsManager.sunandmoon = checked
                        }
                    }
                }

                ////////

                Item {
                    id: element_location
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight
                    height: Theme.componentHeightXL

                    visible: settingsManager.sunandmoon

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padIcon
                        anchors.verticalCenter: parent.verticalCenter

                        width: 24
                        height: 24
                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: contentColumn.padText
                        anchors.right: rowPosition.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("GPS position")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        lineHeight: 0.8
                    }

                    Row {
                        id: rowPosition
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        TextFieldThemed {
                            width: contentWidth + leftPadding*2
                            readOnly: true
                            visible: settingsManager.locationSet
                            text: {
                                settingsManager.latitude.toFixed(5) + ", " + settingsManager.longitude.toFixed(5)
                            }
                        }

                        SquareButtonOutline {
                            source: "qrc:/IconLibrary/material-symbols/location/my_location-fill.svg"
                            onClicked: gpsLoader.start()
                        }
                    }

                    Loader {
                        id: gpsLoader
                        active: false
                        asynchronous: true

                        function start() {
                            gpsLoader.active = true
                            gpsTimer.start()
                        }
                        function stop() {
                            gpsLoader.active = false
                            gpsTimer.stop()
                        }

                        Timer {
                            id: gpsTimer
                            interval: 10000
                            running: false
                            repeat: false
                            onTriggered: {
                                if (gpsLoader.status === Loader.Ready) {
                                    gpsLoader.item.wrapUp()
                                }
                                gpsLoader.stop()
                            }
                        }

                        sourceComponent: PositionSource {
                            active: true
                            updateInterval: 2000

                            onSupportedPositioningMethodsChanged: {
                                //console.log("Positioning method: " + supportedPositioningMethods)
                            }
                            onPositionChanged: {
                                if (position.horizontalAccuracy < 3333) {
                                    settingsManager.latitude = position.coordinate.latitude
                                    settingsManager.longitude = position.coordinate.longitude
                                }
                                if (position.horizontalAccuracy < 100) {
                                    gpsLoader.stop()
                                }
                            }
                            function wrapUp() {
                                //console.log("Coordinate: ", position.coordinate.longitude, position.coordinate.latitude)
                                //console.log("Accuracy  : ", position.horizontalAccuracy)

                                if (position.latitudeValid && position.longitudeValid) {
                                    if (position.horizontalAccuracy < 3333) {
                                        settingsManager.latitude = position.coordinate.latitude
                                        settingsManager.longitude = position.coordinate.longitude
                                    }
                                }
                            }
                        }
                    }
/*
                    Timer {
                        id: gpsTimer
                        interval: 10000
                        running: false
                        repeat: false
                        onTriggered: {
                            gps.wrapUp()
                            gps.stop()
                        }
                    }
                    PositionSource {
                        id: gps

                        active: false
                        updateInterval: 2000

                        function start() {
                            gps.active = true
                            gpsTimer.running = true
                        }
                        function stop() {
                            gps.active = false
                            gpsTimer.running = false
                        }

                        onSupportedPositioningMethodsChanged: {
                            console.log("Positioning method: " + supportedPositioningMethods)
                        }
                        onPositionChanged: {
                            wrapUp()
                        }
                        function wrapUp() {
                            console.log("Coordinate: ", position.coordinate.longitude, position.coordinate.latitude)
                            console.log("Accuracy  : ", position.horizontalAccuracy)

                            if (position.latitudeValid && position.longitudeValid) {
                                settingsManager.latitude = position.coordinate.latitude
                                settingsManager.longitude = position.coordinate.longitude

                                //geocodeModel.query = position.coordinate
                                //geocodeModel.update()
                            }
                        }
                    }
                    //GeocodeModel {
                    //    id: geocodeModel
                    //    autoUpdate: false
                    //}
*/
                }

                ////////////////

                ListTitle {
                    text: qsTr("Data archiving")
                    source: "qrc:/IconLibrary/material-symbols/archive.svg"
                    visible: deviceManager.hasDevices
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

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

                        text: qsTr("Saved in your documents, under the 'SmartCare' directory.")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContentSmall
                        verticalAlignment: Text.AlignBottom
                    }
                }

                ////////

                Row { // element_export
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    height: Theme.componentHeightXL
                    spacing: Theme.componentMargin
                    visible: deviceManager.hasDevices

                    ButtonFlat {
                        height: 36
                        anchors.verticalCenter: parent.verticalCenter

                        visible: isDesktop

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

                    ButtonFlat {
                        id: openFolderButton
                        height: 36
                        anchors.verticalCenter: parent.verticalCenter

                        visible: false

                        text: qsTr("Open folder")
                        onClicked: {
                            utilsApp.openWith(deviceManager.exportDataFolder())
                        }
                    }

                    ButtonFlat {
                        height: 36
                        anchors.verticalCenter: parent.verticalCenter

                        visible: isMobile

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
    }

    ////////////////////////////////////////////////////////////////////////////
}
