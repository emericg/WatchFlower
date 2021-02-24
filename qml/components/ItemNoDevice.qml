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
            width: (isDesktop || isTablet || (isPhone && screenOrientation === Qt.LandscapeOrientation)) ? 256 : (parent.width*0.666)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcon

            SequentialAnimation on opacity {
                id: rescanAnimation
                loops: Animation.Infinite
                running: deviceManager.scanning
                onStopped: imageSearch.opacity = 1

                PropertyAnimation { to: 0.33; duration: 750; }
                PropertyAnimation { to: 1; duration: 750; }
            }
        }

        Text {
            anchors.right: parent.right
            anchors.left: parent.left

            visible: (Qt.platform.os === "android")

            text: qsTr("On Android 6+, scanning for Bluetooth Low Energy devices needs location permission. The application is neither using nor storing your location. Sorry for the inconveniance.")
            font.pixelSize: 14
            color: Theme.colorSubText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Item { width: 1; height: 16; anchors.horizontalCenter: parent.horizontalCenter; } // spacer

        Row {
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            ButtonWireframe {
                visible: (Qt.platform.os === "android")

                text: qsTr("Official information")
                primaryColor: Theme.colorSubText
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth-le#permissions")
            }

            ButtonWireframe {
                text: qsTr("Launch detection")
                fullColor: true
                primaryColor: Theme.colorPrimary
                onClicked: deviceManager.scanDevices()
            }
        }
    }
}
