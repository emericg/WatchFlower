import QtQuick 2.12

import ThemeEngine 1.0

Rectangle {
    id: rectangleHeaderBar
    width: parent.width
    height: screenPaddingStatusbar + screenPaddingNotch + headerHeight
    z: 10
    color: Theme.colorHeader

    property int headerHeight: 52
    property string title: "WatchFlower"

    ////////////////////////////////////////////////////////////////////////////

    property string leftMenuMode: "drawer" // drawer / back / close
    signal leftMenuClicked()

    onLeftMenuModeChanged: {
        if (leftMenuMode === "drawer")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-menu-24px.svg"
        else if (leftMenuMode === "close")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-close-24px.svg"
        else // back
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
    }

    ////////////////////////////////////////////////////////////////////////////

    property string rightMenuMode: "off" // on / off
    signal rightMenuClicked()

    function rightMenuIsOpen() { return actionMenu.visible; }
    function rightMenuClose() { actionMenu.close(); }

    signal deviceLedButtonClicked()
    signal deviceRefreshHistoryButtonClicked()
    signal deviceRefreshButtonClicked()
    signal deviceDataButtonClicked() // compatibility
    signal deviceHistoryButtonClicked() // compatibility
    signal deviceSettingsButtonClicked() // compatibility

    function setActiveDeviceData() { } // compatibility
    function setActiveDeviceHistory() { } // compatibility
    function setActiveDeviceSettings() { } // compatibility

    ////////////////////////////////////////////////////////////////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    Item {
        anchors.fill: parent
        anchors.topMargin: screenPaddingStatusbar + screenPaddingNotch

        MouseArea {
            id: leftArea
            width: headerHeight
            height: headerHeight
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            visible: true
            onClicked: leftMenuClicked()

            ImageSvg {
                id: leftMenuImg
                width: (headerHeight/2)
                height: (headerHeight/2)
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                color: Theme.colorHeaderContent
            }
        }

        Text {
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 64
            anchors.verticalCenter: parent.verticalCenter

            text: title
            color: Theme.colorHeaderContent
            font.bold: true
            font.pixelSize: Theme.fontSizeHeader
            font.capitalization: Font.Capitalize
            verticalAlignment: Text.AlignVCenter
        }

        ////////////

        Row {
            id: menu
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            spacing: 4
            visible: true

            Item {
                width: parent.height;
                height: width;
                anchors.verticalCenter: parent.verticalCenter
                visible: (appContent.state === "DeviceList")

                ImageSvg {
                    id: workingIndicator
                    width: 24; height: 24;
                    anchors.centerIn: parent

                    source: (deviceManager.scanning) ? "qrc:/assets/icons_material/baseline-search-24px.svg" : "qrc:/assets/icons_material/baseline-autorenew-24px.svg";
                    color: Theme.colorHeaderContent
                    opacity: 0
                    Behavior on opacity { OpacityAnimator { duration: 333 } }

                    NumberAnimation on rotation {
                        //id: refreshAnimation
                        from: 0
                        to: 360
                        duration: 2000
                        loops: Animation.Infinite
                        easing.type: Easing.Linear
                        running: deviceManager.refreshing
                        alwaysRunToEnd: true
                        onStarted: workingIndicator.opacity = 1
                        onStopped: workingIndicator.opacity = 0
                    }
                    SequentialAnimation on opacity {
                        //id: rescanAnimation
                        loops: Animation.Infinite
                        running: deviceManager.scanning
                        onStopped: workingIndicator.opacity = 0
                        PropertyAnimation { to: 1; duration: 750; }
                        PropertyAnimation { to: 0.33; duration: 750; }
                    }
                }
            }

            ////////////
/*
            ItemImageButton {
                id: buttonThermoChart
                width: 36; height: 36;
                anchors.verticalCenter: parent.verticalCenter

                visible: (appContent.state === "DeviceThermo")
                source: (settingsManager.graphThermometer === "minmax") ? "qrc:/assets/icons_material/duotone-insert_chart_outlined-24px.svg" : "qrc:/assets/icons_material/baseline-timeline-24px.svg";
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight

                onClicked: {
                    if (settingsManager.graphThermometer === "lines")
                        settingsManager.graphThermometer = "minmax"
                    else
                        settingsManager.graphThermometer = "lines"
                }
            }
            ItemImageButton {
                id: buttonLed
                width: 36; height: 36;
                anchors.verticalCenter: parent.verticalCenter

                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasLED) && appContent.state === "DeviceSensor")
                source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight

                onClicked: deviceLedButtonClicked()
            }
            ItemImageButton {
                id: buttonRefreshHistory
                width: 36; height: 36;
                anchors.verticalCenter: parent.verticalCenter

                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory) &&
                          ((appContent.state === "DeviceSensor") || (appContent.state === "DeviceThermo")))
                source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight
                onClicked: deviceRefreshHistoryButtonClicked()
            }
            ItemImageButton {
                id: buttonRefreshData
                width: 36; height: 36;
                anchors.verticalCenter: parent.verticalCenter

                visible: (deviceManager.bluetooth && ((appContent.state === "DeviceSensor") || (appContent.state === "DeviceThermo")))
                source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
                iconColor: Theme.colorHeaderContent
                backgroundColor: Theme.colorHeaderHighlight

                onClicked: deviceRefreshButtonClicked()

                NumberAnimation on rotation {
                    id: refreshAnimation
                    duration: 2000
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    running: selectedDevice.updating
                    alwaysRunToEnd: true
                    easing.type: Easing.Linear
                }
            }
*/
            ////////////

            MouseArea {
                id: rightMenu
                width: headerHeight
                height: headerHeight

                visible: (deviceManager.bluetooth && (appContent.state === "DeviceSensor" || appContent.state === "DeviceThermo"))
                onClicked: {
                    rightMenuClicked()
                    actionMenu.open()
                }

                ImageSvg {
                    id: rightMenuImg
                    width: (headerHeight/2)
                    height: (headerHeight/2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-more_vert-24px.svg"
                    color: Theme.colorHeaderContent
                }
            }
        }
    }

    ////////////

    MouseArea {
        id: actionMenuCloseArea
        width: appWindow.width
        height: appWindow.height
        //anchors.fill: appWindow

        enabled: actionMenu.isOpen
        onClicked: actionMenu.close()
    }

    ActionMenu {
        id: actionMenu
        anchors.top: parent.top
        anchors.topMargin: screenPaddingStatusbar + screenPaddingNotch + 8
        anchors.right: parent.right
        anchors.rightMargin: 8

        //onMenuSelected: console.log(" MENU " + index)

        Connections {
            target: appDrawer
            onVisibleChanged: actionMenu.close()
        }
        Connections {
            target: deviceManager
            onBluetoothChanged: {
                if (!deviceManager.bluetooth) actionMenu.close()
            }
        }
    }
}
