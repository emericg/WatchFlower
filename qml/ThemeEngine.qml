pragma Singleton
import QtQuick 2.9
import QtQuick.Controls.Material 2.0

Item {
    enum ThemeNames {
        THEME_GREEN = 0,
        THEME_DAY = 1,
        THEME_NIGHT = 2,

        THEME_LAST
    }
    property int currentTheme: -1

    ////////////////

    property int themeStatusbar
    property string colorStatusbar

    // Header
    property string colorHeader
    property string colorHeaderHighlight
    property string colorHeaderContent

    // Sidebar
    property string colorSidebar
    property string colorSidebarContent

    // Action bar
    property string colorActionbar
    property string colorActionbarHighlight
    property string colorActionbarContent

    // Tablet bar
    property string colorTabletmenu
    property string colorTabletmenuContent
    property string colorTabletmenuHighlight

    // Content
    property string colorBackground
    property string colorForeground

    property string colorPrimary
    property string colorSecondary
    property string colorWarning // todo
    property string colorError // todo

    property string colorText
    property string colorSubText
    property string colorIcon
    property string colorSeparator

    property string colorLowContrast
    property string colorHighContrast

    // Qt Quick controls & theming
    property string colorComponent
    property string colorComponentText
    property string colorComponentContent
    property string colorComponentBorder
    property string colorComponentDown
    property string colorComponentBackground
    property int componentRadius: 3
    property int componentHeight: 40

    ////////////////

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
    readonly property string colorMaterialGrey: "#eeeeee"
    readonly property string colorMaterialDarkGrey: "#ececec"
    readonly property string colorNeutralDay: "#e4e4e4"
    readonly property string colorNeutralNight: "#ffb300"

    ////////////////

    // Fonts (sizes in pixel) (WIP)
    readonly property int fontSizeHeader: (Qt.platform.os === "ios" || Qt.platform.os === "android") ? 26 : 28
    readonly property int fontSizeTitle: 24
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContent: 16
    readonly property int fontSizeComponent: 14
    readonly property int fontSizeContentSmall: 14

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: loadTheme(settingsManager.appTheme)
    Connections {
        target: settingsManager
        onAppthemeChanged: loadTheme(settingsManager.appTheme)
    }

    function loadTheme(themeIndex) {
        //console.log("ThemeEngine.loadTheme(" + themeIndex + ")")

        if (themeIndex === "green") themeIndex = ThemeEngine.THEME_GREEN
        if (themeIndex === "day") themeIndex = ThemeEngine.THEME_DAY
        if (themeIndex === "night") themeIndex = ThemeEngine.THEME_NIGHT
        if (themeIndex >= ThemeEngine.THEME_LAST) themeIndex = 0

        if (settingsManager.autoDark) {
            var rightnow = new Date();
            var hour = Qt.formatDateTime(rightnow, "hh");
            if (hour >= 21 || hour <= 8) {
                themeIndex = ThemeEngine.THEME_NIGHT;
            }
        }

        if (themeIndex === currentTheme) return;

        if (themeIndex === ThemeEngine.THEME_GREEN) {

            colorGreen = "#07bf97"
            colorBlue = "#4CA1D5"
            colorYellow = "#ffba5a"
            colorRed = "#ff7657"

            themeStatusbar = Material.Dark
            colorStatusbar = "#009688"

            colorHeader = colorGreen
            colorHeaderHighlight = "#009688"
            colorHeaderContent = "white"

            colorActionbar = colorYellow
            colorActionbarHighlight = "#ff8b5a"
            colorActionbarContent = "white"

            colorTabletmenu = "#f3f3f3"
            colorTabletmenuContent = "#9d9d9d"
            colorTabletmenuHighlight = "#0079fe"

            colorBackground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? "white" : colorMaterialLightGrey
            colorForeground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? colorMaterialLightGrey : colorMaterialGrey

            colorPrimary = colorGreen
            colorSecondary = colorLightGreen

            colorText = "#333333"
            colorSubText = "#666666"
            colorIcon = "#606060"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "black"

            colorComponent = "#eaeaea"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#b3b3b3"
            colorComponentDown = "#cacaca"
            colorComponentBackground = "#eaeaea"

        } else if (themeIndex === ThemeEngine.THEME_DAY) {

            colorGreen = "#8cd200"
            colorBlue = "#4cafe9"
            colorYellow = "#ffcf00"
            colorRed = "#ff7657"

            themeStatusbar = Material.Dark
            colorStatusbar = colorNeutralNight

            colorHeader = "#ffcf00"
            colorHeaderHighlight = colorNeutralNight
            colorHeaderContent = "white"

            colorActionbar = colorGreen
            colorActionbarHighlight = "#7ab800"
            colorActionbarContent = "white"

            colorTabletmenu = "#f3f3f3"
            colorTabletmenuContent = "#9d9d9d"
            colorTabletmenuHighlight = "#0079fe"

            colorBackground = "white"
            colorForeground = colorMaterialLightGrey

            colorPrimary = colorYellow
            colorSecondary = "#ffe800"

            colorText = "#4b4747"
            colorSubText = "#666666"
            colorIcon = "#606060"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "#303030"

            colorComponent = "#efefef"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#b3b3b3"
            colorComponentDown = "#cacaca"
            colorComponentBackground = "#FAFAFA"

        } else if (themeIndex === ThemeEngine.THEME_NIGHT) {

            colorGreen = "#58CF77"
            colorBlue = "#4dceeb"
            colorYellow = "#fcc632"
            colorRed = "#e8635a"

            themeStatusbar = Material.Dark
            colorStatusbar = "#725595"

            colorHeader = "#b16bee"
            colorHeaderHighlight = "#725595"
            colorHeaderContent = "white"

            colorActionbar = colorBlue
            colorActionbarHighlight = "#4dabeb"
            colorActionbarContent = "white"

            colorTabletmenu = "#292929"
            colorTabletmenuContent = "#808080"
            colorTabletmenuHighlight = "#bb86fc"

            colorBackground = "#313236"
            colorForeground = "#292929"

            colorPrimary = "#bb86fc"
            colorSecondary = "#b16bee"

            colorText = "#EEEEEE"
            colorSubText = "#AAAAAA"
            colorIcon = "#b9babe"
            colorSeparator = "#404040"
            colorLowContrast = "black"
            colorHighContrast = "white"

            colorComponent = "#757575"
            colorComponentText = "#222222"
            colorComponentContent = "white"
            colorComponentBorder = "#757575"
            colorComponentDown = "#555555"
            colorComponentBackground = "#dddddd"
        }

        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
