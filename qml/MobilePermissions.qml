import QtQuick

import ComponentLibrary
import MobileUI
import AppUtils

Item {
    id: screenAboutPermissions
    anchors.fill: parent

    property string entryPoint: "ScreenAbout"

    readonly property bool isIOS: (Qt.platform.os === "ios")
    readonly property bool isAndroid: (Qt.platform.os === "android")

    //! Android 10 and lower (SDK <= 29): VIBRATE
    readonly property bool androidLegacyVibrate: (isAndroid && UtilsApp.getAndroidSdkVersion() <= 29)

    //! Android 11 and lower (SDK <= 30): BLUETOOTH / BLUETOOTH_ADMIN + location based BLE scanning
    readonly property bool androidLegacyBluetooth: (isAndroid && UtilsApp.getAndroidSdkVersion() <= 30)

    //! Android 12 and higher (SDK >= 31): BLUETOOTH_SCAN / BLUETOOTH_CONNECT ("Nearby devices")
    readonly property bool androidModernBluetooth: (isAndroid && UtilsApp.getAndroidSdkVersion() >= 31)

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // refresh permissions
        refreshPermissions()

        // change screen
        appContent.state = "ScreenAboutPermissions"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        loadScreen()
    }

    function backAction() {
        screenAbout.loadScreen()
    }

    function refreshPermissions() {
        DeviceManager.checkBluetoothPermissions()
        element_notifications.status = UtilsOS.checkMobileNotificationPermission()
    }

    Timer {
        id: retryPermissions
        interval: 333
        repeat: false
        onTriggered: screenAboutPermissions.refreshPermissions()
    }

    ////////////////////////////////////////////////////////////////////////////

    Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: contentColumn.height

        Column {
            id: contentColumn

            anchors.left: parent.left
            anchors.right: parent.right

            topPadding: Theme.componentMarginXXL
            bottomPadding: Theme.componentMarginXXL
            spacing: Theme.componentMarginL
/*
            ListSeparator { } //////////////////////////////////////////////////

            ListItemPermission { // element_network
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Network access")
                legend: qsTr("Network state and Internet permissions are used to connect to SQL databases or MQTT brokers.")
                status: true
            }
*/
            ListSeparator { } //////////////////////////////////////////////////

            ListItemPermission {
                id: element_bluetooth_control
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Bluetooth control")
                legend: qsTr("WatchFlower can activate your device's Bluetooth in order to operate.")
                status: true
            }

            ListSeparator { visible: element_bluetooth_legacy.visible } ////////

            ListItemPermission {
                id: element_bluetooth_legacy
                anchors.left: parent.left
                anchors.right: parent.right

                visible: (screenAboutPermissions.androidLegacyBluetooth || screenAboutPermissions.isIOS)

                text: qsTr("Bluetooth (legacy)")
                legend: qsTr("The Android operating system requires permission to scan for nearby Bluetooth Low Energy sensors.")
                status: DeviceManager.permissionBluetooth

                onClicked: {
                    MobileUI.hapticFeedback()
                    DeviceManager.requestBluetoothPermission()
                    retryPermissions.start()
                }
            }

            ListSeparator { visible: element_bluetooth_nearby.visible } ////////

            ListItemPermission {
                id: element_bluetooth_nearby
                anchors.left: parent.left
                anchors.right: parent.right

                visible: screenAboutPermissions.androidModernBluetooth

                text: qsTr("Bluetooth (nearby devices)")
                legend: qsTr("Since Android 12, the \"Nearby devices\" permission is required to scan for and connect to nearby Bluetooth Low Energy sensors.") + "\n" +
                        qsTr("This permission is not used to derive your location.")
                status: DeviceManager.permissionBluetooth

                onClicked: {
                    MobileUI.hapticFeedback()
                    DeviceManager.requestBluetoothPermission()
                    retryPermissions.start()
                }
            }

            ButtonWireframe {
                anchors.left: parent.left
                anchors.leftMargin: element_bluetooth_nearby.headerPosition
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginL

                visible: element_bluetooth_nearby.visible

                layoutAlignment: Qt.AlignLeft
                colorBackground: Theme.colorForeground

                text: qsTr("Official information")
                source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android12-or-higher")
            }

            ListSeparator { visible: element_location.visible } ////////////////

            ListItemPermission {
                id: element_location
                anchors.left: parent.left
                anchors.right: parent.right

                visible: screenAboutPermissions.androidLegacyBluetooth

                text: qsTr("Location")
                legend: qsTr("The Android operating system requires applications to ask for device location permission in order to scan for nearby Bluetooth Low Energy sensors.") + "\n" +
                        qsTr("WatchFlower doesn't use, store nor communicate your location to anyone or anything.")
                status: DeviceManager.permissionLocationForeground

                onClicked: {
                    MobileUI.hapticFeedback()
                    UtilsOS.getMobileBleLocationPermission()
                    retryPermissions.start()
                }
            }

            ButtonWireframe {
                anchors.left: parent.left
                anchors.leftMargin: element_location.headerPosition
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginL

                visible: element_location.visible

                layoutAlignment: Qt.AlignLeft
                colorBackground: Theme.colorForeground

                text: qsTr("Official information")
                source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower")
            }

            ListSeparator { visible: element_location_background.visible } /////

            ListItemPermission {
                id: element_location_background
                anchors.left: parent.left
                anchors.right: parent.right

                visible: (UtilsApp.getAndroidSdkVersion() >= 29 && UtilsApp.getAndroidSdkVersion() <= 30)

                text: qsTr("Background location")
                legend: qsTr("Similarly, background location permission is needed if you want to automatically get data from the sensors, while the application is not explicitly opened.")
                status: DeviceManager.permissionLocationBackground

                onClicked: {
                    MobileUI.hapticFeedback()
                    DeviceManager.requestLocationPermission_background()
                    retryPermissions.start()
                }
            }

            ListSeparator { visible: element_gps.visible } /////////////////////

            ListItemPermission {
                id: element_gps
                anchors.left: parent.left
                anchors.right: parent.right

                visible: screenAboutPermissions.androidLegacyBluetooth

                text: qsTr("GPS")
                legend: qsTr("Some Android devices also require the GPS to be turned on for Bluetooth operations.")
                status: DeviceManager.gpsEnabled

                onClicked: {
                    MobileUI.hapticFeedback()
                    retryPermissions.start()
                }
            }

            ButtonWireframe {
                anchors.left: parent.left
                anchors.leftMargin: element_gps.headerPosition
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginL

                visible: element_gps.visible

                layoutAlignment: Qt.AlignLeft
                colorBackground: Theme.colorForeground

                text: qsTr("Location settings")
                source: "qrc:/IconLibrary/material-icons/duotone/tune.svg"
                onClicked: UtilsApp.openAndroidLocationSettings()
            }

            ListSeparator { visible: element_notifications.visible } ///////////

            ListItemPermission {
                id: element_notifications
                anchors.left: parent.left
                anchors.right: parent.right

                visible: UtilsApp.getAndroidSdkVersion() >= 33

                text: qsTr("Notifications")
                legend: qsTr("The Android operating system requires permission to send notifications.")
                status: false

                onClicked: {
                    MobileUI.hapticFeedback()
                    status = UtilsOS.getMobileNotificationPermission()
                    retryPermissions.start()
                }
            }

            ListSeparator { visible: element_vibrate.visible } /////////////////

            ListItemPermission {
                id: element_vibrate
                anchors.left: parent.left
                anchors.right: parent.right

                visible: androidLegacyVibrate

                text: qsTr("Notifications")
                legend: qsTr("The Android operating system requires permission to trigger vibrations.")
                status: true
            }

            ListSeparator { } //////////////////////////////////////////////////

            ListItemPermissionInfo { // element_infos
                anchors.left: parent.left
                anchors.right: parent.right

                applicationID: "com.emeric.watchflower"
            }

            ////////////////////////////////////////////////////////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
