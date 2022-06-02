import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Loader {
    id: deviceThermometer

    property var currentDevice: null

    ////////

    function loadDevice(clickedDevice) {
        // set device
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.isThermometer) return
        if (clickedDevice === currentDevice) return
        currentDevice = clickedDevice

        // load screen
        deviceThermometer.active = true
        deviceThermometer.item.loadDevice()
    }

    ////////

    function backAction() {
        if (deviceThermometer.status === Loader.Ready)
            deviceThermometer.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false

    asynchronous: false
    sourceComponent: Item {
        id: itemDeviceThermometer
        width: 480
        height: 720

        focus: parent.focus

        property alias thermoChart: graphLoader.item

        property string cccc: headerUnicolor ? Theme.colorHeaderContent : "white"

        ////////

        Connections {
            target: currentDevice
            function onSensorUpdated() { updateHeader() }
            function onSensorsUpdated() { updateHeader() }
            function onCapabilitiesUpdated() { updateHeader() }
            function onStatusUpdated() { updateHeader() }
            function onDataUpdated() {
                updateData()
            }
            function onRefreshUpdated() {
                updateData()
                updateGraph()
            }
            function onHistoryUpdated() {
                updateGraph()
            }
        }

        Connections {
            target: settingsManager
            function onTempUnitChanged() {
                updateData()
            }
            function onAppLanguageChanged() {
                updateData()
                updateStatusText()
            }
            function onGraphThermometerChanged() {
                loadGraph()
            }
        }

        Connections {
            target: appHeader
            // desktop only
            function onDeviceDataButtonClicked() {
                appHeader.setActiveDeviceData()
            }
            function onDeviceSettingsButtonClicked() {
                appHeader.setActiveDeviceSettings()
            }
            // mobile only
            function onRightMenuClicked() {
                //
            }
        }

        Timer {
            interval: 60000; running: true; repeat: true;
            onTriggered: updateStatusText()
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_F5) {
                event.accepted = true
                deviceManager.updateDevice(currentDevice.deviceAddress)
            } else if (event.key === Qt.Key_Backspace) {
                event.accepted = true
                appWindow.backAction()
            }
        }

        ////////

        function loadDevice() {
            //console.log("DeviceThermometer // loadDevice() >> " + currentDevice)

            sensorTemp.visible = false
            heatIndex.visible = false
            sensorHygro.visible = false

            graphLoader.source = "" // force graph reload

            loadGraph()
            updateHeader()
            updateData()
        }

        function updateHeader() {
            if (typeof currentDevice === "undefined" || !currentDevice) return
            if (!currentDevice.isThermometer) return
            //console.log("DeviceThermometer // updateHeader() >> " + currentDevice)

            // Status
            updateStatusText()
        }

        function updateData() {
            if (typeof currentDevice === "undefined" || !currentDevice) return
            if (!currentDevice.isThermometer) return
            //console.log("DeviceThermometer // updateData() >> " + currentDevice)

            if (currentDevice.temperatureC < -40) {
                sensorDisconnected.visible = true

                sensorTemp.visible = false
                heatIndex.visible = false
                sensorHygro.visible = false
                imageBattery.visible = false

            } else {
                sensorDisconnected.visible = false

                if (currentDevice.temperatureC >= -40) {
                    sensorTemp.text = currentDevice.getTempString()
                    sensorTemp.visible = true
                }
                if (currentDevice.hasHumiditySensor && currentDevice.humidity >= 0) {
                    sensorHygro.text = currentDevice.humidity.toFixed(0) + "% " + qsTr("humidity")
                    sensorHygro.visible = true
                }
                if (currentDevice.hasHumiditySensor && currentDevice.temperatureC >= 27 && currentDevice.humidity >= 40) {
                    if (currentDevice.getHeatIndex() > (currentDevice.temperature + 1)) {
                        heatIndex.text = qsTr("feels like %1").arg(currentDevice.getHeatIndexString())
                        heatIndex.visible = true
                    } else {
                        heatIndex.visible = false
                    }
                } else {
                    heatIndex.visible = false
                }
                if (currentDevice.hasBattery && currentDevice.deviceBattery >= 0) {
                    imageBattery.visible = true
                }
            }
        }

        function updateStatusText() {
            if (typeof currentDevice === "undefined" || !currentDevice) return
            if (!currentDevice.isThermometer) return
            //console.log("DeviceThermometer // updateStatusText() >> " + currentDevice)

            // Status
            textStatus.text = UtilsDeviceSensors.getDeviceStatusText(currentDevice.status)

            if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE &&
                (currentDevice.isDataFresh_rt() || currentDevice.isDataToday())) {
                if (currentDevice.lastUpdateMin <= 1)
                    textStatus.text = qsTr("Synced")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
            }
        }

        function loadGraph() {
            var reload = !(settingsManager.graphThermometer === "lines" && graphLoader.source === "ChartPlantDataAio.qml") ||
                         !(settingsManager.graphThermometer === "minmax" && graphLoader.source === "ChartThermometerMinMax.qml")

            if (graphLoader.status !== Loader.Ready || reload) {
                if (settingsManager.graphThermometer === "lines") {
                    graphLoader.source = "ChartPlantDataAio.qml"
                } else {
                    graphLoader.source = "ChartThermometerMinMax.qml"
                }
            }

            if (graphLoader.status === Loader.Ready) {
                thermoChart.loadGraph()
                thermoChart.updateGraph()
            }
        }
        function updateGraph() {
            if (graphLoader.status === Loader.Ready) thermoChart.updateGraph()
        }

        ////////

        function backAction() {
            if (textInputLocation.focus) {
                textInputLocation.focus = false
                return
            }
            if (isHistoryMode()) {
                resetHistoryMode()
                return
            }

            appContent.state = "DeviceList"
        }

        function isHistoryMode() {
            if (graphLoader.status === Loader.Ready) return thermoChart.isIndicator()
            return false
        }
        function resetHistoryMode() {
            if (graphLoader.status === Loader.Ready) thermoChart.resetIndicator()
        }

        ////////////////////////////////////////////////////////////////////

        Flow {
            anchors.fill: parent

            Rectangle {
                id: tempBox

                property int dimboxw: Math.min(deviceThermometer.width * 0.4, isPhone ? 320 : 600)
                property int dimboxh: Math.max(deviceThermometer.height * 0.333, isPhone ? 180 : 256)

                width: singleColumn ? parent.width : dimboxw
                height: singleColumn ? dimboxh : parent.height
                color: Theme.colorHeader
                z: 5

                MouseArea { anchors.fill: parent } // prevent clicks below this area

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -(appHeader.height / 2) + (imageBattery.visible ? (imageBattery.width / 2) : 0)
                    spacing: 2

                    IconSvg {
                        id: sensorDisconnected
                        width: isMobile ? 96 : 128
                        height: isMobile ? 96 : 128
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                        color: cccc
                    }

                    Text {
                        id: sensorTemp
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.bold: false
                        font.pixelSize: isPhone ? 44 : 48
                        color: cccc
                    }

                    Text {
                        id: heatIndex
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.bold: false
                        font.pixelSize: isPhone ? 19 : 20
                        color: cccc
                    }

                    Text {
                        id: sensorHygro
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.bold: false
                        font.pixelSize: isPhone ? 22 : 24
                        color: cccc
                        opacity: 0.8
                    }

                    IconSvg {
                        id: imageBattery
                        width: isPhone ? 20 : 24
                        height: isPhone ? 32 : 36
                        rotation: 90
                        anchors.horizontalCenter: parent.horizontalCenter

                        source: UtilsDeviceSensors.getDeviceBatteryIcon(currentDevice.deviceBattery)
                        fillMode: Image.PreserveAspectCrop
                        color: cccc
                    }
                }

                ////////

                Row {
                    id: status
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: itemLocation.left
                    anchors.rightMargin: 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8

                    height: 24
                    spacing: 8

                    IconSvg {
                        id: imageStatus
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/duotone-schedule-24px.svg"
                        color: cccc
                    }
                    Text {
                        id: textStatus
                        width: status.width - status.spacing - imageStatus.width
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Loading...")
                        color: cccc
                        font.bold: false
                        font.pixelSize: 17
                        elide: Text.ElideRight
                    }
                }

                ////////

                Row {
                    id: itemLocation
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    height: 24
                    spacing: 4

                    IconSvg {
                        id: imageEditLocation
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                        color: cccc

                        opacity: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputLocationArea.containsMouse) ? 0.9 : 0
                        Behavior on opacity { OpacityAnimator { duration: 133 } }
                    }
                    TextInput {
                        id: textInputLocation
                        anchors.verticalCenter: parent.verticalCenter

                        padding: 4
                        font.pixelSize: 17
                        font.bold: false
                        color: cccc

                        text: currentDevice ? currentDevice.deviceLocationName : ""
                        onEditingFinished: {
                            currentDevice.deviceLocationName = text
                            focus = false
                        }

                        MouseArea {
                            id: textInputLocationArea
                            anchors.fill: parent
                            anchors.topMargin: -4
                            anchors.leftMargin: -24
                            anchors.rightMargin: -4
                            anchors.bottomMargin: -4

                            hoverEnabled: true
                            propagateComposedEvents: true

                            onPressed: (mouse) => {
                                textInputLocation.forceActiveFocus()
                                mouse.accepted = false
                            }
                        }
                    }
                    IconSvg {
                        id: imageLocation
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                        color: cccc
                    }
                }

                ////////

                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    width: 2
                    opacity: 0.33
                    color: Theme.colorHeaderHighlight
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    visible: singleColumn
                    height: 2
                    opacity: 0.33
                    color: Theme.colorHeaderHighlight
                }
            }

            ////////////////

            Item {
                width: singleColumn ? parent.width : (parent.width - tempBox.width)
                height: singleColumn ? (parent.height - tempBox.height) : parent.height

                ItemBannerSync {
                    id: bannersync
                    z: 5
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                ItemNoData {
                    id: noDataIndicator
                    visible: (currentDevice.countDataNamed("temperature", 14) <= 1)
                }

                Loader {
                    id: graphLoader
                    anchors.top: bannersync.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    asynchronous: true
                    onLoaded: {
                        thermoChart.loadGraph()
                        thermoChart.updateGraph()
                    }
                }
            }
        }
    }
}
