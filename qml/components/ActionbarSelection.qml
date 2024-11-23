import QtQuick
import QtQuick.Controls

import ComponentLibrary

Rectangle {
    id: actionbarSelection
    anchors.left: parent.left
    anchors.right: parent.right

    height: (screenDeviceList.selectionCount) ? 52 : 0
    Behavior on height { NumberAnimation { duration: 133 } }

    clip: true
    visible: (height > 0)
    color: Theme.colorActionbar

    ////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////

    Row { // row left
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        RoundButtonIcon {
            id: buttonClear
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/IconLibrary/material-symbols/backspace-fill.svg"
            sourceRotation: 180
            iconColor: Theme.colorActionbarContent
            backgroundColor: Theme.colorActionbarHighlight
            onClicked: screenDeviceList.exitSelectionMode()
        }

        Text {
            id: textActions
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("%n device(s) selected", "", screenDeviceList.selectionCount)
            textFormat: Text.PlainText
            color: Theme.colorActionbarContent
            font.bold: true
            font.pixelSize: Theme.componentFontSize
        }
    }

    Row { // row right
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ButtonCompactable {
            id: buttonDelete
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: !wideMode
            iconColor: Theme.colorActionbarContent
            backgroundColor: Theme.colorActionbarHighlight
            onClicked: confirmDeleteDevice.open()

            text: qsTr("Delete")
            source: "qrc:/IconLibrary/material-symbols/delete.svg"
        }

        ButtonCompactable {
            id: buttonSync
            height: !wideMode ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter
            visible: deviceManager.bluetooth

            compact: !wideMode
            iconColor: Theme.colorActionbarContent
            backgroundColor: Theme.colorActionbarHighlight
            onClicked: screenDeviceList.syncSelectedDevice()

            text: qsTr("Synchronize history")
            source: "qrc:/IconLibrary/material-icons/duotone/date_range.svg"
        }

        ButtonCompactable {
            id: buttonRefresh
            height: !wideMode ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter
            visible: deviceManager.bluetooth

            compact: !wideMode
            iconColor: Theme.colorActionbarContent
            backgroundColor: Theme.colorActionbarHighlight
            onClicked: screenDeviceList.updateSelectedDevice()

            text: qsTr("Refresh")
            source: "qrc:/IconLibrary/material-symbols/refresh.svg"
        }
    }

    ////////////////
}
