import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0

ApplicationWindow {
    id: appWindow
    flags: Qt.Window
    color: Theme.colorBackground

    property bool isDesktop: true
    property bool isMobile: false
    property bool isPhone: false
    property bool isTablet: false
    property bool isHdpi: (utilsScreen.screenDpi > 128)

    property var selectedDevice: null

    // Desktop stuff ///////////////////////////////////////////////////////////

    minimumWidth: 480
    minimumHeight: 480

    width: {
        if (settingsManager.initialSize.width > 0)
            return settingsManager.initialSize.width
        else
            return isHdpi ? 800 : 1280
    }
    height: {
        if (settingsManager.initialSize.height > 0)
            return settingsManager.initialSize.height
        else
            return isHdpi ? 480 : 720
    }
    x: settingsManager.initialPosition.width
    y: settingsManager.initialPosition.height

    WindowGeometrySaver {
        windowInstance: appWindow
        Component.onCompleted: {
            // Make sure we handle window visibility correctly
            if (startMinimized) {
                if (settingsManager.systray) visibility = ApplicationWindow.Hidden
                else visibility = ApplicationWindow.Minimized
            } else {
                visibility = settingsManager.initialVisibility
            }
        }
    }

    // Mobile stuff ////////////////////////////////////////////////////////////

    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: 0
    property int screenPaddingNotch: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    Item { // compatibility
        id: tabletMenuDevice
        signal deviceDataButtonClicked()
        signal deviceHistoryButtonClicked()
        signal deviceSettingsButtonClicked()
    }

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        //deviceManager.refreshDevices_check();
    }

    Connections {
        target: appHeader
        onBackButtonClicked: {
            if (appContent.state !== "DeviceList") {
                appContent.state = "DeviceList"
            }
        }

        onDeviceLedButtonClicked: {
            if (selectedDevice) {
                selectedDevice.actionLedBlink()
            }
        }
        onDeviceWateringButtonClicked: {
            if (selectedDevice) {
                selectedDevice.actionWatering()
            }
        }

        onDeviceClearButtonClicked: {
            if (selectedDevice) {
                popupDeleteData.open()
            }
        }
        onDeviceRefreshHistoryButtonClicked: {
            if (selectedDevice) {
                selectedDevice.refreshStartHistory()
            }
        }

        onDeviceRefreshRealtimeButtonClicked: {
            if (selectedDevice) {
                selectedDevice.refreshStartRealtime()
            }
        }
        onDeviceRefreshButtonClicked: {
            if (selectedDevice) {
                deviceManager.updateDevice(selectedDevice.deviceAddress)
            }
        }
        onRefreshButtonClicked: {
            if (!deviceManager.scanning && !deviceManager.refreshing) {
                deviceManager.refreshDevices_start()
            }
        }
        onRescanButtonClicked: {
            if (!deviceManager.scanning && !deviceManager.refreshing) {
                deviceManager.scanDevices()
            }
        }

        onPlantsButtonClicked: { appContent.state = "DeviceList" }
        onSettingsButtonClicked: { appContent.state = "Settings" }
        onAboutButtonClicked: { appContent.state = "About" }
    }

    Connections {
        target: systrayManager
        onSettingsClicked: { appContent.state = "Settings" }
    }

    Connections {
        target: Qt.application
        onStateChanged: {
            switch (Qt.application.state) {
            case Qt.ApplicationActive:
                //console.log("Qt.ApplicationActive")

                // Check if we need an 'automatic' theme change
                Theme.loadTheme(settingsManager.appTheme);

                // Check Bluetooth anyway (on macOS)
                //if (Qt.platform.os === "osx") deviceManager.checkBluetooth();

                // Needs to check if a refresh could be usefull
                deviceManager.refreshDevices_check();

                break;
            }
        }
    }

    onClosing: {
        if (settingsManager.systray || Qt.platform.os === "osx") {
            close.accepted = false;
            appWindow.hide();
        }
    }

    // User generated events handling //////////////////////////////////////////

    function backAction() {
        if (appContent.state === "Tutorial" && screenTutorial.exitTo === "DeviceList") return; // do nothing

        if (appContent.state === "DeviceList") {
            // do nothing
        } else if (appContent.state === "DevicePlantSensor") {
            if (screenDevicePlantSensor.isHistoryMode()) {
                screenDevicePlantSensor.resetHistoryMode()
            } else {
                appContent.previousStates.pop()
                appContent.state = "DeviceList"
            }
        } else if (appContent.state === "DeviceThermometer") {
            if (screenDeviceThermometer.isHistoryMode()) {
                screenDeviceThermometer.resetHistoryMode()
            } else {
                appContent.previousStates.pop()
                appContent.state = "DeviceList"
            }
        } else if (appContent.state === "DeviceEnvironmental") {
            appContent.previousStates.pop()
            appContent.state = "DeviceList"
        } else {
            appContent.previousStates.pop()
            if (appContent.previousStates.length)
                appContent.state = appContent.previousStates[appContent.previousStates.length-1]
            else
                appContent.state = "DeviceList"
        }
    }
    function forwardAction() {
        if (appContent.state === "Tutorial") return; // do nothing

        if (appContent.state === "DeviceList") {
            if (selectedDevice) {
                if (selectedDevice.deviceType === DeviceUtils.DEVICE_PLANTSENSOR)
                    appContent.state = "DevicePlantSensor"
                else if (selectedDevice.deviceType === DeviceUtils.DEVICE_THERMOMETER)
                    appContent.state = "DeviceThermometer"
                else if (selectedDevice.deviceType === DeviceUtils.DEVICE_ENVIRONMENTAL) {
                    appContent.state = "DeviceEnvironmental"
                }
            }
        }
    }
    function deselectAction() {
        if (appContent.state === "DeviceList") {
            screenDeviceList.exitSelectionMode()
        } else if (appContent.state === "DevicePlantSensor" && screenDevicePlantSensor.isHistoryMode()) {
            screenDevicePlantSensor.resetHistoryMode()
        } else if (appContent.state === "DeviceThermometer" && screenDeviceThermometer.isHistoryMode()) {
            screenDeviceThermometer.resetHistoryMode()
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 10
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onClicked: {
            if (mouse.button === Qt.BackButton) {
                backAction()
            } else if (mouse.button === Qt.ForwardButton) {
                forwardAction()
            }
        }
    }

    Shortcut {
        sequences: [StandardKey.Back, StandardKey.Backspace]
        onActivated: backAction()
    }
    Shortcut {
        sequence: StandardKey.Forward
        onActivated: forwardAction()
    }
    Shortcut {
        sequence: StandardKey.Preferences
        onActivated: appContent.state = "Settings"
    }
    Shortcut {
        sequence: StandardKey.Refresh
        onActivated: deviceManager.refreshDevices_check()
    }
    Shortcut {
        sequence: "Ctrl+F5"
        onActivated: deviceManager.refreshDevices_start()
    }
    Shortcut {
        sequences: [StandardKey.Deselect, StandardKey.Cancel]
        onActivated: deselectAction()
    }
    Shortcut {
        sequence: StandardKey.Close
        onActivated: appWindow.close()
    }
    Shortcut {
        sequence: StandardKey.Quit
        onActivated: utilsApp.appExit()
    }

    // UI sizes ////////////////////////////////////////////////////////////////

    property bool headerUnicolor: (Theme.colorHeader === Theme.colorBackground)

    property bool singleColumn: {
        if (isMobile) {
            if (screenOrientation === Qt.PortraitOrientation ||
                (isTablet && width < 480)) { // can be a 2/3 split screen on tablet
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

    DesktopHeader {
        id: appHeader
        width: parent.width
        anchors.top: parent.top
    }

    PopupDeleteData {
        id: popupDeleteData
    }

    Item {
        id: appContent
        anchors.top: appHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        Tutorial {
            anchors.fill: parent
            id: screenTutorial
        }
        DeviceList {
            anchors.fill: parent
            id: screenDeviceList
        }
        DevicePlantSensor {
            anchors.fill: parent
            id: screenDevicePlantSensor
        }
        DeviceThermometer {
            anchors.fill: parent
            id: screenDeviceThermometer
        }
        DeviceEnvironmental {
            anchors.fill: parent
            id: screenDeviceEnvironmental
        }
        Settings {
            anchors.fill: parent
            id: screenSettings
        }
        About {
            anchors.fill: parent
            id: screenAbout
        }

        // Initial state
        state: deviceManager.areDevicesAvailable() ? "DeviceList" : "Tutorial"

        property var previousStates: []

        onStateChanged: {
            appHeader.setActiveMenu()
            screenDeviceList.exitSelectionMode()

            if (previousStates[previousStates.length-1] !== state) previousStates.push(state)
            if (previousStates.length > 4) previousStates.splice(0, 1)
            //console.log("states > " + appContent.previousStates)
        }

        states: [
            State {
                name: "Tutorial"
                PropertyChanges { target: screenTutorial; enabled: true; visible: true; focus: true; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDevicePlantSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceEnvironmental; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceList"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: true; visible: true; focus: true; }
                PropertyChanges { target: screenDevicePlantSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceEnvironmental; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DevicePlantSensor"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDevicePlantSensor; enabled: true; visible: true; focus: true; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceEnvironmental; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceThermometer"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDevicePlantSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: true; visible: true; focus: true; }
                PropertyChanges { target: screenDeviceEnvironmental; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceEnvironmental"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDevicePlantSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceEnvironmental; enabled: true; visible: true; focus: true; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "Settings"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceEnvironmental; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "About"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDevicePlantSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceEnvironmental; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: true; enabled: true; focus: true; }
            }
        ]
    }
}
