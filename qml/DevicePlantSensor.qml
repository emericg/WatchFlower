import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Loader {
    id: devicePlantSensor

    sourceComponent: null
    asynchronous: false

    property var currentDevice: null

    ////////

    function loadDevice(clickedDevice) {
        // set device
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.isPlantSensor) return
        if (clickedDevice === currentDevice) return
        currentDevice = clickedDevice


        // load screen
        if (!sourceComponent) {
            sourceComponent = componentDevicePlantSensor
        }
        devicePlantSensor.item.loadDevice()
    }

    ////////

    function isHistoryMode() {
        if (sourceComponent) return devicePlantSensor.item.isHistoryMode()
        return false
    }
    function resetHistoryMode() {
        if (sourceComponent) devicePlantSensor.item.resetHistoryMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentDevicePlantSensor

        Item {
            id: itemDevicePlantSensor
            width: 480
            height: 720

            focus: parent.focus

            Connections {
                target: currentDevice

                function onStatusUpdated() {
                    plantSensorData.updateHeader()
                }
                function onSensorUpdated() {
                    plantSensorData.updateHeader()
                    plantSensorCare.updateHeader()
                }
                function onSensorsUpdated() {
                    plantSensorData.updateHeader()
                    plantSensorCare.updateHeader()
                }
                function onRefreshUpdated() {
                    plantSensorData.resetHistoryMode()
                    plantSensorData.updateGraph()
                    plantSensorHistory.updateData()
                }
                function onHistoryUpdated() {
                    plantSensorData.updateGraph()
                    plantSensorHistory.updateData()
                }
            }

            Connections {
                target: settingsManager

                function onBigIndicatorChanged() {
                    plantSensorData.reloadIndicators()
                }
                function onAppLanguageChanged() {
                    plantSensorData.updateStatusText()
                    plantSensorData.updateLegendSizes()
                }
                function onGraphHistoryChanged() {
                    plantSensorHistory.updateHistoryMode()
                }
            }

            Connections {
                target: ThemeEngine
                function onCurrentThemeChanged() {
                    plantSensorData.updateHeader()
                    plantSensorHistory.updateHeader()
                    plantSensorHistory.updateColors()
                    plantSensorCare.updateHeader()
                }
            }

            Connections {
                target: appHeader

                // desktop only
                function onDeviceDataButtonClicked() {
                    appHeader.setActiveDeviceData()
                    sensorPages.currentIndex = 0
                }
                function onDeviceHistoryButtonClicked() {
                    appHeader.setActiveDeviceHistory()
                    sensorPages.currentIndex = 1
                }
                function onDevicePlantButtonClicked() {
                    appHeader.setActiveDevicePlant()
                    sensorPages.currentIndex = 2
                }
                function onDeviceSettingsButtonClicked() {
                    appHeader.setActiveDeviceSettings()
                    sensorPages.currentIndex = 3
                }
            }

            Connections {
                target: mobileMenu

                // mobile only
                function onDeviceDataButtonClicked() {
                    mobileMenu.setActiveDeviceData()
                    sensorPages.currentIndex = 0
                }
                function onDeviceHistoryButtonClicked() {
                    mobileMenu.setActiveDeviceHistory()
                    sensorPages.currentIndex = 1
                }
                function onDevicePlantButtonClicked() {
                    mobileMenu.setActiveDevicePlant()
                    sensorPages.currentIndex = 2
                }
                function onDeviceSettingsButtonClicked() {
                    mobileMenu.setActiveDeviceSettings()
                    sensorPages.currentIndex = 3
                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Left) {
                    event.accepted = true
                    if (sensorPages.currentIndex > 0)
                        sensorPages.currentIndex--
                } else if (event.key === Qt.Key_Right) {
                    event.accepted = true
                    if (sensorPages.currentIndex+1 < sensorPages.count)
                        sensorPages.currentIndex++
                } else if (event.key === Qt.Key_F5) {
                    event.accepted = true
                    deviceManager.updateDevice(currentDevice.deviceAddress)
                } else if (event.key === Qt.Key_Backspace) {
                    event.accepted = true
                    appWindow.backAction()
                }
            }

            ////////////////////////////////////////////////////////////////////////////

            function isHistoryMode() {
                return (plantSensorData.isHistoryMode() || plantSensorHistory.isHistoryMode())
            }
            function resetHistoryMode() {
                plantSensorData.resetHistoryMode()
                plantSensorHistory.resetHistoryMode()
            }

            function loadDevice() {
                //console.log("DevicePlantSensor // loadDevice() >> " + currentDevice)

                sensorPages.disableAnimation()
                sensorPages.currentIndex = 0
                sensorPages.interactive = isPhone
                sensorPages.enableAnimation()

                plantSensorData.loadData()
                plantSensorHistory.loadData()
                plantSensorHistory.updateHeader()
                plantSensorCare.loadData()
                plantSensorCare.updateHeader()
                plantSensorCare.updateLimits()

                if (isMobile) mobileMenu.setActiveDeviceData()
                if (isDesktop) appHeader.setActiveDeviceData()
            }

            ////////////////////////////////////////////////////////////////////////////

            ItemBannerSync {
                id: bannerSync
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                z: 5
            }

            Item {
                anchors.top: parent.top
                anchors.topMargin: bannerSync.visible ? bannerSync.height : 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

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
                                appHeader.setActiveDevicePlant()
                            else if (sensorPages.currentIndex === 3)
                                appHeader.setActiveDeviceSettings()
                        } else {
                            if (sensorPages.currentIndex === 0)
                                mobileMenu.setActiveDeviceData()
                            else if (sensorPages.currentIndex === 1)
                                mobileMenu.setActiveDeviceHistory()
                            else if (sensorPages.currentIndex === 2)
                                mobileMenu.setActiveDevicePlant()
                            else if (sensorPages.currentIndex === 3)
                                mobileMenu.setActiveDeviceSettings()
                        }
                    }

                    function enableAnimation() {
                        contentItem.highlightMoveDuration = 333
                    }
                    function disableAnimation() {
                        contentItem.highlightMoveDuration = 0
                    }

                    DevicePlantSensorData {
                        clip: false
                        id: plantSensorData
                    }
                    DevicePlantSensorHistory {
                        clip: true
                        id: plantSensorHistory
                    }
                    DevicePlantSensorCare {
                        clip: false
                        id: plantSensorCare
                    }
                    DevicePlantSensorSettings {
                        clip: false
                        id: plantSensorSettings
                    }
                }
            }
        }
    }
}
