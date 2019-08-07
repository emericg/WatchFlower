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

import QtQuick 2.9

import com.watchflower.theme 1.0

Rectangle {
    width: parent.width
    height: screenStatusbarPadding + screenNotchPadding + headerHeight
    color: Theme.colorHeader
    z: 10

    property int headerHeight: 52

    property string title: "WatchFlower"
    property string leftMenuMode: "drawer" // drawer / back / exit

    signal leftMenuClicked()
    signal rightMenuClicked()
    signal deviceRefreshButtonClicked()

    onLeftMenuModeChanged: {
        if (leftMenuMode === "drawer")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-menu-24px.svg"
        else if (leftMenuMode === "close")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-close-24px.svg"
        else // back
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: screenStatusbarPadding + screenNotchPadding

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 64
            anchors.verticalCenter: parent.verticalCenter

            text: title
            color: Theme.colorHeaderContent
            font.bold: false
            font.pixelSize: Theme.fontSizeHeader
            font.capitalization: Font.Capitalize
        }

        MouseArea {
            id: leftArea
            width: headerHeight
            height: headerHeight
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            onClicked: leftMenuClicked()

            ImageSvg {
                id: leftMenuImg
                width: headerHeight/2
                height: headerHeight/2
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                color: Theme.colorHeaderContent
            }
        }

        Row {
            id: menu
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 8

            spacing: 0
            visible: true

            ////////////

            MouseArea {
                id: refreshButton
                width: headerHeight
                height: headerHeight

                visible: (deviceManager.bluetooth && ((appContent.state === "DeviceSensor") || (appContent.state === "DeviceThermo")))
                onClicked: deviceRefreshButtonClicked()

                ImageSvg {
                    id: refreshButtonImg
                    width: headerHeight/2
                    height: headerHeight/2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
                    color: Theme.colorHeaderContent

                    NumberAnimation on rotation {
                        id: refreshAnimation
                        duration: 2000
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        running: currentDevice.updating
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
            }

            MouseArea {
                id: rightMenu
                width: headerHeight
                height: headerHeight

                visible: false // (appContent.state === "DeviceSensor" || appContent.state === "DeviceThermo")
                onClicked: rightMenuClicked()

                ImageSvg {
                    id: rightMenuImg
                    width: headerHeight/2
                    height: headerHeight/2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-more_vert-24px.svg"
                    color: Theme.colorHeaderContent
                }
            }
        }
    }
}
