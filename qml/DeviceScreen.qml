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

Item {
    id: deviceScreenSensor
    width: 450
    height: 700

    property var myDevice: currentDevice

    Connections {
        target: myDevice
        onStatusUpdated: {
            rectangleDeviceDatas.updateHeader()
        }
        onSensorUpdated: {
            rectangleDeviceDatas.updateHeader()
            rectangleDeviceLimits.updateHeader()
        }
        onDatasUpdated: {
            rectangleDeviceDatas.updateDatas()
            rectangleDeviceHistory.updateDatas()
        }
        onLimitsUpdated: {
            rectangleDeviceDatas.updateDatas()
        }
    }

    Connections {
        target: settingsManager
        onAppThemeChanged: {
            rectangleDeviceDatas.updateHeader()
            rectangleDeviceHistory.updateHeader()
            rectangleDeviceHistory.updateColors()
            rectangleDeviceLimits.updateHeader()
        }
    }

    Connections {
        target: appHeader
        // desktop only
        onDeviceDatasButtonClicked: {
            appHeader.setActiveDeviceDatas()
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
        onDeviceDatasButtonClicked: {
            tabletMenuDevice.setActiveDeviceDatas()
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

    function loadDevice() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreen // loadDevice() >> " + myDevice)

        sensorPages.currentIndex = 0

        rectangleDeviceDatas.loadDatas()
        rectangleDeviceHistory.updateHeader()
        rectangleDeviceHistory.loadDatas()
        rectangleDeviceLimits.updateHeader()
        rectangleDeviceLimits.updateLimits()
        rectangleDeviceLimits.updateLimitsVisibility()

        isMobile ? tabletMenuDevice.setActiveDeviceDatas() : appHeader.setActiveDeviceDatas()
    }

    function isHistoryMode() {
        return rectangleDeviceDatas.dataBarsHistory
    }
    function resetHistoryMode() {
        rectangleDeviceDatas.resetHistoryMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        anchors.fill: parent

        SwipeView {
            id: sensorPages
            anchors.fill: parent

            //anchors.bottomMargin: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 48 : 0
            interactive: isMobile

            currentIndex: 0
            onCurrentIndexChanged: {
                if (isDesktop) {
                    if (sensorPages.currentIndex === 0)
                        appHeader.setActiveDeviceDatas()
                    else if (sensorPages.currentIndex === 1)
                        appHeader.setActiveDeviceHistory()
                    else if (sensorPages.currentIndex === 2)
                        appHeader.setActiveDeviceSettings()
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
}
