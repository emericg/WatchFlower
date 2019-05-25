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

import com.watchflower.theme 1.0

Item {
    anchors.fill: parent

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        ImageSvg {
            id: image
            width: 256
            height: 256
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcons

            OpacityAnimator {
                id: rescanAnimation
                target: image
                duration: 1000
                from: 0.33
                to: 1
                loops: Animation.Infinite
                running: deviceManager.scanning
                onStopped: rescanAnimationStop.start()
            }
            OpacityAnimator {
                id: rescanAnimationStop
                target: image
                duration: 500
                to: 1
                easing.type: Easing.OutExpo
                running: false
            }
        }

        Text {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            visible: (Qt.platform.os === "android")

            text: qsTr("On Android 6+, scanning for Bluetooth low energy devices needs location permissions. The application is not using or storing GPS, sorry for the inconveniance.")
            wrapMode: Text.WordWrap
            font.pixelSize: 16
        }

        Item { width: 1; height: 16; }

        ButtonThemed {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: (Qt.platform.os === "android")

            text: qsTr("Official informations")
            onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth-le#permissions")
        }
    }
}
