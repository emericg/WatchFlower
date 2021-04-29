import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceBLE.js" as UtilsDeviceBLE

Item {
    id: deviceEnvironmental
    width: 450
    height: 700

    property var currentDevice: null
    property bool isAirMonitor: false
    property bool isWeatherStation: false
    property bool isGeigerCounter: false

    property string cccc: headerUnicolor ? Theme.colorHeaderContent : "white"

    ////////////////////////////////////////////////////////////////////////////

    Connections {
        target: currentDevice
        onStatusUpdated: { updateHeader() }
        onSensorUpdated: { updateHeader() }
        onBatteryUpdated: { updateHeader() }
        onDataUpdated: { updateData() }
    }

    Connections {
        target: settingsManager
        onTempUnitChanged: { updateData() }
        onAppLanguageChanged: {
            updateData()
            updateStatusText()
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

    function isHistoryMode() {
        return false
    }
    function resetHistoryMode() {
        return
    }

    ////////

    function loadDevice(clickedDevice) {
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (!clickedDevice.isEnvironmentalSensor) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        console.log("DeviceEnvironmental // loadDevice() >> " + currentDevice)

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

        indicatorDisconnected.visible = !currentDevice.isDataAvailable()
        indicatorAirQuality.visible = isAirMonitor && currentDevice.isDataAvailable()
        indicatorRadioactivity.visible = isGeigerCounter && currentDevice.isDataAvailable()

        //
        loadGraph()
        //
        updateHeader()
        updateData()
    }

    function loadGraph() {
        chartEnvironmentalLoader.visible = false

        if (isAirMonitor) {
            if (currentDevice.deviceName === "WP6003") {
                chartEnvironmentalLoader.source = "ChartEnvironmentalVoc.qml"
                chartEnvironmentalLoader.visible = true
            }
        }
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isEnvironmentalSensor) return
        //console.log("DeviceEnvironmental // updateHeader() >> " + currentDevice)

        // Indicators
        if (isAirMonitor) {
            if (currentDevice.deviceName === "WP6003") {
                indicatorAirQuality.legend = qsTr("VOC")
                indicatorAirQuality.value = currentDevice.voc
                indicatorAirQuality.valueMin = 0
                indicatorAirQuality.valueMax = 1500
            }
        }

        // Battery level
        //imageBattery.visible = (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)
        //imageBattery.source = UtilsDeviceBLE.getDeviceBatteryIcon(currentDevice.deviceBattery)
        //imageBattery.color = UtilsDeviceBLE.getDeviceBatteryColor(currentDevice.deviceBattery)

        // Status
        updateStatusText()
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isEnvironmentalSensor) return
        //console.log("DeviceEnvironmental // updateData() >> " + currentDevice)

        // DATA

        // GRAPH
        if (isAirMonitor) {
            if (currentDevice.deviceName === "WP6003") {
                currentDevice.updateChartData_environmentalVoc(14)
            }
        }
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isEnvironmentalSensor) return
        //console.log("DeviceEnvironmental // updateStatusText() >> " + currentDevice)

        textStatus.text = UtilsDeviceBLE.getDeviceStatusText(currentDevice.status)

        if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE &&
            (currentDevice.isDataFresh() || currentDevice.isDataAvailable())) {
            if (currentDevice.getLastUpdateInt() <= 1)
                textStatus.text = qsTr("Synced")
            else
                textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
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
            height: singleColumn ? dimboxh: parent.height

            color: Theme.colorHeader
            z: 5

            //MouseArea { anchors.fill: parent } // prevent clicks below this area

            Flow {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: headerUnicolor ? -(appHeader.height/2) : -(appHeader.height/4)
                spacing: 48

                ImageSvg {
                    id: indicatorDisconnected
                    width: isMobile ? 96 : 128
                    height: isMobile ? 96 : 128
                    source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                    color: cccc
                }

                ////////////////

                AirQualityIndicator {
                    id: indicatorAirQuality
                    width: singleColumn ? headerBox.height * 0.666 : headerBox.width * 0.5
                    height: width
                    color: cccc
                }

                ////////////////

                ImageSvg {
                    id: indicatorRadioactivity
                    width: isMobile ? 128 : 160
                    height: isMobile ? 128 : 160

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

                clip: true
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
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Loading...")
                    color: cccc
                    font.pixelSize: 17
                    font.bold: false
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
                        currentDevice.setLocationName(text)
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

        ////////////////////////////////////////////////////////////////////////

        Item {
            id: sensorBox
            width: singleColumn ? parent.width : (parent.width - headerBox.width)
            height: singleColumn ? (parent.height - headerBox.height) : parent.height

            ItemBannerSync {
                id: bannersync
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
                        color: Theme.colorDeviceHeader
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

                            property int wwwTarget: isPhone ? 144 : 160
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
                            }

                            ItemEnvBox {
                                id: pm25
                                width: airFlow.www
                                visible: currentDevice.hasPM25Sensor

                                title: qsTr("PM2.5")
                                legend: qsTr("µg/m³")
                                value: currentDevice.pm25
                                precision: 1
                            }

                            ItemEnvBox {
                                id: pm100
                                width: airFlow.www
                                visible: currentDevice.hasPM10Sensor

                                title: qsTr("PM10")
                                legend: qsTr("µg/m³")
                                value: currentDevice.pm10
                                precision: 1
                            }

                            ItemEnvBox {
                                id: o3
                                width: airFlow.www
                                visible: currentDevice.hasO3Sensor

                                title: qsTr("O3")
                                legend: qsTr("µg/m³")
                                value: 8.0
                                precision: 0
                            }

                            ItemEnvBox {
                                id: so2
                                width: airFlow.www
                                visible: currentDevice.hasSo2Sensor

                                title: qsTr("SO2")
                                legend: qsTr("µg/m³")
                                value: currentDevice.so2
                                precision: 0
                            }

                            ItemEnvBox {
                                id: no2
                                width: airFlow.www
                                visible: currentDevice.hasNo2Sensor

                                title: qsTr("NO2")
                                legend: qsTr("µg/m³")
                                value: currentDevice.no2
                                precision: 0
                            }

                            ItemEnvBox {
                                id: co
                                width: airFlow.www
                                visible: currentDevice.hasCoSensor

                                title: qsTr("CO")
                                legend: qsTr("PPM")
                                value: currentDevice.co
                                precision: 0
                            }

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

                    ////////////////////////////////////////////////////////////////

                    Rectangle {
                        id: radBox
                        width: parent.width
                        height: radFlow.height + 48

                        visible: isGeigerCounter
                        color: Theme.colorDeviceHeader
                        z: 3

                        Flow {
                            id: radFlow
                            anchors.top: parent.top
                            anchors.topMargin: 24
                            anchors.left: parent.left
                            anchors.leftMargin: 24
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            spacing: 16

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

                    ////////////////////////////////////////////////////////////////////////

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
                            anchors.topMargin: isDesktop ? 24 : 16
                            anchors.left: parent.left
                            anchors.leftMargin: isDesktop ? 24 : 16
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            spacing: isDesktop ? 16 : 12

                            onWidthChanged: {
                                var itemcount = 1
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

                            property int wwwTarget: 128
                            property int wwwMax: 128
                            property int www: wwwTarget

                            ItemWeatherBox {
                                id: temp
                                height: weatherFlow.www
                                visible: currentDevice.hasTemperatureSensor

                                title: qsTr("Temperature")
                                legend: "°" + settingsManager.tempUnit
                                icon: "qrc:/assets/icons_custom/thermometer-24px.svg"
                                value: currentDevice.deviceTemp
                                precision: 1
                            }
                            ItemWeatherBox {
                                id: hum
                                height: weatherFlow.www
                                visible: currentDevice.hasHumiditySensor

                                title: qsTr("Humidity")
                                legend: qsTr("°RH")
                                icon: "qrc:/assets/icons_material/duotone-water_full-24px.svg"
                                value: 55
                                precision: 0
                            }
                            ItemWeatherBox {
                                id: press
                                height: weatherFlow.www
                                visible: currentDevice.hasPressureSensor

                                title: qsTr("Pressure")
                                legend: qsTr("Hpa")
                                icon: "qrc:/assets/icons_material/duotone_speed-24px.svg"
                                value: 1028
                                precision: 0
                            }

                            ItemWeatherBox {
                                id: sound
                                height: weatherFlow.www
                                visible: currentDevice.hasSoundSensor

                                title: qsTr("Sound level")
                                legend: qsTr("db")
                                icon: "qrc:/assets/icons_material/duotone-mic-24px.svg"
                                value: 47
                                precision: 0
                            }

                            ItemWeatherBox {
                                id: light
                                height: weatherFlow.www
                                visible: currentDevice.hasLuminositySensor

                                title: qsTr("Luminosity")
                                legend: qsTr("lux")
                                icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                                value: 892
                                precision: 0
                            }
                            ItemWeatherBox {
                                id: uv
                                height: weatherFlow.www
                                visible: currentDevice.hasUvSensor

                                title: qsTr("UV index")
                                legend: ""
                                icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                                value: 3
                                precision: 0
                            }

                            ItemWeatherBox {
                                id: windd
                                height: weatherFlow.www
                                visible: currentDevice.hasWindDirectionSensor

                                title: qsTr("Wind direction")
                                legend: "north"
                                icon: "qrc:/assets/icons_material/baseline-near_me-24px.svg"
                                value: 0
                                precision: 0
                            }
                            ItemWeatherBox {
                                id: winds
                                height: weatherFlow.www
                                visible: currentDevice.hasWindSpeedSensor

                                title: qsTr("Wind speed")
                                legend: qsTr("km/h")
                                icon: "qrc:/assets/icons_material/baseline-air-24px.svg"
                                value: 16
                                precision: 0
                            }

                            ItemWeatherBox {
                                id: rain
                                height: weatherFlow.www
                                visible: currentDevice.hasWaterLevelSensor

                                title: qsTr("Rain")
                                legend: qsTr("mm")
                                icon: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
                                value: 7
                                precision: 0
                            }
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
                    ////////////////////////////////////////////////////////////////

                    Loader {
                        id: chartEnvironmentalLoader
                        width: parent.width
                        height: singleColumn ? 360 : (sensorFlick.height - airBox.height - weatherBox.height)
                        asynchronous: true
                    }

                    ////////////////////////////////////////////////////////////////
                }
            }
        }
    }
}
