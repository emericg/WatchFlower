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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.7
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Rectangle {
    id: rectangleHeader
    width: parent.width
    height: screenTopPadding + 56
    color: "#1dcb58"

    property int screenOrientation: Screen.primaryOrientation // 1 = Qt::PortraitOrientation, 2 = Qt::LandscapeOrientation
    property int screenTopPadding: 0

    signal leftMenuClicked()
    signal rightMenuClicked()

    function handleNotches() {
        var safeMargins = settingsManager.getSafeAreaMargins(quickWindow)
        if (Screen.primaryOrientation === 1 && safeMargins["total"] > 0)
            screenTopPadding = 30
        else
            screenTopPadding = 0
    }

    onScreenOrientationChanged: {
/*
        console.log("screen orientation changed")

        var screenPadding = (Screen.height - Screen.desktopAvailableHeight)
        console.log("screen height : " + Screen.height)
        console.log("screen avail  : " + Screen.desktopAvailableHeight)
        console.log("screen padding: " + screenPadding)

        var safeMargins = settingsManager.getSafeAreaMargins(quickWindow)
        console.log("top:" + safeMargins["top"])
        console.log("right:" + safeMargins["right"])
        console.log("bottom:" + safeMargins["bottom"])
        console.log("left:" + safeMargins["left"])
*/
        handleNotches()
    }

    Component.onCompleted: {
        handleNotches()
    }

    Connections {
        target: quickWindow
        onChanged: {
            //
        }
    }

    Rectangle {
        color: "transparent"
        anchors.fill: parent
        anchors.topMargin: screenTopPadding

        Text {
            text: "WatchFlower"
            color: "#FFFFFF"
            font.bold: true
            font.pixelSize: 36
            antialiasing: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Image {
            id: leftMenuImg
            width: 32
            height: 32
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit

            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: leftMenuClicked()
            }
        }

        Image {
            id: rightMenuImg
            width: 32
            height: 32
            visible: false
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-more_vert-24px.svg"
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit

            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: rightMenuClicked()
            }
        }
    }
}
