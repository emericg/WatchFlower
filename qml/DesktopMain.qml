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
            return (Qt.platform.os === "osx") ? 800 : 1280
    }
    height: {
        if (settingsManager.initialSize.height > 0)
            return settingsManager.initialSize.height
        else
            return (Qt.platform.os === "osx") ? 480 : 720
    }
    x: settingsManager.initialPosition.width
    y: settingsManager.initialPosition.height

    color: Theme.colorBackground
    visible: true // !settingsManager.minimized
    flags: Qt.Window

    property var lastUpdate
    property var currentDevice: null

    // Mobile stuff ////////////////////////////////////////////////////////////

    property bool isDesktop: true
    property bool isMobile: false
    property bool isPhone: false
    property bool isTablet: false

    property int screenOrientation: Screen.primaryOrientation
    property int screenStatusbarPadding: 0
    property int screenNotchPadding: 0
    property int screenLeftPadding: 0
    property int screenRightPadding: 0

    // Desktop stuff ///////////////////////////////////////////////////////////

    WindowGeometrySaver {
        window: applicationWindow
        windowName: "applicationWindow"
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
            if (currentDevice) {
                deviceManager.updateDevice(currentDevice.deviceAddress)
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

        onPlantsButtonClicked: appContent.state = "DeviceList"
        onSettingsButtonClicked: appContent.state = "Settings"
        onAboutButtonClicked: appContent.state = "About"
    }

    Connections {
        target: systrayManager
        onSettingsClicked: appContent.state = "Settings"
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
                    lastUpdate = rightnow
                } else {
                    // Check bluetooth anyway (on macOS)
                    if (Qt.platform.os === "osx") deviceManager.checkBluetooth()
                }

                break
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 10
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onClicked: {
            if (appContent.state === "Tutorial") return; // do nothing

            if (mouse.button === Qt.BackButton) {
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
            } else if (mouse.button === Qt.ForwardButton) {
                if (appContent.state === "DeviceList") {
                    if (currentDevice) {
                        if (!currentDevice.hasSoilMoistureSensor())
                            appContent.state = "DeviceThermo"
                        else
                            appContent.state = "DeviceSensor"
                    }
                }
            }
        }
    }
    Shortcut {
        sequence: StandardKey.Back
        onActivated: {
            if (appContent.state === "Tutorial" || appContent.state === "DeviceList") return;
            appContent.state = "DeviceList"
        }
    }
    Shortcut {
        sequence: StandardKey.Forward
        onActivated: {
            if (appContent.state !== "DeviceList") return;
            if (currentDevice) {
                if (!currentDevice.hasSoilMoistureSensor())
                    appContent.state = "DeviceThermo"
                else
                    appContent.state = "DeviceSensor"
            }
        }
    }

    onClosing: {
        if (settingsManager.systray || Qt.platform.os === "osx") {
            close.accepted = false;
            applicationWindow.hide();
        }
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

                PropertyChanges {
                    target: screenTutorial
                    enabled: true
                    visible: true
                }

                PropertyChanges {
                    target: screenDeviceList
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceList"

                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }

                PropertyChanges {
                    target: screenDeviceList
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceSensor"

                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }

                PropertyChanges {
                    target: screenDeviceList
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceThermo"

                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }

                PropertyChanges {
                    target: screenDeviceList
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "Settings"

                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }

                PropertyChanges {
                    target: screenDeviceList
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: true
                    enabled: true
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "About"

                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }

                PropertyChanges {
                    target: screenDeviceList
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: true
                    enabled: true
                }
            }
        ]
    }
}
