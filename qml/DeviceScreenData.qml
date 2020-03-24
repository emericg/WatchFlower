/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: deviceScreenData
    width: 400
    height: 300

    property var aioLineCharts: null
    property bool dataBarsHistory: false

    function updateHeader() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateHeader() >> " + myDevice)

        // Sensor battery level
        if (myDevice.hasBatteryLevel()) {
            imageBattery.visible = true
            imageBattery.color = Theme.colorIcon

            if (myDevice.deviceBattery > 95) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
            } else if (myDevice.deviceBattery > 85) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
            } else if (myDevice.deviceBattery > 75) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
            } else if (myDevice.deviceBattery > 55) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
            } else if (myDevice.deviceBattery > 45) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
            } else if (myDevice.deviceBattery > 25) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
            } else if (myDevice.deviceBattery > 15) {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
            } else if (myDevice.deviceBattery > 1) {
                if (myDevice.deviceBattery <= 10) imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                if (myDevice.deviceBattery === 0) imageBattery.color = Theme.colorRed
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }

        // Plant
        if (myDevice.hasSoilMoistureSensor()) {
            itemPlant.visible = true

            textInputPlant.text = myDevice.devicePlantName
            imageEditPlant.visible = !textInputPlant.text || textInputPlant.focus
        } else {
            itemPlant.visible = false
        }

        // Location
        textInputLocation.text = myDevice.deviceLocationName
        imageEditLocation.visible = !textInputLocation.text || textInputLocation.focus

        // Status
        updateStatusText()
    }

    function updateHeaderColor() {
        if (isPhone) {
            if (screenOrientation === Qt.PortraitOrientation) {
                rectangleHeader.color = Theme.colorForeground
            } else {
                rectangleHeader.color = "transparent"
            }
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    function updateStatusText() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // updateStatusText() >> " + myDevice)

        textStatus.color = Theme.colorHighContrast
        textStatus.font.bold = false

        if (myDevice.status === 1) {
            textStatus.text = qsTr("Update queued. ")
        } else if (myDevice.status === 2) {
            textStatus.text = qsTr("Connecting... ")
        } else if (myDevice.status === 3) {
            textStatus.text = qsTr("Updating... ")
        } else {
            if (myDevice.isFresh() || myDevice.isAvailable()) {
                if (myDevice.getLastUpdateInt() <= 1)
                    textStatus.text = qsTr("Just synced!")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(myDevice.lastUpdateStr)
            } else {
                textStatus.text = qsTr("Offline! ")
                textStatus.color = Theme.colorRed
            }
        }
    }

    function loadData() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenData // loadData() >> " + myDevice)

        if (graphLoader.status != Loader.Ready) {
            graphLoader.source = "ItemAioLineCharts.qml"
            aioLineCharts = graphLoader.item
        }

        aioLineCharts.loadGraph()
        aioLineCharts.resetIndicator()

        updateHeader()
        updateData()
    }

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
        aioLineCharts.updateGraph()
    }

    function updateDataBars(tempD, lumiD, hygroD, conduD) {
        dataBarsHistory = true
        temp.value = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempD) : tempD
        humi.value = hygroD
        lumi.value = lumiD
        condu.value = conduD
    }

    function resetDataBars() {
        dataBarsHistory = false
        humi.value = myDevice.deviceHumidity
        temp.value = (settingsManager.tempUnit === "F") ? myDevice.deviceTempF : myDevice.deviceTempC
        lumi.value = myDevice.deviceLuminosity
        condu.value = myDevice.deviceConductivity
    }

    function resetHistoryMode() {
        aioLineCharts.resetIndicator()
        resetDataBars()
    }

    Connections {
        target: settingsManager
        onTempUnitChanged: updateData()
    }
    Connections {
        target: Theme
        onCurrentThemeChanged: updateHeaderColor()
    }
    onWidthChanged: updateHeaderColor()

    ////////////////////////////////////////////////////////////////////////////

    Grid {
        id: dataGrid
        columns: 1
        rows: 2
        spacing: (rows > 1) ? 12 : 0

        onWidthChanged: {
            if (isPhone) {
                if (screenOrientation === Qt.PortraitOrientation) {
                    dataGrid.columns = 1
                    dataGrid.rows = 2
                } else {
                    dataGrid.columns = 2
                    dataGrid.rows = 1
                }
            }
        }

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Column {
            width: dataGrid.width / dataGrid.columns
            spacing: 8

            Rectangle {
                id: rectangleHeader
                color: Theme.colorForeground
                width: parent.width
                height: columnHeader.height + 16
                z: 5

                Column {
                    id: columnHeader
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        id: textDeviceName
                        height: 36
                        anchors.left: parent.left

                        visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                        text: myDevice.deviceName
                        color: Theme.colorText
                        font.pixelSize: 24
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

                            source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                            color: Theme.colorIcon
                        }
                    }

                    Item {
                        id: itemPlant
                        height: 28
                        width: parent.width

                        Text {
                            id: labelPlant
                            width: isPhone ? 78 : 96
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
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: labelPlant.right
                            anchors.leftMargin: 8

                            padding: 4
                            color: Theme.colorHighContrast
                            font.pixelSize: 18

                            onEditingFinished: {
                                if (text) {
                                    imageEditPlant.visible = false
                                } else {
                                    imageEditPlant.visible = true
                                }
                                myDevice.setPlantName(text)
                                focus = false
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                //propagateComposedEvents: true

                                onEntered: { imageEditPlant.visible = true; }
                                onExited: {
                                    if (textInputPlant.text && !textInputPlant.focus) {
                                        imageEditPlant.visible = false
                                    } else {
                                        imageEditPlant.visible = true
                                    }
                                }
                                onClicked: {
                                    imageEditPlant.visible = true;
                                    mouse.accepted = false;
                                }
                                onPressed: {
                                    imageEditPlant.visible = true;
                                    mouse.accepted = false;
                                }
                                onReleased: mouse.accepted = false;
                                onDoubleClicked: mouse.accepted = false;
                                onPositionChanged: mouse.accepted = false;
                                onPressAndHold: mouse.accepted = false;
                            }

                            MouseArea {
                                id: mouseArea
                                width: 26
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 0
                                anchors.left: parent.right
                                anchors.leftMargin: 0

                                hoverEnabled: true

                                onEntered: { imageEditPlant.visible = true; }
                                onExited: {
                                    if (textInputPlant.text && !textInputPlant.focus) {
                                        imageEditPlant.visible = false
                                    } else {
                                        imageEditPlant.visible = true
                                    }
                                }
                                onClicked: textInputPlant.forceActiveFocus()
                                onPressed: textInputPlant.forceActiveFocus()

                                ImageSvg {
                                    id: imageEditPlant
                                    width: 20
                                    height: 20

                                    visible: false
                                    source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                                    color: Theme.colorIcon
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    Item {
                        id: itemLocation
                        height: 28
                        width: parent.width

                        Text {
                            id: labelLocation
                            width: isPhone ? 78 : 96
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
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: labelLocation.right
                            anchors.leftMargin: 8

                            padding: 4
                            color: Theme.colorHighContrast
                            font.pixelSize: 18

                            onEditingFinished: {
                                if (text) {
                                    imageEditLocation.visible = false
                                } else {
                                    imageEditLocation.visible = true
                                }

                                myDevice.setLocationName(text)
                                focus = false
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                propagateComposedEvents: true

                                onEntered: { imageEditLocation.visible = true; }
                                onExited: {
                                    if (textInputLocation.text && !textInputLocation.focus) {
                                        imageEditLocation.visible = false
                                    } else {
                                        imageEditLocation.visible = true
                                    }
                                }
                                onClicked: {
                                    imageEditLocation.visible = true;
                                    mouse.accepted = false;
                                }
                                onPressed: {
                                    imageEditLocation.visible = true;
                                    mouse.accepted = false;
                                }
                                onReleased: mouse.accepted = false;
                                onDoubleClicked: mouse.accepted = false;
                                onPositionChanged: mouse.accepted = false;
                                onPressAndHold: mouse.accepted = false;
                            }

                            MouseArea {
                                id: mouseArea1
                                width: 26
                                anchors.left: parent.right
                                anchors.leftMargin: 0
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 0
                                anchors.top: parent.top
                                anchors.topMargin: 0

                                hoverEnabled: true

                                onEntered: { imageEditLocation.visible = true; }
                                onExited: {
                                    if (textInputLocation.text && !textInputLocation.focus) {
                                        imageEditLocation.visible = false
                                    } else {
                                        imageEditLocation.visible = true
                                    }
                                }
                                onClicked: textInputLocation.forceActiveFocus()
                                onPressed: textInputLocation.forceActiveFocus()

                                ImageSvg {
                                    id: imageEditLocation
                                    width: 20
                                    height: 20

                                    visible: false
                                    source: "qrc:/assets/icons_material/baseline-edit-24px.svg"
                                    color: Theme.colorIcon
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                }
                            }
                        }
                    }

                    Item {
                        id: status
                        height: 28
                        width: parent.width

                        Text {
                            id: labelStatus
                            width: isPhone ? 78 : 96
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
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: labelStatus.right
                            anchors.leftMargin: 8

                            text: qsTr("Loading...")
                            color: Theme.colorHighContrast
                            padding: 4
                            font.pixelSize: 18
                        }
                    }
                }
            }

            ////////////////

            Rectangle {
                id: rectangeData
                color: "transparent" // Theme.colorForeground
                width: parent.width
                height: columnData.height + 16
                z: 5

                Column {
                    id: columnData
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 14
                    visible: (myDevice.available || myDevice.hasData())

                    ItemDataBarFilled {
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
                    ItemDataBarFilled {
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
                    ItemDataBarFilled {
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
                    ItemDataBarFilled {
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
        }

        ////////////////

        Loader {
            id: graphLoader
            width: (dataGrid.width / dataGrid.columns)
            height: (dataGrid.columns === 1) ? (dataGrid.height - rectangleHeader.height - rectangeData.height - (dataGrid.rows > 1 ? dataGrid.spacing : 0)) : dataGrid.height
        }
    }
}
