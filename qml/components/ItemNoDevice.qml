import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    anchors.fill: parent

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -20

        ImageSvg {
            id: imageSearch
            width: (isDesktop || isTablet || (isPhone && appWindow.screenOrientation === Qt.LandscapeOrientation)) ? 256 : (parent.width*0.666)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcon

            SequentialAnimation on opacity {
                id: rescanAnimation
                loops: Animation.Infinite
                running: deviceManager.scanning
                alwaysRunToEnd: true

                PropertyAnimation { to: 0.33; duration: 750; }
                PropertyAnimation { to: 1; duration: 750; }
            }
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right

            visible: (Qt.platform.os === "android")

            text: qsTr("On Android 6+, scanning for Bluetooth Low Energy devices requires location permission. The application is neither using nor storing your location. Sorry for the inconvenience.")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentSmall
            color: Theme.colorSubText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right

            visible: (Qt.platform.os === "ios")

            text: qsTr("Authorization to use Bluetooth is required to connect to the sensors.")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentSmall
            color: Theme.colorSubText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Item { // spacer
            width: 1; height: 16;
            anchors.horizontalCenter: parent.horizontalCenter;
            visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")
        }

        Row {
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            ButtonWireframe {
                visible: (Qt.platform.os === "android")

                text: qsTr("Official information")
                primaryColor: Theme.colorSubText
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower")
            }

            ButtonWireframe {
                text: qsTr("Launch detection")
                fullColor: true
                primaryColor: Theme.colorPrimary
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
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            height: contentHeight + 16

            visible: settingsManager.bluetoothLimitScanningRange

            text: qsTr("Please keep your device close to the sensors you want to scan.")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentSmall
            color: Theme.colorSubText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
        }
    }
}
