import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Popup {
    id: actionMenu
    width: 200

    padding: 0
    margins: 0

    parent: Overlay.overlay
    modal: true
    dim: false
    focus: isMobile
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

    property int layoutDirection: Qt.RightToLeft

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        radius: Theme.componentRadius
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        topPadding: 8
        bottomPadding: 8
        spacing: 4

        ////////

        ActionMenuItem {
            id: actionUpdate

            index: 0
            text: qsTr("Update data")
            source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && selectedDevice)

            onClicked: {
                deviceRefreshButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionMenuItem {
            id: actionRealtime

            index: 1
            text: qsTr("Real time data")
            source: "qrc:/assets/icons_material/duotone-update-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasRealTime))

            onClicked: {
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

        ActionMenuItem {
            id: actionHistoryRefresh

            index: 2
            text: qsTr("Update history")
            source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))

            onClicked: {
                deviceRefreshHistoryButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionMenuItem {
            id: actionHistoryClear

            index: 3
            text: qsTr("Clear history")
            source: "qrc:/assets/icons_material/duotone-date_clear-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))

            onClicked: {
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

        ActionMenuItem {
            id: actionLed

            index: 5
            text: qsTr("Blink LED")
            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasLED))

            onClicked: {
                deviceLedButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionMenuItem {
            id: actionWatering

            index: 6
            text: qsTr("Watering")
            source: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasWaterTank))

            onClicked: {
                deviceWateringButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionMenuItem {
            id: actionGraphMode

            index: 7
            text: qsTr("Switch graph")
            source: (settingsManager.graphThermometer === "minmax") ? "qrc:/assets/icons_material/duotone-insert_chart-24px.svg" : "qrc:/assets/icons_material/baseline-timeline-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (appContent.state === "DeviceThermometer")

            onClicked: {
                if (settingsManager.graphThermometer === "minmax") settingsManager.graphThermometer = "lines"
                else settingsManager.graphThermometer = "minmax"
                menuSelected(index)
                close()
            }
        }

        ActionMenuItem {
            id: actionCalibrate

            index: 8
            text: qsTr("Calibrate sensor")
            source: "qrc:/assets/icons_material/duotone-model_training-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasCalibration))

            onClicked: {
                deviceCalibrateButtonClicked()
                menuSelected(index)
                close()
            }
        }

        ActionMenuItem {
            id: actionReboot

            index: 9
            text: qsTr("Reboot sensor")
            source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasReboot))

            onClicked: {
                deviceRebootButtonClicked()
                menuSelected(index)
                close()
            }
        }
    }
}
