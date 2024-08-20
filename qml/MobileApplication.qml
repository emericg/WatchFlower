import QtQuick
import QtQuick.Controls
import QtQuick.Window

import ThemeEngine
import MobileUI

ApplicationWindow {
    id: appWindow
    minimumWidth: 480
    minimumHeight: 960

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true

    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)
    property bool isDesktop: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
    property bool isMobile: (Qt.platform.os === "android" || Qt.platform.os === "ios")
    property bool isPhone: ((Qt.platform.os === "android" || Qt.platform.os === "ios") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "android" || Qt.platform.os === "ios") && (utilsScreen.screenSize >= 7.0))

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt.PortraitOrientation, 2 = Qt.LandscapeOrientation
    // 4 = Qt.InvertedPortraitOrientation, 8 = Qt.InvertedLandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: 0
    property int screenPaddingNavbar: 0

    property int screenPaddingTop: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    Connections {
        target: Screen
        function onOrientationChanged() { mobileUI.handleSafeAreas() }
    }

    MobileUI {
        id: mobileUI

        statusbarColor: "transparent"
        statusbarTheme: Theme.themeStatusbar

        navbarColor: {
            if (appContent.state === "Tutorial") return Theme.colorHeader
            return Theme.colorBackground
        }

        Component.onCompleted: handleSafeAreas()

        function handleSafeAreas() {
            // safe areas handling is a work in progress /!\
            // safe areas are only taken into account when using maximized geometry / full screen mode

            mobileUI.refreshUI() // hack

            if (appWindow.visibility === Window.FullScreen ||
                appWindow.flags & Qt.MaximizeUsingFullscreenGeometryHint) {

                screenPaddingStatusbar = mobileUI.statusbarHeight
                screenPaddingNavbar = mobileUI.navbarHeight

                screenPaddingTop = mobileUI.safeAreaTop
                screenPaddingLeft = mobileUI.safeAreaLeft
                screenPaddingRight = mobileUI.safeAreaRight
                screenPaddingBottom = mobileUI.safeAreaBottom

                // hacks
                if (Qt.platform.os === "android") {
                    if (appWindow.visibility === Window.FullScreen) {
                        screenPaddingStatusbar = 0
                        screenPaddingNavbar = 0
                    }
                    if (appWindow.flags & Qt.MaximizeUsingFullscreenGeometryHint) {
                        if (mobileUI.isPhone) {
                            if (Screen.orientation === Qt.LandscapeOrientation) {
                                screenPaddingLeft = screenPaddingStatusbar
                                screenPaddingRight = screenPaddingNavbar
                                screenPaddingNavbar = 0
                            } else if (Screen.orientation === Qt.InvertedLandscapeOrientation) {
                                screenPaddingLeft = screenPaddingNavbar
                                screenPaddingRight = screenPaddingStatusbar
                                screenPaddingNavbar = 0
                            }
                        }
                    }
                }
                // hacks
                if (Qt.platform.os === "ios") {
                    if (appWindow.visibility === Window.FullScreen) {
                        screenPaddingStatusbar = 0
                    }
                }
            } else {
                screenPaddingStatusbar = 0
                screenPaddingNavbar = 0
                screenPaddingTop = 0
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 0
            }
/*
            console.log("> handleSafeAreas()")
            console.log("- window mode:         " + appWindow.visibility)
            console.log("- window flags:        " + appWindow.flags)
            console.log("- screen dpi:          " + Screen.devicePixelRatio)
            console.log("- screen width:        " + Screen.width)
            console.log("- screen width avail:  " + Screen.desktopAvailableWidth)
            console.log("- screen height:       " + Screen.height)
            console.log("- screen height avail: " + Screen.desktopAvailableHeight)
            console.log("- screen orientation (full): " + Screen.orientation)
            console.log("- screen orientation (primary): " + Screen.primaryOrientation)
            console.log("- screenSizeStatusbar: " + screenPaddingStatusbar)
            console.log("- screenSizeNavbar:    " + screenPaddingNavbar)
            console.log("- screenPaddingTop:    " + screenPaddingTop)
            console.log("- screenPaddingLeft:   " + screenPaddingLeft)
            console.log("- screenPaddingRight:  " + screenPaddingRight)
            console.log("- screenPaddingBottom: " + screenPaddingBottom)
*/
        }
    }

    MobileHeader {
        id: appHeader
    }

    MobileDrawer {
        id: appDrawer

        interactive: (appContent.state !== "Tutorial")
    }

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: appHeader
        function onLeftMenuClicked() {
            if (appContent.state === "DeviceList") {
                appDrawer.open()
            } else {
                if (appContent.state === "Tutorial") {
                    appContent.state = screenTutorial.entryPoint
                } else if (appContent.state === "PlantBrowser") {
                    appContent.state = screenPlantBrowser.entryPoint
                } else if (appContent.state === "AboutPermissions") {
                    appContent.state = screenAboutPermissions.entryPoint
                } else {
                    screenDeviceList.loadScreen()
                }
            }
        }
        function onRightMenuClicked() {
            //
        }

        function onDeviceLedButtonClicked() {
            if (selectedDevice) {
                selectedDevice.actionLedBlink()
            }
        }
        function onDeviceWateringButtonClicked() {
            if (selectedDevice) {
                selectedDevice.actionWatering()
            }
        }
        function onDeviceCalibrateButtonClicked() {
            if (selectedDevice) {
                popupCalibration.open()
            }
        }
        function onDeviceRebootButtonClicked() {
            if (selectedDevice) {
                selectedDevice.actionReboot()
            }
        }

        function onDeviceClearButtonClicked() {
            if (selectedDevice) {
                popupDeleteData.open()
            }
        }
        function onDeviceRefreshHistoryButtonClicked() {
            if (selectedDevice) {
                selectedDevice.refreshStartHistory()
            }
        }

        function onDeviceRefreshRealtimeButtonClicked() {
            if (selectedDevice) {
                selectedDevice.refreshStartRealtime()
            }
        }
        function onDeviceRefreshButtonClicked() {
            if (selectedDevice) {
                deviceManager.updateDevice(selectedDevice.deviceAddress)
            }
        }
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            switch (Qt.application.state) {
                case Qt.ApplicationSuspended:
                    //console.log("Qt.ApplicationSuspended")
                    deviceManager.refreshDevices_stop()
                    break
                case Qt.ApplicationHidden:
                    //console.log("Qt.ApplicationHidden")
                    deviceManager.refreshDevices_stop()
                    break
                case Qt.ApplicationInactive:
                    //console.log("Qt.ApplicationInactive")
                    break

                case Qt.ApplicationActive:
                    //console.log("Qt.ApplicationActive")

                    // Update sun position
                    if (sunAndMoon && settingsManager.sunandmoon) {
                        sunAndMoon.update()
                    }

                    // Check if we need an 'automatic' theme change
                    Theme.loadTheme(settingsManager.appTheme)

                    if (appContent.state === "DeviceBrowser") {
                        // Restart the device browser
                        deviceManager.scanNearby_start()
                    } else {
                        // Listen for nearby devices
                        deviceManager.refreshDevices_listen()
                    }

                    break
            }
        }
    }

    // UI sizes ////////////////////////////////////////////////////////////////

    property bool headerUnicolor: (Theme.colorHeader === Theme.colorBackground)

    property bool singleColumn: {
        if (isMobile) {
            if ((isPhone && screenOrientation === Qt.PortraitOrientation) ||
                (isTablet && width < 512)) { // can be a 2/3 split screen on tablet
                return true
            } else {
                return false
            }
        } else {
            return (appWindow.width < appWindow.height)
        }
    }

    property bool wideMode: (isDesktop && width >= 560) || (isTablet && width >= 480)
    property bool wideWideMode: (width >= 640)

    // QML /////////////////////////////////////////////////////////////////////

    property var selectedDevice: null

    PopupCalibration {
        id: popupCalibration
    }
    PopupDeleteData {
        id: popupDeleteData
    }

    FocusScope {
        id: appContent

        anchors.top: appHeader.bottom
        anchors.left: parent.left
        anchors.leftMargin: screenPaddingLeft
        anchors.right: parent.right
        anchors.rightMargin: screenPaddingRight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: screenPaddingBottom

        focus: true
        Keys.onBackPressed: {
            if (appContent.state === "Tutorial" && screenTutorial.entryPoint === "DeviceList") {
                return // do nothing
            }

            if (appHeader.rightMenuIsOpen()) {
                appHeader.rightMenuClose()
                return
            }

            if (appContent.state === "DeviceList") {
                if (screenDeviceList.isSelected()) {
                    screenDeviceList.exitSelectionMode()
                } else {
                    if (mobileExit.enabled) {
                        if (mobileExit.timerRunning)
                            Qt.quit()
                        else
                            mobileExit.timerStart()
                    } else {
                        mobileUI.backToHomeScreen()
                    }
                }
            } else if (appContent.state === "DevicePlantSensor") {
                screenDevicePlantSensor.backAction()
            } else if (appContent.state === "DeviceThermometer") {
                screenDeviceThermometer.backAction()
            } else if (appContent.state === "DeviceEnvironmental") {
                screenDeviceEnvironmental.backAction()
            } else if (appContent.state === "AboutPermissions") {
                appContent.state = screenAboutPermissions.entryPoint
            } else if (appContent.state === "Tutorial") {
                appContent.state = screenTutorial.entryPoint
            } else if (appContent.state === "PlantBrowser") {
                screenPlantBrowser.backAction()
            } else {
                screenDeviceList.loadScreen()
            }
        }

        Tutorial {
            id: screenTutorial
            anchors.fill: parent
        }

        DeviceList {
            id: screenDeviceList
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        DevicePlantSensor {
            id: screenDevicePlantSensor
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceThermometer {
            id: screenDeviceThermometer
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceEnvironmental {
            id: screenDeviceEnvironmental
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }

        Settings {
            id: screenSettings
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        SettingsAdvanced {
            id: screenSettingsAdvanced
            anchors.bottomMargin: mobileMenu.hhv
        }
        About {
            id: screenAbout
            anchors.bottomMargin: mobileMenu.hhv
        }
        MobilePermissions {
            id: screenAboutPermissions
            anchors.bottomMargin: mobileMenu.hhv
        }

        PlantBrowser {
            id: screenPlantBrowser
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceBrowser {
            id: screenDeviceBrowser
            anchors.bottomMargin: mobileMenu.hhv
        }

        // Start on the device list or tutorial?
        Component.onCompleted: {
            if (deviceManager.areDevicesAvailable()) {
                screenDeviceList.loadScreen()
            } else {
                screenTutorial.loadScreen()
            }
        }

        // Initial state
        state: "DeviceList"

        onStateChanged: {
            screenDeviceList.exitSelectionMode()

            if (state === "DeviceList") {
                appHeader.leftMenuMode = "drawer"
            } else if (state === "Tutorial") {
                appHeader.leftMenuMode = "close"
            } else {
                appHeader.leftMenuMode = "back"
            }
        }

        states: [
            State {
                name: "Tutorial"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Welcome"); }
                PropertyChanges { target: screenTutorial; visible: true; enabled: true; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "DeviceList"
                PropertyChanges { target: appHeader; headerTitle: "WatchFlower"; }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: true; enabled: true; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "DevicePlantSensor"
                PropertyChanges { target: appHeader; headerTitle: selectedDevice.deviceName; }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: true; enabled: true; }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "DeviceThermometer"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Thermometer"); }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false }
                PropertyChanges { target: screenDeviceThermometer; visible: true; enabled: true; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "DeviceEnvironmental"
                PropertyChanges { target: appHeader; headerTitle: selectedDevice.deviceName; }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: true; enabled: true; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "Settings"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Settings"); }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: true; enabled: true; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "SettingsAdvanced"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Settings"); }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: true; enabled: true; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "About"
                PropertyChanges { target: appHeader; headerTitle: qsTr("About"); }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: true; enabled: true; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "AboutPermissions"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Permissions"); }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: true; enabled: true; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "PlantBrowser"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Plant browser"); }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: true; enabled: true; }
                PropertyChanges { target: screenDeviceBrowser; visible: false; enabled: false; }
            },
            State {
                name: "DeviceBrowser"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Device browser"); }
                PropertyChanges { target: screenTutorial; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceEnvironmental; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenSettingsAdvanced; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenPlantBrowser; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceBrowser; visible: true; enabled: true; }
            }
        ]
    }

    ////////////////////////////////////////////////////////////////////////////

    MobileExit {
        id: mobileExit
    }

    MobileMenu {
        id: mobileMenu
    }

    Rectangle { // navbar area
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: screenPaddingNavbar

        visible: (!mobileMenu.visible || appContent.state === "Tutorial")
        opacity: appWindow.isTablet ? 0.5 : 0.95

        color: {
            if (appContent.state === "Tutorial") return Theme.colorHeader
            return Theme.colorBackground
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
