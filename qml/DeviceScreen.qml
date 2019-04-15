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
        onDatasUpdated: rectangleDeviceDatas.updateDatas()
    }

    Connections {
        target: header
        // desktop only
        onDeviceDatasButtonClicked: {
            header.setActiveDeviceDatas()
            rectangleContent.state = "datas"
        }
        onDeviceHistoryButtonClicked: {
            header.setActiveDeviceHistory()
            rectangleContent.state = "history"
        }
        onDeviceSettingsButtonClicked: {
            header.setActiveDeviceSettings()
            rectangleContent.state = "limits"
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
        if (typeof myDevice === "undefined") return

        //console.log("DeviceScreen // loadDevice() >> " + myDevice)

        rectangleContent.state = "datas"
        miniMenu.visible = false

        rectangleDeviceDatas.loadDatas()
        rectangleDeviceLimits.updateHeader()
        rectangleDeviceLimits.updateLimits()
        rectangleDeviceLimits.updateLimitsVisibility()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: rectangleContent
        anchors.fill: parent

        ItemDeviceDatas {
            anchors.fill: parent
            id: rectangleDeviceDatas
        }
        ItemDeviceHistory {
            anchors.fill: parent
            id: rectangleDeviceHistory
        }
        DeviceScreenLimits {
            anchors.fill: parent
            id: rectangleDeviceLimits
        }

        state: "datas"
        states: [
            State {
                name: "datas"
                PropertyChanges {
                    target: rectangleDeviceDatas
                    visible: true
                }
                PropertyChanges {
                    target: rectangleDeviceHistory
                    visible: false
                }
                PropertyChanges {
                    target: rectangleDeviceLimits
                    visible: false
                }
            },
            State {
                name: "history"
                PropertyChanges {
                    target: rectangleDeviceDatas
                    visible: false
                }
                PropertyChanges {
                    target: rectangleDeviceHistory
                    visible: true
                }
                PropertyChanges {
                    target: rectangleDeviceLimits
                    visible: false
                }
            },
            State {
                name: "limits"
                PropertyChanges {
                    target: rectangleDeviceDatas
                    visible: false
                }
                PropertyChanges {
                    target: rectangleDeviceHistory
                    visible: false
                }
                PropertyChanges {
                    target: rectangleDeviceLimits
                    visible: true
                }
            }
        ]
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

            if (rectangleContent.state === "datas")
                menuLimitsText.text = qsTr("Edit limits")
            else
                menuLimitsText.text = qsTr("Show datas")

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
                        myDevice.refreshDatas()
                        miniMenu.hideMiniMenu()
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

                        if (rectangleContent.state === "datas") {
                            rectangleContent.state = "limits"
                        } else {
                            rectangleContent.state = "datas"

                            // Update color bars with new limits
                            rectangleDeviceDatas.updateDatas()
                        }
                    }
                }
            }
/*
            Rectangle {
                id: menuInfos
                height: 40
                color: "#ffffff"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: menuInfosText
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Device infos")
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 18
                }

                MouseArea {
                    id: mouseAreaDeviceInfos
                    anchors.fill: parent

                    onClicked: {
                        menuInfos.color = Theme.colorMaterialDarkGrey
                        miniMenu.hideMiniMenu()

                        if (plantPanel.visible) {
                            plantPanel.visible = false
                            devicePanel.visible = true
                        } else {
                            plantPanel.visible = true
                            devicePanel.visible = false
                        }
                    }
                }
            }
*/
        }
    }
}
