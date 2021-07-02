import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceBLE.js" as UtilsDeviceBLE

Item {
    id: deviceThermometer
    width: 450
    height: 700

    property var currentDevice: null
    property alias thermoChart: graphLoader.item

    property string cccc: headerUnicolor ? Theme.colorHeaderContent : "white"

    ////////////////////////////////////////////////////////////////////////////

    Connections {
        target: currentDevice
        onSensorUpdated: { updateHeader() }
        onSensorsUpdated: { updateHeader() }
        onCapabilitiesUpdated: { updateHeader() }
        onStatusUpdated: { updateHeader() }
        onBatteryUpdated: { updateHeader() }
        onDataUpdated: {
            updateData()
        }
        onRefreshUpdated: {
            updateData()
            updateGraph()
        }
        onHistoryUpdated: {
            updateGraph()
        }
    }

    Connections {
        target: settingsManager
        onTempUnitChanged: {
            updateData()
        }
        onAppLanguageChanged: {
            updateData()
            updateStatusText()
        }
        onGraphThermometerChanged: {
            loadGraph()
        }
    }

    Connections {
        target: appHeader
        // desktop only
        onDeviceDataButtonClicked: {
            appHeader.setActiveDeviceData()
        }
        onDeviceSettingsButtonClicked: {
            appHeader.setActiveDeviceSettings()
        }
        // mobile only
        onRightMenuClicked: {
            //
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Backspace) {
            event.accepted = true;
            appWindow.backAction()
        }
    }

    ////////

    function loadDevice(clickedDevice) {
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.isThermometer) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        //console.log("DeviceThermometer // loadDevice() >> " + currentDevice)

        sensorTemp.visible = false
        heatIndex.visible = false
        sensorHygro.visible = false

        loadGraph()
        updateHeader()
        updateData()
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isThermometer) return
        //console.log("DeviceThermometer // updateHeader() >> " + currentDevice)

        // Battery level
        imageBattery.visible = (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)
        imageBattery.source = UtilsDeviceBLE.getDeviceBatteryIcon(currentDevice.deviceBattery)

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
        } else {
            sensorDisconnected.visible = false

            if (currentDevice.temperatureC >= -40) {
                sensorTemp.text = currentDevice.getTempString()
                sensorTemp.visible = true
            }
            if (currentDevice.humidity >= 0) {
                sensorHygro.text = currentDevice.humidity.toFixed(0) + "% " + qsTr("humidity")
                sensorHygro.visible = true
            }
            if (currentDevice.temperatureC >= 27 && currentDevice.humidity >= 40) {
                if (currentDevice.getHeatIndex() > (currentDevice.temperature + 1)) {
                    heatIndex.text = qsTr("feels like %1").arg(currentDevice.getHeatIndexString())
                    heatIndex.visible = true
                }
            }
        }
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isThermometer) return
        //console.log("DeviceThermometer // updateStatusText() >> " + currentDevice)

        // Status
        textStatus.text = UtilsDeviceBLE.getDeviceStatusText(currentDevice.status)

        if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE &&
            (currentDevice.isDataFresh() || currentDevice.isDataToday())) {
            if (currentDevice.lastUpdateMin <= 1)
                textStatus.text = qsTr("Synced")
            else
                textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
        }
    }

    function loadGraph() {
        var reload = !(settingsManager.graphThermometer === "lines" && graphLoader.source === "ChartPlantDataAio.qml") ||
                     !(settingsManager.graphThermometer === "minmax" && graphLoader.source === "ChartThermometerMinMax.qml")

        if (graphLoader.status != Loader.Ready || reload) {
            if (settingsManager.graphThermometer === "lines") {
                graphLoader.source = "ChartPlantDataAio.qml"
            } else {
                graphLoader.source = "ChartThermometerMinMax.qml"
            }
        }

        if (graphLoader.status == Loader.Ready) {
            thermoChart.loadGraph()
            thermoChart.updateGraph()
        }
    }
    function updateGraph() {
        if (graphLoader.status == Loader.Ready) thermoChart.updateGraph()
    }

    function isHistoryMode() {
        if (graphLoader.status == Loader.Ready) return thermoChart.isIndicator()
        return false
    }
    function resetHistoryMode() {
        if (graphLoader.status == Loader.Ready) thermoChart.resetIndicator()
    }

    ////////////////////////////////////////////////////////////////////////////

    Flow {
        anchors.fill: parent

        Rectangle {
            id: tempBox

            property int dimboxw: Math.min(deviceThermometer.width * 0.4, isPhone ? 320 : 600)
            property int dimboxh: Math.max(deviceThermometer.height * 0.333, isPhone ? 180 : 256)

            width: singleColumn ? parent.width : dimboxw
            height: singleColumn ? dimboxh: parent.height
            color: Theme.colorHeader
            z: 5

            MouseArea { anchors.fill: parent } // prevent clicks below this area

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -(appHeader.height / 2) + (imageBattery.visible ? (imageBattery.width / 2) : 0)
                spacing: 2

                ImageSvg {
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
                }

                ImageSvg {
                    id: imageBattery
                    width: isPhone ? 20 : 24
                    height: isPhone ? 32 : 36
                    rotation: 90
                    anchors.horizontalCenter: parent.horizontalCenter

                    fillMode: Image.PreserveAspectCrop
                    color: cccc
                    visible: source
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

                ImageSvg {
                    id: imageStatus
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-access_time-24px.svg"
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

                ImageSvg {
                    id: imageEditLocation
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                    color: cccc

                    opacity: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputLocationArea.containsMouse) ? 0.75 : 0
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

                        onClicked: {
                            textInputLocation.forceActiveFocus()
                            mouse.accepted = false
                        }
                        onPressed: {
                            textInputLocation.forceActiveFocus()
                            mouse.accepted = false
                        }
                    }
                }
                ImageSvg {
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

                visible: ((isDesktop || headerUnicolor) && !singleColumn)
                width: 2
                opacity: 0.33
                color: Theme.colorHeaderHighlight
            }
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: ((isDesktop || headerUnicolor) && singleColumn)
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
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
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
