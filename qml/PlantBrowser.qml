import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ComponentLibrary
import WatchFlower

Loader {
    id: plantBrowser
    anchors.fill: parent

    property string entryPoint: "DeviceList"

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load the data
        plantDatabase.load()
        plantDatabase.filter("")

        if (status === Loader.Ready) {
            // reset state
            item.resetPlantClicked()
            item.focusSearchBox()
        } else {
            // load the plant browser
            active = true
        }

        // change screen
        appContent.state = "PlantBrowser"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        loadScreen()
    }

    function backAction() {
        if (status === Loader.Ready) {
            item.backAction()
        }
    }

    function forwardAction() {
        if (status === Loader.Ready) {
            item.forwardAction()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ItemLoadData {
        id: loadingIndicator
        visible: (plantBrowser.status !== Loader.Ready)
    }

    active: false
    asynchronous: true

    sourceComponent: Item {
        function backAction() {
            if (isPlantClicked()) {
                itemPlantBrowser.visible = true
                itemPlantBrowser.enabled = true
                itemPlantViewer.visible = false
                itemPlantViewer.enabled = false
                return
            }

            if (plantSearchBox.focus) {
                plantSearchBox.focus = false
                return
            }

            appContent.state = entryPoint
        }

        function forwardAction() {
            if (appContent.state === "PlantBrowser") {
                if (typeof plantScreen.currentPlant !== "undefined" && plantScreen.currentPlant) {
                    plantSearchBox.focus = false
                    itemPlantBrowser.visible = false
                    itemPlantBrowser.enabled = false
                    itemPlantViewer.visible = true
                    itemPlantViewer.enabled = true
                }
            } else {
                appContent.state = "PlantBrowser"
                focusSearchBox()
            }
        }

        function isPlantClicked() {
            if (itemPlantViewer.visible) return true
            return false
        }

        function resetPlantClicked() {
            plantScreen.currentPlant = null
            plantSearchBox.text = ""
            plantSearchBox.focus = false
            itemPlantBrowser.visible = true
            itemPlantBrowser.enabled = true
            itemPlantViewer.visible = false
            itemPlantViewer.enabled = false
            itemPlantViewer.contentY = 0
        }

        function focusSearchBox() {
            // Search focus is set on desktop
            if (isDesktop) {
                plantSearchBox.focus = true
            }
        }

        Component.onCompleted: {
            focusSearchBox()
        }

        ////////////////

        Item {
            id: itemPlantBrowser
            anchors.fill: parent

            Rectangle {
                id: plantSearchArea
                anchors.left: parent.left
                anchors.right: parent.right

                height: plantSearchBox.height + Theme.componentMargin*2
                color: Theme.colorBackground
                z: 4

                TextFieldThemed {
                    id: plantSearchBox
                    anchors.top: parent.top
                    anchors.topMargin: Theme.componentMargin
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    z: 5
                    height: 40
                    placeholderText: qsTr("Search for plants")
                    selectByMouse: true
                    colorSelectedText: "white"

                    onDisplayTextChanged: plantDatabase.filter(displayText)

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.componentMargin

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("%1 plants").arg(((plantSearchBox.displayText) ? plantDatabase.plantCountFiltered : plantDatabase.plantCount))
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorSubText
                        }

                        RoundButtonIcon {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter

                            visible: plantSearchBox.text.length
                            highlightMode: "color"
                            source: "qrc:/IconLibrary/material-symbols/backspace-fill.svg"

                            onClicked: plantSearchBox.text = ""
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
            }

            ListView {
                id: plantList
                anchors.fill: parent
                anchors.topMargin: plantSearchArea.height
                anchors.leftMargin: 0
                anchors.rightMargin: 0

                topMargin: 0
                bottomMargin: 0
                spacing: 0

                ScrollBar.vertical: ScrollBar {
                    visible: true
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    policy: ScrollBar.AsNeeded
                }

                Component.onCompleted: {
                    if (isMobile) {
                        maximumFlickVelocity *= 1.5
                    }
                }

                model: plantDatabase.plantsFiltered
                delegate: Rectangle {
                    width: ListView.view.width
                    height: 40

                    color: (index % 2) ? Theme.colorForeground :Theme.colorBackground

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.componentMargin

                        Text {
                            text: modelData.name
                            color: Theme.colorText
                            fontSizeMode: Text.Fit
                            font.pixelSize: Theme.fontSizeContent
                            minimumPixelSize: Theme.fontSizeContentSmall
                        }
                        Text {
                            visible: modelData.nameCommon
                            text: "« " + modelData.nameCommon + " »"
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            fontSizeMode: Text.Fit
                            font.pixelSize: Theme.fontSizeContent
                            minimumPixelSize: Theme.fontSizeContentSmall
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            plantScreen.currentPlant = modelData
                            plantSearchBox.focus = false

                            itemPlantBrowser.visible = false
                            itemPlantBrowser.enabled = false
                            itemPlantViewer.visible = true
                            itemPlantViewer.enabled = true
                            itemPlantViewer.contentX = 0
                            itemPlantViewer.contentY = 0
                        }
                    }
                }

                ItemNoPlants {
                    visible: (plantList.count <= 0)
                }
            }
        }

        ////////////////////////////////////////////////////////////////////

        Flickable {
            id: itemPlantViewer
            anchors.fill: parent
            anchors.topMargin: plantSelector_desktop.visible ? plantSelector_desktop.height : 0
            anchors.bottomMargin: plantSelector_mobile.visible ? plantSelector_mobile.height : 0

            visible: false

            // 1: single column (single column view or portrait tablet)
            // 2: wide mode (wide view)
            property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

            contentWidth: (uiMode === 1) ? -1 : plantScreen.width
            contentHeight: (uiMode === 1) ? plantScreen.height : -1

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            function setPlant() {
                plantScreen.currentPlant = currentDevice.plant

                if (typeof itemPlantViewer !== "undefined" && itemPlantViewer) {
                    itemPlantViewer.contentX = 0
                    itemPlantViewer.contentY = 0
                }
            }

            PlantScreen {
                id: plantScreen
            }
        }

        ////////////////////////////////////////////////////////////////////

        Rectangle {
            id: plantSelector_desktop
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            z: 5
            height: 52
            color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

            visible: (!singleColumn &&
                      appContent.state === "PlantBrowser" &&
                      screenPlantBrowser.entryPoint === "DevicePlantSensor" &&
                      isPlantClicked())

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("You are previewing a plant.")
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: 22
            }

            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                ButtonFlat {
                    height: 36

                    Layout.fillWidth: true
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 320

                    text: qsTr("Choose this plant")
                    source: "qrc:/IconLibrary/material-symbols/check_circle.svg"

                    onClicked: {
                         selectedDevice.setPlantName(plantScreen.currentPlant.name)
                         appContent.state = "DevicePlantSensor"
                    }
                }
                ButtonFlat {
                    height: 36

                    Layout.fillWidth: false

                    text: qsTr("Cancel")

                    onClicked: {
                        appContent.state = "DevicePlantSensor"
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: (isDesktop && !headerUnicolor)
                height: 2
                opacity: 0.5
                color: Theme.colorSeparator
            }
        }

        ////////

        Rectangle {
            id: plantSelector_mobile
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            z: 5
            height: 52
            color: Theme.colorForeground
            visible: (singleColumn &&
                      appContent.state === "PlantBrowser" &&
                      screenPlantBrowser.entryPoint === "DevicePlantSensor" &&
                      isPlantClicked())

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ButtonFlat {
                    height: 36

                    Layout.fillWidth: true
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 999

                    text: qsTr("Choose this plant")
                    source: "qrc:/IconLibrary/material-symbols/check_circle.svg"

                    onClicked: {
                        selectedDevice.setPlantName(plantScreen.currentPlant.name)
                        appContent.state = "DevicePlantSensor"
                    }
                }
                ButtonFlat {
                    height: 36

                    color: Theme.colorSubText
                    Layout.fillWidth: false

                    text: qsTr("Cancel")

                    onClicked: {
                        appContent.state = "DevicePlantSensor"
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////
    }
}
