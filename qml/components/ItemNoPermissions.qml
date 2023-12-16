import QtQuick
import QtQuick.Layouts

import ThemeEngine

Item {
    id: itemNoPermissions
    anchors.fill: parent

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMarginXL
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginXL
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -Theme.componentMarginXL
        spacing: Theme.componentMargin

        ////

        Column {
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter

                width: singleColumn ? (itemNoPermissions.width*0.5) : (itemNoPermissions.height*0.4)
                height: width
                radius: width
                color: Theme.colorForeground

                IconSvg { // lock icon
                    anchors.centerIn: parent
                    width: parent.width*0.8
                    height: width

                    source: "qrc:/assets/icons_material/outline-lock-24px.svg"
                    fillMode: Image.PreserveAspectFit
                    color: Theme.colorSubText
                    opacity: 0.9
                    smooth: true
                }
            }

            Item { width: Theme.componentMarginXL; height: Theme.componentMarginXL; }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Bluetooth permission(s) missing…")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentBig
                color: Theme.colorText
            }

            Item { width: 8; height: 8; }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.componentMargin

                ButtonWireframeIcon {
                    //width: ((isDesktop || isTablet) && !singleColumn) ? 256 : undefined

                    text: qsTr("Request permission(s)")
                    primaryColor: Theme.colorPrimary
                    fullColor: true
                    sourceSize: 24
                    source: "qrc:/assets/icons_material/duotone-touch_app-24px.svg"

                    onClicked: {
                        deviceManager.requestBluetoothPermissions()
                    }
                }
            }

            Item { width: 8; height: 8; }
        }

        ////

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: singleColumn ? (itemNoPermissions.width*0.85) : undefined
            spacing: Theme.componentMargin

            visible: (Qt.platform.os === "android" || Qt.platform.os === "ios" || Qt.platform.os === "osx")

            IconSvg {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter

                source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                color: Theme.colorWarning
            }
            Text {
                Layout.fillWidth: singleColumn
                Layout.alignment: Qt.AlignVCenter

                text: qsTr("Authorization to use Bluetooth is <b>required</b> to connect to the sensors.")
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
            }
        }

        ////

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: singleColumn ? (itemNoPermissions.width*0.85) : undefined
            spacing: Theme.componentMargin

            visible: (Qt.platform.os === "android")

            IconSvg {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter

                source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                color: Theme.colorWarning
            }
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                text: qsTr("On Android 6+, scanning for Bluetooth Low Energy devices requires <b>location permission</b>.")
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
            }
        }

        ////

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: singleColumn ? (itemNoPermissions.width*0.85) : undefined
            spacing: Theme.componentMargin

            visible: (Qt.platform.os === "android" && !deviceManager.permissionLocationGPS)

            IconSvg {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter

                source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                color: Theme.colorSubText
            }

            Text {
                Layout.fillWidth: singleColumn
                Layout.alignment: Qt.AlignVCenter

                text: qsTr("Some Android devices also require the actual <b>GPS to be turned on</b>.")
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
            }
        }

        ////

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: singleColumn ? (itemNoPermissions.width*0.85) : undefined
            spacing: Theme.componentMargin

            visible: (Qt.platform.os === "android")

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

                text: qsTr("The application is neither using nor storing your location. Sorry for the inconvenience.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                horizontalAlignment: singleColumn ? Text.AlignJustify : Text.AlignHCenter
            }
        }

        ////

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.componentMargin

            ButtonWireframeIcon {
                //width: ((isDesktop || isTablet) && !singleColumn) ? 256 : undefined

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

        ////
    }
}
