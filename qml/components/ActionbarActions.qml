import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: actionbarActions
    anchors.left: parent.left
    anchors.right: parent.right

    height: 52
    clip: true
    color: Theme.colorSeparator

    ////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////

    Row { // row left
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        ButtonCompactable {
            id: buttonRefreshAll
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            enabled: (deviceManager.bluetooth && !deviceManager.syncing)

            text: qsTr("Refresh sensor data")
            tooltipText: text
            source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Qt.darker(Theme.colorSeparator, 1.1)

            onClicked: refreshButtonClicked()

            animation: {
                if (deviceManager.updating && deviceManager.listening) return "both"
                if (deviceManager.updating) return "rotate"
                if (deviceManager.listening) return "fade"
                return ""
            }
            animationRunning: (deviceManager.updating || deviceManager.listening)
        }
        ButtonCompactable {
            id: buttonSyncAll
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            enabled: (deviceManager.bluetooth && !deviceManager.scanning)

            text: qsTr("Sync sensors history")
            tooltipText: text
            source: "qrc:/assets/icons_custom/duotone-date_all-24px.svg"
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Qt.darker(Theme.colorSeparator, 1.1)

            onClicked: syncButtonClicked()

            animation: "fade"
            animationRunning: deviceManager.syncing
        }
        ButtonCompactable {
            id: buttonScan
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            enabled: (deviceManager.bluetooth && !deviceManager.syncing)

            text: qsTr("Search for new sensors")
            tooltipText: text
            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Qt.darker(Theme.colorSeparator, 1.1)

            onClicked: scanButtonClicked()

            animation: "fade"
            animationRunning: deviceManager.scanning
        }
    }

    Row { // row right
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        ButtonWireframeIcon {
            id: buttonSort
            anchors.verticalCenter: parent.verticalCenter

            height: 36
            layoutDirection: Qt.RightToLeft

            source: "qrc:/assets/icons_material/baseline-filter_list-24px.svg"
            primaryColor: Qt.darker(Theme.colorSeparator, 1.1)
            fullColor: true

            text: {
                var txt = qsTr("Order by:") + " "
                if (settingsManager.orderBy === "waterlevel") {
                    txt += qsTr("water level")
                } else if (settingsManager.orderBy === "plant") {
                    txt += qsTr("plant name")
                } else if (settingsManager.orderBy === "model") {
                    txt += qsTr("sensor model")
                } else if (settingsManager.orderBy === "location") {
                    txt += qsTr("location")
                }
                return txt
            }

            Component.onCompleted: buttonSort.setText()
            Connections {
                target: settingsManager
                function onOrderByChanged() { buttonSort.setText() }
                function onAppLanguageChanged() { buttonSort.setText() }
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
    }

    ////////////////
}
