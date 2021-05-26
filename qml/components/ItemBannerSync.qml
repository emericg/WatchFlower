import QtQuick 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0

Rectangle {
    id: statusBox
    width: parent.width
    height: (syncing && visible) ? (isPhone ? 40 : 48) : 0
    Behavior on height { NumberAnimation { duration: 133 } }

    clip: true
    visible: (height > 0)
    color: Theme.colorActionbar

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

            text: qsTr("Syncing with the sensor")
            color: Theme.colorActionbarContent
            font.pixelSize: Theme.fontSizeContent
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY)

            text: " (" + currentDevice.historyUpdatePercent + "%)"
            color: Theme.colorActionbarContent
            font.pixelSize: Theme.fontSizeContent
        }
    }

    ////////////////

    ButtonCompactable {
        id: buttonCancel
        height: compact ? 36 : 34
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        compact: !wideMode
        iconColor: Theme.colorActionbarContent
        backgroundColor: Theme.colorActionbarHighlight
        text: qsTr("Stop")
        source: "qrc:/assets/icons_material/baseline-close-24px.svg"

        onClicked: currentDevice.deviceDisconnect()
    }

    ////////////////

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        visible: (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY)
        width: (parent.width * (currentDevice.historyUpdatePercent/100))
        height: 4
        color: Theme.colorActionbarHighlight
    }
}
