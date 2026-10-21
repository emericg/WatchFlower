import QtQuick
import QtQuick.Window
import QtQuick.Controls

import ComponentLibrary
import MobileUI
import AppUtils

Window {
    id: appWindow

    minimumWidth: 480
    minimumHeight: 960

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true

    // Helpers
    property bool isHdpi: (UtilsScreen.screenDpi >= 128 || UtilsScreen.screenPar >= 2.0)
    property bool isDesktop: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
    property bool isMobile: (Qt.platform.os === "android" || Qt.platform.os === "ios")
    property bool isPhone: ((Qt.platform.os === "android" || Qt.platform.os === "ios") && (UtilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "android" || Qt.platform.os === "ios") && (UtilsScreen.screenSize >= 7.0))

    // Setup ThemeEngine
    Binding { target: Theme; property: "appTheme";               value: SettingsManager.appTheme }
    Binding { target: Theme; property: "appThemeAuto";           value: SettingsManager.appThemeAuto }
    Binding { target: Theme; property: "appThemeAutoMethod";     value: SettingsManager.appThemeAutoMethod }
    Binding { target: Theme; property: "appWidth";               value: appWindow.width }
    Binding { target: Theme; property: "appHeight";              value: appWindow.height }
    Binding { target: Theme; property: "screenOrientation";      value: Screen.primaryOrientation }
    Binding { target: Theme; property: "screenDpiLogical";       value: UtilsScreen.screenDpiLogical }
    Binding { target: Theme; property: "screenDpi";              value: UtilsScreen.screenDpi }
    Binding { target: Theme; property: "screenPar";              value: UtilsScreen.screenPar }
    Binding { target: Theme; property: "screenSize";             value: UtilsScreen.screenSize }
    Binding { target: Theme; property: "screenPaddingStatusbar"; value: MobileUI.statusbarHeight }
    Binding { target: Theme; property: "screenPaddingNavbar";    value: MobileUI.navbarHeight }
    Binding { target: Theme; property: "screenPaddingTop";       value: MobileUI.safeAreaTop }
    Binding { target: Theme; property: "screenPaddingLeft";      value: MobileUI.safeAreaLeft }
    Binding { target: Theme; property: "screenPaddingRight";     value: MobileUI.safeAreaRight }
    Binding { target: Theme; property: "screenPaddingBottom";    value: MobileUI.safeAreaBottom }

    // Setup MobileUI
    Binding { target: MobileUI; property: "statusbarContentColor"; value: Theme.colorStatusbar }
    Binding { target: MobileUI; property: "navbarColor"; value: "transparent" }
    Binding { target: MobileUI; property: "navbarContentColor"; value: {
            if (appContent.state === "ScreenTutorial") return Theme.colorHeader
            // if(mobileMenu.visible) return Theme.isTablet ? Theme.colorTabletmenu : Theme.colorBackground
            return Theme.colorBackground
        }
    }

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt.PortraitOrientation, 2 = Qt.LandscapeOrientation
    // 4 = Qt.InvertedPortraitOrientation, 8 = Qt.InvertedLandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: MobileUI.statusbarHeight
    property int screenPaddingNavbar: MobileUI.navbarHeight

    property int screenPaddingTop: MobileUI.safeAreaTop
    property int screenPaddingLeft: MobileUI.safeAreaLeft
    property int screenPaddingRight: MobileUI.safeAreaRight
    property int screenPaddingBottom: MobileUI.safeAreaBottom

    MobileHeader {
        id: appHeader
    }

    MobileDrawer {
        id: appDrawer

        interactive: (appContent.state !== "ScreenTutorial")
    }

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: appHeader
        function onLeftMenuClicked() {
            if (appContent.state === "DeviceList") {
                appDrawer.open()
            } else {
                if (appContent.state === "ScreenTutorial") {
                    appContent.state = screenTutorial.entryPoint
                } else if (appContent.state === "PlantBrowser") {
                    appContent.state = screenPlantBrowser.entryPoint
                } else if (appContent.state === "ScreenAboutPermissions") {
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
                DeviceManager.updateDevice(appWindow.selectedDevice.deviceAddress)
            }
        }
    }

    // Foreground heartbeat for the background service (the service considers it stale after 90s)
    Timer {
        id: serviceHeartbeatTimer
        interval: 30000
        repeat: true
        running: (Qt.platform.os === "android" &&
                  Qt.application.state !== Qt.ApplicationSuspended &&
                  Qt.application.state !== Qt.ApplicationHidden)
        onTriggered: AndroidServiceLink.setBackgroundServiceAppState(true)
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            switch (Qt.application.state) {
                case Qt.ApplicationSuspended:
                    //console.log("Qt.ApplicationSuspended")
                    DeviceManager.refreshDevices_stop()
                    if (Qt.platform.os === "android") AndroidServiceLink.setBackgroundServiceAppState(false)
                    break
                case Qt.ApplicationHidden:
                    //console.log("Qt.ApplicationHidden")
                    DeviceManager.refreshDevices_stop()
                    if (Qt.platform.os === "android") AndroidServiceLink.setBackgroundServiceAppState(false)
                    break
                case Qt.ApplicationInactive:
                    //console.log("Qt.ApplicationInactive")
                    break

                case Qt.ApplicationActive:
                    //console.log("Qt.ApplicationActive")

                    if (Qt.platform.os === "android")  {
                        // Tell the background service to stand down while we are active
                        AndroidServiceLink.setBackgroundServiceAppState(true)

                        // Re-check whether the background service is online (updates the drawer indicator)
                        AndroidServiceLink.checkServiceState()
                    }

                    // Update sun/moon positions
                    if (SettingsManager.sunandmoon) {
                        sunAndMoon.update()
                    }

                    // Check if we need an 'automatic' theme change
                    Theme.loadTheme(SettingsManager.appTheme)

                    if (appContent.state === "DeviceBrowser") {
                        // Restart the device browser
                        DeviceManager.scanNearby_start()
                    } else {
                        // Listen for nearby devices
                        DeviceManager.refreshDevices_listen()
                    }

                    break
            }
        }
    }

    // UI sizes ////////////////////////////////////////////////////////////////

    property bool headerUnicolor: (Theme.colorHeader === Theme.colorBackground)

    property bool singleColumn: {
        if (Theme.isMobile) {
            if ((Theme.isPhone && Theme.screenOrientation === Qt.PortraitOrientation) ||
                (Theme.isTablet && width < 512)) { // can be a 2/3 split screen on tablet
                return true
            } else {
                return false
            }
        } else {
            return (appWindow.width < appWindow.height)
        }
    }

    property bool wideMode: (Theme.isDesktop && width >= 560) || (Theme.isTablet && width >= 480)
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
        anchors.bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

        focus: true
        Keys.onBackPressed: {
            if (appContent.state === "ScreenTutorial" && screenTutorial.entryPoint === "DeviceList") {
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
                        MobileUI.backToHomeScreen()
                    }
                }
            } else if (appContent.state === "DevicePlantSensor") {
                screenDevicePlantSensor.backAction()
            } else if (appContent.state === "DeviceThermometer") {
                screenDeviceThermometer.backAction()
            } else if (appContent.state === "DeviceEnvironmental") {
                screenDeviceEnvironmental.backAction()
            } else if (appContent.state === "ScreenAboutPermissions") {
                appContent.state = screenAboutPermissions.entryPoint
            } else if (appContent.state === "ScreenTutorial") {
                appContent.state = screenTutorial.entryPoint
            } else if (appContent.state === "PlantBrowser") {
                screenPlantBrowser.backAction()
            } else {
                screenDeviceList.loadScreen()
            }
        }

        ScreenTutorial {
            id: screenTutorial
        }

        DeviceList {
            id: screenDeviceList
            anchors.leftMargin: Theme.screenPaddingLeft
            anchors.rightMargin: Theme.screenPaddingRight
            anchors.bottomMargin: mobileMenu.hhv
        }
        DevicePlantSensor {
            id: screenDevicePlantSensor
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceThermometer {
            id: screenDeviceThermometer
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceEnvironmental {
            id: screenDeviceEnvironmental
            anchors.bottomMargin: mobileMenu.hhv
        }

        ScreenSettings {
            id: screenSettings
            anchors.leftMargin: Theme.screenPaddingLeft
            anchors.rightMargin: Theme.screenPaddingRight
            anchors.bottomMargin: mobileMenu.hhv
        }
        ScreenSettingsAdvanced {
            id: screenSettingsAdvanced
            anchors.leftMargin: Theme.screenPaddingLeft
            anchors.rightMargin: Theme.screenPaddingRight
            anchors.bottomMargin: mobileMenu.hhv
        }
        ScreenAbout {
            id: screenAbout
            anchors.leftMargin: Theme.screenPaddingLeft
            anchors.rightMargin: Theme.screenPaddingRight
            anchors.bottomMargin: mobileMenu.hhv
        }
        MobilePermissions {
            id: screenAboutPermissions
            anchors.leftMargin: Theme.screenPaddingLeft
            anchors.rightMargin: Theme.screenPaddingRight
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

        Component.onCompleted: {
            // Start on the device list or tutorial?
            if (DeviceManager.areDevicesAvailable()) {
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
            } else if (state === "ScreenTutorial") {
                appHeader.leftMenuMode = "close"
            } else {
                appHeader.leftMenuMode = "back"
            }
        }

        states: [
            State {
                name: "ScreenTutorial"
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
                PropertyChanges { target: appHeader; headerTitle: selectedDevice.deviceModel; headerSubTitle: selectedDevice.plantNameDisplay; }
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
                name: "ScreenSettings"
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
                name: "ScreenSettingsAdvanced"
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
                name: "ScreenAbout"
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
                name: "ScreenAboutPermissions"
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
        height: Theme.screenPaddingNavbar

        visible: (!mobileMenu.visible || appContent.state === "ScreenTutorial")
        opacity: Theme.isTablet ? 0.5 : 0.95

        color: {
            if (appContent.state === "ScreenTutorial") return Theme.colorHeader
            return Theme.colorBackground
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Timer {
        id: disconnectTimer
        running: false
        repeat: true
        interval: 100
        onTriggered: {
            if (!DeviceManager.areDevicesConnected()) {
                appWindow.close()
            }
        }
    }
    onClosing: (close) => {
        //console.log("onClosing(" + close + ")")

        // If BLE devices are still connected, disconnect them first
        if (DeviceManager.areDevicesConnected()) {
            DeviceManager.disconnectDevices()
            disconnectTimer.start()
            close.accepted = false
            return
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
