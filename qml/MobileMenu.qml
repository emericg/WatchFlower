import QtQuick

import ThemeEngine

Item {
    id: mobileMenu
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    property int hhh: (appWindow.isPhone ? 36 : 48)
    property int hhi: (hhh * 0.5)
    property int hhv: visible ? hhh : 0

    height: hhh + screenPaddingNavbar + screenPaddingBottom

    visible: (isTablet && (appContent.state === "DeviceList" ||
                           appContent.state === "DevicePlantSensor" ||
                           appContent.state === "DeviceBrowser" ||
                           appContent.state === "PlantBrowser" ||
                           appContent.state === "Settings" ||
                           appContent.state === "SettingsAdvanced" ||
                           appContent.state === "About" ||
                           appContent.state === "AboutPermissions")) ||
             (isPhone && screenOrientation === Qt.PortraitOrientation &&
                          (appContent.state === "DevicePlantSensor"))

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // background
        anchors.fill: parent

        opacity: 0.95
        color: appWindow.isTablet ? Theme.colorTabletmenu : Theme.colorBackground

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            opacity: 0.33
            visible: !appWindow.isPhone
            color: Theme.colorTabletmenuContent
        }
    }

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////////////////////////////////////////////////////////////////

    signal deviceDataButtonClicked()
    signal deviceHistoryButtonClicked()
    signal devicePlantButtonClicked()
    signal deviceSettingsButtonClicked()

    function setActiveDeviceData() {
        menuDeviceData.highlighted = true
        menuDeviceHistory.highlighted = false
        menuDevicePlant.highlighted = false
        menuDeviceSettings.highlighted = false
    }
    function setActiveDeviceHistory() {
        menuDeviceData.highlighted = false
        menuDeviceHistory.highlighted = true
        menuDevicePlant.highlighted = false
        menuDeviceSettings.highlighted = false
    }
    function setActiveDevicePlant() {
        menuDeviceData.highlighted = false
        menuDeviceHistory.highlighted = false
        menuDevicePlant.highlighted = true
        menuDeviceSettings.highlighted = false
    }
    function setActiveDeviceSettings() {
        menuDeviceData.highlighted = false
        menuDeviceHistory.highlighted = false
        menuDevicePlant.highlighted = false
        menuDeviceSettings.highlighted = true
    }

    ////////////////////////////////////////////////////////////////////////////

    Item { // menu area
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: mobileMenu.hhh

        ////////////////////////

        Row { // main menu
            anchors.centerIn: parent
            spacing: (!appWindow.wideMode || (isPhone && utilsScreen.screenSize < 5.0)) ? -10 : 20

            visible: (appContent.state === "DeviceList" ||
                      appContent.state === "DeviceBrowser" ||
                      appContent.state === "PlantBrowser" ||
                      appContent.state === "Settings" ||
                      appContent.state === "SettingsAdvanced" ||
                      appContent.state === "About" ||
                      appContent.state === "AboutPermissions")

            MobileMenuItem_horizontal {
                id: menuMainView
                height: mobileMenu.hhh

                text: qsTr("Sensors")
                source: "qrc:/assets/gfx/logos/watchflower_tray_monochrome.svg"
                sourceSize: mobileMenu.hhi
                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                highlighted: (appContent.state === "DeviceList")
                onClicked: screenDeviceList.loadScreen()
            }
            MobileMenuItem_horizontal {
                id: menuPlantBrowser
                height: mobileMenu.hhh

                text: qsTr("Plant browser")
                source: "qrc:/assets/icons/material-symbols/sensors/local_florist.svg"
                sourceSize: mobileMenu.hhi
                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                visible: (screenOrientation === Qt.LandscapeOrientation)
                highlighted: (appContent.state === "PlantBrowser")
                onClicked: screenPlantBrowser.loadScreenFrom("DeviceList")
            }
            MobileMenuItem_horizontal {
                id: menuDeviceBrowser
                height: mobileMenu.hhh

                text: qsTr("Device browser")
                source: "qrc:/assets/icons/material-symbols/sensors/radar.svg"
                sourceSize: mobileMenu.hhi
                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                visible: (screenOrientation === Qt.LandscapeOrientation)
                enabled: (deviceManager.bluetooth && deviceManager.bluetoothPermissions)
                highlighted: (appContent.state === "DeviceBrowser")
                onClicked: screenDeviceBrowser.loadScreen()
            }
            MobileMenuItem_horizontal {
                id: menuSettings
                height: mobileMenu.hhh

                text: qsTr("Settings")
                source: "qrc:/assets/icons/material-symbols/settings.svg"
                sourceSize: mobileMenu.hhi
                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                highlighted: (appContent.state === "Settings" || appContent.state === "SettingsAdvanced")
                onClicked: screenSettings.loadScreen()
            }
            MobileMenuItem_horizontal {
                id: menuAbout
                height: mobileMenu.hhh

                text: qsTr("About")
                source: "qrc:/assets/icons/material-symbols/info-fill.svg"
                sourceSize: mobileMenu.hhi
                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                highlighted: (appContent.state === "About" || appContent.state === "AboutPermissions")
                onClicked: screenAbout.loadScreen()
            }
        }

        ////////////////////////

        Row { // plant care submenu
            anchors.centerIn: parent
            spacing: (!wideMode || (isPhone && utilsScreen.screenSize < 5.0)) ? -10 : 20

            visible: (appContent.state === "DevicePlantSensor")

            MobileMenuItem_horizontal {
                id: menuDeviceData
                height: mobileMenu.hhh

                text: qsTr("Data")
                source: "qrc:/assets/icons/material-icons/duotone/insert_chart.svg"
                sourceSize: mobileMenu.hhi

                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                onClicked: mobileMenu.deviceDataButtonClicked()
            }
            MobileMenuItem_horizontal {
                id: menuDeviceHistory
                height: mobileMenu.hhh

                text: qsTr("History")
                source: "qrc:/assets/icons/material-icons/duotone/date_range.svg"
                sourceSize: mobileMenu.hhi

                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                onClicked: mobileMenu.deviceHistoryButtonClicked()
            }
            MobileMenuItem_horizontal {
                id: menuDevicePlant
                height: mobileMenu.hhh

                text: qsTr("Plant")
                source: "qrc:/assets/gfx/icons/duotone-plant_care-24px.svg"
                sourceSize: mobileMenu.hhi

                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                onClicked: mobileMenu.devicePlantButtonClicked()
            }
            MobileMenuItem_horizontal {
                id: menuDeviceSettings
                height: mobileMenu.hhh

                text: qsTr("Sensor")
                source: "qrc:/assets/icons/material-icons/duotone/memory.svg"
                sourceSize: mobileMenu.hhi

                colorContent: Theme.colorTabletmenuContent
                colorHighlight: Theme.colorTabletmenuHighlight

                onClicked: mobileMenu.deviceSettingsButtonClicked()
            }
        }

        ////////////////////////

        Row { // thermometer submenu
            anchors.centerIn: parent
            spacing: (!wideMode || (isPhone && utilsScreen.screenSize < 5.0)) ? -12 : 24

            visible: (appContent.state === "DeviceThermometer")
        }

        ////////////////////////

        Row { // environmental submenu
            anchors.centerIn: parent
            spacing: (!wideMode || (isPhone && utilsScreen.screenSize < 5.0)) ? -12 : 24

            visible: (appContent.state === "DeviceEnvironmental")
        }

        ////////////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
