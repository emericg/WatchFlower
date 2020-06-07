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

import ThemeEngine 1.0

Item {
    width: parent.width
    height: parent.height

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: rectangleHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 5

        Connections {
            target: applicationWindow
            onScreenStatusbarPaddingChanged: rectangleHeader.updateIOSHeader()
        }
        Connections {
            target: Theme
            onCurrentThemeChanged: rectangleHeader.updateIOSHeader()
        }

        function updateIOSHeader() {
            if (Qt.platform.os === "ios") {
                if (screenStatusbarPadding != 0 && Theme.currentTheme === ThemeEngine.THEME_NIGHT)
                    rectangleStatusbar.height = screenStatusbarPadding
                else
                    rectangleStatusbar.height = 0
            }
        }

        ////////

        Rectangle {
            id: rectangleStatusbar
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.colorBackground // "red" // to hide scrollview content
            height: screenStatusbarPadding
        }
        Rectangle {
            id: rectangleNotch
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.colorBackground // "yellow" // to hide scrollview content
            height: screenNotchPadding
        }
        Rectangle {
            id: rectangleLogo
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            color: Theme.colorBackground
            height: 80

            Image {
                id: imageHeader
                width: 40
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/logos/logo.svg"
                sourceSize: Qt.size(width, height)
            }
            Text {
                id: textHeader
                anchors.left: imageHeader.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2

                text: "WatchFlower"
                color: Theme.colorText
                font.bold: true
                font.pixelSize: 22
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: rectangleHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        ////////

        Column {
            anchors.fill: parent

            Rectangle {
                id: rectangleHome
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                color: (appContent.state === "DeviceList") ? Theme.colorForeground : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        appContent.state = "DeviceList"
                        appDrawer.close()
                    }
                }

                ImageSvg {
                    id: buttonPlantsImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/logos/watchflower_tray_dark.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("My plants")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colorText
                }
            }

            ////////

            Rectangle {
                id: rectangleSettings
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                color: (appContent.state === "Settings") ? Theme.colorForeground : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        appContent.state = "Settings"
                        appDrawer.close()
                    }
                }

                ImageSvg {
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/outline-settings-24px.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Settings")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colorText
                }
            }

            Rectangle {
                id: rectangleAbout
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left
                color: (appContent.state === "About") ? Theme.colorForeground : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        appContent.state = "About"
                        appDrawer.close()
                    }
                }

                ImageSvg {
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("About")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colorText
                }
            }

            ////////

            Item { // spacer
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
            }
            Rectangle {
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorSeparator
            }
            Item {
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
            }

            ////////

            Item {
                id: rectangleRefresh
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                enabled: deviceManager.bluetooth

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!deviceManager.scanning) {
                            if (deviceManager.refreshing) {
                                deviceManager.refreshDevices_stop()
                            } else {
                                deviceManager.refreshDevices_start()
                            }
                            appDrawer.close()
                        }
                    }
                }

                ImageSvg {
                    id: buttonRefresh
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                    color: deviceManager.bluetooth ? Theme.colorText : Theme.colorSubText

                    NumberAnimation on rotation {
                        id: refreshAnimation
                        duration: 2000
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        running: deviceManager.refreshing
                        alwaysRunToEnd: true
                        easing.type: Easing.Linear
                    }
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Refresh sensors data")
                    font.pixelSize: 13
                    font.bold: true
                    color: deviceManager.bluetooth ? Theme.colorText : Theme.colorSubText
                }
            }

            ////////

            Item {
                id: rectangleRescan
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right

                enabled: deviceManager.bluetooth

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!deviceManager.scanning && !deviceManager.refreshing) {
                            deviceManager.scanDevices()
                            appDrawer.close()
                        }
                    }
                }

                ImageSvg {
                    id: buttonRescan
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                    color: deviceManager.bluetooth ? Theme.colorText : Theme.colorSubText

                    SequentialAnimation on opacity {
                        id: rescanAnimation
                        loops: Animation.Infinite
                        running: deviceManager.scanning
                        onStopped: buttonRescan.opacity = 1;

                        PropertyAnimation { to: 0.33; duration: 750; }
                        PropertyAnimation { to: 1; duration: 750; }
                    }
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Search for new devices")
                    font.pixelSize: 13
                    font.bold: true
                    color: deviceManager.bluetooth ? Theme.colorText : Theme.colorSubText
                }
            }

            ////////

            Item { // spacer
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
                visible: isDesktop
            }
            Rectangle {
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorSeparator
                visible: isDesktop
            }
            Item {
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
                visible: isDesktop
            }

            ////////

            Item {
                id: rectangleExit
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                visible: isDesktop

                MouseArea {
                    anchors.fill: parent
                    onClicked: utilsApp.appExit()
                }

                ImageSvg {
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-exit_to_app-24px.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: screenLeftPadding + 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Exit")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colorText
                }
            }
        }
    }
}
