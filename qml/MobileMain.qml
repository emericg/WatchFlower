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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

import StatusBar 0.1
import com.watchflower.theme 1.0

ApplicationWindow {
    id: applicationWindow
    minimumWidth: 400
    minimumHeight: 640

    color: "white"
    visible: true
    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint

    // Mobile stuff

    Material.theme: Material.Dark
    Material.accent: Material.LightGreen

    StatusBar {
        theme: Material.Dark
        color: Theme.colorHeaderStatusbar
    }

    Drawer {
        id: drawer
        width: 0.80 * applicationWindow.width
        height: applicationWindow.height

        onOpenedChanged: drawerscreen.updateDrawerFocus()
        MobileDrawer { id: drawerscreen }
    }

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        if (!deviceManager.areDevicesAvailable()) {
            content.state = "Tutorial"
        }
    }

    Connections {
        target: header
        onLeftMenuClicked: {
            if (content.state === "DeviceList")
                drawer.open()
            else
                content.state = "DeviceList"
        }
        onRightMenuClicked: {
            //
        }
    }
/*
    Connections {
        target: Qt.application
        onStateChanged: {
            switch (Qt.application.state) {
            case Qt.ApplicationSuspended:
                console.log("Qt.ApplicationSuspended")
                break
            case Qt.ApplicationHidden:
                console.log("Qt.ApplicationHidden")
                break
            case Qt.ApplicationActive:
                console.log("Qt.ApplicationActive")
                break
            }
        }
    }
*/
    onClosing: {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
            close.accepted = false;
        } else {
            close.accepted = false;
            applicationWindow.hide()
        }
    }

    // QML /////////////////////////////////////////////////////////////////////

    property var curentlySelectedDevice: null

    MobileHeader {
        id: header
        width: parent.width
        anchors.top: parent.top
    }

    FocusScope {
        id: content

        focus: true
        Keys.onBackPressed: {
            if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
                if (content.state === "DeviceList") {
                    // hide window?
                    //event.accepted = true;
                } else if (content.state === "Tutorial") {
                    // do nothing
                } else {
                    content.state = "DeviceList"
                }
            } else {
                content.state = "DeviceList"
            }
        }

        anchors.top: header.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        Tutorial {
            anchors.fill: parent
            id: screenTutorial
        }
        MobileDeviceList {
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
        state: "DeviceList"

        onStateChanged: {
            drawerscreen.updateDrawerFocus()

            if (state === "DeviceList")
                header.leftMenuMode = "drawer"
            else if (state === "Tutorial")
                header.leftMenuMode = "close"
            else
                header.leftMenuMode = "back"

            if (state === "Tutorial")
                drawer.interactive = false;
            else
                drawer.interactive = true;

            if (state === "DeviceSensor" || state === "DeviceThermo")
                header.rightMenuEnabled = true
            else
                header.rightMenuEnabled = false
        }

        states: [
            State {
                name: "Tutorial"

                PropertyChanges {
                    target: header
                    title: "Welcome"
                }
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
                    target: header
                    title: "WatchFlower"
                }
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
                    target: header
                    title: curentlySelectedDevice.deviceName
                }
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
                    target: header
                    title: "Thermometer"
                }
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
                    target: header
                    title: qsTr("Settings")
                }
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
                    target: header
                    title: qsTr("About")
                }
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
