import QtQuick 2.15
import QtQuick.Controls 2.15

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
            contentWidth: singleColumn ? -1 : plantScreen.width
            contentHeight: singleColumn ? plantScreen.height : -1

            function setPlant() {
                plantScreen.currentPlant = currentDevice.plant
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
