import QtQuick

import ComponentLibrary
import DeviceUtils

Rectangle {
    id: statusBox
    anchors.left: parent.left
    anchors.right: parent.right

    height: (connecting || syncing) ? (isPhone ? 44 : 48) : 0
    Behavior on height { NumberAnimation { duration: 133 } }

    clip: true
    visible: (height > 0)
    color: Theme.colorActionbar

    property bool connecting: (currentDevice &&
                               currentDevice.status === DeviceUtils.DEVICE_CONNECTING &&
                               (currentDevice.action === DeviceUtils.ACTION_UPDATE_HISTORY ||
                                currentDevice.action === DeviceUtils.ACTION_UPDATE_REALTIME))

    property bool syncing: (currentDevice &&
                            (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY ||
                             currentDevice.status === DeviceUtils.DEVICE_UPDATING_REALTIME))

    ////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        IconSvg {
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            source: syncing ? "qrc:/IconLibrary/material-icons/duotone/bluetooth_connected.svg" :
                              "qrc:/IconLibrary/material-icons/duotone/bluetooth_searching.svg"
            color: Theme.colorActionbarContent

            SequentialAnimation on opacity {
                running: (connecting || syncing)
                alwaysRunToEnd: true
                loops: Animation.Infinite

                PropertyAnimation { to: 0.33; duration: 750; }
                PropertyAnimation { to: 1; duration: 750; }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: syncing ? qsTr("Syncing with the sensor...") : qsTr("Connecting...")
            color: Theme.colorActionbarContent
            font.pixelSize: Theme.fontSizeContent
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: (currentDevice && currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY)

            text: " (" + currentDevice.historyUpdatePercent + "%)"
            textFormat: Text.PlainText
            color: Theme.colorActionbarContent
            font.pixelSize: Theme.fontSizeContent
        }
    }

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
        source: "qrc:/IconLibrary/material-symbols/close.svg"

        onClicked: currentDevice.deviceDisconnect()
    }

    ////////////////

    Rectangle { // progress bar
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: currentDevice ? (parent.width * (currentDevice.historyUpdatePercent/100)) : 0
        height: 4

        visible: (currentDevice && currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY)
        color: Theme.colorActionbarHighlight
    }

    ////////////////
}
