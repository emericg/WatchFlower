import QtQuick
import QtQuick.Layouts

import ThemeEngine
import "qrc:/js/UtilsNumber.js" as UtilsNumber
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Flickable {
    id: plantSensorSettings

    contentWidth: -1
    contentHeight: flow.height

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("plantSensorSettings // updateHeader() >> " + currentDevice)

        plantSensorSettings.contentY = 0
    }

    function backAction() {
        screenDeviceList.loadScreen()
    }

    ////////////////////////////////////////////////////////////////////////////

    // 1: single column (single column view or portrait tablet)
    // 2: wide mode (wide view)
    property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

    property int flow_width: (flow.width - flow.spacing)
    property int flow_divider: Math.round(flow_width / 512)
    property int www: ((flow_width - (flow.spacing * flow_divider)) / flow_divider)

    Flow {
        id: flow
        anchors.left: parent.left
        anchors.right: parent.right
        height: (uiMode === 1) ? maxheight : plantSensorSettings.height

        property int maxheight: 2*topPadding + 3*spacing + itemDevice.height + itemDeviceInfos.height +
                                itemDeviceConnection.height + itemDeviceSensors.height + itemDeviceSettings.height

        padding: Theme.componentMargin
        spacing: Theme.componentMargin
        flow: Flow.TopToBottom

        ////////////////////////////////

        FrameThemed {
            id: itemDevice
            width: www

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Column {
                    Layout.fillWidth: true

                    Text {
                        text: qsTr("Bluetooth name")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        width: parent.width

                        text: currentDevice.deviceName
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        font.capitalization: Font.Capitalize
                        color: Theme.colorText
                        elide: Text.ElideRight
                    }
                }

                Column {
                    Layout.fillWidth: true

                    Text {
                        text: qsTr("Bluetooth address")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        width: parent.width

                        text: (Qt.platform.os === "osx" || Qt.platform.os === "ios") ?
                                  currentDevice.deviceAddress :
                                  "[" + currentDevice.deviceAddress + "]"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContentBig
                        font.capitalization: Font.AllUppercase
                        elide: Text.ElideRight
                    }
                }

                Column {
                    Layout.fillWidth: true
                    visible: currentDevice.deviceAddressMAC.length && (Qt.platform.os === "osx" || Qt.platform.os === "ios")

                    Text {
                        text: qsTr("MAC Address")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        text: "[" + currentDevice.deviceAddressMAC + "]"
                        textFormat: Text.PlainText
                        color: Theme.colorText
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
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceFirmware
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText

                            IconSvg {
                                id: imageFwUpdate
                                width: parent.height - 4
                                height: parent.height - 4
                                anchors.left: parent.right
                                anchors.leftMargin: 6
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                                color: Theme.colorGreen
                                visible: currentDevice.deviceFirmwareUpToDate
                            }
                        }
                    }

                    Column {
                        visible: (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)

                        Text {
                            text: qsTr("Battery")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceBattery + "%"
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText

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
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: uptime
                        text: currentDevice.deviceUptime.toLocaleString(Locale.ShortFormat)
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }

                Column {
                    visible: lastmove.text

                    Text {
                        text: qsTr("Last time moved")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: lastmove
                        text: currentDevice.lastMove.toLocaleString(Locale.ShortFormat)
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }

                Column {
                    visible: lastupdate.text

                    Text {
                        text: qsTr("Last update")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: lastupdate
                        text: currentDevice.lastUpdate.toLocaleString(Locale.ShortFormat)
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }

                Column {
                    visible: lastsync.text

                    Text {
                        text: qsTr("Last history sync")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        id: lastsync
                        text: currentDevice.lastHistorySync.toLocaleString(Locale.ShortFormat)
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }
            }
        }

        ////////////////////////////////

        FrameThemed {
            id: itemDeviceInfos
            width: www

            visible: currentDevice.deviceInfos

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Column {
                    Text {
                        text: qsTr("Model")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        text: currentDevice.deviceInfos.deviceModel
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }

                Column {
                    Text {
                        text: qsTr("Manufacturer")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        text: currentDevice.deviceInfos.deviceManufacturer
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }

                Column {
                    Text {
                        text: qsTr("Product ID")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        text: currentDevice.deviceInfos.deviceId
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }

                Row {
                    spacing: 32

                    Column {
                        visible: currentDevice.deviceInfos.deviceYear

                        Text {
                            text: qsTr("Year")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceInfos.deviceYear
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }

                    Column {
                        visible: currentDevice.deviceInfos.deviceIPrating

                        Text {
                            text: qsTr("IP Rating")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceInfos.deviceIPrating
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }
                }

                Row {
                    spacing: 32

                    Column {
                        visible: currentDevice.deviceInfos.deviceBattery

                        Text {
                            text: qsTr("Battery")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            textFormat: Text.PlainText
                            text: currentDevice.deviceInfos.deviceBattery
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }

                    Column {
                        visible: currentDevice.deviceInfos.deviceScreen

                        Text {
                            text: qsTr("Screen")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                        }
                        Text {
                            text: currentDevice.deviceInfos.deviceScreen
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }
                }
            }
        }

        ////////////////////////////////

        FrameThemed {
            id: itemDeviceConnection
            width: www

            visible: currentDevice.deviceInfos && currentDevice.deviceInfos.deviceNeedsOfficialApp

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Row {
                    spacing: 8

                    IconSvg {
                        width: 20; height: 20;
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                        color: Theme.colorWarning
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Be advised")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                    }
                }

                Text {
                    Layout.fillWidth: true

                    text: qsTr("This sensor needs to be registered to its official application once before it can be used with third party applications like WatchFlower.")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: false
                    font.pixelSize: Theme.fontSizeContentSmall
                    wrapMode: Text.WordWrap
                }
            }
        }

        ////////////////////////////////

        FrameThemed {
            id: itemDeviceSensors
            width: www

            visible: currentDevice.deviceInfos

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Text {
                    visible: repeaterSensors.count
                    text: qsTr("Sensors")
                    textFormat: Text.PlainText
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
                            borderVisible: true
                            backgroundVisible: true
                            backgroundColor: Theme.colorBackground
                            iconColor: Theme.colorIcon
                            source: UtilsDeviceSensors.getDeviceSensorIcon(modelData.sensorId)
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: UtilsDeviceSensors.getDeviceSensorName(modelData.sensorId)
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                color: Theme.colorText
                            }
                            Text {
                                text: modelData.sensorString
                                textFormat: Text.PlainText
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
                    textFormat: Text.PlainText
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
                            borderVisible: true
                            backgroundVisible: true
                            backgroundColor: Theme.colorBackground
                            iconColor: Theme.colorIcon
                            source: UtilsDeviceSensors.getDeviceCapabilityIcon(modelData.capabilityId)
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: UtilsDeviceSensors.getDeviceCapabilityName(modelData.capabilityId)
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                color: Theme.colorText
                            }
                            Text {
                                text: modelData.capabilityString
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentSmall
                                color: Theme.colorSubText
                            }
                        }
                    }
                }
            }
        }

        ////////////////////////////////

        FrameThemed {
            id: itemDeviceSettings
            width: www

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Text {
                    text: qsTr("Settings")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentVerySmall
                    font.capitalization: Font.AllUppercase
                }

                SwitchThemed {
                    text: checked ? qsTr("Device is enabled") : qsTr("Device is disabled")
                    checked: currentDevice.deviceEnabled
                    onClicked: currentDevice.deviceEnabled = checked
                }

                Row {
                    spacing: 16

                    Rectangle { // rectangle inside
                        width: 96; height: 96; radius: 96;
                        anchors.bottom: parent.bottom

                        color: Theme.colorBackground
                        border.width: (currentDevice && currentDevice.deviceIsInside) ? 2 : 0
                        border.color: Qt.darker(color, 1.03)

                        opacity: (currentDevice && currentDevice.deviceIsInside) ? 1 : 0.5
                        Behavior on opacity { OpacityAnimator { duration: 133 } }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentDevice.deviceIsInside = true
                        }

                        Column {
                            anchors.centerIn: parent

                            IconSvg {
                                width: 40; height: 40;
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Theme.colorIcon
                                source: "qrc:/assets/icons_custom/inside-24px.svg"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("inside")
                                textFormat: Text.PlainText
                                color: Theme.colorText
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                        }
                    }

                    Rectangle { // rectangle outside
                        width: 96; height: 96; radius: 96;
                        anchors.bottom: parent.bottom

                        color: Theme.colorBackground
                        border.width: (currentDevice && currentDevice.deviceIsOutside) ? 2 : 0
                        border.color: Qt.darker(color, 1.03)

                        opacity: (currentDevice && currentDevice.deviceIsOutside) ? 1 : 0.5
                        Behavior on opacity { OpacityAnimator { duration: 133 } }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentDevice.deviceIsOutside = true
                        }

                        Column {
                            anchors.centerIn: parent

                            IconSvg {
                                width: 40; height: 40;
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "qrc:/assets/icons_custom/outside-24px.svg"
                                color: Theme.colorIcon
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("outside")
                                textFormat: Text.PlainText
                                color: Theme.colorText
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                        }
                    }
                }

                Column {
                    Layout.fillWidth: true

                    visible: (Qt.platform.os === "osx" || Qt.platform.os === "ios")
                    topPadding: 8
                    spacing: 6

                    Text {
                        text: qsTr("MAC Address")
                        textFormat: Text.PlainText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContentVerySmall
                        font.capitalization: Font.AllUppercase
                        color: Theme.colorSubText
                    }

                    Text {
                        width: parent.width

                        text: "The MAC address of the sensor must be set in order for some features (like history synchronization) to work."
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        width: parent.width

                        text: "Sorry for the inconvenience."
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        width: parent.width

                        height: 36
                        radius: Theme.componentRadius

                        IconSvg {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 24

                            color: Theme.colorIcon
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
                            color: Theme.colorText

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
