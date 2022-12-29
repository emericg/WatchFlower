import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Item {
    id: devicePlantSensorData

    // 1: single column (single column view or portrait tablet)
    // 2: wide mode, two main rows (wide view)
    // 3: wide mode, two main columns (wide view, phones)
    property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : (isPhone ? 3 : 2)

    property var dataIndicators: indicatorsLoader.item
    property var dataChart: graphLoader.item

    ////////////////////////////////////////////////////////////////////////////

    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return
        //console.log("DevicePlantSensorData // loadData() >> " + currentDevice)

        // force graph reload
        graphLoader.source = ""
        graphLoader.opacity = 0
        noDataIndicator.visible = false

        loadIndicators()
        loadGraph()
        updateHeader()
        updateData()
    }

    function loadGraph() {
        if (graphLoader.status !== Loader.Ready) {
            graphLoader.source = "ChartPlantDataAio.qml"
        } else {
            dataChart.loadGraph()
            dataChart.updateGraph()
        }
    }

    function loadIndicators() {
        if (indicatorsLoader.status !== Loader.Ready) {
            if (settingsManager.bigIndicator)
                indicatorsLoader.source = "IndicatorsSolid.qml"
            else
                indicatorsLoader.source = "IndicatorsCompact.qml"
        } else {
            dataIndicators.loadIndicators()
        }
    }
    function reloadIndicators() {
        if (settingsManager.bigIndicator)
            indicatorsLoader.source = "IndicatorsSolid.qml"
        else
            indicatorsLoader.source = "IndicatorsCompact.qml"

        if (indicatorsLoader.status === Loader.Ready) {
            dataIndicators.loadIndicators()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return
        //console.log("DevicePlantSensorData // updateHeader() >> " + currentDevice)

        // Status
        updateStatusText()
    }

    Timer {
        interval: 60000
        running: visible
        repeat: true
        onTriggered: updateStatusText()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return
        //console.log("DevicePlantSensorData // updateStatusText() >> " + currentDevice)

        textStatus.text = UtilsDeviceSensors.getDeviceStatusText(currentDevice.status)
        textStatus.color = Theme.colorHighContrast
        textStatus.font.bold = false

        if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE) {
            if (currentDevice.isDataFresh_rt() || currentDevice.isDataToday()) {
                if (currentDevice.lastUpdateMin <= 1)
                    textStatus.text = qsTr("Synced")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
            } else {
                textStatus.color = Theme.colorRed
            }
        }
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return
        //console.log("DevicePlantSensorData // updateData() >> " + currentDevice)
    }

    function updateLegendSizes() {
        if (indicatorsLoader.status === Loader.Ready) dataIndicators.updateLegendSize()
    }

    function updateGraph() {
        if (graphLoader.status === Loader.Ready) dataChart.updateGraph()
    }

    function backAction() {
        if (textInputPlant.focus) {
            textInputPlant.focus = false
            return
        }
        if (textInputLocation.focus) {
            textInputLocation.focus = false
            return
        }
        if (isHistoryMode()) {
            resetHistoryMode()
            return
        }

        appContent.state = "DeviceList"
    }

    function isHistoryMode() {
        if (graphLoader.status === Loader.Ready) return dataChart.isIndicator()
        return false
    }
    function resetHistoryMode() {
        if (graphLoader.status === Loader.Ready) dataChart.resetIndicator()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: subHeaderBackground
        width: parent.width
        height: (uiMode === 1) ? itemHeader.height : contentGrid_lvl2.height
        //Behavior on height { NumberAnimation { duration: 133 } }

        visible: (uiMode !== 3)
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

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

    ////////

    Grid {
        id: contentGrid_lvl1
        anchors.fill: parent
        columns: (uiMode === 3) ? 2 : 1
        rows: 2
        spacing: 0

        Grid {
            id: contentGrid_lvl2
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            columns: (uiMode === 2) ? 3 : 1
            rows: 3
            spacing: 0

            ////////

            Item {
                id: itemHeader
                width: parent.columns === 1 ? parent.width : (parent.width * 0.36)
                height: columnHeader.height + 12

                Column {
                    id: columnHeader
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 2
                    spacing: 2

                    Text {
                        id: textDeviceName
                        height: 32
                        anchors.left: parent.left

                        visible: isDesktop

                        text: currentDevice ? currentDevice.deviceName : ""
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeTitle
                        font.capitalization: Font.AllUppercase
                        verticalAlignment: Text.AlignVCenter

                        IconSvg {
                            id: imageBattery
                            width: 32
                            height: 32
                            rotation: 90
                            anchors.verticalCenter: textDeviceName.verticalCenter
                            anchors.left: textDeviceName.right
                            anchors.leftMargin: 16

                            visible: (currentDevice.hasBattery && currentDevice.deviceBattery >= 0)
                            source: UtilsDeviceSensors.getDeviceBatteryIcon(currentDevice.deviceBattery)
                            color: UtilsDeviceSensors.getDeviceBatteryColor(currentDevice.deviceBattery)
                        }
                    }

                    Item {
                        id: itemPlant
                        height: 28
                        width: parent.width

                        Text {
                            id: labelPlant
                            width: (dataIndicators) ? dataIndicators.legendWidth : 80
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Plant")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        TextInput {
                            id: textInputPlant
                            anchors.left: labelPlant.right
                            anchors.leftMargin: 8
                            anchors.baseline: labelPlant.baseline
                            padding: 4

                            font.pixelSize: Theme.fontSizeContentBig
                            font.bold: false
                            color: Theme.colorHighContrast

                            text: currentDevice ? currentDevice.devicePlantName : ""
                            onEditingFinished: {
                                currentDevice.devicePlantName = text
                                focus = false
                            }

                            MouseArea {
                                id: textInputPlantArea
                                anchors.fill: parent
                                anchors.topMargin: -4
                                anchors.leftMargin: -4
                                anchors.rightMargin: -24
                                anchors.bottomMargin: -4

                                hoverEnabled: true
                                propagateComposedEvents: true

                                onPressed: (mouse) => {
                                    textInputPlant.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        IconSvg {
                            id: imageEditPlant
                            width: 20
                            height: 20
                            anchors.left: textInputPlant.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: textInputPlant.verticalCenter

                            source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                            color: Theme.colorSubText

                            opacity: (isMobile || !textInputPlant.text || textInputPlant.focus || textInputPlantArea.containsMouse) ? 0.9 : 0
                            Behavior on opacity { OpacityAnimator { duration: 133 } }
                        }
                    }

                    Item {
                        id: itemLocation
                        height: 28
                        width: parent.width

                        Text {
                            id: labelLocation
                            width: (dataIndicators) ? dataIndicators.legendWidth : 80
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Location")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        TextInput {
                            id: textInputLocation
                            anchors.left: labelLocation.right
                            anchors.leftMargin: 8
                            anchors.baseline: labelLocation.baseline
                            padding: 4

                            font.pixelSize: Theme.fontSizeContentBig
                            font.bold: false
                            color: Theme.colorHighContrast

                            text: currentDevice ? currentDevice.deviceLocationName : ""
                            onEditingFinished: {
                                currentDevice.deviceLocationName = text
                                focus = false
                            }

                            MouseArea {
                                id: textInputLocationArea
                                anchors.fill: parent
                                anchors.topMargin: -4
                                anchors.leftMargin: -4
                                anchors.rightMargin: -24
                                anchors.bottomMargin: -4

                                hoverEnabled: true
                                propagateComposedEvents: true

                                onPressed: (mouse) => {
                                    textInputLocation.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        IconSvg {
                            id: imageEditLocation
                            width: 20
                            height: 20
                            anchors.left: textInputLocation.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: textInputLocation.verticalCenter

                            source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                            color: Theme.colorSubText

                            opacity: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputLocationArea.containsMouse) ? 0.9 : 0
                            Behavior on opacity { OpacityAnimator { duration: 133 } }
                        }
                    }

                    Item {
                        id: status
                        height: 28
                        width: parent.width

                        Text {
                            id: labelStatus
                            width: (dataIndicators) ? dataIndicators.legendWidth : 80
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Status")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            id: textStatus
                            anchors.left: labelStatus.right
                            anchors.leftMargin: 8
                            anchors.right: parent.right
                            anchors.rightMargin: -4
                            anchors.baseline: labelStatus.baseline
                            padding: 4

                            text: qsTr("Loading...")
                            color: Theme.colorHighContrast
                            font.pixelSize: Theme.fontSizeContentBig
                            font.bold: false
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            ////////

            Item {
                id: itemIndicators
                height: Math.max(itemHeader.height, indicatorsLoader.height)
                width: (parent.columns === 1) ? parent.width : (parent.width * 0.64)

                Loader {
                    id: indicatorsLoader
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width

                    asynchronous: false
                    onLoaded: {
                        dataIndicators.loadIndicators()
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Item {
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            height: {
                if (contentGrid_lvl1.columns === 1) return (contentGrid_lvl1.height - contentGrid_lvl1.spacing - contentGrid_lvl2.height)
                else return contentGrid_lvl1.height
            }
            clip: true

            ItemNoData {
                id: noDataIndicator
                visible: false
            }

            ItemLoadData {
                id: loadingIndicator
                visible: !noDataIndicator.visible
            }

            Loader {
                id: graphLoader
                anchors.fill: parent

                opacity: 0
                Behavior on opacity { OpacityAnimator { duration: (graphLoader.status === Loader.Ready) ? 200 : 0 } }

                asynchronous: true
                onLoaded: {
                    dataChart.loadGraph()
                    dataChart.updateGraph()

                    graphLoader.opacity = 1
                    noDataIndicator.visible = (currentDevice.countDataNamed("temperature", dataChart.daysVisible) <= 1)
                }
            }
        }
    }
}
