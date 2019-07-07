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
    font.pixelSize: 14
    font.bold: true

    indicator: Rectangle {
        implicitWidth: 40
        implicitHeight: 16
        x: control.leftPadding
        y: parent.height / 2 - height / 2

        radius: 13
        //border.color: Theme.colorComponentBorder
        color: control.checked ? Theme.colorHighlight2 : Theme.colorComponentBorder

        Rectangle {
            x: control.checked ? parent.width - width : 0
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            radius: 12
            color: control.checked ? Theme.colorHighlight : Theme.colorNeutralDay
            border.color: control.checked ? Theme.colorHighlight : Theme.colorNeutralDay
        }
    }

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing

        text: control.text
        font: control.font
        color: Theme.colorText
        opacity: enabled ? 1.0 : 0.3
    }
}
