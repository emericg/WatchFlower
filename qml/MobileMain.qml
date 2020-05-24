/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.0
import QtQuick.Window 2.2

import ThemeEngine 1.0
import StatusBar 0.1

ApplicationWindow {
    id: applicationWindow
    minimumWidth: 400
    minimumHeight: 800

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true

    property bool isHdpi: (utilsScreen.screenDpi > 128)
    property bool isDesktop: (Qt.platform.os !== "ios" && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios" || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize >= 7.0))

    property var lastUpdate
    property var currentDevice: null

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt::PortraitOrientation, 2 = Qt::LandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation

    property int screenStatusbarPadding: 0
    property int screenNotchPadding: 0
    property int screenLeftPadding: 0
    property int screenRightPadding: 0

    onScreenOrientationChanged: handleNotches()
    Component.onCompleted: firstHandleNotches.restart()
    Timer {
        id: firstHandleNotches
        interval: 100
        repeat: false
        onTriggered: handleNotches()
    }

    function handleNotches() {
        if (Qt.platform.os !== "ios") return
        if (typeof quickWindow === "undefined" || !quickWindow) return

        var screenPadding = (Screen.height - Screen.desktopAvailableHeight)
        //console.log("screen height : " + Screen.height)
        //console.log("screen avail  : " + Screen.desktopAvailableHeight)
        //console.log("screen padding: " + screenPadding)

        var safeMargins = utilsScreen.getSafeAreaMargins(quickWindow)
        //console.log("top:" + safeMargins["top"])
        //console.log("right:" + safeMargins["right"])
        //console.log("bottom:" + safeMargins["bottom"])
        //console.log("left:" + safeMargins["left"])

        if (safeMargins["total"] !== safeMargins["top"]) {
            if (Screen.primaryOrientation === Qt.PortraitOrientation) {
                screenStatusbarPadding = 20
                screenNotchPadding = 12
            } else {
                screenStatusbarPadding = 0
                screenNotchPadding = 0
            }

            if (Screen.primaryOrientation === Qt.LandscapeOrientation) {
                // TODO left or right ???
                screenLeftPadding = 32
                screenRightPadding = 0
            } else {
                screenLeftPadding = 0
                screenRightPadding = 0
            }
        } else {
            screenStatusbarPadding = 20
            screenNotchPadding = 0
        }
/*
        console.log("RECAP screenStatusbarPadding:" + screenStatusbarPadding)
        console.log("RECAP screenNotchPadding:" + screenNotchPadding)
        console.log("RECAP screenLeftPadding:" + screenLeftPadding)
        console.log("RECAP screenRightPadding:" + screenRightPadding)
*/
    }

    StatusBar {
        theme: Theme.themeStatusbar
        color: Theme.colorStatusbar
    }

    MobileHeader {
        id: appHeader
        width: parent.width
        anchors.top: parent.top
    }

    Drawer {
        id: appDrawer
        width: (Screen.primaryOrientation === 1 || applicationWindow.width < 480) ? 0.80 * applicationWindow.width : 0.50 * applicationWindow.width
        height: applicationWindow.height

        background: Rectangle {
            Rectangle {
                x: parent.width - 1
                width: 1
                height: parent.height
                color: Theme.colorSeparator
            }
        }

        MobileDrawer { id: drawerscreen }
    }

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: appHeader
        function onLeftMenuClicked() {
            if (appContent.state === "DeviceList")
                appDrawer.open()
            else
                appContent.state = "DeviceList"
        }
        function onDeviceRefreshButtonClicked() {
            if (currentDevice) {
                deviceManager.updateDevice(currentDevice.deviceAddress)
            }
        }
        function onRightMenuClicked() {
            //
        }
    }

    Connections {
        target: Qt.application
        function onStateChanged(newstate) {
            switch (newstate) {
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
            if (appContent.state === "Tutorial") return; // do nothing

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
                if (screenDeviceSensor.isHistoryMode()) {
                    screenDeviceSensor.resetHistoryMode()
                } else {
                    appContent.state = "DeviceList"
                }
            } else if (appContent.state === "DeviceThermo") {
                if (screenDeviceThermometer.isHistoryMode()) {
                    screenDeviceThermometer.resetHistoryMode()
                } else {
                    appContent.state = "DeviceList"
                }
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

        onStateChanged: {
            screenDeviceList.exitSelectionMode()

            if (state === "DeviceList")
                appHeader.leftMenuMode = "drawer"
            else if (state === "Tutorial")
                appHeader.leftMenuMode = "close"
            else
                appHeader.leftMenuMode = "back"

            if (state === "Tutorial")
                appDrawer.interactive = false;
            else
                appDrawer.interactive = true;
        }

        states: [
            State {
                name: "Tutorial"
                PropertyChanges { target: appHeader; title: qsTr("Welcome"); }
                PropertyChanges { target: screenTutorial; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceList"
                PropertyChanges { target: appHeader; title: "WatchFlower"; }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceSensor"
                PropertyChanges { target: appHeader; title: currentDevice.deviceName; }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceThermo"
                PropertyChanges { target: appHeader; title: qsTr("Thermometer"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: true; visible: true; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "Settings"
                PropertyChanges { target: appHeader; title: qsTr("Settings"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: true; enabled: true; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "About"
                PropertyChanges { target: appHeader; title: qsTr("About"); }
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: true; enabled: true; }
            }
        ]
    }

    ////////////////

    Rectangle {
        id: appTabletMenu
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        width: parent.width
        height: isPhone ? 44 : 48
        color: isTablet ? Theme.colorTabletmenu : "transparent"

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            opacity: 0.5
            visible: isTablet
            color: Theme.colorTabletmenuContent
        }

        visible: (isTablet && appContent.state !== "Tutorial" && appContent.state !== "DeviceThermo") ||
                 (isPhone && appContent.state === "DeviceSensor" && screenOrientation === Qt.PortraitOrientation)

        Row {
            id: tabletMenuScreen
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: (applicationWindow.width >= 480) ? 24 : 0

            visible: (appContent.state === "DeviceList" ||
                      appContent.state === "Settings" ||
                      appContent.state === "About")

            ItemMenuButton {
                id: menuPlants
                imgSize: 24

                colorBackground: Theme.colorTabletmenuContent
                colorContent: Theme.colorTabletmenuHighlight
                highlightMode: "text"

                menuText: qsTr("My plants")
                selected: (appContent.state === "DeviceList")
                source: "qrc:/assets/logos/watchflower_tray_dark.svg"
                onClicked: appContent.state = "DeviceList"
            }
            ItemMenuButton {
                id: menuSettings
                imgSize: 24

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
                imgSize: 24

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
            spacing: (applicationWindow.width < 480 || (isPhone && utilsScreen.screenSize < 5.0)) ? -8 : 24

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
                imgSize: 24

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
                imgSize: 24

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
                imgSize: 24

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

    Rectangle {
        id: exitWarning
        width: exitWarningText.width + 16
        height: exitWarningText.height + 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        anchors.horizontalCenter: parent.horizontalCenter

        radius: 4
        color: Theme.colorSubText
        opacity: 0
        Behavior on opacity { OpacityAnimator { duration: 333 } }

        Text {
            id: exitWarningText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Press one more time to exit...")
            font.pixelSize: 16
            color: Theme.colorForeground
        }
    }
}
