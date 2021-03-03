import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: devicePlantSensor
    width: 450
    height: 700

    property var currentDevice: null

    property bool unicolor: (Theme.colorHeader === Theme.colorBackground)

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
            event.accepted = true
            if (sensorPages.currentIndex > 0)
                sensorPages.currentIndex--
        } else if (event.key === Qt.Key_Right) {
            event.accepted = true;
            if (sensorPages.currentIndex+1 < sensorPages.count)
                sensorPages.currentIndex++
        } else if (event.key === Qt.Key_Backspace) {
            event.accepted = true
            appWindow.backAction()
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
        //console.log("DevicePlantSensor // loadDevice() >> " + currentDevice)

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

            DevicePlantSensorData {
                clip: true
                id: rectangleDeviceData
            }
            DevicePlantSensorHistory {
                clip: true
                id: rectangleDeviceHistory
            }
            DevicePlantSensorLimits {
                clip: true
                id: rectangleDeviceLimits
            }
        }
    }
}
