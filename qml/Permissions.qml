import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: permissionsScreen
    width: 480
    height: 640
    anchors.fill: parent
    anchors.leftMargin: screenPaddingLeft
    anchors.rightMargin: screenPaddingRight

    function loadScreen() {
        // Refresh permissions
        button_gps_test.validperm = utilsApp.checkMobileLocationPermission()
        button_storage_test.validperm = utilsApp.checkMobileStoragePermissions()

        // Load screen
        appContent.state = "Permissions"
    }

    ////////////////////////////////////////////////////////////////////////////
/*
    Rectangle {
        id: rectangleHeader
        color: Theme.colorDeviceHeader
        height: 80
        z: 5

        visible: isDesktop

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        // prevent clicks below this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        Text {
            id: textTitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 12

            text: qsTr("Permissions")
            font.bold: true
            font.pixelSize: Theme.fontSizeTitle
            color: Theme.colorText
        }

        Text {
            id: textSubtitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14

            text: qsTr("Why are we using these permissions?")
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentBig
        }
    }
*/
    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            topPadding: 16
            bottomPadding: 16
            spacing: 8

            ////////

            Item {
                id: element_gps
                height: 24
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    id: text_gps
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Location")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 17
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                ItemImageButton {
                    id: button_gps_test
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    property bool validperm: false

                    source: (validperm) ? "qrc:/assets/icons_material/baseline-check-24px.svg" : "qrc:/assets/icons_material/baseline-close-24px.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorPrimary : Theme.colorSubText
                    background: true

                    onClicked: validperm = utilsApp.getMobileLocationPermission();
                }
            }
            Text {
                id: legend_gps
                anchors.left: parent.left
                anchors.leftMargin: 48
                anchors.right: parent.right
                anchors.rightMargin: 4
                topPadding: 0
                bottomPadding: 0

                text: qsTr("The Android operating system requires applications to ask for device location permission in order to scan for nearby Bluetooth LE sensors.<br>" +
                           "This permission is only needed while scanning for new sensors.<br>" +
                           "WatchFlower doesn't use, store nor communicate your location to anyone or anything.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }
            ButtonWireframe {
                height: 36
                anchors.left: parent.left
                anchors.leftMargin: 48

                text: qsTr("Official information")
                primaryColor: Theme.colorPrimary
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth-le#permissions")
            }

            ////////

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: element_storage
                height: 24
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    id: text_storage
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Storage write")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: 17
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                ItemImageButton {
                    id: button_storage_test
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    property bool validperm: false

                    source: (validperm) ? "qrc:/assets/icons_material/baseline-check-24px.svg" : "qrc:/assets/icons_material/baseline-close-24px.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorPrimary : Theme.colorSubText
                    background: true

                    onClicked: validperm = utilsApp.getMobileStoragePermissions();
                }
            }
            Text {
                id: legend_storage
                anchors.left: parent.left
                anchors.leftMargin: 48
                anchors.right: parent.right
                anchors.rightMargin: 4

                text: qsTr("Storage write permission can be needed for exporting sensors data to the SD card.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: element_bluetooth
                height: 24
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    id: text_bluetooth
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Bluetooth control")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: 17
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                ItemImageButton {
                    id: button_bluetooth_test
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    property bool validperm: true

                    source: (validperm) ? "qrc:/assets/icons_material/baseline-check-24px.svg" : "qrc:/assets/icons_material/baseline-close-24px.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorPrimary : Theme.colorSubText
                    background: true
                }
            }
            Text {
                id: legend_bluetooth
                anchors.left: parent.left
                anchors.leftMargin: 48
                anchors.right: parent.right
                anchors.rightMargin: 4

                text: qsTr("WatchFlower can activate your device's Bluetooth in order to operate.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////
        }
    }
}
