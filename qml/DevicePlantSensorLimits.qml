import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber
import "qrc:/js/UtilsDeviceBLE.js" as UtilsDeviceBLE

Item {
    id: devicePlantSensorLimits

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("DevicePlantSensorLimits // updateHeader() >> " + currentDevice)

        // Address
        if (currentDevice.deviceAddress.charAt(0) === '{') {
            textAddress.text = currentDevice.deviceAddress.toUpperCase()
            textAddress.font.pixelSize = 15
        } else {
            textAddress.text = "[" + currentDevice.deviceAddress.toUpperCase() + "]"
            textAddress.font.pixelSize = 17
        }

        // MAC Address
        if ((Qt.platform.os === "osx" || Qt.platform.os === "ios") &&
            (currentDevice.deviceName === "Flower care" || currentDevice.deviceName === "ropot" ||
             currentDevice.deviceName === "Grow care garden")) {
            itemMacAddr.visible = true
            if (currentDevice.getSetting("mac")) {
                textInputMacAddr.text = currentDevice.getSetting("mac")
            } else {
                textInputMacAddr.text = ""
            }
        } else {
            itemMacAddr.visible = false
            textInputMacAddr.text = ""
        }

        // Firmware
        textFirmware.text = currentDevice.deviceFirmware
        if (isDesktop && wideMode && !currentDevice.deviceFirmwareUpToDate) {
            imageFwUpdate.visible = true
            textFwUpdate.visible = true
        } else {
            imageFwUpdate.visible = false
            textFwUpdate.visible = false
        }
    }

    function updateLimits() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("DevicePlantSensorLimits // updateLimits() >> " + currentDevice)

        itemHygro.visible = currentDevice.hasHumiditySensor || currentDevice.hasSoilMoistureSensor
        itemTemp.visible = currentDevice.hasTemperatureSensor
        itemLumi.visible = currentDevice.hasLuminositySensor
        itemCondu.visible = currentDevice.hasSoilConductivitySensor

        rangeSlider_hygro.setValues(currentDevice.limitHygroMin, currentDevice.limitHygroMax)
        rangeSlider_condu.setValues(currentDevice.limitConduMin, currentDevice.limitConduMax)
        rangeSlider_temp.setValues(currentDevice.limitTempMin, currentDevice.limitTempMax)
        rangeSlider_lumi.setValues(currentDevice.limitLuxMin, currentDevice.limitLuxMax)
    }

    property bool insideMode: (currentDevice && currentDevice.deviceIsInside)
    property bool outsideMode: (currentDevice && currentDevice.deviceIsOutside)

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            anchors.fill: parent

            topPadding: 0
            bottomPadding: 16
            spacing: 12

            ////////

            Rectangle {
                id: rectangleHeader
                color: Theme.colorDeviceHeader
                width: parent.width
                height: devicePanel.height + 12

                Column {
                    id: devicePanel
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 2
                    spacing: 2

                    Text {
                        id: textDeviceName
                        height: 32
                        anchors.left: parent.left

                        visible: isDesktop

                        text: currentDevice.deviceName
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Theme.fontSizeTitle
                        font.capitalization: Font.AllUppercase
                        color: Theme.colorText

                        ImageSvg {
                            id: imageBattery
                            width: 32
                            height: 32
                            rotation: 90
                            anchors.verticalCenter: textDeviceName.verticalCenter
                            anchors.left: textDeviceName.right
                            anchors.leftMargin: 16

                            visible: (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)
                            source: UtilsDeviceBLE.getDeviceBatteryIcon(currentDevice.deviceBattery)
                            color: UtilsDeviceBLE.getDeviceBatteryColor(currentDevice.deviceBattery)
                        }
                    }

                    Item {
                        id: itemAddress
                        height: 28
                        width: parent.width

                        Text {
                            id: labelAddress
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Address")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        Text {
                            id: textAddress
                            anchors.left: labelAddress.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: -2
                            anchors.baseline: labelAddress.baseline

                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }
                    }

                    Item {
                        id: itemFirmware
                        height: 28
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Text {
                            id: labelFirmware
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Firmware")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        Text {
                            id: textFirmware
                            anchors.left: labelFirmware.right
                            anchors.leftMargin: 10
                            anchors.baseline: labelFirmware.baseline

                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }

                        ImageSvg {
                            id: imageFwUpdate
                            width: 20
                            height: 20
                            anchors.left: textFirmware.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: textFirmware.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-new_releases-24px.svg"
                            color: Theme.colorIcon
                            opacity: 0.8
                        }
                        Text {
                            id: textFwUpdate
                            anchors.left: imageFwUpdate.right
                            anchors.leftMargin: 6
                            anchors.baseline: labelFirmware.baseline

                            text: qsTr("Update %1 available with official application").arg("")
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorHighContrast
                        }
                    }

                    Item {
                        id: battery
                        height: 28
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Text {
                            id: labelBattery
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Battery")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        Text {
                            id: textBattery
                            anchors.left: labelBattery.right
                            anchors.leftMargin: 10
                            anchors.baseline: labelBattery.baseline

                            text: currentDevice.deviceBattery + "%"
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }
                    }

                    Item {
                        id: time
                        height: 28
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: textTime.text

                        Text {
                            id: labelTime
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Uptime")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        Text {
                            id: textTime
                            anchors.left: labelTime.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: -2
                            anchors.baseline: labelTime.baseline

                            text: currentDevice.deviceTime.toLocaleString(Locale.ShortFormat)
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        id: lastSync
                        height: 28
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: textLastSync.text

                        Text {
                            id: labelLastSync
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Last sync")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        Text {
                            id: textLastSync
                            anchors.left: labelLastSync.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: -2
                            anchors.baseline: labelLastSync.baseline

                            text: currentDevice.lastHistorySync.toLocaleString(Locale.ShortFormat)
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        id: lastMove
                        height: 28
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: textLastMove.text

                        Text {
                            id: labelLastMove
                            width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Last move")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        Text {
                            id: textLastMove
                            anchors.left: labelLastMove.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: -2
                            anchors.baseline: labelLastMove.baseline

                            text: currentDevice.lastMove.toLocaleString(Locale.ShortFormat)
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                            elide: Text.ElideRight
                        }
                    }
/*
                    Item {
                        id: itemMacAddr
                        height: 28
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: false
                        enabled: visible

                        Text {
                            id: labelMacAddr
                            //width: isPhone ? 80 : 96
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("MAC Address")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        TextInput {
                            id: textInputMacAddr
                            anchors.left: labelMacAddr.right
                            anchors.leftMargin: 6
                            anchors.baseline: labelMacAddr.baseline
                            padding: 4

                            font.pixelSize: 17
                            font.bold: false
                            color: Theme.colorHighContrast

                            inputMask: "HH:HH:HH:HH:HH:HH"
                            onEditingFinished: {
                                if (text) currentDevice.setSetting("mac", text)
                                focus = false
                            }

                            MouseArea {
                                id: textInputMacAddrArea
                                anchors.fill: parent
                                anchors.topMargin: -4
                                anchors.leftMargin: -4
                                anchors.rightMargin: -24
                                anchors.bottomMargin: -4

                                hoverEnabled: true
                                propagateComposedEvents: true

                                onClicked: {
                                    textInputMacAddr.forceActiveFocus()
                                    mouse.accepted = false
                                }
                                onPressed: {
                                    textInputMacAddr.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        ImageSvg {
                            id: imageEditMacAddr
                            width: 20
                            height: 20
                            anchors.left: textInputMacAddr.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: textInputMacAddr.verticalCenter

                            source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                            color: Theme.colorSubText

                            //visible: (isMobile || !textInputMacAddr.text || textInputMacAddr.focus || textInputArea.containsMouse)
                            opacity: (isMobile || !textInputMacAddr.text || textInputMacAddr.focus || textInputMacAddrArea.containsMouse) ? 0.9 : 0
                            Behavior on opacity { OpacityAnimator { duration: 133 } }
                        }
                    }

                    Text {
                        id: legendMacAddr
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        topPadding: 0
                        bottomPadding: 8

                        visible: itemMacAddr.visible
                        text: "The MAC address of the sensor must be set in order for the history synchronization to work. Sorry for the inconvenience."
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }
*/
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    visible: (isDesktop && !headerUnicolor)
                    height: 2
                    opacity: 0.5
                    color: Theme.colorSeparator
                }
            }

            ////////
/*
            Rectangle {
                id: itemDevice
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                height: itemDeviceRow.height + 24
                color: Theme.colorForeground

                ImageSvg {
                    width: 80
                    height: 80
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    color: Theme.colorSubText
                    source: "qrc:/assets/devices/flowercare.svg"
                }

                Column {
                    id: itemDeviceRow
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    spacing: 6

                    Row {
                        height: 32
                        spacing: 16

                        Text {
                            text: currentDevice.deviceName
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontSizeTitle
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorText
                        }

                        ImageSvg {
                            id: imageBattery
                            width: 32; height: 32;
                            rotation: 90
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                            color: Theme.colorIcon
                        }
                    }

                    Row {
                        height: 24
                        spacing: 12

                        Text {
                            width: isPhone ? 80 : 96
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Address")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                        Text {
                            id: textAddress
                            anchors.verticalCenter: parent.verticalCenter

                            text: "[" + currentDevice.deviceAddress + "]"
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }
                    }

                    Row {
                        height: 24
                        spacing: 12

                        Text {
                            width: isPhone ? 80 : 96
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Firmware")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                        Text {
                            id: textFirmware
                            anchors.verticalCenter: parent.verticalCenter

                            text: currentDevice.deviceFirmware
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }

                        ImageSvg {
                            id: imageFwUpdate
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-new_releases-24px.svg"
                            color: Theme.colorIcon

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: textFwUpdate.text = qsTr("Use official app to upgrade")
                                onExited: textFwUpdate.text = qsTr("Update available!")
                            }
                        }
                        Text {
                            id: textFwUpdate
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Update available!")
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorHighContrast
                        }
                    }

                    Row {
                        height: 24
                        spacing: 12

                        Text {
                            width: isPhone ? 80 : 96
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Battery")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: currentDevice.deviceBattery + "%"
                            font.pixelSize: 17
                            color: Theme.colorHighContrast
                        }
                    }

                    Item { width: 8; height: 8; } // spacer

                    Grid {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 12
                        columns: 2
                        //rows: 3

                        Row {
                            spacing: 12
                            visible: currentDevice.hasSoilMoistureSensor

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: qsTr("Soil moisture")
                                    font.pixelSize: 15
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "0 → 100% ±1%"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasSoilConductivitySensor

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                rotation: 90
                                source: "qrc:/assets/icons_material/baseline-tonality-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: qsTr("Soil fertility")
                                    font.pixelSize: 15
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "0 → 100 uc/cm ±1%"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasSoilTemperatureSensor

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: qsTr("Soil temperature")
                                    font.pixelSize: 15
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "-15 → 50°C ±0.5°C"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasTemperatureSensor

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: qsTr("Temperature")
                                    font.pixelSize: 15
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "-15 → 50°C ±0.5°C"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasHumiditySensor

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: qsTr("Humidity")
                                    font.pixelSize: 15
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "0 → 100% ±1%"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasLuminositySensor

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: qsTr("Luminosity")
                                    font.pixelSize: 15
                                    color: Theme.colorText
                                }
                                Text {
                                    text: "0 → 100k lux ±100lux"
                                    font.pixelSize: 13
                                    color: Theme.colorText
                                }
                            }
                        }

                        Row {
                            spacing: 12
                            visible: currentDevice.hasLED

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("LED indicator")
                                font.pixelSize: 15
                                color: Theme.colorText
                            }
                        }
                        Row {
                            spacing: 12
                            visible: currentDevice.hasHistory

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Data history")
                                font.pixelSize: 15
                                color: Theme.colorText
                            }
                        }
                        Row {
                            spacing: 12
                            visible: currentDevice.hasClock

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-schedule-24px.svg"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Clock")
                                font.pixelSize: 15
                                color: Theme.colorText
                            }
                        }
                        Row {
                            spacing: 12
                            visible: currentDevice.hasWaterTank

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Water tank")
                                font.pixelSize: 15
                                color: Theme.colorText
                            }
                        }
                        Row {
                            spacing: 12
                            visible: currentDevice.hasButtons

                            ItemImageButton {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: "white"
                                iconColor: Theme.colorText
                                source: "qrc:/assets/icons_material/duotone-touch_app-24px.svg"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Buttons")
                                font.pixelSize: 15
                                color: Theme.colorText
                            }
                        }
                    }
                }
            }
*/
            ////////

            Rectangle {
                id: itemMacAddr
                height: rowMacAddr.height + 16 + legendMacAddr.contentHeight
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                color: Theme.colorForeground
                border.width: isDesktop ? 2 : 0
                border.color: Theme.colorSeparator

                visible: false
                enabled: visible

                ImageSvg {
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    width: 24
                    height: 24

                    color: Theme.colorSubText
                    source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                }

                Column {
                    id: columnMacAddr
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    spacing: 0

                    Row {
                        id: rowMacAddr
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 8

                        Text {
                            id: labelMacAddr
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("MAC Address")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                        }

                        TextInput {
                            id: textInputMacAddr
                            anchors.baseline: labelMacAddr.baseline
                            padding: 4

                            font.pixelSize: 17
                            font.bold: false
                            color: Theme.colorHighContrast

                            inputMask: "HH:HH:HH:HH:HH:HH"
                            onEditingFinished: {
                                if (text) currentDevice.setSetting("mac", text)
                                focus = false
                            }

                            MouseArea {
                                id: textInputMacAddrArea
                                anchors.fill: parent
                                anchors.topMargin: -4
                                anchors.leftMargin: -4
                                anchors.rightMargin: -24
                                anchors.bottomMargin: -4

                                hoverEnabled: true
                                propagateComposedEvents: true

                                onClicked: {
                                    textInputMacAddr.forceActiveFocus()
                                    mouse.accepted = false
                                }
                                onPressed: {
                                    textInputMacAddr.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }

                            ImageSvg {
                                id: imageEditMacAddr
                                width: 20
                                height: 20
                                anchors.left: parent.right
                                anchors.leftMargin: 8
                                anchors.verticalCenter: textInputMacAddr.verticalCenter

                                source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                                color: Theme.colorSubText

                                //visible: (isMobile || !textInputMacAddr.text || textInputMacAddr.focus || textInputArea.containsMouse)
                                opacity: (isMobile || !textInputMacAddr.text || textInputMacAddr.focus || textInputMacAddrArea.containsMouse) ? 0.9 : 0
                                Behavior on opacity { OpacityAnimator { duration: 133 } }
                            }
                        }
                    }

                    Text {
                        id: legendMacAddr
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: "The MAC address of the sensor must be set in order for the history synchronization to work. Sorry for the inconvenience."
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ////////

            Row {
                id: itemInOut
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                spacing: 12

                Rectangle {
                    id: rectangleInside
                    width: parent.width/2 - parent.spacing/2
                    height: isDesktop ? 112 : 96
                    anchors.bottom: parent.bottom

                    color: Theme.colorForeground
                    border.width: (insideMode && isDesktop) ? 2 : 0
                    border.color: Theme.colorSeparator

                    opacity: insideMode ? 1 : 0.5
                    Behavior on opacity { OpacityAnimator { duration: 133 } }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentDevice.setOutside(false)
                            rangeSlider_temp.setValues(currentDevice.limitTempMin, currentDevice.limitTempMax)
                            rangeSlider_lumi.setValues(currentDevice.limitLuxMin, currentDevice.limitLuxMax)
                        }
                    }

                    Column {
                        anchors.centerIn: parent

                        ImageSvg {
                            id: insideImage
                            width: 48; height: 48;
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Theme.colorText
                            source: "qrc:/assets/icons_custom/inside-24px.svg"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("inside")
                            color: Theme.colorText
                            font.pixelSize: Theme.fontSizeContentSmall
                        }
                    }
                }

                Rectangle {
                    id: rectangleOutside
                    width: (parent.width/2 - parent.spacing/2)
                    height: isDesktop ? 112 : 96
                    anchors.bottom: parent.bottom

                    color: Theme.colorForeground
                    border.width: (outsideMode && isDesktop) ? 2 : 0
                    border.color: Theme.colorSeparator

                    opacity: outsideMode ? 1 : 0.5
                    Behavior on opacity { OpacityAnimator { duration: 133 } }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentDevice.setOutside(true)
                            rangeSlider_temp.setValues(currentDevice.limitTempMin, currentDevice.limitTempMax)
                            rangeSlider_lumi.setValues(currentDevice.limitLuxMin, currentDevice.limitLuxMax)
                        }
                    }

                    Column {
                        anchors.centerIn: parent

                        ImageSvg {
                            id: outsideImage
                            width: 48; height: 48;
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: "qrc:/assets/icons_custom/outside-24px.svg"
                            color: Theme.colorText
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("outside")
                            color: Theme.colorText
                            font.pixelSize: Theme.fontSizeContentSmall
                        }
                    }
                }
            }

            ////////

            Item {
                id: itemHygro
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: imageHygro
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 8

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
                }
                Text {
                    anchors.left: imageHygro.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageHygro.verticalCenter
                    anchors.verticalCenterOffset: 2

                    text: currentDevice.hasSoilMoistureSensor ? qsTr("Moisture") : qsTr("Humidity")
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_hygro
                    height: 20
                    anchors.top: imageHygro.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    unit: "%"
                    from: 0
                    to: 66
                    stepSize: 1
                    first.onValueChanged: if (currentDevice) currentDevice.limitHygroMin = first.value.toFixed(0);
                    second.onValueChanged: if (currentDevice) currentDevice.limitHygroMax = second.value.toFixed(0);
                }
            }
            Text {
                id: legendHygro
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 16

                visible: itemHygro.visible

                text: qsTr("Ideal soil moisture for indoor plants is usually 15 to 50%. Cacti and succulents can go as low as 7%. Tropical plants like to have more water.") +
                      qsTr("<br><b>Tip: </b>") + qsTr("Be careful, too much water over long periods of time can be just as lethal as not enough!") +
                      qsTr("<br><b>Tip: </b>") + qsTr("Water your plants more frequently during their growth period.")
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item {
                id: itemTemp
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                ImageSvg {
                    id: imageTemp
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 8

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                }
                Text {
                    anchors.left: imageTemp.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageTemp.verticalCenter
                    anchors.verticalCenterOffset: 1

                    text: qsTr("Temperature")
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_temp
                    height: 20
                    anchors.top: imageTemp.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    unit: "°"
                    from: outsideMode ? 0 : 12
                    to: outsideMode ? 50 : 32
                    stepSize: 1

                    first.onValueChanged: {
                        if (currentDevice) {
                            if ((first.value > rangeSlider_temp.from && first.value < rangeSlider_temp.to) ||
                                (first.value >= rangeSlider_temp.from && first.value <= rangeSlider_temp.to &&
                                 currentDevice.limitTempMin >= rangeSlider_temp.from && currentDevice.limitTempMin <= rangeSlider_temp.to)) {
                                currentDevice.limitTempMin = first.value.toFixed(0)
                            }
                        }
                    }
                    second.onValueChanged: {
                        if (currentDevice) {
                            if ((second.value > rangeSlider_temp.from && second.value < rangeSlider_temp.to) ||
                                (second.value >= rangeSlider_temp.from && second.value <= rangeSlider_temp.to &&
                                 currentDevice.limitTempMax >= rangeSlider_temp.from && currentDevice.limitTempMax <= rangeSlider_temp.to)) {
                                currentDevice.limitTempMax = second.value.toFixed(0)
                            }
                        }
                    }
                }
            }
            Text {
                id: legendTemp
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 16

                visible: itemTemp.visible

                text: qsTr("Most indoor plants thrive between 15 and 25°C (59 to 77°F). Not many plants can tolerate -2°C (28°F) and below.") +
                      qsTr("<br><b>Tip: </b>") + qsTr("Having constant temperature is important for indoor plants.") +
                      qsTr("<br><b>Tip: </b>") + qsTr("If you have an hygrometer, you can monitor the air humidity so it stays between 40 and 60% (and even above for tropical plants).")
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item {
                id: itemLumi
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: imageLumi
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 8

                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
                }
                Text {
                    anchors.left: imageLumi.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageLumi.verticalCenter
                    anchors.verticalCenterOffset: 1

                    text: qsTr("Luminosity")
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_lumi
                    height: 20
                    anchors.top: imageLumi.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    unit: "k"
                    kshort: true
                    from: 0
                    to: outsideMode ? 100000 : 10000
                    stepSize: outsideMode ? 5000 : 1000

                    first.onValueChanged: {
                        if (currentDevice) {
                            if (first.value < rangeSlider_lumi.to ||
                                (first.value <= rangeSlider_lumi.to && currentDevice.limitLuxMin <= rangeSlider_lumi.to)) {
                                currentDevice.limitLuxMin = first.value.toFixed(0)
                            }
                        }
                    }
                    second.onValueChanged: {
                        if (currentDevice) {
                            if (second.value < rangeSlider_lumi.to ||
                                (second.value <= rangeSlider_lumi.to && currentDevice.limitLuxMax <= rangeSlider_lumi.to)) {
                                currentDevice.limitLuxMax = second.value.toFixed(0)
                            }
                        }
                    }

                    Row {
                        id: lumiScale
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 24

                        spacing: 2

                        Rectangle {
                            id: lux_1
                            height: 16
                            width: (lumiScale.width - 4) * 0.1 // 0 to 1k
                            visible: !outsideMode
                            color: Theme.colorGrey
                            Text {
                                anchors.fill: parent
                                text: qsTr("low")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_2
                            height: 16
                            width: (lumiScale.width - 8) * 0.2 // 1k to 3k
                            visible: !outsideMode
                            color: "grey"
                            Text {
                                anchors.fill: parent
                                text: qsTr("indirect")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_3
                            height: 16
                            width: (lumiScale.width - 16) * 0.5 // 3k to 8k
                            visible: !outsideMode
                            color: Theme.colorYellow
                            Text {
                                anchors.fill: parent
                                text: qsTr("direct light (indoor)")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_4
                            height: 16
                            width: (lumiScale.width - 0) * 0.2 // 8k+
                            visible: !outsideMode
                            color: "orange"
                            Text {
                                anchors.fill: parent
                                text: qsTr("sunlight")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            id: lux_5
                            height: 16
                            width: (lumiScale.width - 6) * 0.16 // 0-15k
                            visible: outsideMode
                            color: "grey"
                            Text {
                                anchors.fill: parent
                                text: qsTr("indirect")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            id: lux_6
                            height: 16
                            width: (lumiScale.width - 6) * 0.84 // 15k+
                            visible: outsideMode
                            color: Theme.colorYellow
                            Text {
                                anchors.fill: parent
                                text: qsTr("sunlight")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
            Text {
                id: legendLumi
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 16

                visible: itemLumi.visible

                text: qsTr("Some plants like direct sun exposition, all day long or just for part of the day. But many indoor plants don't like direct sunlight: place them away from south oriented windows!")
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item {
                id: itemCondu
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: imageCondu
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 8

                    rotation: 90
                    color: Theme.colorText
                    source: "qrc:/assets/icons_material/baseline-tonality-24px.svg"
                }
                Text {
                    anchors.left: imageCondu.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: imageCondu.verticalCenter
                    anchors.verticalCenterOffset: 0

                    text: qsTr("Fertility")
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.capitalization: Font.AllUppercase
                }

                RangeSliderValueSolid {
                    id: rangeSlider_condu
                    height: 20
                    anchors.top: imageCondu.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    colorBg: Theme.colorYellow
                    colorFg: Theme.colorGreen
                    from: 0
                    to: 2000
                    stepSize: 50
                    first.onValueChanged: if (currentDevice) currentDevice.limitConduMin = first.value.toFixed(0);
                    second.onValueChanged: if (currentDevice) currentDevice.limitConduMax = second.value.toFixed(0);
                }
            }
            Text {
                id: legendCondu
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 16

                visible: itemCondu.visible

                text: qsTr("Soil fertility value is an indication of the availability of nutrients in the soil. Use fertilizer (with moderation) to keep this value up.") +
                      qsTr("<br><b>Tip: </b>") + qsTr("Be sure to use the right soil composition for your plants.")
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }
        }
    }
}
