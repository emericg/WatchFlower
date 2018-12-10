/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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

import QtQuick 2.7
import QtQuick.Controls 2.3

ApplicationWindow {
    id: applicationWindow
    color: "#E0FAE7"
    visible: true

    //width: 480
    //height: 740
    minimumWidth: 400
    minimumHeight: 640

    WindowGeometrySaver {
        window: applicationWindow
        windowName: "applicationWindow"
    }

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: header
        onMenuButtonClicked: {
            if (content.state === "DeviceList") {
                content.state = "Settings"
            } else {
                content.state = "DeviceList"
            }
        }
    }
    Connections {
        target: systrayManager
        onSettingsClicked: {
            content.state = "Settings"
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onClicked: {
            if (mouse.button === Qt.BackButton) {
                content.state = "DeviceList"
            } else if (mouse.button === Qt.ForwardButton) {
                if (curentlySelectedDevice)
                    content.state = "DeviceDetails"
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
            if (curentlySelectedDevice)
                content.state = "DeviceDetails"
        }
    }
    Item {
        focus: true
        Keys.onBackPressed: {
            if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
                if (content.state === "DeviceList") {
                    // hide windows?
                } else {
                    content.state = "DeviceList"
                }
            } else {
                content.state = "DeviceList"
            }
        }
    }
    onClosing: {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
            close.accepted = false;
        }
        if (Qt.platform.os === "osx") {
            close.accepted = false;
            applicationWindow.hide()
        }
    }

    // QML /////////////////////////////////////////////////////////////////////

    property var curentlySelectedDevice

    Header {
        id: header
        anchors.top: parent.top
        menuButtonImg.source: "qrc:/assets/menu_settings.svg"
    }

    Rectangle {
        id: content
        color: "#e0fae7"
        anchors.top: header.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        DeviceList {
            anchors.fill: parent
            id: screenDeviceList
        }
        DeviceScreen {
            anchors.fill: parent
            id: screenDeviceDetails
        }
        Settings {
            anchors.fill: parent
            id: screenSettings
        }

        state: "DeviceList"
        states: [
            State {
                name: "DeviceList"

                PropertyChanges {
                    target: header.menuButtonImg
                    source: "qrc:/assets/menu_settings.svg"
                }
                PropertyChanges {
                    target: screenDeviceList
                    visible: true
                }
                PropertyChanges {
                    target: screenDeviceDetails
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                }
            },
            State {
                name: "DeviceDetails"

                PropertyChanges {
                    target: header.menuButtonImg
                    source: "qrc:/assets/menu_back.svg"
                }
                PropertyChanges {
                    target: screenDeviceList
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceDetails
                    visible: true
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                }
                StateChangeScript {
                    name: "secondScript"
                    script: screenDeviceDetails.loadDevice()
                }
            },
            State {
                name: "Settings"

                PropertyChanges {
                    target: header.menuButtonImg
                    source: "qrc:/assets/menu_back.svg"
                }
                PropertyChanges {
                    target: screenDeviceList
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceDetails
                    myDevice: curentlySelectedDevice
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: true
                }
            }
        ]
    }
}
