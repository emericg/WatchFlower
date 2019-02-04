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
import QtQuick.Controls 2.0

import QtGraphicalEffects 1.0
import app.watchflower.theme 1.0

Rectangle {
    width: parent.width
    height: parent.height
    color: "#ffffff"

    function updateDrawerFocus() {
        rectangleHome.color = "#00000000"
        rectangleSettings.color = "#00000000"
        rectangleAbout.color = "#00000000"

        if (content.state === "DeviceList")
            rectangleHome.color = Theme.colorMaterialDarkGrey
        else if (content.state === "Settings")
            rectangleSettings.color = Theme.colorMaterialDarkGrey
        else if (content.state === "About")
            rectangleAbout.color = Theme.colorMaterialDarkGrey
    }

    Connections {
        target: deviceManager
        onScanningChanged: {
            if (deviceManager.scanning)
                rescanAnimation.start()
            else
                rescanAnimation.stop()
        }
        onRefreshingChanged: {
            if (deviceManager.refreshing)
                refreshAnimation.start()
            else
                refreshAnimation.stop()
        }
    }

    Rectangle {
        id: rectangleHeader
        height: 128
        color: "#00000000"
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Image {
            id: imageHeader
            width: 256
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.top: parent.top

            source: "qrc:/assets/desktop/watchflower.svg"
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectCrop
        }
    }

    Column {
        id: row
        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.left: parent.left

        Rectangle {
            id: rectangleHome
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    content.state = "DeviceList"
                    drawer.close()
                }
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/watchflower.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Plants")
                font.pixelSize: 14
                font.bold: true
                color: Theme.colorText
            }
        }

        Rectangle {
            id: rectangleSettings
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    content.state = "Settings"
                    drawer.close()
                }
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-tune-24px.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Settings")
                font.pixelSize: 14
                font.bold: true
                color: Theme.colorText
            }
        }

        Rectangle {
            id: rectangleAbout
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    content.state = "About"
                    drawer.close()
                }
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-info-24px.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("About")
                font.pixelSize: 14
                font.bold: true
                color: Theme.colorText
            }
        }

        Rectangle { // spacer
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
        }
        Rectangle {
            height: 1
            anchors.right: parent.right
            anchors.left: parent.left
            color: Theme.colorText
        }
        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
        }

        Rectangle {
            id: rectangleRefresh
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    deviceManager.refreshDevices()
                    drawer.close()
                }
            }

            Image {
                id: buttonRefresh
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }

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
                    easing.type: Easing.OutExpo
                    running: false
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Update sensors")
                font.pixelSize: 14
                font.bold: true
                color: Theme.colorText
            }
        }

        Rectangle {
            id: rectangleScan
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    deviceManager.scanDevices()
                    drawer.close()
                }
            }

            Image {
                id: buttonRescan
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }

                OpacityAnimator {
                    id: rescanAnimation
                    target: buttonRescan
                    duration: 1000
                    from: 0.5
                    to: 1
                    loops: Animation.Infinite
                    running: deviceManager.scanning
                    onStopped: rescanAnimationStop.start()
                }
                OpacityAnimator {
                    id: rescanAnimationStop
                    target: buttonRescan
                    duration: 500
                    to: 1
                    easing.type: Easing.OutExpo
                    running: false
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Search for new devices")
                font.pixelSize: 14
                font.bold: true
                color: Theme.colorText
            }
        }

        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
            visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
        }
        Rectangle {
            height: 1
            anchors.right: parent.right
            anchors.left: parent.left
            color: Theme.colorIcons
            visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
        }
        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
            visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
        }

        Rectangle {
            id: rectangleExit
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
            visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

            MouseArea {
                anchors.fill: parent
                onClicked: settingsManager.exit()
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Exit")
                font.pixelSize: 14
                font.bold: true
                color: Theme.colorText
            }
        }
    }
}
