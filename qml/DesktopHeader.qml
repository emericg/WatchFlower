import QtQuick 2.12

import ThemeEngine 1.0

Rectangle {
    id: rectangleHeaderBar
    width: parent.width
    height: headerHeight
    z: 10
    color: Theme.colorHeader

    property int headerHeight: 64

    ////////////////////////////////////////////////////////////////////////////

    signal backButtonClicked()
    signal rightMenuClicked() // compatibility

    signal deviceLedButtonClicked()
    signal deviceRefreshHistoryButtonClicked()
    signal deviceRefreshButtonClicked()
    signal deviceDataButtonClicked()
    signal deviceHistoryButtonClicked()
    signal deviceSettingsButtonClicked()

    signal refreshButtonClicked()
    signal rescanButtonClicked()
    signal plantsButtonClicked()
    signal settingsButtonClicked()
    signal aboutButtonClicked()
    signal exitButtonClicked()

    function setActiveDeviceData() {
        menuDeviceData.selected = true
        menuDeviceHistory.selected = false
        menuDeviceSettings.selected = false
    }
    function setActiveDeviceHistory() {
        menuDeviceData.selected = false
        menuDeviceHistory.selected = true
        menuDeviceSettings.selected = false
    }
    function setActiveDeviceSettings() {
        menuDeviceData.selected = false
        menuDeviceHistory.selected = false
        menuDeviceSettings.selected = true
    }

    function setActiveMenu() {
        if (appContent.state === "Tutorial") {
            title.text = qsTr("Welcome")
            menus.visible = false

            buttonBack.source = "qrc:/assets/menus/menu_close.svg"
        } else {
            title.text = "WatchFlower"
            menus.visible = true

            if (appContent.state === "DeviceList") {
                buttonBack.source = "qrc:/assets/menus/menu_logo_large.svg"
            } else {
                buttonBack.source = "qrc:/assets/menus/menu_back.svg"
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    DragHandler {
        // make that surface draggable
        // also, prevent clicks below this area
        onActiveChanged: if (active) appWindow.startSystemMove();
        target: null
    }

    MouseArea {
        width: 40
        height: 40
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        hoverEnabled: (buttonBack.source !== "qrc:/assets/menus/menu_logo_large.svg")
        onEntered: { buttonBackBg.opacity = 0.5; }
        onExited: { buttonBackBg.opacity = 0; buttonBack.width = 24; }

        onPressed: buttonBack.width = 20
        onReleased: buttonBack.width = 24
        onClicked: backButtonClicked()

        enabled: (buttonBack.source != "qrc:/assets/menus/menu_logo_large.svg" || wideMode)
        visible: enabled

        Rectangle {
            id: buttonBackBg
            anchors.fill: parent
            radius: height
            z: -1
            color: Theme.colorHeaderHighlight
            opacity: 0
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }

        ImageSvg {
            id: buttonBack
            width: 24
            height: width
            anchors.centerIn: parent

            source: "qrc:/assets/menus/menu_logo_large.svg"
            color: Theme.colorHeaderContent
        }
    }

    Text {
        id: title
        anchors.left: parent.left
        anchors.leftMargin: 64
        anchors.verticalCenter: parent.verticalCenter

        visible: wideMode
        text: "WatchFlower"
        font.bold: true
        font.pixelSize: Theme.fontSizeHeader
        color: Theme.colorHeaderContent
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        id: menus
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        spacing: 8
        visible: true

        ////////////

        ButtonCompactable {
            id: buttonThermoChart
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            visible: (appContent.state === "DeviceThermometer")

            source: (settingsManager.graphThermometer === "lines") ? "qrc:/assets/icons_material/duotone-insert_chart_outlined-24px.svg" : "qrc:/assets/icons_material/baseline-timeline-24px.svg";
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: {
                if (settingsManager.graphThermometer === "lines")
                    settingsManager.graphThermometer = "minmax"
                else
                    settingsManager.graphThermometer = "lines"
            }
            tooltipText: qsTr("Switch graph")
        }
        ButtonCompactable {
            id: buttonLed
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasLED) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: deviceLedButtonClicked()
            tooltipText: qsTr("Blink LED")
        }
        ButtonCompactable {
            id: buttonRefreshHistory
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasHistory) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: deviceRefreshHistoryButtonClicked()
            tooltipText: qsTr("Sync history")
        }
        ButtonCompactable {
            id: buttonRefreshData
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: deviceRefreshButtonClicked()

            tooltipText: qsTr("Refresh device")
            animation: "rotate"
            animationRunning: selectedDevice.updating
        }
        Item { // spacer
            width: 8
            height: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: (appContent.state === "DeviceThermometer" || appContent.state === "DeviceEnvironmental")
        }

        Row {
            id: menuDevice
            spacing: 0

            visible: (appContent.state === "DevicePlantSensor")

            ItemMenuButton {
                id: menuDeviceData
                width: headerHeight
                height: headerHeight
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                onClicked: deviceDataButtonClicked()
            }
            ItemMenuButton {
                id: menuDeviceHistory
                width: headerHeight
                height: headerHeight
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-date_range-24px.svg"
                onClicked: deviceHistoryButtonClicked()
            }
            ItemMenuButton {
                id: menuDeviceSettings
                width: headerHeight
                height: headerHeight
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-iso-24px.svg"
                onClicked: deviceSettingsButtonClicked()
            }
        }

        ////////////

        ButtonCompactable {
            id: buttonSort
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            visible: menuMain.visible
            source: "qrc:/assets/icons_material/baseline-filter_list-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            function setText() {
                var txt = qsTr("Order by:") + " "
                if (settingsManager.orderBy === "waterlevel") {
                    txt += qsTr("water level")
                } else if (settingsManager.orderBy === "plant") {
                    txt += qsTr("plant name")
                } else if (settingsManager.orderBy === "model") {
                    txt += qsTr("device model")
                } else if (settingsManager.orderBy === "location") {
                    txt += qsTr("location")
                }
                buttonSort.tooltipText = txt
            }

            Component.onCompleted: buttonSort.setText()
            Connections {
                target: settingsManager
                onOrderByChanged: buttonSort.setText()
                onAppLanguageChanged: buttonSort.setText()
            }

            property var sortmode: {
                if (settingsManager.orderBy === "waterlevel") {
                    return 3
                } else if (settingsManager.orderBy === "plant") {
                    return 2
                } else if (settingsManager.orderBy === "model") {
                    return 1
                } else { // if (settingsManager.orderBy === "location") {
                    return 0
                }
            }

            onClicked: {
                sortmode++
                if (sortmode > 3) sortmode = 0

                if (sortmode === 0) {
                    settingsManager.orderBy = "location"
                    deviceManager.orderby_location()
                } else if (sortmode === 1) {
                    settingsManager.orderBy = "model"
                    deviceManager.orderby_model()
                } else if (sortmode === 2) {
                    settingsManager.orderBy = "plant"
                    deviceManager.orderby_plant()
                } else if (sortmode === 3) {
                    settingsManager.orderBy = "waterlevel"
                    deviceManager.orderby_waterlevel()
                }
            }
        }
        ButtonCompactable {
            id: buttonScan
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth && menuMain.visible)
            enabled: !deviceManager.refreshing

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: rescanButtonClicked()
            text: qsTr("Scan for devices")
            tooltipText: text

            animation: "fade"
            animationRunning: deviceManager.scanning
        }
        ButtonCompactable {
            id: buttonRefreshAll
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth && menuMain.visible)
            enabled: !deviceManager.scanning

            source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: refreshButtonClicked()
            text: qsTr("Refresh devices")
            tooltipText: text

            animation: "rotate"
            animationRunning: deviceManager.refreshing
        }

        ////////////

        Row {
            id: menuMain
            spacing: 0
            visible: (appContent.state === "DeviceList" ||
                      appContent.state === "Settings" ||
                      appContent.state === "About")

            ItemMenuButton {
                id: menuPlants
                width: headerHeight
                height: headerHeight
                selected: (appContent.state === "DeviceList")
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/logos/watchflower_tray_dark.svg"
                onClicked: plantsButtonClicked()
            }
            ItemMenuButton {
                id: menuSettings
                width: headerHeight
                height: headerHeight
                selected: (appContent.state === "Settings")
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                onClicked: settingsButtonClicked()
            }
            ItemMenuButton {
                id: menuAbout
                width: headerHeight
                height: headerHeight
                selected: (appContent.state === "About")
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/menus/menu_infos.svg"
                onClicked: aboutButtonClicked()
            }
        }
    }

    ////////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: (!headerUnicolor &&
                  appContent.state !== "DeviceThermometer" &&
                  appContent.state !== "DeviceEnvironmental" &&
                  appContent.state !== "Tutorial")

        height: 2
        opacity: 0.33
        color: Theme.colorHeaderHighlight
    }
}
