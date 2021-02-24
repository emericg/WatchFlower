import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: deviceThermometer
    width: 450
    height: 700

    property var currentDevice: null
    property alias deviceScreenChart: graphLoader.item

    property var cchh: (Theme.colorHeader !== Theme.colorBackground) ? Theme.colorHeader : Theme.colorPrimary
    property var cccc: (Theme.colorHeader !== Theme.colorBackground) ? Theme.colorHeaderContent : "white"

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

    function isHistoryMode() {
        return deviceScreenChart.isIndicator()
    }
    function resetHistoryMode() {
        deviceScreenChart.resetIndicator()
    }

    function loadDevice(clickedDevice) {
        if (typeof clickedDevice === "undefined" || !clickedDevice) return
        if (clickedDevice.hasSoilMoistureSensor()) return
        if (clickedDevice === currentDevice) return

        currentDevice = clickedDevice
        //console.log("DeviceThermometer // loadDevice() >> " + currentDevice)

        sensorTemp.visible = false
        heatIndex.visible = false
        sensorHygro.visible = false
        imageBattery.visible = false

        loadGraph()
        updateHeader()
        updateData()
    }

    function loadGraph() {
        if (settingsManager.graphThermometer === "lines") {
            graphLoader.source = "ItemAioLineCharts.qml"
        } else {
            graphLoader.source = "ItemThermometerWidget.qml"
        }
        deviceScreenChart.loadGraph()
        deviceScreenChart.updateGraph()
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateHeader() >> " + currentDevice)

        // Sensor battery level
        if (currentDevice.hasBatteryLevel()) {
            //imageBattery.visible = true
            imageBattery.color = cccc

            if (currentDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (currentDevice.deviceBattery > 85) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (currentDevice.deviceBattery > 75) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (currentDevice.deviceBattery > 55) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (currentDevice.deviceBattery > 45) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (currentDevice.deviceBattery > 25) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (currentDevice.deviceBattery > 15) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (currentDevice.deviceBattery > 1) {
                //if (currentDevice.deviceBattery <= 10) imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                if (currentDevice.deviceBattery === 0) imageBattery.color = Theme.colorRed
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            //imageBattery.visible = false
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
        }

        // Status
        updateStatusText()
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateData() >> " + currentDevice)

        if (currentDevice.deviceTempC < -40) {
            sensorDisconnected.visible = true

            sensorTemp.visible = false
            heatIndex.visible = false
            sensorHygro.visible = false
            imageBattery.visible = false
        } else {
            sensorDisconnected.visible = false

            if (currentDevice.deviceTempC >= -40) {
                sensorTemp.text = currentDevice.getTempString()
                sensorTemp.visible = true
            }
            if (currentDevice.deviceHumidity >= 0) {
                sensorHygro.text = currentDevice.deviceHumidity + "% " + qsTr("humidity")
                sensorHygro.visible = true
            }
            if (currentDevice.deviceTempC >= 27 && currentDevice.deviceHumidity >= 40) {
                if (currentDevice.getHeatIndex() > currentDevice.getTemp()) {
                    heatIndex.text = qsTr("feels like %1").arg(currentDevice.getHeatIndexString())
                    heatIndex.visible = true
                }
            }

            if (currentDevice.hasBatteryLevel()) {
                imageBattery.visible = true
            }
        }

        deviceScreenChart.updateGraph()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceThermometer // updateStatusText() >> " + currentDevice)

        if (currentDevice.status === 1) {
            textStatus.text = qsTr("Update queued.") + " "
        } else if (currentDevice.status === 2) {
            textStatus.text = qsTr("Connecting...") + " "
        } else if (currentDevice.status === 3) {
            textStatus.text = qsTr("Connected") + " "
        } else if (currentDevice.status === 8) {
            textStatus.text = qsTr("Working...") + " "
        } else if (currentDevice.status === 9 ||
                   currentDevice.status === 10 ||
                   currentDevice.status === 11) {
            textStatus.text = qsTr("Updating...") + " "
        } else {
            if (currentDevice.isFresh() || currentDevice.isAvailable()) {
                if (currentDevice.getLastUpdateInt() <= 1)
                    textStatus.text = qsTr("Just synced!")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
            } else {
                textStatus.text = qsTr("Offline!") + " "
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    property bool singleColumn: {
        if (isMobile) {
            if (isPhone) {
                if (screenOrientation === Qt.PortraitOrientation) {
                    return true
                } else {
                    return false
                }
            }
            if (isTablet) {
                if (screenOrientation === Qt.PortraitOrientation || width < 480) {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return (appWindow.width < 720)
        }
    }

    Flow {
        anchors.fill: parent

        Rectangle {
            id: tempBox

            property int dimboxw: Math.max(deviceThermometer.width * 0.333, isPhone ? 160 : 320)
            property int dimboxh: Math.max(deviceThermometer.height * 0.333, isPhone ? 160 : 256)

            width: singleColumn ? parent.width : dimboxw
            height: singleColumn ? dimboxh: parent.height
            color: cchh
            z: 5

            //width: dimboxw - 32
            //height: dimboxh: - 32
            //color: singleColumn ? Theme.colorPrimary : cchh
            //radius: 16

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
                    font.pixelSize: isPhone ? 18 : 20
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

                    //visible: (currentDevice.hasBatteryLevel() && currentDevice.deviceTempC > -40)
                    fillMode: Image.PreserveAspectCrop
                    color: cccc
                    source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
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
        }

        Loader {
            id: graphLoader
            width: singleColumn ? parent.width : (parent.width - tempBox.width)
            height: singleColumn ? (parent.height - tempBox.height) : parent.height
            asynchronous: false
        }
    }
}
