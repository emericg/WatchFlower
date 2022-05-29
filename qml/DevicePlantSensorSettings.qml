import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Item {
    id: devicePlantSensorSettings

    property bool insideMode: (currentDevice && currentDevice.deviceIsInside)
    property bool outsideMode: (currentDevice && currentDevice.deviceIsOutside)

    ////////////////////////////////////////////////////////////////////////////

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("devicePlantSensorSettings // updateHeader() >> " + currentDevice)
    }

    ////////////////////////////////////////////////////////////////////////////

    property int flow_width: (flow.width - flow.spacing)
    property int flow_divider: Math.round(flow_width / 512)
    property int www: ((flow_width - (flow.spacing * flow_divider)) / flow_divider)

    Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: flow.height

        Flow {
            id: flow
            anchors.left: parent.left
            anchors.right: parent.right
            height: singleColumn ? maxheight : devicePlantSensorSettings.height

            property int maxheight: 2*topPadding + 3*spacing + itemDevice.height + itemDeviceInfos.height + itemDeviceSensors.height + itemDeviceSettings.height

            topPadding: 14
            padding: 12
            bottomPadding: 14
            spacing: 12
            flow: Flow.TopToBottom

            ////////////////////////////////

            Rectangle {
                id: itemDevice
                width: www
                height: itemDeviceContent.height + 24

                radius: Theme.componentRadius
                color: Theme.colorForeground
                border.width: 2
                border.color: Theme.colorSeparator

                IconSvg {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.bottom: parent.bottom
                    anchors.margins: 0

                    width: parent.height * 0.85
                    height: parent.height * 0.85

                    asynchronous: true
                    smooth: true
                    opacity: 0.15
                    color: Theme.colorSubText
                    fillMode: Image.PreserveAspectFit

                    source: {
                        if (currentDevice.deviceName === "Flower care") return "qrc:/devices/flowercare.svg"
                        if (currentDevice.deviceName === "Grow care garden") return "qrc:/devices/flowercaremax.svg"
                        if (currentDevice.deviceName === "Flower power") return "qrc:/devices/flowerpower.svg"
                        if (currentDevice.deviceName === "Parrot pot") return "qrc:/devices/parrotpot.svg"
                        if (currentDevice.deviceName === "ropot") return "qrc:/devices/ropot.svg"
                        if (currentDevice.deviceName === "HiGrow") return "qrc:/devices/higrow.svg"
                        return ""
                    }
                }

                Column {
                    id: itemDeviceContent
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    spacing: 12

                    Column {
                        Text {
                            text: qsTr("Device")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceName
                            font.pixelSize: Theme.fontSizeContentBig
                            font.capitalization: Font.Capitalize
                            color: Theme.colorHighContrast
                        }
                    }

                    Column {
                        Text {
                            text: qsTr("Address")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: (Qt.platform.os === "osx" || Qt.platform.os === "ios") ?
                                      currentDevice.deviceAddress :
                                      "[" + currentDevice.deviceAddress + "]"
                            color: Theme.colorHighContrast
                            font.pixelSize: Theme.fontSizeContentBig
                            font.capitalization: Font.AllUppercase
                        }
                    }

                    Column {
                        visible: currentDevice.deviceAddressMAC.length && (Qt.platform.os === "osx" || Qt.platform.os === "ios")

                        Text {
                            text: qsTr("MAC Address")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: "[" + currentDevice.deviceAddressMAC + "]"
                            color: Theme.colorHighContrast
                            font.pixelSize: Theme.fontSizeContentBig
                            font.capitalization: Font.AllUppercase
                        }
                    }

                    Row {
                        spacing: 32

                        Column {
                            visible: (currentDevice.deviceFirmware)

                            Text {
                                text: qsTr("Firmware")
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                text: currentDevice.deviceFirmware
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorHighContrast

                                IconSvg {
                                    id: imageFwUpdate
                                    width: parent.height - 4; height: parent.height - 4;
                                    anchors.left: parent.right
                                    anchors.leftMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter

                                    source: "qrc:/assets/icons_material/baseline-new_releases-24px.svg"
                                    color: Theme.colorSubText
                                    visible: !currentDevice.deviceFirmwareUpToDate
                                }
                            }
                        }

                        Column {
                            visible: (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)

                            Text {
                                text: qsTr("Battery")
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                text: currentDevice.deviceBattery + "%"
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorHighContrast

                                IconSvg {
                                    id: imageBattery
                                    width: 32; height: 32;
                                    rotation: 90
                                    anchors.left: parent.right
                                    anchors.leftMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter

                                    source: UtilsDeviceSensors.getDeviceBatteryIcon(currentDevice.deviceBattery)
                                    color: UtilsDeviceSensors.getDeviceBatteryColor(currentDevice.deviceBattery)
                                }
                            }
                        }
                    }

                    Column {
                        visible: uptime.text

                        Text {
                            text: qsTr("Uptime")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: uptime
                            text: currentDevice.deviceUptime.toLocaleString(Locale.ShortFormat)
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHighContrast
                        }
                    }
/*
                    Column {
                        visible: lastmove.text

                        Text {
                            text: qsTr("Last time moved")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: lastmove
                            text: currentDevice.lastMove.toLocaleString(Locale.ShortFormat)
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHighContrast
                        }
                    }
*/
                    Column {
                        visible: lastupdate.text

                        Text {
                            text: qsTr("Last update")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: lastupdate
                            text: currentDevice.lastUpdate.toLocaleString(Locale.ShortFormat)
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHighContrast
                        }
                    }

                    Column {
                        visible: lastsync.text

                        Text {
                            text: qsTr("Last history sync")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            id: lastsync
                            text: currentDevice.lastHistorySync.toLocaleString(Locale.ShortFormat)
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHighContrast
                        }
                    }
                }
            }

            ////////////////////////////////

            Rectangle {
                id: itemDeviceInfos
                width: www
                height: itemDeviceInfosContent.height + 24

                radius: Theme.componentRadius
                color: Theme.colorForeground
                border.width: 2
                border.color: Theme.colorSeparator

                Column {
                    id: itemDeviceInfosContent
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    spacing: 8

                    Column {
                        Text {
                            text: qsTr("Manufacturer")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceInfos.deviceManufacturer
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHighContrast
                        }
                    }

                    Column {
                        Text {
                            text: qsTr("Product ID")
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceInfos.deviceId
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHighContrast
                        }
                    }

                    Row {
                        spacing: 32

                        Column {
                            Text {
                                text: qsTr("Year")
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                text: currentDevice.deviceInfos.deviceYear
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorHighContrast
                            }
                        }

                        Column {
                            Text {
                                text: qsTr("IP Rating")
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                text: currentDevice.deviceInfos.deviceIPrating
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorHighContrast
                            }
                        }
                    }

                    Row {
                        spacing: 32

                        Column {
                            visible: dbatt.text

                            Text {
                                text: qsTr("Battery")
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                id: dbatt
                                text: currentDevice.deviceInfos.deviceBattery
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorHighContrast
                            }
                        }

                        Column {
                            visible: dscreen.text

                            Text {
                                text: qsTr("Screen")
                                color: Theme.colorSubText
                                font.bold: true
                                font.pixelSize: Theme.fontSizeContentVerySmall
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                id: dscreen
                                text: currentDevice.deviceInfos.deviceScreen
                                font.pixelSize: Theme.fontSizeContentBig
                                color: Theme.colorHighContrast
                            }
                        }
                    }
                }
            }

            ////////////////////////////////

            Rectangle {
                id: itemDeviceSensors
                width: www
                height: itemDeviceSensorsContent.height + 24

                radius: Theme.componentRadius
                color: Theme.colorForeground
                border.width: 2
                border.color: Theme.colorSeparator

                Column {
                    id: itemDeviceSensorsContent
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        visible: repeaterSensors.count
                        text: qsTr("Sensors")
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }

                    Repeater {
                        id: repeaterSensors
                        model: currentDevice.deviceInfos.deviceSensors

                        Row {
                            spacing: 12

                            RoundButtonIcon {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: Theme.colorBackground
                                iconColor: Theme.colorText
                                source: UtilsDeviceSensors.getDeviceSensorIcon(modelData.sensorId)
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: UtilsDeviceSensors.getDeviceSensorName(modelData.sensorId)
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                }
                                Text {
                                    text: modelData.sensorString
                                    font.pixelSize: Theme.fontSizeContentSmall
                                    color: Theme.colorSubText
                                }
                            }
                        }
                    }

                    Text {
                        height: 24
                        verticalAlignment: Text.AlignBottom
                        visible: repeaterCapabilities.count

                        text: qsTr("Capabilities")
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }

                    Repeater {
                        id: repeaterCapabilities
                        model: currentDevice.deviceInfos.deviceCapabilities

                        Row {
                            spacing: 12

                            RoundButtonIcon {
                                width: 40; height: 40;
                                border: true
                                background: true
                                backgroundColor: Theme.colorBackground
                                iconColor: Theme.colorText
                                source: UtilsDeviceSensors.getDeviceCapabilityIcon(modelData.capabilityId)
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: UtilsDeviceSensors.getDeviceCapabilityName(modelData.capabilityId)
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                }
                                Text {
                                    text: modelData.capabilityString
                                    font.pixelSize: Theme.fontSizeContentSmall
                                    color: Theme.colorSubText
                                }
                            }
                        }
                    }
                }
            }

            ////////////////////////////////

            Rectangle {
                id: itemDeviceSettings
                width: www
                height: itemDeviceSettingsContent.height + 24

                radius: Theme.componentRadius
                color: Theme.colorForeground
                border.width: 2
                border.color: Theme.colorSeparator

                Column {
                    id: itemDeviceSettingsContent
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: qsTr("Settings")
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }

                    SwitchThemedDesktop {
                        text: checked ? qsTr("Device is enabled") : qsTr("Device is disabled")
                        checked: currentDevice.deviceEnabled
                        onClicked: currentDevice.deviceEnabled = checked
                    }

                    Row {
                        id: itemInOut
                        spacing: 16

                        Rectangle {
                            id: rectangleInside
                            width: 96
                            height: 96
                            radius: 96
                            anchors.bottom: parent.bottom

                            color: Theme.colorBackground
                            border.width: (insideMode) ? 2 : 0
                            border.color: Theme.colorSeparator

                            opacity: insideMode ? 1 : 0.5
                            Behavior on opacity { OpacityAnimator { duration: 133 } }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: currentDevice.deviceIsInside = true
                            }

                            Column {
                                anchors.centerIn: parent

                                IconSvg {
                                    id: insideImage
                                    width: 40; height: 40;
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
                            width: 96
                            height: 96
                            radius: 96
                            anchors.bottom: parent.bottom

                            color: Theme.colorBackground
                            border.width: (outsideMode) ? 2 : 0
                            border.color: Theme.colorSeparator

                            opacity: outsideMode ? 1 : 0.5
                            Behavior on opacity { OpacityAnimator { duration: 133 } }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: currentDevice.deviceIsOutside = true
                            }

                            Column {
                                anchors.centerIn: parent

                                IconSvg {
                                    id: outsideImage
                                    width: 40; height: 40;
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

                    Column {
                        id: itemMacAddr
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: (Qt.platform.os === "osx" || Qt.platform.os === "ios")
                        topPadding: 8
                        spacing: 6

                        Text {
                            text: qsTr("MAC Address")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            text: "The MAC address of the sensor must be set in order for some features (like history synchronization) to work."
                            color: Theme.colorSubText
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            text: "Sorry for the inconvenience."
                            color: Theme.colorSubText
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            height: 36
                            radius: Theme.componentRadius

                            IconSvg {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                width: 24
                                height: 24

                                color: Theme.colorSubText
                                source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                            }

                            TextInput {
                                id: textInputMacAddr
                                anchors.left: parent.left
                                anchors.leftMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                padding: 8

                                font.pixelSize: 17
                                font.bold: false
                                color: Theme.colorHighContrast

                                text: currentDevice.deviceAddressMAC

                                inputMask: "HH:HH:HH:HH:HH:HH"
                                onEditingFinished: {
                                    if (text) currentDevice.deviceAddressMAC = text
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

                                    onPressed: (mouse) => {
                                        textInputMacAddr.forceActiveFocus()
                                        mouse.accepted = false
                                    }
                                }

                                IconSvg {
                                    id: imageEditMacAddr
                                    width: 20
                                    height: 20
                                    anchors.left: parent.right
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter

                                    source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                                    color: Theme.colorSubText

                                    opacity: (isMobile || !textInputMacAddr.text || textInputMacAddr.focus || textInputMacAddrArea.containsMouse) ? 0.9 : 0
                                    Behavior on opacity { OpacityAnimator { duration: 133 } }
                                }
                            }
                        }
                    }
                }
            }

            ////////////////////////////////
        }
    }
}
