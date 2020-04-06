import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Rectangle {
    id: rectangeData
    color: "transparent" // Theme.colorForeground
    width: parent.width
    height: columnData.height + 16
    z: 5

    function updateData() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateData() >> " + myDevice)

        // Has data? always display them
        if (myDevice.isAvailable()) {
            humi.visible = (myDevice.deviceConductivity > 0 || myDevice.deviceHumidity > 0)
            lumi.visible = myDevice.hasLuminositySensor()
            condu.visible = (myDevice.deviceConductivity > 0 || myDevice.deviceHumidity > 0)
        } else {
            humi.visible = myDevice.hasHumiditySensor() || myDevice.hasSoilMoistureSensor()
            temp.visible = myDevice.hasTemperatureSensor()
            lumi.visible = myDevice.hasLuminositySensor()
            condu.visible = myDevice.hasConductivitySensor()
        }

        resetDataBars()
    }

    function updateDataBars(tempD, lumiD, hygroD, conduD) {
        temp.value = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempD) : tempD
        humi.value = hygroD
        lumi.value = lumiD
        condu.value = conduD
    }

    function resetDataBars() {
        humi.value = myDevice.deviceHumidity
        temp.value = (settingsManager.tempUnit === "F") ? myDevice.deviceTempF : myDevice.deviceTempC
        lumi.value = myDevice.deviceLuminosity
        condu.value = myDevice.deviceConductivity
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: columnData
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        spacing: 14
        visible: (myDevice.available || myDevice.hasData())

        ItemDataBarCompact {
            id: humi
            width: parent.width

            legend: myDevice.hasSoilMoistureSensor() ? qsTr("Moisture") : qsTr("Humidity")
            suffix: "%"
            warning: true
            colorForeground: Theme.colorBlue
            //colorBackground: Theme.colorBackground

            value: myDevice.deviceHumidity
            valueMin: 0
            valueMax: 50
            limitMin: myDevice.limitHygroMin
            limitMax: myDevice.limitHygroMax
        }

        ItemDataBarCompact {
            id: temp
            width: parent.width

            legend: qsTr("Temperature")
            floatprecision: 1
            warning: true
            suffix: "°" + settingsManager.tempUnit
            colorForeground: Theme.colorGreen
            //colorBackground: Theme.colorBackground

            value: (settingsManager.tempUnit === "F") ? myDevice.deviceTempF : myDevice.deviceTempC
            valueMin: (settingsManager.tempUnit === "F") ? 32 : 0
            valueMax: (settingsManager.tempUnit === "F") ? 104 : 40
            limitMin: (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(myDevice.limitTempMin) : myDevice.limitTempMin
            limitMax: (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(myDevice.limitTempMax) : myDevice.limitTempMax
        }

        ItemDataBarCompact {
            id: lumi
            width: parent.width

            legend: qsTr("Luminosity")
            suffix: " lumens"
            colorForeground: Theme.colorYellow
            //colorBackground: Theme.colorBackground

            value: myDevice.deviceLuminosity
            valueMin: 0
            valueMax: 10000
            limitMin: myDevice.limitLumiMin
            limitMax: myDevice.limitLumiMax
        }

        ItemDataBarCompact {
            id: condu
            width: parent.width

            legend: qsTr("Fertility")
            suffix: " µS/cm"
            colorForeground: Theme.colorRed
            //colorBackground: Theme.colorBackground

            value: myDevice.deviceConductivity
            valueMin: 0
            valueMax: 500
            limitMin: myDevice.limitConduMin
            limitMax: myDevice.limitConduMax
        }
    }
}
