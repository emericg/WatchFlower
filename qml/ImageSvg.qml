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

import QtQuick 2.7
import QtQuick.Controls 2.0

import QtGraphicalEffects 1.0
import com.watchflower.theme 1.0

Item {
    width: 32
    height: 32

    property string source
    property string color
    property int fillMode: Image.PreserveAspectFit

    Image {
        id: sourceImg
        anchors.fill: parent
        visible: color ? false : true

        source: parent.source
        sourceSize: Qt.size(width, height)
        fillMode: parent.fillMode
    }
    ColorOverlay {
        source: sourceImg
        anchors.fill: parent
        visible: color ? true : false

        color: parent.color
        cached: true
    }
}
