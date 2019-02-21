/*!
 * This file is part of OffloadBuddy.
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
    readonly property string colorHeaderMobile: "#00c853"
    readonly property string colorHeaderMobileStatusbar: "#009624"

    // Material
    readonly property string colorMaterialLightGrey: "#f8f8f8"
    readonly property string colorMaterialDarkGrey: "#ececec"
    readonly property string colorMaterialLightGreen: "#00c853"
    readonly property string colorMaterialDarkGreen: "#84E351"
    readonly property string colorMaterialOrange: "#ffb300"

    // Actually used colors...
    readonly property string colorGood: "#87d241"
    readonly property string colorBad: "#ffbf66"
    readonly property string colorNeutralDay: "#e4e4e4"
    readonly property string colorNeutralNight: "#ffb300"

    readonly property string colorTitles: "#454B54"
    readonly property string colorText: "#505050"
    readonly property string colorIcons: "#606060"

    readonly property string colorBarHygro: "#31A3EC"
    readonly property string colorBarTemp: "#87D241"
    readonly property string colorBarLumi: "#F1EC5C"
    readonly property string colorBarCond: "#E19C2F"

    // statusbar: "#1abc9c"
    // header: "#009688"
    // select: bbebe1

    // Palette (WIP)
    readonly property string colorRed: "#ff7657"
    readonly property string colorOrange: "#ffb74c"
    readonly property string colorBlue: "#408ab4"
    readonly property string colorGreen1: "#c9ffc7"
    readonly property string colorGreen2: "#2ecc71"
    readonly property string colorGreen3: "#27ae60"
    readonly property string colorGreen4: "#1abc9c"
    readonly property string colorDarkGrey: "#555151"
    readonly property string colorBlueGrey: "#a9bcb8"

    // Fonts (sizes in pixel) (WIP)
    readonly property int fontSizeHeader: 30
    readonly property int fontSizeTitle: 17
    readonly property int fontSizeContent: 15
}
