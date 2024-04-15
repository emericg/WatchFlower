import QtQuick
import QtQuick.Controls

import ThemeEngine

DrawerThemed {
    contentItem: Item {

        ////////////////

        Column {
            id: headerColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            z: 5

            ////////

            Rectangle { // statusbar area
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: -1

                height: Math.max(screenPaddingTop, screenPaddingStatusbar)
                color: Theme.colorStatusbar // to be able to read statusbar content
            }

            ////////

            Rectangle { // logo area
                anchors.left: parent.left
                anchors.right: parent.right

                height: 80
                color: Theme.colorBackground

                Image {
                    id: imageHeader
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    width: 40
                    height: 40
                    source: "qrc:/assets/gfx/logos/logo.svg"
                }
                Text {
                    id: textHeader
                    anchors.left: imageHeader.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 2

                    text: "WatchFlower"
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeTitle
                }
            }

            ////////
        }

        ////////////////

        Flickable {
            anchors.top: headerColumn.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            contentWidth: -1
            contentHeight: contentColumn.height

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerItem {
                    highlighted: (appContent.state === "DeviceList")
                    text: qsTr("Sensors")
                    source: "qrc:/assets/gfx/logos/watchflower_tray_dark.svg"

                    onClicked: {
                        screenDeviceList.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem {
                    highlighted: (appContent.state === "Settings" || appContent.state === "SettingsAdvanced")
                    text: qsTr("Settings")
                    source: "qrc:/assets/icons/material-symbols/settings.svg"

                    onClicked: {
                        screenSettings.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem {
                    highlighted: (appContent.state === "About" || appContent.state === "AboutPermissions")
                    text: qsTr("About")
                    source: "qrc:/assets/icons/material-symbols/info-fill.svg"

                    onClicked: {
                        screenAbout.loadScreen()
                        appDrawer.close()
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerItem {
                    source: "qrc:/assets/icons/material-symbols/sort.svg"
                    text: {
                        var txt = qsTr("Order by:") + " "
                        if (settingsManager.orderBy === "waterlevel") {
                            txt += qsTr("water level")
                        } else if (settingsManager.orderBy === "plant") {
                            txt += qsTr("plant name")
                        } else if (settingsManager.orderBy === "model") {
                            txt += qsTr("sensor model")
                        } else if (settingsManager.orderBy === "location") {
                            txt += qsTr("location")
                        }
                        return txt
                    }

                    property var sortmode: {
                        if (settingsManager.orderBy === "waterlevel") {
                            return 3
                        } else if (settingsManager.orderBy === "plant") {
                            return 2
                        } else if (settingsManager.orderBy === "model") {
                            return 1
                        } else { // if (settingsManager.orderBy === "location") {
                            return 0
                        }
                    }

                    onClicked: {
                        sortmode++
                        if (sortmode > 3) sortmode = 0

                        if (sortmode === 0) {
                            settingsManager.orderBy = "location"
                            deviceManager.orderby_location()
                        } else if (sortmode === 1) {
                            settingsManager.orderBy = "model"
                            deviceManager.orderby_model()
                        } else if (sortmode === 2) {
                            settingsManager.orderBy = "plant"
                            deviceManager.orderby_plant()
                        } else if (sortmode === 3) {
                            settingsManager.orderBy = "waterlevel"
                            deviceManager.orderby_waterlevel()
                        }
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerButton {
                    text: qsTr("Refresh sensor data")

                    source: "qrc:/assets/icons/material-symbols/autorenew.svg"
                    iconAnimation: deviceManager.updating ? "rotate" : "fade"
                    iconAnimated: (deviceManager.updating || deviceManager.listening)

                    enabled: (deviceManager.bluetooth && !deviceManager.scanning && deviceManager.hasDevices)

                    onClicked: {
                        if (!deviceManager.scanning) {
                            if (deviceManager.updating) {
                                deviceManager.refreshDevices_stop()
                            } else {
                                deviceManager.refreshDevices_start()
                            }
                            appDrawer.close()
                        }
                    }
                }

                DrawerButton {
                    text: qsTr("Sync sensors history")

                    source: "qrc:/assets/gfx/icons/duotone-date_all-24px.svg"
                    iconAnimation: "fade"
                    iconAnimated: deviceManager.syncing

                    enabled: (deviceManager.bluetooth && !deviceManager.scanning && deviceManager.hasDevices)

                    onClicked: {
                        if (!deviceManager.scanning) {
                            if (deviceManager.syncing) {
                                deviceManager.syncDevices_stop()
                            } else {
                                deviceManager.syncDevices_start()
                            }
                            appDrawer.close()
                        }
                    }
                }

                DrawerButton {
                    text: qsTr("Search for new sensors")

                    source: "qrc:/assets/icons/material-symbols/search.svg"
                    iconAnimation: "fade"
                    iconAnimated: deviceManager.scanning

                    enabled: deviceManager.bluetooth

                    onClicked: {
                        if (deviceManager.scanning) {
                            deviceManager.scanDevices_stop()
                        } else {
                            deviceManager.scanDevices_start()
                        }
                        appDrawer.close()
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////
            }
        }

        ////////////////

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: screenPaddingNavbar + screenPaddingBottom

            DrawerItem {
                highlighted: (appContent.state === "PlantBrowser")
                text: qsTr("Plant browser")
                source: "qrc:/assets/icons/material-symbols/sensors/local_florist.svg"

                onClicked: {
                    screenPlantBrowser.loadScreenFrom("DeviceList")
                    appDrawer.close()
                }
            }

            DrawerItem {
                highlighted: (appContent.state === "DeviceBrowser")
                text: qsTr("Device browser")
                source: "qrc:/assets/icons/material-symbols/sensors/radar.svg"

                enabled: deviceManager.bluetooth

                onClicked: {
                    screenDeviceBrowser.loadScreen()
                    appDrawer.close()
                }
            }
        }

        ////////////////
    }
}
