import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: indicatorsSolid
    width: parent.width
    height: columnData.height + 24
    z: 5

    property string colorBackground: (uiMode === 2) ? Theme.colorBackground : Theme.colorForeground

    property int legendWidth: 92
    Component.onCompleted: updateSize()

    function updateSize() {
        legendWidth = 0
        if (legendWidth < soil_moisture.legendContentWidth) legendWidth = soil_moisture.legendContentWidth
        if (legendWidth < soil_conductivity.legendContentWidth) legendWidth = soil_conductivity.legendContentWidth
        if (legendWidth < soil_temperature.legendContentWidth) legendWidth = soil_temperature.legendContentWidth
        if (legendWidth < temp.legendContentWidth) legendWidth = temp.legendContentWidth
        if (legendWidth < humi.legendContentWidth) legendWidth = humi.legendContentWidth
        if (legendWidth < lumi.legendContentWidth) legendWidth = lumi.legendContentWidth
        if (legendWidth < water_tank.legendContentWidth) legendWidth = water_tank.legendContentWidth
    }

    ////////////////////////////////////////////////////////////////////////////

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DevicePlantSensorData // updateData() >> " + currentDevice)

        // Has data? always display them
        if (currentDevice.isAvailable()) {
            var hasHygro_short = (currentDevice.deviceSoilMoisture > 0 || currentDevice.deviceSoilConductivity > 0)
            var hasHygro_long = (currentDevice.hasData("soilMoisture") || currentDevice.hasData("soilConductivity"))

            soil_moisture.visible = hasHygro_long
            soil_conductivity.visible = hasHygro_long
            soil_temperature.visible = currentDevice.hasSoilTemperatureSensor()
            temp.visible = currentDevice.hasTemperatureSensor()
            humi.visible = currentDevice.hasHumiditySensor()
            lumi.visible = currentDevice.hasLuminositySensor()
            water_tank.visible = currentDevice.hasWaterLevelSensor()
        } else {
            soil_moisture.visible = currentDevice.hasHumiditySensor() || currentDevice.hasSoilMoistureSensor()
            soil_conductivity.visible = currentDevice.hasSoilConductivitySensor()
            soil_temperature.visible = currentDevice.hasSoilTemperatureSensor()
            temp.visible = currentDevice.hasTemperatureSensor()
            humi.visible = currentDevice.hasHumiditySensor()
            lumi.visible = currentDevice.hasLuminositySensor()
            water_tank.visible = currentDevice.hasWaterLevelSensor()
        }

        resetDataBars()
    }

    function updateDataBars(soilM, soilC, soilT, tempD, humiD, lumiD) {
        soil_moisture.value = soilM
        soil_conductivity.value = soilC
        soil_temperature.value = soilT
        temp.value = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempD) : tempD
        humi.value = humiD
        lumi.value = lumiD
        water_tank.value =  -99

        soil_moisture.warning = false
        temp.warning = false
        water_tank.warning = false
    }

    function resetDataBars() {
        soil_moisture.value = currentDevice.deviceSoilMoisture
        soil_conductivity.value = currentDevice.deviceSoilConductivity
        soil_temperature.value = currentDevice.deviceSoilTemperature
        temp.value = (settingsManager.tempUnit === "F") ? currentDevice.deviceTempF : currentDevice.deviceTempC
        humi.value = currentDevice.deviceHumidity
        lumi.value = currentDevice.deviceLuminosity
        water_tank.value = currentDevice.waterTankLevel

        soil_moisture.warning = true
        temp.warning = true
        water_tank.warning = true
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: columnData
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 0

        spacing: 14

        ////////

        DataBarSolid {
            id: soil_moisture
            width: parent.width

            legend: qsTr("Moisture")
            legendWidth: indicatorsSolid.legendWidth
            suffix: "%"
            warning: true
            colorForeground: Theme.colorBlue
            colorBackground: indicatorsSolid.colorBackground

            value: currentDevice.deviceSoilMoisture
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(currentDevice.hygroMax*1.10) : 50
            limitMin: currentDevice.limitHygroMin
            limitMax: currentDevice.limitHygroMax
        }

        ////////

        DataBarSolid {
            id: temp
            width: parent.width

            legend: qsTr("Temperature")
            legendWidth: indicatorsSolid.legendWidth
            warning: true
            suffix: "°" + settingsManager.tempUnit
            colorForeground: Theme.colorGreen
            colorBackground: indicatorsSolid.colorBackground

            function tempHelper(tempDeg) {
                return (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempDeg) : tempDeg
            }

            value: tempHelper(currentDevice.deviceTemp)
            floatprecision: 1
            valueMin: tempHelper(settingsManager.dynaScale ? Math.floor(currentDevice.tempMin*0.80) : tempHelper(0))
            valueMax: tempHelper(settingsManager.dynaScale ? (currentDevice.tempMax*1.20) : tempHelper(40))
            limitMin: tempHelper(currentDevice.limitTempMin)
            limitMax: tempHelper(currentDevice.limitTempMax)
        }

        ////////

        DataBarSolid {
            id: humi
            width: parent.width

            legend: qsTr("Humidity")
            legendWidth: indicatorsSolid.legendWidth
            suffix: "%"
            colorForeground: Theme.colorBlue
            colorBackground: indicatorsSolid.colorBackground

            value: currentDevice.deviceHumidity
            valueMin: 0
            valueMax: 100
            limitMin: 0
            limitMax: 100
        }

        ////////

        DataBarSolid {
            id: lumi
            width: parent.width

            legend: qsTr("Luminosity")
            legendWidth: indicatorsSolid.legendWidth
            suffix: " " + qsTr("lux")
            colorForeground: Theme.colorYellow
            colorBackground: indicatorsSolid.colorBackground

            value: currentDevice.deviceLuminosity
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(currentDevice.luxMax*1.10) : 10000
            limitMin: currentDevice.limitLuxMin
            limitMax: currentDevice.limitLuxMax
        }

        ////////

        DataBarSolid {
            id: soil_conductivity
            width: parent.width

            legend: qsTr("Fertility")
            legendWidth: indicatorsSolid.legendWidth
            suffix: " " + qsTr("µS/cm")
            colorForeground: Theme.colorRed
            colorBackground: indicatorsSolid.colorBackground

            value: currentDevice.deviceSoilConductivity
            valueMin: 0
            valueMax: settingsManager.dynaScale ? Math.ceil(currentDevice.conduMax*1.10) : 2000
            limitMin: currentDevice.limitConduMin
            limitMax: currentDevice.limitConduMax
        }

        ////////

        DataBarSolid {
            id: soil_temperature
            width: parent.width

            legend: qsTr("Soil temp.")
            legendWidth: indicatorsSolid.legendWidth
            suffix: "°" + settingsManager.tempUnit
            colorForeground: Theme.colorGreen
            colorBackground: indicatorsSolid.colorBackground

            value: currentDevice.deviceSoilTemperature
            valueMin: tempHelper(settingsManager.dynaScale ? Math.floor(currentDevice.tempMin*0.80) : tempHelper(0))
            valueMax: tempHelper(settingsManager.dynaScale ? (currentDevice.tempMax*1.20) : tempHelper(40))
            limitMin: 0
            limitMax: 0
        }

        ////////

        DataBarSolid {
            id: water_tank
            width: parent.width

            legend: qsTr("Water tank")
            legendWidth: indicatorsSolid.legendWidth
            suffix: "L"
            colorForeground: Theme.colorBlue
            colorBackground: indicatorsSolid.colorBackground

            value: currentDevice.waterTankLevel
            floatprecision: 1
            valueMin: 0
            valueMax: currentDevice.waterTankCapacity
            limitMin: currentDevice.waterTankCapacity * 0.15
            limitMax: currentDevice.waterTankCapacity
        }
    }
}
