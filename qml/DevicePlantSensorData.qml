import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Item {
    id: devicePlantSensorData

    // 1: single column
    // 2: wide mode (two main rows)
    // 3: wide mode for phones (two main columns)
    property int uiMode: singleColumn ? 1 : (isPhone ? 3 : 2)

    property var dataIndicators: indicatorsLoader.item
    property var dataChart: chartAioLoader.item

    ////////////////////////////////////////////////////////////////////////////

    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("DevicePlantSensorData // loadData() >> " + currentDevice)

        indicatorsLoader.source = "" // force graph reload

        loadIndicators()
        loadGraph()

        updateHeader()
        updateData()
    }

    function loadGraph() {
        if (chartAioLoader.status != Loader.Ready) {
            chartAioLoader.source = "ChartPlantDataAio.qml"
        } else {
            dataChart.loadGraph()
            dataChart.updateGraph()
        }
    }

    function loadIndicators() {
        if (indicatorsLoader.status != Loader.Ready) {
            if (settingsManager.bigIndicator)
                indicatorsLoader.source = "IndicatorsSolid.qml"
            else
                indicatorsLoader.source = "IndicatorsCompact.qml"
        } else {
            dataIndicators.updateLegendSize()
            dataIndicators.updateData()
        }
    }
    function reloadIndicators() {
        if (settingsManager.bigIndicator)
            indicatorsLoader.source = "IndicatorsSolid.qml"
        else
            indicatorsLoader.source = "IndicatorsCompact.qml"

        if (indicatorsLoader.status == Loader.Ready) {
            dataIndicators.updateLegendSize()
            dataIndicators.updateData()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("DevicePlantSensorData // updateHeader() >> " + currentDevice)

        // Status
        updateStatusText()
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("DevicePlantSensorData // updateStatusText() >> " + currentDevice)

        textStatus.text = UtilsDeviceSensors.getDeviceStatusText(currentDevice.status)
        textStatus.color = Theme.colorHighContrast
        textStatus.font.bold = false

        if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE) {
            if (currentDevice.isDataFresh() || currentDevice.isDataToday()) {
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
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("DevicePlantSensorData // updateData() >> " + currentDevice)
    }

    function updateLegendSizes() {
        if (indicatorsLoader.status == Loader.Ready) dataIndicators.updateLegendSize()
    }

    function updateGraph() {
        if (chartAioLoader.status == Loader.Ready) dataChart.updateGraph()
    }

    function isHistoryMode() {
        if (chartAioLoader.status == Loader.Ready) return dataChart.isIndicator()
        return false
    }
    function resetHistoryMode() {
        if (chartAioLoader.status == Loader.Ready) dataChart.resetIndicator()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: subHeaderBackground
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground
        width: parent.width
        height: (uiMode === 1) ? itemHeader.height : contentGrid_lvl2.height
        visible: (uiMode !== 3)

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
        rows: (uiMode === 3) ? 1 : 2
        spacing: 0

        Grid {
            id: contentGrid_lvl2
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            columns: (uiMode === 2) ? 3 : 1
            rows: (uiMode === 2) ? 1 : 3
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
                            width: dataIndicators.legendWidth
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

                            font.pixelSize: 17
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
                            width: dataIndicators.legendWidth
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

                            font.pixelSize: 17
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
                            width: dataIndicators.legendWidth
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
                            font.pixelSize: 17
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
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    onLoaded: {
                        dataIndicators.updateLegendSize()
                        dataIndicators.updateData()
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Item {
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            height: (contentGrid_lvl1.columns === 1) ? (contentGrid_lvl1.height - contentGrid_lvl1.spacing - contentGrid_lvl2.height) : contentGrid_lvl1.height
            clip: true

            Loader {
                id: chartAioLoader
                anchors.fill: parent

                asynchronous: true
                onLoaded: {
                    dataChart.loadGraph()
                    dataChart.updateGraph()
                }
            }
        }
    }
}
