import QtQuick 2.15

import ThemeEngine 1.0

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
            if (currentDevice.soilMoisture > 0 || currentDevice.countDataNamed("soilMoisture") > 0) {
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
            if (currentDevice.soilConductivity > 0 || currentDevice.countDataNamed("soilConductivity") > 0) {
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
        return graphGrid.hasSelection()
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
                    subHeader.visible = true
                    subHeader.height = 48
                } else {
                    graphGrid.columns = 2
                    subHeader.visible = false
                    subHeader.height = 0
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
                buttonPanel.anchors.horizontalCenter = subHeader.horizontalCenter
                subHeader.height = 96
            } else {
                buttonPanel.anchors.topMargin = 8
                buttonPanel.anchors.rightMargin = 8
                buttonPanel.anchors.horizontalCenter = undefined
                buttonPanel.anchors.right = subHeader.right
                subHeader.height = 48
            }
        }

        // graph size multiplier
        if (graphCount === 3 && graphGrid.columns === 2) {
            if (currentDevice.hasSoilMoistureSensor && currentDevice.hasDataNamed("soilMoisture")) {
                hygroChart.duo = 2
                lumiChart.duo = 1
            } else if (currentDevice.hasLuminositySensor && currentDevice.hasDataNamed("luminosityLux")) {
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
        id: subHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        height: isPhone ? 96 : 48
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

        Text {
            id: textDeviceName
            height: 32
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12

            visible: isDesktop

            text: currentDevice.deviceName + " - " + currentDevice.devicePlantName
            color: Theme.colorText
            font.pixelSize: 22
            font.capitalization: Font.Capitalize
            horizontalAlignment: wideMode ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Row {
            id: buttonPanel
            anchors.top: parent.top
            anchors.topMargin: isMobile ? 8 : 52
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

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

        anchors.top: subHeader.bottom
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

        function hasSelection() {
            return (barSelectionIndex >= 0 || barSelectionDays >= 0 || barSelectionHours >= 0)
        }
        function resetSelection() {
            barSelectionIndex = -1
            barSelectionDays = -1
            barSelectionHours = -1
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
            uuu: ChartHistory.Data.LuminosityLux
            color: Theme.colorYellow
            suffix: " " + "<br>" + qsTr("lux")
            floatprecision: 0

            valueMax: currentDevice.luxMax*1.2
            valueMin: currentDevice.luxMin*0.8
            limitMin: currentDevice.limitLuxMin
            limitMax: currentDevice.limitLuxMax
        }

        ////////
    }
}
