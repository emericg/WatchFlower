import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Popup {
    id: actionMenu

    implicitWidth: 200
    implicitHeight: contentColumn.height

    padding: 0
    margins: 0

    modal: true
    dim: false
    focus: isMobile
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside
    parent: Overlay.overlay

    property bool partonevisible: (actionUpdate.visible || actionRealtime.visible)
    property bool parttwovisible: (actionHistoryRefresh.visible || actionHistoryClear.visible)
    property bool partthreevisible: (actionLed.visible || actionWatering.visible || actionGraphMode.visible || actionShowSettings.visible)

    property int layoutDirection: Qt.RightToLeft

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        radius: Theme.componentRadius
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Column {
            id: contentColumn
            width: parent.width

            topPadding: 8
            bottomPadding: 8
            spacing: 4

            ////////

            ActionMenuItem {
                id: actionUpdate
                width: parent.width

                index: 0
                text: qsTr("Update data")
                source: "qrc:/assets/icons/material-symbols/refresh.svg"
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasBluetoothConnection))

                onClicked: {
                    deviceRefreshButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem {
                id: actionRealtime
                width: parent.width

                index: 1
                text: qsTr("Real time data")
                source: "qrc:/assets/icons/material-icons/duotone/update.svg"
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasRealTime))

                onClicked: {
                    deviceRefreshRealtimeButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ////////

            ListSeparatorPadded {
                anchors.leftMargin: Theme.componentMargin
                anchors.rightMargin: Theme.componentMargin
                height: 9
                visible: (partonevisible && parttwovisible)
            }

            ActionMenuItem {
                id: actionHistoryRefresh
                width: parent.width

                index: 2
                text: qsTr("Update history")
                source: "qrc:/assets/icons/material-icons/duotone/date_range.svg"
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
                width: parent.width

                index: 3
                text: qsTr("Clear history")
                source: "qrc:/assets/icons/material-icons/duotone/date_clear.svg"
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))

                onClicked: {
                    deviceClearButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ////////

            ListSeparatorPadded {
                anchors.leftMargin: Theme.componentMargin
                anchors.rightMargin: Theme.componentMargin
                height: 9
                visible: ((partonevisible || parttwovisible) && partthreevisible)
            }

            ActionMenuItem {
                id: actionLed
                width: parent.width

                index: 8
                text: qsTr("Blink LED")
                source: "qrc:/assets/icons/material-icons/duotone/emoji_objects.svg"
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
                width: parent.width

                index: 9
                text: qsTr("Watering")
                source: "qrc:/assets/icons/material-icons/duotone/local_drink.svg"
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasWaterTank))

                onClicked: {
                    deviceWateringButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem {
                id: actionCalibrate
                width: parent.width

                index: 10
                text: qsTr("Calibrate sensor")
                source: "qrc:/assets/icons/material-icons/duotone/model_training.svg"
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasCalibration))

                onClicked: {
                    deviceCalibrateButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem {
                id: actionGraphMode
                width: parent.width

                index: 16
                text: qsTr("Switch graph")
                layoutDirection: actionMenu.layoutDirection
                visible: (appContent.state === "DeviceThermometer")
                source: (settingsManager.graphThermometer === "minmax") ?
                            "qrc:/assets/icons/material-icons/duotone/insert_chart.svg" :
                            "qrc:/assets/icons/material-symbols/timeline.svg"

                onClicked: {
                    if (settingsManager.graphThermometer === "minmax") settingsManager.graphThermometer = "lines"
                    else settingsManager.graphThermometer = "minmax"
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem {
                id: actionShowSettings
                width: parent.width

                index: 17
                text: qsTr("Sensor infos")
                source: "qrc:/assets/icons/material-icons/duotone/memory.svg"
                layoutDirection: actionMenu.layoutDirection
                visible: (appContent.state === "DeviceThermometer" || appContent.state === "DeviceEnvironmental")

                onClicked: {
                    deviceSettingsButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem {
                id: actionReboot
                width: parent.width

                index: 32
                text: qsTr("Reboot sensor")
                source: "qrc:/assets/icons/material-symbols/refresh.svg"
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

    ////////////////////////////////////////////////////////////////////////////
}
