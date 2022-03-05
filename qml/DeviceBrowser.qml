import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Item {
    id: deviceBrowser
    implicitWidth: 480
    implicitHeight: 800

    ////////////////////////////////////////////////////////////////////////////

    function open() {
        deviceManager.scanNearby_start()
        appContent.state = "DeviceBrowser"
    }

    function backAction() {
        deviceManager.scanNearby_stop()
        deviceManager.listenDevices()
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

        Item {
            id: itemDeviceBrowser
            anchors.fill: parent

            PopupBlacklistDevice {
                id: confirmBlacklistDevice
            }

            ListView {
                id: devicesView
                anchors.fill: parent

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
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentDeviceBrowser_desktop

        Item {
            id: itemDeviceBrowser
            anchors.fill: parent

            PopupBlacklistDevice {
                id: confirmBlacklistDevice
            }

            ListView {
                id: devicesView
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: (parent.width / 2)

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

            ////////////////

            Rectangle {
                id: radar
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: (parent.width / 2)

                clip: true
                color: Theme.colorForeground

                Rectangle {
                    anchors.centerIn: cc
                    width: (parent.width * 1.5)
                    height: width
                    radius: width
                    color: Theme.colorForeground
                    opacity: 0.5
                    border.width: 2
                    border.color: Theme.colorLowContrast
                }
                Rectangle {
                    anchors.centerIn: cc
                    width: parent.width
                    height: width
                    radius: width
                    color: Theme.colorForeground
                    opacity: 0.66
                    border.width: 2
                    border.color: Theme.colorLowContrast
                }
                Rectangle {
                    anchors.centerIn: cc
                    width: (parent.width / 1.5)
                    height: width
                    radius: width
                    color: Theme.colorForeground
                    opacity: 0.8
                    border.width: 2
                    border.color: Theme.colorLowContrast
                }
                Rectangle {
                    anchors.centerIn: cc
                    width: (parent.width / 3)
                    height: width
                    radius: width
                    color: Theme.colorForeground
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
                        NumberAnimation { target: ra; property: "width"; from: 0; to: radar.height*2; duration: 2500; }
                        NumberAnimation { target: ra; property: "opacity"; from: 0.8; to: 0.2; duration: 2500; }
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
                        source: "qrc:/assets/icons_material/duotone-devices-24px.svg"
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

                        // Using angle
                        property real alpha: Math.random() * (3.14/2) + (3.14/4)
                        property real a: c * Math.cos(alpha)
                        property real b: c * Math.sin(alpha)
                        property real c: radar.height * Math.abs(((boxDevice.deviceRssi)+10) / 100)

                        x: (radar.width / 2) - a
                        y: radar.height - b

                        width: 32
                        height: 32
                        radius: 32
                        opacity: (boxDevice.deviceRssi < 0) ? 1 : 0.66

                        border.width: boxDevice.selected ? 6 : 2
                        border.color: boxDevice.selected ? Theme.colorPrimary : Qt.darker(color, 1.2)

                        color: {
                            if (boxDevice.deviceRssi < 0) {
                                if (boxDevice.deviceRssi > -65) return Theme.colorGreen
                                if (boxDevice.deviceRssi > -85) return Theme.colorOrange
                                if (boxDevice.deviceRssi > -100) return Theme.colorRed
                            } else {
                                if (boxDevice.deviceRssi < 65) return Theme.colorGreen
                                if (boxDevice.deviceRssi < 85) return Theme.colorOrange
                                if (boxDevice.deviceRssi < 100) return Theme.colorRed
                            }
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
