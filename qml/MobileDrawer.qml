import QtQuick
import QtQuick.Controls

import ComponentLibrary
import AppUtils

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

                height: Math.max(Theme.screenPaddingTop, Theme.screenPaddingStatusbar)
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
                    textFormat: Text.PlainText
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

                topPadding: -Theme.componentMargin/2

                ListSeparatorPadded { }

                ////////

                DrawerItem_menu {
                    highlighted: (appContent.state === "DeviceList")
                    text: qsTr("Sensors")
                    source: "qrc:/assets/gfx/logos/watchflower_tray_dark.svg"

                    onClicked: {
                        screenDeviceList.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem_menu {
                    highlighted: (appContent.state === "ScreenSettings" || appContent.state === "ScreenSettingsAdvanced")
                    text: qsTr("Settings")
                    source: "qrc:/IconLibrary/material-icons/duotone/tune.svg"

                    onClicked: {
                        screenSettings.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem_menu {
                    highlighted: (appContent.state === "ScreenAbout" || appContent.state === "ScreenAboutPermissions")
                    text: qsTr("About")
                    source: "qrc:/IconLibrary/material-icons/duotone/info.svg"

                    onClicked: {
                        screenAbout.loadScreen()
                        appDrawer.close()
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerItem_menu {
                    source: "qrc:/IconLibrary/material-symbols/sort.svg"
                    text: {
                        var txt = qsTr("Order by:") + " "
                        if (SettingsManager.orderBy === "waterlevel") {
                            txt += qsTr("water level")
                        } else if (SettingsManager.orderBy === "plant") {
                            txt += qsTr("plant name")
                        } else if (SettingsManager.orderBy === "model") {
                            txt += qsTr("sensor model")
                        } else if (SettingsManager.orderBy === "location") {
                            txt += qsTr("location")
                        } else if (SettingsManager.orderBy === "address") {
                            txt += qsTr("device address")
                        }
                        return txt
                    }

                    readonly property int sortmodeMax: (Qt.platform.os === "osx" || Qt.platform.os === "ios") ? 3 : 4
                    property int sortmode: {
                        if (SettingsManager.orderBy === "address") {
                            return 4
                        } else if (SettingsManager.orderBy === "waterlevel") {
                            return 3
                        } else if (SettingsManager.orderBy === "plant") {
                            return 2
                        } else if (SettingsManager.orderBy === "model") {
                            return 1
                        } else { // if (SettingsManager.orderBy === "location") {
                            return 0
                        }
                    }

                    onClicked: {
                        sortmode++
                        if (sortmode > sortmodeMax) sortmode = 0

                        if (sortmode === 0) {
                            SettingsManager.orderBy = "location"
                            DeviceManager.orderby_location()
                        } else if (sortmode === 1) {
                            SettingsManager.orderBy = "model"
                            DeviceManager.orderby_model()
                        } else if (sortmode === 2) {
                            SettingsManager.orderBy = "plant"
                            DeviceManager.orderby_plant()
                        } else if (sortmode === 3) {
                            SettingsManager.orderBy = "waterlevel"
                            DeviceManager.orderby_waterlevel()
                        } else if (sortmode === 4) {
                            SettingsManager.orderBy = "address"
                            DeviceManager.orderby_address()
                        }
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerItem_button {
                    text: qsTr("Refresh sensor data")

                    source: "qrc:/IconLibrary/material-symbols/autorenew.svg"
                    iconAnimation: DeviceManager.updating ? "rotate" : "fade"
                    iconAnimated: (DeviceManager.updating || DeviceManager.listening)

                    enabled: (DeviceManager.bluetooth && !DeviceManager.scanning && DeviceManager.hasDevices)

                    onClicked: {
                        if (!DeviceManager.scanning) {
                            if (DeviceManager.updating) {
                                DeviceManager.refreshDevices_stop()
                            } else {
                                DeviceManager.refreshDevices_start()
                            }
                            appDrawer.close()
                        }
                    }
                }

                DrawerItem_button {
                    text: qsTr("Sync sensors history")

                    source: "qrc:/IconLibrary/material-symbols/merge_type.svg"
                    sourceRotation: 180
                    iconAnimation: "fade"
                    iconAnimated: DeviceManager.syncing

                    enabled: (DeviceManager.bluetooth && !DeviceManager.scanning && DeviceManager.hasDevices)

                    onClicked: {
                        if (!DeviceManager.scanning) {
                            if (DeviceManager.syncing) {
                                DeviceManager.syncDevices_stop()
                            } else {
                                DeviceManager.syncDevices_start()
                            }
                            appDrawer.close()
                        }
                    }
                }

                DrawerItem_button {
                    text: qsTr("Search for new sensors")

                    source: "qrc:/IconLibrary/material-symbols/search.svg"
                    iconAnimation: "fade"
                    iconAnimated: DeviceManager.scanning

                    enabled: DeviceManager.bluetooth

                    onClicked: {
                        if (DeviceManager.scanning) {
                            DeviceManager.scanDevices_stop()
                        } else {
                            DeviceManager.scanDevices_start()
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
            anchors.bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

            visible: (screenOrientation === Qt.PortraitOrientation)

            ////////

            DrawerItem_button {
                visible: (Qt.platform.os === "android")

                // The service is enabled, but can't start without the Bluetooth permission
                property bool needsPermission: (SettingsManager.systray &&
                                                !AndroidServiceLink.serviceOnline &&
                                                !DeviceManager.permissionBluetooth)

                highlighted: AndroidServiceLink.serviceOnline
                text: {
                    if (AndroidServiceLink.serviceOnline) return qsTr("Service active")
                    if (needsPermission) return qsTr("Service needs permission")
                    return qsTr("Service stopped")
                }
                source: AndroidServiceLink.serviceOnline ? "qrc:/IconLibrary/material-symbols/check_circle-fill.svg"
                                                        : "qrc:/IconLibrary/material-symbols/cancel_circle.svg"
                sourceColor: {
                    if (AndroidServiceLink.serviceOnline) return Theme.colorSuccess
                    if (needsPermission) return Theme.colorWarning
                    return Theme.colorSubText
                }

                onClicked: {
                    if (needsPermission) {
                        DeviceManager.requestBluetoothPermissions()
                        appDrawer.close()
                    } else if (UtilsApp.hasAndroidAutostartSettings()) {
                        UtilsApp.openAndroidAutostartSettings("com.emeric.watchflower")
                        appDrawer.close()
                    }
                }
            }

            ////////

            DrawerItem_menu {
                highlighted: (appContent.state === "PlantBrowser")
                text: qsTr("Plant browser")
                source: "qrc:/IconLibrary/material-symbols/sensors/local_florist.svg"

                onClicked: {
                    screenPlantBrowser.loadScreenFrom("DeviceList")
                    appDrawer.close()
                }
            }

            DrawerItem_menu {
                highlighted: (appContent.state === "DeviceBrowser")
                text: qsTr("Device browser")
                source: "qrc:/IconLibrary/material-symbols/sensors/radar.svg"

                enabled: DeviceManager.bluetooth

                onClicked: {
                    screenDeviceBrowser.loadScreen()
                    appDrawer.close()
                }
            }

            ////////
        }

        ////////////////
    }
}
