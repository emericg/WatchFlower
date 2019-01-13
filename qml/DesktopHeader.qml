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
                rescanRotation.start()
            else
                rescanRotation.stop()
        }
        onRefreshingChanged: {
            if (deviceManager.refreshing)
                refreshRotation.start()
            else
                refreshRotation.stop()
        }
    }

    Text {
        text: "WatchFlower"
        anchors.left: parent.left
        anchors.leftMargin: 48
        color: "#FFFFFF"
        font.bold: true
        font.pixelSize: 36
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
        width: 36
        height: 36
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: buttonRescan.left
        anchors.rightMargin: 16

        source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit

        NumberAnimation on rotation {
            id: refreshRotation
            duration: 3000;
            from: 0;
            to: 360;
            loops: Animation.Infinite
            running: deviceManager.scanning
            onStopped: refreshRotationStop.start()
        }
        NumberAnimation on rotation {
            id: refreshRotationStop
            duration: 1000;
            to: 360;
            easing.type: Easing.OutQuart
            running: false
        }

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: "white"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: refreshButtonClicked()
        }
    }

    Image {
        id: buttonRescan
        width: 36
        height: 36
        anchors.right: imageSettings.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/icons_material/baseline-search-24px.svg"
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit

        NumberAnimation on rotation {
            id: rescanRotation
            duration: 3000;
            from: 0;
            to: 360;
            loops: Animation.Infinite
            running: false
            onStopped: rescanRotationStop.start()
        }
        NumberAnimation on rotation {
            id: rescanRotationStop
            duration: 1000;
            to: 360;
            easing.type: Easing.OutQuart
            running: false
        }

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: "white"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: rescanButtonClicked()
        }
    }

    Image {
        id: imageSettings
        width: 36
        height: 36
        anchors.right: buttonExit.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/icons_material/baseline-tune-24px.svg"
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
            onClicked: settingsButtonClicked()
        }
    }

    Image {
        id: buttonExit
        width: 36
        height: 36
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        source: "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
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
            onClicked: exitButtonClicked()
        }
    }
}
