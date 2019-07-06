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

import com.watchflower.theme 1.0

Rectangle {
    width: parent.width
    height: parent.height
    color: Theme.colorBackground

    Rectangle {
        id: rectangleHeader
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        color: Theme.colorBackground // to hide scrollview content

        z: 5
        height: 80

        Image {
            id: imageHeader
            width: 40
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/logo.svg"
            sourceSize: Qt.size(width, height)
        }

        Text {
            id: element
            anchors.verticalCenterOffset: 2
            anchors.left: imageHeader.right
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            text: "WatchFlower"
            color: Theme.colorText
            font.bold: true
            font.pixelSize: 22
        }
    }

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left

        Column {
            id: row
            anchors.fill: parent

            Rectangle {
                id: rectangleHome
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left
                color: (content.state === "DeviceList") ? Theme.colorForeground : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        content.state = "DeviceList"
                        drawer.close()
                    }
                }

                ImageSvg {
                    id: buttonPlantsImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/desktop/watchflower_tray_dark.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("My plants")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colorText
                }
            }

            Rectangle {
                id: rectangleSettings
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left
                color: (content.state === "Settings") ? Theme.colorForeground : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        content.state = "Settings"
                        drawer.close()
                    }
                }

                ImageSvg {
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/outline-settings-24px.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 56
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
                color: (content.state === "About") ? Theme.colorForeground : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        content.state = "About"
                        drawer.close()
                    }
                }

                ImageSvg {
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("About")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colorText
                }
            }

            Item { // spacer
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
            }
            Rectangle {
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorBordersDrawer
            }
            Item {
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
            }

            Item {
                id: rectangleRefresh
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

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
                            drawer.close()
                        }
                    }
                }

                ImageSvg {
                    id: buttonRefresh
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
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
                        onStopped: refreshAnimationStop.start()
                    }
                    NumberAnimation on rotation {
                        id: refreshAnimationStop
                        duration: 1000;
                        to: 360;
                        easing.type: Easing.Linear
                        running: false
                    }
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Refresh sensors datas")
                    font.pixelSize: 13
                    font.bold: true
                    color: deviceManager.bluetooth ? Theme.colorText : Theme.colorSubText
                }
            }

            Item {
                id: rectangleScan
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left

                enabled: deviceManager.bluetooth

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!deviceManager.scanning && !deviceManager.refreshing) {
                            deviceManager.scanDevices()
                            drawer.close()
                        }
                    }
                }

                ImageSvg {
                    id: buttonRescan
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
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
                    anchors.leftMargin: 56
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Search for new devices")
                    font.pixelSize: 13
                    font.bold: true
                    color: deviceManager.bluetooth ? Theme.colorText : Theme.colorSubText
                }
            }

            Item {
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
            }
            Rectangle {
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                color: Theme.colorBordersDrawer
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
            }
            Item {
                height: 8
                anchors.right: parent.right
                anchors.left: parent.left
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
            }

            Item {
                id: rectangleExit
                height: 48
                anchors.right: parent.right
                anchors.left: parent.left
                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                MouseArea {
                    anchors.fill: parent
                    onClicked: settingsManager.exit()
                }

                ImageSvg {
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
                    color: Theme.colorText
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 56
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
