import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Popup {
    id: actionMenu

    width: appWindow.width
    height: actualHeight

    y: appWindow.height - actualHeight

    padding: 0
    margins: 0

    modal: true
    dim: true
    focus: appWindow.isMobile
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside
    parent: T.Overlay.overlay

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    property int layoutDirection: Qt.RightToLeft

    property int actualHeight: {
        if (typeof mobileMenu !== "undefined" && mobileMenu.height)
            return contentColumn.height + appWindow.screenPaddingNavbar + appWindow.screenPaddingBottom
        return contentColumn.height
    }

    property bool opening: false
    property bool closing: false

    onAboutToShow: {
        opening = true
        closing = false
    }
    onAboutToHide: {
        opening = false
        closing = true
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 233; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.66; duration: 233; } }

    T.Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.24 : 0.48
    }

    background: Item { }

    contentItem: Item { }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: actualPopup
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: opening ? actionMenu.actualHeight : 0
        Behavior on height { NumberAnimation { duration: 233 } }

        color: Theme.colorComponentBackground

        Rectangle { // separator
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.componentBorderWidth
            color: Theme.colorSeparator
        }

        Column { // content
            id: contentColumn
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: screenPaddingLeft
            anchors.right: parent.right
            anchors.rightMargin: screenPaddingRight

            topPadding: Theme.componentMargin
            bottomPadding: 8
            spacing: 4

            property bool partonevisible: (actionUpdate.visible || actionRealtime.visible)
            property bool parttwovisible: (actionHistoryRefresh.visible || actionHistoryClear.visible)
            property bool partthreevisible: (actionLed.visible || actionWatering.visible || actionGraphMode.visible || actionShowSettings.visible)

            ////////

            ActionMenuItem {
                id: actionUpdate
                anchors.left: parent.left
                anchors.right: parent.right
                index: 1

                text: qsTr("Update data")
                source: "qrc:/IconLibrary/material-symbols/refresh.svg"
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
                index: 2

                text: qsTr("Real time data")
                source: "qrc:/IconLibrary/material-icons/duotone/update.svg"
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
                index: 3

                text: qsTr("Update history")
                source: "qrc:/IconLibrary/material-icons/duotone/date_range.svg"
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
                index: 4

                text: qsTr("Clear history")
                source: "qrc:/IconLibrary/material-icons/duotone/date_clear.svg"
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
                index: 8

                text: qsTr("Blink LED")
                source: "qrc:/IconLibrary/material-icons/duotone/emoji_objects.svg"
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
                index: 9

                text: qsTr("Watering")
                source: "qrc:/IconLibrary/material-icons/duotone/local_drink.svg"
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
                index: 10

                text: qsTr("Calibrate sensor")
                source: "qrc:/IconLibrary/material-icons/duotone/model_training.svg"
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
                index: 16

                text: qsTr("Switch graph")
                layoutDirection: actionMenu.layoutDirection
                visible: (appContent.state === "DeviceThermometer")
                source: (settingsManager.graphThermometer === "minmax") ?
                            "qrc:/IconLibrary/material-icons/duotone/insert_chart.svg" :
                            "qrc:/IconLibrary/material-symbols/timeline.svg"

                onClicked: {
                    if (settingsManager.graphThermometer === "minmax") settingsManager.graphThermometer = "lines"
                    else settingsManager.graphThermometer = "minmax"
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem {
                id: actionShowSettings
                index: 17

                text: qsTr("Sensor infos")
                source: "qrc:/IconLibrary/material-icons/duotone/memory.svg"
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
                index: 32

                text: qsTr("Reboot sensor")
                source: "qrc:/IconLibrary/material-symbols/refresh.svg"
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasReboot))

                onClicked: {
                    deviceRebootButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
