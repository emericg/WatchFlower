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

    property string titleTxt
    property string titleSrc // disabled

    property int layoutDirection: Qt.RightToLeft

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

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
            bottomPadding: 4
            spacing: 0

            ////////

            property bool partonevisible: (actionUpdate.visible || actionRealtime.visible)
            property bool parttwovisible: (actionHistoryRefresh.visible || actionHistoryClear.visible)
            property bool partthreevisible: (actionLed.visible || actionWatering.visible || actionGraphMode.visible || actionShowSettings.visible)

            ////////

            Text { // title
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin + 4
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin

                height: Theme.componentHeight
                visible: actionMenu.titleTxt

                text: actionMenu.titleTxt
                textFormat: Text.PlainText

                color: Theme.colorSubText
                font.bold: false
                font.pixelSize: Theme.fontSizeContentVeryBig
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            ////////

            ActionMenuItem_button {
                id: actionUpdate
                index: 1

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasBluetoothConnection))

                text: qsTr("Update data")
                source: "qrc:/IconLibrary/material-symbols/refresh.svg"

                onClicked: {
                    deviceRefreshButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem_button {
                id: actionRealtime
                index: 2

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasRealTime))

                text: qsTr("Real time data")
                source: "qrc:/IconLibrary/material-icons/duotone/update.svg"

                onClicked: {
                    deviceRefreshRealtimeButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ////////

            ActionMenuItem_separator {
                anchors.leftMargin: Theme.componentMargin
                anchors.rightMargin: Theme.componentMargin
                visible: (contentColumn.partonevisible && contentColumn.parttwovisible)
            }

            ActionMenuItem_button {
                id: actionHistoryRefresh
                index: 3

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))

                text: qsTr("Update history")
                source: "qrc:/IconLibrary/material-icons/duotone/date_range.svg"

                onClicked: {
                    deviceRefreshHistoryButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem_button {
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

            ActionMenuItem_separator {
                anchors.leftMargin: Theme.componentMargin
                anchors.rightMargin: Theme.componentMargin
                visible: ((contentColumn.partonevisible || contentColumn.parttwovisible) && contentColumn.partthreevisible)
            }

            ActionMenuItem_button {
                id: actionLed
                index: 8

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasLED))

                text: qsTr("Blink LED")
                source: "qrc:/IconLibrary/material-icons/duotone/emoji_objects.svg"

                onClicked: {
                    deviceLedButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem_button {
                id: actionWatering
                index: 9

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasWaterTank))

                text: qsTr("Watering")
                source: "qrc:/IconLibrary/material-icons/duotone/local_drink.svg"

                onClicked: {
                    deviceWateringButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem_button {
                id: actionCalibrate
                index: 10

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasCalibration))

                text: qsTr("Calibrate sensor")
                source: "qrc:/IconLibrary/material-icons/duotone/model_training.svg"

                onClicked: {
                    deviceCalibrateButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem_button {
                id: actionGraphMode
                index: 16

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (appContent.state === "DeviceThermometer")

                text: qsTr("Switch graph")
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

            ActionMenuItem_button {
                id: actionShowSettings
                index: 17

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (appContent.state === "DeviceThermometer" || appContent.state === "DeviceEnvironmental")

                text: qsTr("Sensor infos")
                source: "qrc:/IconLibrary/material-icons/duotone/memory.svg"

                onClicked: {
                    deviceSettingsButtonClicked()
                    menuSelected(index)
                    close()
                }
            }

            ActionMenuItem_button {
                id: actionReboot
                index: 32

                height: Theme.componentHeightL
                layoutDirection: actionMenu.layoutDirection
                visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasReboot))

                text: qsTr("Reboot sensor")
                source: "qrc:/IconLibrary/material-symbols/refresh.svg"

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
