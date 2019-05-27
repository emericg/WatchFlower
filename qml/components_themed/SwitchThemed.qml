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

Switch {
    id: control
    font.bold: true

    indicator: Rectangle {
        implicitWidth: 40
        implicitHeight: 16
        x: control.leftPadding
        y: parent.height / 2 - height / 2

        radius: 13
        //border.color: Theme.colorBorders
        color: control.checked ? "#8dd9ca" : Theme.colorBorders

        Rectangle {
            x: control.checked ? parent.width - width : 0
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            radius: 12
            color: control.checked ? Theme.colorGreen : "#e0e0e0"
            border.color: control.checked ? Theme.colorGreen : "#e0e0e0"
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: Theme.colorText
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
