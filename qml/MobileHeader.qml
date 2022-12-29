import QtQuick

import ThemeEngine 1.0

Rectangle {
    id: rectangleHeaderBar
    width: parent.width
    height: screenPaddingStatusbar + screenPaddingNotch + headerHeight
    z: 10
    color: Theme.colorHeader

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

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

    signal deviceRebootButtonClicked()
    signal deviceCalibrateButtonClicked()
    signal deviceWateringButtonClicked()
    signal deviceLedButtonClicked()
    signal deviceRefreshButtonClicked()
    signal deviceRefreshRealtimeButtonClicked()
    signal deviceRefreshHistoryButtonClicked()
    signal deviceClearButtonClicked()
    signal deviceDataButtonClicked() // compatibility
    signal deviceHistoryButtonClicked() // compatibility
    signal devicePlantButtonClicked() // compatibility
    signal deviceSettingsButtonClicked() // compatibility

    function setActiveDeviceData() { } // compatibility
    function setActiveDeviceHistory() { } // compatibility
    function setActiveDevicePlant() { } // compatibility
    function setActiveDeviceSettings() { } // compatibility

    ////////////////////////////////////////////////////////////////////////////

    ActionMenuFixed {
        id: actionMenu

        x: parent.width - actionMenu.width - 12
        y: screenPaddingStatusbar + screenPaddingNotch + 16

        onMenuSelected: (index) => {
            //console.log("ActionMenu clicked #" + index)
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        anchors.fill: parent
        anchors.topMargin: screenPaddingStatusbar + screenPaddingNotch

        MouseArea { // left button
            id: leftArea
            width: headerHeight
            height: headerHeight
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            visible: true
            onClicked: leftMenuClicked()

            IconSvg {
                id: leftMenuImg
                width: (headerHeight / 2)
                height: (headerHeight / 2)
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                color: Theme.colorHeaderContent
            }
        }

        Text { // title
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

        Row { // right area
            id: menu
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.bottom: parent.bottom

            spacing: 4
            visible: true

            Item { // right indicators
                width: parent.height
                height: width
                anchors.verticalCenter: parent.verticalCenter
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

            ////////////

            MouseArea { // right button
                width: headerHeight
                height: headerHeight

                visible: (deviceManager.bluetooth &&
                          (appContent.state === "DevicePlantSensor" ||
                           appContent.state === "DeviceThermometer" ||
                           appContent.state === "DeviceEnvironmental"))

                onClicked: {
                    rightMenuClicked()
                    actionMenu.open()
                }

                IconSvg {
                    width: (headerHeight / 2)
                    height: (headerHeight / 2)
                    anchors.centerIn: parent

                    source: "qrc:/assets/icons_material/baseline-more_vert-24px.svg"
                    color: Theme.colorHeaderContent
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
