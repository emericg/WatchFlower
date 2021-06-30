import QtQuick 2.12
import QtQuick.Layouts 1.12

import ThemeEngine 1.0
import "qrc:/js/UtilsDeviceBLE.js" as UtilsDeviceBLE

Item {
    id: devicePlantSensorHistory

    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("DevicePlantSensorHistory // loadData() >> " + currentDevice)

        // graph visibility
        graphCount = 0
        if (currentDevice.hasTemperatureSensor) {
            tempChart.visible = true
            graphCount += 1
        } else {
            tempChart.visible = false
        }
        if (currentDevice.hasHumiditySensor || currentDevice.hasSoilMoistureSensor) {
            if (currentDevice.soilMoisture > 0 || currentDevice.countData("soilMoisture") > 0) {
                hygroChart.visible = true
                graphCount += 1
            } else {
                hygroChart.visible = false
            }
        } else {
            hygroChart.visible = false
        }
        if (currentDevice.hasLuminositySensor) {
            lumiChart.visible = true
            graphCount += 1
        } else {
            lumiChart.visible = false
        }
        if (currentDevice.hasSoilConductivitySensor) {
            if (currentDevice.soilConductivity > 0 || currentDevice.countData("soilConductivity") > 0) {
                conduChart.visible = true
                graphCount += 1
            } else {
                conduChart.visible = false
            }
        } else {
            conduChart.visible = false
        }

        resetHistoryMode()
        updateHistoryMode()

        updateColors()
        updateData()
        updateSize()
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("DevicePlantSensorHistory // updateHeader() >> " + currentDevice)

        // Battery level
        imageBattery.source = UtilsDeviceBLE.getDeviceBatteryIcon(currentDevice.deviceBattery)
        imageBattery.color = UtilsDeviceBLE.getDeviceBatteryColor(currentDevice.deviceBattery)
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("ItemDeviceHistory // updateData() >> " + currentDevice)

        currentDevice.updateChartData_history_month(31)
        currentDevice.updateChartData_history_day()
    }

    function updateHistoryMode() {
        if (settingsManager.graphHistory === "daily") {
            graphGrid.mode = ChartHistory.Span.Daily
        } else if (settingsManager.graphHistory === "weekly") {
            graphGrid.mode = ChartHistory.Span.Weekly
        } else if (settingsManager.graphHistory === "monthly") {
            graphGrid.mode = ChartHistory.Span.Monthly
        }
    }

    function isHistoryMode() {
        return false
    }
    function resetHistoryMode() {
        graphGrid.resetSelection()
    }

    function updateColors() {
        //
    }

    function updateSize() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("width: " + graphGrid.width)
        //console.log("height: " + graphGrid.height)

        // grid geometry
        if (isMobile) {
            if (isPhone) {
                if (screenOrientation === Qt.PortraitOrientation) {
                    graphGrid.columns = 1
                    rectangleHeader.visible = true
                    rectangleHeader.height = 48
                } else {
                    graphGrid.columns = 2
                    rectangleHeader.visible = false
                    rectangleHeader.height = 0
                }
            }
            if (isTablet) {
                if (screenOrientation === Qt.PortraitOrientation || width < 480) {
                    graphGrid.columns = 1
                } else {
                    graphGrid.columns = 2
                }
            }
        } else {
            if (graphGrid.width < 1080) {
                graphGrid.columns = 1
            } else {
                graphGrid.columns = 2
            }
            if (graphGrid.width < 575) {
                buttonPanel.anchors.topMargin = 52
                buttonPanel.anchors.rightMargin = 0
                buttonPanel.anchors.right = undefined
                buttonPanel.anchors.horizontalCenter = rectangleHeader.horizontalCenter
                rectangleHeader.height = 96
            } else {
                buttonPanel.anchors.topMargin = 8
                buttonPanel.anchors.rightMargin = 8
                buttonPanel.anchors.horizontalCenter = undefined
                buttonPanel.anchors.right = rectangleHeader.right
                rectangleHeader.height = 48
            }
        }

        // graph size multiplier
        if (graphCount === 3 && graphGrid.columns === 2) {
            if (currentDevice.hasSoilMoistureSensor && currentDevice.hasData("soilMoisture")) {
                hygroChart.duo = 2
                lumiChart.duo = 1
            } else if (currentDevice.hasLuminositySensor && currentDevice.hasData("luminosity")) {
                hygroChart.duo = 1
                lumiChart.duo = 2
            }
        } else {
            hygroChart.duo = 1
            lumiChart.duo = 1
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: Theme.colorDeviceHeader
        height: isMobile ? 48 : 96
        z: 5

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Row {
            id: buttonPanel
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            anchors.top: parent.top
            anchors.topMargin: isMobile ? 8 : 52

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (settingsManager.graphHistory === "monthly")
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Month")
                onClicked: settingsManager.graphHistory = "monthly"
            }

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (settingsManager.graphHistory === "weekly")
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Week")
                onClicked: settingsManager.graphHistory = "weekly"
            }

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (settingsManager.graphHistory === "daily")
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Day")
                onClicked: settingsManager.graphHistory = "daily"
            }
        }

        Text {
            id: textDeviceName
            height: 32
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12

            visible: isDesktop

            text: currentDevice.deviceName
            color: Theme.colorText
            font.pixelSize: Theme.fontSizeTitle
            font.capitalization: Font.AllUppercase
            verticalAlignment: Text.AlignVCenter

            ImageSvg {
                id: imageBattery
                width: 32
                height: 32
                rotation: 90
                anchors.verticalCenter: textDeviceName.verticalCenter
                anchors.left: textDeviceName.right
                anchors.leftMargin: 16

                visible: source
                color: Theme.colorIcon
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

    ////////////////////////////////////////////////////////////////////////////

    property int graphCount: 4
    property int graphWidth: (graphGrid.width / graphGrid.columns)
    property int graphHeight: (graphGrid.height / Math.ceil(graphCount / graphGrid.columns))

    Flow {
        id: graphGrid

        anchors.top: rectangleHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        onWidthChanged: updateSize()
        //onHeightChanged: updateSize()

        property int columns: 1
        property var mode: ChartHistory.Span.Weekly

        property int barSelectionIndex: -1
        property int barSelectionDays: -1
        property int barSelectionHours: -1

        function resetSelection() {
            graphGrid.barSelectionIndex = -1
            graphGrid.barSelectionDays = -1
            graphGrid.barSelectionHours = -1
        }

        ////////

        ChartHistory {
            id: hygroChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Moisture")
            ddd: graphGrid.mode
            uuu: ChartHistory.Data.SoilMoisture
            color: Theme.colorBlue
            suffix: "%"
            floatprecision: 0

            valueMax: currentDevice.hygroMax*1.2
            valueMin: currentDevice.hygroMin*0.8
            limitMin: currentDevice.limitHygroMin
            limitMax: currentDevice.limitHygroMax
        }

        ////////

        ChartHistory {
            id: tempChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Temperature")
            ddd: graphGrid.mode
            uuu: ChartHistory.Data.Temperature
            color: Theme.colorGreen
            suffix: "°"
            floatprecision: 1

            valueMax: currentDevice.tempMax*1.2
            valueMin: currentDevice.tempMin*0.8
            limitMin: currentDevice.limitTempMin
            limitMax: currentDevice.limitTempMax
        }

        ////////

        ChartHistory {
            id: lumiChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Luminosity")
            ddd: graphGrid.mode
            uuu: ChartHistory.Data.Luminosity
            color: Theme.colorYellow
            suffix: " " + "<br>" + qsTr("lux")
            floatprecision: 0

            valueMax: currentDevice.luxMax*1.2
            valueMin: currentDevice.luxMin*0.8
            limitMin: currentDevice.limitLuxMin
            limitMax: currentDevice.limitLuxMax
        }

        ////////

        ChartHistory { // graph
            id: conduChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Fertility")
            ddd: graphGrid.mode
            uuu: ChartHistory.Data.SoilConductivity
            color: Theme.colorRed
            suffix: " " + "<br>" + qsTr("µs/cm")
            floatprecision: 0

            valueMax: currentDevice.conduMax*1.2
            valueMin: currentDevice.conduMin*0.8
            limitMin: currentDevice.limitConduMin
            limitMax: currentDevice.limitConduMax
        }

        ////////
    }
}
