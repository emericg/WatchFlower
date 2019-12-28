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
        id: column
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -12
        spacing: -8

        ImageSvg {
            width: isDesktop ? 128 : (parent.width*0.33)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/assets/icons_material/baseline-timeline-24px.svg"
            color: Theme.colorSubText
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Not enough datas")
            font.pixelSize: 16
            color: Theme.colorSubText
        }
    }
}
