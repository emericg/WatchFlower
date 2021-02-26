import QtQuick 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: deviceWidget
    implicitWidth: 640
    implicitHeight: bigAssMode ? 140 : 100

    property var boxDevice: pointer

    property bool wideAssMode: (width >= 380) || (isTablet && width >= 480)
    property bool bigAssMode: false
    property bool singleColumn: true

    property bool selected: false

    Connections {
        target: boxDevice
        onStatusUpdated: { updateSensorData() }
        onSensorUpdated: { updateSensorBattery() }
        onDataUpdated: { updateSensorData() }
        onLimitsUpdated: { updateSensorData() }
    }
    Connections {
        target: Theme
        onCurrentThemeChanged: {
            updateSensorBattery()
            updateSensorData()
        }
    }
    Connections {
        target: devicesView
        onBigWidgetChanged: {
            updateSensorBattery()
            updateSensorData()
        }
    }
    Connections {
        target: settingsManager
        onAppLanguageChanged: {
            updateSensorData()
        }
    }

    Component.onCompleted: initBoxData()

    function initBoxData() {
        // Device picture
        if (boxDevice.deviceName === "MJ_HT_V1" ||
            boxDevice.deviceName === "ClearGrass Temp & RH" ||
            boxDevice.deviceName === "Qingping Temp & RH M" ||
            boxDevice.deviceName === "Qingping Temp & RH H") {
            imageDevice.source = "qrc:/assets/icons_material/baseline-trip_origin-24px.svg"
        } else if (boxDevice.deviceName === "LYWSD02") {
            imageDevice.source = "qrc:/assets/icons_material/baseline-crop_16_9-24px.svg"
        } else if (boxDevice.deviceName === "LYWSD03MMC") {
            imageDevice.source = "qrc:/assets/icons_material/baseline-crop_square-24px.svg"
        } else if (boxDevice.deviceName === "GeigerCounter") {
            imageDevice.source = "qrc:/assets/icons_custom/nuclear_icon.svg"
        } else {
            if (boxDevice.hasData("soilMoisture")) {
                if (boxDevice.deviceName === "ropot" || boxDevice.deviceName === "Parrot pot")
                    imageDevice.source = "qrc:/assets/icons_material/pot_flower-24px.svg"
                else
                    imageDevice.source = "qrc:/assets/icons_material/outline-local_florist-24px.svg"
            } else {
                imageDevice.source = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
            }
        }

        updateSensorData()
        updateSensorBattery()
    }

    function updateSensorBattery() {
        // Sensor battery level
        if (boxDevice.hasBatteryLevel()) {
            imageBattery.visible = true
            //imageBattery.color = Theme.colorIcon

            if (boxDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (boxDevice.deviceBattery > 85) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (boxDevice.deviceBattery > 75) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (boxDevice.deviceBattery > 55) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (boxDevice.deviceBattery > 45) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (boxDevice.deviceBattery > 25) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (boxDevice.deviceBattery > 15) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (boxDevice.deviceBattery > 1) {
                //if (boxDevice.deviceBattery <= 10) imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                //if (boxDevice.deviceBattery === 0) imageBattery.color = Theme.colorRed
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }
    }

    function updateSensorData() {
        rectangleSensors.visible = false
        rectangleHygroTemp.visible = false

        // Texts
        if (boxDevice.hasGeigerCounter()) {
            textTitle.text = qsTr("Geiger Counter")
        } else if (!boxDevice.hasSoilMoistureSensor()) {
            textTitle.text = qsTr("Thermometer")
        } else if (boxDevice.devicePlantName !== "") {
            textTitle.text = boxDevice.devicePlantName
        } else {
            textTitle.text = boxDevice.deviceName
        }

        textLocation.font.pixelSize = bigAssMode ? 20 : 18
        if (boxDevice.deviceLocationName !== "") {
            textLocation.text = boxDevice.deviceLocationName
        } else {
            if (Qt.platform.os === "osx" || Qt.platform.os === "ios") {
                textLocation.text = boxDevice.deviceAddress
                textLocation.font.pixelSize = 14
            } else {
                textLocation.text = boxDevice.deviceAddress
            }
        }

        // Status
        if (boxDevice.status === 1) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Queued")
            opa.stop()
        } else if (boxDevice.status === 2) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Connecting...")
            opa.start()
        } else if (boxDevice.status === 3) {
            textStatus.color = Theme.colorGreen
            textStatus.text = qsTr("Connected")
            opa.stop()
        } else if (boxDevice.status === 8) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Working...")
            opa.start()
        } else if (boxDevice.status === 9 ||
                   boxDevice.status === 10 ||
                   boxDevice.status === 11) {
            textStatus.color = Theme.colorYellow
            textStatus.text = qsTr("Updating...")
            opa.start()
        } else {
            opa.stop()
            if (boxDevice.isFresh()) {
                textStatus.color = Theme.colorGreen
                textStatus.text = qsTr("Synced")
            } else if (boxDevice.isAvailable()) {
                textStatus.color = Theme.colorYellow
                textStatus.text = qsTr("Synced")
            } else {
                textStatus.color = Theme.colorRed
                textStatus.text = qsTr("Offline")
            }
        }

        lilIcons.visible = false
        water.visible = false
        temp.visible = false

        // Warnings are only for plants (with available data)
        if (boxDevice.hasSoilMoistureSensor() && boxDevice.isAvailable()) {

            // Water me notif
            if (boxDevice.deviceSoilMoisture > 0 && boxDevice.deviceSoilMoisture < boxDevice.limitHygroMin) {
                lilIcons.visible = true
                water.visible = true
                water.source = "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                temp.color = Theme.colorBlue
            } else if (boxDevice.deviceSoilMoisture > boxDevice.limitHygroMax) {
                lilIcons.visible = true
                water.visible = true
                water.source = "qrc:/assets/icons_material/duotone-water_full-24px.svg"
                temp.color = Theme.colorYellow
            }

            // Extreme temperature notif
            if (boxDevice.deviceTempC > 40) {
                lilIcons.visible = true
                temp.visible = true
                temp.color = Theme.colorYellow
                temp.source = "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
            } else if (boxDevice.deviceTempC <= 2 && boxDevice.deviceTempC > -80) {
                lilIcons.visible = true
                temp.visible = true
                temp.source = "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"

                if (boxDevice.deviceTempC <= -4)
                    temp.color = Theme.colorRed
                else if (boxDevice.deviceTempC <= -2)
                    temp.color = Theme.colorYellow
                else
                    temp.color = Theme.colorBlue
            }
        }

        // Update notif
        if (boxDevice.isAvailable()) {
            // if we have data cached, no indicator
            imageStatus.visible = false;
            refreshAnimation.running = false;
        } else {
            imageStatus.visible = true;

            if (boxDevice.status === 1) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg";
                refreshAnimation.running = false;
            } else if (boxDevice.status === 2 || boxDevice.status === 3) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg";
                refreshAnimation.running = true;
            } else if (boxDevice.status >= 8) {
                imageStatus.source = "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg";
                refreshAnimation.running = true;
            } else {
                imageStatus.source = "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg";
                refreshAnimation.running = false;
            }
        }

        // Has data? always display them
        if (boxDevice.isAvailable()) {
            if (boxDevice.hasGeigerCounter()) {
                rectangleHygroTemp.visible = true
                textTemp.text = ""
                textHygro.font.pixelSize = bigAssMode ? 24 : 22
                textHygro.text = boxDevice.deviceRadioactivityH.toFixed(2) + " µSv/h"
                // TODO status color
            } else if (boxDevice.hasSoilMoistureSensor()) {
                rectangleSensors.visible = true
                hygro_data.height = UtilsNumber.normalize(boxDevice.deviceSoilMoisture, boxDevice.limitHygroMin - 1, boxDevice.limitHygroMax) * rowRight.height
                temp_data.height = UtilsNumber.normalize(boxDevice.deviceTempC, boxDevice.limitTempMin - 1, boxDevice.limitTempMax) * rowRight.height
                lumi_data.height = UtilsNumber.normalize(boxDevice.deviceLuminosity, boxDevice.limitLuxMin, boxDevice.limitLuxMax) * rowRight.height
                cond_data.height = UtilsNumber.normalize(boxDevice.deviceSoilConductivity, boxDevice.limitConduMin, boxDevice.limitConduMax) * rowRight.height

                hygro_bg.visible = (boxDevice.deviceSoilMoisture > 0 || boxDevice.deviceSoilConductivity > 0)
                lumi_bg.visible = boxDevice.hasLuminositySensor()
                cond_bg.visible = (boxDevice.deviceSoilMoisture > 0 || boxDevice.deviceSoilConductivity > 0)
            } else {
                rectangleHygroTemp.visible = true
                textTemp.text = boxDevice.deviceTemp.toFixed(1) + "°"
                textHygro.text = boxDevice.deviceHumidity + "%"
            }
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

        color: deviceWidget.selected ? Theme.colorSeparator : Theme.colorDeviceWidget
        Behavior on color { ColorAnimation { duration: animated ? 133 : 0 } }

        opacity: deviceWidget.selected ? 0.5 : (singleColumn ? 0 : 1)
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
                    if (!selected) {
                        selected = true;
                        screenDeviceList.selectDevice(index);
                    } else {
                        selected = false;
                        screenDeviceList.deselectDevice(index);
                    }
                    return;
                }

                if (mouse.button === Qt.LeftButton) {
                    // multi selection
                    if ((mouse.modifiers & Qt.ControlModifier) ||
                        (screenDeviceList.selectionMode)) {
                        if (!selected) {
                            selected = true;
                            screenDeviceList.selectDevice(index);
                        } else {
                            selected = false;
                            screenDeviceList.deselectDevice(index);
                        }
                        return;
                    }

                    // regular click
                    if (boxDevice.hasData()) {
                        selectedDevice = boxDevice
                        if (boxDevice.hasSoilMoistureSensor()){
                            screenDeviceSensor.loadDevice(boxDevice)
                            appContent.state = "DeviceSensor"
                        } else if (boxDevice.hasGeigerCounter()) {
                            screenDeviceGeiger.loadDevice(boxDevice)
                            appContent.state = "DeviceGeiger"
                        } else {
                            screenDeviceThermometer.loadDevice(boxDevice)
                            appContent.state = "DeviceThermo"
                        }
                    }
                }
            }

            onPressAndHold: {
                // multi selection
                if (!selected) {
                    selected = true;
                    screenDeviceList.selectDevice(index);
                } else {
                    selected = false;
                    screenDeviceList.deselectDevice(index);
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
                    text: boxDevice.deviceLocationName
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
                    text: boxDevice.deviceAddress
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
                        source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        id: textStatus
                        anchors.verticalCenterOffset: 0
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: bigAssMode ? 16 : 15
                        color: Theme.colorGreen

                        SequentialAnimation on opacity {
                            id: opa
                            loops: Animation.Infinite
                            onStopped: textStatus.opacity = 1;

                            PropertyAnimation { to: 0.33; duration: 750; }
                            PropertyAnimation { to: 1; duration: 750; }
                        }
                    }
                }
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

            Row {
                id: lilIcons
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                layoutDirection: Qt.RightToLeft
                spacing: 8

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
            }

            Row {
                id: rectangleSensors
                anchors.bottom: parent.bottom
                anchors.top: parent.top

                visible: true
                clip: true
                spacing: 8
                property int sensorWidth: isPhone ? 8 : (bigAssMode ? 12 : 10)
                property int sensorRadius: bigAssMode ? 3 : 2

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

            Column {
                id: rectangleHygroTemp
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: textTemp
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    text: "25.0°"
                    color: Theme.colorText
                    font.wordSpacing: -1.2
                    font.letterSpacing: -1.4
                    font.pixelSize: bigAssMode ? 32 : 30
                    font.family: "Tahoma"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft

                    Connections {
                        target: settingsManager
                        onTempUnitChanged: { textTemp.text = boxDevice.getTemp().toFixed(1) + "°"; }
                    }
                }

                Text {
                    id: textHygro
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    text: "55%"
                    color: Theme.colorSubText
                    font.pixelSize: bigAssMode ? 26 : 24
                    font.family: "Tahoma"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
            }

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

            source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
            visible: false
            color: Theme.colorIcon

            SequentialAnimation on opacity {
                id: refreshAnimation
                loops: Animation.Infinite
                running: false
                onStopped: imageStatus.opacity = 1
                OpacityAnimator { from: 0; to: 1; duration: 750 }
                OpacityAnimator { from: 1; to: 0; duration: 750 }
            }
        }
    }
}
