import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: indicatorsCompact
    width: parent.width
    height: columnData.height + 16
    z: 5

    function updateData() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateData() >> " + myDevice)

        // Has data? always display them
        if (myDevice.isAvailable()) {
            hygro.visible = (myDevice.deviceConductivity > 0 || myDevice.deviceHumidity > 0)
            lumi.visible = myDevice.hasLuminositySensor()
            condu.visible = (myDevice.deviceConductivity > 0 || myDevice.deviceHumidity > 0)
        } else {
            hygro.visible = myDevice.hasHumiditySensor() || myDevice.hasSoilMoistureSensor()
            temp.visible = myDevice.hasTemperatureSensor()
            lumi.visible = myDevice.hasLuminositySensor()
            condu.visible = myDevice.hasConductivitySensor()
        }

        resetDataBars()
    }

    function updateDataBars(tempD, lumiD, hygroD, conduD) {
        temp.value = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempD) : tempD
        hygro.value = hygroD
        lumi.value = lumiD
        condu.value = conduD
    }

    function resetDataBars() {
        hygro.value = myDevice.deviceHumidity
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
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        spacing: 12
        visible: (myDevice.available || myDevice.hasData())

        ItemDataBarCompact {
            id: hygro
            width: parent.width

            legend: myDevice.hasSoilMoistureSensor() ? qsTr("Moisture") : qsTr("Humidity")
            suffix: "%"
            warning: true
            colorForeground: Theme.colorBlue
            //colorBackground: Theme.colorBackground

            value: myDevice.deviceHumidity
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(myDevice.hygroMax*1.10) : 50
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

            function tempHelper(tempDeg) {
                return (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempDeg) : tempDeg
            }

            value: tempHelper(myDevice.deviceTemp)
            valueMin: tempHelper(settingsManager.dynaScale ? Math.floor(myDevice.tempMin*0.80) : tempHelper(0))
            valueMax: tempHelper(settingsManager.dynaScale ? Math.ceil(myDevice.tempMax*1.20) : tempHelper(40))
            limitMin: tempHelper(myDevice.limitTempMin)
            limitMax: tempHelper(myDevice.limitTempMax)
        }

        ItemDataBarCompact {
            id: lumi
            width: parent.width

            legend: qsTr("Luminosity")
            suffix: " lux"
            colorForeground: Theme.colorYellow
            //colorBackground: Theme.colorBackground

            value: myDevice.deviceLuminosity
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(myDevice.lumiMax*1.10) : 10000
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
            valueMax: settingsManager.dynaScale ? Math.ceil(myDevice.conduMax*1.10) : 2000
            limitMin: myDevice.limitConduMin
            limitMax: myDevice.limitConduMax
        }
    }
}
