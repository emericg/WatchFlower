import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Drawer {
    width: parent.width*0.8
    height: parent.height

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground

        Rectangle {
            x: parent.width - 1
            width: 1
            height: parent.height
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {

        Column {
            id: rectangleHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            z: 5

            Connections {
                target: appWindow
                onScreenPaddingStatusbarChanged: rectangleHeader.updateIOSHeader()
            }
            Connections {
                target: ThemeEngine
                onCurrentThemeChanged: rectangleHeader.updateIOSHeader()
            }

            function updateIOSHeader() {
                if (Qt.platform.os === "ios") {
                    if (screenPaddingStatusbar !== 0 && Theme.currentTheme === ThemeEngine.THEME_NIGHT)
                        rectangleStatusbar.height = screenPaddingStatusbar
                    else
                        rectangleStatusbar.height = 0
                }
            }

            ////////

            Rectangle {
                id: rectangleStatusbar
                height: screenPaddingStatusbar
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorBackground // "red" // to hide scrollview content
            }
            Rectangle {
                id: rectangleNotch
                height: screenPaddingNotch
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorBackground // "yellow" // to hide scrollview content
            }
            Rectangle {
                id: rectangleLogo
                height: 80
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.colorBackground

                Image {
                    id: imageHeader
                    width: 40
                    height: 40
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/logos/logo.svg"
                    sourceSize: Qt.size(width, height)
                }
                Text {
                    id: textHeader
                    anchors.left: imageHeader.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 2

                    text: "WatchFlower"
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: 22
                }
            }
        }
        MouseArea { anchors.fill: rectangleHeader; acceptedButtons: Qt.AllButtons; }

        ////////////////////////////////////////////////////////////////////////////

        ScrollView {
            id: scrollView
            contentWidth: -1

            anchors.top: rectangleHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Column {
                anchors.fill: parent

                ////////

                Rectangle {
                    id: rectangleHome
                    height: 48
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: (appContent.state === "DeviceList") ? Theme.colorForeground : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appContent.state = "DeviceList"
                            appDrawer.close()
                        }
                    }

                    ImageSvg {
                        id: buttonPlantsImg
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 16
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/logos/watchflower_tray_dark.svg"
                        color: Theme.colorText
                    }
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 56
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Sensors")
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.colorText
                    }
                }

                ////////

                Rectangle {
                    id: rectangleSettings
                    height: 48
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: (appContent.state === "Settings") ? Theme.colorForeground : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appContent.state = "Settings"
                            appDrawer.close()
                        }
                    }

                    ImageSvg {
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 16
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/outline-settings-24px.svg"
                        color: Theme.colorText
                    }
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 56
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Settings")
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.colorText
                    }
                }

                Rectangle {
                    id: rectangleAbout
                    height: 48
                    anchors.right: parent.right
                    anchors.left: parent.left
                    color: (appContent.state === "About") ? Theme.colorForeground : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appContent.state = "About"
                            appDrawer.close()
                        }
                    }

                    ImageSvg {
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 16
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/outline-info-24px.svg"
                        color: Theme.colorText
                    }
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 56
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("About")
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.colorText
                    }
                }

                ////////

                Item { // spacer
                    height: 8
                    anchors.right: parent.right
                    anchors.left: parent.left
                }
                Rectangle {
                    height: 1
                    anchors.right: parent.right
                    anchors.left: parent.left
                    color: Theme.colorSeparator
                }
                Item {
                    height: 8
                    anchors.right: parent.right
                    anchors.left: parent.left
                }

                ////////

                Item {
                    id: rectangleOrderBy
                    height: 48
                    anchors.right: parent.right
                    anchors.left: parent.left

                    MouseArea {
                        anchors.fill: parent

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

                    ImageSvg {
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 16
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/baseline-sort-24px.svg"
                        color: Theme.colorText
                    }
                    Label {
                        id: textOrderBy
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 56
                        anchors.verticalCenter: parent.verticalCenter

                        function setText() {
                            var txt = qsTr("Order by:") + " "
                            if (settingsManager.orderBy === "waterlevel") {
                                txt += qsTr("water level")
                            } else if (settingsManager.orderBy === "plant") {
                                txt += qsTr("plant name")
                            } else if (settingsManager.orderBy === "model") {
                                txt += qsTr("device model")
                            } else if (settingsManager.orderBy === "location") {
                                txt += qsTr("location")
                            }
                            textOrderBy.text = txt
                        }

                        Component.onCompleted: textOrderBy.setText()
                        Connections {
                            target: settingsManager
                            onOrderByChanged: textOrderBy.setText()
                            onAppLanguageChanged: textOrderBy.setText()
                        }

                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.colorText
                    }
                }

                ////////

                Item { // spacer
                    height: 8
                    anchors.right: parent.right
                    anchors.left: parent.left
                }
                Rectangle {
                    height: 1
                    anchors.right: parent.right
                    anchors.left: parent.left
                    color: Theme.colorSeparator
                }
                Item {
                    height: 8
                    anchors.right: parent.right
                    anchors.left: parent.left
                }

                ////////

                Item {
                    id: rectangleRefresh
                    height: 48
                    anchors.left: parent.left
                    anchors.right: parent.right

                    enabled: deviceManager.bluetooth && !deviceManager.scanning

                    MouseArea {
                        anchors.fill: parent
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

                    ImageSvg {
                        id: buttonRefresh
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 16
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                        color: rectangleRefresh.enabled ? Theme.colorText : Theme.colorSubText

                        NumberAnimation on rotation {
                            id: refreshAnimation
                            duration: 2000
                            from: 0
                            to: 360
                            loops: Animation.Infinite
                            running: deviceManager.updating
                            alwaysRunToEnd: true
                            easing.type: Easing.Linear
                        }
                    }
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 56
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Refresh sensors data")
                        font.pixelSize: 13
                        font.bold: true
                        color: rectangleRefresh.enabled ? Theme.colorText : Theme.colorSubText
                    }
                }

                ////////

                Item {
                    id: rectangleSync
                    height: 48
                    anchors.left: parent.left
                    anchors.right: parent.right

                    enabled: deviceManager.bluetooth && !deviceManager.scanning

                    MouseArea {
                        anchors.fill: parent
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

                    ImageSvg {
                        id: buttonSync
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 16
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/duotone-autorenew-24px.svg"
                        color: rectangleSync.enabled ? Theme.colorText : Theme.colorSubText

                        NumberAnimation on rotation {
                            id: syncAnimation
                            duration: 2000
                            from: 0
                            to: 360
                            loops: Animation.Infinite
                            running: deviceManager.syncing
                            alwaysRunToEnd: true
                            easing.type: Easing.Linear
                        }
                    }
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 56
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Sync sensors history")
                        font.pixelSize: 13
                        font.bold: true
                        color: rectangleSync.enabled ? Theme.colorText : Theme.colorSubText
                    }
                }

                ////////

                Item {
                    id: rectangleRescan
                    height: 48
                    anchors.left: parent.left
                    anchors.right: parent.right

                    enabled: deviceManager.bluetooth && !deviceManager.updating

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!deviceManager.updating) {
                                if (deviceManager.scanning) {
                                    deviceManager.scanDevices_stop()
                                } else {
                                    deviceManager.scanDevices_start()
                                }
                            }
                        }
                    }

                    ImageSvg {
                        id: buttonRescan
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 16
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                        color: rectangleRescan.enabled ? Theme.colorText : Theme.colorSubText

                        SequentialAnimation on opacity {
                            id: rescanAnimation
                            loops: Animation.Infinite
                            running: deviceManager.scanning
                            onStopped: buttonRescan.opacity = 1;

                            PropertyAnimation { to: 0.33; duration: 750; }
                            PropertyAnimation { to: 1; duration: 750; }
                        }
                    }
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + 56
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Search for new devices")
                        font.pixelSize: 13
                        font.bold: true
                        color: rectangleRescan.enabled ? Theme.colorText : Theme.colorSubText
                    }
                }

                ////////
            }
        }
    }
}
