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

import QtQuick 2.7
import QtQuick.Controls 2.0

import QtGraphicalEffects 1.0
import com.watchflower.theme 1.0

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

    Item {
        id: rectangleHeader
        height: 80
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

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
            color: "#4b4747"
            text: qsTr("WatchFlower")
            font.bold: true
            anchors.verticalCenterOffset: 2
            anchors.left: imageHeader.right
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 22
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

            Item {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: buttonPlantsImg
                    anchors.fill: parent
                    visible: false
                    source: "qrc:/assets/watchflower_small.svg"
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }
                ColorOverlay {
                    source: buttonPlantsImg
                    anchors.fill: parent
                    color: Theme.colorText
                    cached: true
                }
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
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    content.state = "Settings"
                    drawer.close()
                }
            }

            Item {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: buttonSettingsImg
                    anchors.fill: parent
                    visible: false
                    source: "qrc:/assets/icons_material/baseline-tune-24px.svg"
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }
                ColorOverlay {
                    source: buttonSettingsImg
                    anchors.fill: parent
                    color: Theme.colorText
                    cached: true
                }
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
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    content.state = "About"
                    drawer.close()
                }
            }

            Item {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: buttonAboutImg
                    anchors.fill: parent
                    visible: false
                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }
                ColorOverlay {
                    source: buttonAboutImg
                    anchors.fill: parent
                    color: Theme.colorText
                    cached: true
                }
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
            color: "#b3b3b3"
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

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    deviceManager.refreshDevices()
                    drawer.close()
                }
            }

            Item {
                id: buttonRefresh
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: buttonRefreshImg
                    anchors.fill: parent
                    visible: false
                    source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }
                ColorOverlay {
                    source: buttonRefreshImg
                    anchors.fill: parent
                    color: Theme.colorText
                    cached: true
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

                text: qsTr("Refresh sensors")
                font.pixelSize: 13
                font.bold: true
                color: Theme.colorText
            }
        }

        Item {
            id: rectangleScan
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    deviceManager.scanDevices()
                    drawer.close()
                }
            }

            Item {
                id: buttonRescan
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: buttonRescanImg
                    anchors.fill: parent
                    visible: false
                    source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }
                ColorOverlay {
                    anchors.fill: parent
                    source: buttonRescanImg
                    color: Theme.colorText
                    cached: true
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
                font.pixelSize: 13
                font.bold: true
                color: Theme.colorText
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
            color: "#b3b3b3"
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

            Item {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: buttonExitImg
                    anchors.fill: parent
                    visible: false
                    source: "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }
                ColorOverlay {
                    source: buttonExitImg
                    anchors.fill: parent
                    color: Theme.colorText
                    cached: true
                }
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
