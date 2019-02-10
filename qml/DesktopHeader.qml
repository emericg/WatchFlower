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
import QtGraphicalEffects 1.0

Rectangle {
    id: rectangleHeader
    width: 720
    height: 64
    color: "#1dcb58"

    property var leftIcon: buttonBack
    signal backButtonClicked()
    signal refreshButtonClicked()
    signal rescanButtonClicked()
    signal settingsButtonClicked()
    signal exitButtonClicked()

    Connections {
        target: deviceManager
        onScanningChanged: {
            if (deviceManager.scanning)
                rescanAnimation.start()
            else
                rescanAnimation.stop()
        }
        onRefreshingChanged: {
            if (deviceManager.refreshing)
                refreshAnimation.start()
            else
                refreshAnimation.stop()
        }
    }
    Connections {
        target: settingsManager
        onSystrayChanged: {
            if (settingsManager.systray)
                buttonExit.source = "qrc:/assets/icons_material/baseline-minimize-24px.svg"
            else
                buttonExit.source = "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
        }
    }

    Text {
        text: "WatchFlower"
        anchors.left: parent.left
        anchors.leftMargin: 48
        color: "#FFFFFF"
        font.bold: true
        font.pixelSize: 30
        antialiasing: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: buttonBack
        width: 24
        height: 24
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/watchflower.svg"
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: "white"
        }

        MouseArea {
            anchors.fill: parent

            onPressed: {
                buttonBack.anchors.topMargin += 2
                buttonBack.anchors.leftMargin += 2
                buttonBack.width -= 4
                buttonBack.height -= 4
            }
            onReleased: {
                buttonBack.anchors.topMargin -= 2
                buttonBack.anchors.leftMargin -= 2
                buttonBack.width += 4
                buttonBack.height += 4
            }
            onClicked: backButtonClicked()
        }
    }

    Image {
        id: buttonRefresh
        width: 24
        height: 24
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: buttonRescan.left
        anchors.rightMargin: 12

        source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit

        NumberAnimation on rotation {
            id: refreshAnimation
            duration: 2000
            from: 0
            to: 360
            loops: Animation.Infinite
            running: deviceManager.refreshing
            onStopped: refreshAnimationStop.start()
        }
        NumberAnimation on rotation {
            id: refreshAnimationStop
            duration: 1000;
            to: 360;
            easing.type: Easing.OutExpo
            running: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: refreshButtonClicked()
        }
    }

    Image {
        id: buttonRescan
        width: 24
        height: 24
        anchors.right: imageSettings.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/icons_material/baseline-search-24px.svg"
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit

        OpacityAnimator {
            id: rescanAnimation
            target: buttonRescan
            duration: 1000
            from: 0.5
            to: 1
            loops: Animation.Infinite
            running: deviceManager.scanning
            onStopped: rescanAnimationStop.start()
        }
        OpacityAnimator {
            id: rescanAnimationStop
            target: buttonRescan
            duration: 500
            to: 1
            easing.type: Easing.OutExpo
            running: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: rescanButtonClicked()
        }
    }

    Image {
        id: imageSettings
        width: 32
        height: 32
        anchors.right: buttonExit.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/icons_material/baseline-tune-24px.svg"
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent
            onClicked: settingsButtonClicked()
        }
    }

    Image {
        id: buttonExit
        width: 32
        height: 32
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: {
            if (settingsManager.systray)
                buttonExit.source = "qrc:/assets/icons_material/baseline-minimize-24px.svg"
            else
                buttonExit.source = "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
        }
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (settingsManager.systray)
                    applicationWindow.hide()
                else
                    exitButtonClicked()
            }
        }
    }
}
