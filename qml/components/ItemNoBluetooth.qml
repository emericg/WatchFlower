import QtQuick
import QtQuick.Layouts

import ThemeEngine

Item {
    id: itemNoBluetooth
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

                width: singleColumn ? (itemNoBluetooth.width*0.5) : (itemNoBluetooth.height*0.4)
                height: width
                radius: width
                color: Theme.colorForeground

                IconSvg { // bluetooth disabled icon
                    anchors.centerIn: parent
                    width: parent.width*0.8
                    height: width

                    source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                    fillMode: Image.PreserveAspectFit
                    color: Theme.colorSubText
                    opacity: 0.9
                    smooth: true
                }
            }

            Item { width: Theme.componentMarginXL; height: Theme.componentMarginXL; }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: {
                    if (deviceManager.bluetoothAdapter && !deviceManager.bluetoothEnabled) {
                        return qsTr("Bluetooth is disabled...")
                    }
                    return qsTr("Bluetooth adapter not found...")
                }
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentBig
                color: Theme.colorText
            }

            Item { width: 8; height: 8; }

            ButtonWireframe {
                anchors.horizontalCenter: parent.horizontalCenter

                fullColor: true
                text: {
                    if (deviceManager.bluetoothAdapter &&!deviceManager.bluetoothEnabled) {
                        if (Qt.platform.os === "android") return qsTr("Enable")
                    }
                    return qsTr("Retry")
                }
                onClicked: {
                    if (deviceManager.bluetoothAdapter &&!deviceManager.bluetoothEnabled) {
                        if (Qt.platform.os === "android") {
                            deviceManager.enableBluetooth()
                            return
                        }
                    }
                    deviceManager.checkBluetooth()
                }
            }

            Item { width: 8; height: 8; }
        }

        ////

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: singleColumn ? (itemNoBluetooth.width*0.85) : undefined
            spacing: Theme.componentMargin

            visible: !deviceManager.bluetoothEnabled

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

                text: qsTr("Please <b>enable Bluetooth</b> on your device in order to use the application.")
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
