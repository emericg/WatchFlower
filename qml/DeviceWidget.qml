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

    property bool wideAssMode: (width >= 380) || (isTablet && width >= 480)
    property bool bigAssMode: false
    property bool singleColumn: true

    Connections {
        target: boxDevice
        function onSensorUpdated() { initBoxData() }
        function onSensorsUpdated() { initBoxData() }
        function onCapabilitiesUpdated() { initBoxData() }
        function onStatusUpdated() { updateSensorStatus() }
        function onSettingsUpdated() { updateSensorStatus(); updateSensorSettings(); }
        function onDataUpdated() { updateSensorData() }
        function onRefreshUpdated() { updateSensorData() }
        function onLimitsUpdated() { updateSensorData() }
    }
    Connections {
        target: ThemeEngine
        function onCurrentThemeChanged() {
            updateSensorSettings()
            updateSensorStatus()
            updateSensorData()
        }
    }
    Connections {
        target: settingsManager
        function onAppLanguageChanged() {
            updateSensorSettings()
            updateSensorStatus()
            updateSensorData()
        }
        function onTempUnitChanged() {
            if (loaderIndicators.item) loaderIndicators.item.updateData()
        }
    }

    Component.onCompleted: initBoxData()

    ////////////////////////////////////////////////////////////////////////////

    function initBoxData() {
        //console.log("DeviceWidget // initBoxData() >> " + boxDevice)

        // Set icon
        imageDevice.source = UtilsDeviceSensors.getDeviceIcon(boxDevice, hasHygro)

        // Load indicators
        if (!loaderIndicators.sourceComponent) {
            if (boxDevice.isPlantSensor) {
                loaderIndicators.sourceComponent = componentPlantSensor
            } else if (boxDevice.isThermometer) {
                if (boxDevice.hasHumiditySensor)
                    loaderIndicators.sourceComponent = componentText_2l
                else
                    loaderIndicators.sourceComponent = componentText_1l
            } else if (boxDevice.isEnvironmentalSensor) {
                if (boxDevice.hasSetting("primary")) {
                    var primary = boxDevice.getSetting("primary")
                    if (primary === "hygrometer") {
                        if (boxDevice.hasHumiditySensor)
                            loaderIndicators.sourceComponent = componentText_2l
                        else
                            loaderIndicators.sourceComponent = componentText_1l
                    } else if (primary === "radioactivity") {
                        loaderIndicators.sourceComponent = componentText_1l
                    } else {
                        loaderIndicators.sourceComponent = componentEnvironmentalGauge
                    }
                }
            }

            if (loaderIndicators.item) {
                loaderIndicators.item.initData()
                loaderIndicators.item.updateData()
            }
        }

        updateSensorSettings()
        updateSensorStatus()
        updateSensorData()
    }

    function updateSensorStatus() {
        // Text
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
        if (!boxDevice.deviceEnabled) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Disabled")
        }

        // Image
        if (!boxDevice.isDataToday()) {
            if (boxDevice.status === DeviceUtils.DEVICE_QUEUED) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
            } else if (boxDevice.status === DeviceUtils.DEVICE_CONNECTING) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
            } else if (boxDevice.status === DeviceUtils.DEVICE_CONNECTED) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
            } else if (boxDevice.status >= DeviceUtils.DEVICE_WORKING) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
            } else {
                imageStatus.source = "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
            }
        }
    }

    function updateSensorSettings() {
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
        textLocation.font.pixelSize = bigAssMode ? 20 : 18
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

    function updateSensorIcon() {
        if (boxDevice.isPlantSensor) {
            if (hasHygro) {
                if (boxDevice.deviceName === "ropot" || boxDevice.deviceName === "Parrot pot")
                    imageDevice.source = "qrc:/assets/icons_custom/pot_flower-24px.svg"
                else
                    imageDevice.source = "qrc:/assets/icons_material/outline-local_florist-24px.svg"
            } else {
                if (boxDevice.deviceName === "ropot" || boxDevice.deviceName === "Parrot pot")
                    imageDevice.source = "qrc:/assets/icons_custom/pot_empty-24px.svg"
                else
                    imageDevice.source = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
            }
        }
    }

    function updateSensorWarnings() {
        // Warnings icons (for sensors with available data)

        if (boxDevice.isDataToday()) {

            if (boxDevice.isPlantSensor) {

                alarmWater.visible = false
                alarmFreeze.visible = false

                // Water me notif
                if (hasHygro && boxDevice.soilMoisture < boxDevice.soilMoisture_limitMin) {
                    alarmWater.visible = true
                    alarmWater.source = "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                    alarmFreeze.color = Theme.colorBlue
                } else if (boxDevice.soilMoisture > boxDevice.soilMoisture_limitMax) {
                    alarmWater.visible = true
                    alarmWater.source = "qrc:/assets/icons_material/duotone-water_full-24px.svg"
                    alarmFreeze.color = Theme.colorYellow
                }

                // Extreme temperature notif
                if (boxDevice.temperatureC > 40) {
                    alarmFreeze.visible = true
                    alarmFreeze.color = Theme.colorYellow
                    alarmFreeze.source = "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                } else if (boxDevice.temperatureC <= 2 && boxDevice.temperatureC > -80) {
                    alarmFreeze.visible = true
                    alarmFreeze.source = "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"

                    if (boxDevice.temperatureC <= -4)
                        alarmFreeze.color = Theme.colorRed
                    else if (boxDevice.temperatureC <= -2)
                        alarmFreeze.color = Theme.colorYellow
                    else
                        alarmFreeze.color = Theme.colorBlue
                }

            } else if (boxDevice.isEnvironmentalSensor) {

                alarmVentilate.visible = false
                alarmRadiation.visible = false
                //alarmWarning.visible = false

                // Air warning
                if ((boxDevice.hasVocSensor && boxDevice.voc > 1000) ||
                    (boxDevice.hasHchoSensor && boxDevice.hcho > 1000) ||
                    (boxDevice.hasCo2Sensor && boxDevice.co2 > 1500)) {
                    alarmVentilate.visible = true
                    alarmVentilate.color = Theme.colorRed
                } else if ((boxDevice.hasVocSensor && boxDevice.voc > 500) ||
                           (boxDevice.hasHchoSensor && boxDevice.hcho > 500) ||
                           (boxDevice.hasCo2Sensor && boxDevice.co2 > 850) ||
                           (boxDevice.hasPM25Sensor && boxDevice.pm25 > 120) ||
                           (boxDevice.hasPM10Sensor && boxDevice.pm10 > 350)) {
                    alarmVentilate.visible = true
                    alarmVentilate.color = Theme.colorYellow
                }

                // Radiation warning
                if (boxDevice.hasGeigerCounter) {
                    if (boxDevice.radioactivityM > 1) {
                        alarmRadiation.visible = true
                        if (boxDevice.radioactivityM > 10)
                            alarmRadiation.color = Theme.colorRed
                        else
                            alarmRadiation.color = Theme.colorYellow
                    }
                }
            }
        }
    }

    function updateSensorData() {
        updateSensorIcon()
        updateSensorWarnings()
        if (loaderIndicators.item) loaderIndicators.item.updateData()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // bottomSeparator
        height: 1
        anchors.left: parent.left
        anchors.leftMargin: -6
        anchors.right: parent.right
        anchors.rightMargin: -6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        visible: singleColumn
        color: Theme.colorSeparator
    }

    Rectangle {
        id: deviceWidgetRectangleSeparator
        anchors.fill: deviceWidgetRectangle
        anchors.leftMargin: singleColumn ? -12 : 0
        anchors.rightMargin: singleColumn ? -12 : 0
        anchors.topMargin: singleColumn ? -6 : 0
        anchors.bottomMargin: singleColumn ? -6 : 0

        radius: 4
        border.width: 2
        border.color: {
            if (singleColumn) return "transparent"
            if (mousearea.containsPress) return Theme.colorSecondary
            return Theme.colorSeparator
        }
        Behavior on border.color { ColorAnimation { duration: 133 } }

        color: boxDevice.selected ? Theme.colorSeparator : Theme.colorDeviceWidget
        Behavior on color { ColorAnimation { duration: 133 } }

        opacity: boxDevice.selected ? 0.5 : (singleColumn ? 0 : 1)
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: deviceWidgetRectangle
        anchors.fill: parent
        anchors.margins: 6

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
                    //if (boxDevice.isDataAvailable()) {
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
                    //}
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
            anchors.topMargin: bigAssMode ? 16 : 8
            anchors.left: parent.left
            anchors.leftMargin: bigAssMode ? (singleColumn ? 4 : 16) : (singleColumn ? 6 : 14)
            anchors.right: (rowRight.width > 0) ? rowRight.left : imageStatus.left
            anchors.rightMargin: singleColumn ? 0 : 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: bigAssMode ? 16 : 8

            spacing: bigAssMode ? (singleColumn ? 20 : 12) : (singleColumn ? 24 : 10)

            IconSvg {
                id: imageDevice
                width: bigAssMode ? 32 : 24
                height: bigAssMode ? 32 : 24
                anchors.verticalCenter: parent.verticalCenter

                color: Theme.colorHighContrast
                visible: (wideAssMode || bigAssMode)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: textTitle
                    width: rowLeft.width - imageDevice.width - rowLeft.spacing

                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.pixelSize: bigAssMode ? 22 : 20
                    //font.capitalization: Font.Capitalize
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Text {
                    id: textLocation
                    width: rowLeft.width - imageDevice.width - rowLeft.spacing

                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.pixelSize: bigAssMode ? 20 : 18
                    //font.capitalization: Font.Capitalize
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Row {
                    id: row
                    height: bigAssMode ? 26 : 22
                    anchors.left: parent.left
                    spacing: 8

                    IconSvg {
                        id: imageBattery
                        width: bigAssMode ? 30 : 28
                        height: bigAssMode ? 32 : 30
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
                        font.pixelSize: bigAssMode ? 16 : 15

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

            IconSvg {
                id: alarmWater
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                visible: false
                source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                color: Theme.colorBlue
            }
            IconSvg {
                id: alarmFreeze
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                visible: false
                source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                color: Theme.colorYellow
            }
            IconSvg {
                id: alarmVentilate
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                visible: false
                source: "qrc:/assets/icons_material/baseline-air-24px.svg"
                color: Theme.colorYellow

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: width
                    radius: width
                    z: -1

                    color: parent.color

                    SequentialAnimation on opacity {
                        running: visible
                        loops: Animation.Infinite

                        PropertyAnimation { to: 0.1; duration: 1000; }
                        PropertyAnimation { to: 0.33; duration: 1000; }
                    }
                }
            }
            IconSvg {
                id: alarmRadiation
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                visible: false
                asynchronous: true
                source: "qrc:/assets/icons_custom/nuclear_icon.svg"
                color: Theme.colorYellow

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: width
                    radius: width
                    z: -1

                    color: Qt.lighter(parent.color, 1.66)

                    SequentialAnimation on opacity {
                        running: visible
                        alwaysRunToEnd: true
                        loops: Animation.Infinite

                        PropertyAnimation { to: 0; duration: 1000; }
                        PropertyAnimation { to: 1; duration: 1000; }
                    }
                }
            }
/*
            IconSvg {
                id: alarmWarning
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                visible: false
                asynchronous: true
                source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                color: Theme.colorYellow
            }
*/
        }

        ////////////////

        Row {
            id: rowRight
            anchors.top: parent.top
            anchors.topMargin: bigAssMode ? 16 : 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: bigAssMode ? 16 : 8
            anchors.right: parent.right
            anchors.rightMargin: singleColumn ? (wideAssMode ? 0 : -4) : (bigAssMode ? 14 : 10)

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

            IconSvg {
                id: imageForward
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter

                visible: singleColumn
                color: boxDevice.hasData ? Theme.colorHighContrast : Theme.colorSubText
                source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
            }
        }

        ////////////////

        IconSvg {
            id: imageStatus
            width: 32
            height: 32
            anchors.right: parent.right
            anchors.rightMargin: singleColumn ? 56 : 36
            anchors.verticalCenter: parent.verticalCenter

            visible: !boxDevice.hasDataToday
            color: Theme.colorIcon
            opacity: 0.8

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

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentPlantSensor

        Row {
            id: rectangleSensors
            height: rowRight.height

            spacing: 8

            property int sensorWidth: isPhone ? 8 : (bigAssMode ? 12 : 10)
            property int sensorRadius: bigAssMode ? 3 : 2

            function initData() {
                //
            }
            function updateData() {
                //
            }

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

                    height: UtilsNumber.normalize(boxDevice.soilMoisture, boxDevice.soilMoisture_limitMin - 1, boxDevice.soilMoisture_limitMax) * rowRight.height

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

                    height: UtilsNumber.normalize(boxDevice.soilConductivity, boxDevice.soilConductivity_limitMin, boxDevice.soilConductivity_limitMax) * rowRight.height

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

                    height: UtilsNumber.normalize(boxDevice.temperatureC, boxDevice.temperature_limitMin - 1, boxDevice.temperature_limitMax) * rowRight.height

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

                    height: UtilsNumber.normalize(boxDevice.luminosityLux, boxDevice.luminosityLux_limitMin, boxDevice.luminosityLux_limitMax) * rowRight.height

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
                        unit.text = "hPa"
                    }
                }
            }

            Text {
                id: text
                anchors.verticalCenter: parent.verticalCenter

                textFormat: Text.PlainText
                color: Theme.colorText
                font.letterSpacing: -1.4
                font.pixelSize: bigAssMode ? 28 : 24
            }
            Text {
                id: unit
                anchors.verticalCenter: parent.verticalCenter

                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.letterSpacing: -1.4
                font.pixelSize: bigAssMode ? 24 : 20
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
                font.pixelSize: bigAssMode ? 32 : 28
            }

            Text {
                id: textTwo
                anchors.right: parent.right

                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.pixelSize: bigAssMode ? 26 : 22
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

            property string primaryValue: "voc"
            property int limitMin: -1
            property int limitMax: -1

            function initData() {
                if (boxDevice.hasSetting("primary")) {
                    primaryValue = boxDevice.getSetting("primary")
                } else {
                    if (boxDevice.hasVocSensor) primaryValue = "voc"
                    else if (boxDevice.hasCo2Sensor) primaryValue = "co2"
                    else if (boxDevice.hasPM10Sensor) primaryValue = "pm10"
                    else if (boxDevice.hasHchoSensor) primaryValue = "hcho"
                    else if (boxDevice.hasGeigerCounter) primaryValue = "nuclear"
                    else primaryValue = "hygrometer"
                }

                if (primaryValue === "voc") {
                    gaugeLegend.text = qsTr("VOC")
                    gaugeValue.from = 0
                    gaugeValue.to = 1500
                    limitMin = 500
                    limitMax = 1000
                    gaugeValue.value = boxDevice.voc
                } else if (primaryValue === "hcho") {
                    gaugeLegend.text = qsTr("HCHO")
                    gaugeValue.from = 0
                    gaugeValue.to = 1000
                    limitMin = 250
                    limitMax = 750
                    gaugeValue.value = boxDevice.hcho
                } else if (primaryValue === "co2") {
                    gaugeLegend.text = boxDevice.haseCo2Sensor ? qsTr("eCO₂") : qsTr("CO₂")
                    gaugeValue.from = 0
                    gaugeValue.to = 2000
                    limitMin = 850
                    limitMax = 1500
                    gaugeValue.value = boxDevice.co2
                } else if (primaryValue === "pm25") {
                    gaugeLegend.text = qsTr("PM2.5")
                    gaugeValue.from = 0
                    gaugeValue.to = 240
                    limitMin = 60
                    limitMax = 120
                    gaugeValue.value = boxDevice.pm25
                } else if (primaryValue === "pm10") {
                    gaugeLegend.text = qsTr("PM10")
                    gaugeValue.from = 0
                    gaugeValue.to = 500
                    limitMin = 100
                    limitMax = 350
                    gaugeValue.value = boxDevice.pm10
                }
            }

            function updateData() {
                if (boxDevice.hasSetting("primary")) {
                    primaryValue = boxDevice.getSetting("primary")
                }

                // value
                if (primaryValue === "voc") gaugeValue.value = boxDevice.voc
                else if (primaryValue === "hcho") gaugeValue.value = boxDevice.hcho
                else if (primaryValue === "co2") gaugeValue.value = boxDevice.co2
                else if (primaryValue === "co") gaugeValue.value = boxDevice.co
                else if (primaryValue === "o2") gaugeValue.value = boxDevice.o2
                else if (primaryValue === "o3") gaugeValue.value = boxDevice.o3
                else if (primaryValue === "no2") gaugeValue.value = boxDevice.no2
                else if (primaryValue === "so2") gaugeValue.value = boxDevice.so2
                else if (primaryValue === "pm1") gaugeValue.value = boxDevice.pm1
                else if (primaryValue === "pm25") gaugeValue.value = boxDevice.pm25
                else if (primaryValue === "pm10") gaugeValue.value = boxDevice.pm10

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

                arcWidth: isPhone ? 8 : (bigAssMode ? 10 : 8)
                arcSpan: 270

                from: 0
                to: 1500
                value: -1

                background: true
                backgroundOpacity: 0.33
            }
        }
    }

    ////////////////
}
