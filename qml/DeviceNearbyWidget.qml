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

    Column {
        id: col
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Text {
            text: device.deviceName
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
        }
        Text {
            text: qsTr("RSSI -%1 db").arg(Math.abs(device.deviceRssi))
            font.pixelSize: Theme.fontSizeContentSmall
            color: Theme.colorSubText
        }
    }

    ////////

    ImageSvg {
        anchors.right: imgsupp.left
        anchors.rightMargin: 12
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

    ImageSvg {
        id: imgsupp
        anchors.right: barbg.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

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
                return "qrc:/assets/icons_material/baseline-stars-24px.svg"
/*
            if (device.deviceName === "Flower care" || device.deviceName === "Flower power" ||
                device.deviceName === "Flower mate" || device.deviceName === "Grow care garden")
                return "qrc:/assets/icons_material/outline-local_florist-24px.svg"
            if (device.deviceName === "ropot" || device.deviceName === "Parrot pot")
                return "qrc:/assets/icons_custom/pot_flower-24px.svg"

            if (device.deviceName === "MJ_HT_V1" ||
                device.deviceName === "ClearGrass Temp & RH" ||
                device.deviceName === "Qingping Temp & RH M" || device.deviceName === "Qingping Temp & RH H" ||
                device.deviceName === "Qingping Temp RH Lite" ||
                device.deviceName === "ThermoBeacon")
                return "qrc:/assets/icons_material/baseline-trip_origin-24px.svg"
            if (device.deviceName === "LYWSD02" || device.deviceName === "MHO-C303")
                return "qrc:/assets/icons_material/baseline-crop_16_9-24px.svg"
            if (device.deviceName === "LYWSD03MMC" || device.deviceName === "MHO-C401")
                return "qrc:/assets/icons_material/baseline-crop_square-24px.svg"

            if (device.deviceName === "WP6003" || device.deviceName === "AirQualityMonitor")
                return "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
            if (device.deviceName === "GeigerCounter")
                return "qrc:/assets/icons_custom/nuclear_icon.svg"
*/
            return ""
        }
    }

    ////////

    Rectangle {
        id: barbg
        anchors.right: parent.right
        anchors.rightMargin: 12
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

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.colorSeparator
    }
}
