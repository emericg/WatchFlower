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

    // Header
    property string colorHeader
    property string colorHeaderContent
    property string colorHeaderStatusbar

    // Status bar
    property string colorStatusbar
    property string colorStatusbarContent

    // Content
    property string colorBackground
    property string colorForeground

    property string colorHighlight
    property string colorHighlight2
    property string colorHighContrast

    property string colorText
    property string colorSubText
    property string colorIcons
    property string colorSeparator
    property string colorComponentBorder
    property string colorComponentBgUp
    property string colorComponentBgDown

    // Palette colors
    property string colorLightGreen: "#09debc" // unused
    property string colorGreen
    property string colorDarkGreen: "#1ea892" // unused
    property string colorBlue
    property string colorYellow
    property string colorRed
    property string colorGrey: "#555151" // unused
    property string colorLightGrey: "#a9bcb8" // unused

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

    Component.onCompleted: loadTheme(settingsManager.appTheme)

    function loadTheme(themeIndex) {
        if (themeIndex === "green") themeIndex = ThemeEngine.THEME_GREEN
        if (themeIndex === "day") themeIndex = ThemeEngine.THEME_DAY
        if (themeIndex === "night") themeIndex = ThemeEngine.THEME_NIGHT
        if (themeIndex >= ThemeEngine.THEME_LAST) themeIndex = 0

        if (settingsManager.autoDark) {
            var today = new Date();
            var hour = Qt.formatDateTime(today, "hh");
            if (hour >= 21 || hour <= 8) themeIndex = ThemeEngine.THEME_NIGHT;
        }

        currentTheme = themeIndex

        if (themeIndex === ThemeEngine.THEME_GREEN) {

            colorGreen = "#07bf97"
            colorBlue = "#4CA1D5"
            colorYellow = "#ffba5a"
            colorRed = "#ff7657"

            colorHeader = colorGreen
            colorHeaderStatusbar = "#009688"
            colorHeaderContent = "white"

            colorStatusbar = colorYellow
            colorStatusbarContent = "white"

            colorBackground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? "white" : colorMaterialLightGrey
            colorForeground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? colorMaterialLightGrey : colorMaterialDarkGrey

            colorText = "#333333"
            colorSubText = "#666666"
            colorIcons = "#606060"
            colorSeparator = colorMaterialDarkGrey
            colorComponentBorder = "#b3b3b3"
            colorComponentBgUp = colorMaterialDarkGrey
            colorComponentBgDown = colorMaterialLightGrey

            colorHighlight = colorGreen
            colorHighlight2 = "#8dd9ca"
            colorHighContrast = "black"

        } else if (themeIndex === ThemeEngine.THEME_DAY) {

            colorGreen = "#8cd200"
            colorBlue = "#4cafe9"
            colorYellow = "#ffcf00"
            colorRed = "#ff7657"

            colorHeader = "#ffcf00"
            colorHeaderStatusbar = colorNeutralNight
            colorHeaderContent = "white"

            colorStatusbar = colorGreen
            colorStatusbarContent = "white"

            colorBackground = "white"
            colorForeground = colorMaterialLightGrey

            colorText = "#4b4747"
            colorSubText = "#666666"
            colorIcons = "#606060"
            colorSeparator = colorMaterialDarkGrey
            colorComponentBorder = "#b3b3b3"
            colorComponentBgUp = colorMaterialDarkGrey
            colorComponentBgDown = colorMaterialLightGrey

            colorHighlight = "#ffd700"
            colorHighlight2 = colorHeaderStatusbar
            colorHighContrast = "#303030"

        } else if (themeIndex === ThemeEngine.THEME_NIGHT) {

            colorGreen = "#58CF77"
            colorBlue = "#4dceeb"
            colorYellow = "#fcc632"
            colorRed = "#e8635a"

            colorHeader = "#b16bee"
            colorHeaderStatusbar = "#725595"
            colorHeaderContent = "white"

            colorStatusbar = colorBlue
            colorStatusbarContent = "white"

            colorBackground = "#313236"
            colorForeground = "#292929"

            colorText = "#EEEEEE"
            colorSubText = "#AAAAAA"
            colorIcons = "#b9babe"
            colorSeparator = "#404040"
            colorComponentBorder = "#75767a"
            colorComponentBgUp = "#75767a"
            colorComponentBgDown = "#292929"

            colorHighlight = "#bb86fc"
            colorHighlight2 = colorHeaderStatusbar
            colorHighContrast = "white"
        }
    }
}
