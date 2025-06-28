import QtQuick
import QtQuick.Controls

import ComponentLibrary
import SmartCare

Item {
    id: deviceBrowser
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // start nearby scanning
        deviceManager.scanNearby_start()

        // change screen
        appContent.state = "DeviceBrowser"
    }

    function backAction() {
        if (loaderDeviceBrowser.sourceComponent) {
            loaderDeviceBrowser.item.backAction()
        }
    }

    Loader {
        id: loaderDeviceBrowser
        anchors.fill: parent

        active: (appContent.state === "DeviceBrowser")
        sourceComponent: singleColumn ? componentDeviceBrowser_mobile : componentDeviceBrowser_desktop
        asynchronous: true
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentDeviceBrowser_mobile

        Item { // itemDeviceBrowser mobile
            anchors.fill: parent

            ////////

            function backAction() {
                if (areDeviceClicked()) {
                    //
                } else {
                    deviceManager.scanNearby_stop()
                    deviceManager.listenDevices_start()
                    screenDeviceList.loadScreen()
                }
            }

            function areDeviceClicked() {
                return false
            }

            ////////

            PopupBlacklistDevice {
                id: confirmBlacklistDevice
            }

            ListView {
                id: devicesView
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                topMargin: 6
                bottomMargin: 6

                model: deviceManager.devicesNearby
                delegate: DeviceNearbyWidget {
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                ItemNoDeviceNearby {
                    visible: (devicesView.count <= 0)
                }
            }

            Rectangle {
                id: infoBox
                anchors.left: devicesView.left
                anchors.right: devicesView.right
                anchors.bottom: devicesView.bottom
                anchors.margins: Theme.componentMargin

                height: infoText.contentHeight + Theme.componentMargin
                radius: Theme.componentRadius
                z: 2

                color: Theme.colorComponentBackground
                border.color: Theme.colorSeparator
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: parent.visible = false
                }

                IconSvg {
                    width: 28
                    height: 28
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 8

                    opacity: 0.66
                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
                }

                Text {
                    id: infoText
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 8 + 28 + 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    text: qsTr("The device browser helps you locate nearby BLE devices. You can also use this screen to blacklist sensors so the scan doesn't pick them up.")
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentDeviceBrowser_desktop

        Item { // itemDeviceBrowser desktop
            anchors.fill: parent

            ////////

            function backAction() {
                if (areDeviceClicked()) {
                    //
                } else {
                    deviceManager.scanNearby_stop()
                    deviceManager.listenDevices_start()
                    screenDeviceList.loadScreen()
                }
            }

            function areDeviceClicked() {
                return false
            }

            ////////

            PopupBlacklistDevice {
                id: confirmBlacklistDevice
            }

            ListView {
                id: devicesView
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: (parent.width / 2)

                topMargin: 8
                bottomMargin: 8

                model: deviceManager.devicesNearby
                delegate: DeviceNearbyWidget {
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                ItemNoDeviceNearby {
                    visible: (devicesView.count <= 0)
                }
            }

            Rectangle {
                id: infoBox
                anchors.left: devicesView.left
                anchors.right: devicesView.right
                anchors.bottom: devicesView.bottom
                anchors.margins: Theme.componentMargin

                height: infoText.contentHeight + 16
                radius: 4
                z: 2

                color: Theme.colorComponentBackground
                border.color: Theme.colorSeparator
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: parent.visible = false
                }

                IconSvg {
                    width: 28
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    opacity: 0.66
                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
                }

                Text {
                    id: infoText
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 8 + 28 + 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    text: qsTr("The device browser helps you locate nearby BLE devices. You can also use this screen to blacklist sensors so the scan doesn't pick them up.")
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }
            }

            ////////////////

            Rectangle {
                id: radar
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: (parent.width / 2)

                clip: true
                color: Theme.colorBackground

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: 2
                    color: Theme.colorLowContrast
                }

                Rectangle {
                    anchors.centerIn: cc
                    width: (parent.width * 1.5)
                    height: width
                    radius: width
                    color: Qt.darker(Theme.colorForeground, 1.1)
                    opacity: 0.16
                    border.width: 2
                    border.color: Theme.colorLowContrast
                }
                Rectangle {
                    anchors.centerIn: cc
                    width: (parent.width * 1.0)
                    height: width
                    radius: width
                    color: Qt.darker(Theme.colorForeground, 1.1)
                    opacity: 0.33
                    border.width: 2
                    border.color: Theme.colorLowContrast
                }
                Rectangle {
                    anchors.centerIn: cc
                    width: (parent.width * 0.66)
                    height: width
                    radius: width
                    color: Qt.darker(Theme.colorForeground, 1.1)
                    opacity: 0.6
                    border.width: 2
                    border.color: Theme.colorLowContrast
                }
                Rectangle {
                    anchors.centerIn: cc
                    width: (parent.width * 0.33)
                    height: width
                    radius: width
                    color: Qt.darker(Theme.colorForeground, 1.1)
                    opacity: 1.0
                    border.width: 2
                    border.color: Theme.colorLowContrast
                }

                Rectangle {
                    id: ra
                    anchors.centerIn: cc
                    width: 0
                    height: width
                    radius: width
                    color: Theme.colorSeparator

                    ParallelAnimation {
                        alwaysRunToEnd: true
                        loops: Animation.Infinite
                        running: (appContent.state === "DeviceBrowser" && deviceManager.listening)
                        NumberAnimation { target: ra; property: "width"; from: 0; to: radar.width*3; duration: 2500; }
                        NumberAnimation { target: ra; property: "opacity"; from: 0.85; to: 0; duration: 2500; }
                    }
                }

                Rectangle {
                    id: cc
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.bottom
                    anchors.verticalCenterOffset: -40
                    width: 80
                    height: 80
                    radius: 80
                    color: Theme.colorBackground
                    border.width: 2
                    border.color: Theme.colorSeparator

                    IconSvg {
                        anchors.centerIn: parent
                        source: "qrc:/IconLibrary/material-icons/duotone/devices.svg"
                        color: Theme.colorIcon
                    }
                }

                ////////

                Repeater {
                    anchors.fill: parent
                    anchors.margins: 24

                    model: deviceManager.devicesNearby
                    delegate: Rectangle {
                        property var boxDevice: pointer

                        // Using pythagores
                        //property int a: Math.floor(Math.random() * radar.width - (radar.width / 2))
                        //property int b: Math.sqrt(Math.pow(c, 2) - Math.pow(a, 2))

                        // Using angles
                        property real alpha: Math.random() * (3.14/2) + (3.14/4)
                        property real a: c * Math.cos(alpha)
                        property real b: c * Math.sin(alpha)
                        property real c: radar.height * Math.abs(((boxDevice.rssi)+12) / 100)

                        x: (radar.width / 2) - a
                        y: radar.height - b

                        width: 32
                        height: 32
                        radius: 32
                        opacity: (boxDevice.rssi < 0) ? 1 : 0.66

                        border.width: 2
                        border.color: Qt.darker(color, 1.2)

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -8
                            radius: width
                            z: -1
                            opacity: boxDevice.selected ? 0.5 : 0
                            Behavior on opacity { OpacityAnimator { duration: 133 } }
                            color: (Theme.currentTheme === Theme.THEME_SNOW) ? Theme.colorPrimary : Theme.colorHeader
                        }

                        color: {
                            if (Math.abs(boxDevice.rssi) < 65) return Theme.colorGreen
                            if (Math.abs(boxDevice.rssi) < 85) return Theme.colorOrange
                            if (Math.abs(boxDevice.rssi) < 100) return Theme.colorRed
                            return Theme.colorRed
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: boxDevice.selected = !boxDevice.selected
                        }
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
