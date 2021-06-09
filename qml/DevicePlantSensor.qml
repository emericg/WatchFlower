import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: devicePlantSensor
    width: 450
    height: 700

    property var currentDevice: null

    Connections {
        target: currentDevice
        onStatusUpdated: {
            plantSensorData.updateHeader()
        }
        onSensorUpdated: {
            plantSensorData.updateHeader()
            plantSensorLimits.updateHeader()
        }
        onBatteryUpdated: {
            plantSensorData.updateHeader()
            plantSensorLimits.updateHeader()
        }
        onDataUpdated: {
            plantSensorData.updateData()
            plantSensorHistory.updateData()
        }
        onLimitsUpdated: {
            plantSensorData.updateData()
        }
    }

    Connections {
        target: settingsManager

        onTempUnitChanged: {
            plantSensorData.updateData()
        }
        onBigIndicatorChanged: {
            plantSensorData.reloadIndicators()
        }
        onAppLanguageChanged: {
            plantSensorData.updateStatusText()
            plantSensorData.updateLegendSizes()
        }
        onGraphHistoryChanged: {
            plantSensorHistory.updateHistoryMode()
        }
    }

    Connections {
        target: Theme
        onCurrentThemeChanged: {
            plantSensorData.updateHeader()
            plantSensorHistory.updateHeader()
            plantSensorHistory.updateColors()
            plantSensorLimits.updateHeader()
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

    ////////////////////////////////////////////////////////////////////////////

    function isHistoryMode() {
        return plantSensorData.isHistoryMode()
    }
    function resetHistoryMode() {
        plantSensorData.resetHistoryMode()
    }

    function loadDevice(clickedDevice) {
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.hasSoilMoistureSensor) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        //console.log("DevicePlantSensor // loadDevice() >> " + currentDevice)

        sensorPages.currentIndex = 0
        sensorPages.interactive = isPhone

        plantSensorData.loadData()
        plantSensorHistory.updateHeader()
        plantSensorHistory.loadData()
        plantSensorLimits.updateHeader()
        plantSensorLimits.updateLimits()
        plantSensorLimits.updateLimitsVisibility()

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
                clip: false
                id: plantSensorData
            }
            DevicePlantSensorHistory {
                clip: true
                id: plantSensorHistory
            }
            DevicePlantSensorLimits {
                clip: false
                id: plantSensorLimits
            }
        }
    }
}
