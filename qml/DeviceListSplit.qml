import QtQuick
import QtQuick.Controls

import ThemeEngine

Item {
    id: deviceList
    anchors.fill: parent

    // list devices, split per sensor type
    // per category ordering
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
        if (deviceManager.getDeviceByProxyIndex(index, type).selected) return

        // then add
        selectionMode = true
        selectionList.push(index)
        selectionCount++

        deviceManager.getDeviceByProxyIndex(index, type).selected = true
    }
    function deselectDevice(index, type) {
        var i = selectionList.indexOf(index)
        if (i > -1) { selectionList.splice(i, 1); selectionCount--; }
        if (selectionList.length <= 0 || selectionCount <= 0) { exitSelectionMode() }

        deviceManager.getDeviceByProxyIndex(index, type).selected = false
    }
    function exitSelectionMode() {
        selectionMode = false
        selectionList = []
        selectionCount = 0

        for (var i = 0; i < deviceManager.deviceCount; i++) {
            deviceManager.getDeviceByProxyIndex(i, 0).selected = false
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: devicesView.height
/*
        ScrollBar.vertical: ScrollBar {
            anchors.right: parent.right
            anchors.rightMargin: -halfmargin
            policy: ScrollBar.AsNeeded
            visible: false
        }
*/
        Column {
            id: devicesView
            anchors.left: parent.left
            anchors.leftMargin: halfmargin
            anchors.right: parent.right
            anchors.rightMargin: halfmargin

            topPadding: listWidget ? 16 : 16
            bottomPadding: listWidget ? 0 : halfmargin
            spacing: listWidget ? 0 : halfmargin

            ////////

            property int halfmargin: (Theme.componentMargin / 2)

            property bool bigWidget: (!isHdpi || (isTablet && width >= 480))
            property bool listWidget: (cellColumnsTarget === 1)

            property int cellColumnsTarget: Math.trunc(devicesView.width / cellWidthTarget)
            property int cellWidthTarget: {
                if (singleColumn) return devicesView.width
                if (isTablet) return (bigWidget ? 350 : 280)
                return (bigWidget ? 440 : 320)
            }
            property int cellWidth: (devicesView.width / cellColumnsTarget)
            property int cellHeight: {
                if (isPhone) return 100
                if (bigWidget) return 144
                return 112
            }

            ////////

            ListTitle {
                anchors.leftMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin
                anchors.rightMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin

                text: qsTr("Plant sensor(s)", "", deviceManager.devicePlantCount)
                textSize: Theme.fontSizeContentVeryBig
                visible: deviceManager.devicePlantCount
            }

            Flow {
                id: devicesPlantView
                anchors.left: parent.left
                anchors.right: parent.right

                Repeater {
                    model: deviceManager.devicesPlantList
                    delegate: DeviceWidget {
                        width: devicesView.cellWidth
                        height: devicesView.cellHeight
                        listMode: devicesView.listWidget
                    }
                }
            }

            ////////

            ListTitle {
                anchors.leftMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin
                anchors.rightMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin

                text: qsTr("Thermometer(s)", "", deviceManager.deviceThermoCount)
                textSize: Theme.fontSizeContentVeryBig
                visible: deviceManager.deviceThermoCount
            }

            Flow {
                id: devicesThermoView
                anchors.left: parent.left
                anchors.right: parent.right

                Repeater {
                    model: deviceManager.devicesThermoList
                    delegate: DeviceWidget {
                        width: devicesView.cellWidth
                        height: devicesView.cellHeight
                        listMode: devicesView.listWidget
                    }
                }
            }

            ////////

            ListTitle {
                anchors.leftMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin
                anchors.rightMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin

                text: qsTr("Environmental sensor(s)", "", deviceManager.deviceEnvCount)
                textSize: Theme.fontSizeContentVeryBig
                visible: deviceManager.deviceEnvCount
            }

            Flow {
                id: devicesEnvView
                anchors.left: parent.left
                anchors.right: parent.right

                Repeater {
                    model: deviceManager.devicesEnvList
                    delegate: DeviceWidget {
                        width: devicesView.cellWidth
                        height: devicesView.cellHeight
                        listMode: devicesView.listWidget
                    }
                }
            }

            ////////

            ListTitle {
                anchors.leftMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin
                anchors.rightMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin

                text: qsTr("Tools")
                textSize: Theme.fontSizeContentVeryBig
            }

            Flow {
                id: toolsView
                anchors.left: parent.left
                anchors.right: parent.right

                DeviceBrowserWidget {
                    width: devicesView.cellWidth
                    height: devicesView.cellWidth * 0.33
                    listMode: devicesView.listWidget
                }

                PlantBrowserWidget {
                    width: devicesView.cellWidth
                    height: devicesView.cellWidth * 0.33
                    listMode: devicesView.listWidget
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
