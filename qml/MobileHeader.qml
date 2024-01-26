import QtQuick

import ThemeEngine

Rectangle {
    id: appHeader

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    height: headerHeight + Math.max(screenPaddingStatusbar, screenPaddingTop)
    color: Theme.colorHeader
    clip: true
    z: 10

    property int headerHeight: 52

    property int headerPosition: 56

    property string headerTitle: "WatchFlower"

    ////////////////////////////////////////////////////////////////////////////

    property string leftMenuMode: "drawer" // drawer / back / close
    signal leftMenuClicked()

    property string rightMenuMode: "off" // on / off
    signal rightMenuClicked()

    ////////////////////////////////////////////////////////////////////////////

    function rightMenuIsOpen() { return actionMenu.visible; }
    function rightMenuClose() { actionMenu.close(); }

    signal deviceRebootButtonClicked()
    signal deviceCalibrateButtonClicked()
    signal deviceWateringButtonClicked()
    signal deviceLedButtonClicked()
    signal deviceRefreshButtonClicked()
    signal deviceRefreshRealtimeButtonClicked()
    signal deviceRefreshHistoryButtonClicked()
    signal deviceClearButtonClicked()
    signal deviceDataButtonClicked() // desktop header compatibility
    signal deviceHistoryButtonClicked() // desktop header compatibility
    signal devicePlantButtonClicked() // desktop header compatibility
    signal deviceSettingsButtonClicked() // desktop header compatibility

    function setActiveDeviceData() { } // desktop header compatibility
    function setActiveDeviceHistory() { } // desktop header compatibility
    function setActiveDevicePlant() { } // desktop header compatibility
    function setActiveDeviceSettings() { } // desktop header compatibility

    ////////////////////////////////////////////////////////////////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ActionMenuFixed {
        id: actionMenu

        x: parent.width - actionMenu.width - 12
        y: Math.max(screenPaddingStatusbar, screenPaddingTop) + 16

        onMenuSelected: (index) => {
            //console.log("ActionMenu clicked #" + index)
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // OS statusbar area
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: Math.max(screenPaddingStatusbar, screenPaddingTop)
        color: Theme.colorStatusbar
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: Math.max(screenPaddingStatusbar, screenPaddingTop)

        ////////////

        MouseArea { // left button
            width: headerHeight
            height: headerHeight

            visible: true
            onClicked: leftMenuClicked()

            RippleThemed {
                anchor: parent
                width: parent.width
                height: parent.height

                pressed: parent.pressed
                //active: enabled && parent.containsPress
                color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.33)
            }

            IconSvg {
                anchors.centerIn: parent
                width: (headerHeight / 2)
                height: (headerHeight / 2)

                source: {
                    if (leftMenuMode === "drawer") return "qrc:/assets/icons_material/baseline-menu-24px.svg"
                    if (leftMenuMode === "close") return "qrc:/assets/icons_material/baseline-close-24px.svg"
                    return "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
                }
                color: Theme.colorHeaderContent
            }
        }

        Text { // header title
            anchors.left: parent.left
            anchors.leftMargin: headerPosition
            anchors.right: rightArea.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            text: headerTitle
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: Theme.fontSizeHeader
            color: Theme.colorHeaderContent
            elide: Text.ElideRight
        }

        ////////////

        Row { // right area
            id: rightArea
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            spacing: 4

            Item { // right indicator
                width: headerHeight
                height: headerHeight

                visible: (appContent.state !== "Tutorial" &&
                          appContent.state !== "DevicePlantSensor" &&
                          appContent.state !== "DeviceThermometer" &&
                          appContent.state !== "DeviceEnvironmental")

                IconSvg {
                    id: workingIndicator
                    width: 24; height: 24;
                    anchors.centerIn: parent

                    source: {
                        if (deviceManager.scanning)
                            return "qrc:/assets/icons_material/baseline-search-24px.svg"
                        else if (deviceManager.syncing)
                            return "qrc:/assets/icons_custom/duotone-date_all-24px.svg"
                        else if (deviceManager.listening)
                            return "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                        else
                            return "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                    }
                    color: Theme.colorHeaderContent
                    opacity: 0
                    Behavior on opacity { OpacityAnimator { duration: 333 } }

                    NumberAnimation on rotation { // refreshAnimation (rotate)
                        from: 0
                        to: 360
                        duration: 2000
                        loops: Animation.Infinite
                        easing.type: Easing.Linear
                        running: (deviceManager.updating && !deviceManager.scanning && !deviceManager.syncing)
                        alwaysRunToEnd: true
                        onStarted: workingIndicator.opacity = 1
                        onStopped: workingIndicator.opacity = 0
                    }
                    SequentialAnimation on opacity { // scanAnimation (fade)
                        loops: Animation.Infinite
                        running: (deviceManager.scanning || deviceManager.listening || deviceManager.syncing)
                        onStopped: workingIndicator.opacity = 0
                        PropertyAnimation { to: 1; duration: 750; }
                        PropertyAnimation { to: 0.33; duration: 750; }
                    }
                }
            }

            MouseArea { // right button
                width: headerHeight
                height: headerHeight

                visible: (deviceManager.bluetooth &&
                          ((appContent.state === "DevicePlantSensor" && selectedDevice.hasBluetoothConnection) ||
                           appContent.state === "DeviceThermometer" ||
                           appContent.state === "DeviceEnvironmental"))

                onClicked: {
                    rightMenuClicked()
                    actionMenu.open()
                }

                RippleThemed {
                    width: parent.width
                    height: parent.height

                    pressed: parent.pressed
                    //active: enabled && parent.containsPress
                    color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.33)
                }

                IconSvg {
                    anchors.centerIn: parent
                    width: (headerHeight / 2)
                    height: (headerHeight / 2)

                    source: "qrc:/assets/icons_material/baseline-more_vert-24px.svg"
                    color: Theme.colorHeaderContent
                }
            }
        }

        ////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
