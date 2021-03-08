import QtQuick 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0

Rectangle {
    id: statusBox
    width: parent.width

    height: syncing ? 48 : 0
    Behavior on height { NumberAnimation { duration: 133 } }

    color: Theme.colorActionbar
    clip: true

    property bool syncing: (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY ||
                            currentDevice.status === DeviceUtils.DEVICE_UPDATING_REALTIME)

    ////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ImageSvg {
            id: buttonBle
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
            color: Theme.colorActionbarContent
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Syncing with the device")
            color: Theme.colorActionbarContent
            font.pixelSize: Theme.fontSizeContent
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: " (" + currentDevice.historyUpdatePercent + "%)"
            visible: (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY)
            color: Theme.colorActionbarContent
            font.pixelSize: Theme.fontSizeContent
        }
    }

    ////////////////

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        ItemImageButton {
            id: buttonCancel1
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            //visible: !parent.useBigButtons
            iconColor: Theme.colorActionbarContent
            backgroundColor: Theme.colorActionbarHighlight
            source: "qrc:/assets/icons_material/baseline-close-24px.svg"

            onClicked: currentDevice.deviceDisconnect()
        }

        ButtonWireframeImage {
            id: buttonCancel2
            height: 32
            anchors.verticalCenter: parent.verticalCenter

            //visible: parent.useBigButtons
            fullColor: true
            primaryColor: Theme.colorActionbarHighlight
            text: qsTr("Cancel")
            source: "qrc:/assets/icons_material/baseline-close-24px.svg"
            onClicked: currentDevice.deviceDisconnect()
        }
    }

    ////////////////

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        visible: (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY)
        width: (parent.width * (currentDevice.historyUpdatePercent/100))
        height: 3
        color: Theme.colorActionbarHighlight
    }
}
