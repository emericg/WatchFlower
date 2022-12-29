import QtQuick

import ThemeEngine 1.0
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Rectangle {
    id: deviceNearbyWidget
    implicitWidth: 480
    implicitHeight: 48

    opacity: (device.rssi < 0) ? 1 : 0.66
    color: (device.selected) ? Theme.colorForeground : Theme.colorBackground

    property var device: pointer
    property bool deviceSupported: UtilsDeviceSensors.isDeviceSupported(device.deviceName)
    property bool deviceBlacklisted: deviceManager.isBleDeviceBlacklisted(device.deviceAddress)

    Connections {
        target: deviceManager
        function onDevicesBlacklistUpdated() {
            deviceNearbyWidget.deviceBlacklisted = deviceManager.isBleDeviceBlacklisted(device.deviceAddress)
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !singleColumn
        onClicked: device.selected = !device.selected
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            id: deviceTitle
            text: (device.deviceName.length ? device.deviceName : "No name")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: (device.deviceName.length ? Theme.colorText : Theme.colorSubText)
        }

        Text {
            text: device.deviceAddress
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentSmall
            color: Theme.colorSubText
            visible: !(Qt.platform.os === "osx" || Qt.platform.os === "ios")
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        ////////

        IconSvg {
            anchors.verticalCenter: parent.verticalCenter

            width: 20
            height: 20
            visible: deviceSupported
            enabled: true

            source: deviceBlacklisted ? "qrc:/assets/icons_material/outline-remove_circle-24px.svg"
                                      : "qrc:/assets/icons_material/outline-add_circle-24px.svg"
            color: {
                if (ma.hovered) return Theme.colorPrimary
                if (deviceBlacklisted) return Theme.colorRed
                return Theme.colorIcon
            }

            MouseArea {
                id: ma
                anchors.fill: parent

                hoverEnabled: true
                property bool hovered: false
                onEntered: hovered = true
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
            color: deviceSupported ? Theme.colorGreen : Theme.colorSubText
            source: deviceSupported ? "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                                    : "qrc:/assets/icons_material/baseline-help-24px.svg"
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
                width: parent.width * Math.abs(device.rssi / 100)
                radius: 3
                color: {
                    if (Math.abs(device.rssi) < 65) return Theme.colorGreen
                    if (Math.abs(device.rssi) < 85) return Theme.colorOrange
                    if (Math.abs(device.rssi) < 100) return Theme.colorRed
                    return Theme.colorRed
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("-%1 dB").arg(Math.abs(device.rssi))
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
