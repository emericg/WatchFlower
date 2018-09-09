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

Rectangle {
    id: rectangleHeader
    width: parent.width
    height: 56
    color: "#1dcb58"

    property alias menuButtonImg: buttonImg
    property alias menuScanImg: refreshRotation

    signal menuButtonClicked()

    Text {
        text: "WatchFlower"
        color: "#FFFFFF"
        font.bold: true
        font.pointSize: 26
        antialiasing: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: buttonImg
        y: 12
        width: 32
        height: 32
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/menu_back.svg"
        fillMode: Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent

            onPressed: {
                buttonImg.anchors.topMargin += 2
                buttonImg.anchors.leftMargin += 2
                buttonImg.width -= 4
                buttonImg.height -= 4
            }
            onReleased: {
                buttonImg.anchors.topMargin -= 2
                buttonImg.anchors.leftMargin -= 2
                buttonImg.width += 4
                buttonImg.height += 4
            }
            onClicked: menuButtonClicked()
        }
    }

    Image {
        id: refreshImg
        width: 32
        height: 32
        visible: false
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/refresh.svg"
        fillMode: Image.PreserveAspectFit

        NumberAnimation on rotation {
            id: refreshRotation
            duration: 3000;
            from: 0;
            to: 360;
            loops: Animation.Infinite
            running: false

            onStarted: refreshImg.visible = true
            onStopped: refreshImg.visible = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: refreshClicked()
        }
    }
}
