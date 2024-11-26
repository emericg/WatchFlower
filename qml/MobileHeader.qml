import QtQuick

import ComponentLibrary
import WatchFlower

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

    property string headerTitle: utilsApp.appName()

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

    // Action menu
    ActionMenuFixed { id: actionMenu }

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
        anchors.leftMargin: screenPaddingLeft
        anchors.rightMargin: screenPaddingRight

        ////////////

        MouseArea { // left button
            width: headerHeight
            height: headerHeight

            visible: true
            onClicked: leftMenuClicked()

            RippleThemed {
                anchors.fill: parent
                anchor: parent

                pressed: parent.pressed
                //active: enabled && parent.containsPress
                color: Qt.rgba(Theme.colorHeaderHighlight.r, Theme.colorHeaderHighlight.g, Theme.colorHeaderHighlight.b, 0.33)
            }

            IconSvg {
                anchors.centerIn: parent
                width: (headerHeight / 2)
                height: (headerHeight / 2)

                source: {
                    if (leftMenuMode === "drawer") return "qrc:/IconLibrary/material-symbols/menu.svg"
                    if (leftMenuMode === "close") return "qrc:/IconLibrary/material-symbols/close.svg"
                    return "qrc:/IconLibrary/material-symbols/arrow_back.svg"
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
            font.bold: false
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

                visible: (appContent.state !== "ScreenTutorial" &&
                          appContent.state !== "DevicePlantSensor" &&
                          appContent.state !== "DeviceThermometer" &&
                          appContent.state !== "DeviceEnvironmental")

                IconSvg {
                    id: workingIndicator
                    width: 24; height: 24;
                    anchors.centerIn: parent

                    source: {
                        if (deviceManager.scanning)
                            return "qrc:/IconLibrary/material-symbols/search.svg"
                        else if (deviceManager.syncing)
                            return "qrc:/assets/gfx/icons/duotone-date_all-24px.svg"
                        else if (deviceManager.listening)
                            return "qrc:/IconLibrary/material-symbols/autorenew.svg"
                        else
                            return "qrc:/IconLibrary/material-symbols/autorenew.svg"
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
                    anchors.fill: parent
                    anchor: parent

                    pressed: parent.pressed
                    //active: enabled && parent.containsPress
                    color: Qt.rgba(Theme.colorHeaderHighlight.r, Theme.colorHeaderHighlight.g, Theme.colorHeaderHighlight.b, 0.33)
                }

                IconSvg {
                    anchors.centerIn: parent
                    width: (headerHeight / 2)
                    height: (headerHeight / 2)

                    source: "qrc:/IconLibrary/material-symbols/more_vert.svg"
                    color: Theme.colorHeaderContent
                }
            }
        }

        ////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
