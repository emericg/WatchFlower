import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Item {
    id: deviceList
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    property bool selectionMode: false
    property var selectionList: []
    property int selectionCount: 0

    function isSelected() {
        return (selectionList.length !== 0)
    }
    function selectDevice(index, type) {
        // make sure it's not already selected
        if (deviceManager.getDeviceByProxyIndex(index).selected) return

        // then add
        selectionMode = true
        selectionList.push(index)
        selectionCount++

        deviceManager.getDeviceByProxyIndex(index).selected = true
    }
    function deselectDevice(index, type) {
        var i = selectionList.indexOf(index)
        if (i > -1) { selectionList.splice(i, 1); selectionCount--; }
        if (selectionList.length <= 0 || selectionCount <= 0) { exitSelectionMode() }

        deviceManager.getDeviceByProxyIndex(index).selected = false
    }
    function exitSelectionMode() {
        selectionMode = false
        selectionList = []
        selectionCount = 0

        for (var i = 0; i < devicesView.count; i++) {
            deviceManager.getDeviceByProxyIndex(i).selected = false
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    GridView {
        id: devicesView
        anchors.fill: parent
        anchors.topMargin: singleColumn ? 0 : 8
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.bottomMargin: singleColumn ? 0 : 8

        property bool bigWidget: (!isHdpi || (isTablet && width >= 480))

        property int cellWidthTarget: {
            if (singleColumn) return devicesView.width
            if (isTablet) return (bigWidget ? 350 : 280)
            return (bigWidget ? 440 : 320)
        }
        property int cellColumnsTarget: Math.trunc(devicesView.width / cellWidthTarget)

        cellWidth: (devicesView.width / cellColumnsTarget)
        cellHeight: (bigWidget ? 144 : 100)

        ScrollBar.vertical: ScrollBar {
            visible: false
            anchors.right: parent.right
            anchors.rightMargin: -6
            policy: ScrollBar.AsNeeded
        }

        model: deviceManager.devicesList
        delegate: DeviceWidget {
            width: devicesView.cellWidth
            height: devicesView.cellHeight
            bigAssMode: devicesView.bigWidget
            singleColumn: (appWindow.singleColumn || devicesView.cellColumnsTarget === 1)
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
