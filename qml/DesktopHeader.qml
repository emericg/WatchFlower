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

import com.watchflower.theme 1.0

Rectangle {
    id: rectangleHeader
    width: 720
    height: 64
    color: Theme.colorHeader

    signal backButtonClicked()

    signal deviceRefreshButtonClicked()
    signal deviceDatasButtonClicked()
    signal deviceSettingsButtonClicked()

    signal refreshButtonClicked()
    signal rescanButtonClicked()
    signal plantsButtonClicked()
    signal settingsButtonClicked()
    signal aboutButtonClicked()
    signal exitButtonClicked()

    function setActiveDeviceDatas() {
        menuDeviceDatas.selected = true
        menuDeviceSettings.selected = false
    }
    function setActiveDeviceSettings() {
        menuDeviceDatas.selected = false
        menuDeviceSettings.selected = true
    }

    function setActiveMenu() {

        if (content.state === "Tutorial") {
            title.text = qsTr("Welcome")
            menu.visible = false
            buttonBack.source = "qrc:/assets/menu_close.svg"
        } else {
            title.text = "WatchFlower"
            menu.visible = true
            if (content.state === "DeviceList") {
                buttonBack.source = "qrc:/assets/menu_logo.svg"
            } else {
                buttonBack.source = "qrc:/assets/menu_back.svg"
            }

            if (content.state === "DeviceDetails") {
                buttonRefreshAll.visible = false
                buttonRescan.visible = false
                menuMain.visible = false
                setActiveDeviceDatas()
            } else {
                buttonRefreshAll.visible = true
                buttonRescan.visible = true
                menuMain.visible = true

                if (content.state === "DeviceList") {
                    menuPlants.selected = true
                    menuAbout.selected = false
                    menuSettings.selected = false
                } else if (content.state == "Settings") {
                    menuPlants.selected = false
                    menuAbout.selected = false
                    menuSettings.selected = true
                } else if (content.state == "About") {
                    menuPlants.selected = false
                    menuAbout.selected = true
                    menuSettings.selected = false
                }
            }
        }
    }

    ImageSvg {
        id: buttonBack
        width: 24
        height: 24
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/watchflower.svg"
        color: Theme.colorHeaderContent

        MouseArea {
            anchors.fill: parent

            onPressed: {
                buttonBack.anchors.topMargin += 2
                buttonBack.anchors.leftMargin += 2
                buttonBack.width -= 4
                buttonBack.height -= 4
            }
            onReleased: {
                buttonBack.anchors.topMargin -= 2
                buttonBack.anchors.leftMargin -= 2
                buttonBack.width += 4
                buttonBack.height += 4
            }
            onClicked: backButtonClicked()
        }
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
            if (deviceManager.refreshing) {
                refreshAnimation.start()
                refreshAllAnimation.start()
            } else {
                refreshAnimation.stop()
                refreshAllAnimation.stop()
            }
        }
    }

    Text {
        id: title
        anchors.left: parent.left
        anchors.leftMargin: 48
        anchors.verticalCenter: parent.verticalCenter

        text: "WatchFlower"
        color: Theme.colorTitles
        font.bold: true
        font.pixelSize: 32
    }

    Row {
        id: menu
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        spacing: 8
        visible: true

        ///////

        ItemImageButton {
            id: buttonRefresh
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter
            visible: content.state == "DeviceDetails"

            source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            iconColor: Theme.colorTitles
            onClicked: deviceRefreshButtonClicked()

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

        Row {
            id: menuDevice
            spacing: 0

            ItemMenuButton {
                id: menuDeviceDatas
                width: 64
                height: 64
                visible: content.state == "DeviceDetails"
                source: "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                onClicked: deviceDatasButtonClicked()
            }
            ItemMenuButton {
                id: menuDeviceSettings
                width: 64
                height: 64
                visible: content.state == "DeviceDetails"
                source: "qrc:/assets/icons_material/baseline-iso-24px.svg"
                onClicked: deviceSettingsButtonClicked()
            }
        }

        ///////

        ItemImageButton {
            id: buttonRefreshAll
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
            iconColor: Theme.colorTitles
            onClicked: refreshButtonClicked()

            NumberAnimation on rotation {
                id: refreshAllAnimation
                duration: 2000
                from: 0
                to: 360
                loops: Animation.Infinite
                running: deviceManager.refreshing
                onStopped: refreshAllAnimationStop.start()
            }
            NumberAnimation on rotation {
                id: refreshAllAnimationStop
                duration: 1000;
                to: 360;
                easing.type: Easing.OutExpo
                running: false
            }
        }
        ItemImageButton {
            id: buttonRescan
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            iconColor: Theme.colorTitles
            onClicked: rescanButtonClicked()

            OpacityAnimator {
                id: rescanAnimation
                target: buttonRescan
                running: deviceManager.scanning
                loops: Animation.Infinite
                to: 1
                from: 0.5
                duration: 1000
            }
            OpacityAnimator {
                id: rescanAnimationStop
                target: buttonRescan
                running: false
                easing.type: Easing.OutExpo
                to: 1
                duration: 500
            }
        }

        Row {
            id: menuMain
            spacing: 0

            ItemMenuButton {
                id: menuPlants
                width: 64
                height: 64
                visible: (rectangleHeader.width > 600)
                source: "qrc:/assets/watchflower_small.svg"
                onClicked: plantsButtonClicked()
            }
            ItemMenuButton {
                id: menuSettings
                width: 64
                height: 64
                source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                onClicked: settingsButtonClicked()
            }
            ItemMenuButton {
                id: menuAbout
                width: 64
                height: 64
                source: "qrc:/assets/icons_material/outline-info-24px.svg"
                onClicked: aboutButtonClicked()
            }
        }

        ///////
/*
        ImageSvg {
            id: buttonExit
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter

            Connections {
                target: settingsManager
                onSystrayChanged: {
                    if (settingsManager.systray)
                        buttonExit.source = "qrc:/assets/icons_material/baseline-minimize-24px.svg"
                    else
                        buttonExit.source = "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
                }
            }

            source: {
                if (settingsManager.systray)
                    buttonExit.source = "qrc:/assets/icons_material/baseline-minimize-24px.svg"
                else
                    buttonExit.source = "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
            }
            color: Theme.colorTitles

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (settingsManager.systray)
                        applicationWindow.hide()
                    else
                        settingsManager.exit()
                }
            }
        }
*/
    }
}
