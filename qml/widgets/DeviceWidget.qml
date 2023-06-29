import QtQuick

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Item {
    id: deviceWidget
    implicitWidth: 480
    implicitHeight: 128

    property var boxDevice: pointer

    property bool hasHygro: boxDevice.isPlantSensor &&
                            ((boxDevice.soilMoisture > 0 || boxDevice.soilConductivity > 0) ||
                             (boxDevice.hasDataNamed("soilMoisture") || boxDevice.hasDataNamed("soilConductivity")))

    property bool wideMode: ((width >= 380) || (isTablet && width >= 480))
    property bool hugeMode: (!isHdpi || (isTablet && width >= 480))
    property bool listMode: false

    property int margin: Theme.componentMargin
    property int halfmargin: Theme.componentMargin / 2

    Connections {
        target: boxDevice
        function onSensorUpdated() { initBoxData() }
        function onSensorsUpdated() { initBoxData() }
        function onCapabilitiesUpdated() { initBoxData() }
        function onStatusUpdated() { updateSensorStatus() }
        function onSettingsUpdated() { updateSensorStatus(); updateSensorTitle(); }
        function onDataUpdated() { updateSensorData() }
        function onRefreshUpdated() { updateSensorData() }
        function onLimitsUpdated() { updateSensorData() }
    }
    Connections {
        target: ThemeEngine
        function onCurrentThemeChanged() {
            updateSensorTitle()
            updateSensorStatus()
            updateSensorData()
        }
    }
    Connections {
        target: settingsManager
        function onAppLanguageChanged() {
            updateSensorTitle()
            updateSensorStatus()
            updateSensorData()
        }
        function onTempUnitChanged() {
            updateSensorData()
        }
    }

    Component.onCompleted: initBoxData()

    ////////////////////////////////////////////////////////////////////////////

    function initBoxData() {
        // Load indicators
        if (boxDevice.isPlantSensor) {
            if (!loaderIndicators.sourceComponent) {
                loaderIndicators.sourceComponent = componentPlantSensor
            }
        } else if (boxDevice.isThermometer) {
            if (!loaderIndicators.sourceComponent) {
                if (boxDevice.hasHumiditySensor)
                    loaderIndicators.sourceComponent = componentText_2l
                else
                    loaderIndicators.sourceComponent = componentText_1l
            }
        } else if (boxDevice.isEnvironmentalSensor) {
            if (boxDevice.primary === "hygrometer") {
                if (boxDevice.hasHumiditySensor)
                    loaderIndicators.sourceComponent = componentText_2l
                else
                    loaderIndicators.sourceComponent = componentText_1l
            } else if (boxDevice.primary === "radioactivity") {
                loaderIndicators.sourceComponent = componentText_1l
            } else {
                loaderIndicators.sourceComponent = componentEnvironmentalGauge
                loaderIndicators.item.initData()
            }
        }

        updateSensorTitle()
        updateSensorStatus()
        updateSensorData()
    }

    function updateSensorStatus() {
        // Status
        if (!boxDevice.deviceEnabled) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Disabled")
            return
        }

        textStatus.text = UtilsDeviceSensors.getDeviceStatusText(boxDevice.status)
        textStatus.color = UtilsDeviceSensors.getDeviceStatusColor(boxDevice.status)

        if (boxDevice.status === DeviceUtils.DEVICE_OFFLINE) {
            if (boxDevice.isDataFresh_rt()) {
                textStatus.color = Theme.colorGreen
                textStatus.text = qsTr("Synced")
            } else if (boxDevice.isDataToday()) {
                textStatus.color = Theme.colorYellow
                textStatus.text = qsTr("Synced")
            }
        }
    }

    function updateSensorTitle() {
        // Title
        if (boxDevice.isPlantSensor) {
            if (boxDevice.deviceAssociatedName !== "")
                textTitle.text = boxDevice.deviceAssociatedName
            else
                textTitle.text = boxDevice.deviceName
        } else if (boxDevice.isThermometer) {
            if (boxDevice.deviceName === "ThermoBeacon")
                textTitle.text = boxDevice.deviceName
            else
                textTitle.text = qsTr("Thermometer")
        } else {
            textTitle.text = boxDevice.deviceName
        }
        // Location
        if (boxDevice.deviceLocationName) {
            textLocation.visible = true
            textLocation.text = boxDevice.deviceLocationName
        } else {
            if (Qt.platform.os === "osx" || Qt.platform.os === "ios") {
                textLocation.visible = false
                textLocation.text = ""
            } else {
                textLocation.visible = true
                textLocation.text = boxDevice.deviceAddress
            }
        }
    }

    function updateSensorData() {
        if (loaderIndicators.item) loaderIndicators.item.updateData()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // rectangle border
        anchors.fill: deviceWidgetRectangle

        anchors.topMargin: listMode ? -halfmargin : 0
        anchors.leftMargin: listMode ? -margin : 0
        anchors.rightMargin: listMode ? -margin : 0
        anchors.bottomMargin: listMode ? -halfmargin : 0

        radius: Math.min(Theme.componentRadius, 8)
        border.width: Theme.componentBorderWidth
        border.color: {
            if (listMode) return "transparent"
            if (mousearea.containsPress) return Qt.lighter(Theme.colorSecondary, 1.1)
            return Theme.colorSeparator
        }
        Behavior on border.color { ColorAnimation { duration: 133 } }

        color: boxDevice.selected ? Theme.colorSeparator : Theme.colorDeviceWidget
        Behavior on color { ColorAnimation { duration: 133 } }

        opacity: boxDevice.selected ? 0.5 : (listMode ? 0 : 1)
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    Item { // outside indicator
        anchors.fill: parent
        anchors.topMargin: listMode ? 0 : halfmargin
        anchors.leftMargin: listMode ? -halfmargin : halfmargin
        clip: true

        Loader {
            asynchronous: true
            active: boxDevice.deviceIsOutside
            sourceComponent: IconSvg {
                anchors.top: parent.top
                anchors.topMargin: -40
                anchors.left: parent.left
                anchors.leftMargin: -40

                width: 96
                height: 96
                opacity: 0.2

                source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                color: Theme.colorYellow
            }
        }
    }

    Rectangle { // bottom separator
        anchors.left: parent.left
        anchors.leftMargin: -halfmargin
        anchors.right: parent.right
        anchors.rightMargin: -halfmargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        height: 1
        visible: listMode
        color: Theme.colorSeparator
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: deviceWidgetRectangle
        anchors.fill: parent
        anchors.margins: halfmargin

        opacity: boxDevice.deviceEnabled ? 1 : 0.66

        MouseArea {
            id: mousearea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            onClicked: (mouse) => {
                if (typeof boxDevice === "undefined" || !boxDevice) return

                if (mouse.button === Qt.LeftButton) {
                    // multi selection
                    if ((mouse.modifiers & Qt.ControlModifier) ||
                        (deviceList.selectionMode)) {
                        if (!boxDevice.selected) {
                            deviceList.selectDevice(index, boxDevice.deviceType)
                        } else {
                            deviceList.deselectDevice(index, boxDevice.deviceType)
                        }
                        return
                    }

                    // regular click
                    selectedDevice = boxDevice
                    if (boxDevice.isPlantSensor) {
                        screenDevicePlantSensor.loadDevice(boxDevice)
                        appContent.state = "DevicePlantSensor"
                    } else if (boxDevice.isThermometer) {
                        screenDeviceThermometer.loadDevice(boxDevice)
                        appContent.state = "DeviceThermometer"
                    } else if (boxDevice.isEnvironmentalSensor) {
                        screenDeviceEnvironmental.loadDevice(boxDevice)
                        appContent.state = "DeviceEnvironmental"
                    }
                }

                if (mouse.button === Qt.MiddleButton) {
                    // multi selection
                    if (!boxDevice.selected) {
                        deviceList.selectDevice(index, boxDevice.deviceType)
                    } else {
                        deviceList.deselectDevice(index, boxDevice.deviceType)
                    }
                    return
                }
            }

            onPressAndHold: {
                // multi selection
                if (!boxDevice.selected) {
                    utilsApp.vibrate(25)
                    deviceList.selectDevice(index, boxDevice.deviceType)
                } else {
                    deviceList.deselectDevice(index, boxDevice.deviceType)
                }
            }
        }

        ////////////////

        Row {
            id: rowLeft
            anchors.top: parent.top
            anchors.topMargin: hugeMode ? 16 : 8
            anchors.left: parent.left
            anchors.leftMargin: hugeMode ? (listMode ? 0 : 16) : (listMode ? 2 : 12)
            anchors.right: rowRight.left
            anchors.rightMargin: listMode ? 2 : 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: hugeMode ? 16 : 8

            spacing: hugeMode ? (listMode ? 14 : 12) : (listMode ? 18 : 10)

            IconSvg {
                id: imageDevice
                width: hugeMode ? 32 : 24
                height: hugeMode ? 32 : 24
                anchors.verticalCenter: parent.verticalCenter

                color: Theme.colorHighContrast
                visible: (wideMode || hugeMode)
                fillMode: Image.PreserveAspectFit
                asynchronous: true

                source: {
                    if (boxDevice.isPlantSensor) {
                        if (hasHygro) {
                            if (boxDevice.deviceName === "ropot" || boxDevice.deviceName === "Parrot pot")
                                return "qrc:/assets/icons_custom/pot_flower-24px.svg"
                            else
                                return "qrc:/assets/icons_material/outline-local_florist-24px.svg"
                        } else {
                            if (boxDevice.deviceName === "ropot" || boxDevice.deviceName === "Parrot pot")
                                return "qrc:/assets/icons_custom/pot_empty-24px.svg"
                            else
                                return "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
                        }
                    }
                    return UtilsDeviceSensors.getDeviceIcon(boxDevice, hasHygro)
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: textTitle
                    width: rowLeft.width - imageDevice.width - rowLeft.spacing

                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.pixelSize: hugeMode ? 22 : 20
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Text {
                    id: textLocation
                    width: rowLeft.width - imageDevice.width - rowLeft.spacing

                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.pixelSize: hugeMode ? 20 : 18
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Row {
                    height: hugeMode ? 26 : 22
                    anchors.left: parent.left
                    spacing: 8

                    IconSvg {
                        id: imageBattery
                        width: hugeMode ? 30 : 28
                        height: hugeMode ? 32 : 30
                        anchors.verticalCenter: parent.verticalCenter

                        visible: (boxDevice.hasBattery && boxDevice.deviceBattery >= 0)
                        source: UtilsDeviceSensors.getDeviceBatteryIcon(boxDevice.deviceBattery)
                        color: Theme.colorIcon
                        rotation: 90
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        id: textStatus
                        anchors.verticalCenter: parent.verticalCenter

                        textFormat: Text.PlainText
                        color: Theme.colorGreen
                        font.pixelSize: hugeMode ? 16 : 15

                        SequentialAnimation on opacity {
                            id: opa
                            loops: Animation.Infinite
                            alwaysRunToEnd: true
                            running: (visible &&
                                      boxDevice.status !== DeviceUtils.DEVICE_OFFLINE &&
                                      boxDevice.status !== DeviceUtils.DEVICE_QUEUED &&
                                      boxDevice.status !== DeviceUtils.DEVICE_CONNECTED)

                            PropertyAnimation { to: 0.33; duration: 750; }
                            PropertyAnimation { to: 1; duration: 750; }
                        }
                    }
                }
            }
        }

        ////////////////

        Row { // alarms icons
            height: 24
            spacing: 8
            anchors.right: rowRight.left
            anchors.rightMargin: 12
            anchors.verticalCenter: rowRight.verticalCenter
            layoutDirection: Qt.RightToLeft

            visible: boxDevice.hasDataToday

            Loader { // alarmWater
                asynchronous: true
                active: (hasHygro &&
                         (boxDevice.soilMoisture < boxDevice.soilMoisture_limitMin) ||
                         (boxDevice.soilMoisture > boxDevice.soilMoisture_limitMax))

                sourceComponent: AlarmIndicator {
                    source: (boxDevice.soilMoisture > boxDevice.soilMoisture_limitMax) ?
                                "qrc:/assets/icons_material/duotone-water_full-24px.svg" :
                                "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                    color: (boxDevice.soilMoisture < boxDevice.soilMoisture_limitMin - 5 ||
                            boxDevice.soilMoisture > boxDevice.soilMoisture_limitMax + 5) ?
                                Theme.colorBlue : Theme.colorBlue
                }
            }

            Loader { // alarmFreeze
                asynchronous: true
                active: ((boxDevice.temperatureC > 40) ||
                         (boxDevice.temperatureC <= 2 && boxDevice.temperatureC > -80))

                sourceComponent: AlarmIndicator {
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                    color: {
                        if (boxDevice.temperatureC <= -4)
                            return Theme.colorRed
                        else
                            return Theme.colorYellow
                    }
                }
            }

            Loader { // alarmVentilate
                asynchronous: true
                active: ((boxDevice.hasVocSensor && boxDevice.voc > 500) ||
                         (boxDevice.hasHchoSensor && boxDevice.hcho > 500) ||
                         (boxDevice.hasCo2Sensor && boxDevice.co2 > 1000) ||
                         (boxDevice.hasPM25Sensor && boxDevice.pm25 > 120) ||
                         (boxDevice.hasPM10Sensor && boxDevice.pm10 > 350))

                sourceComponent: AlarmIndicator {
                    source: "qrc:/assets/icons_material/baseline-air-24px.svg"
                    color: {
                        if ((boxDevice.hasVocSensor && boxDevice.voc > 1000) ||
                            (boxDevice.hasHchoSensor && boxDevice.hcho > 1000) ||
                            (boxDevice.hasCo2Sensor && boxDevice.co2 > 2000)) {
                            return Theme.colorRed
                        } else if ((boxDevice.hasVocSensor && boxDevice.voc > 500) ||
                                  (boxDevice.hasHchoSensor && boxDevice.hcho > 500) ||
                                  (boxDevice.hasCo2Sensor && boxDevice.co2 > 1000) ||
                                  (boxDevice.hasPM25Sensor && boxDevice.pm25 > 120) ||
                                  (boxDevice.hasPM10Sensor && boxDevice.pm10 > 350)) {
                            return Theme.colorYellow
                        }
                    }
                }
            }

            Loader { // alarmRadiation
                asynchronous: true
                active: (boxDevice.hasGeigerCounter && boxDevice.radioactivityM > 1)

                sourceComponent: AlarmIndicator {
                    source: "qrc:/assets/icons_custom/nuclear_icon.svg"
                    color: {
                        if (boxDevice.radioactivityM > 10)
                            return Theme.colorRed
                        else
                            return Theme.colorYellow
                    }
                }
            }

            Loader { // alarmWarning
                asynchronous: true
                active: false

                sourceComponent: AlarmIndicator {
                    source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                    color: Theme.colorYellow
                }
            }
        }

        ////////////////

        Row {
            id: rowRight
            anchors.top: parent.top
            anchors.topMargin: hugeMode ? 16 : 8
            anchors.right: parent.right
            anchors.rightMargin: listMode ? -4 : (hugeMode ? 14 : 10)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: hugeMode ? 16 : 8

            spacing: 8

            ////

            Loader {
                id: loaderIndicators
                anchors.verticalCenter: parent.verticalCenter

                visible: boxDevice.hasDataToday

                sourceComponent: null
                asynchronous: false
            }

            ////

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.height * 0.5
                height: parent.height

                visible: !boxDevice.hasDataToday

                IconSvg {
                    id: imageStatus
                    anchors.centerIn: parent
                    width: 32
                    height: 32

                    color: Theme.colorIcon
                    opacity: 0.8

                    source: {
                        if (boxDevice.status === DeviceUtils.DEVICE_QUEUED) {
                            return "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                        } else if (boxDevice.status === DeviceUtils.DEVICE_CONNECTING) {
                            return "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
                        } else if (boxDevice.status === DeviceUtils.DEVICE_CONNECTED) {
                            return "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                        } else if (boxDevice.status >= DeviceUtils.DEVICE_WORKING) {
                            return "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                        }
                        return "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                    }

                    SequentialAnimation on opacity {
                        id: refreshAnimation
                        loops: Animation.Infinite
                        running: (visible &&
                                  boxDevice.status === DeviceUtils.DEVICE_CONNECTING ||
                                  boxDevice.status === DeviceUtils.DEVICE_CONNECTED ||
                                  boxDevice.status === DeviceUtils.DEVICE_WORKING)
                        alwaysRunToEnd: true
                        OpacityAnimator { from: 0.8; to: 0; duration: 750 }
                        OpacityAnimator { from: 0; to: 0.8; duration: 750 }
                    }
                }
            }

            ////

            IconSvg {
                id: imageForward
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter

                visible: listMode
                color: boxDevice.hasData ? Theme.colorHighContrast : Theme.colorSubText
                source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentPlantSensor

        Row {
            id: rectangleSensors
            height: rowRight.height
            spacing: 7

            property int sensorWidth: isPhone ? 9 : (hugeMode ? 12 : 10)
            property int sensorRadius: hugeMode ? 3 : 2

            function initData() { }
            function updateData() { }

            Item {
                id: hygro
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: hasHygro

                Rectangle {
                    anchors.fill: parent
                    radius: rectangleSensors.sensorRadius
                    color: Theme.colorBlue
                    opacity: 0.33
                    border.width: 1
                    border.color: Qt.darker(color, 1.1)
                }
                Rectangle {
                    id: hygro_data
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: UtilsNumber.normalize(boxDevice.soilMoisture,
                                                  boxDevice.soilMoisture_limitMin - 1,
                                                  boxDevice.soilMoisture_limitMax) * rowRight.height

                    color: Theme.colorBlue
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }

            Item {
                id: cond
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: hasHygro

                Rectangle {
                    anchors.fill: parent
                    radius: rectangleSensors.sensorRadius
                    color: Theme.colorRed
                    opacity: 0.33
                    border.width: 1
                    border.color: Qt.darker(color, 1.1)
                }
                Rectangle {
                    id: cond_data
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: UtilsNumber.normalize(boxDevice.soilConductivity,
                                                  boxDevice.soilConductivity_limitMin,
                                                  boxDevice.soilConductivity_limitMax) * rowRight.height

                    color: Theme.colorRed
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }

            Item {
                id: temp
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Rectangle {
                    anchors.fill: parent
                    radius: rectangleSensors.sensorRadius
                    color: Theme.colorGreen
                    opacity: 0.33
                    border.width: 1
                    border.color: Qt.darker(color, 1.1)
                }
                Rectangle {
                    id: temp_data
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: UtilsNumber.normalize(boxDevice.temperatureC,
                                                  boxDevice.temperature_limitMin - 1,
                                                  boxDevice.temperature_limitMax) * rowRight.height

                    color: Theme.colorGreen
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }

            Item {
                id: lumi
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: boxDevice.hasLuminositySensor

                Rectangle {
                    anchors.fill: parent
                    radius: rectangleSensors.sensorRadius
                    color: Theme.colorYellow
                    opacity: 0.33
                    border.width: 1
                    border.color: Qt.darker(color, 1.1)
                }
                Rectangle {
                    id: lumi_data
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: UtilsNumber.normalize(boxDevice.luminosityLux,
                                                  boxDevice.luminosityLux_limitMin,
                                                  boxDevice.luminosityLux_limitMax) * rowRight.height

                    color: Theme.colorYellow
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }
        }
    }

    ////////////////

    Component {
        id: componentText_1l

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            function initData() { }

            function updateData() {
                if (boxDevice.isEnvironmentalSensor) {
                    if (boxDevice.hasGeigerCounter) {
                        text.text = boxDevice.radioactivityH.toFixed(2)
                        unit.text = qsTr("µSv/h")
                    } else if (boxDevice.hasTemperatureSensor) {
                        text.text = boxDevice.temperature.toFixed(1)
                        unit.text = "°"
                    }
                } else {
                    if (boxDevice.hasTemperatureSensor) {
                        text.text = boxDevice.temperature.toFixed(1)
                        unit.text = "°"
                    }
                    else if (boxDevice.hasHumiditySensor) {
                        text.text = boxDevice.humidity.toFixed(0)
                        unit.text = "%"
                    }
                    else if (boxDevice.hasPressureSensor) {
                        text.text = boxDevice.pressure.toFixed(0)
                        unit.text = qsTr("hPa")
                    }
                }
            }

            Text {
                id: text
                anchors.verticalCenter: parent.verticalCenter

                textFormat: Text.PlainText
                color: Theme.colorText
                font.letterSpacing: -1.4
                font.pixelSize: hugeMode ? 28 : 24
            }
            Text {
                id: unit
                anchors.verticalCenter: parent.verticalCenter

                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.letterSpacing: -1.4
                font.pixelSize: hugeMode ? 24 : 20
            }
        }
    }

    ////////////////

    Component {
        id: componentText_2l

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            function initData() { }

            function updateData() {
                if (boxDevice.temperature > -40) textOne.text = boxDevice.temperature.toFixed(1) + "°"
                if (boxDevice.humidity > 0) textTwo.text = boxDevice.humidity.toFixed(0) + "%"
            }

            Text {
                id: textOne
                anchors.right: parent.right

                textFormat: Text.PlainText
                color: Theme.colorText
                font.letterSpacing: -1.4
                font.pixelSize: hugeMode ? 32 : 28
            }

            Text {
                id: textTwo
                anchors.right: parent.right

                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.pixelSize: hugeMode ? 26 : 22
            }
        }
    }

    ////////////////

    Component {
        id: componentEnvironmentalGauge

        Item {
            width: rowRight.height
            height: width
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 4

            property string primarySensor: "voc"
            property int limitMin: -1
            property int limitMax: -1

            function initData() {
                // primary sensor
                primarySensor = boxDevice.primary
                if (primarySensor.length <= 0) {
                    if (boxDevice.hasVocSensor) primarySensor = "voc"
                    else if (boxDevice.hasCo2Sensor) primarySensor = "co2"
                    else if (boxDevice.hasPM10Sensor) primarySensor = "pm10"
                    else if (boxDevice.hasPM25Sensor) primarySensor = "pm25"
                    else if (boxDevice.hasPM1Sensor) primarySensor = "pm1"
                    else if (boxDevice.hasHchoSensor) primarySensor = "hcho"
                    else if (boxDevice.hasGeigerCounter) primarySensor = "nuclear"
                    else primarySensor = "hygrometer"
                }

                // values
                if (primarySensor === "voc") {
                    gaugeLegend.text = qsTr("VOC")
                    gaugeValue.from = 0
                    gaugeValue.to = 1500
                    limitMin = 500
                    limitMax = 1000
                    gaugeValue.value = boxDevice.voc
                } else if (primarySensor === "hcho") {
                    gaugeLegend.text = qsTr("HCHO")
                    gaugeValue.from = 0
                    gaugeValue.to = 1000
                    limitMin = 250
                    limitMax = 750
                    gaugeValue.value = boxDevice.hcho
                } else if (primarySensor === "co2") {
                    gaugeLegend.text = boxDevice.haseCo2Sensor ? qsTr("eCO₂") : qsTr("CO₂")
                    gaugeValue.from = 0
                    gaugeValue.to = 3000
                    limitMin = 1000
                    limitMax = 2000
                    gaugeValue.value = boxDevice.co2
                } else if (primarySensor === "pm10") {
                    gaugeLegend.text = qsTr("PM10")
                    gaugeValue.from = 0
                    gaugeValue.to = 500
                    limitMin = 100
                    limitMax = 350
                    gaugeValue.value = boxDevice.pm10
                } else if (primarySensor === "pm25") {
                    gaugeLegend.text = qsTr("PM2.5")
                    gaugeValue.from = 0
                    gaugeValue.to = 240
                    limitMin = 60
                    limitMax = 120
                    gaugeValue.value = boxDevice.pm25
                } else if (primarySensor === "pm1") {
                    gaugeLegend.text = qsTr("PM1")
                    gaugeValue.from = 0
                    gaugeValue.to = 240
                    limitMin = 60
                    limitMax = 120
                    gaugeValue.value = boxDevice.pm1
                }
            }

            function updateData() {
                // value
                if (primarySensor === "voc") gaugeValue.value = boxDevice.voc
                else if (primarySensor === "hcho") gaugeValue.value = boxDevice.hcho
                else if (primarySensor === "co2") gaugeValue.value = boxDevice.co2
                else if (primarySensor === "co") gaugeValue.value = boxDevice.co
                else if (primarySensor === "o2") gaugeValue.value = boxDevice.o2
                else if (primarySensor === "o3") gaugeValue.value = boxDevice.o3
                else if (primarySensor === "no2") gaugeValue.value = boxDevice.no2
                else if (primarySensor === "so2") gaugeValue.value = boxDevice.so2
                else if (primarySensor === "pm10") gaugeValue.value = boxDevice.pm10
                else if (primarySensor === "pm25") gaugeValue.value = boxDevice.pm25
                else if (primarySensor === "pm1") gaugeValue.value = boxDevice.pm1

                // limits
                if (limitMin > 0 && limitMax > 0) {
                    var clr = Theme.colorGreen
                    if (gaugeValue.value > limitMax) clr = Theme.colorRed
                    else if (gaugeValue.value > limitMin) clr = Theme.colorOrange
                    gaugeValue.arcColor = clr
                    gaugeValue.backgroundColor = clr
                }
            }

            Text {
                id: gaugeLegend
                anchors.centerIn: parent

                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }

            ProgressArc {
                id: gaugeValue
                anchors.fill: parent
                anchors.margins: isPhone ? 0 : 2

                arcWidth: isPhone ? 8 : (hugeMode ? 10 : 8)
                arcSpan: 270
                arcCap: "round"

                from: 0
                to: 1500
                value: -1

                background: true
                backgroundOpacity: 0.33
            }
        }
    }

    ////////////////

    component AlarmIndicator: IconSvg {
        width: hugeMode ? 28 : 24
        height: hugeMode ? 28 : 24
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 8
            height: width
            radius: width

            z: -1
            color: parent.color
            opacity: 0.08

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PropertyAnimation { to: 0.16; duration: 1500; }
                PropertyAnimation { to: 0.08; duration: 1500; }
            }
        }
    }

    ////////////////
}
