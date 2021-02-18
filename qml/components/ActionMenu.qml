import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Rectangle {
    id: actionMenu
    width: isPhone ? 190 : 256
    height: menuHolder.height
    visible: isOpen
    focus: isOpen && !isMobile

    color: Theme.colorBackground
    radius: Theme.componentRadius

    signal menuSelected(var index)
    property int menuWidth: 0
    property bool isOpen: false

    function open() { isOpen = true; updateSize(); }
    function close() { isOpen = false; }
    function openClose() { isOpen = !isOpen; updateSize(); }

    function updateSize() {
        if (isOpen) {
            menuWidth = 0
            if (actionUpdate.visible && menuWidth < actionUpdate.contentWidth) menuWidth = actionUpdate.contentWidth
            if (actionHistory.visible && menuWidth < actionHistory.contentWidth) menuWidth = actionHistory.contentWidth
            if (actionLed.visible && menuWidth < actionLed.contentWidth) menuWidth = actionLed.contentWidth
            if (actionGraphMode.visible && menuWidth < actionGraphMode.contentWidth) menuWidth = actionGraphMode.contentWidth
            menuWidth += 80
            actionMenu.width = menuWidth
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: menuHolder
        width: parent.width
        height: children.height * children.length

        topPadding: 4
        bottomPadding: 4
        spacing: 4

        ActionButton {
            id: actionUpdate
            index: 2
            visible: (deviceManager.bluetooth && selectedDevice)
            button_text: qsTr("Update data")
            button_source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            onButtonClicked: {
                deviceRefreshButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionButton {
            id: actionHistory
            index: 3
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))
            button_text: qsTr("Update history")
            button_source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
            onButtonClicked: {
                deviceRefreshHistoryButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionButton {
            id: actionLed
            index: 1
            button_text: qsTr("Blink LED")
            button_source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasLED) && appContent.state === "DeviceSensor")
            onButtonClicked: {
                deviceLedButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionButton {
            id: actionGraphMode
            index: 0
            button_text: qsTr("Switch graph")
            button_source: (settingsManager.graphThermometer === "minmax") ? "qrc:/assets/icons_material/duotone-insert_chart_outlined-24px.svg" : "qrc:/assets/icons_material/baseline-timeline-24px.svg";
            visible: (appContent.state === "DeviceThermo")
            onButtonClicked: {
                if (settingsManager.graphThermometer === "minmax") settingsManager.graphThermometer = "lines"
                else settingsManager.graphThermometer = "minmax"
                menuSelected(index)
                close()
            }
        }
    }
}
