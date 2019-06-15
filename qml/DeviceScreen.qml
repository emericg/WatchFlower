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

    property var myDevice: currentlySelectedDevice
    property var contentState: ""

    Connections {
        target: myDevice
        onStatusUpdated: rectangleDeviceDatas.updateHeader()
        onSensorUpdated: rectangleDeviceDatas.updateHeader()
        onDatasUpdated: {
            rectangleDeviceDatas.updateDatas()
            rectangleDeviceHistory.updateDatas()
        }
        onLimitsUpdated: rectangleDeviceDatas.updateDatas()
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
    }

    function loadDevice() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreen // loadDevice() >> " + myDevice)

        swipeView.currentIndex = 0

        rectangleDeviceDatas.loadDatas()
        rectangleDeviceHistory.updateHeader()
        rectangleDeviceHistory.loadDatas()
        rectangleDeviceLimits.updateHeader()
        rectangleDeviceLimits.updateLimits()
        rectangleDeviceLimits.updateLimitsVisibility()

        if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") header.setActiveDeviceDatas()
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
}
