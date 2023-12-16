import QtQuick
import QtQuick.Layouts

import ThemeEngine

Item {
    id: itemNoDevice
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    Timer {
        id: retryScan
        interval: 333
        running: false
        repeat: false
        onTriggered: scan()
    }

    function scan() {
        if (!deviceManager.updating) {
            if (deviceManager.scanning) {
                deviceManager.scanDevices_stop()
            } else {
                deviceManager.scanDevices_start()
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -Theme.componentMarginXL

        IconSvg { // magnifying glass icon
            anchors.horizontalCenter: parent.horizontalCenter
            width: (isDesktop || isTablet || (isPhone && screenOrientation === Qt.LandscapeOrientation)) ? 320 : (parent.width*0.66)
            height: width

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcon

            SequentialAnimation on opacity {
                id: scanAnimation
                loops: Animation.Infinite
                running: deviceManager.scanning
                alwaysRunToEnd: true

                PropertyAnimation { to: 0.33; duration: 750; }
                PropertyAnimation { to: 1; duration: 750; }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginXL

            ////////

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin*2.5 + 20
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin*2.5
                spacing: Theme.componentMargin/2

                ////

                Text {
                    Layout.maximumWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter

                    visible: !deviceManager.bluetoothEnabled

                    IconSvg {
                        anchors.right: parent.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20; height: 20;
                        source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                        color: Theme.colorWarning
                    }

                    text: qsTr("Please <b>enable Bluetooth</b> on your device in order to use the application.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
                }

                ////

                Text {
                    Layout.maximumWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter

                    visible: (Qt.platform.os === "osx" || Qt.platform.os === "ios")

                    IconSvg {
                        anchors.right: parent.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20; height: 20;
                        source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                        color: Theme.colorWarning
                    }

                    text: qsTr("Authorization to use Bluetooth is <b>required</b> to connect to the sensors.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
                }

                ////

                Text {
                    Layout.maximumWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter

                    visible: (Qt.platform.os === "android")

                    IconSvg {
                        anchors.right: parent.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20; height: 20;
                        source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                        color: Theme.colorWarning
                    }

                    text: qsTr("On Android 6+, scanning for Bluetooth Low Energy devices requires <b>location permission</b>.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
                }
                Text {
                    Layout.maximumWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter

                    visible: (Qt.platform.os === "android")

                    text: qsTr("The application is neither using nor storing your location. Sorry for the inconvenience.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
                }

                ////

                Text {
                    Layout.maximumWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter

                    visible: (Qt.platform.os === "android" && !deviceManager.permissionLocationGPS)

                    IconSvg {
                        anchors.right: parent.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20; height: 20;
                        source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                        color: Theme.colorSubText
                    }

                    text: qsTr("Some Android devices also require the actual <b>GPS to be turned on</b>.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
                }

                ////

                Text {
                    Layout.maximumWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter

                    visible: settingsManager.bluetoothLimitScanningRange

                    IconSvg {
                        anchors.right: parent.left
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20; height: 20;
                        source: "qrc:/assets/icons_material/baseline-info-24px.svg"
                        color: Theme.colorSubText
                    }

                    text: qsTr("Please keep your device <b>close</b> to the sensors you want to scan.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
                }

                ////
            }

            ////////

            Grid {
                anchors.horizontalCenter: parent.horizontalCenter

                visible: isMobile
                spacing: Theme.componentMarginXL

                rows: 2
                columns: singleColumn ? 1 : 2

                Item {
                    width: singleColumn ? contentColumn.width : btn1.width
                    height: Theme.componentHeight

                    ButtonWireframeIcon {
                        id: btn1
                        anchors.horizontalCenter: parent.horizontalCenter

                        //width: (isDesktop || isTablet || (isPhone && appWindow.screenOrientation === Qt.LandscapeOrientation)) ? undefined : (parent.width*0.75)

                        text: qsTr("Official information")
                        primaryColor: Theme.colorSubText
                        sourceSize: 20
                        source: "qrc:/assets/icons_material/duotone-launch-24px.svg"

                        onClicked: {
                            if (Qt.platform.os === "android") {
                                if (utilsApp.getAndroidSdkVersion() >= 12)
                                    Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android12-or-higher")
                                else
                                    Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower")
                            } else if (Qt.platform.os === "ios") {
                                Qt.openUrlExternally("https://support.apple.com/HT210578")
                            }
                        }
                    }
                }

                Item {
                    width: singleColumn ? contentColumn.width : btn2.width
                    height: Theme.componentHeight

                    ButtonWireframe {
                        id: btn2
                        anchors.horizontalCenter: parent.horizontalCenter

                        //width: (isDesktop || isTablet || (isPhone && appWindow.screenOrientation === Qt.LandscapeOrientation)) ? undefined : (parent.width*0.75)

                        text: deviceManager.scanning ? qsTr("Scanning...") : qsTr("Launch detection")
                        fullColor: true
                        primaryColor: Theme.colorPrimary

                        onClicked: {
                            if (!deviceManager.bluetoothAdapter || !deviceManager.bluetoothEnabled) {
                                // Just to be sure...
                                deviceManager.enableBluetooth(true)
                            }

                            if (!deviceManager.bluetoothPermissions) {
                                // Ask permission
                                utilsApp.getMobileBleLocationPermission()
                            }

                            // Now we scan...
                            retryScan.start()
                        }
                    }
                }
            }

            ////////

            ButtonWireframe { // desktop only launch button
                anchors.horizontalCenter: parent.horizontalCenter
                width: 320

                visible: isDesktop
                fullColor: true
                primaryColor: Theme.colorPrimary

                text: deviceManager.scanning ? qsTr("Scanning...") : qsTr("Launch detection")

                onClicked: {
                    // Just to be sure...
                    deviceManager.enableBluetooth()

                    // Now we scan...
                    retryScan.start()
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
