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
import QtQuick.Window 2.2

import com.watchflower.theme 1.0

Rectangle {
    id: rectangleHeader
    width: parent.width
    height: screenTopPadding + barHeight
    color: Theme.colorHeader

    // Border can be good for material design
    //border.width: 1
    //border.color: Theme.colorHeader

    property int barHeight: 52

    property int screenOrientation: Screen.primaryOrientation // 1 = Qt::PortraitOrientation, 2 = Qt::LandscapeOrientation
    property int screenTopPadding: 0

    property string title: "WatchFlower"
    property string leftMenuMode: "drawer"
    property bool rightMenuEnabled: false

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

    onLeftMenuModeChanged: {
        if (leftMenuMode === "drawer")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-menu-24px.svg"
        else if (leftMenuMode === "close")
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-close-24px.svg"
        else // back
            leftMenuImg.source = "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
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

    Item {
        anchors.fill: parent
        anchors.topMargin: screenTopPadding

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 68
            anchors.verticalCenter: parent.verticalCenter

            text: title
            color: Theme.colorHeaderContent
            font.bold: false
            font.pixelSize: 26
            font.capitalization: Font.Capitalize
            antialiasing: true
        }

        MouseArea {
            id: leftArea
            width: barHeight
            height: barHeight
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            onClicked: leftMenuClicked()

            ImageSvg {
                id: leftMenuImg
                width: barHeight/2
                height: barHeight/2
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                color: Theme.colorHeaderContent
            }
        }

        MouseArea {
            id: rightArea
            width: barHeight
            height: barHeight
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            enabled:rightMenuEnabled
            onClicked: rightMenuClicked()

            ImageSvg {
                id: rightMenuImg
                width: barHeight/2
                height: barHeight/2
                visible: rightMenuEnabled
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-more_vert-24px.svg"
                color: Theme.colorHeaderContent
            }
        }
    }
}
