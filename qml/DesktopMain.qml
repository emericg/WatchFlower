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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import ThemeEngine 1.0

ApplicationWindow {
    id: applicationWindow
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

    flags: Qt.Window
    color: Theme.colorBackground

    property var lastUpdate
    property var selectedDevice: null

    // Mobile stuff ////////////////////////////////////////////////////////////

    property bool isDesktop: true
    property bool isMobile: false
    property bool isPhone: false
    property bool isTablet: false
    property bool isHdpi: (utilsScreen.screenDpi > 128)

    property int screenOrientation: Screen.primaryOrientation
    property int screenStatusbarPadding: 0
    property int screenNotchPadding: 0
    property int screenLeftPadding: 0
    property int screenRightPadding: 0

    Item { // compatibility
        id: tabletMenuDevice
        signal deviceDataButtonClicked()
        signal deviceHistoryButtonClicked()
        signal deviceSettingsButtonClicked()
    }

    // Desktop stuff ///////////////////////////////////////////////////////////

    WindowGeometrySaver {
        windowInstance: applicationWindow
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

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: appHeader
        onBackButtonClicked: {
            if (appContent.state !== "DeviceList") {
                appContent.state = "DeviceList"
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

                // Needs to check if a refresh could be usefull
                var rightnow = new Date()
                if (!lastUpdate || (rightnow - lastUpdate) > 5*60*1000) {
                    deviceManager.refreshDevices_check();
                    lastUpdate = rightnow;
                } else {
                    // Check Bluetooth anyway (on macOS)
                    if (Qt.platform.os === "osx") deviceManager.checkBluetooth();
                }
                break;
            }
        }
    }

    onClosing: {
        if (settingsManager.systray || Qt.platform.os === "osx") {
            close.accepted = false;
            applicationWindow.hide();
        }
    }

    // User generated events handling //////////////////////////////////////////

    function backAction() {
        if (appContent.state === "Tutorial") return; // do nothing

        if (appContent.state === "DeviceList") {
            // do nothing
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
    function forwardAction() {
        if (appContent.state === "Tutorial") return; // do nothing

        if (appContent.state === "DeviceList") {
            if (selectedDevice) {
                if (!selectedDevice.hasSoilMoistureSensor())
                    appContent.state = "DeviceThermo"
                else
                    appContent.state = "DeviceSensor"
            }
        }
    }
    function deselectAction() {
        if (appContent.state === "DeviceList") {
            screenDeviceList.exitSelectionMode()
        } else if (appContent.state === "DeviceSensor" &&
                   screenDeviceSensor.isHistoryMode()) {
            screenDeviceSensor.resetHistoryMode()
        } else if (appContent.state === "DeviceThermo" &&
                   screenDeviceThermometer.isHistoryMode()) {
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
        sequences: [StandardKey.Deselect, StandardKey.Cancel]
        onActivated: deselectAction()
    }
    Shortcut {
        sequence: StandardKey.Close
        onActivated: applicationWindow.close()
    }
    Shortcut {
        sequence: StandardKey.Quit
        onActivated: utilsApp.appExit()
    }

    // QML /////////////////////////////////////////////////////////////////////

    DesktopHeader {
        id: appHeader
        width: parent.width
        anchors.top: parent.top
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
            appHeader.setActiveMenu()
            screenDeviceList.exitSelectionMode()
        }

        states: [
            State {
                name: "Tutorial"
                PropertyChanges { target: screenTutorial; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceList"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: true; visible: true; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceSensor"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: true; visible: true; focus: true; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "DeviceThermo"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceSensor; enabled: false; visible: false }
                PropertyChanges { target: screenDeviceThermometer; enabled: true; visible: true; focus: true; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "Settings"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: true; enabled: true; }
                PropertyChanges { target: screenAbout; visible: false; enabled: false; }
            },
            State {
                name: "About"
                PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
                PropertyChanges { target: screenDeviceList; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceSensor; visible: false; enabled: false; }
                PropertyChanges { target: screenDeviceThermometer; enabled: false; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
                PropertyChanges { target: screenAbout; visible: true; enabled: true; }
            }
        ]
    }
}
