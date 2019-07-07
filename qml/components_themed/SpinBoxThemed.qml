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

SpinBox {
    id: control
    value: 50
    editable: true
    clip: true
    font.pixelSize: 14

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale) // + qsTr("min.")

        font: control.font
        color: Theme.colorSubText
        selectionColor: Theme.colorText
        selectedTextColor: "white"
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -8
            color: Theme.colorForeground
        }
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.up.pressed ? Theme.colorComponentBgDown : Theme.colorComponentBgUp
        //border.color: enabled ? Theme.colorSubText : Theme.colorSubText
        radius: 4

        Text {
            text: "+"
            font.pixelSize: 20
            color: enabled ? Theme.colorText : Theme.colorSubText
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.down.pressed ? Theme.colorComponentBgDown : Theme.colorComponentBgUp
        //border.color: enabled ? Theme.colorSubText : Theme.colorSubText
        radius: 4

        Text {
            text: "-"
            font.pixelSize: 30
            color: enabled ? Theme.colorText : Theme.colorSubText
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 128
        z: 3
        color: "transparent"
        border.color: Theme.colorComponentBorder
        radius: 4
    }
}
