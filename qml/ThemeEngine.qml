pragma Singleton

import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Item {
    enum ThemeNames {
        THEME_PLANT = 0,
        THEME_DAY = 1,
        THEME_NIGHT = 2,
        THEME_SNOW = 3,

        THEME_LAST
    }
    property int currentTheme: -1

    ////////////////

    property int themeStatusbar
    property string colorStatusbar

    // Header
    property string colorHeader
    property string colorHeaderContent
    property string colorHeaderHighlight

    // Sidebar
    property string colorSidebar
    property string colorSidebarContent
    property string colorSidebarHighlight

    // Action bar
    property string colorActionbar
    property string colorActionbarContent
    property string colorActionbarHighlight

    // Tablet bar
    property string colorTabletmenu
    property string colorTabletmenuContent
    property string colorTabletmenuHighlight

    // Content
    property string colorBackground
    property string colorForeground

    property string colorPrimary
    property string colorSecondary
    property string colorSuccess
    property string colorWarning
    property string colorError

    property string colorText
    property string colorSubText
    property string colorIcon
    property string colorSeparator

    property string colorLowContrast
    property string colorHighContrast

    // App specific
    property string colorDeviceHeader
    property string colorDeviceWidget

    // Qt Quick controls & theming
    property string colorComponent
    property string colorComponentText
    property string colorComponentContent
    property string colorComponentBorder
    property string colorComponentDown
    property string colorComponentBackground

    property int componentHeight: 40
    property int componentRadius: 4
    property int componentBorderWidth: 1

    ////////////////

    // Palette colors
    property string colorLightGreen: "#09debc" // unused
    property string colorGreen
    property string colorDarkGreen: "#1ea892" // unused
    property string colorBlue
    property string colorYellow
    property string colorOrange
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
    readonly property int fontSizeHeader: (Qt.platform.os === "ios" || Qt.platform.os === "android") ? 22 : 26
    readonly property int fontSizeTitle: 24
    readonly property int fontSizeContentVerySmall: 12
    readonly property int fontSizeContentSmall: 14
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContentVeryBig: 20
    readonly property int fontSizeComponent: (Qt.platform.os === "ios" || Qt.platform.os === "android") ? 14 : 15

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: loadTheme(settingsManager.appTheme)
    Connections {
        target: settingsManager
        function onAppThemeChanged() { loadTheme(settingsManager.appTheme) }
    }

    function loadTheme(themeIndex) {
        //console.log("ThemeEngine.loadTheme(" + themeIndex + ")")

        if (themeIndex === "snow") themeIndex = ThemeEngine.THEME_SNOW
        if (themeIndex === "green") themeIndex = ThemeEngine.THEME_PLANT // legacy
        if (themeIndex === "plant") themeIndex = ThemeEngine.THEME_PLANT
        if (themeIndex === "day") themeIndex = ThemeEngine.THEME_DAY
        if (themeIndex === "night") themeIndex = ThemeEngine.THEME_NIGHT
        if (themeIndex >= ThemeEngine.THEME_LAST) themeIndex = ThemeEngine.THEME_PLANT // default

        if (settingsManager.appThemeAuto) {
            var rightnow = new Date()
            var hour = Qt.formatDateTime(rightnow, "hh")
            if (hour >= 21 || hour <= 8) {
                themeIndex = ThemeEngine.THEME_NIGHT
            }
        }

        if (themeIndex === currentTheme) return;

        if (themeIndex === ThemeEngine.THEME_SNOW) {

            colorGreen = "#85c700"
            colorBlue = "#4cafe9"
            colorYellow = "#facb00"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            themeStatusbar = Material.Dark
            colorStatusbar = "white"

            colorHeader = "white"
            colorHeaderContent = "#444"
            colorHeaderHighlight = colorMaterialDarkGrey

            colorActionbar = colorGreen
            colorActionbarContent = "white"
            colorActionbarHighlight = "#7ab800"

            colorTabletmenu = "#ffffff"
            colorTabletmenuContent = "#9d9d9d"
            colorTabletmenuHighlight = "#0079fe"

            colorBackground = "white"
            colorForeground = colorMaterialLightGrey

            colorPrimary = colorYellow
            colorSecondary = "#ffe800"
            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorText = "#474747"
            colorSubText = "#666666"
            colorIcon = "#606060"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "#303030"

            colorDeviceHeader = "white"
            colorDeviceWidget = "#fdfdfd"

            componentHeight = 40
            componentRadius = 20
            componentBorderWidth = 2

            colorComponent = "#EFEFEF"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#EAEAEA"
            colorComponentDown = "#DADADA"
            colorComponentBackground = "#FAFAFA"

        } else if (themeIndex === ThemeEngine.THEME_PLANT) {

            colorGreen = "#07bf97"
            colorBlue = "#4CA1D5"
            colorYellow = "#ffba5a"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            themeStatusbar = Material.Dark
            colorStatusbar = "#009688"

            colorHeader = colorGreen
            colorHeaderContent = "white"
            colorHeaderHighlight = "#009688"

            colorActionbar = "#00b5c4"
            colorActionbarContent = "white"
            colorActionbarHighlight = "#069fac"

            colorTabletmenu = "#f3f3f3"
            colorTabletmenuContent = "#9d9d9d"
            colorTabletmenuHighlight = "#0079fe"

            colorBackground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? "white" : colorMaterialLightGrey
            colorForeground = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? colorMaterialLightGrey : colorMaterialGrey

            colorPrimary = colorGreen
            colorSecondary = colorLightGreen
            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorText = "#333333"
            colorSubText = "#666666"
            colorIcon = "#606060"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "black"

            colorDeviceHeader = colorForeground
            colorDeviceWidget = "#fdfdfd"

            componentHeight = 40
            componentRadius = 4
            componentBorderWidth = 2

            colorComponent = "#EAEAEA"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#E3E3E3"
            colorComponentDown = "#D0D0D0"
            colorComponentBackground = "#EAEAEA"

        } else if (themeIndex === ThemeEngine.THEME_DAY) {

            colorGreen = "#8cd200"
            colorBlue = "#4cafe9"
            colorYellow = "#ffcf00"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            themeStatusbar = Material.Dark
            colorStatusbar = colorNeutralNight

            colorHeader = "#ffcf00"
            colorHeaderContent = "white"
            colorHeaderHighlight = colorNeutralNight

            colorActionbar = colorGreen
            colorActionbarContent = "white"
            colorActionbarHighlight = "#7ab800"

            colorTabletmenu = "#f3f3f3"
            colorTabletmenuContent = "#9d9d9d"
            colorTabletmenuHighlight = "#0079fe"

            colorBackground = "white"
            colorForeground = colorMaterialLightGrey

            colorPrimary = colorYellow
            colorSecondary = "#ffe800"
            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorText = "#474747"
            colorSubText = "#666666"
            colorIcon = "#606060"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "#303030"

            colorDeviceHeader = colorForeground
            colorDeviceWidget = "#fdfdfd"

            componentHeight = 40
            componentRadius = 8
            componentBorderWidth = 2

            colorComponent = "#EFEFEF"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#E8E8E8"
            colorComponentDown = "#DDDDDD"
            colorComponentBackground = "#FAFAFA"

        } else if (themeIndex === ThemeEngine.THEME_NIGHT) {

            colorGreen = "#58CF77"
            colorBlue = "#4dceeb"
            colorYellow = "#fcc632"
            colorOrange = "#ff8f35"
            colorRed = "#e8635a"

            themeStatusbar = Material.Dark
            colorStatusbar = "#725595"

            colorHeader = "#b16bee"
            colorHeaderHighlight = "#725595"
            colorHeaderContent = "white"

            colorActionbar = colorBlue
            colorActionbarContent = "white"
            colorActionbarHighlight = "#4dabeb"

            colorTabletmenu = "#292929"
            colorTabletmenuContent = "#808080"
            colorTabletmenuHighlight = "#bb86fc"

            colorBackground = "#313236"
            colorForeground = "#292929"

            colorPrimary = "#bb86fc"
            colorSecondary = "#b16bee"
            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorText = "#EEE"
            colorSubText = "#AAA"
            colorIcon = "#b9babe"
            colorSeparator = "#404040"
            colorLowContrast = "#111"
            colorHighContrast = "white"

            colorDeviceHeader = colorForeground
            colorDeviceWidget = "#333"

            componentHeight = 40
            componentRadius = 4
            componentBorderWidth = 2

            colorComponent = "#757575"
            colorComponentText = "#222"
            colorComponentContent = "white"
            colorComponentBorder = "#777"
            colorComponentDown = "#595959"
            colorComponentBackground = "#DDD"

        }

        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
