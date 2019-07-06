/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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

import com.watchflower.theme 1.0
import "UtilsNumber.js" as UtilsNumber

Item {
    id: deviceScreenDatas
    width: 400
    height: 300

    function updateHeader() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenDatas // updateHeader() >> " + myDevice)

        // Sensor battery level
        if (myDevice.hasBatteryLevel()) {
            imageBattery.visible = true
            imageBattery.color = Theme.colorIcons

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
            if (textInputPlant.text && !textInputPlant.focus)
                imageEditPlant.visible = false
            else
                imageEditPlant.visible = true
        } else {
            itemPlant.visible = false
        }

        // Location
        textInputLocation.text = myDevice.deviceLocationName
        if (textInputLocation.text && !textInputLocation.focus)
            imageEditLocation.visible = false
        else
            imageEditLocation.visible = true

        // Status
        updateStatusText()
    }

    Timer {
        interval: 60000; running: true; repeat: true;
        onTriggered: updateStatusText()
    }

    property var aioLineCharts: null

    function updateStatusText() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenDatas // updateStatusText() >> " + myDevice)

        textStatus.color = Theme.colorHighContrast
        textStatus.font.bold = false

        if (myDevice.status === 1) {
            textStatus.text = qsTr("Update queued. ")
        } else if (myDevice.status === 2) {
            textStatus.text = qsTr("Connecting... ")
        } else if (myDevice.status === 3) {
            textStatus.text = qsTr("Updating... ")
        } else {
            if (!myDevice.available) {
                textStatus.text = qsTr("Offline! ")
                textStatus.color = Theme.colorRed
            } else {
                textStatus.text = ""
            }
        }

        if (myDevice.isFresh() || myDevice.isAvailable()) {
            if (myDevice.getLastUpdateInt() <= 1)
                textStatus.text = qsTr("Just synced!")
            else
                textStatus.text += qsTr("Synced %1 ago").arg(myDevice.lastUpdateStr)
        }
    }

    function loadDatas() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenDatas // loadDatas() >> " + myDevice)

        if (settingsManager.graph === "bar")
            pageLoader.source = "ItemAioBarCharts.qml"
        else
            pageLoader.source = "ItemAioLineCharts.qml"

        aioLineCharts = pageLoader.item
        aioLineCharts.loadGraph()
        aioLineCharts.resetIndicator()

        updateHeader()
        updateDatas()
    }

    function updateDatas() {
        if (typeof myDevice === "undefined" || !myDevice) return
        if (!myDevice.hasSoilMoistureSensor()) return
        //console.log("DeviceScreenDatas // updateDatas() >> " + myDevice)

        // Has datas? always display them
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

        //
        aioLineCharts.updateGraph()
    }

    function updateDatasBars(tempD, lumiD, hygroD, conduD) {
        temp.value = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempD) : tempD
        humi.value = hygroD
        lumi.value = lumiD
        condu.value = conduD
    }

    function resetDatasBars() {
        humi.value = myDevice.deviceHumidity
        temp.value = (settingsManager.tempUnit === "F") ? myDevice.deviceTempF : myDevice.deviceTempC
        lumi.value = myDevice.deviceLuminosity
        condu.value = myDevice.deviceConductivity
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: Theme.colorForeground
        height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 96 : 132
        z: 5

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Column {
            id: plantPanel
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.left: parent.left

            Text {
                id: textDeviceName
                height: 36
                anchors.left: parent.left
                anchors.leftMargin: 12

                visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

                font.pixelSize: 24
                text: myDevice.deviceName
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.AllUppercase
                color: Theme.colorText

                ImageSvg {
                    id: imageBattery
                    width: 32
                    height: 32
                    rotation: 90
                    anchors.verticalCenter: textDeviceName.verticalCenter
                    anchors.left: textDeviceName.right
                    anchors.leftMargin: 16

                    source: "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg"
                    color: Theme.colorIcons
                }
            }

            Item {
                id: itemPlant
                height: 28
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: labelPlant
                    width: 72
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Plant")
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 16
                }

                TextInput {
                    id: textInputPlant
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelPlant.right
                    anchors.leftMargin: 8

                    padding: 4
                    color: Theme.colorHighContrast
                    font.pixelSize: 16

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
                            color: Theme.colorIcons
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
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: labelLocation
                    width: 72
                    anchors.left: parent.left
                    anchors.leftMargin: 12

                    text: qsTr("Location")
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 16
                }

                TextInput {
                    id: textInputLocation
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelLocation.right
                    anchors.leftMargin: 8

                    padding: 4
                    color: Theme.colorHighContrast
                    font.pixelSize: 16

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
                            color: Theme.colorIcons
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
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelStatus
                    width: 72
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Status")
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 16
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
                    font.pixelSize: 16
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Grid {
        id: datasGrid
        columns: 1
        rows: 2
        spacing: (rows > 1) ? 12 : 0

        onWidthChanged: {
            if ((Qt.platform.os === "android" || Qt.platform.os === "ios")) {
                if (Screen.primaryOrientation === 1 /*Qt::PortraitOrientation*/) {
                    datasGrid.columns = 1
                    datasGrid.rows = 2
                } else {
                    datasGrid.columns = 2
                    datasGrid.rows = 1
                }
            }
        }

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        ImageSvg {
            id: imageOffline
            width: 96
            height: 96
            //anchors.horizontalCenter: datasColumns.horizontalCenter
            //anchors.verticalCenter: datasColumns.verticalCenter

            visible: !(myDevice.available || (myDevice.lastUpdateMin >= 0 && myDevice.lastUpdateMin <= 720))

            source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcons
        }

        Column {
            id: datasColumns
            width: datasGrid.width / datasGrid.columns

            visible: (myDevice.available || (myDevice.lastUpdateMin >= 0 && myDevice.lastUpdateMin <= 720))

            ItemDataBar {
                id: humi
                legend: qsTr("Moisture")
                unit: "%"
                color: Theme.colorBlue
                value: myDevice.deviceHumidity
                valueMin: 0
                valueMax: 50
                limitMin: myDevice.limitHygroMin
                limitMax: myDevice.limitHygroMax
            }
            ItemDataBar {
                id: temp
                legend: qsTr("Temperature")
                floatprecision: 1
                unit: "°" + settingsManager.tempUnit
                color: Theme.colorGreen
                value: (settingsManager.tempUnit === "F") ? myDevice.deviceTempF : myDevice.deviceTempC
                valueMin: (settingsManager.tempUnit === "F") ? 32 : 0
                valueMax: (settingsManager.tempUnit === "F") ? 104 : 40
                limitMin: (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(myDevice.limitTempMin) : myDevice.limitTempMin
                limitMax: (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(myDevice.limitTempMax) : myDevice.limitTempMax
            }
            ItemDataBar {
                id: lumi
                legend: qsTr("Luminosity")
                unit: " lumens"
                color: Theme.colorYellow
                value: myDevice.deviceLuminosity
                valueMin: 0
                valueMax: 10000
                limitMin: myDevice.limitLumiMin
                limitMax: myDevice.limitLumiMax
            }
            ItemDataBar {
                id: condu
                legend: qsTr("Fertility")
                unit: " µS/cm"
                color: Theme.colorRed
                value: myDevice.deviceConductivity
                valueMin: 0
                valueMax: 500
                limitMin: myDevice.limitConduMin
                limitMax: myDevice.limitConduMax
            }
        }

        Loader {
            id: pageLoader
            width: (datasGrid.width / datasGrid.columns)
            height: (datasGrid.columns == 1) ? (datasGrid.height - datasColumns.height - (datasGrid.rows > 1 ? datasGrid.spacing : 0)) : datasGrid.height

            visible: myDevice.hasDatas()
        }
    }
}
