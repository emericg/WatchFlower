import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Rectangle {
    id: actionMenu
    width: 220
    height: menuHolder.height
    visible: isOpen
    focus: isOpen && !isMobile

    color: Theme.colorBackground
    radius: Theme.componentRadius
    border.color: Theme.colorSeparator
    border.width: Theme.componentBorderWidth

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
            if (actionRealtime.visible && menuWidth < actionRealtime.contentWidth) menuWidth = actionRealtime.contentWidth
            if (actionHistoryRefresh.visible && menuWidth < actionHistoryRefresh.contentWidth) menuWidth = actionHistoryRefresh.contentWidth
            if (actionHistoryClear.visible && menuWidth < actionHistoryClear.contentWidth) menuWidth = actionHistoryClear.contentWidth
            if (actionLed.visible && menuWidth < actionLed.contentWidth) menuWidth = actionLed.contentWidth
            if (actionWatering.visible && menuWidth < actionWatering.contentWidth) menuWidth = actionWatering.contentWidth
            if (actionGraphMode.visible && menuWidth < actionGraphMode.contentWidth) menuWidth = actionGraphMode.contentWidth
            menuWidth += 96
            actionMenu.width = menuWidth
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: menuHolder
        width: parent.width
        height: children.height * children.length

        topPadding: 8
        bottomPadding: 8
        spacing: 4

        ActionButton {
            id: actionUpdate
            index: 0
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
            id: actionRealtime
            index: 1
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasRealTime))
            button_text: qsTr("Real time data")
            button_source: "qrc:/assets/icons_material/duotone-update-24px.svg"
            onButtonClicked: {
                deviceRefreshRealtimeButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ////////

        Rectangle {
            width: parent.width; height: 1;
            color: Theme.colorSeparator
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))
        }

        ActionButton {
            id: actionHistoryRefresh
            index: 2
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
            id: actionHistoryClear
            index: 3
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))
            button_text: qsTr("Clear history")
            button_source: "qrc:/assets/icons_material/duotone-date_clear-24px.svg"
            onButtonClicked: {
                deviceClearButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ////////

        Rectangle {
            width: parent.width; height: 1;
            color: Theme.colorSeparator
            visible: (actionLed.visible || actionWatering.visible || actionGraphMode.visible)
        }

        ActionButton {
            id: actionLed
            index: 4
            button_text: qsTr("Blink LED")
            button_source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasLED))
            onButtonClicked: {
                deviceLedButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionButton {
            id: actionWatering
            index: 1
            button_text: qsTr("Watering")
            button_source: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasWaterTank))
            onButtonClicked: {
                deviceWateringButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionButton {
            id: actionGraphMode
            index: 5
            button_text: qsTr("Switch graph")
            button_source: (settingsManager.graphThermometer === "minmax") ? "qrc:/assets/icons_material/duotone-insert_chart-24px.svg" : "qrc:/assets/icons_material/baseline-timeline-24px.svg"
            visible: (appContent.state === "DeviceThermometer")
            onButtonClicked: {
                if (settingsManager.graphThermometer === "minmax") settingsManager.graphThermometer = "lines"
                else settingsManager.graphThermometer = "minmax"
                menuSelected(index)
                close()
            }
        }

        ActionButton {
            id: actionCalibrate
            index: 6
            button_text: qsTr("Calibrate sensor")
            button_source: "qrc:/assets/icons_material/duotone-model_training-24px.svg"
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasCalibration))
            onButtonClicked: {
                deviceCalibrateButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionButton {
            id: actionReboot
            index: 7
            button_text: qsTr("Reboot sensor")
            button_source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasReboot))
            onButtonClicked: {
                deviceRebootButtonClicked()
                menuSelected(index)
                close()
            }
        }
    }
}
