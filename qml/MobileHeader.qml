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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.12

import ThemeEngine 1.0

Rectangle {
    id: rectangleHeaderBar
    color: Theme.colorHeader
    width: parent.width
    height: screenStatusbarPadding + screenNotchPadding + headerHeight
    z: 10

    property int headerHeight: 52
    property string title: "WatchFlower"
    property string leftMenuMode: "drawer" // drawer / back / exit

    signal leftMenuClicked()
    signal rightMenuClicked()

    signal deviceLedButtonClicked()
    signal deviceRefreshHistoryButtonClicked()
    signal deviceRefreshButtonClicked()
    signal deviceDataButtonClicked()  // compatibility
    signal deviceHistoryButtonClicked()  // compatibility
    signal deviceSettingsButtonClicked()  // compatibility

    onLeftMenuModeChanged: {
        if (leftMenuMode === "drawer")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-menu-24px.svg"
        else if (leftMenuMode === "close")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-close-24px.svg"
        else // back
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
    }

    ////////////////////////////////////////////////////////////////////////////

    // prevent clicks into this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    Item {
        anchors.fill: parent
        anchors.topMargin: screenStatusbarPadding + screenNotchPadding

        Text {
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 64
            anchors.verticalCenter: parent.verticalCenter

            text: title
            color: Theme.colorHeaderContent
            font.bold: false
            font.pixelSize: Theme.fontSizeHeader
            font.capitalization: Font.Capitalize
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            id: leftArea
            width: headerHeight
            height: headerHeight
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top

            visible: true
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
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom

            spacing: 4
            visible: true

            ////////////

            ItemImageButton {
                id: buttonThermoChart
                width: 36; height: 36;
                anchors.verticalCenter: parent.verticalCenter

                visible: (appContent.state === "DeviceThermo")
                source: (settingsManager.graphThermometer === "minmax") ? "qrc:/assets/icons_material/duotone-insert_chart_outlined-24px.svg" : "qrc:/assets/icons_material/baseline-timeline-24px.svg";
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight

                onClicked: {
                    if (settingsManager.graphThermometer === "lines")
                        settingsManager.graphThermometer = "minmax"
                    else
                        settingsManager.graphThermometer = "lines"
                }
            }
            ItemImageButton {
                id: buttonLed
                width: 36; height: 36;
                anchors.verticalCenter: parent.verticalCenter

                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasLED) && appContent.state === "DeviceSensor")
                source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight

                onClicked: deviceLedButtonClicked()
            }
            ItemImageButton {
                id: buttonRefreshHistory
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter

                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory) &&
                          ((appContent.state === "DeviceSensor") || (appContent.state === "DeviceThermo")))
                source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight
                onClicked: deviceRefreshHistoryButtonClicked()
            }
            ItemImageButton {
                id: buttonRefreshData
                width: 36; height: 36;
                anchors.verticalCenter: parent.verticalCenter

                visible: (deviceManager.bluetooth && ((appContent.state === "DeviceSensor") || (appContent.state === "DeviceThermo")))
                source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight

                onClicked: deviceRefreshButtonClicked()

                NumberAnimation on rotation {
                    id: refreshAnimation
                    duration: 2000
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    running: selectedDevice.updating
                    alwaysRunToEnd: true
                    easing.type: Easing.Linear
                }
            }
/*
            MouseArea {
                id: rightMenu
                width: headerHeight
                height: headerHeight

                visible: (appContent.state === "DeviceSensor" || appContent.state === "DeviceThermo")
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
*/
        }
    }
}
