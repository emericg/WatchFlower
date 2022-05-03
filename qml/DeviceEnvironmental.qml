import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Loader {
    id: deviceEnvironmental

    sourceComponent: null
    asynchronous: false

    property var currentDevice: null

    ////////

    function loadDevice(clickedDevice) {
        // set device
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.isEnvironmentalSensor) return
        if (clickedDevice === currentDevice) return
        currentDevice = clickedDevice

        // load screen
        if (!sourceComponent) {
            sourceComponent = componentDeviceEnvironmental
        }
        deviceEnvironmental.item.loadDevice()
    }

    ////////

    function isHistoryMode() {
        if (sourceComponent) return deviceEnvironmental.item.isHistoryMode()
        return false
    }
    function resetHistoryMode() {
        if (sourceComponent) deviceEnvironmental.item.resetHistoryMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentDeviceEnvironmental

        Item {
            id: itemDeviceEnvironmental
            width: 480
            height: 720

            focus: parent.focus

            property bool isAirMonitor: false
            property bool isWeatherStation: false
            property bool isGeigerCounter: false

            property string primary: "voc"

            property string cccc: headerUnicolor ? Theme.colorHeaderContent : "white"

            property var historyChart: chartEnvLoader.item

            ////////////////////////////////////////////////////////////////////////////

            Connections {
                target: currentDevice
                function onSensorUpdated() { updateHeader() }
                function onSensorsUpdated() { updateHeader() }
                function onCapabilitiesUpdated() { updateHeader() }
                function onStatusUpdated() { updateHeader() }
                function onDataUpdated() {
                    updateHeader()
                    updateData()
                }
                function onRefreshUpdated() {
                    updateHeader()
                    updateData()
                    updateGraph()
                }
                function onHistoryUpdated() {
                    updateHeader()
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

            onPrimaryChanged: {
                currentDevice.setSetting("primary", primary)
                loadIndicator()
                if (chartEnvLoader.status == Loader.Ready) historyChart.updateGraph()
            }

            ////////

            function isHistoryMode() {
                return false
            }
            function resetHistoryMode() {
                return
            }

            ////////

            function loadDevice() {
                //console.log("DeviceEnvironmental // loadDevice() >> " + currentDevice)

                if (currentDevice.hasSetting("primary")) {
                    primary = currentDevice.getSetting("primary")
                } else {
                    if (currentDevice.hasVocSensor) primary = "voc"
                    else if (currentDevice.hasCo2Sensor) primary = "co2"
                    else if (currentDevice.hasPM10Sensor) primary = "pm10"
                    else if (currentDevice.hasHchoSensor) primary = "hcho"
                    else if (currentDevice.hasGeigerCounter) primary = "nuclear"
                    else primary = "hygrometer"
                }

                //
                if (currentDevice.hasPM1Sensor || currentDevice.hasPM25Sensor || currentDevice.hasPM10Sensor ||
                    currentDevice.hasO2Sensor || currentDevice.hasO3Sensor ||
                    currentDevice.hasCoSensor || currentDevice.hasCo2Sensor ||
                    currentDevice.hasNo2Sensor || currentDevice.hasSo2Sensor ||
                    currentDevice.hasVocSensor || currentDevice.hasHchoSensor) {
                    isAirMonitor = true
                } else {
                    isAirMonitor = false
                }
                //
                isGeigerCounter = currentDevice.hasGeigerCounter
                //
                if (currentDevice.hasTemperatureSensor || currentDevice.hasHumiditySensor ||
                    currentDevice.hasPressureSensor ||
                    currentDevice.hasLuminositySensor || currentDevice.hasUvSensor ||
                    currentDevice.hasSoundSensor ||
                    currentDevice.hasWaterLevelSensor ||
                    currentDevice.hasWindDirectionSensor || currentDevice.hasWindSpeedSensor) {
                    isWeatherStation = true
                } else {
                    isWeatherStation = false
                }

                // demo?
                //isAirMonitor = true
                //isGeigerCounter = true
                //isWeatherStation = true

                chartEnvLoader.source = "" // force graph reload

                //
                loadIndicator()
                loadGraph()
                //
                updateHeader()
                updateData()
            }

            function loadIndicator() {
                if (typeof currentDevice === "undefined" || !currentDevice) return
                if (!currentDevice.isEnvironmentalSensor) return
                //console.log("DeviceEnvironmental // loadIndicator()")

                if (primary === "voc") {
                    indicatorAirQuality.legend = qsTr("VOC")
                    indicatorAirQuality.limitMin = 500
                    indicatorAirQuality.limitMax = 1000
                    indicatorAirQuality.valueMin = 0
                    indicatorAirQuality.valueMax = 1500
                    indicatorAirQuality.value = currentDevice.voc
                } else if (primary === "hcho") {
                    indicatorAirQuality.legend = qsTr("HCHO")
                    indicatorAirQuality.limitMin = 250
                    indicatorAirQuality.limitMax = 750
                    indicatorAirQuality.valueMin = 0
                    indicatorAirQuality.valueMax = 1000
                    indicatorAirQuality.value = currentDevice.hcho
                } else if (primary === "co2") {
                    indicatorAirQuality.legend = (currentDevice.haseCo2Sensor ? qsTr("eCO2") : qsTr("CO2"))
                    indicatorAirQuality.limitMin = 850
                    indicatorAirQuality.limitMax = 1500
                    indicatorAirQuality.valueMin = 0
                    indicatorAirQuality.valueMax = 2000
                    indicatorAirQuality.value = currentDevice.co2
                }

                if (primary === "hygrometer") {
                    //
                }

                if (primary === "barometer") {
                    //
                }
            }

            function updateHeader() {
                if (typeof currentDevice === "undefined" || !currentDevice) return
                if (!currentDevice.isEnvironmentalSensor) return
                //console.log("DeviceEnvironmental // updateHeader() >> " + currentDevice)

                //indicatorDisconnected.visible = !currentDevice.hasDataToday
                //indicatorAirQuality.visible = isAirMonitor && currentDevice.hasDataToday
                //indicatorRadioactivity.visible = isGeigerCounter && currentDevice.hasDataToday
                //indicatorHygrometer.visible = isWeatherStation && currentDevice.hasDataToday

                // Indicators
                if (primary === "hygrometer") {
                    //indicatorAirQuality.visible = false
                    //indicatorRadioactivity.visible = false
                    //indicatorHygrometer.visible = true

                    if (currentDevice.temperatureC < -40) {
                        sensorTemp.visible = false
                        heatIndex.visible = false
                        sensorHygro.visible = false
                    } else {
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
                            } else {
                                heatIndex.visible = false
                            }
                        } else {
                            heatIndex.visible = false
                        }
                    }
                } else if (primary === "barometer") {
                    //indicatorAirQuality.visible = false
                    //indicatorRadioactivity.visible = false
                    //indicatorHygrometer.visible = true
                } else if (isAirMonitor) {
                    //indicatorAirQuality.visible = true
                    //indicatorRadioactivity.visible = false
                    //indicatorHygrometer.visible = false

                    if (primary === "voc") indicatorAirQuality.value = currentDevice.voc
                    else if (primary === "hcho") indicatorAirQuality.value = currentDevice.hcho
                    else if (primary === "co2") indicatorAirQuality.value = currentDevice.co2
                    else if (primary === "co") indicatorAirQuality.value = currentDevice.co
                    else if (primary === "o2") indicatorAirQuality.value = currentDevice.o2
                    else if (primary === "o3") indicatorAirQuality.value = currentDevice.o3
                    else if (primary === "no2") indicatorAirQuality.value = currentDevice.no2
                    else if (primary === "so2") indicatorAirQuality.value = currentDevice.so2
                }

                // Battery level
                //imageBattery.visible = (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)
                //imageBattery.source = UtilsDeviceSensors.getDeviceBatteryIcon(currentDevice.deviceBattery)
                //imageBattery.color = UtilsDeviceSensors.getDeviceBatteryColor(currentDevice.deviceBattery)

                // Status
                updateStatusText()
            }

            function updateData() {
                if (typeof currentDevice === "undefined" || !currentDevice) return
                if (!currentDevice.isEnvironmentalSensor) return
                //console.log("DeviceEnvironmental // updateData() >> " + currentDevice)
            }

            function updateStatusText() {
                if (typeof currentDevice === "undefined" || !currentDevice) return
                if (!currentDevice.isEnvironmentalSensor) return
                //console.log("DeviceEnvironmental // updateStatusText() >> " + currentDevice)

                textStatus.text = UtilsDeviceSensors.getDeviceStatusText(currentDevice.status)

                if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE &&
                    (currentDevice.isDataFresh() || currentDevice.isDataToday())) {
                    if (currentDevice.lastUpdateMin <= 1)
                        textStatus.text = qsTr("Synced")
                    else
                        textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
                }
            }

            function loadGraph() {
                chartEnvLoader.visible = false

                if (isAirMonitor) {
                    if (currentDevice.hasVocSensor || currentDevice.hasHchoSensor || currentDevice.hasCo2Sensor) {
                        if (chartEnvLoader.status != Loader.Ready) {
                            chartEnvLoader.source = "ChartEnvironmentalVoc.qml"
                        } else {
                            historyChart.loadGraph()
                            historyChart.updateGraph()
                        }
                        currentDevice.updateChartData_environmentalVoc(31)
                        chartEnvLoader.visible = true
                    }
                }
            }
            function updateGraph() {
                if (typeof currentDevice === "undefined" || !currentDevice) return
                if (!currentDevice.isEnvironmentalSensor) return
                //console.log("DeviceEnvironmental // updateGraph() >> " + currentDevice)

                // GRAPH
                if (isAirMonitor) {
                    if (currentDevice.hasVocSensor || currentDevice.hasHchoSensor || currentDevice.hasCo2Sensor) {
                        currentDevice.updateChartData_environmentalVoc(31)
                    }
                }
            }

            ////////////////////////////////////////////////////////////////////////////

            property real fakeAQI: 25
            //   0- 50 (good)
            //  51-100 (moderate)
            // 101-150 (unhealthy for Sensitive Groups)
            // 151-200 (unhealthy)
            // 201-300 (Very Unhealthy)
            // 301-500 (Hazardous)

            ////////////////////////////////////////////////////////////////////////////

            Flow {
                anchors.fill: parent

                Rectangle {
                    id: headerBox

                    property int dimboxw: Math.min(deviceEnvironmental.width * 0.4, isPhone ? 192 : 600)
                    property int dimboxh: Math.max(deviceEnvironmental.height * 0.333, isPhone ? 160 : 256)

                    width: singleColumn ? parent.width : dimboxw
                    height: singleColumn ? dimboxh : parent.height

                    color: Theme.colorHeader
                    z: 5

                    //MouseArea { anchors.fill: parent } // prevent clicks below this area

                    Flow {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: headerUnicolor ? -(appHeader.height/2) : -(appHeader.height/4)
                        spacing: 48

                        IconSvg {
                            id: indicatorDisconnected
                            width: isMobile ? 96 : 128
                            height: isMobile ? 96 : 128

                            visible: (currentDevice && !currentDevice.hasDataToday)
                            color: cccc
                            source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                        }

                        ////////////////

                        AirQualityIndicator {
                            id: indicatorAirQuality
                            width: singleColumn ? headerBox.height * 0.72 : headerBox.width * 0.5
                            height: width

                            color: cccc
                            visible: (currentDevice && isAirMonitor && currentDevice.hasDataToday)
                        }

                        ////////////////

                        Column {
                            id: indicatorHygrometer
                            width: isMobile ? 96 : 128
                            height: isMobile ? 96 : 128
                            spacing: 2

                            visible: (currentDevice && primary === "hygrometer")

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
                        }

                        ////////////////

                        IconSvg {
                            id: indicatorRadioactivity
                            width: isMobile ? 128 : 160
                            height: isMobile ? 128 : 160

                            visible: (currentDevice && isGeigerCounter && currentDevice.hasDataToday)
                            color: cccc
                            source: "qrc:/assets/icons_custom/nuclear_icon_big.svg"

                            property real minOpacity: 0.5
                            property real maxOpacity: 1
                            property int minDuration: 500
                            property int maxDuration: 1000
                            property int duration: 750

                            SequentialAnimation on opacity {
                                id: radioactivityAnimation
                                loops: Animation.Infinite
                                running: false
                                onStopped: indicatorRadioactivity.opacity = indicatorRadioactivity.maxOpacity
                                OpacityAnimator { from: indicatorRadioactivity.minOpacity; to: indicatorRadioactivity.maxOpacity; duration: indicatorRadioactivity.duration }
                                OpacityAnimator { from: indicatorRadioactivity.maxOpacity; to: indicatorRadioactivity.minOpacity; duration: indicatorRadioactivity.duration }
                            }
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

                ////////////////////////////////////////////////////////////////////////

                Item {
                    id: sensorBox
                    width: singleColumn ? parent.width : (parent.width - headerBox.width)
                    height: singleColumn ? (parent.height - headerBox.height) : parent.height

                    ItemBannerSync {
                        id: bannersync
                        z: 5
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }

                    ////////////////////////////////////////////////////////////////////

                    Flickable {
                        id: sensorFlick
                        anchors.top: bannersync.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        contentWidth: parent.width
                        contentHeight: sensorFlow.height

                        flickableDirection: Flickable.VerticalFlick
                        boundsBehavior: Flickable.StopAtBounds

                        Flow {
                            id: sensorFlow
                            anchors.left: parent.left
                            anchors.right: parent.right

                            Rectangle {
                                id: airBox
                                width: parent.width
                                height: airFlow.height + (airFlow.anchors.topMargin*2)

                                visible: isAirMonitor
                                color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground
                                z: 3

                                Flow {
                                    id: airFlow
                                    anchors.top: parent.top
                                    anchors.topMargin: isDesktop ? 24 : 16
                                    anchors.left: parent.left
                                    anchors.leftMargin: isDesktop ? 24 : 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    spacing: isDesktop ? 16 : 12

                                    onWidthChanged: {
                                        var itemcount = 3
                                        var availableWidth = sensorBox.width - (anchors.leftMargin + anchors.rightMargin)
                                        var cellColumnsTarget = Math.trunc(availableWidth / (wwwTarget + spacing))
                                        if (cellColumnsTarget >= itemcount) {
                                            www = (availableWidth - (spacing * itemcount)) / itemcount
                                            if (www > wwwMax) www = wwwMax
                                        } else {
                                            www = (availableWidth - (spacing * cellColumnsTarget)) / cellColumnsTarget
                                        }
                                        //console.log("--- wwww: " + www)
                                    }

                                    property int wwwTarget: isPhone ? 128 : 160
                                    property int wwwMax: 200
                                    property int www: wwwTarget

                                    ItemEnvBox {
                                        id: pm1
                                        width: airFlow.www
                                        visible: currentDevice.hasPM1Sensor

                                        title: qsTr("PM1")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.pm1
                                        precision: 1
                                        onSensorSelection: primary = "pm1"
                                    }

                                    ItemEnvBox {
                                        id: pm25
                                        width: airFlow.www
                                        visible: currentDevice.hasPM25Sensor

                                        title: qsTr("PM2.5")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.pm25
                                        precision: 1
                                        onSensorSelection: primary = "pm25"
                                    }

                                    ItemEnvBox {
                                        id: pm100
                                        width: airFlow.www
                                        visible: currentDevice.hasPM10Sensor

                                        title: qsTr("PM10")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.pm10
                                        precision: 1
                                        onSensorSelection: primary = "pm10"
                                    }

                                    ItemEnvBox {
                                        id: voc
                                        width: airFlow.www
                                        visible: currentDevice.hasVocSensor

                                        title: qsTr("VOC")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.voc
                                        limit_mid: 500
                                        limit_high: 1000
                                        precision: 0
                                        onSensorSelection: primary = "voc"
                                    }

                                    ItemEnvBox {
                                        id: hcho
                                        width: airFlow.www
                                        visible: currentDevice.hasHchoSensor

                                        title: qsTr("HCHO")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.hcho
                                        limit_mid: 500
                                        limit_high: 1000
                                        precision: 0
                                        onSensorSelection: primary = "hcho"
                                    }
/*
                                    ItemEnvBox {
                                        id: o2
                                        width: airFlow.www
                                        visible: currentDevice.hasO2Sensor

                                        title: qsTr("O2")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.o2
                                        precision: 0
                                        onSensorSelection: primary = "o2"
                                    }

                                    ItemEnvBox {
                                        id: o3
                                        width: airFlow.www
                                        visible: currentDevice.hasO3Sensor

                                        title: qsTr("O3")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.o3
                                        precision: 0
                                        onSensorSelection: primary = "o3"
                                    }

                                    ItemEnvBox {
                                        id: so2
                                        width: airFlow.www
                                        visible: currentDevice.hasSo2Sensor

                                        title: qsTr("SO2")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.so2
                                        precision: 0
                                        onSensorSelection: primary = "so2"
                                    }

                                    ItemEnvBox {
                                        id: no2
                                        width: airFlow.www
                                        visible: currentDevice.hasNo2Sensor

                                        title: qsTr("NO2")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.no2
                                        precision: 0
                                        onSensorSelection: primary = "no2"
                                    }

                                    ItemEnvBox {
                                        id: co
                                        width: airFlow.www
                                        visible: currentDevice.hasCoSensor

                                        title: qsTr("CO")
                                        legend: qsTr("PPM")
                                        value: currentDevice.co
                                        precision: 0
                                        onSensorSelection: primary = "co"
                                    }
*/
                                    ItemEnvBox {
                                        id: co2
                                        width: airFlow.www
                                        visible: currentDevice.hasCo2Sensor

                                        title: (currentDevice.haseCo2Sensor ? qsTr("eCO2") : qsTr("CO2"))
                                        legend: qsTr("PPM")
                                        value: currentDevice.co2
                                        precision: 0
                                        limit_mid: 850
                                        limit_high: 1500
                                        onSensorSelection: primary = "co2"
                                    }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom

                                    visible: (isDesktop && singleColumn && !headerUnicolor)
                                    height: 2
                                    opacity: 0.5
                                    color: Theme.colorSeparator
                                }
                            }

                            ////////////////////////////////////////////////////////////

                            Rectangle {
                                id: radBox
                                width: parent.width
                                height: radFlow.height + (radFlow.anchors.topMargin*2)

                                visible: isGeigerCounter
                                color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground
                                z: 3

                                Flow {
                                    id: radFlow
                                    anchors.top: parent.top
                                    anchors.topMargin: isDesktop ? 24 : 16
                                    anchors.left: parent.left
                                    anchors.leftMargin: isDesktop ? 24 : 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    spacing: isDesktop ? 16 : 12

                                    onWidthChanged: {
                                        var itemcount = 2
                                        var availableWidth = sensorBox.width - (anchors.leftMargin + anchors.rightMargin)
                                        var cellColumnsTarget = Math.trunc(availableWidth / (wwwTarget + spacing))
                                        if (cellColumnsTarget >= itemcount) {
                                            www = (availableWidth - (spacing * itemcount)) / itemcount
                                            if (www > wwwMax) www = wwwMax
                                        } else {
                                            www = (availableWidth - (spacing * cellColumnsTarget)) / cellColumnsTarget
                                        }
                                        //console.log("--- wwww: " + www)
                                    }

                                    property int wwwTarget: isPhone ? 180 : 200
                                    property int wwwMax: 256
                                    property int www: wwwTarget

                                    ItemEnvBox {
                                        id: radm
                                        width: radFlow.www

                                        title: qsTr("RADIATION")
                                        legend: qsTr("µSv/h")
                                        value: currentDevice.radioactivityH
                                        precision: 2
                                        limit_mid: 1
                                        limit_high: 10
                                        onSensorSelection: primary = "radiation"
                                    }

                                    ItemEnvBox {
                                        id: rads
                                        width: radFlow.www

                                        title: qsTr("RADIATION")
                                        legend: qsTr("µSv/m")
                                        value: currentDevice.radioactivityM
                                        precision: 2
                                        limit_mid: 1
                                        limit_high: 10
                                        onSensorSelection: primary = "radiation"
                                    }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom

                                    visible: (isDesktop && singleColumn && !headerUnicolor)
                                    height: 2
                                    opacity: 0.5
                                    color: Theme.colorSeparator
                                }
                            }

                            ////////////////////////////////////////////////////////////

                            Rectangle {
                                id: weatherBox

                                visible: isWeatherStation

                                width: parent.width
                                height: weatherFlow.height + (weatherFlow.anchors.topMargin*2)
                                color: Theme.colorBackground
                                z: 3

                                Flow {
                                    id: weatherFlow
                                    anchors.top: parent.top
                                    anchors.topMargin: isDesktop ? 16 : 12
                                    anchors.left: parent.left
                                    anchors.leftMargin: isDesktop ? 16 : 12
                                    anchors.right: parent.right
                                    anchors.rightMargin: isDesktop ? 8 : 6
                                    spacing: isDesktop ? 16 : 12

                                    onWidthChanged: {
                                        var itemcount = 3
                                        var availableWidth = sensorBox.width - (anchors.leftMargin + anchors.rightMargin)
                                        var cellColumnsTarget = Math.trunc(availableWidth / (wwwTarget + spacing))
                                        if (cellColumnsTarget >= itemcount) {
                                            www = (availableWidth - (spacing * itemcount)) / itemcount
                                            if (www > wwwMax) www = wwwMax
                                        } else {
                                            www = (availableWidth - (spacing * cellColumnsTarget)) / cellColumnsTarget
                                            if (www > wwwMax) www = wwwMax
                                        }
                                        //console.log("--- wwww: " + www)
                                    }

                                    property int wwwTarget: isPhone ? 96 : 112
                                    property int wwwMax: isPhone ? 112 : 128
                                    property int www: wwwTarget

                                    ItemWeatherBox {
                                        id: temp
                                        size: weatherFlow.www
                                        visible: currentDevice.hasTemperatureSensor

                                        title: qsTr("Temperature")
                                        legend: "°" + settingsManager.tempUnit
                                        icon: "qrc:/assets/icons_custom/thermometer-24px.svg"
                                        value: currentDevice.temperature
                                        precision: 1
                                    }
                                    ItemWeatherBox {
                                        id: hum
                                        size: weatherFlow.www
                                        visible: currentDevice.hasHumiditySensor

                                        title: qsTr("Humidity")
                                        legend: qsTr("°RH")
                                        icon: "qrc:/assets/icons_material/duotone-water_full-24px.svg"
                                        value: currentDevice.humidity
                                        precision: 0
                                    }
                                    ItemWeatherBox {
                                        id: press
                                        size: weatherFlow.www
                                        visible: currentDevice.hasPressureSensor

                                        title: qsTr("Pressure")
                                        legend: qsTr("hPa")
                                        icon: "qrc:/assets/icons_material/duotone-speed-24px.svg"
                                        value: currentDevice.pressure
                                        precision: 0
                                    }

                                    ItemWeatherBox {
                                        id: sound
                                        size: weatherFlow.www
                                        visible: currentDevice.hasSoundSensor

                                        title: qsTr("Sound level")
                                        legend: qsTr("db")
                                        icon: "qrc:/assets/icons_material/duotone-mic-24px.svg"
                                        value: 47
                                        precision: 0
                                    }

                                    ItemWeatherBox {
                                        id: light
                                        size: weatherFlow.www
                                        visible: currentDevice.hasLuminositySensor

                                        title: qsTr("Luminosity")
                                        legend: qsTr("lux")
                                        icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                                        value: currentDevice.luminosityLux
                                        precision: 0
                                    }
                                    ItemWeatherBox {
                                        id: uv
                                        size: weatherFlow.www
                                        visible: currentDevice.hasUvSensor

                                        title: qsTr("UV index")
                                        legend: ""
                                        icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                                        value: currentDevice.uv
                                        precision: 0
                                    }
        /*
                                    ItemWeatherBox {
                                        id: windd
                                        size: weatherFlow.www
                                        visible: currentDevice.hasWindDirectionSensor

                                        title: qsTr("Wind direction")
                                        legend: "north"
                                        icon: "qrc:/assets/icons_material/baseline-near_me-24px.svg"
                                        value: 0
                                        precision: 0
                                    }
                                    ItemWeatherBox {
                                        id: winds
                                        size: weatherFlow.www
                                        visible: currentDevice.hasWindSpeedSensor

                                        title: qsTr("Wind speed")
                                        legend: qsTr("km/h")
                                        icon: "qrc:/assets/icons_material/baseline-air-24px.svg"
                                        value: 16
                                        precision: 0
                                    }

                                    ItemWeatherBox {
                                        id: rain
                                        size: weatherFlow.www
                                        visible: currentDevice.hasWaterLevelSensor

                                        title: qsTr("Rain")
                                        legend: qsTr("mm")
                                        icon: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
                                        value: 7
                                        precision: 0
                                    }
        */
                                }
                            }
        /*
                            Rectangle {
                                width: parent.width

                                visible: (isDesktop && singleColumn && !headerUnicolor)
                                height: 2
                                opacity: 0.5
                                color: Theme.colorSeparator
                            }
        */
                            ////////////////////////////////////////////////////////////

                            Loader {
                                id: chartEnvLoader
                                width: parent.width
                                height: (sensorFlick.height - airBox.height - weatherBox.height)
                                //height: singleColumn ? 360 : (sensorFlick.height - airBox.height - weatherBox.height)

                                asynchronous: true
                                onLoaded: {
                                    historyChart.loadGraph()
                                    historyChart.updateGraph()
                                }
                            }

                            ////////////////////////////////////////////////////////////
                        }
                    }
                }
            }
        }
    }
}
