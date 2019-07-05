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
import QtQuick 2.9

Item {
    enum ThemeNames {
        THEME_GREEN = 0,
        THEME_DAY = 1,
        THEME_NIGHT = 2,

        THEME_LAST
    }
    property int currentTheme: -1

    // Headers
    property string colorHeader
    property string colorHeaderStatusbar
    property string colorHeaderContent

    // Content
    property string colorBackground
    property string colorForeground

    property string colorHighlight
    property string colorHighlight2
    property string colorHighContrast

    property string colorText
    property string colorSubText
    property string colorIcons

    property string colorBordersDrawer
    property string colorBordersWidget
    property string colorBordersComponents
    property string colorBgUpComponents
    property string colorBgDownComponents

    // Palette colors
    //property string colorLightGreen: "#09debc"
    property string colorGreen
    //property string colorDarkGreen: "#1ea892"
    property string colorBlue
    property string colorYellow
    property string colorRed
    //property string colorGrey: "#555151"
    property string colorLightGrey

    // Fixed colors
    readonly property string colorMaterialLightGrey: "#f8f8f8"
    readonly property string colorMaterialDarkGrey: "#ececec"
    readonly property string colorNeutralDay: "#e4e4e4"
    readonly property string colorNeutralNight: "#ffb300"

    // Fonts (sizes in pixel) (WIP)
    readonly property int fontSizeHeader: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 26 : 28
    readonly property int fontSizeTitle: 24
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentSmall: 14

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: loadTheme(settingsManager.theme)

    function loadTheme(themeIndex) {
        if (themeIndex === "green") themeIndex = ThemeEngine.THEME_GREEN
        if (themeIndex === "day") themeIndex = ThemeEngine.THEME_DAY
        if (themeIndex === "night") themeIndex = ThemeEngine.THEME_NIGHT
        if (themeIndex >= ThemeEngine.THEME_LAST) themeIndex = 0
        currentTheme = themeIndex

        if (themeIndex === ThemeEngine.THEME_GREEN) {

            colorHeader = "#07bf97"
            colorHeaderStatusbar = "#009688"
            colorHeaderContent = "white"

            colorBackground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? "white" : colorMaterialLightGrey
            colorForeground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? colorMaterialLightGrey : colorMaterialDarkGrey

            colorText = "#333333"
            colorSubText = "#666666"
            colorIcons = "#606060"

            colorBordersDrawer = "#d3d3d3"
            colorBordersWidget = colorMaterialDarkGrey
            colorBordersComponents = "#b3b3b3"
            colorBgUpComponents = colorMaterialDarkGrey
            colorBgDownComponents = colorMaterialLightGrey

            colorHighlight = "#07bf97"
            colorHighlight2 = "#8dd9ca"
            colorHighContrast = "black"

            colorGreen = "#07bf97"
            colorBlue = "#4CA1D5"
            colorYellow = "#ffba5a"
            colorRed = "#ff7657"
            colorLightGrey = "#a9bcb8"

        } else if (themeIndex === ThemeEngine.THEME_DAY) {

            colorHeader = "#ffcf00"
            colorHeaderStatusbar = colorNeutralNight
            colorHeaderContent = "white"

            colorBackground = "white"
            colorForeground = colorMaterialLightGrey

            colorText = "#4b4747"
            colorSubText = "#666666"
            colorIcons = "#606060"

            colorBordersDrawer = "#d3d3d3"
            colorBordersWidget = colorMaterialDarkGrey
            colorBordersComponents = "#b3b3b3"
            colorBgUpComponents = colorMaterialDarkGrey
            colorBgDownComponents = colorMaterialLightGrey

            colorHighlight = "#ffd700"
            colorHighlight2 = colorNeutralNight
            colorHighContrast = "#303030"

            colorGreen = "#8cd200"
            colorBlue = "#4cafe9"
            colorYellow = "#ffcf00"
            colorRed = "#ff7657"
            colorLightGrey = "#a9bcb8"

        } else if (themeIndex === ThemeEngine.THEME_NIGHT) {

            colorHeader = "#b16bee"
            colorHeaderStatusbar = "#725595"
            colorHeaderContent = "white"

            colorBackground = "#313236"
            colorForeground = "#292929"

            colorText = "#b9babe"
            colorSubText = "#75767a"
            colorIcons = "#b9babe"

            colorBordersDrawer = "#292929"
            colorBordersWidget = "#404040"
            colorBordersComponents = "#75767a"
            colorBgUpComponents = "#75767a"
            colorBgDownComponents = "#292929"

            colorHighlight = "#bb86fc"
            colorHighlight2 = "#725595"
            colorHighContrast = "white"

            colorGreen = "#58b870"
            colorBlue = "#4dceeb"
            colorYellow = "#fcc632"
            colorRed = "#e8635a"
            colorLightGrey = "#a9bcb8"
        }
    }
}
