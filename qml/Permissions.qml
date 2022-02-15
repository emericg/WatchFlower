import QtQuick 2.15
import QtQuick.Controls 2.15

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
        button_location_test.validperm = utilsApp.checkMobileBleLocationPermission()
        button_gps_test.validperm = utilsApp.isMobileGpsEnabled()

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
        anchors.fill: parent
        contentWidth: -1

        Column {
            anchors.fill: parent

            topPadding: 16
            bottomPadding: 16
            spacing: 8

            ////////

            Item {
                id: element_location
                height: 24
                anchors.left: parent.left
                anchors.right: parent.right

                ItemImageButton {
                    id: button_location_test
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    property bool validperm: false

                    source: (validperm) ? "qrc:/assets/icons_material/baseline-check-24px.svg" : "qrc:/assets/icons_material/baseline-close-24px.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorPrimary : Theme.colorSubText
                    background: true

                    onClicked: validperm = utilsApp.getMobileBleLocationPermission()
                }

                Text {
                    id: text_location
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Location")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: 17
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Text {
                id: legend_location
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                anchors.rightMargin: 12

                text: qsTr("The Android operating system requires applications to ask for device location permission in order to scan for nearby Bluetooth Low Energy sensors.") + "<br>" +
                      qsTr("This permission is only needed while scanning for new sensors.") + "<br>" +
                      qsTr("WatchFlower doesn't use, store nor communicate your location to anyone or anything.")
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }
            ButtonWireframeImage {
                height: 36
                anchors.left: parent.left
                anchors.leftMargin: 64

                imgSize: 20
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground
                source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                text: qsTr("Official information")
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower")
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
                    anchors.leftMargin: -screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -screenPaddingRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ////////

            Item {
                id: element_gps
                height: 24
                anchors.left: parent.left
                anchors.right: parent.right

                ItemImageButton {
                    id: button_gps_test
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    property bool validperm: false

                    source: (validperm) ? "qrc:/assets/icons_material/baseline-check-24px.svg" : "qrc:/assets/icons_material/baseline-close-24px.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorPrimary : Theme.colorSubText
                    background: true

                    onClicked: validperm = utilsApp.isMobileGpsEnabled()
                }

                Text {
                    id: text_gps
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("GPS")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: 17
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Text {
                id: legend_gps
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                anchors.rightMargin: 12

                text: qsTr("Some Android devices also require the GPS to be turned on.") + "<br>" +
                      qsTr("This permission is only needed while scanning for new sensors.")
                textFormat: Text.StyledText
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
                    anchors.leftMargin: -screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -screenPaddingRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ////////

            Item {
                id: element_bluetooth
                height: 24
                anchors.left: parent.left
                anchors.right: parent.right

                ItemImageButton {
                    id: button_bluetooth_test
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    property bool validperm: true

                    source: (validperm) ? "qrc:/assets/icons_material/baseline-check-24px.svg" : "qrc:/assets/icons_material/baseline-close-24px.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorPrimary : Theme.colorSubText
                    background: true
                }

                Text {
                    id: text_bluetooth
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 64
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
            }
            Text {
                id: legend_bluetooth
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                anchors.rightMargin: 12

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
