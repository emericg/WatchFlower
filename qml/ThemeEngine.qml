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

pragma Singleton
import QtQuick 2.7

Item {
    // Headers
    readonly property string colorHeader: "#07bf97"
    readonly property string colorHeaderStatusbar: "#009688"
    readonly property string colorHeaderContent: "white"

    // Actually used colors
    readonly property string colorMaterialLightGrey: "#f8f8f8"
    readonly property string colorMaterialDarkGrey: "#ececec"

    readonly property string colorGood: "#83d83a"
    readonly property string colorBad: "#ffba5a"
    readonly property string colorNeutralDay: "#e4e4e4"
    readonly property string colorNeutralNight: "#ffb300"

    readonly property string colorTitles: "#FFFFFF"
    readonly property string colorText: "#333333"
    readonly property string colorSubText: "#666666"

    readonly property string colorIcons: "#606060"
    readonly property string colorSeparators: "#d3d3d3"

    // Palette
    readonly property string colorLightGreen: "#09debc"
    readonly property string colorGreen: "#07bf97"
    readonly property string colorDarkGreen: "#1ea892"
    readonly property string colorBlue: "#408ab4"
    readonly property string colorYellow: "#ffba5a"
    readonly property string colorRed: "#ff7657"
    readonly property string colorGrey: "#555151"
    readonly property string colorLightGrey: "#a9bcb8"

    // Fonts (sizes in pixel) (WIP)
    readonly property int fontSizeHeader: 30
    readonly property int fontSizeTitle: 17
    readonly property int fontSizeContent: 15
}
