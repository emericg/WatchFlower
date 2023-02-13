import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Loader {
    id: deviceEnvironmental

    property var currentDevice: null

    ////////

    function loadDevice(clickedDevice) {
        // set device
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.isEnvironmentalSensor) return
        if (clickedDevice === currentDevice) return
        currentDevice = clickedDevice

        // load screen
        deviceEnvironmental.active = true
        deviceEnvironmental.item.loadDevice()

        // change screen
        appContent.state = "DeviceEnvironmental"
    }

    ////////

    function backAction() {
        if (deviceEnvironmental.status === Loader.Ready)
            deviceEnvironmental.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: false

    sourceComponent: Item {
        id: itemDeviceEnvironmental
        implicitWidth: 480
        implicitHeight: 720

        focus: parent.focus

        // 1: single column (single column view or portrait tablet)
        // 2: wide mode (wide view)
        property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

        property bool isAirMonitor: false
        property bool isWeatherStation: false
        property bool isGeigerCounter: false

        property string primary: "voc"

        property string cccc: headerUnicolor ? Theme.colorHeaderContent : "white"

        property var envChart: graphLoader.item

        property int itemCount_AirMonitor: 3
        property int itemCount_GeigerCounter: 2
        property int itemCount_WeatherStation: 3

        ////////

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
            interval: 60000; running: true; repeat: true;
            onTriggered: updateStatusText()
        }

        ////////

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
                appWindow.backAction()
            }
        }

        onPrimaryChanged: {
            currentDevice.setSetting("primary", primary)
            loadIndicator()
            updateHeader()
            loadGraph()
            if (graphLoader.status === Loader.Ready) {
                updateGraph()
            }
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

            appContent.state = "DeviceList"
        }

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
                else if (currentDevice.hasCoSensor) primary = "co"
                else if (currentDevice.hasCo2Sensor) primary = "co2"
                else if (currentDevice.hasPM25Sensor) primary = "pm25"
                else if (currentDevice.hasPM10Sensor) primary = "pm10"
                else if (currentDevice.hasHchoSensor) primary = "hcho"
                else if (currentDevice.hasGeigerCounter) primary = "radioactivity"
                else primary = "hygrometer"
            }

            // Update device type
            if (currentDevice.hasPM1Sensor || currentDevice.hasPM25Sensor || currentDevice.hasPM10Sensor ||
                currentDevice.hasO2Sensor || currentDevice.hasO3Sensor ||
                currentDevice.hasCoSensor || currentDevice.hasCo2Sensor ||
                currentDevice.hasNo2Sensor || currentDevice.hasSo2Sensor ||
                currentDevice.hasVocSensor || currentDevice.hasHchoSensor) {
                isAirMonitor = true
            } else {
                isAirMonitor = false
            }

            isGeigerCounter = currentDevice.hasGeigerCounter

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

            // Update sizes
            itemCount_AirMonitor = 0
            if (currentDevice.hasPM1Sensor) itemCount_AirMonitor++
            if (currentDevice.hasPM25Sensor) itemCount_AirMonitor++
            if (currentDevice.hasPM10Sensor) itemCount_AirMonitor++
            if (currentDevice.hasVocSensor) itemCount_AirMonitor++
            if (currentDevice.hasHchoSensor) itemCount_AirMonitor++
            if (currentDevice.hasCoSensor) itemCount_AirMonitor++
            if (currentDevice.hasCo2Sensor) itemCount_AirMonitor++
            if (itemCount_AirMonitor > 3) itemCount_AirMonitor = 3
            airFlow.updateSize()

            itemCount_WeatherStation = 0
            if (currentDevice.hasTemperatureSensor) itemCount_WeatherStation++
            if (currentDevice.hasHumiditySensor) itemCount_WeatherStation++
            if (currentDevice.hasPressureSensor) itemCount_WeatherStation++
            if (currentDevice.hasSoundSensor) itemCount_WeatherStation++
            if (currentDevice.hasLuminositySensor) itemCount_WeatherStation++
            if (currentDevice.hasUvSensor) itemCount_WeatherStation++
            weatherFlow.updateSize()

            swipeBox.disableAnimation()
            swipeBox.currentIndex = 0
            swipeBox.interactive = false
            swipeBox.enableAnimation()

            // force graph reload
            graphLoader.source = ""
            graphLoader.opacity = 0
            noDataIndicator.visible = false

            loadIndicator()
            loadGraph()
            updateGraph()
            updateHeader()
            updateData()
            sensorSettings.updateHeader()

            mobileMenu.setActiveDeviceData()
            appHeader.setActiveDeviceData()
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
            } else if (primary === "pm25") {
                indicatorAirQuality.legend = qsTr("PM2.5")
                indicatorAirQuality.limitMin = 60
                indicatorAirQuality.limitMax = 120
                indicatorAirQuality.valueMin = 0
                indicatorAirQuality.valueMax = 240
                indicatorAirQuality.value = currentDevice.pm25
            } else if (primary === "pm10") {
                indicatorAirQuality.legend = qsTr("PM10")
                indicatorAirQuality.limitMin = 100
                indicatorAirQuality.limitMax = 350
                indicatorAirQuality.valueMin = 0
                indicatorAirQuality.valueMax = 500
                indicatorAirQuality.value = currentDevice.pm10
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

            //indicatorAirQuality.visible = isAirMonitor && currentDevice.hasDataToday
            //indicatorRadioactivity.visible = isGeigerCounter && currentDevice.hasDataToday
            //indicatorHygrometer.visible = isWeatherStation && currentDevice.hasDataToday

            // Indicators
            if (primary === "hygrometer") {

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
            } else if (primary === "barometer") {
                // TODO
            } else if (isAirMonitor) {
                if (primary === "voc") indicatorAirQuality.value = currentDevice.voc
                else if (primary === "hcho") indicatorAirQuality.value = currentDevice.hcho
                else if (primary === "co2") indicatorAirQuality.value = currentDevice.co2
                else if (primary === "co") indicatorAirQuality.value = currentDevice.co
                else if (primary === "o2") indicatorAirQuality.value = currentDevice.o2
                else if (primary === "o3") indicatorAirQuality.value = currentDevice.o3
                else if (primary === "no2") indicatorAirQuality.value = currentDevice.no2
                else if (primary === "so2") indicatorAirQuality.value = currentDevice.so2
                else if (primary === "pm1") indicatorAirQuality.value = currentDevice.pm1
                else if (primary === "pm25") indicatorAirQuality.value = currentDevice.pm25
                else if (primary === "pm10") indicatorAirQuality.value = currentDevice.pm10
            }

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
                (currentDevice.isDataFresh_rt() || currentDevice.isDataToday())) {
                if (currentDevice.lastUpdateMin <= 1)
                    textStatus.text = qsTr("Synced")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
            }
        }

        function loadGraph() {
            if (isAirMonitor) {
                if (currentDevice.hasPM1Sensor || currentDevice.hasPM25Sensor || currentDevice.hasPM10Sensor ||
                    currentDevice.hasVocSensor || currentDevice.hasHchoSensor ||
                    currentDevice.hasCoSensor || currentDevice.hasCo2Sensor) {
                    if (primary === "hygrometer") {
                        graphLoader.source = ""
                        graphLoader.opacity = 0
                    } else {
                        if (graphLoader.status !== Loader.Ready) {
                            graphLoader.source = "ChartEnvironmentalVoc.qml"
                        } else {
                            envChart.loadGraph()
                            envChart.updateGraph()
                        }
                    }
                }
            }
        }

        function updateGraph() {
            if (typeof currentDevice === "undefined" || !currentDevice) return
            if (!currentDevice.isEnvironmentalSensor) return
            //console.log("DeviceEnvironmental // updateGraph() >> " + currentDevice)

            // GRAPH
            if (isAirMonitor) {
                if (currentDevice.hasPM25Sensor || currentDevice.hasPM10Sensor) {
                    currentDevice.updateChartData_environmentalEnv(90)
                } else if (currentDevice.hasVocSensor || currentDevice.hasHchoSensor || currentDevice.hasCo2Sensor) {
                    currentDevice.updateChartData_environmentalVoc(90)
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////

        property real fakeAQI: 25
        //   0- 50 (good)
        //  51-100 (moderate)
        // 101-150 (unhealthy for Sensitive Groups)
        // 151-200 (unhealthy)
        // 201-300 (Very Unhealthy)
        // 301-500 (Hazardous)

        ////////////////////////////////////////////////////////////////////////

        Flow {
            anchors.fill: parent

            Rectangle {
                id: headerBox

                property int dimboxw: Math.min(deviceEnvironmental.width * 0.4, isPhone ? 320 : 600)
                property int dimboxh: Math.max(deviceEnvironmental.height * 0.333, isPhone ? 180 : 256)

                width: (uiMode === 1) ? parent.width : dimboxw
                height: (uiMode === 1) ? dimboxh : parent.height

                color: Theme.colorHeader
                z: 5

                //MouseArea { anchors.fill: parent } // prevent clicks below this area

                Item {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 24

                    ////////////////

                    IconSvg {
                        id: indicatorDisconnected
                        width: isMobile ? 96 : 128
                        height: isMobile ? 96 : 128
                        anchors.centerIn: parent

                        visible: (currentDevice && !currentDevice.hasDataToday)
                        source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                        color: cccc
                    }

                    ////////////////

                    AirQualityIndicator {
                        id: indicatorAirQuality
                        width: (uiMode === 1) ? headerBox.height-24 : headerBox.width * 0.60
                        height: width
                        anchors.centerIn: parent

                        visible: (currentDevice && currentDevice.hasDataToday &&
                                  (primary === "voc" || primary === "hcho" ||
                                   primary === "co" || primary === "co2" ||
                                   primary === "pm1" || primary === "pm25" || primary === "pm10"))

                        color: cccc
                    }

                    ////////////////

                    Column {
                        id: indicatorHygrometer
                        width: isMobile ? 96 : 128
                        height: isMobile ? 96 : 128
                        anchors.centerIn: parent
                        spacing: 2

                        visible: (currentDevice && currentDevice.hasDataToday &&
                                  (primary === "hygrometer" || primary === "barometer"))

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
                        }
                    }

                    ////////////////

                    IconSvg {
                        id: indicatorRadioactivity
                        width: isMobile ? 128 : 160
                        height: isMobile ? 128 : 160
                        anchors.centerIn: parent

                        visible: (currentDevice && currentDevice.hasDataToday && primary === "radioactivity")
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

                    ////////////////

                    IconSvg {
                        id: imageBattery
                        width: isPhone ? 20 : 24
                        height: isPhone ? 32 : 36
                        rotation: 90
                        anchors.top: {
                            if (indicatorAirQuality.visible) return indicatorAirQuality.bottom
                            if (indicatorHygrometer.visible) return indicatorHygrometer.bottom
                            if (indicatorRadioactivity.visible) return indicatorRadioactivity.bottom
                            return indicatorAirQuality.bottom
                        }
                        anchors.topMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter

                        visible: (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)
                        source: UtilsDeviceSensors.getDeviceBatteryIcon(currentDevice.deviceBattery)
                        fillMode: Image.PreserveAspectCrop
                        color: UtilsDeviceSensors.getDeviceBatteryColor(currentDevice.deviceBattery)
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

                        text: currentDevice.deviceLocationName
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

            ////////////////////////////////////////////////////////////////////

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

                ////////////////

                Item {
                    ItemBannerSync {
                        id: bannersync
                        z: 5
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }

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
                                id: airBoxes
                                width: parent.width
                                height: airFlow.height + (airFlow.anchors.topMargin*2)

                                visible: isAirMonitor
                                color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground
                                z: 3

                                Flow {
                                    id: airFlow
                                    anchors.top: parent.top
                                    anchors.topMargin: isDesktop ? 20 : 14
                                    anchors.left: parent.left
                                    anchors.leftMargin: isDesktop ? 20 : 14
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    spacing: 8

                                    onWidthChanged: updateSize()
                                    function updateSize() {
                                        var availableWidth = swipeBox.width - (anchors.leftMargin + anchors.rightMargin)
                                        var cellColumnsTarget = Math.trunc(availableWidth / (wwwTarget + spacing))
                                        if (itemCount_AirMonitor >= cellColumnsTarget) {
                                            www = (availableWidth - (spacing * cellColumnsTarget)) / cellColumnsTarget
                                        } else {
                                            www = (availableWidth - (spacing * itemCount_AirMonitor)) / itemCount_AirMonitor
                                        }
                                        if (www > (availableWidth/2)) www = (availableWidth/2)
                                        if (www > wwwMax) www = wwwMax
                                        //console.log("--- airFlow cellWidth: " + www)
                                    }

                                    property int wwwTarget: isPhone ? 96 : 140
                                    property int wwwMax: 240
                                    property int www: wwwTarget

                                    ItemEnvBox {
                                        id: pm1
                                        width: airFlow.www
                                        visible: currentDevice.hasPM1Sensor

                                        title: qsTr("PM1")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.pm1
                                        precision: 0
                                        onSensorSelection: primary = "pm1"
                                    }

                                    ItemEnvBox {
                                        id: pm25
                                        width: airFlow.www
                                        visible: currentDevice.hasPM25Sensor

                                        title: qsTr("PM2.5")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.pm25
                                        limit_mid: 60
                                        limit_high: 120
                                        precision: 0
                                        onSensorSelection: primary = "pm25"
                                    }

                                    ItemEnvBox {
                                        id: pm100
                                        width: airFlow.www
                                        visible: currentDevice.hasPM10Sensor

                                        title: qsTr("PM10")
                                        legend: qsTr("µg/m³")
                                        value: currentDevice.pm10
                                        limit_mid: 100
                                        limit_high: 350
                                        precision: 0
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
                                        legend: qsTr("ppm")
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
                                        legend: qsTr("ppm")
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

                                    visible: !headerUnicolor
                                    height: 2
                                    color: Theme.colorSeparator
                                }
                            }

                            ////////////////////////////////////////////////////

                            Rectangle {
                                id: radBoxes
                                width: parent.width
                                height: radFlow.height + (radFlow.anchors.topMargin*2)

                                visible: isGeigerCounter
                                color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground
                                z: 3

                                Flow {
                                    id: radFlow
                                    anchors.top: parent.top
                                    anchors.topMargin: isDesktop ? 20 : 12
                                    anchors.left: parent.left
                                    anchors.leftMargin: isDesktop ? 20 : 12
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    spacing: 12

                                    onWidthChanged: updateSize()
                                    function updateSize() {
                                        var availableWidth = swipeBox.width - (anchors.leftMargin + anchors.rightMargin)
                                        var cellColumnsTarget = Math.trunc(availableWidth / (wwwTarget + spacing))
                                        if (itemCount_GeigerCounter >= cellColumnsTarget) {
                                            www = (availableWidth - (spacing * cellColumnsTarget)) / cellColumnsTarget
                                        } else {
                                            www = (availableWidth - (spacing * itemCount_GeigerCounter)) / itemCount_GeigerCounter
                                        }
                                        if (www > (availableWidth/2)) www = (availableWidth/2)
                                        if (www > wwwMax) www = wwwMax
                                        //console.log("--- radFlow cellWidth: " + www)
                                    }

                                    property int wwwTarget: 128
                                    property int wwwMax: 256
                                    property int www: wwwTarget

                                    ItemEnvBox {
                                        id: rad_h
                                        width: radFlow.www

                                        title: qsTr("RADIATION")
                                        legend: qsTr("µSv/h")
                                        value: currentDevice.radioactivityH
                                        precision: 2
                                        limit_mid: 1
                                        limit_high: 10
                                        onSensorSelection: primary = "radioactivity"
                                    }

                                    ItemEnvBox {
                                        id: rad_m
                                        width: radFlow.www

                                        title: qsTr("RADIATION")
                                        legend: qsTr("µSv/m")
                                        value: currentDevice.radioactivityM
                                        precision: 2
                                        limit_mid: 1
                                        limit_high: 10
                                        onSensorSelection: primary = "radioactivity"
                                    }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom

                                    visible: !headerUnicolor
                                    height: 2
                                    opacity: 0.5
                                    color: Theme.colorSeparator
                                }
                            }

                            ////////////////////////////////////////////////////

                            Rectangle {
                                id: weatherBoxes

                                visible: isWeatherStation

                                width: parent.width
                                height: weatherFlow.height + (weatherFlow.anchors.topMargin*2)
                                color: Theme.colorBackground
                                z: 3

                                Flow {
                                    id: weatherFlow
                                    anchors.top: parent.top
                                    anchors.topMargin: isPhone ? 8 : 14
                                    anchors.left: parent.left
                                    anchors.leftMargin: isPhone ? 8 : 14
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    spacing: isPhone ? 8 : 14

                                    onWidthChanged: updateSize()
                                    function updateSize() {
                                        var availableWidth = swipeBox.width - (anchors.leftMargin + anchors.rightMargin)
                                        var cellColumnsTarget = Math.trunc(availableWidth / (wwwTarget + spacing))
                                        if (itemCount_WeatherStation >= cellColumnsTarget) {
                                            www = (availableWidth - (spacing * cellColumnsTarget)) / cellColumnsTarget
                                        } else {
                                            www = (availableWidth - (spacing * itemCount_WeatherStation)) / itemCount_WeatherStation
                                        }
                                        if (www > (availableWidth/2)) www = (availableWidth/2)
                                        if (www > wwwMax) www = wwwMax
                                        //console.log("--- weatherFlow cellWidth: " + www)
                                    }

                                    property int wwwTarget: isPhone ? 92 : 128
                                    property int wwwMax: 240
                                    property int www: wwwTarget

                                    ItemWeatherBox {
                                        id: temp
                                        visible: currentDevice.hasTemperatureSensor
                                        sz: weatherFlow.www
                                        duo: false

                                        title: qsTr("Temperature")
                                        legend: "°" + settingsManager.tempUnit
                                        icon: "qrc:/assets/icons_custom/thermometer-24px.svg"
                                        value: currentDevice.temperature
                                        precision: 1
                                        onSensorSelection: primary = "hygrometer"
                                    }
                                    ItemWeatherBox {
                                        id: humi
                                        visible: currentDevice.hasHumiditySensor
                                        sz: weatherFlow.www
                                        duo: false

                                        title: qsTr("Humidity")
                                        legend: qsTr("%RH")
                                        icon: "qrc:/assets/icons_material/duotone-water_full-24px.svg"
                                        value: currentDevice.humidity
                                        precision: 0
                                        onSensorSelection: primary = "hygrometer"
                                    }
                                    ItemWeatherBox {
                                        id: pres
                                        visible: currentDevice.hasPressureSensor
                                        sz: weatherFlow.www
                                        duo: false

                                        title: qsTr("Pressure")
                                        legend: qsTr("hPa")
                                        icon: "qrc:/assets/icons_material/duotone-speed-24px.svg"
                                        value: currentDevice.pressure
                                        precision: 0
                                    }

                                    ItemWeatherBox {
                                        id: light
                                        visible: currentDevice.hasLuminositySensor
                                        sz: weatherFlow.www

                                        title: qsTr("Luminosity")
                                        legend: qsTr("lux")
                                        icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                                        value: currentDevice.luminosityLux
                                        precision: 0
                                    }
                                    ItemWeatherBox {
                                        id: uv
                                        visible: currentDevice.hasUvSensor
                                        sz: weatherFlow.www

                                        title: qsTr("UV index")
                                        legend: ""
                                        icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                                        value: currentDevice.uv
                                        precision: 0
                                    }
/*
                                    ItemWeatherBox {
                                        id: sound
                                        visible: currentDevice.hasSoundSensor
                                        sz: weatherFlow.www

                                        title: qsTr("Sound level")
                                        legend: qsTr("db")
                                        icon: "qrc:/assets/icons_material/duotone-mic-24px.svg"
                                        value: 47
                                        precision: 0
                                    }

                                    ItemWeatherBox {
                                        id: windd
                                        visible: currentDevice.hasWindDirectionSensor
                                        sz: weatherFlow.www

                                        title: qsTr("Wind direction")
                                        legend: "north"
                                        icon: "qrc:/assets/icons_material/baseline-near_me-24px.svg"
                                        value: 0
                                        precision: 0
                                    }
                                    ItemWeatherBox {
                                        id: winds
                                        visible: currentDevice.hasWindSpeedSensor
                                        sz: weatherFlow.www

                                        title: qsTr("Wind speed")
                                        legend: qsTr("km/h")
                                        icon: "qrc:/assets/icons_material/baseline-air-24px.svg"
                                        value: 16
                                        precision: 0
                                    }

                                    ItemWeatherBox {
                                        id: rain
                                        visible: currentDevice.hasWaterLevelSensor
                                        sz: weatherFlow.www

                                        title: qsTr("Rain")
                                        legend: qsTr("mm")
                                        icon: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
                                        value: 7
                                        precision: 0
                                    }
*/
                                }
                            }

                            ////////////////////////////////////////////////////

                            Item {
                                width: parent.width
                                height: (sensorFlick.height - airBoxes.height - weatherBoxes.height)

                                ItemNoData {
                                    id: noDataIndicator
                                    visible: false
                                }

                                Loader {
                                    id: graphLoader
                                    anchors.fill: parent

                                    opacity: 0
                                    Behavior on opacity { OpacityAnimator { duration: (graphLoader.status === Loader.Ready) ? 200 : 0 } }

                                    asynchronous: true
                                    onLoaded: {
                                        envChart.loadGraph()
                                        envChart.updateGraph()

                                        graphLoader.opacity = 1
                                        noDataIndicator.visible = (currentDevice.countDataNamed("temperature", envChart.daysVisible) < 1)
                                    }
                                }
                            }

                            ////////////////////////////////////////////////////
                        }
                    }
                }

                ////////////////

                DevicePlantSensorSettings {
                    id: sensorSettings
                }

                ////////////////
            }
        }

        ////////////////////////////////////////////////////////////////////////
    }
}
