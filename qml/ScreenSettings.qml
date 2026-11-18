import QtQuick
import QtQuick.Controls
import QtPositioning

import ComponentLibrary
import MobileSharing
import AppUtils

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

        ////////////////

        function backAction() {
            screenDeviceList.loadScreen()
        }

        PopupBackgroundUpdates {
            id: popupBackgroundUpdates

            onClosed: {
                SettingsManager.systray = DeviceManager.checkLocationPermission_background()
                switch_worker.checked = SettingsManager.systray
            }
        }

        ////////////////

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: contentColumn.height

            boundsBehavior: Theme.isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Component.onCompleted: {
                //console.log("> (default) flick maximum velocity: " + maximumFlickVelocity)
                //console.log("> (default) flick deceleration: " + flickDeceleration)

                if (Theme.isDesktop) {
                    // mouse wheel or trackpad
                    maximumFlickVelocity = 6500
                    flickDeceleration = 5000
                    boundsBehavior = Flickable.OvershootBounds
                } else {
                    // touch
                    maximumFlickVelocity = 7500
                    flickDeceleration = 3000
                    boundsBehavior = Flickable.DragAndOvershootBounds
                }
            }

            Column {
                id: contentColumn

                anchors.left: parent.left
                anchors.leftMargin: ((Theme.singleColumn || Theme.isPhone) ? 0 : parent.width * 0.12)
                anchors.right: parent.right
                anchors.rightMargin: ((Theme.singleColumn || Theme.isPhone) ? 0 : parent.width * 0.12)

                topPadding: 16
                bottomPadding: 16
                spacing: 8

                property int paddingLeft: (Theme.singleColumn ? 0 : 16)
                property int paddingRight: (Theme.singleColumn ? 0 : 16)

                property int padIcon: Theme.singleColumn ? Theme.componentMarginL : Theme.componentMarginL
                property int padText: appHeader.headerPosition

                ////////////////

                ListTitle {
                    text: qsTr("User interface")
                    source: "qrc:/IconLibrary/material-symbols/settings.svg"
                }

                ////////////////

                ListItemSetting { // element_appTheme
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-icons/duotone/style.svg"
                    text: qsTr("Theme")

                    Row {
                        id: appTheme_selector
                        spacing: Theme.componentMargin / 2

                        Rectangle {
                            id: rectangleSnow
                            width: Theme.wideWideMode ? 80 : 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: "white"
                            border.color: (SettingsManager.appTheme === "THEME_SNOW") ? Theme.colorSubText : "#ddd"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                visible: Theme.wideWideMode
                                text: qsTr("snow")
                                textFormat: Text.PlainText
                                color: (SettingsManager.appTheme === "THEME_SNOW") ? Theme.colorSubText : "#ccc"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: SettingsManager.appTheme = "THEME_SNOW"
                            }
                        }
                        Rectangle {
                            id: rectangleRain
                            width: Theme.wideWideMode ? 80 : 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: "#476cae"
                            border.color: "#06307a"
                            border.width: (SettingsManager.appTheme === "THEME_RAIN") ? 2 : 0

                            Text {
                                anchors.centerIn: parent
                                visible: Theme.wideWideMode
                                text: qsTr("rain")
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: SettingsManager.appTheme = "THEME_RAIN"
                            }
                        }
                        Rectangle {
                            id: rectangleGreen
                            width: Theme.wideWideMode ? 80 : 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: "#09debc" // green theme colorSecondary
                            border.color: Theme.colorPrimary
                            border.width: (SettingsManager.appTheme === "THEME_PLANT") ? 2 : 0

                            Text {
                                anchors.centerIn: parent
                                visible: Theme.wideWideMode
                                text: qsTr("plant")
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: SettingsManager.appTheme = "THEME_PLANT"
                            }
                        }
                        Rectangle {
                            id: rectangleDay
                            width: Theme.wideWideMode ? 80 : 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: "#FFE400" // day theme colorSecondary
                            border.color: Theme.colorPrimary
                            border.width: (SettingsManager.appTheme === "THEME_DAY") ? 2 : 0

                            Text {
                                anchors.centerIn: parent
                                visible: Theme.wideWideMode
                                text: qsTr("day")
                                textFormat: Text.PlainText
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: SettingsManager.appTheme = "THEME_DAY"
                            }
                        }
                        Rectangle {
                            id: rectangleNight
                            width: Theme.wideWideMode ? 80 : 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: "#555151"
                            border.color: Theme.colorPrimary
                            border.width: (SettingsManager.appTheme === "THEME_NIGHT") ? 2 : 0

                            Text {
                                anchors.centerIn: parent
                                visible: Theme.wideWideMode
                                text: qsTr("night")
                                textFormat: Text.PlainText
                                color: (SettingsManager.appTheme === "THEME_NIGHT") ? Theme.colorPrimary : "#ececec"
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: SettingsManager.appTheme = "THEME_NIGHT"
                            }
                        }
                    }
                }

                ////////

                ListItemSetting { // element_appThemeAuto
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-icons/duotone/brightness_4.svg"
                    text: qsTr("Automatic dark mode")
                    legend: SettingsManager.appThemeAuto ?
                                qsTr("Dark mode will switch on automatically between 9 PM and 9 AM.") :
                                qsTr("Dark mode schedule is disabled.")

                    onClicked: switch_appThemeAuto.click()

                    SwitchThemed {
                        id: switch_appThemeAuto

                        checked: SettingsManager.appThemeAuto
                        onClicked: {
                            SettingsManager.appThemeAuto = checked
                            Theme.loadTheme(SettingsManager.appTheme)
                        }
                    }
                }

                ////////

                ListItemSetting { // element_splitView
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-symbols/menu.svg"
                    text: qsTr("Split sensor list in categories")
                    legend: SettingsManager.splitView ?
                                qsTr("Devices will be split into categories (plant sensors, thermometers, air quality monitors)") :
                                qsTr("Devices will be shown together.")

                    onClicked: switch_splitView.click()

                    SwitchThemed {
                        id: switch_splitView

                        checked: SettingsManager.splitView
                        onClicked: SettingsManager.splitView = checked
                    }
                }

                ////////

                ListSeparator { visible: Theme.isDesktop }

                ////////

                ListItemSetting {
                    id: element_language
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-icons/duotone/translate.svg"
                    text: qsTr("Language")

                    ComboBoxThemed {
                        id: combobox_language
                        height: 36

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
                            ListElement { text: "Polski"; }
                            ListElement { text: "Pусский"; }
                        }

                        Component.onCompleted: {
                            for (var i = 0; i < cbAppLanguage.count; i++) {
                                if (cbAppLanguage.get(i).text === SettingsManager.appLanguage)
                                    currentIndex = i
                            }
                        }
                        onActivated: {
                            UtilsLanguage.loadLanguage(cbAppLanguage.get(currentIndex).text)
                            SettingsManager.appLanguage = cbAppLanguage.get(currentIndex).text
                        }
                    }
                }

                ////////

                ListSeparator { visible: Theme.isDesktop }

                ////////

                ListItemSetting { // element_minimized
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    visible: Theme.isDesktop

                    source: "qrc:/IconLibrary/material-icons/duotone/minimize.svg"
                    text: qsTr("Start application minimized")

                    onClicked: switch_minimized.click()

                    SwitchThemed {
                        id: switch_minimized

                        checked: SettingsManager.startMinimized
                        onClicked: SettingsManager.startMinimized = checked
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("Background updates")
                    source: "qrc:/IconLibrary/material-symbols/android.svg"

                    visible: (Qt.platform.os === "android")
                    headerPosition: contentColumn.padText

                    ButtonWireframe {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        height: 32

                        text: qsTr("about")
                        colorBackground: Theme.colorForeground
                        colorText: Theme.colorOrange
                        colorBorder: Theme.colorOrange

                        onClicked: popupBackgroundUpdates.open()
                    }
                }

                ////////////////

                ListItemSetting {
                    id: element_worker
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-symbols/autorenew.svg"
                    text: qsTr("Enable background updates")
                    legend: {
                        if (Qt.platform.os === "android")
                            return qsTr("Wake up at a predefined interval to refresh sensor data. Only if Bluetooth is enabled.")
                        if (Theme.isDesktop)
                            return SettingsManager.systray ?
                                       qsTr("WatchFlower will remain active in the notification area after the window is closed, and will automatically refresh sensors data at regular interval.") :
                                       qsTr("WatchFlower is only active while the window is open.")
                        return ""
                    }

                    onClicked: switch_worker.click()

                    SwitchThemed {
                        id: switch_worker

                        checked: SettingsManager.systray
                        onClicked: {
                            if (Theme.isMobile) {
                                if (checked) {
                                    checked = false
                                    popupBackgroundUpdates.open()
                                } else {
                                    SettingsManager.systray = false
                                }
                            } else {
                                SettingsManager.systray = checked
                            }
                        }
                    }
                }

                ////////

                ListItemSetting {
                    id: element_notifications
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    // every platforms except iOS // also, need the systray
                    visible: (Qt.platform.os !== "ios")
                    enabled: SettingsManager.systray

                    source: "qrc:/IconLibrary/material-symbols/notifications.svg"
                    text: qsTr("Enable notifications")
                    legend: SettingsManager.notifications ?
                                "" : qsTr("If a plant needs water, WatchFlower can bring it to your attention.")

                    onClicked: switch_notifications.click()

                    SwitchThemed {
                        id: switch_notifications

                        checked: SettingsManager.notifications
                        onClicked: {
                            SettingsManager.notifications = checked
                            if (SettingsManager.notifications) {
                                UtilsOS.getMobileNotificationPermission()
                            }
                        }
                    }
                }

                ////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    topPadding: -12
                    visible: SettingsManager.systray && SettingsManager.notifications

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

                            checked: SettingsManager.notif_battery
                            onClicked: SettingsManager.notif_battery = checked
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

                            checked: SettingsManager.notif_water
                            onClicked: SettingsManager.notif_water = checked
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

                            checked: SettingsManager.notif_subzero
                            onClicked: SettingsManager.notif_subzero = checked
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

                            checked: SettingsManager.notif_env
                            onClicked: SettingsManager.notif_env = checked
                        }
                    }
                }

                ////////

                ListTitle {
                    text: qsTr("Bluetooth")
                    source: "qrc:/IconLibrary/material-symbols/bluetooth.svg"
                    headerPosition: contentColumn.padText
                }

                ////////

                ListItemSetting { // element_bluetoothControl
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    visible: (Qt.platform.os === "android")

                    source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
                    text: qsTr("Bluetooth control")
                    legend: SettingsManager.bluetoothControl ?
                                qsTr("WatchFlower will enable your device's Bluetooth in order to operate.") :
                                qsTr("WatchFlower will only operate if your device's Bluetooth is already enabled.")

                    onClicked: switch_bluetoothControl.click()

                    SwitchThemed {
                        id: switch_bluetoothControl

                        checked: SettingsManager.bluetoothControl
                        onClicked: SettingsManager.bluetoothControl = checked
                    }
                }

                ////////

                ListItemSetting { // element_bluetoothRange
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-symbols/sensors/radar.svg"
                    text: qsTr("Limit Bluetooth scanning range")
                    legend: SettingsManager.bluetoothLimitScanningRange ?
                                qsTr("Will only scan for sensors approximately 2 meters around you.") :
                                qsTr("Sensor scanning range is not limited.")

                    onClicked: switch_bluetoothRange.click()

                    SwitchThemed {
                        id: switch_bluetoothRange

                        checked: SettingsManager.bluetoothLimitScanningRange
                        onClicked: SettingsManager.bluetoothLimitScanningRange = checked
                    }
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
                        anchors.right: Theme.isDesktop ? undefined : spinBox_bluetoothSimUpdate.left
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

                        visible: Theme.isDesktop
                        z: 1

                        from: 1
                        to: 6
                        stepSize: 1
                        snapMode: Slider.SnapOnRelease
                        wheelEnabled: false

                        value: SettingsManager.bluetoothSimUpdates
                        onMoved: SettingsManager.bluetoothSimUpdates = value
                    }
                    SpinBoxThemedMobile {
                        id: spinBox_bluetoothSimUpdate
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        visible: Theme.isMobile
                        width: 128
                        height: 36
                        z: 1

                        from: 1
                        to: 6
                        stepSize: 1
                        editable: false

                        value: SettingsManager.bluetoothSimUpdates
                        onValueModified: SettingsManager.bluetoothSimUpdates = value
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
                    headerPosition: contentColumn.padText
                }

                ////////////////

                ListItemSetting { // element_plant_update
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-icons/duotone/timer.svg"
                    text: qsTr("Update interval")

                    SpinBoxThemedMobile {
                        id: spinBox_plant_update
                        width: 128
                        height: 36

                        legend: " " + qsTr("h.", "short for hours")
                        from: 1
                        to: 24
                        stepSize: 1
                        editable: false
                        wheelEnabled: Theme.isDesktop

                        value: (SettingsManager.updateIntervalPlant / 60)
                        onValueModified: SettingsManager.updateIntervalPlant = (value * 60)
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

                            currentSelection: (SettingsManager.bigIndicator) ? 2 : 1
                            onMenuSelected: (index) => {
                                currentSelection = index
                                SettingsManager.bigIndicator = (index === 2)
                            }
                        }

                        SelectorMenuColorful {
                            id: row_plant_dynascale2
                            height: 32

                            model: ListModel {
                                ListElement { idx: 1; txt: qsTr("static"); src: ""; sz: 16; }
                                ListElement { idx: 2; txt: qsTr("dynamic"); src: ""; sz: 16; }
                            }

                            currentSelection: (SettingsManager.dynaScale) ? 2 : 1
                            onMenuSelected: (index) => {
                                currentSelection = index
                                SettingsManager.dynaScale = (index === 2)
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

                            visible: !SettingsManager.bigIndicator
                            width: Theme.singleColumn ? parent.width : element_plant_indicators_selector.width

                            animated: false
                            legend: qsTr("preview")
                            suffix: "°" + SettingsManager.tempUnit
                            colorForeground: Theme.colorLightGrey

                            value: 24
                            valueMin: SettingsManager.dynaScale ? 16 : 0
                            valueMax: SettingsManager.dynaScale ? 32 : 40
                            limitMin: 20
                            limitMax: 28
                        }

                        DataBarSolid {
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -8

                            visible: SettingsManager.bigIndicator
                            width: Theme.singleColumn ? parent.width : element_plant_indicators_selector.width

                            animated: false
                            legend: qsTr("preview")
                            suffix: "°" + SettingsManager.tempUnit
                            colorForeground: Theme.colorLightGrey

                            value: 24
                            valueMin: SettingsManager.dynaScale ? 16 : 0
                            valueMax: SettingsManager.dynaScale ? 32 : 40
                            limitMin: 20
                            limitMax: 28
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("Thermometers")
                    source: "qrc:/assets/gfx/icons/thermometer_big-24px.svg"
                    headerPosition: contentColumn.padText
                }

                ////////////////

                ListItemSetting { // element_thermometer_update
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-icons/duotone/timer.svg"
                    text: qsTr("Update interval")

                    SpinBoxThemedMobile {
                        id: spinBox_thermometer_update
                        width: 128
                        height: 36

                        legend: " " + qsTr("h.", "short for hours")
                        from: 1
                        to: 24
                        stepSize: 1
                        editable: false
                        wheelEnabled: Theme.isDesktop

                        value: (SettingsManager.updateIntervalThermo / 60)
                        onValueModified: SettingsManager.updateIntervalThermo = (value * 60)
                    }
                }

                ////////

                ListItemSetting { // element_thermometer_unit
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-symbols/sensors/airware.svg"
                    text: qsTr("Temperature unit")

                    SelectorMenuColorful {
                        id: row_thermometer_unit
                        height: 32

                        model: ListModel {
                            ListElement { idx: 1; txt: qsTr("°C"); src: ""; sz: 16; }
                            ListElement { idx: 2; txt: qsTr("°F"); src: ""; sz: 16; }
                        }

                        currentSelection: (SettingsManager.tempUnit === 'C') ? 1 : 2
                        onMenuSelected: (index) => {
                            currentSelection = index
                            SettingsManager.tempUnit = (index === 1) ? 'C' : 'F'
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("My location")
                    source: "qrc:/IconLibrary/material-symbols/language.svg"
                    headerPosition: contentColumn.padText
                }

                ////////////////

                ListItemSetting {
                    id: element_sunandmoon
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    source: "qrc:/IconLibrary/material-symbols/routine-fill.svg"
                    text: qsTr("Enable Sun and Moon widget")
                    legend: qsTr("Gives you sunset / sunrise time at your location.")

                    onClicked: switch_sunandmoon.click()

                    SwitchThemed {
                        id: switch_sunandmoon

                        checked: SettingsManager.sunandmoon
                        onClicked: {
                            SettingsManager.sunandmoon = checked
                            element_sunandmoon.updateSunAndMoon()
                        }
                    }

                    function updateSunAndMoon() {
                        var currentDate = new Date()
                        sunAndMoon.set(SettingsManager.latitude, SettingsManager.longitude, currentDate)
                    }
                }

                ////////

                ListItemSetting {
                    id: element_location
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight

                    visible: SettingsManager.sunandmoon

                    source: "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"
                    text: qsTr("GPS position")
                    legend: qsTr("Coarse location is required to give you sunset and sunrise times.")

                    Row {
                        id: rowPosition
                        spacing: 12

                        property bool manualEdit: false

                        TextFieldThemed { // display position
                            width: contentWidth + leftPadding*2
                            readOnly: true
                            visible: SettingsManager.locationSet && !rowPosition.manualEdit
                            text: {
                                SettingsManager.latitude.toFixed(3) + ", " + SettingsManager.longitude.toFixed(3)
                            }
                        }

                        TextFieldThemed { // edit latitude
                            id: latitudeEdit
                            width: contentWidth + leftPadding*2
                            visible: rowPosition.manualEdit

                            validator: DoubleValidator {
                                bottom: -90
                                top: 90
                                decimals: 6
                                locale: "en_US"
                                notation: DoubleValidator.StandardNotation
                            }
                            colorBorder: latitudeEdit.acceptableInput ? Theme.colorComponentBorder : Theme.colorWarning

                            text: {
                                SettingsManager.latitude.toFixed(3)
                            }
                            onEditingFinished: {
                                //console.log("latitudeEdit.onEditingFinished: " + text + " - " + displayText)
                                SettingsManager.latitude = latitudeEdit.displayText
                                element_sunandmoon.updateSunAndMoon()
                                latitudeEdit.text = SettingsManager.latitude.toFixed(3)
                            }
                        }
                        TextFieldThemed { // edit longitude
                            id: longitudeEdit
                            width: contentWidth + leftPadding*2
                            visible: rowPosition.manualEdit

                            validator: DoubleValidator {
                                bottom: -180
                                top: 180
                                decimals: 6
                                locale: "en_US"
                                notation: DoubleValidator.StandardNotation
                            }
                            colorBorder: longitudeEdit.acceptableInput ? Theme.colorComponentBorder : Theme.colorWarning

                            text: {
                                SettingsManager.longitude.toFixed(3)
                            }
                            onEditingFinished: {
                                //console.log("longitudeEdit.onEditingFinished: " + text + " - " + displayText)
                                SettingsManager.longitude = longitudeEdit.displayText
                                longitudeEdit.text = SettingsManager.longitude.toFixed(3)
                                element_sunandmoon.updateSunAndMoon()
                            }
                        }

                        SquareButtonOutline {
                            source: "qrc:/IconLibrary/material-symbols/edit.svg"
                            color: rowPosition.manualEdit ? "white" : Theme.colorPrimary
                            colorBackground: rowPosition.manualEdit ? Theme.colorPrimary : "transparent"
                            onClicked: {
                                if (rowPosition.manualEdit) {
                                    latitudeEdit.focus = false
                                    longitudeEdit.focus = false
                                }
                                rowPosition.manualEdit = !rowPosition.manualEdit
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
                                    SettingsManager.latitude = position.coordinate.latitude
                                    SettingsManager.longitude = position.coordinate.longitude
                                    element_sunandmoon.updateSunAndMoon()
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
                                        SettingsManager.latitude = position.coordinate.latitude
                                        SettingsManager.longitude = position.coordinate.longitude
                                        element_sunandmoon.updateSunAndMoon()
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
                                SettingsManager.latitude = position.coordinate.latitude
                                SettingsManager.longitude = position.coordinate.longitude

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
                    visible: DeviceManager.hasDevices
                    headerPosition: contentColumn.padText
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.paddingLeft + contentColumn.padText
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.paddingRight + Theme.componentMargin

                    topPadding: 8
                    visible: DeviceManager.hasDevices

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

                        visible: Theme.isDesktop

                        text: qsTr("Saved in your documents, under the 'WatchFlower' directory.")
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
                    visible: DeviceManager.hasDevices

                    ButtonFlat {
                        height: 36
                        anchors.verticalCenter: parent.verticalCenter

                        visible: Theme.isDesktop

                        text: qsTr("Export data")
                        onClicked: {
                            if (DeviceManager.exportDataSave()) {
                                text = qsTr("Exported")
                                primaryColor = Theme.colorPrimary
                                fullColor = true
                                if (Theme.isDesktop) openFolderButton.visible = true
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
                            UtilsApp.openWith(DeviceManager.exportDataFolder())
                        }
                    }

                    ButtonFlat {
                        height: 36
                        anchors.verticalCenter: parent.verticalCenter

                        visible: Theme.isMobile

                        text: qsTr("Export file")
                        onClicked: {
                            var file = DeviceManager.exportDataOpen()
                            MobileSharing.sendFile(file, qsTr("Export file"), "text/csv", 0)
                        }
                    }
                }

                ////////
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
