import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber
import "qrc:/js/UtilsDeviceBLE.js" as UtilsDeviceBLE

Item {
    id: deviceEnvironmental
    width: 450
    height: 700

    property var currentDevice: null

    property bool unicolor: (Theme.colorHeader === Theme.colorBackground)
    property string cccc: unicolor ? Theme.colorHeaderContent : "white"

    property bool singleColumn: {
        if (isMobile) {
            if (screenOrientation === Qt.PortraitOrientation ||
                (isTablet && width < 480)) { // can be a 2/3 split screen on tablet
                return true
            } else {
                return false
            }
        } else {
            return (appWindow.width < appWindow.height)
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Connections {
        target: currentDevice
        onStatusUpdated: { updateHeader() }
        onSensorUpdated: { updateHeader() }
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
        if (!clickedDevice.isEnvironmentalSensor()) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        console.log("DeviceEnvironmental // loadDevice() >> " + currentDevice)

        indicatorDisconnected.visible = true
        //indicatorAirQuality.visible = false
        //indicatorRadioactivity.visible = false

        //
        loadGraph()
        //
        updateHeader()
        updateData()
    }

    function loadGraph() {
        //
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceEnvironmental // updateHeader() >> " + currentDevice)

        // Battery level
        //imageBattery.source = UtilsDeviceBLE.getDeviceBatteryIcon(currentDevice.deviceBattery)
        //imageBattery.color = UtilsDeviceBLE.getDeviceBatteryColor(currentDevice.deviceBattery)

        // Status
        updateStatusText()
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceEnvironmental // updateData() >> " + currentDevice)

        // DATA

        // GRAPH
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceEnvironmental // updateStatusText() >> " + currentDevice)

        textStatus.text = UtilsDeviceBLE.getDeviceStatusText(currentDevice.status)

        if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE &&
            (currentDevice.isFresh() || currentDevice.isAvailable())) {
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

            width: parent.width
            height: 256
            color: Theme.colorHeader
            z: 5

            //MouseArea { anchors.fill: parent } // prevent clicks below this area

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: unicolor ? -(appHeader.height/2) : 4
                spacing: 48

                ImageSvg {
                    id: indicatorDisconnected
                    width: isMobile ? 96 : 128
                    height: isMobile ? 96 : 128
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                    color: cccc
                }

                ////////////////
/*
                AirQualityIndicator {
                    id: indicatorAirQuality
                    width: isMobile ? 128 : 180
                    height: isMobile ? 128 : 180
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: unicolor ? -(appHeader.height*0.16) : 4
                    color: cccc
                }
*/
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

                    source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
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

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: (isDesktop && singleColumn)
                height: 2
                opacity: 0.33
                color: Theme.colorHeaderHighlight
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Rectangle {
            id: statusBox
            width: parent.width
            height: syncing ? 48 : 0
            Behavior on height { NumberAnimation { duration: 133 } }

            color: Theme.colorActionbar
            clip: true

            // prevent clicks below this area
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

            //property bool syncing: (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY ||
            //                        currentDevice.status === DeviceUtils.DEVICE_UPDATING_REALTIME)

            property bool syncing: true//currentDevice.status !== DeviceUtils.DEVICE_OFFLINE

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ImageSvg {
                    id: buttonBle
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                    color: Theme.colorActionbarContent
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Syncing with the device")
                    color: Theme.colorActionbarContent
                    font.pixelSize: Theme.fontSizeContent
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Rectangle {
            id: airBox

            width: parent.width
            height: airFlow.height + 48
            color: Theme.colorDeviceHeader
            z: 3

            Flow {
                id: airFlow
                anchors.top: parent.top
                anchors.topMargin: 24
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 0
                spacing: 16

                onWidthChanged: {
                    var itemcount = 6
                    var availableWidth = deviceEnvironmental.width - (anchors.leftMargin + anchors.rightMargin)
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
                    id: pm25
                    width: airFlow.www

                    title: "PM2.5"
                    legend: "µg/m³"
                    value: 88.5
                    precision: 1
                    color: Theme.colorRed
                }

                ItemEnvBox {
                    id: pm100
                    width: airFlow.www

                    title: "PM10"
                    legend: "µg/m³"
                    value: 91.5
                    precision: 1
                    color: Theme.colorYellow
                }

                ItemEnvBox {
                    id: o3
                    width: airFlow.www

                    title: "O3"
                    legend: "µg/m³"
                    value: 8.0
                    precision: 1
                    color: Theme.colorGreen
                }

                ItemEnvBox {
                    id: so2
                    width: airFlow.www

                    title: "SO2"
                    legend: "µg/m³"
                    value: 12.0
                    precision: 1
                    color: Theme.colorGreen
                }

                ItemEnvBox {
                    id: no2
                    width: airFlow.www

                    title: "NO2"
                    legend: "µg/m³" // "PPM"
                    value: 57.0
                    precision: 1
                    color: Theme.colorGreen
                }

                ItemEnvBox {
                    id: co
                    width: airFlow.www

                    title: "CO"
                    legend: "µg/m³" // "PPM"
                    value: 1100.0
                    precision: 1
                    color: Theme.colorGreen
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: (isDesktop && singleColumn && !unicolor)
                height: 2
                opacity: 0.5
                color: Theme.colorSeparator
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Rectangle {
            id: radBox

            width: parent.width
            height: radFlow.height + 48
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
                    var availableWidth = deviceEnvironmental.width - (anchors.leftMargin + anchors.rightMargin)
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

                    title: ("RADIATION")
                    legend: ("µSv/m")
                    value: 0.24
                    precision: 2
                    color: Theme.colorGreen
                }

                ItemEnvBox {
                    id: rads
                    width: radFlow.www

                    title: ("RADIATION")
                    legend: ("µSv/s")
                    value: 0.10
                    precision: 2
                    color: Theme.colorGreen
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: (isDesktop && singleColumn && !unicolor)
                height: 2
                opacity: 0.5
                color: Theme.colorSeparator
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Rectangle {
            id: weatherBox

            width: parent.width
            height: weatherFlow.height + 48
            //color: Theme.colorDeviceHeader
            color: Theme.colorBackground
            z: 3

            Flow {
                id: weatherFlow
                anchors.top: parent.top
                anchors.topMargin: 24
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 8
                spacing: 16

                onWidthChanged: {
                    var itemcount = 9
                    var availableWidth = deviceEnvironmental.width - (anchors.leftMargin + anchors.rightMargin)
                    var cellColumnsTarget = Math.trunc(availableWidth / (wwwTarget + spacing))
                    if (cellColumnsTarget >= itemcount) {
                        www = (availableWidth - (spacing * itemcount)) / itemcount
                        if (www > wwwMax) www = wwwMax
                    } else {
                        www = (availableWidth - (spacing * cellColumnsTarget)) / cellColumnsTarget
                    }
                    //console.log("--- wwww: " + www)
                }

                property int wwwTarget: 128
                property int wwwMax: 128
                property int www: wwwTarget

                ItemWeatherBox {
                    id: temp
                    height: weatherFlow.www

                    title: "Temperature"
                    legend: "°C"
                    icon: "qrc:/assets/icons_material/device_thermostat-24px.svg"
                    value: 27.1
                    precision: 1
                }

                ItemWeatherBox {
                    id: hum
                    height: weatherFlow.www

                    title: "Humidity"
                    legend: "°RH"
                    icon: "qrc:/assets/icons_material/duotone-water_full-24px.svg"
                    value: 55
                    precision: 0
                }

                ItemWeatherBox {
                    id: press
                    height: weatherFlow.www

                    title: "Pressure"
                    legend: "Hpa"
                    icon: "qrc:/assets/icons_material/duotone_speed-24px.svg"
                    value: 1028
                    precision: 0
                }

                ItemWeatherBox {
                    id: sound
                    height: weatherFlow.www

                    title: "Sound level"
                    legend: "db"
                    icon: "qrc:/assets/icons_material/mic-24px.svg"
                    value: 47
                    precision: 0
                }

                ItemWeatherBox {
                    id: light
                    height: weatherFlow.www

                    title: "Luminosity"
                    legend: "lux"
                    icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                    value: 892
                    precision: 0
                }

                ItemWeatherBox {
                    id: uv
                    height: weatherFlow.www

                    title: "UV index"
                    legend: ""
                    icon: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                    value: 3
                    precision: 0
                }

                ItemWeatherBox {
                    id: windd
                    height: weatherFlow.www

                    title: "Wind direction"
                    legend: "north"
                    icon: "qrc:/assets/icons_material/near_me-24px.svg"
                    value: 0
                    precision: 0
                }
                ItemWeatherBox {
                    id: winds
                    height: weatherFlow.www

                    title: "Wind speed"
                    legend: "km/h"
                    icon: "qrc:/assets/icons_material/baseline-air-24px.svg"
                    value: 16
                    precision: 0
                }
                ItemWeatherBox {
                    id: rain
                    height: weatherFlow.www

                    title: "Rain"
                    legend: "mm"
                    icon: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
                    value: 7
                    precision: 0
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: (isDesktop && singleColumn && !unicolor)
                height: 2
                opacity: 0.5
                color: Theme.colorSeparator
            }
        }
    }
}
