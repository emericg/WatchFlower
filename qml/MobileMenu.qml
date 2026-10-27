import QtQuick

import ComponentLibrary
import MobileUI
import AppUtils

Item {
    id: mobileMenu
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    property int hhh: (Theme.isPhone ? 48 : 48)
    property int hhi: (Theme.isPhone ? 26 : (hhh * 0.5))
    property int hhv: visible ? hhh : 0
    property int www: 80

    height: hhh + Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

    visible: (Theme.isTablet &&
                (appContent.state === "DeviceList" ||
                 appContent.state === "DevicePlantSensor" ||
                 appContent.state === "DeviceThermometer" ||
                 appContent.state === "DeviceEnvironmental" ||
                 appContent.state === "DeviceBrowser" ||
                 appContent.state === "PlantBrowser" ||
                 appContent.state === "ScreenSettings" ||
                 appContent.state === "ScreenSettingsAdvanced" ||
                 appContent.state === "ScreenAbout" ||
                 appContent.state === "ScreenAboutPermissions")) ||
             (Theme.isPhone && Theme.screenOrientation === Qt.PortraitOrientation &&
                (appContent.state === "DevicePlantSensor"))
                 //appContent.state === "DeviceThermometer" ||
                 //appContent.state === "DeviceEnvironmental"))

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // background
        anchors.fill: parent

        opacity: 0.95
        color: Theme.isTablet ? Theme.colorTabletmenu : Theme.colorBackground

        Rectangle { // separator
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.isPhone ? 1 : 2
            opacity: Theme.isPhone ? 0.24 : 0.33
            color: Theme.colorTabletmenuContent
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    signal deviceDataButtonClicked()
    signal deviceHistoryButtonClicked()
    signal devicePlantButtonClicked()
    signal deviceSettingsButtonClicked()

    property bool menuDeviceData_plant_highlighted: false
    property bool menuDeviceHistory_plant_highlighted: false
    property bool menuDevicePlant_plant_highlighted: false
    property bool menuDeviceSettings_plant_highlighted: false

    property bool menuDeviceData_thermo_highlighted: false
    property bool menuDeviceSettings_thermo_highlighted: false

    property bool menuDeviceData_env_highlighted: false
    property bool menuDeviceSettings_env_highlighted: false

    function resetActiveDeviceView() {
        if (appContent.state === "DevicePlantSensor") {
            menuDeviceData_plant_highlighted = true
            menuDeviceHistory_plant_highlighted = false
            menuDevicePlant_plant_highlighted = false
            menuDeviceSettings_plant_highlighted = false
        } else if (appContent.state === "DeviceThermometer") {
            menuDeviceData_thermo_highlighted = true
            menuDeviceSettings_thermo_highlighted = false
        } else if (appContent.state === "DeviceEnvironmental") {
            menuDeviceData_env_highlighted = true
            menuDeviceSettings_env_highlighted = false
        }
    }

    function setActiveDeviceData() {
        if (appContent.state === "DevicePlantSensor") {
            menuDeviceData_plant_highlighted = true
            menuDeviceHistory_plant_highlighted = false
            menuDevicePlant_plant_highlighted = false
            menuDeviceSettings_plant_highlighted = false
        } else if (appContent.state === "DeviceThermometer") {
            menuDeviceData_thermo_highlighted = true
            menuDeviceSettings_thermo_highlighted = false
        } else if (appContent.state === "DeviceEnvironmental") {
            menuDeviceData_env_highlighted = true
            menuDeviceSettings_env_highlighted = false
        }
    }
    function setActiveDeviceHistory() {
        menuDeviceData_plant_highlighted = false
        menuDeviceHistory_plant_highlighted = true
        menuDevicePlant_plant_highlighted = false
        menuDeviceSettings_plant_highlighted = false
    }
    function setActiveDevicePlant() {
        menuDeviceData_plant_highlighted = false
        menuDeviceHistory_plant_highlighted = false
        menuDevicePlant_plant_highlighted = true
        menuDeviceSettings_plant_highlighted = false
    }
    function setActiveDeviceSettings() {
        if (appContent.state === "DevicePlantSensor") {
            menuDeviceData_plant_highlighted = false
            menuDeviceHistory_plant_highlighted = false
            menuDevicePlant_plant_highlighted = false
            menuDeviceSettings_plant_highlighted = true
        } else if (appContent.state === "DeviceThermometer") {
            menuDeviceData_thermo_highlighted = false
            menuDeviceSettings_thermo_highlighted = true
        } else if (appContent.state === "DeviceEnvironmental") {
            menuDeviceData_env_highlighted = false
            menuDeviceSettings_env_highlighted = true
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader { // main menu (tablet)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: mobileMenu.hhh

        asynchronous: true
        active: (Theme.isTablet)

        sourceComponent: Item {
            anchors.fill: parent

            visible: (appContent.state === "DeviceList" ||
                      appContent.state === "DeviceBrowser" ||
                      appContent.state === "PlantBrowser" ||
                      appContent.state === "ScreenSettings" ||
                      appContent.state === "ScreenSettingsAdvanced" ||
                      appContent.state === "ScreenAbout" ||
                      appContent.state === "ScreenAboutPermissions")

            Row {
                anchors.centerIn: parent

                spacing: (!Theme.wideMode || (Theme.isPhone && UtilsScreen.screenSize < 5.0)) ? -10 : 20

                visible: (appContent.state === "DeviceList" ||
                          appContent.state === "DeviceBrowser" ||
                          appContent.state === "PlantBrowser" ||
                          appContent.state === "ScreenSettings" ||
                          appContent.state === "ScreenSettingsAdvanced" ||
                          appContent.state === "ScreenAbout" ||
                          appContent.state === "ScreenAboutPermissions")

                MobileMenuItem_horizontal { // menuMainView
                    height: mobileMenu.hhh

                    text: qsTr("Sensors")
                    source: "qrc:/assets/gfx/logos/watchflower_tray_monochrome.svg"
                    sourceSize: mobileMenu.hhi
                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    highlighted: (appContent.state === "DeviceList")
                    onClicked: screenDeviceList.loadScreen()
                }
                MobileMenuItem_horizontal { // menuPlantBrowser
                    height: mobileMenu.hhh

                    text: qsTr("Plant browser")
                    source: "qrc:/IconLibrary/material-symbols/sensors/local_florist.svg"
                    sourceSize: mobileMenu.hhi
                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    visible: (screenOrientation === Qt.LandscapeOrientation)
                    highlighted: (appContent.state === "PlantBrowser")
                    onClicked: screenPlantBrowser.loadScreenFrom("DeviceList")
                }
                MobileMenuItem_horizontal { // menuDeviceBrowser
                    height: mobileMenu.hhh

                    text: qsTr("Device browser")
                    source: "qrc:/IconLibrary/material-symbols/sensors/radar.svg"
                    sourceSize: mobileMenu.hhi
                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    visible: (screenOrientation === Qt.LandscapeOrientation)
                    enabled: (DeviceManager.bluetooth && DeviceManager.bluetoothPermissions)
                    highlighted: (appContent.state === "DeviceBrowser")
                    onClicked: screenDeviceBrowser.loadScreen()
                }
                MobileMenuItem_horizontal { // menuSettings
                    height: mobileMenu.hhh

                    text: qsTr("Settings")
                    source: "qrc:/IconLibrary/material-symbols/settings.svg"
                    sourceSize: mobileMenu.hhi
                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    highlighted: (appContent.state === "ScreenSettings" || appContent.state === "ScreenSettingsAdvanced")
                    onClicked: screenSettings.loadScreen()
                }
                MobileMenuItem_horizontal { // menuAbout
                    height: mobileMenu.hhh

                    text: qsTr("About")
                    source: "qrc:/IconLibrary/material-symbols/info.svg"
                    sourceSize: mobileMenu.hhi
                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    highlighted: (appContent.state === "ScreenAbout" || appContent.state === "ScreenAboutPermissions")
                    onClicked: screenAbout.loadScreen()
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader { // plant care submenu (phone)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: mobileMenu.hhh

        asynchronous: true
        active: (Theme.isPhone && appContent.state === "DevicePlantSensor")

        sourceComponent: Item {
            anchors.fill: parent

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 6
                spacing: 0

                MobileMenuItem_vertical {
                    width: mobileMenu.www

                    text: qsTr("Data")
                    source: "qrc:/IconLibrary/material-icons/duotone/insert_chart.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceData_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceDataButtonClicked()
                }
                MobileMenuItem_vertical {
                    width: mobileMenu.www

                    text: qsTr("History")
                    source: "qrc:/IconLibrary/material-icons/duotone/date_range.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceHistory_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceHistoryButtonClicked()
                }
                MobileMenuItem_vertical {
                    width: mobileMenu.www

                    text: qsTr("Plant")
                    source: "qrc:/assets/gfx/icons/duotone-plant_care-24px.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDevicePlant_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.devicePlantButtonClicked()
                }
                MobileMenuItem_vertical {
                    width: mobileMenu.www

                    text: qsTr("Sensor")
                    source: "qrc:/IconLibrary/material-icons/duotone/memory.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceSettings_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceSettingsButtonClicked()
                }
            }
        }
    }

    ////////////////////////

    Loader { // plant care submenu (tablet)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: mobileMenu.hhh

        asynchronous: true
        active: (Theme.isTablet && appContent.state === "DevicePlantSensor")

        sourceComponent: Item {
            anchors.fill: parent

            Row {
                anchors.centerIn: parent
                spacing: 20

                MobileMenuItem_horizontal {
                    height: mobileMenu.hhh

                    text: qsTr("Data")
                    source: "qrc:/IconLibrary/material-icons/duotone/insert_chart.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceData_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceDataButtonClicked()
                }
                MobileMenuItem_horizontal {
                    height: mobileMenu.hhh

                    text: qsTr("History")
                    source: "qrc:/IconLibrary/material-icons/duotone/date_range.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceHistory_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceHistoryButtonClicked()
                }
                MobileMenuItem_horizontal {
                    height: mobileMenu.hhh

                    text: qsTr("Plant")
                    source: "qrc:/assets/gfx/icons/duotone-plant_care-24px.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDevicePlant_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.devicePlantButtonClicked()
                }
                MobileMenuItem_horizontal {
                    height: mobileMenu.hhh

                    text: qsTr("Sensor")
                    source: "qrc:/IconLibrary/material-icons/duotone/memory.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceSettings_plant_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceSettingsButtonClicked()
                }
            }
        }
    }

    ////////////////////////

    Loader { // thermometer submenu (phone)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: mobileMenu.hhh

        asynchronous: true
        active: (Theme.isPhone && appContent.state === "DeviceThermometer")

        sourceComponent: Item {
            anchors.fill: parent

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 6

                MobileMenuItem_vertical {
                    width: mobileMenu.www
                    height: mobileMenu.hhh

                    text: qsTr("Data")
                    source: "qrc:/IconLibrary/material-icons/duotone/insert_chart.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceData_thermo_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceDataButtonClicked()
                }
                MobileMenuItem_vertical {
                    width: mobileMenu.www
                    height: mobileMenu.hhh

                    text: qsTr("Sensor")
                    source: "qrc:/IconLibrary/material-icons/duotone/memory.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceSettings_thermo_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceSettingsButtonClicked()
                }
            }
        }
    }

    ////////////////////////

    Loader { // thermometer submenu (tablet)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: mobileMenu.hhh

        asynchronous: true
        active: (Theme.isTablet && appContent.state === "DeviceThermometer")

        sourceComponent: Item {
            anchors.fill: parent

            Row {
                anchors.centerIn: parent
                spacing: 20

                MobileMenuItem_horizontal {
                    height: mobileMenu.hhh

                    text: qsTr("Data")
                    source: "qrc:/IconLibrary/material-icons/duotone/insert_chart.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceData_thermo_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceDataButtonClicked()
                }
                MobileMenuItem_horizontal {
                    height: mobileMenu.hhh

                    text: qsTr("Sensor")
                    source: "qrc:/IconLibrary/material-icons/duotone/memory.svg"
                    sourceSize: mobileMenu.hhi
                    highlighted: mobileMenu.menuDeviceSettings_thermo_highlighted

                    colorContent: Theme.colorTabletmenuContent
                    colorHighlight: Theme.colorTabletmenuHighlight

                    onClicked: mobileMenu.deviceSettingsButtonClicked()
                }
            }
        }
    }

    ////////////////////////
/*
    Loader { // environmental submenu (phone)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: mobileMenu.hhh

        asynchronous: true
        active: (Theme.isPhone && appContent.state === "DeviceEnvironmental")

        sourceComponent: Item {
            anchors.fill: parent

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 6
            }
        }
    }

    ////////////////////////

    Loader { // environmental submenu (tablet)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: mobileMenu.hhh

        asynchronous: true
        active: (Theme.isTablet && appContent.state === "DeviceEnvironmental")

        sourceComponent: Item {
            anchors.fill: parent

            Row {
                anchors.centerIn: parent
            }
        }
    }
*/
    ////////////////////////////////////////////////////////////////////////////
}
