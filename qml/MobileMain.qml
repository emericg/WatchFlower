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
    color: "white"
    visible: true

    minimumWidth: 400
    minimumHeight: 640

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint

    // Mobile stuff

    Material.theme: Material.Dark
    Material.accent: Material.LightGreen

    StatusBar {
        theme: Material.Dark
        color: Theme.colorHeaderMobileStatusbar
        //color: Material.color(Material.LightGreen, Material.Shade900)
    }

    Drawer {
        id: drawer
        width: 0.80 * applicationWindow.width
        height: applicationWindow.height

        onOpenedChanged: drawerscreen.updateDrawerFocus()
        MobileDrawer { id: drawerscreen }
    }

    // Events handling /////////////////////////////////////////////////////////

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
                } else {
                    if (content.state === "DeviceDetails" && screenDeviceDetails.content.state === "limits") {
                        screenDeviceDetails.content.state = "datas"
                    } else {
                        content.state = "DeviceList"
                    }
                }
            } else {
                content.state = "DeviceList"
            }
        }

        anchors.top: header.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        MobileDeviceList {
            anchors.fill: parent
            id: screenDeviceList
        }
        DeviceScreen {
            anchors.fill: parent
            id: screenDeviceDetails
        }
        MobileSettings {
            anchors.fill: parent
            id: screenSettings
        }
        MobileAbout {
            anchors.fill: parent
            id: screenAbout
        }

        onStateChanged: {
            drawerscreen.updateDrawerFocus()
            if (state === "DeviceList")
                header.leftMenuMode = "drawer"
            else
                header.leftMenuMode = "back"

            if (state === "DeviceDetails")
                header.rightMenuEnabled = true
            else
                header.rightMenuEnabled = false
        }

        state: "DeviceList"
        states: [
            State {
                name: "DeviceList"

                PropertyChanges {
                    target: header
                    title: "WatchFlower"
                }
                PropertyChanges {
                    target: screenDeviceList
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenDeviceDetails
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
                name: "DeviceDetails"

                PropertyChanges {
                    target: header
                    title: "WatchFlower"
                }
                PropertyChanges {
                    target: screenDeviceList
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceDetails
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
                StateChangeScript {
                    name: "secondScript"
                    script: screenDeviceDetails.loadDevice()
                }
            },
            State {
                name: "Settings"

                PropertyChanges {
                    target: header
                    title: qsTr("Settings")
                }
                PropertyChanges {
                    target: screenDeviceList
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceDetails
                    visible: false
                    enabled: false
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
                    target: screenDeviceList
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceDetails
                    visible: false
                    enabled: false
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
