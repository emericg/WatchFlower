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
    property bool isDesktop: (Qt.platform.os !== "ios" && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios" || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize >= 7.0))

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt.PortraitOrientation, 2 = Qt.LandscapeOrientation
    // 4 = Qt.InvertedPortraitOrientation, 8 = Qt.InvertedLandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation
    onScreenOrientationChanged: {
        handleSafeAreas()
        mobileUI.refresh()
    }

    property int screenPaddingStatusbar: 0
    property int screenPaddingNotch: 0
    property int screenPaddingNavbar: 0

    property int screenPaddingTop: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    function handleSafeAreas() {
        // safe areas are only taken into account if using full screen mode
        if (flags & Qt.MaximizeUsingFullscreenGeometryHint) {
            screenPaddingStatusbar = mobileUI.statusbarHeight
            screenPaddingNotch = 0
            screenPaddingNavbar = mobileUI.navbarHeight

            screenPaddingTop = mobileUI.safeAreaTop
            screenPaddingLeft = mobileUI.safeAreaLeft
            screenPaddingRight = mobileUI.safeAreaRight
            screenPaddingBottom = mobileUI.safeAreaBottom

            if (Qt.platform.os === "android") {
                screenPaddingStatusbar = screenPaddingTop // hack
                screenPaddingNotch = screenPaddingTop - screenPaddingStatusbar
                screenPaddingBottom = screenPaddingNavbar
            }
            if (Qt.platform.os === "ios") {
                screenPaddingNotch = screenPaddingTop - screenPaddingStatusbar
            }
        }
/*
        console.log("> handleSafeAreas()")
        console.log("- screen width:        " + Screen.width)
        console.log("- screen width avail:  " + Screen.desktopAvailableWidth)
        console.log("- screen height:       " + Screen.height)
        console.log("- screen height avail: " + Screen.desktopAvailableHeight)
        console.log("- screen orientation:  " + Screen.orientation)
        console.log("- screen orientation (primary): " + Screen.primaryOrientation)
        console.log("- screenSizeStatusbar: " + screenPaddingStatusbar)
        console.log("- screenSizeNotch:     " + screenPaddingNotch)
        console.log("- screenSizeNavbar:    " + screenPaddingNavbar)
        console.log("- screenPaddingTop:    " + screenPaddingTop)
        console.log("- screenPaddingLeft:   " + screenPaddingLeft)
        console.log("- screenPaddingRight:  " + screenPaddingRight)
        console.log("- screenPaddingBottom: " + screenPaddingBottom)
*/
    }

    MobileUI {
        id: mobileUI
        property bool isLoading: true

        statusbarTheme: Theme.themeStatusbar
        statusbarColor: isLoading ? "white" : Theme.colorStatusbar
        navbarColor: {
            if (isLoading) return "white"
            if (appContent.state === "Tutorial") return Theme.colorHeader
            return Theme.colorBackground
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

    Component.onCompleted: {
        handleSafeAreas()
        mobileUI.isLoading = false
    }

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

    Timer {
        id: exitTimer
        interval: 3333
        running: false
        repeat: false
        onRunningChanged: exitWarning.opacity = running
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
        anchors.right: parent.right
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
                    if (exitTimer.running)
                        Qt.quit()
                    else
                        exitTimer.start()
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
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        About {
            id: screenAbout
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        MobilePermissions {
            id: screenAboutPermissions
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }

        PlantBrowser {
            id: screenPlantBrowser
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceBrowser {
            id: screenDeviceBrowser
            anchors.fill: parent
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

    Rectangle { // navbar area
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: screenPaddingBottom
        visible: (mobileMenu.visible || appContent.state === "Tutorial")
        color: {
            if (appContent.state === "Tutorial") return Theme.colorHeader
            return Theme.colorBackground
        }
    }

    ////////////////

    MobileMenu {
        id: mobileMenu
    }

    ////////////////

    Rectangle {
        id: exitWarning

        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.componentMargin + screenPaddingBottom

        height: Theme.componentHeight
        radius: Theme.componentRadius

        color: Theme.colorComponentBackground
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth

        opacity: 0
        Behavior on opacity { OpacityAnimator { duration: 333 } }
        visible: opacity

        Text {
            anchors.centerIn: parent

            text: qsTr("Press one more time to exit...")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
