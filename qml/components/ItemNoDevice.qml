import QtQuick
import QtQuick.Layouts

import ThemeEngine

Item {
    id: itemNoDevice
    anchors.fill: parent

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
            spacing: Theme.componentMarginXL + 8

            ////

            ButtonWireframe {
                anchors.horizontalCenter: parent.horizontalCenter

                width: (isDesktop || isTablet || (isPhone && screenOrientation === Qt.LandscapeOrientation)) ? 320 : (parent.width*0.5)

                text: deviceManager.scanning ? qsTr("Scanning...") : qsTr("Launch detection")
                fullColor: true
                primaryColor: Theme.colorPrimary

                onClicked: {
                    // Just to be sure...
                    if (!deviceManager.bluetoothPermissions) {
                        // Ask permission
                        utilsApp.getMobileBleLocationPermission()
                    }
                    if (!deviceManager.bluetoothAdapter || !deviceManager.bluetoothEnabled) {
                        // Enable
                        deviceManager.enableBluetooth(true)
                    }

                    // Now we scan...
                    tryScan.start()
                }

                Timer {
                    id: tryScan
                    interval: 333
                    running: false
                    repeat: false
                    onTriggered: {
                        if (!deviceManager.updating) {
                            if (deviceManager.scanning) {
                                deviceManager.scanDevices_stop()
                            } else {
                                deviceManager.scanDevices_start()
                            }
                        }
                    }
                }
            }

            ////

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                width: singleColumn ? (itemNoDevice.width*0.85) : undefined
                spacing: Theme.componentMargin

                //visible: !deviceManager.bluetoothEnabled

                IconSvg {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    Layout.alignment: Qt.AlignVCenter

                    source: "qrc:/assets/icons_material/baseline-info-24px.svg"
                    color: Theme.colorSubText
                }
                Text {
                    Layout.fillWidth: singleColumn
                    Layout.alignment: Qt.AlignVCenter

                    text: qsTr("Please keep your device <b>close</b> to the sensors you want to scan.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
                }
            }

            ////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
