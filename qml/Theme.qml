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
    readonly property string colorHeaderDesktop: "#4E598C"
    readonly property string colorHeaderMobile: "#58b79b"
    readonly property string colorHeaderMobileStatusbar: "#449287"

    // Material
    readonly property string colorMaterialLightGrey: "#f8f8f8" // desktop BG
    readonly property string colorMaterialDarkGrey: "#ececec"
    readonly property string colorMaterialLightGreen: "#00c853"

    // Actually used colors...
    readonly property string colorGood: "#87d241"
    readonly property string colorBad: "#ffbf66"
    readonly property string colorNeutralDay: "#e4e4e4"
    readonly property string colorNeutralNight: "#ffb300"

    readonly property string colorTitles: "#FFFFFF"
    readonly property string colorText: "#333333"
    readonly property string colorSubText: "#666666"

    readonly property string colorBarHygro: "#31A3EC"
    readonly property string colorBarTemp: "#87D241"
    readonly property string colorBarLumi: "#F1EC5C"
    readonly property string colorBarCond: "#E19C2F"

    // statusbar: "#1abc9c"
    // header: "#009688"
    // select: bbebe1

    // Palette (WIP)
    readonly property string colorLightGreen: "#09debc"
    readonly property string colorGreen: "#07bf97"
    readonly property string colorDarkGreen: "#1ea892"
    readonly property string colorBlue: "#408ab4"
    readonly property string colorYellow: "#ffba5a"
    readonly property string colorRed: "#ff7657"
    readonly property string colorBrown: "#555151"
    readonly property string colorGrey: "#555151"

    // Fonts (sizes in pixel) (WIP)
    readonly property int fontSizeHeader: 30
    readonly property int fontSizeTitle: 17
    readonly property int fontSizeContent: 15
}
