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

import QtQuick 2.7
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

Item {
    id: deviceDatas
    width: 400
    height: 300

    function updateHeader() {
        if (typeof myDevice === "undefined") return
    }

    function loadDatas() {
        if (typeof myDevice === "undefined") return
    }

    function updateDatas() {
        if (typeof myDevice === 'undefined' || !myDevice) return
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
            id: plantPanel
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.left: parent.left

            Text {
                id: textDeviceName
                height: 32
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
                    font.pixelSize: 15
                }
                Text {
                    id: textStatus
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: labelStatus.right
                    anchors.leftMargin: 8

                    text: qsTr("Loading...")
                    color: Theme.colorText
                    padding: 4
                    font.pixelSize: 16
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        clip: true

        anchors.top: rectangleHeader.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Item { anchors.fill: parent } // HACK // so the scrollview content resizes?

        Column {
            id: column
            anchors.fill: parent

            //
        }
    }
}
