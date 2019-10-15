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

import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Item {
    anchors.fill: parent

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -26

        ImageSvg {
            id: imageSearch
            width: 200
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcon

            OpacityAnimator {
                id: rescanAnimation
                target: imageSearch
                duration: 1000
                from: 0.33
                to: 1
                loops: Animation.Infinite
                running: deviceManager.scanning
                onStopped: rescanAnimationStop.start()
            }
            OpacityAnimator {
                id: rescanAnimationStop
                target: imageSearch
                duration: 500
                to: 1
                easing.type: Easing.OutExpo
                running: false
            }
        }

        Text {
            anchors.right: parent.right
            anchors.left: parent.left

            visible: (Qt.platform.os === "android")

            text: qsTr("On Android 6+, scanning for Bluetooth Low Energy devices needs location permission. The application is neither using or storing your location. Sorry for the inconveniance.")
            font.pixelSize: 14
            color: Theme.colorSubText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Item { width: 1; height: 16; anchors.horizontalCenter: parent.horizontalCenter } // spacer

        Row {
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            ButtonWireframe {
                height: 40
                visible: (Qt.platform.os === "android")

                text: qsTr("Official informations")
                primaryColor: Theme.colorSubText
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth-le#permissions")
            }

            ButtonWireframe {
                height: 40

                text: qsTr("Launch detection")
                primaryColor: Theme.colorPrimary
                onClicked: deviceManager.scanDevices()
            }
        }
    }
}
