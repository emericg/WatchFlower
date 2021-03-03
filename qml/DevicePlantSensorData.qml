import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import ThemeEngine 1.0
import DeviceUtils 1.0
import "qrc:/js/UtilsDeviceBLE.js" as UtilsDeviceBLE

Item {
    id: devicePlantSensorData
    width: 400
    height: 300

    property var dataIndicators: null
    property var dataCharts: null

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DevicePlantSensorData // updateHeader() >> " + currentDevice)

        // Battery level
        imageBattery.source = UtilsDeviceBLE.getDeviceBatteryIcon(currentDevice.deviceBattery)
        imageBattery.color = UtilsDeviceBLE.getDeviceBatteryColor(currentDevice.deviceBattery)

        // Plant
        if (currentDevice.hasSoilMoistureSensor()) {
            itemPlant.visible = true
        } else {
            itemPlant.visible = false
        }

        // Status
        updateStatusText()
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DevicePlantSensorData // updateStatusText() >> " + currentDevice)

        textStatus.text = UtilsDeviceBLE.getDeviceStatusText(currentDevice.status)
        textStatus.color = Theme.colorHighContrast
        textStatus.font.bold = false

        if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE) {
            if (currentDevice.isFresh() || currentDevice.isAvailable()) {
                if (currentDevice.getLastUpdateInt() <= 1)
                    textStatus.text = qsTr("Synced")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(currentDevice.lastUpdateStr)
            } else {
                textStatus.color = Theme.colorRed
            }
        }
    }

    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DevicePlantSensorData // loadData() >> " + currentDevice)

        updateHeader()

        if (indicatorsLoader.status != Loader.Ready) {
            if (settingsManager.bigIndicator)
                indicatorsLoader.source = "ItemIndicatorsSolid.qml"
            else
                indicatorsLoader.source = "ItemIndicatorsCompact.qml"
            dataIndicators = indicatorsLoader.item
        }
        dataIndicators.updateSize()

        if (graphLoader.status != Loader.Ready) {
            graphLoader.source = "ItemAioLineCharts.qml"
            dataCharts = graphLoader.item
        }
        dataCharts.loadGraph()

        updateData()
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor()) return
        //console.log("DevicePlantSensorData // updateData() >> " + currentDevice)

        resetHistoryMode()
        dataIndicators.updateData()
        dataCharts.updateGraph()
    }

    function isHistoryMode() {
        return dataCharts.isIndicator()
    }
    function resetHistoryMode() {
        dataCharts.resetIndicator()
    }

    Connections {
        target: settingsManager
        onTempUnitChanged: {
            updateData()
        }
        onBigIndicatorChanged: {
            if (settingsManager.bigIndicator)
                indicatorsLoader.source = "ItemIndicatorsSolid.qml"
            else
                indicatorsLoader.source = "ItemIndicatorsCompact.qml"
            dataIndicators = indicatorsLoader.item
            updateData()
        }
        onAppLanguageChanged: {
            updateStatusText()
            dataIndicators.updateSize()
        }
    }
/*
    onWidthChanged: {
        if (isPhone) {
            if (screenOrientation === Qt.PortraitOrientation) {
                contentGrid_lvl1.columns = 1
                contentGrid_lvl1.rows = 2
                rectangleHeader.color = Theme.colorForeground
            } else {
                contentGrid_lvl1.columns = 2
                contentGrid_lvl1.rows = 1
                rectangleHeader.color = "transparent"
            }
        }
        if (isDesktop) {
            if (devicePlantSensorData.width < devicePlantSensorData.height) {
                contentGrid_lvl2.columns = 1
                contentGrid_lvl2.rows = 2
                rectangleHeader.color = Theme.colorForeground
            } else {
                contentGrid_lvl2.columns = 2
                contentGrid_lvl2.rows = 1
                rectangleHeader.color = "transparent"
            }
        }
    }
*/
    ////////////////////////////////////////////////////////////////////////////

    Grid {
        id: contentGrid_lvl1
        columns: (isPhone && screenOrientation === Qt.LandscapeOrientation) ? 2 : 1
        rows: (isPhone && screenOrientation === Qt.LandscapeOrientation) ? 1 : 2
        spacing: (rows > 1) ? 12 : 0

        anchors.fill: parent

        Grid {
            id: contentGrid_lvl2
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            columns: 1
            rows: 2
            spacing: 6

            ////////

            Rectangle {
                id: rectangleHeader
                color: (isPhone && screenOrientation === Qt.LandscapeOrientation) ? "transparent" : Theme.colorDeviceHeader
                width: (parent.width / parent.columns)
                height: columnHeader.height + 12
                z: 5

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
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        TextInput {
                            id: textInputPlant
                            anchors.left: labelPlant.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 0

                            padding: 4
                            font.pixelSize: 17
                            font.bold: false
                            color: Theme.colorHighContrast

                            text: currentDevice ? currentDevice.devicePlantName : ""
                            onEditingFinished: {
                                currentDevice.setAssociatedName(text)
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

                                onClicked: {
                                    textInputPlant.forceActiveFocus()
                                    mouse.accepted = false
                                }
                                onPressed: {
                                    textInputPlant.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        ImageSvg {
                            id: imageEditPlant
                            width: 20
                            height: 20
                            anchors.left: textInputPlant.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                            color: Theme.colorSubText

                            //visible: (isMobile || !textInputPlant.text || textInputPlant.focus || textInputPlantArea.containsMouse)
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
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        TextInput {
                            id: textInputLocation
                            anchors.left: labelLocation.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 0

                            padding: 4
                            font.pixelSize: 17
                            font.bold: false
                            color: Theme.colorHighContrast

                            text: currentDevice ? currentDevice.deviceLocationName : ""
                            onEditingFinished: {
                                currentDevice.setLocationName(text)
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

                                onClicked: {
                                    textInputLocation.forceActiveFocus()
                                    mouse.accepted = false
                                }
                                onPressed: {
                                    textInputLocation.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        ImageSvg {
                            id: imageEditLocation
                            width: 20
                            height: 20
                            anchors.left: textInputLocation.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                            color: Theme.colorSubText

                            //visible: (isMobile || !textInputLocation.text || textInputLocation.focus || textInputArea.containsMouse)
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
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            id: textStatus
                            anchors.left: labelStatus.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 0
                            padding: 4

                            text: qsTr("Loading...")
                            color: Theme.colorHighContrast
                            font.pixelSize: 17
                            font.bold: false
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    visible: (isDesktop && !unicolor)
                    height: 2
                    opacity: 0.5
                    color: Theme.colorSeparator
                }
            }

            ////////

            Loader {
                id: indicatorsLoader
                width: parent.width / parent.columns
                //height: columnData.height + 16
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Loader {
            id: graphLoader
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            height: (contentGrid_lvl1.columns === 1) ? (contentGrid_lvl1.height - rectangleHeader.height - indicatorsLoader.height - (contentGrid_lvl1.rows > 1 ? contentGrid_lvl1.spacing : 0)) : contentGrid_lvl1.height
        }
    }
}
