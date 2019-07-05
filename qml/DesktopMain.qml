/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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

import com.watchflower.theme 1.0

ApplicationWindow {
    id: applicationWindow

    width: (Qt.platform.os === "osx") ? 800 : 1280
    height: (Qt.platform.os === "osx") ? 480 : 720
    minimumWidth: 480
    minimumHeight: 480

    color: Theme.colorBackground
    visible: true // !settingsManager.minimized
    flags: Qt.Window

    // Desktop stuff

    WindowGeometrySaver {
        window: applicationWindow
        windowName: "applicationWindow"
    }

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: header
        onBackButtonClicked: {
            if (content.state !== "DeviceList") {
                content.state = "DeviceList"
            }
        }

        onDeviceRefreshButtonClicked: {
            if (currentlySelectedDevice) {
                deviceManager.updateDevice(currentlySelectedDevice.deviceAddress)
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

        onPlantsButtonClicked: content.state = "DeviceList"
        onSettingsButtonClicked: content.state = "Settings"
        onAboutButtonClicked: content.state = "About"
    }

    Connections {
        target: systrayManager
        onSettingsClicked: content.state = "Settings"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onClicked: {
            if (content.state === "Tutorial")
                return;

            if (mouse.button === Qt.BackButton) {
                content.state = "DeviceList"
            } else if (mouse.button === Qt.ForwardButton) {
                if (currentlySelectedDevice) {
                    if (!currentlySelectedDevice.hasSoilMoistureSensor())
                        content.state = "DeviceThermo"
                    else
                        content.state = "DeviceSensor"
                }
            }
        }
    }
    Shortcut {
        sequence: StandardKey.Back
        onActivated: {
            content.state = "DeviceList"
        }
    }
    Shortcut {
        sequence: StandardKey.Forward
        onActivated: {
            if (currentlySelectedDevice)
                content.state = "DeviceSensor"
        }
    }

    onClosing: {
        if (settingsManager.systray || Qt.platform.os === "osx") {
            close.accepted = false;
            applicationWindow.hide()
        }
    }

    // QML /////////////////////////////////////////////////////////////////////

    property var currentlySelectedDevice: null

    DesktopHeader {
        id: header
        width: parent.width
        anchors.top: parent.top
    }

    Item {
        id: content
        anchors.top: header.bottom
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
            header.setActiveMenu()
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
