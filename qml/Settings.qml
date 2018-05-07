/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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

Rectangle {
    id: settingsRectangle
    color: "#eefbdb"
    width: 400
    height: 640

    Header {
        id: header
        anchors.top: parent.top

        backAvailable.visible: true
        scanAvailable.visible: false

        onBackClicked: {
            pageLoader.source = "main.qml"
        }
    }

    Rectangle {
        id: rectangleBody
        color: "#ccffffff"
        border.width: 0

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        MouseArea {
            id: mouseArea // so the underlying stuff doesn't hijack clicks
            anchors.fill: parent
        }

        Rectangle {
            id: rectangleHeader
            height: 80
            color: "#e8e9e8"
            border.width: 0

            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            Text {
                id: textAddr
                y: 46
                width: 375
                height: 16
                text: "Change persistent settings here"
                anchors.left: parent.left
                anchors.leftMargin: 13
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
            }

            Text {
                id: text1
                height: 32
                color: "#454b54"
                text: qsTr("Settings")
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.top: parent.top
                anchors.topMargin: 12
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 26
            }
        }

        Rectangle {
            id: rectanglePlant
            y: 41
            width: 368
            height: 110
            color: "#f2f2f2"
            border.width: 0
            anchors.top:rectangleHeader.bottom
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Image {
                id: imagePlant
                width: 32
                height: 32
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                source: "../assets/app/icon_tray.svg"
            }

            CheckBox {
                id: checkBox_systray
                width: 332
                height: 32
                text: qsTr("Enables tray icon")
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 8
            }

            SpinBox {
                id: spinBox_update
                y: 71
                width: 128
                height: 40
                from: 30
                value: 30
                stepSize: 30
                to: 120
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
            }

            Text {
                id: text2
                y: 58
                width: 234
                height: 40
                text: qsTr("Update interval in minutes")
                renderType: Text.QtRendering
                font.pointSize: 12
                verticalAlignment: Text.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                anchors.left: spinBox_update.right
                anchors.leftMargin: 14
            }
        }

    }
}
