import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import ThemeEngine 1.0
import MobileUI 0.1

ApplicationWindow {
    id: appWindow
    minimumWidth: 480
    minimumHeight: 960

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true

    property bool isHdpi: (utilsScreen.screenDpi > 128)
    property bool isDesktop: (Qt.platform.os !== "ios" && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios" || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize >= 7.0))

    property var lastUpdate
    property var selectedDevice: null

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt.PortraitOrientation, 2 = Qt.LandscapeOrientation
    // 4 = Qt.InvertedPortraitOrientation, 8 = Qt.InvertedLandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation
    onScreenOrientationChanged: handleNotchesTimer.restart()

    property int screenPaddingStatusbar: 0
    property int screenPaddingNotch: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    Timer {
        id: handleNotchesTimer
        interval: 33
        repeat: false
        onTriggered: handleNotches()
    }

    function handleNotches() {
/*
        console.log("handleNotches()")
        console.log("screen width : " + Screen.width)
        console.log("screen width avail  : " + Screen.desktopAvailableWidth)
        console.log("screen height : " + Screen.height)
        console.log("screen height avail  : " + Screen.desktopAvailableHeight)
        console.log("screen orientation: " + Screen.orientation)
        console.log("screen orientation (primary): " + Screen.primaryOrientation)
*/
        if (Qt.platform.os !== "ios") return
        if (typeof quickWindow === "undefined" || !quickWindow) {
            handleNotchesTimer.restart();
            return;
        }

        // Statusbar text color hack (iOS)
        mobileUI.statusbarTheme = (Theme.themeStatusbar === 0) ? 1 : 0
        mobileUI.statusbarTheme = Theme.themeStatusbar

        // Margins
        var safeMargins = utilsScreen.getSafeAreaMargins(quickWindow)
        if (safeMargins["total"] === safeMargins["top"]) {
            screenPaddingStatusbar = safeMargins["top"]
            screenPaddingNotch = 0
            screenPaddingLeft = 0
            screenPaddingRight = 0
            screenPaddingBottom = 0
        } else if (safeMargins["total"] > 0) {
            if (Screen.orientation === Qt.PortraitOrientation) {
                screenPaddingStatusbar = 20
                screenPaddingNotch = 12
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 6
            } else if (Screen.orientation === Qt.InvertedPortraitOrientation) {
                screenPaddingStatusbar = 12
                screenPaddingNotch = 20
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 6
            } else if (Screen.orientation === Qt.LandscapeOrientation) {
                screenPaddingStatusbar = 0
                screenPaddingNotch = 0
                screenPaddingLeft = 32
                screenPaddingRight = 0
                screenPaddingBottom = 0
            } else if (Screen.orientation === Qt.InvertedLandscapeOrientation) {
                screenPaddingStatusbar = 0
                screenPaddingNotch = 0
                screenPaddingLeft = 0
                screenPaddingRight = 32
                screenPaddingBottom = 0
            } else {
                screenPaddingStatusbar = 0
                screenPaddingNotch = 0
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 0
            }
        } else {
            screenPaddingStatusbar = 0
            screenPaddingNotch = 0
            screenPaddingLeft = 0
            screenPaddingRight = 0
            screenPaddingBottom = 0
        }
/*
        console.log("total:" + safeMargins["total"])
        console.log("top:" + safeMargins["top"])
        console.log("left:" + safeMargins["left"])
        console.log("right:" + safeMargins["right"])
        console.log("bottom:" + safeMargins["bottom"])

        console.log("RECAP screenPaddingStatusbar:" + screenPaddingStatusbar)
        console.log("RECAP screenPaddingNotch:" + screenPaddingNotch)
        console.log("RECAP screenPaddingLeft:" + screenPaddingLeft)
        console.log("RECAP screenPaddingRight:" + screenPaddingRight)
        console.log("RECAP screenPaddingBottom:" + screenPaddingBottom)
*/
    }

    MobileUI {
        id: mobileUI
        property var isLoading: true

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
        width: appWindow.width
        anchors.top: appWindow.top
    }

    MobileDrawer {
        id: appDrawer
        width: (appWindow.screenOrientation === Qt.PortraitOrientation || appWindow.width < 480) ? 0.8 * appWindow.width : 0.5 * appWindow.width
        height: appWindow.height
    }

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        handleNotchesTimer.restart()
        mobileUI.isLoading = false
    }

    Connections {
        target: appHeader
        onLeftMenuClicked: {
            if (appContent.state === "DeviceList") {
                appDrawer.open()
            } else {
                if (appContent.state === "Tutorial")
                    appContent.state = screenTutorial.exitTo
                else if (appContent.state === "Permissions")
                    appContent.state = "About"
                else
                    appContent.state = "DeviceList"
            }
        }
        onDeviceLedButtonClicked: {
            if (selectedDevice) {
                selectedDevice.ledActionStart()
            }
        }
        onDeviceRefreshHistoryButtonClicked: {
            if (selectedDevice) {
                selectedDevice.refreshHistoryStart()
            }
        }
        onDeviceRefreshButtonClicked: {
            if (selectedDevice) {
                deviceManager.updateDevice(selectedDevice.deviceAddress)
            }
        }
        onRightMenuClicked: {
            //
        }
    }

    Connections {
        target: Qt.application
        onStateChanged: {
            switch (Qt.application.state) {
            case Qt.ApplicationSuspended:
                //console.log("Qt.ApplicationSuspended")
                deviceManager.refreshDevices_stop();
                break;
            case Qt.ApplicationHidden:
                //console.log("Qt.ApplicationHidden")
                deviceManager.refreshDevices_stop();
                break;
            case Qt.ApplicationInactive:
                //console.log("Qt.ApplicationInactive")
                break;
            case Qt.ApplicationActive:
                //console.log("Qt.ApplicationActive")

                // Check if we need an 'automatic' theme change
                Theme.loadTheme(settingsManager.appTheme);

                // Refresh
                deviceManager.refreshDevices_check();
/*
                // Needs to check if a refresh could be usefull
                var rightnow = new Date()
                if (!lastUpdate || (rightnow - lastUpdate) > 1*60*1000) {
                    deviceManager.refreshDevices_check();
                    lastUpdate = rightnow
                }
*/
                break;
            }
        }
    }

    Timer {
        id: exitTimer
        interval: 3000
        running: false
        repeat: false
        onRunningChanged: exitWarning.opacity = running
    }

    // QML /////////////////////////////////////////////////////////////////////

    FocusScope {
        id: appContent
        anchors.top: appHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: appTabletMenu.visible ? appTabletMenu.height : 0
        anchors.left: parent.left

        focus: true
        Keys.onBackPressed: {
            if (appContent.state === "Tutorial" && screenTutorial.exitTo === "DeviceList") return; // do nothing

            if (appContent.state === "DeviceList") {
                if (screenDeviceList.selectionList.length !== 0) {
                    screenDeviceList.exitSelectionMode()
                } else {
                    if (exitTimer.running)
                        Qt.quit()
                    else
                        exitTimer.start()
                }
            } else if (appContent.state === "DeviceSensor") {
                if (appHeader.rightMenuIsOpen()) {
                    appHeader.rightMenuClose()
                } else if (screenDeviceSensor.isHistoryMode()) {
                    screenDeviceSensor.resetHistoryMode()
                } else {
                    appContent.state = "DeviceList"
                }
            } else if (appContent.state === "DeviceThermo") {
                if (appHeader.rightMenuIsOpen()) {
                    appHeader.rightMenuClose()
                } else if (screenDeviceThermometer.isHistoryMode()) {
                    screenDeviceThermometer.resetHistoryMode()
                } else {
                    appContent.state = "DeviceList"
                }
            } else if (appContent.state === "Permissions") {
                appContent.state = "About"
            } else if (appContent.state === "Tutorial") {
                appContent.state = screenTutorial.exitTo
            } else {
                appContent.state = "DeviceList"
            }
        }

        Tutorial {
            anchors.fill: parent
            id: screenTutorial
        }
        DeviceList {
            anchors.fill: parent
            id: screenDeviceList
        }
        DeviceScreen {
            anchors.fill: parent
            id: screenDeviceSensor
        }
        DeviceThermometer {
            anchors.fill: parent
            id: screenDeviceThermometer
        }
        DeviceGeiger {
            anchors.fill: parent
            id: screenDeviceGeiger
        }
        Settings {
            anchors.fill: parent
            id: screenSettings
        }
        Permissions {
            anchors.fill: parent
            id: screenPermissions
        }
        About {
            anchors.fill: parent
            id: screenAbout
        }

        // Initial state
        state: deviceManager.areDevicesAvailable() ? "DeviceList" : "Tutorial"

        onStateChanged: {
            screenDeviceList.exitSelectionMode()

            if (state === "DeviceList")
                appHeader.leftMenuMode = "drawer"
            else if (state === "Tutorial")
                appHeader.leftMenuMode = "close"
            else
                appHeader.leftMenuMode = "back"

            if (state === "Tutorial")
                appDrawer.interactive = false
            else
                appDrawer.interactive = true
        }

        states: [
            State {
                name: "Tutorial"
                PropertyChanges { target: appHeader; title: qsTr("Welcome"); }
                PropertyChanges { target: screenTutorial; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceGeiger; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceList"
                PropertyChanges { target: appHeader; title: "WatchFlower"; }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceGeiger; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceSensor"
                PropertyChanges { target: appHeader; title: selectedDevice.deviceName; }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceGeiger; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceThermo"
                PropertyChanges { target: appHeader; title: qsTr("Thermometer"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceGeiger; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceGeiger"
                PropertyChanges { target: appHeader; title: qsTr("Geiger Counter"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceGeiger; enabled: true; visible: true; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "Settings"
                PropertyChanges { target: appHeader; title: qsTr("Settings"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceGeiger; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: true; enabled: true; }
                PropertyChanges { target: screenPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "Permissions"
                PropertyChanges { target: appHeader; title: qsTr("Permissions"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceGeiger; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenPermissions; visible: true; enabled: true; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "About"
                PropertyChanges { target: appHeader; title: qsTr("About"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceGeiger; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenPermissions; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: true; enabled: true; }
            }
        ]
    }

    ////////////////

    Rectangle {
        id: appTabletMenu
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        property int hhh: (isPhone ? 40 : 48)

        height: hhh + screenPaddingBottom
        color: isTablet ? Theme.colorTabletmenu : "transparent"

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            opacity: 0.5
            visible: isTablet
            color: Theme.colorTabletmenuContent
        }

        // prevent clicks below this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        visible: (isTablet && appContent.state !== "Tutorial" && appContent.state !== "DeviceThermo") ||
                 (isPhone && appContent.state === "DeviceSensor" && screenOrientation === Qt.PortraitOrientation)

        Row {
            id: tabletMenuScreen
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -screenPaddingBottom
            spacing: (appWindow.width >= 480) ? 24 : 0

            visible: (appContent.state === "DeviceList" ||
                      appContent.state === "Settings" ||
                      appContent.state === "About")

            ItemMenuButton {
                id: menuPlants
                imgSize: isPhone ? 20 : 24

                colorBackground: Theme.colorTabletmenuContent
                colorContent: Theme.colorTabletmenuHighlight
                highlightMode: "text"

                menuText: qsTr("Sensors")
                selected: (appContent.state === "DeviceList")
                source: "qrc:/assets/logos/watchflower_tray_dark.svg"
                onClicked: appContent.state = "DeviceList"
            }
            ItemMenuButton {
                id: menuSettings
                imgSize: isPhone ? 20 : 24

                colorBackground: Theme.colorTabletmenuContent
                colorContent: Theme.colorTabletmenuHighlight
                highlightMode: "text"

                menuText: qsTr("Settings")
                selected: (appContent.state === "Settings")
                source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                onClicked: appContent.state = "Settings"
            }
            ItemMenuButton {
                id: menuAbout
                imgSize: isPhone ? 20 : 24

                colorBackground: Theme.colorTabletmenuContent
                colorContent: Theme.colorTabletmenuHighlight
                highlightMode: "text"

                menuText: qsTr("About")
                selected: (appContent.state === "About")
                source: "qrc:/assets/icons_material/outline-info-24px.svg"
                onClicked: appContent.state = "About"
            }
        }

        Row {
            id: tabletMenuDevice
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -screenPaddingBottom
            spacing: (appWindow.width < 480 || (isPhone && utilsScreen.screenSize < 5.0)) ? -8 : 24

            signal deviceDataButtonClicked()
            signal deviceHistoryButtonClicked()
            signal deviceSettingsButtonClicked()

            visible: (appContent.state === "DeviceSensor")

            function setActiveDeviceData() {
                menuDeviceData.selected = true
                menuDeviceHistory.selected = false
                menuDeviceSettings.selected = false
            }
            function setActiveDeviceHistory() {
                menuDeviceData.selected = false
                menuDeviceHistory.selected = true
                menuDeviceSettings.selected = false
            }
            function setActiveDeviceSettings() {
                menuDeviceData.selected = false
                menuDeviceHistory.selected = false
                menuDeviceSettings.selected = true
            }

            ItemMenuButton {
                id: menuDeviceData
                imgSize: isPhone ? 20 : 24

                colorBackground: Theme.colorTabletmenuContent
                colorContent: Theme.colorTabletmenuHighlight
                highlightMode: "text"

                menuText: qsTr("Data")
                selected: (appContent.state === "DeviceSensor" && appContent.state === "DeviceList")
                source: "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                onClicked: tabletMenuDevice.deviceDataButtonClicked()
            }
            ItemMenuButton {
                id: menuDeviceHistory
                imgSize: isPhone ? 20 : 24

                colorBackground: Theme.colorTabletmenuContent
                colorContent: Theme.colorTabletmenuHighlight
                highlightMode: "text"

                menuText: qsTr("History")
                selected: (appContent.state === "About")
                source: "qrc:/assets/icons_material/baseline-date_range-24px.svg"
                onClicked: tabletMenuDevice.deviceHistoryButtonClicked()
            }
            ItemMenuButton {
                id: menuDeviceSettings
                imgSize: isPhone ? 20 : 24

                colorBackground: Theme.colorTabletmenuContent
                colorContent: Theme.colorTabletmenuHighlight
                highlightMode: "text"

                menuText: qsTr("Settings")
                selected: (appContent.state === "About")
                source: "qrc:/assets/icons_material/baseline-iso-24px.svg"
                onClicked: tabletMenuDevice.deviceSettingsButtonClicked()
            }
        }
    }

    ////////////////

    Text {
        id: exitWarning
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        anchors.horizontalCenter: parent.horizontalCenter

        visible: opacity
        opacity: 0
        Behavior on opacity { OpacityAnimator { duration: 333 } }

        text: qsTr("Press one more time to exit...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorForeground

        Rectangle {
            anchors.fill: parent
            anchors.margins: -8
            z: -1
            radius: 4
            color: Theme.colorSubText
        }
    }
}
