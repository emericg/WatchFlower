import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Item {
    id: plantCareInfos

    function load() {
        if (currentDevice.hasPlant) {
            plantScreenLoader.active = true
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

        active: false
        visible: currentDevice.hasPlant

        asynchronous: true
        sourceComponent: Flickable {
            anchors.fill: parent
        }
    }
}
