import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: indicatorsFilled
    width: parent.width
    height: columnData.height + 16
    z: 5

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateData() >> " + currentDevice)

        // Has data? always display them
        if (currentDevice.isAvailable()) {
            hygro.visible = (currentDevice.deviceConductivity > 0 || currentDevice.deviceHumidity > 0)
            lumi.visible = currentDevice.hasLuminositySensor()
            condu.visible = (currentDevice.deviceConductivity > 0 || currentDevice.deviceHumidity > 0)
        } else {
            hygro.visible = currentDevice.hasHumiditySensor() || currentDevice.hasSoilMoistureSensor()
            temp.visible = currentDevice.hasTemperatureSensor()
            lumi.visible = currentDevice.hasLuminositySensor()
            condu.visible = currentDevice.hasConductivitySensor()
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
        hygro.value = currentDevice.deviceHumidity
        temp.value = (settingsManager.tempUnit === "F") ? currentDevice.deviceTempF : currentDevice.deviceTempC
        lumi.value = currentDevice.deviceLuminosity
        condu.value = currentDevice.deviceConductivity
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: columnData
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        spacing: 14
        visible: (currentDevice.available || currentDevice.hasData())

        ItemDataBarFilled {
            id: hygro
            width: parent.width

            legend: currentDevice.hasSoilMoistureSensor() ? qsTr("Moisture") : qsTr("Humidity")
            suffix: "%"
            warning: true
            colorForeground: Theme.colorBlue
            //colorBackground: Theme.colorBackground

            value: currentDevice.deviceHumidity
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(currentDevice.hygroMax*1.10) : 50
            limitMin: currentDevice.limitHygroMin
            limitMax: currentDevice.limitHygroMax
        }

        ItemDataBarFilled {
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

            value: tempHelper(currentDevice.deviceTemp)
            valueMin: tempHelper(settingsManager.dynaScale ? Math.floor(currentDevice.tempMin*0.80) : tempHelper(0))
            valueMax: tempHelper(settingsManager.dynaScale ? (currentDevice.tempMax*1.20) : tempHelper(40))
            limitMin: tempHelper(currentDevice.limitTempMin)
            limitMax: tempHelper(currentDevice.limitTempMax)
        }

        ItemDataBarFilled {
            id: lumi
            width: parent.width

            legend: qsTr("Luminosity")
            suffix: " lux"
            colorForeground: Theme.colorYellow
            //colorBackground: Theme.colorBackground

            value: currentDevice.deviceLuminosity
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(currentDevice.lumiMax*1.10) : 10000
            limitMin: currentDevice.limitLumiMin
            limitMax: currentDevice.limitLumiMax
        }

        ItemDataBarFilled {
            id: condu
            width: parent.width

            legend: qsTr("Fertility")
            suffix: " µS/cm"
            colorForeground: Theme.colorRed
            //colorBackground: Theme.colorBackground

            value: currentDevice.deviceConductivity
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(currentDevice.conduMax*1.10) : 2000
            limitMin: currentDevice.limitConduMin
            limitMax: currentDevice.limitConduMax
        }
    }
}
