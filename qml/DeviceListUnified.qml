import QtQuick
import QtQuick.Controls

import ComponentLibrary

Item {
    id: deviceList
    anchors.fill: parent

    // list devices
    // multi selection support

    ////////////////////////////////////////////////////////////////////////////

    property bool selectionMode: false
    property var selectionList: []
    property int selectionCount: 0

    function isSelected() {
        return (selectionList.length > 0)
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

        anchors.topMargin: listWidget ? 0 : halfmargin
        anchors.leftMargin: halfmargin
        anchors.rightMargin: halfmargin
        anchors.bottomMargin: listWidget ? 1 : halfmargin
/*
        ScrollBar.vertical: ScrollBar {
            anchors.right: parent.right
            anchors.rightMargin: -halfmargin
            policy: ScrollBar.AsNeeded
            visible: false
        }
*/
        Component.onCompleted: {
            //console.log("> (default) flick maximum velocity: " + maximumFlickVelocity)
            //console.log("> (default) flick deceleration: " + flickDeceleration)

            if (isDesktop) {
                // mouse wheel or trackpad
                maximumFlickVelocity = 6500
                flickDeceleration = 5000
                boundsBehavior = Flickable.OvershootBounds
            } else {
                // touch
                maximumFlickVelocity = 7500
                flickDeceleration = 3000
                boundsBehavior = Flickable.DragAndOvershootBounds
            }
        }

        ////////

        property int halfmargin: (Theme.componentMargin / 2)

        property bool bigWidget: (!isHdpi || (isTablet && width >= 480))
        property bool listWidget: (devicesView.cellColumnsTarget === 1)

        property int cellColumnsTarget: Math.trunc(devicesView.width / cellWidthTarget)
        property int cellWidthTarget: {
            if (singleColumn) return devicesView.width
            if (isTablet) return (bigWidget ? 350 : 280)
            return (bigWidget ? 440 : 320)
        }
        cellWidth: (devicesView.width / cellColumnsTarget)
        cellHeight: {
            if (isPhone) return 100
            if (bigWidget) return 144
            return 112
        }

        ////////

        model: deviceManager.devicesList
        delegate: DeviceWidget {
            width: devicesView.cellWidth
            height: devicesView.cellHeight
            listMode: devicesView.listWidget
        }

        ////////

        footer: Flow {
            id: toolsView
            anchors.left: parent.left
            anchors.right: parent.right
            SunAndMoonWidget {
                visible: settingsManager.sunandmoon
                width: devicesView.cellWidth
                height: devicesView.cellWidth * (devicesView.listWidget ? 0.6 : 0.5)
                listMode: devicesView.listWidget
            }

            DeviceBrowserWidget {
                width: devicesView.cellWidth
                height: devicesView.cellWidth * 0.33
                listMode: devicesView.listWidget
                visible: isDesktop
            }

            PlantBrowserWidget {
                width: devicesView.cellWidth
                height: devicesView.cellWidth * 0.33
                listMode: devicesView.listWidget
                visible: isDesktop
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
