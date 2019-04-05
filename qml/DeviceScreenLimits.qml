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

import QtQuick 2.7
import QtQuick.Controls 2.0

import com.watchflower.theme 1.0

Item {
    id: deviceScreenLimits

    function updateLimits() {
        if (myDevice) {
            rangeSlider_hygro.first.value = myDevice.limitHygroMin
            rangeSlider_hygro.second.value = myDevice.limitHygroMax
            rangeSlider_temp.first.value = myDevice.limitTempMin
            rangeSlider_temp.second.value = myDevice.limitTempMax
            rangeSlider_condu.first.value = myDevice.limitConduMin
            rangeSlider_condu.second.value = myDevice.limitConduMax
        }
    }

    function updateLimitsVisibility() {
        if (myDevice) {
            itemTemp.visible = true
            itemHygro.visible = true
            itemLumi.visible = true
            itemCondu.visible = true

            if ((myDevice.deviceCapabilities & 2) == 0) {
                itemTemp.visible = false
            }
            if ((myDevice.deviceCapabilities & 4) == 0) {
                itemHygro.visible = false
            }
            if ((myDevice.deviceCapabilities & 8) == 0) {
                itemLumi.visible = false
            }
            if ((myDevice.deviceCapabilities & 16) == 0) {
                itemCondu.visible = false
            }
        }
    }

    Column {
        id: column
        anchors.fill: parent

        Item {
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
                text: rangeSlider_hygro.first.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.left: imageHygro.right
            }
            ThemedRangeSlider {
                id: rangeSlider_hygro
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: text9.left
                anchors.left: text8.right
                anchors.leftMargin: 4
                anchors.rightMargin: 4

                from: 1
                to: 66
                stepSize: 1
                first.value: myDevice.limitHygroMin
                second.value: myDevice.limitHygroMax
                first.onValueChanged: myDevice.limitHygroMin = first.value.toFixed(0);
                second.onValueChanged: myDevice.limitHygroMax = second.value.toFixed(0);
            }
            Text {
                id: text9
                width: 40
                height: 40
                text: rangeSlider_hygro.second.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 4
            }
        }

        Item {
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
                source: "qrc:/assets/icons_material/baseline-pin_drop-24px.svg"
                color: Theme.colorIcons
            }
            Text {
                id: text3
                width: 40
                height: 40
                text: rangeSlider_temp.first.value.toFixed(0)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: imageTemp.right
                font.pixelSize: 14
            }
            ThemedRangeSlider {
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
                first.value: myDevice.limitTempMin
                second.value: myDevice.limitTempMax
                first.onValueChanged: myDevice.limitTempMin = first.value.toFixed(0);
                second.onValueChanged: myDevice.limitTempMax = second.value.toFixed(0);
            }
            Text {
                id: text5
                width: 40
                height: 40
                text: rangeSlider_temp.second.value.toFixed(0)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
            }
        }

        Item {
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
                text: qsTr("MIN")
                anchors.left: imageLumi.right
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
            }
            SpinBox {
                id: spinBox1
                anchors.left: text1.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: 1
                to: 5000
                stepSize: 100
                value: myDevice.limitLumiMin
                onValueChanged: myDevice.limitLumiMin = value;
            }
            SpinBox {
                id: spinBox2
                anchors.left: spinBox1.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                from: 500
                to: 50000
                stepSize: 100
                value: myDevice.limitLumiMax
                onValueChanged: myDevice.limitLumiMax = value;
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
                font.pixelSize: 14
            }
        }

        Item {
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
                text: rangeSlider_condu.second.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 4
            }
            ThemedRangeSlider {
                id: rangeSlider_condu
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: text7.left
                anchors.left: text6.right
                anchors.leftMargin: 4
                anchors.rightMargin: 4

                from: 100
                to: 1000
                stepSize: 10
                first.value: myDevice.limitConduMin
                second.value: myDevice.limitConduMax
                first.onValueChanged: myDevice.limitConduMin = first.value.toFixed(0);
                second.onValueChanged: myDevice.limitConduMax = second.value.toFixed(0);
            }
            Text {
                id: text6
                width: 40
                height: 40
                text: rangeSlider_condu.first.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.left: imageCondu.right
            }
        }

        Item {
            id: itemDone
            height: 64
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

            ThemedButton {
                id: buttonDone
                width: 140
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("OK I'm done!")
                font.pointSize: 14
                onClicked: rectangleContent.state = "datas"
            }
        }
    }
}
