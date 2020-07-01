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

import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: deviceScreenSensor
    width: 450
    height: 700

    property var currentDevice: null

    Connections {
        target: currentDevice
        onStatusUpdated: {
            rectangleDeviceData.updateHeader()
        }
        onSensorUpdated: {
            rectangleDeviceData.updateHeader()
            rectangleDeviceLimits.updateHeader()
        }
        onDataUpdated: {
            rectangleDeviceData.updateData()
            rectangleDeviceHistory.updateData()
        }
        onLimitsUpdated: {
            rectangleDeviceData.updateData()
        }
    }

    Connections {
        target: Theme
        onCurrentThemeChanged: {
            rectangleDeviceData.updateHeader()
            rectangleDeviceHistory.updateHeader()
            rectangleDeviceHistory.updateColors()
            rectangleDeviceLimits.updateHeader()
        }
    }

    Connections {
        target: appHeader
        // desktop only
        onDeviceDataButtonClicked: {
            appHeader.setActiveDeviceData()
            sensorPages.currentIndex = 0
        }
        onDeviceHistoryButtonClicked: {
            appHeader.setActiveDeviceHistory()
            sensorPages.currentIndex = 1
        }
        onDeviceSettingsButtonClicked: {
            appHeader.setActiveDeviceSettings()
            sensorPages.currentIndex = 2
        }
    }

    Connections {
        target: tabletMenuDevice
        // mobile only
        onDeviceDataButtonClicked: {
            tabletMenuDevice.setActiveDeviceData()
            sensorPages.currentIndex = 0
        }
        onDeviceHistoryButtonClicked: {
            tabletMenuDevice.setActiveDeviceHistory()
            sensorPages.currentIndex = 1
        }
        onDeviceSettingsButtonClicked: {
            tabletMenuDevice.setActiveDeviceSettings()
            sensorPages.currentIndex = 2
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Left) {
            event.accepted = true;
            if (sensorPages.currentIndex > 0)
                sensorPages.currentIndex--
        } else if (event.key === Qt.Key_Right) {
            event.accepted = true;
            if (sensorPages.currentIndex+1 < sensorPages.count)
                sensorPages.currentIndex++
        } else if (event.key === Qt.Key_Backspace) {
            event.accepted = true;
            applicationWindow.backAction()
        }
    }

    ////////

    function isHistoryMode() {
        return rectangleDeviceData.isHistoryMode()
    }
    function resetHistoryMode() {
        rectangleDeviceData.resetHistoryMode()
    }

    function loadDevice(clickedDevice) {
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.hasSoilMoistureSensor()) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        //console.log("DeviceScreen // loadDevice() >> " + currentDevice)

        sensorPages.currentIndex = 0
        sensorPages.interactive = isPhone

        rectangleDeviceData.loadData()
        rectangleDeviceHistory.updateHeader()
        rectangleDeviceHistory.loadData()
        rectangleDeviceLimits.updateHeader()
        rectangleDeviceLimits.updateLimits()
        rectangleDeviceLimits.updateLimitsVisibility()

        if (isMobile) tabletMenuDevice.setActiveDeviceData()
        if (isDesktop) appHeader.setActiveDeviceData()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        anchors.fill: parent

        SwipeView {
            id: sensorPages
            anchors.fill: parent

            //anchors.bottomMargin: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 48 : 0
            interactive: isPhone

            currentIndex: 0
            onCurrentIndexChanged: {
                if (isDesktop) {
                    if (sensorPages.currentIndex === 0)
                        appHeader.setActiveDeviceData()
                    else if (sensorPages.currentIndex === 1)
                        appHeader.setActiveDeviceHistory()
                    else if (sensorPages.currentIndex === 2)
                        appHeader.setActiveDeviceSettings()
                } else {
                    if (sensorPages.currentIndex === 0)
                        tabletMenuDevice.setActiveDeviceData()
                    else if (sensorPages.currentIndex === 1)
                        tabletMenuDevice.setActiveDeviceHistory()
                    else if (sensorPages.currentIndex === 2)
                        tabletMenuDevice.setActiveDeviceSettings()
                }
            }

            DeviceScreenData {
                clip: true
                id: rectangleDeviceData
            }
            DeviceScreenHistory {
                clip: true
                id: rectangleDeviceHistory
            }
            DeviceScreenLimits {
                clip: true
                id: rectangleDeviceLimits
            }
        }
    }
}
