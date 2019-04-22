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

import com.watchflower.theme 1.0

Item {
    id: deviceScreenSensor
    width: 450
    height: 700

    property var myDevice: curentlySelectedDevice
    property var contentState: ""

    Connections {
        target: myDevice
        onStatusUpdated: rectangleDeviceDatas.updateHeader()
        onLimitsUpdated: rectangleDeviceDatas.updateDatas()
        onDatasUpdated: {
            rectangleDeviceDatas.updateDatas()
            rectangleDeviceHistory.updateDatas()
        }
    }

    Connections {
        target: header
        // desktop only
        onDeviceDatasButtonClicked: {
            header.setActiveDeviceDatas()
            swipeView.currentIndex = 0
        }
        onDeviceHistoryButtonClicked: {
            header.setActiveDeviceHistory()
            swipeView.currentIndex = 1
        }
        onDeviceSettingsButtonClicked: {
            header.setActiveDeviceSettings()
            swipeView.currentIndex = 2
        }
        // mobile only
        onRightMenuClicked: {
            if (!miniMenu.visible)
                miniMenu.showMiniMenu()
            else
                miniMenu.hideMiniMenu()
        }
    }

    function loadDevice() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreen // loadDevice() >> " + myDevice)

        if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") header.setActiveDeviceDatas()
        swipeView.currentIndex = 0
        miniMenu.visible = false

        rectangleDeviceDatas.loadDatas()
        rectangleDeviceHistory.updateHeader()
        rectangleDeviceHistory.loadDatas()
        rectangleDeviceLimits.updateHeader()
        rectangleDeviceLimits.updateLimits()
        rectangleDeviceLimits.updateLimitsVisibility()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: rectangleContent
        anchors.fill: parent

        SwipeView {
            id: swipeView
            anchors.fill: parent
            //anchors.bottomMargin: 48

            interactive: (Qt.platform.os === "android" || Qt.platform.os === "ios")

            currentIndex: 0
            onCurrentIndexChanged: {
                if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") {
                    if (swipeView.currentIndex === 0)
                        header.setActiveDeviceDatas()
                    else if (swipeView.currentIndex === 1)
                        header.setActiveDeviceHistory()
                    else if (swipeView.currentIndex === 2)
                        header.setActiveDeviceSettings()
                }
            }

            DeviceScreenDatas {
                //anchors.fill: parent
                id: rectangleDeviceDatas
            }
            DeviceScreenHistory {
                //anchors.fill: parent
                id: rectangleDeviceHistory
            }
            DeviceScreenLimits {
                //anchors.fill: parent
                id: rectangleDeviceLimits
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: miniMenu
        width: 150
        height: 80
        color: "#ffffff"
        anchors.top: parent.top
        anchors.topMargin: -8
        anchors.right: parent.right
        anchors.rightMargin: 8

        function showMiniMenu() {
            menuRefresh.color = "#ffffff"
            menuLimits.color = "#ffffff"
            menuHistory.color = "#ffffff"

            if (!visible) {
                visible = true
                opacity = 0
                fadeIn.start()
            }
        }
        function hideMiniMenu() {
            if (visible) {
                opacity = 1
                fadeOut.start()
            }
        }

        OpacityAnimator {
            id: fadeIn
            target: miniMenu
            from: 0
            to: 1
            duration: 133
            running: true
        }
        OpacityAnimator {
            id: fadeOut
            target: miniMenu
            from: 1
            to: 0
            duration: 133
            running: true

            onStopped: {
                miniMenu.visible = false
            }
        }

        Column {
            anchors.fill: parent

            Rectangle {
                id: menuRefresh
                height: 40
                color: "#ffffff"
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: element
                    text: qsTr("Refresh")
                    verticalAlignment: Text.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    font.pixelSize: 18
                }

                MouseArea {
                    id: mouseAreaRefresh
                    anchors.fill: parent

                    onClicked: {
                        menuRefresh.color = Theme.colorMaterialDarkGrey
                        miniMenu.hideMiniMenu()

                        myDevice.refreshDatas()
                    }
                }
            }

            Rectangle {
                id: menuLimits
                height: 40
                color: "#ffffff"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: menuLimitsText
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Edit limits")
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: mouseAreaLimits
                    anchors.fill: parent

                    onClicked: {
                        menuLimits.color = Theme.colorMaterialDarkGrey
                        miniMenu.hideMiniMenu()

                        //
                    }
                }
            }

            Rectangle {
                id: menuHistory
                height: 40
                color: "#ffffff"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: menuHistoryText
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Datas history")
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 18
                }

                MouseArea {
                    id: mouseAreaDeviceInfos
                    anchors.fill: parent

                    onClicked: {
                        menuHistory.color = Theme.colorMaterialDarkGrey
                        miniMenu.hideMiniMenu()

                        //
                    }
                }
            }
        }
    }
}
