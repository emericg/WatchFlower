import QtQuick

import ThemeEngine 1.0

Item {
    id: devicePlantSensorHistory

    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return
        //console.log("DevicePlantSensorHistory // loadData() >> " + currentDevice)

        // graph visibility
        graphCount = 0
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
        if (currentDevice.hasSoilTemperatureSensor) {
            if (currentDevice.soilTemperature > 0 || currentDevice.countDataNamed("soilTemperature") > 0) {
                soiltempChart.visible = true
                graphCount += 1
            } else {
                soiltempChart.visible = false
            }
        } else {
            soiltempChart.visible = false
        }

        if (currentDevice.hasTemperatureSensor) {
            tempChart.visible = true
            graphCount += 1
        } else {
            tempChart.visible = false
        }
        if (currentDevice.hasHumiditySensor) {
            humiChart.visible = true
            graphCount += 1
        } else {
            humiChart.visible = false
        }
        if (currentDevice.hasLuminositySensor) {
            lumiChart.visible = true
            graphCount += 1
        } else {
            lumiChart.visible = false
        }

        resetHistoryMode()
        updateHistoryMode()

        updateSize()

        selectors.visible = false
        selector_month.value = 0
        selector_week.value = 0
        selector_day.value = 0
        currentDevice.updateChartData_history_thismonth(30)
        currentDevice.updateChartData_history_thisweek()
        currentDevice.updateChartData_history_today()
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return
        //console.log("DevicePlantSensorHistory // updateHeader() >> " + currentDevice)
    }

    function updateData() {
        //console.log("DevicePlantSensorHistory // updateData() >> " + currentDevice)

        resetHistoryMode()

        var today = new Date()
        var offset = 0

        if (settingsManager.graphHistory === "daily") {
            offset = selector_day.value
        } else if (settingsManager.graphHistory === "weekly") {
            offset = selector_week.value
        } else if (settingsManager.graphHistory === "monthly") {
            offset = selector_month.value
        }

        if (settingsManager.graphHistory === "daily") {

            if (offset === 0) {
                currentDevice.updateChartData_history_today()
            } else {
                var d1 = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0)
                d1.setTime(d1.getTime() - ((24*60*60*1000) * -offset)) // days offset
                currentDevice.updateChartData_history_day(d1)
            }

        } else if (settingsManager.graphHistory === "weekly") {

            if (offset === 0) {
                currentDevice.updateChartData_history_thisweek()
            } else {
                var lastmonday = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0);
                var day = lastmonday.getDay() || 7;
                if (day !== 1) { lastmonday.setHours(-24 * (day - 1)); }

                var w1 = new Date(lastmonday)
                w1.setTime(w1.getTime() - ((-offset) * (7*24*60*60*1000))) // weeks offset
                var w2 = new Date(lastmonday)
                w2.setTime(w2.getTime() - ((-offset-1) * (7*24*60*60*1000)) - (24*60*60*1000))

                currentDevice.updateChartData_history_week(w1, w2)
            }

        } else if (settingsManager.graphHistory === "monthly") {

            if (offset === 0) {
                currentDevice.updateChartData_history_thismonth(30)
            } else {
                var m1 = new Date(today.getFullYear(), today.getMonth()+offset, 1, 0, 0, 0)
                var m2 = new Date(today.getFullYear(), today.getMonth()+offset+1, 0, 0, 0, 0)

                currentDevice.updateChartData_history_month(m1, m2, m2.getDate())
            }

        }
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

    function backAction() {
        if (isHistoryMode()) {
            resetHistoryMode()
            return
        }

        screenDeviceList.loadScreen()
    }

    function isHistoryMode() {
        return graphGrid.hasSelection()
    }
    function resetHistoryMode() {
        graphGrid.resetSelection()
    }

    function updateSize() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return
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
                if (graphGrid.width < 575) {
                    buttonPanel.anchors.rightMargin = 0
                    buttonPanel.anchors.right = undefined
                    buttonPanel.anchors.horizontalCenter = subHeader.horizontalCenter
                    subHeader.height = 52
                } else {
                    buttonPanel.anchors.rightMargin = 12
                    buttonPanel.anchors.horizontalCenter = undefined
                    buttonPanel.anchors.right = subHeader.right
                    subHeader.height = 52
                }
            }
        } else { // isDesktop
            if (graphGrid.width < 1080) {
                graphGrid.columns = 1
            } else {
                graphGrid.columns = 2
            }
            if (graphGrid.width < 575) {
                buttonPanel.anchors.rightMargin = 0
                buttonPanel.anchors.right = undefined
                buttonPanel.anchors.horizontalCenter = subHeader.horizontalCenter
                subHeader.height = 52
            } else {
                buttonPanel.anchors.rightMargin = 12
                buttonPanel.anchors.horizontalCenter = undefined
                buttonPanel.anchors.right = subHeader.right
                subHeader.height = 52
            }
        }

        // graph size multiplier
        if ((graphCount === 3 || graphCount === 5) && graphGrid.columns === 2) {
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
        height: isPhone ? 48 : 52
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

        Text {
            id: textDeviceName
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            visible: (!isPhone && graphGrid.width >= 575)

            text: {
                if (currentDevice.devicePlantName.length)
                    return currentDevice.deviceName + " - " + currentDevice.devicePlantName
                return currentDevice.deviceName
            }
            color: Theme.colorText
            font.pixelSize: 24
            horizontalAlignment: wideMode ? Text.AlignLeft : Text.AlignHCenter
        }

        Item {
            id: selectorsContainerOne
            width: buttonPanel.width
            anchors.right: buttonPanel.left
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            id: buttonPanel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.componentMargin

            ButtonWireframe {
                width: 100
                height: isPhone ? 32 : 36

                fullColor: (settingsManager.graphHistory === "monthly")
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Month")
                onClicked: {
                    if (settingsManager.graphHistory === "monthly") {
                        selectors.visible = !(selectors.visible && selector_month.value === 0)
                    } else {
                        settingsManager.graphHistory = "monthly"
                        if (!selectors.visible && selector_month.value !== 0) selectors.visible = true
                    }
                }
            }

            ButtonWireframe {
                width: 100
                height: isPhone ? 32 : 36

                fullColor: (settingsManager.graphHistory === "weekly")
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Week")
                onClicked: {
                    if (settingsManager.graphHistory === "weekly") {
                        selectors.visible = !(selectors.visible && selector_week.value === 0)
                    } else {
                        settingsManager.graphHistory = "weekly"
                        if (!selectors.visible && selector_week.value !== 0) selectors.visible = true
                    }
                }
            }

            ButtonWireframe {
                width: 100
                height: isPhone ? 32 : 36

                fullColor: (settingsManager.graphHistory === "daily")
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Day")
                onClicked: {
                    if (settingsManager.graphHistory === "daily") {
                        selectors.visible = !(selectors.visible && selector_day.value === 0)
                    } else {
                        settingsManager.graphHistory = "daily"
                        if (!selectors.visible && selector_day.value !== 0) selectors.visible = true
                    }
                }
            }
        }

        Rectangle { // bottom separator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: (isDesktop && !headerUnicolor)
            height: 2
            opacity: 0.5
            color: Theme.colorSeparator
        }
    }

    Rectangle {
        id: subsubHeader
        anchors.top: subHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        z: 4
        clip: true
        opacity: 0.66
        height: (singleColumn && selectors.visible) ? 40 : 0
        Behavior on height { NumberAnimation { duration: 133 } }
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

        Item {
            id: selectorsContainerTwo
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        id: selectors
        parent: singleColumn ? selectorsContainerTwo : selectorsContainerOne

        anchors.centerIn: parent
        visible: false

        SpinBoxHistory {
            id: selector_month
            width: buttonPanel.width
            height: isPhone ? 32 : 36
            visible: (settingsManager.graphHistory === "monthly")

            from: -2
            to: 0
            value: 0

            hhh: ChartHistory.Span.Monthly
            onValueModified: updateData()
        }
        SpinBoxHistory {
            id: selector_week
            width: buttonPanel.width
            height: isPhone ? 32 : 36
            visible: (settingsManager.graphHistory === "weekly")

            from: -3
            to: 0
            value: 0

            hhh: ChartHistory.Span.Weekly
            onValueModified: updateData()
        }
        SpinBoxHistory {
            id: selector_day
            width: buttonPanel.width
            height: isPhone ? 32 : 36
            visible: (settingsManager.graphHistory === "daily")

            from: -6
            to: 0
            value: 0

            hhh: ChartHistory.Span.Daily
            onValueModified: updateData()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    property int graphCount: 4
    property int graphWidth: (graphGrid.width / graphGrid.columns)
    property int graphHeight: (graphGrid.height / Math.ceil(graphCount / graphGrid.columns))

    Flow {
        id: graphGrid

        anchors.top: subsubHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        onWidthChanged: updateSize()

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

            title: qsTr("Soil moisture")
            hhh: graphGrid.mode
            ddd: ChartHistory.Data.SoilMoisture
            color: Theme.colorBlue
            suffix: "%"
            floatprecision: 0

            valueMax: currentDevice.hygroMax_history*1.2
            valueMin: currentDevice.hygroMin_history*0.8
            limitMin: currentDevice.soilMoisture_limitMin
            limitMax: currentDevice.soilMoisture_limitMax
        }

        ////////

        ChartHistory {
            id: conduChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Soil conductivity")
            hhh: graphGrid.mode
            ddd: ChartHistory.Data.SoilConductivity
            color: Theme.colorRed
            suffix: " " + "<br>" + qsTr("µs/cm")
            floatprecision: 0

            valueMax: currentDevice.conduMax_history*1.2
            valueMin: currentDevice.conduMin_history*0.8
            limitMin: currentDevice.soilConductivity_limitMin
            limitMax: currentDevice.soilConductivity_limitMax
        }

        ////////

        ChartHistory {
            id: soiltempChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Soil temperature")
            hhh: graphGrid.mode
            ddd: ChartHistory.Data.SoilTemperature
            color: Qt.darker(Theme.colorGreen, 1.1)
            suffix: "°"
            floatprecision: 1

            valueMax: currentDevice.tempMax_history*1.2
            valueMin: currentDevice.tempMin_history*0.8
            limitMin: currentDevice.temperature_limitMin
            limitMax: currentDevice.temperature_limitMax
        }

        ////////

        ChartHistory {
            id: tempChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Temperature")
            hhh: graphGrid.mode
            ddd: ChartHistory.Data.Temperature
            color: Theme.colorGreen
            suffix: "°"
            floatprecision: 1

            valueMax: currentDevice.tempMax_history*1.2
            valueMin: currentDevice.tempMin_history*0.8
            limitMin: currentDevice.temperature_limitMin
            limitMax: currentDevice.temperature_limitMax
        }

        ////////

        ChartHistory {
            id: humiChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Humidity")
            hhh: graphGrid.mode
            ddd: ChartHistory.Data.Humidity
            color: Theme.colorBlue
            suffix: "%"
            floatprecision: 1

            valueMax: currentDevice.humiMax_history*1.2
            valueMin: currentDevice.humiMin_history*0.8
            limitMin: currentDevice.humidity_limitMin
            limitMax: currentDevice.humidity_limitMax
        }

        ////////

        ChartHistory {
            id: lumiChart
            width: graphWidth * duo
            height: graphHeight
            property int duo: 1

            title: qsTr("Luminosity")
            hhh: graphGrid.mode
            ddd: ChartHistory.Data.LuminosityLux
            color: Theme.colorYellow
            suffix: " " + "<br>" + qsTr("lux")
            floatprecision: 0

            valueMax: currentDevice.luxMax_history*1.2
            valueMin: currentDevice.luxMin_history*0.8
            limitMin: currentDevice.luminosityLux_limitMin
            limitMax: currentDevice.luminosityLux_limitMax
        }

        ////////
    }
}
