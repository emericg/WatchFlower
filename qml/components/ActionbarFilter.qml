import QtQuick
import QtQuick.Controls

import ComponentLibrary
import WatchFlower

Rectangle {
    id: actionbarFilter
    anchors.left: parent.left
    anchors.right: parent.right

    property bool shown: deviceManager.hasDevices
    property bool singleRow: wideMode

    height: shown ? (content.height + Theme.componentMargin*2) : 0
    visible: shown
    color: Theme.colorBackground

    ////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////

    property string allText: qsTr("All locations")
    property string noneText: qsTr("No location set")
    onAllTextChanged: rebuildLocations()
    onNoneTextChanged: rebuildLocations()

    function rebuildLocations() {
        var names = deviceManager.locationNames

        locationModel.clear()
        locationModel.append({ "text": allText })
        for (var i = 0; i < names.length; i++) {
            locationModel.append({ "text": names[i] })
        }
        locationModel.append({ "text": noneText })

        syncLocationIndex()
    }

    function syncLocationIndex() {
        if (deviceManager.filterNoLocation) {
            locationCombo.currentIndex = locationModel.count - 1
        } else if (deviceManager.filterLocation.length) {
            locationCombo.currentIndex = deviceManager.locationNames.indexOf(deviceManager.filterLocation) + 1
        } else {
            locationCombo.currentIndex = 0
        }
    }

    Component.onCompleted: {
        searchField.text = deviceManager.filterText
        rebuildLocations()
    }

    Connections {
        target: deviceManager
        function onLocationNamesChanged() { actionbarFilter.rebuildLocations() }
        function onFilterChanged() {
            // compare with displayText, so we never overwrite an ongoing input method composition
            if (searchField.displayText !== deviceManager.filterText) searchField.text = deviceManager.filterText
            actionbarFilter.syncLocationIndex()
        }
    }

    ////////////////

    Grid { // single row on wide screens, stacked on narrow ones
        id: content
        anchors.top: parent.top
        anchors.topMargin: Theme.componentMargin
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin

        columns: actionbarFilter.singleRow ? 2 : 1
        spacing: Theme.componentMargin / 2

        TextFieldThemed {
            id: searchField
            width: (actionbarFilter.singleRow && locationCombo.visible) ?
                       (content.width - locationCombo.width - content.spacing) : content.width
            height: 40

            rightPadding: searchIcons.width + Theme.componentMargin*2
            placeholderText: qsTr("Search sensors")
            selectByMouse: true
            colorSelectedText: "white"

            onDisplayTextChanged: deviceManager.filterText = displayText

            Row {
                id: searchIcons
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMargin

                RoundButtonIcon {
                    width: 28
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter

                    visible: searchField.displayText.length
                    highlightMode: "color"
                    source: "qrc:/IconLibrary/material-symbols/backspace-fill.svg"

                    onClicked: searchField.text = ""
                }

                IconSvg {
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/IconLibrary/material-symbols/search.svg"
                    color: Theme.colorText
                }
            }
        }

        ComboBoxThemed {
            id: locationCombo
            width: actionbarFilter.singleRow ? Math.min(220, content.width * 0.4) : content.width
            height: 40

            visible: (deviceManager.locationNames.length > 0 || deviceManager.filterNoLocation)
            wheelEnabled: false

            model: ListModel { id: locationModel }
            textRole: "text"

            onActivated: (index) => {
                if (index <= 0) deviceManager.setFilterLocation("", false)
                else if (index === locationModel.count - 1) deviceManager.setFilterLocation("", true)
                else deviceManager.setFilterLocation(locationModel.get(index).text, false)
            }
        }
    }

    ////////////////
}
