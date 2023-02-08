import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Item {
    id: plantCareInfos

    function load() {
        if (currentDevice.hasPlant) {
            if (plantScreenLoader.status !== Loader.Ready)
                plantScreenLoader.active = true
            else
                plantScreenLoader.item.setPlant()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ItemNoPlant {
        visible: !currentDevice.hasPlant
        onClicked: {
            plantScreenLoader.active = true
            screenPlantBrowser.loadScreenFrom("DevicePlantSensor")
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: plantScreenLoader
        anchors.fill: parent

        visible: currentDevice.hasPlant

        Connections {
            target: currentDevice
            function onPlantChanged() {
                if (currentDevice.hasPlant) {
                    if (plantScreenLoader.status === Loader.Ready)
                        plantScreenLoader.item.setPlant(currentDevice.plant)
                }
            }
        }
        onLoaded: {
            plantScreenLoader.item.setPlant(currentDevice.plant)
        }

        active: false
        asynchronous: true

        sourceComponent: Flickable {
            id: itemPlantViewer
            contentWidth: (uiMode === 1) ? -1 : plantScreen.width
            contentHeight: (uiMode === 1) ? plantScreen.height : -1

            // 1: single column (single column view or portrait tablet)
            // 2: wide mode (wide view or landscape tablet)
            property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

            function setPlant() {
                plantScreen.currentPlant = currentDevice.plant

                if (typeof itemPlantViewer !== "undefined" || itemPlantViewer) {
                    itemPlantViewer.contentX = 0
                    itemPlantViewer.contentY = 0
                }
            }

            PlantScreen {
                id: plantScreen
                //anchors.left: parent.left
                //anchors.right: parent.right

                parentHeight: parent.height

                visible: true
            }
        }
    }
}
