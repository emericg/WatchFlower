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

import com.watchflower.theme 1.0

Rectangle {
    id: rectangleHeader
    width: 720
    height: 64
    color: Theme.colorHeaderDesktop

    property var leftIcon: buttonBack
    property bool menuVisible: true

    signal backButtonClicked()
    signal refreshButtonClicked()
    signal rescanButtonClicked()
    signal settingsButtonClicked()
    signal aboutButtonClicked()
    signal exitButtonClicked()

    ImageSvg {
        id: buttonBack
        width: 24
        height: 24
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/watchflower.svg"
        color: Theme.colorTitles

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
        anchors.left: parent.left
        anchors.leftMargin: 48
        anchors.verticalCenter: parent.verticalCenter

        text: "WatchFlower"
        color: "#FFFFFF"
        font.bold: true
        font.pixelSize: 30
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Row {
        id: menu
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 8

        spacing: 0
        visible: menuVisible

        ItemImageButton {
            id: buttonRefresh
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
            iconColor: Theme.colorTitles
            onClicked: refreshButtonClicked()

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
        }

        ItemImageButton {
            id: buttonRescan
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            iconColor: Theme.colorTitles
            onClicked: rescanButtonClicked()

            OpacityAnimator {
                id: rescanAnimation
                target: buttonRescan
                running: deviceManager.scanning
                loops: Animation.Infinite
                to: 1
                from: 0.5
                duration: 1000
            }
            OpacityAnimator {
                id: rescanAnimationStop
                target: buttonRescan
                running: false
                easing.type: Easing.OutExpo
                to: 1
                duration: 500
            }
        }

        ItemImageButton {
            id: imageSettings
            width: 48
            height: 48
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/baseline-tune-24px.svg"
            iconColor: Theme.colorTitles
            onClicked: settingsButtonClicked()()
        }

        ItemImageButton {
            id: imageAbout
            width: 48
            height: 48
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/assets/icons_material/outline-info-24px.svg"
            iconColor: Theme.colorTitles
            onClicked: aboutButtonClicked()
        }

        ImageSvg {
            id: buttonExit
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter

            visible: false

            source: {
                if (settingsManager.systray)
                    buttonExit.source = "qrc:/assets/icons_material/baseline-minimize-24px.svg"
                else
                    buttonExit.source = "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
            }
            color: Theme.colorTitles

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
}
