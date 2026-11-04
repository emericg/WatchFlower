import QtQuick
import QtQuick.Controls

import ComponentLibrary

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
        if (DeviceManager.getDeviceByProxyIndex(index, type).selected) return

        // then add
        selectionMode = true
        selectionList.push(index)
        selectionCount++

        DeviceManager.getDeviceByProxyIndex(index, type).selected = true
    }
    function deselectDevice(index, type) {
        var i = selectionList.indexOf(index)
        if (i > -1) { selectionList.splice(i, 1); selectionCount--; }
        if (selectionList.length <= 0 || selectionCount <= 0) { exitSelectionMode() }

        DeviceManager.getDeviceByProxyIndex(index, type).selected = false
    }
    function exitSelectionMode() {
        selectionMode = false
        selectionList = []
        selectionCount = 0

        DeviceManager.clearDeviceSelection()
    }

    ////////////////////////////////////////////////////////////////////////////

    Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: devicesView.height
/*
        ScrollBar.vertical: ScrollBarThemed {
            anchors.right: parent.right
            anchors.rightMargin: -halfmargin
            policy: ScrollBar.AsNeeded
            visible: false
        }
*/
        Component.onCompleted: {
            //console.log("> (default) flick maximum velocity: " + maximumFlickVelocity)
            //console.log("> (default) flick deceleration: " + flickDeceleration)

            if (Theme.isDesktop) {
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

        Column {
            id: devicesView
            anchors.left: parent.left
            anchors.leftMargin: halfmargin
            anchors.right: parent.right
            anchors.rightMargin: halfmargin

            topPadding: listWidget ? 16 : 16
            bottomPadding: listWidget ? 1 : halfmargin
            spacing: listWidget ? 0 : halfmargin

            ////////

            property int halfmargin: (Theme.componentMargin / 2)

            property bool bigWidget: (!Theme.isHdpi || (Theme.isTablet && width >= 480))
            property bool listWidget: (cellColumnsTarget === 1)

            property int cellColumnsTarget: Math.trunc(devicesView.width / cellWidthTarget)
            property int cellWidthTarget: {
                if (Theme.singleColumn) return devicesView.width
                if (Theme.isTablet) return (bigWidget ? 350 : 280)
                return (bigWidget ? 440 : 320)
            }
            property int cellWidth: (devicesView.width / cellColumnsTarget)
            property int cellHeight: {
                if (Theme.isPhone) return 100
                if (bigWidget) return 144
                return 112
            }

            ////////

            ListTitle {
                anchors.leftMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin
                anchors.rightMargin: devicesView.listWidget ? -devicesView.halfmargin : devicesView.halfmargin
                visible: plantRepeater.count

                text: qsTr("Plant sensor(s)", "", plantRepeater.count)
                textSize: Theme.fontSizeContentVeryBig
            }

            Flow {
                id: devicesPlantView
                anchors.left: parent.left
                anchors.right: parent.right
                visible: plantRepeater.count

                Repeater {
                    id: plantRepeater
                    model: DeviceManager.devicesPlantList
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
                visible: thermoRepeater.count

                text: qsTr("Thermometer(s)", "", thermoRepeater.count)
                textSize: Theme.fontSizeContentVeryBig
            }

            Flow {
                id: devicesThermoView
                anchors.left: parent.left
                anchors.right: parent.right
                visible: thermoRepeater.count

                Repeater {
                    id: thermoRepeater
                    model: DeviceManager.devicesThermoList
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
                visible: envRepeater.count

                text: qsTr("Environmental sensor(s)", "", envRepeater.count)
                textSize: Theme.fontSizeContentVeryBig
            }

            Flow {
                id: devicesEnvView
                anchors.left: parent.left
                anchors.right: parent.right
                visible: envRepeater.count

                Repeater {
                    id: envRepeater
                    model: DeviceManager.devicesEnvList
                    delegate: DeviceWidget {
                        width: devicesView.cellWidth
                        height: devicesView.cellHeight
                        listMode: devicesView.listWidget
                    }
                }
            }

            ////////

            Text {
                width: devicesView.width
                visible: (plantRepeater.count + thermoRepeater.count + envRepeater.count === 0 &&
                          DeviceManager.filterActive)

                topPadding: Theme.componentMargin
                bottomPadding: Theme.componentMargin
                text: screenDeviceList.noMatchText
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
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
                SunAndMoonWidget {
                    visible: SettingsManager.sunandmoon
                    width: devicesView.cellWidth
                    height: devicesView.cellWidth * (devicesView.listWidget ? 0.6 : 0.5)
                    listMode: devicesView.listWidget
                }

                PlantBrowserWidget {
                    width: devicesView.cellWidth
                    height: devicesView.cellWidth * 0.33
                    listMode: devicesView.listWidget
                }

                DeviceBrowserWidget {
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
