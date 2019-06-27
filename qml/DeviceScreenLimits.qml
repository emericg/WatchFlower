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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0
import "UtilsNumber.js" as UtilsNumber

Item {
    id: deviceScreenLimits

    function updateHeader() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreenLimits // updateHeader() >> " + myDevice)

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
                imageBattery.color = Theme.colorYellow
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
            } else {
                imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            }
        } else {
            imageBattery.source = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
            imageBattery.visible = false
        }

        // Sensor address
        if (myDevice.deviceAddress.charAt(0) !== '{')
            textAddr.text = "[" + myDevice.deviceAddress + "]"

        // Firmware
        textFirmware.text = myDevice.deviceFirmware
        if (!myDevice.deviceFirmwareUpToDate) {
            imageFwUpdate.visible = true
            textFwUpdate.visible = true
        } else {
            imageFwUpdate.visible = false
            textFwUpdate.visible = false
        }
    }

    function updateLimits() {
        if (typeof myDevice === "undefined" || !myDevice) return

        rangeSlider_hygro.first.value = myDevice.limitHygroMin
        rangeSlider_hygro.second.value = myDevice.limitHygroMax
        rangeSlider_temp.first.value = myDevice.limitTempMin
        rangeSlider_temp.second.value = myDevice.limitTempMax
        spinBox1.value = myDevice.limitLumiMin
        spinBox2.value = myDevice.limitLumiMax
        rangeSlider_condu.first.value = myDevice.limitConduMin
        rangeSlider_condu.second.value = myDevice.limitConduMax
    }

    function updateLimitsVisibility() {
        if (typeof myDevice === "undefined" || !myDevice) return

        itemTemp.visible = myDevice.hasTemperatureSensor()
        itemHygro.visible = myDevice.hasHygrometrySensor() || myDevice.hasSoilMoistureSensor()
        itemLumi.visible = myDevice.hasLuminositySensor()
        itemCondu.visible = myDevice.hasConductivitySensor()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Theme.colorMaterialLightGrey : Theme.colorMaterialDarkGrey
        height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 96 : 132

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Column {
            id: devicePanel
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
                id: address
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelAddress
                    width: 72
                    anchors.leftMargin: 12
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Address")
                    horizontalAlignment: Text.AlignRight
                    color: Theme.colorText
                    font.pixelSize: 16
                }

                Text {
                    id: textAddr
                    anchors.left: labelAddress.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: myDevice.deviceAddress
                    font.pixelSize: 16
                }
            }

            Item {
                id: firmware
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: labelFirmware
                    width: 72
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    text: qsTr("Firmware")
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    id: textFirmware
                    anchors.left: labelFirmware.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Update available!")
                    font.pixelSize: 16
                }
                ImageSvg {
                    id: imageFwUpdate
                    width: 20
                    height: 20
                    anchors.left: textFirmware.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-new_releases-24px.svg"
                    color: Theme.colorIcons

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: textFwUpdate.text = qsTr("Use official app to upgrade")
                        onExited: textFwUpdate.text = qsTr("Update available!")
                    }
                }

                Text {
                    id: textFwUpdate
                    text: qsTr("Update available!")
                    anchors.left: imageFwUpdate.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                }
            }

            Item {
                id: battery
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Text {
                    id: textBattery
                    anchors.left: labelBattery.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: myDevice.deviceBattery + "%"
                    font.pixelSize: 16
                }

                Text {
                    id: labelBattery
                    width: 72
                    horizontalAlignment: Text.AlignRight
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Battery")
                    color: Theme.colorText
                    font.pixelSize: 16
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item { // ScrollView {
        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        //Item { anchors.fill: parent } // HACK // so the scrollview content resizes?

        Column {
            id: column
            anchors.fill: parent

            Item { //////
                id: itemHygro
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: imageHygro
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-opacity-24px.svg"
                    color: Theme.colorIcons
                }
                Text {
                    id: text8
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: imageHygro.right

                    text: rangeSlider_hygro.first.value.toFixed(0)
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                RangeSliderThemed {
                    id: rangeSlider_hygro
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: text9.left
                    anchors.left: text8.right
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4

                    from: 0
                    to: 66
                    stepSize: 1
                    first.onValueChanged: if (myDevice) myDevice.limitHygroMin = first.value.toFixed(0);
                    second.onValueChanged: if (myDevice) myDevice.limitHygroMax = second.value.toFixed(0);
                    Component.onCompleted: {
                        if (myDevice) {
                            first.value = myDevice.limitHygroMin
                            second.value = myDevice.limitHygroMax
                        }
                    }
                }
                Text {
                    id: text9
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 4

                    text: rangeSlider_hygro.second.value.toFixed(0)
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item { //////
                id: itemTemp
                height: 64
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                ImageSvg {
                    id: imageTemp
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
                    color: Theme.colorIcons
                }
                Text {
                    id: text3
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: imageTemp.right

                    text: (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(rangeSlider_temp.first.value).toFixed(0) : rangeSlider_temp.first.value.toFixed(0)
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                RangeSliderThemed {
                    id: rangeSlider_temp
                    height: 40
                    anchors.right: text5.left
                    anchors.rightMargin: 4
                    anchors.left: text3.right
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    from: 0
                    to: 40
                    stepSize: 1
                    first.onValueChanged: if (myDevice) myDevice.limitTempMin = first.value.toFixed(0);
                    second.onValueChanged: if (myDevice) myDevice.limitTempMax = second.value.toFixed(0);
                    Component.onCompleted: {
                        if (myDevice) {
                            first.value = myDevice.limitTempMin
                            second.value = myDevice.limitTempMax
                        }
                    }
                }
                Text {
                    id: text5
                    width: 40
                    height: 40
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    text: (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(rangeSlider_temp.second.value).toFixed(0) : rangeSlider_temp.second.value.toFixed(0)
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item { //////
                id: itemLumi
                height: 64
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                ImageSvg {
                    id: imageLumi
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-wb_sunny-24px.svg"
                    color: Theme.colorIcons
                }
                Text {
                    id: text1
                    width: 40
                    height: 40
                    anchors.left: imageLumi.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("MIN")
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                SpinBoxThemed {
                    id: spinBox1
                    height: 36
                    anchors.left: text1.right
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    from: 0
                    to: 5000
                    stepSize: 100
                    Component.onCompleted: if (myDevice) value = myDevice.limitLumiMin;
                    onValueChanged: if (myDevice) myDevice.limitLumiMin = value;
                }
                SpinBoxThemed {
                    id: spinBox2
                    height: 36
                    anchors.left: spinBox1.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    from: 500
                    to: 50000
                    stepSize: 100
                    Component.onCompleted: if (myDevice) value = myDevice.limitLumiMax;
                    onValueChanged: if (myDevice) myDevice.limitLumiMax = value;
                }
                Text {
                    id: text2
                    width: 40
                    height: 40
                    text: qsTr("MAX")
                    anchors.left: spinBox2.right
                    anchors.leftMargin: 8
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 12
                }
            }

            Item { //////
                id: itemCondu
                height: 64
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: imageCondu
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-flash_on-24px.svg"
                    color: Theme.colorIcons
                }
                Text {
                    id: text7
                    width: 40
                    height: 40
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    text: rangeSlider_condu.second.value.toFixed(0)
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                RangeSliderThemed {
                    id: rangeSlider_condu
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: text7.left
                    anchors.left: text6.right
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4

                    from: 0
                    to: 750
                    stepSize: 10
                    first.onValueChanged: if (myDevice) myDevice.limitConduMin = first.value.toFixed(0);
                    second.onValueChanged: if (myDevice) myDevice.limitConduMax = second.value.toFixed(0);
                    Component.onCompleted: {
                        if (myDevice) {
                            first.value = myDevice.limitConduMin
                            second.value = myDevice.limitConduMax
                        }
                    }
                }
                Text {
                    id: text6
                    width: 40
                    height: 40
                    anchors.left: imageCondu.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: rangeSlider_condu.first.value.toFixed(0)
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
