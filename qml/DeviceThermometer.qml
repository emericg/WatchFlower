import QtQuick
import QtQuick.Controls

import ComponentLibrary
import WatchFlower
import DeviceUtils

Loader {
    id: deviceThermometer
    anchors.fill: parent

    property var currentDevice: null

    ////////////////////////////////////////////////////////////////////////////

    function loadDevice(clickedDevice) {
        // checks
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.isThermometer) return

        // already set?
        if (clickedDevice === currentDevice) {
            appContent.state = "DeviceThermometer"
            return
        }

        // set device
        currentDevice = clickedDevice

        // load screen
        deviceThermometer.active = true
        deviceThermometer.item.loadDevice()

        // change screen
        appContent.state = "DeviceThermometer"
    }

    function backAction() {
        if (deviceThermometer.status === Loader.Ready)
            deviceThermometer.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: false

    sourceComponent: Item {
        id: itemDeviceThermometer
        anchors.fill: parent

        focus: parent.focus

        // 1: single column (single column view or portrait tablet)
        // 2: wide mode (wide view)
        property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

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
                updateGraph()
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
                swipeBox.currentIndex = 0
            }
            function onDeviceSettingsButtonClicked() {
                appHeader.setActiveDeviceSettings()
                swipeBox.currentIndex = 1
            }
            // mobile only
            function onRightMenuClicked() {
                //
            }
        }

        Timer {
            interval: 60000
            running: visible
            repeat: true
            onTriggered: updateStatusText()
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Left) {
                event.accepted = true
                if (swipeBox.currentIndex > 0)
                    swipeBox.currentIndex--
            } else if (event.key === Qt.Key_Right) {
                event.accepted = true
                if (swipeBox.currentIndex+1 < swipeBox.count)
                    swipeBox.currentIndex++
            } else if (event.key === Qt.Key_F5) {
                event.accepted = true
                deviceManager.updateDevice(currentDevice.deviceAddress)
            } else if (event.key === Qt.Key_Backspace) {
                event.accepted = true
                backAction()
            }
        }

        ////////

        function loadDevice() {
            //console.log("DeviceThermometer // loadDevice() >> " + currentDevice)

            sensorTemp.visible = false
            sensorHygro.visible = false
            heatIndex.visible = false
            dewPoint.visible = false

            swipeBox.disableAnimation()
            swipeBox.currentIndex = 0
            swipeBox.interactive = false
            swipeBox.enableAnimation()

            // force graph reload
            graphLoader.source = ""
            graphLoader.opacity = 0
            noDataIndicator.visible = false

            loadGraph()
            updateHeader()
            updateData()
            sensorSettings.updateHeader()

            mobileMenu.setActiveDeviceData()
            appHeader.setActiveDeviceData()
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
                sensorHygro.visible = false
                heatIndex.visible = false
                dewPoint.visible = false

            } else {
                sensorDisconnected.visible = false

                if (currentDevice.hasTemperatureSensor && currentDevice.temperatureC >= -40) {
                    sensorTemp.text = currentDevice.getTempString()
                    sensorTemp.visible = true
                }

                if (currentDevice.hasHumiditySensor) {
                    if (currentDevice.humidity >= 0 && currentDevice.humidity <= 100) {
                        sensorHygro.text = currentDevice.humidity.toFixed(0) + "% " + qsTr("humidity")
                        sensorHygro.visible = true

                        if (currentDevice.temperatureC >= 27 && currentDevice.humidity >= 40) {
                            if (currentDevice.getHeatIndex() > (currentDevice.temperature + 1)) {
                                heatIndex.text = qsTr("feels like %1").arg(currentDevice.getHeatIndexString())
                                heatIndex.visible = true
                            } else {
                                heatIndex.visible = false
                            }
                        } else {
                            heatIndex.visible = false
                        }

                        if (currentDevice.deviceIsOutside) {
                            dewPoint.text = qsTr("dew point %1").arg(currentDevice.getDewPointString())
                            dewPoint.visible = true
                        }
                    }
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
            //console.log("DeviceThermometer // loadGraph() >> " + currentDevice)

            var reload = !(settingsManager.graphThermometer === "lines" && graphLoader.source === "charts/ChartPlantDataAio.qml") ||
                         !(settingsManager.graphThermometer === "minmax" && graphLoader.source === "charts/ChartThermometerMinMax.qml")

            if (reload) {
                graphLoader.source = ""
                graphLoader.opacity = 0
            }

            if (graphLoader.status !== Loader.Ready) {
                if (settingsManager.graphThermometer === "lines") {
                    graphLoader.source = "charts/ChartPlantDataAio.qml"
                } else {
                    graphLoader.source = "charts/ChartThermometerMinMax.qml"
                }
            }

            if (graphLoader.status === Loader.Ready) {
                thermoChart.loadGraph()
                thermoChart.updateGraph()
            }
        }

        function updateGraph() {
            //console.log("DeviceThermometer // updateGraph() >> " + currentDevice)

            if (graphLoader.status === Loader.Ready) thermoChart.updateGraph()
        }

        ////////

        function backAction() {
            if (swipeBox.currentIndex === 0) { // data
                if (textInputLocation.focus) {
                    textInputLocation.focus = false
                    return
                }
                if (isHistoryMode()) {
                    resetHistoryMode()
                    return
                }
            }

            if (swipeBox.currentIndex === 1) { // settings
                if (isMobile) {
                    swipeBox.currentIndex = 0
                    return
                }
            }

            screenDeviceList.loadScreen()
        }

        function isHistoryMode() {
            if (graphLoader.status === Loader.Ready) return thermoChart.isIndicator()
            return false
        }
        function resetHistoryMode() {
            if (graphLoader.status === Loader.Ready) thermoChart.resetIndicator()
        }

        ////////////////////////////////////////////////////////////////////////

        Flow {
            anchors.fill: parent

            Rectangle {
                id: headerBox

                property int dimboxw: Math.min(deviceThermometer.width * 0.4, isPhone ? 320 : 600)
                property int dimboxh: Math.max(deviceThermometer.height * 0.333, isPhone ? 180 : 256)

                width: (uiMode === 1) ? parent.width : dimboxw
                height: (uiMode === 1) ? dimboxh : parent.height

                color: Theme.colorHeader
                z: 5

                MouseArea { anchors.fill: parent } // prevent clicks below this area

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -(status.height*0.666)
                    spacing: 0

                    IconSvg {
                        id: sensorDisconnected
                        width: isMobile ? 96 : 128
                        height: isMobile ? 96 : 128
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
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
                        id: sensorHygro
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.bold: false
                        font.pixelSize: isPhone ? 22 : 24
                        color: cccc
                        opacity: 0.8
                    }

                    Item { width: 1; height: 1; } // spacer

                    Text {
                        id: heatIndex
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.bold: false
                        font.pixelSize: isPhone ? 19 : 20
                        color: cccc
                    }
                    Text {
                        id: dewPoint
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.bold: false
                        font.pixelSize: isPhone ? 18 : 19
                        color: cccc
                        opacity: 0.8
                    }

                    IconSvg {
                        id: imageBattery
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: isPhone ? 20 : 24
                        height: isPhone ? 32 : 36
                        rotation: 90

                        visible: (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)
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

                        source: "qrc:/IconLibrary/material-icons/duotone/schedule.svg"
                        color: cccc
                    }
                    Text {
                        id: textStatus
                        width: status.width - status.spacing - imageStatus.width
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Loading...")
                        textFormat: Text.PlainText
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

                        source: "qrc:/IconLibrary/material-icons/duotone/edit.svg"
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

                        source: "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"
                        color: cccc
                    }
                }

                ////////

                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    visible: !singleColumn
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

            SwipeView {
                id: swipeBox

                width: {
                    if (isTablet && screenOrientation == Qt.PortraitOrientation) return parent.width
                    return singleColumn ? parent.width : (parent.width - headerBox.width)
                }
                height: {
                    if (isTablet && screenOrientation == Qt.PortraitOrientation) return (parent.height - headerBox.height)
                    return singleColumn ? (parent.height - headerBox.height) : parent.height
                }

                interactive: false

                currentIndex: 0
                onCurrentIndexChanged: {
                    if (isDesktop) {
                        if (swipeBox.currentIndex === 0)
                            appHeader.setActiveDeviceData()
                        else if (swipeBox.currentIndex === 1)
                            appHeader.setActiveDeviceSettings()
                    }
                }

                function enableAnimation() {
                    contentItem.highlightMoveDuration = 333
                }
                function disableAnimation() {
                    contentItem.highlightMoveDuration = 0
                }

                Item {
                    ActionbarSync {
                        id: bannersync
                        z: 5
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }

                    ItemNoData {
                        id: noDataIndicator
                        visible: false
                    }

                    Loader {
                        id: graphLoader
                        anchors.top: bannersync.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        opacity: 0
                        Behavior on opacity { OpacityAnimator { duration: (graphLoader.status === Loader.Ready) ? 200 : 0 } }

                        asynchronous: true
                        onLoaded: {
                            thermoChart.loadGraph()
                            thermoChart.updateGraph()

                            graphLoader.opacity = 1
                            noDataIndicator.visible = (currentDevice.countDataNamed("temperature", thermoChart.daysVisible) < 1)
                        }
                    }
                }

                DevicePlantSensorSettings {
                    id: sensorSettings
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////
    }
}
