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
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 0
        spacing: 16

        ImageSvg {
            width: 200
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcons
        }

        ButtonThemed {
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter

            color: Theme.colorHighlight
            text: (Qt.platform.os === "android") ? qsTr("Enable Bluetooth") : qsTr("Retry detection")
            onClicked: (Qt.platform.os === "android") ? deviceManager.enableBluetooth() : deviceManager.checkBluetooth()
        }
    }
}
