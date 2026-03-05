import QtQuick

import ComponentLibrary
import DeviceUtils

Item {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    ////////////////

    BannerProgressButton {
        height: isPhone ? 44 : 48

        opacity: (connecting || syncing) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 133 } }

        text: syncing ? qsTr("Syncing with the sensor...") : qsTr("Connecting...")
        textButton: qsTr("Cancel")

        source: syncing ? "qrc:/IconLibrary/material-symbols/autorenew.svg" :
                          "qrc:/IconLibrary/material-icons/duotone/bluetooth_searching.svg"

        enabled: (connecting || syncing)

        progress: (syncing) ? currentDevice.historyUpdatePercent : -1
        progressRunning: (syncing)

        animation: (connecting) ? "fade" : "rotate"
        animationRunning: (connecting || syncing)

        onClicked: currentDevice.actionDisconnect()

        property bool connecting: (currentDevice &&
                                   currentDevice.status === DeviceUtils.DEVICE_CONNECTING &&
                                   (currentDevice.action === DeviceUtils.ACTION_UPDATE_HISTORY ||
                                    currentDevice.action === DeviceUtils.ACTION_UPDATE_REALTIME))

        property bool syncing: (currentDevice &&
                                currentDevice.status >= DeviceUtils.DEVICE_CONNECTED &&
                                (currentDevice.status === DeviceUtils.DEVICE_UPDATING_HISTORY ||
                                 currentDevice.status === DeviceUtils.DEVICE_UPDATING_REALTIME))
    }

    ////////////////
}
