import QtQuick 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber
import "qrc:/js/UtilsDeviceBLE.js" as UtilsDeviceBLE

Item {
    id: deviceWidget
    implicitWidth: 640
    implicitHeight: 128

    property var boxDevice: pointer
    property bool hasHygro: false

    property bool wideAssMode: (width >= 380) || (isTablet && width >= 480)
    property bool bigAssMode: false
    property bool singleColumn: true

    Connections {
        target: boxDevice
        onStatusUpdated: { updateSensorStatus() }
        onSensorUpdated: { initBoxData() }
        onBatteryUpdated: { updateSensorBattery() }
        onDataUpdated: { updateSensorData() }
        onLimitsUpdated: { updateSensorData() }
    }
    Connections {
        target: Theme
        onCurrentThemeChanged: {
            updateSensorStatus()
            updateSensorBattery()
            updateSensorData()
        }
    }
    Connections {
        target: devicesView
        onBigWidgetChanged: {
            updateSensorData()
        }
    }
    Connections {
        target: settingsManager
        onAppLanguageChanged: {
            updateSensorStatus()
            updateSensorData()
        }
    }

    Component.onCompleted: initBoxData()

    ////////////////////////////////////////////////////////////////////////////

    function initBoxData() {
        // Set icon
        if (boxDevice.isPlantSensor) {
            var hasHygro_short = (boxDevice.deviceSoilMoisture > 0 || boxDevice.deviceSoilConductivity > 0)
            var hasHygro_long = (boxDevice.hasData("soilMoisture") || boxDevice.hasData("soilConductivity"))
            hasHygro = hasHygro_short || hasHygro_long

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
        } else if (boxDevice.isThermometer) {
            if (boxDevice.deviceName === "MJ_HT_V1" || boxDevice.deviceName === "ClearGrass Temp & RH" ||
                boxDevice.deviceName === "Qingping Temp & RH M" || boxDevice.deviceName === "Qingping Temp & RH H" ||
                boxDevice.deviceName === "ThermoBeacon") {
                imageDevice.source = "qrc:/assets/icons_material/baseline-trip_origin-24px.svg"
            } else if (boxDevice.deviceName === "LYWSD02" ||
                       boxDevice.deviceName === "MHO-C303") {
                imageDevice.source = "qrc:/assets/icons_material/baseline-crop_16_9-24px.svg"
            } else if (boxDevice.deviceName === "LYWSD03MMC" ||
                       boxDevice.deviceName === "MHO-C401") {
                imageDevice.source = "qrc:/assets/icons_material/baseline-crop_square-24px.svg"
            } else {
                imageDevice.source = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
            }
        } else if (boxDevice.isEnvironmentalSensor) {
            if (boxDevice.deviceName === "GeigerCounter") {
                imageDevice.source = "qrc:/assets/icons_custom/nuclear_icon.svg"
            } else {
                imageDevice.source = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
            }
        } else {
            imageDevice.source = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
        }

        updateSensorStatus()
        updateSensorBattery()
        updateSensorData()
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

    function updateSensorBattery() {
        imageBattery.visible = (boxDevice.hasBattery && boxDevice.deviceBattery >= 0)
        imageBattery.source = UtilsDeviceBLE.getDeviceBatteryIcon(boxDevice.deviceBattery)
    }

    function updateSensorStatus() {
        // Text
        textStatus.text = UtilsDeviceBLE.getDeviceStatusText(boxDevice.status)
        textStatus.color = UtilsDeviceBLE.getDeviceStatusColor(boxDevice.status)

        if (boxDevice.status === DeviceUtils.DEVICE_OFFLINE) {
            if (boxDevice.isDataFresh()) {
                textStatus.color = Theme.colorGreen
                textStatus.text = qsTr("Synced")
            } else if (boxDevice.isDataAvailable()) {
                textStatus.color = Theme.colorYellow
                textStatus.text = qsTr("Synced")
            }
        }
        // Image
        if (!boxDevice.isDataAvailable()) {
            if (boxDevice.status === DeviceUtils.DEVICE_QUEUED) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                refreshAnimation.running = false
            } else if (boxDevice.status === DeviceUtils.DEVICE_CONNECTING || boxDevice.status === DeviceUtils.DEVICE_CONNECTED) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                refreshAnimation.running = true
            } else if (boxDevice.status >= DeviceUtils.DEVICE_WORKING) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
                refreshAnimation.running = true
            } else {
                imageStatus.source = "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                refreshAnimation.running = false
            }
        }
    }

    function updateSensorSettings() {
        // Title
        if (boxDevice.isPlantSensor) {
            if (boxDevice.devicePlantName !== "")
                textTitle.text = boxDevice.devicePlantName
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
                //var addr = boxDevice.deviceAddress.toUpperCase()
                //if (Qt.platform.os === "ios") {
                //    addr = addr.slice(1, -1)
                //    if (isPhone || (isTablet && singleColumn)) {
                //        addr = addr.substr(0, addr.lastIndexOf('-'))
                //        addr += "-..."
                //    }
                //    textLocation.font.pixelSize = 12
                //} else if (Qt.platform.os === "osx") {
                //    addr = addr.slice(1, -1)
                //    textLocation.font.pixelSize = 13
                //}
            } else {
                textLocation.visible = true
                textLocation.text = boxDevice.deviceAddress
            }
        }
    }

    function updateSensorData() {

        if (boxDevice.isPlantSensor) {
            var hasHygro_short = (boxDevice.deviceSoilMoisture > 0 || boxDevice.deviceSoilConductivity > 0)
            var hasHygro_long = (boxDevice.hasData("soilMoisture") || boxDevice.hasData("soilConductivity"))
            hasHygro = hasHygro_short || hasHygro_long
        }

        updateSensorIcon()
        updateSensorSettings()

        water.visible = false
        temp.visible = false
        ventilate.visible = false
        nuclear.visible = false
        warning.visible = false

        // Warnings icons (for sensors with available data)
        if (boxDevice.isDataAvailable()) {

            if (boxDevice.isPlantSensor) {

                // Water me notif
                if (hasHygro && boxDevice.deviceSoilMoisture < boxDevice.limitHygroMin) {
                    water.visible = true
                    water.source = "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                    temp.color = Theme.colorBlue
                } else if (boxDevice.deviceSoilMoisture > boxDevice.limitHygroMax) {
                    water.visible = true
                    water.source = "qrc:/assets/icons_material/duotone-water_full-24px.svg"
                    temp.color = Theme.colorYellow
                }

                // Extreme temperature notif
                if (boxDevice.deviceTempC > 40) {
                    temp.visible = true
                    temp.color = Theme.colorYellow
                    temp.source = "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                } else if (boxDevice.deviceTempC <= 2 && boxDevice.deviceTempC > -80) {
                    temp.visible = true
                    temp.source = "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"

                    if (boxDevice.deviceTempC <= -4)
                        temp.color = Theme.colorRed
                    else if (boxDevice.deviceTempC <= -2)
                        temp.color = Theme.colorYellow
                    else
                        temp.color = Theme.colorBlue
                }

            } else if (boxDevice.isEnvironmentalSensor) {

                // Air warning
                if (boxDevice.hasVocSensor) {
                    if (boxDevice.voc > 500) {
                        ventilate.visible = true
                        if (boxDevice.voc > 1000)
                            ventilate.color = Theme.colorRed
                        else
                            ventilate.color = Theme.colorYellow
                    }
                }

                // Radiation warning
                if (boxDevice.hasGeigerCounter) {
                    if (boxDevice.radioactivityM > 1) {
                        nuclear.visible = true

                        if (boxDevice.radioactivityM > 10)
                            nuclear.color = Theme.colorRed
                        else
                            nuclear.color = Theme.colorYellow
                    }
                }
            }
        }

        // Has data? always display them
        if (boxDevice.isDataAvailable()) {
            if (boxDevice.isPlantSensor) {
                if (!loaderIndicators.sourceComponent) loaderIndicators.sourceComponent = componentPlantSensor
            } else if (boxDevice.isThermometer) {
                if (!loaderIndicators.sourceComponent) loaderIndicators.sourceComponent = componentThermometer
            } else if (boxDevice.isEnvironmentalSensor) {
                if (!loaderIndicators.sourceComponent) {
                    if (boxDevice.deviceName === "GeigerCounter")
                        loaderIndicators.sourceComponent = componentThermometer
                    else
                        loaderIndicators.sourceComponent = componentEnvironmentalGauge
                }
            }
            loaderIndicators.item.updateData()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: bottomSeparator
        height: 1
        anchors.left: parent.left
        anchors.leftMargin: -6
        anchors.right: parent.right
        anchors.rightMargin: -6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

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
        border.color: singleColumn ? "transparent" : Theme.colorSeparator

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

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            onClicked: {
                if (typeof boxDevice === "undefined" || !boxDevice) return

                // multi selection
                if (mouse.button === Qt.MiddleButton) {
                    if (!boxDevice.selected) {
                        screenDeviceList.selectDevice(index)
                    } else {
                        screenDeviceList.deselectDevice(index)
                    }
                    return;
                }

                if (mouse.button === Qt.LeftButton) {
                    // multi selection
                    if ((mouse.modifiers & Qt.ControlModifier) ||
                        (screenDeviceList.selectionMode)) {
                        if (!boxDevice.selected) {
                            screenDeviceList.selectDevice(index)
                        } else {
                            screenDeviceList.deselectDevice(index)
                        }
                        return;
                    }

                    // regular click
                    if (boxDevice.hasData()) {
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
                }
            }

            onPressAndHold: {
                // multi selection
                if (!boxDevice.selected) {
                    utilsApp.vibrate(25)
                    screenDeviceList.selectDevice(index)
                } else {
                    screenDeviceList.deselectDevice(index)
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

            clip: true
            spacing: bigAssMode ? (singleColumn ? 20 : 12) : (singleColumn ? 24 : 10)

            ImageSvg {
                id: imageDevice
                width: bigAssMode ? 32 : 24
                height: bigAssMode ? 32 : 24
                anchors.verticalCenter: parent.verticalCenter

                color: Theme.colorHighContrast
                visible: (wideAssMode || bigAssMode)
                fillMode: Image.PreserveAspectFit
            }

            Column {
                id: column
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: textTitle
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: bigAssMode ? 0 : 8

                    color: Theme.colorText
                    font.capitalization: Font.Capitalize
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: bigAssMode ? 22 : 20
                }

                Text {
                    id: textLocation
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: bigAssMode ? 0 : 8

                    color: Theme.colorSubText
                    font.capitalization: Font.Capitalize
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: bigAssMode ? 20 : 18
                }

                Row {
                    id: row
                    height: bigAssMode ? 26 : 22
                    anchors.left: parent.left
                    spacing: 8

                    ImageSvg {
                        id: imageBattery
                        width: bigAssMode ? 30 : 28
                        height: bigAssMode ? 32 : 30
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        rotation: 90
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        id: textStatus
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorGreen
                        font.pixelSize: bigAssMode ? 16 : 15

                        SequentialAnimation on opacity {
                            id: opa
                            loops: Animation.Infinite
                            alwaysRunToEnd: true
                            running: (boxDevice.status !== DeviceUtils.DEVICE_OFFLINE &&
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

        Row {
            id: lilIcons
            height: 24
            spacing: 8
            anchors.right: rowRight.left
            anchors.rightMargin: 12
            anchors.verticalCenter: rowRight.verticalCenter
            layoutDirection: Qt.RightToLeft

            visible: boxDevice.dataAvailable
            //visible: (water.visible || temp.visible || ventilate.visible || nuclear.visible || warning.visible)

            ImageSvg {
                id: water
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                color: Theme.colorBlue
            }

            ImageSvg {
                id: temp
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                color: Theme.colorYellow
            }
            ImageSvg {
                id: ventilate
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-air-24px.svg"
                color: Theme.colorYellow
            }
            ImageSvg {
                id: nuclear
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_custom/nuclear_icon.svg"
                color: Theme.colorYellow
            }
            ImageSvg {
                id: warning
                width: bigAssMode ? 28 : 24
                height: bigAssMode ? 28 : 24
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                color: Theme.colorYellow
            }
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

            z: 1
            spacing: 8

            ////

            Loader {
                id: loaderIndicators
                anchors.verticalCenter: parent.verticalCenter

                sourceComponent: null
            }

            ////

            ImageSvg {
                id: imageForward
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                z: 1
                visible: singleColumn
                color: boxDevice.hasData() ? Theme.colorHighContrast : Theme.colorSubText
                source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
            }
        }

        ////////////////

        ImageSvg {
            id: imageStatus
            width: 32
            height: 32
            anchors.right: parent.right
            anchors.rightMargin: singleColumn ? 56 : 36
            anchors.verticalCenter: parent.verticalCenter

            visible: !boxDevice.dataAvailable
            color: Theme.colorIcon

            SequentialAnimation on opacity {
                id: refreshAnimation
                loops: Animation.Infinite
                running: parent.visible
                alwaysRunToEnd: true
                OpacityAnimator { from: 1; to: 0; duration: 750 }
                OpacityAnimator { from: 0; to: 1; duration: 750 }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentPlantSensor

        Row {
            id: rectangleSensors
            height: rowRight.height

            clip: true
            spacing: 8
            visible: boxDevice.dataAvailable

            property int sensorWidth: isPhone ? 8 : (bigAssMode ? 12 : 10)
            property int sensorRadius: bigAssMode ? 3 : 2

            function updateData() {
                hygro_data.height = UtilsNumber.normalize(boxDevice.deviceSoilMoisture, boxDevice.limitHygroMin - 1, boxDevice.limitHygroMax) * rowRight.height
                temp_data.height = UtilsNumber.normalize(boxDevice.deviceTempC, boxDevice.limitTempMin - 1, boxDevice.limitTempMax) * rowRight.height
                lumi_data.height = UtilsNumber.normalize(boxDevice.deviceLuminosity, boxDevice.limitLuxMin, boxDevice.limitLuxMax) * rowRight.height
                cond_data.height = UtilsNumber.normalize(boxDevice.deviceSoilConductivity, boxDevice.limitConduMin, boxDevice.limitConduMax) * rowRight.height

                hygro_bg.visible = hasHygro
                lumi_bg.visible = boxDevice.hasLuminositySensor
                cond_bg.visible = hasHygro
            }

            Item {
                id: hygro_bg
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg1
                    anchors.fill: parent
                    color: Theme.colorBlue
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: hygro_data
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    color: Theme.colorBlue
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }

            Item {
                id: temp_bg
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg2
                    anchors.fill: parent
                    color: Theme.colorGreen
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: temp_data
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    visible: true
                    color: Theme.colorGreen
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }

            Item {
                id: lumi_bg
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg3
                    anchors.fill: parent

                    color: Theme.colorYellow
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: lumi_data
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    color: Theme.colorYellow
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }

            Item {
                id: cond_bg
                width: rectangleSensors.sensorWidth
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg4
                    anchors.fill: parent

                    color: Theme.colorRed
                    opacity: 0.33
                    radius: rectangleSensors.sensorRadius
                }
                Rectangle {
                    id: cond_data
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.bottom: parent.bottom

                    color: Theme.colorRed
                    radius: rectangleSensors.sensorRadius
                    Behavior on height { NumberAnimation { duration: 333 } }
                }
            }
        }
    }

    ////////////////

    Component {
        id: componentThermometer

        Column {
            id: rectangleHygroTemp
            anchors.verticalCenter: parent.verticalCenter

            visible: boxDevice.dataAvailable

            function updateData() {
                if (boxDevice.hasGeigerCounter) {
                    textTemp.text = ""
                    textHygro.font.pixelSize = bigAssMode ? 24 : 22
                    textHygro.text = boxDevice.radioactivityH.toFixed(2) + " " + "µSv/h"
                } else if (boxDevice.hasVocSensor) {
                    textTemp.font.pixelSize = bigAssMode ? 28 : 26
                    textTemp.text = (boxDevice.voc).toFixed(0) + " " + "µg/m"
                    textHygro.text = boxDevice.deviceTemp.toFixed(1) + "°"
                } else {
                    textTemp.text = boxDevice.deviceTemp.toFixed(1) + "°"
                    textHygro.text = boxDevice.deviceHumidity.toFixed(0) + "%"
                }
            }

            Text {
                id: textTemp
                anchors.right: parent.right
                anchors.rightMargin: 0

                color: Theme.colorText
                font.letterSpacing: -1.4
                font.pixelSize: bigAssMode ? 32 : 30
                font.family: "Tahoma"

                Connections {
                    target: settingsManager
                    onTempUnitChanged: { textTemp.text = boxDevice.getTemp().toFixed(1) + "°"; }
                }
            }

            Text {
                id: textHygro
                anchors.right: parent.right
                anchors.rightMargin: 0

                color: Theme.colorSubText
                font.pixelSize: bigAssMode ? 26 : 24
                font.family: "Tahoma"
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

            visible: boxDevice.dataAvailable

            function updateData() {
                var clr = Theme.colorGreen

                if (boxDevice.hasVocSensor) {
                    if (boxDevice.voc > 1000) clr = Theme.colorRed
                    else if (boxDevice.voc > 500) clr = Theme.colorOrange

                    gaugeLegend.text = qsTr("VOC")
                    gaugeBg.colorCircle = clr
                    gaugeValue.colorCircle = clr
                    gaugeValue.arcEnd = UtilsNumber.mapNumber(boxDevice.voc, 0, 1500, 0, 270)
                }
            }

            Text {
                id: gaugeLegend
                anchors.centerIn: parent
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }

            ProgressCircle {
                id: gaugeBg
                anchors.fill: parent
                lineWidth: isMobile ? 10 : 12
                opacity: 0.33
            }
            ProgressCircle {
                id: gaugeValue
                anchors.fill: parent
                lineWidth: isMobile ? 10 : 12
            }
        }
    }
}
