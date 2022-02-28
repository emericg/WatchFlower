import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: deviceNearbyWidget
    implicitWidth: 640
    implicitHeight: 48

    opacity: (device.deviceRssi < 0) ? 1 : 0.66
    color: (device.selected) ? Theme.colorForeground : Theme.colorBackground

    property var device: pointer
    property bool blacklisted: deviceManager.isBleDeviceBlacklisted(device.deviceAddress)

    Connections {
        target: deviceManager
        function onDevicesBlacklistUpdated() {
            deviceNearbyWidget.blacklisted = deviceManager.isBleDeviceBlacklisted(device.deviceAddress)
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !singleColumn
        onClicked: device.selected = !device.selected
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: col
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Row {
            spacing: 8

            Text {
                id: deviceTitle
                text: device.deviceName
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }

            IconSvg {
                anchors.verticalCenter: parent.verticalCenter
                visible: singleColumn

                width: height
                height: deviceTitle.height
                color: Theme.colorGreen
                opacity: 0.8
                source: {
                    if (device.deviceName === "Flower care" || device.deviceName === "Flower power" ||
                        device.deviceName === "Flower mate" || device.deviceName === "Grow care garden" ||
                        device.deviceName === "ropot" || device.deviceName === "Parrot pot" ||
                        device.deviceName === "MJ_HT_V1" ||
                        device.deviceName === "ClearGrass Temp & RH" ||
                        device.deviceName === "Qingping Temp & RH M" || device.deviceName === "Qingping Temp & RH H" ||
                        device.deviceName === "Qingping Temp RH Lite" ||
                        device.deviceName === "ThermoBeacon" ||
                        device.deviceName === "LYWSD02" || device.deviceName === "MHO-C303" ||
                        device.deviceName === "LYWSD03MMC" || device.deviceName === "MHO-C401" ||
                        device.deviceName === "WP6003" || device.deviceName === "AirQualityMonitor" ||
                        device.deviceName === "GeigerCounter")
                        return "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                    return ""
                }
            }
        }

        Row {
            spacing: 16

            Text {
                text: device.deviceAddress
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
                visible: !(Qt.platform.os === "osx" || Qt.platform.os === "ios")
            }
/*
            Text {
                text: qsTr("RSSI -%1 dB").arg(Math.abs(device.deviceRssi))
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
            }
*/
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        IconSvg {
            anchors.verticalCenter: parent.verticalCenter

            width: 20
            height: 20
            visible: (device.deviceName === "Flower care" || device.deviceName === "Flower power" ||
                      device.deviceName === "Flower mate" || device.deviceName === "Grow care garden" ||
                      device.deviceName === "ropot" || device.deviceName === "Parrot pot" ||
                      device.deviceName === "MJ_HT_V1" ||
                      device.deviceName === "ClearGrass Temp & RH" ||
                      device.deviceName === "Qingping Temp & RH M" || device.deviceName === "Qingping Temp & RH H" ||
                      device.deviceName === "Qingping Temp RH Lite" ||
                      device.deviceName === "ThermoBeacon" ||
                      device.deviceName === "LYWSD02" || device.deviceName === "MHO-C303" ||
                      device.deviceName === "LYWSD03MMC" || device.deviceName === "MHO-C401" ||
                      device.deviceName === "WP6003" || device.deviceName === "AirQualityMonitor" ||
                      device.deviceName === "GeigerCounter")

            source: blacklisted ? "qrc:/assets/icons_material/outline-remove_circle-24px.svg" : "qrc:/assets/icons_material/outline-add_circle-24px.svg"
            color: {
                if (ma.hovered) return Theme.colorPrimary
                if (blacklisted) return Theme.colorRed
                return Theme.colorIcon
            }

            MouseArea {
                id: ma
                anchors.fill: parent

                hoverEnabled: true
                property bool hovered: false
                onEntered:hovered = true
                onExited: hovered = false
                onCanceled: hovered = false

                onClicked: {
                    confirmBlacklistDevice.deviceName = device.deviceName
                    confirmBlacklistDevice.deviceAddress = device.deviceAddress
                    confirmBlacklistDevice.open()
                }
            }
        }

        ////////

        IconSvg {
            anchors.verticalCenter: parent.verticalCenter
            visible: !singleColumn

            width: 20
            height: 20
            color: Theme.colorIcon
            source: {
                if (device.deviceName === "Flower care" || device.deviceName === "Flower power" ||
                    device.deviceName === "Flower mate" || device.deviceName === "Grow care garden" ||
                    device.deviceName === "ropot" || device.deviceName === "Parrot pot" ||
                    device.deviceName === "MJ_HT_V1" ||
                    device.deviceName === "ClearGrass Temp & RH" ||
                    device.deviceName === "Qingping Temp & RH M" || device.deviceName === "Qingping Temp & RH H" ||
                    device.deviceName === "Qingping Temp RH Lite" ||
                    device.deviceName === "ThermoBeacon" ||
                    device.deviceName === "LYWSD02" || device.deviceName === "MHO-C303" ||
                    device.deviceName === "LYWSD03MMC" || device.deviceName === "MHO-C401" ||
                    device.deviceName === "WP6003" || device.deviceName === "AirQualityMonitor" ||
                    device.deviceName === "GeigerCounter")
                    return "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                return ""
            }
        }

        ////////

        Rectangle {
            id: barbg
            anchors.verticalCenter: parent.verticalCenter

            width: 128
            height: 16
            radius: 3
            color: Theme.colorSeparator

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: parent.width * Math.abs(device.deviceRssi / 100)
                radius: 3
                color: {
                    if (device.deviceRssi < 0) {
                        if (device.deviceRssi > -65) return Theme.colorGreen
                        if (device.deviceRssi > -85) return Theme.colorOrange
                        if (device.deviceRssi > -100) return Theme.colorRed
                    } else {
                        if (device.deviceRssi < 65) return Theme.colorGreen
                        if (device.deviceRssi < 85) return Theme.colorOrange
                        if (device.deviceRssi < 100) return Theme.colorRed
                    }
                    return Theme.colorRed
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("-%1 dB").arg(Math.abs(device.deviceRssi))
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentVerySmall
                    color: "white"
                }
            }

            //layer.enabled: false
            //layer.effect: OpacityMask {
            //    maskSource: Rectangle {
            //        x: barbg.x
            //        y: barbg.y
            //        width: barbg.width
            //        height: barbg.height
            //        radius: 4
            //    }
            //}
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.colorSeparator
    }
}
