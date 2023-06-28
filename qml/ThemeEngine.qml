pragma Singleton

import QtQuick
import QtQuick.Controls.Material

Item {
    enum ThemeNames {
        // WatchFlower
        THEME_PLANT = 0,
        THEME_RAIN = 1,
        THEME_SNOW = 2,
        THEME_DAY = 3,
        THEME_NIGHT = 4,

        THEME_LAST
    }
    property int currentTheme: -1

    ////////////////

    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)
    property bool isDesktop: (Qt.platform.os !== "ios" && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios" || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize >= 7.0))

    ////////////////

    // Status bar (mobile)
    property int themeStatusbar
    property color colorStatusbar

    // Header
    property color colorHeader
    property color colorHeaderContent
    property color colorHeaderHighlight

    // Side bar (desktop)
    property color colorSidebar
    property color colorSidebarContent
    property color colorSidebarHighlight

    // Action bar
    property color colorActionbar
    property color colorActionbarContent
    property color colorActionbarHighlight

    // Tablet bar (mobile)
    property color colorTabletmenu
    property color colorTabletmenuContent
    property color colorTabletmenuHighlight

    // Content
    property color colorBackground
    property color colorForeground

    property color colorPrimary
    property color colorSecondary
    property color colorSuccess
    property color colorWarning
    property color colorError

    property color colorText
    property color colorSubText
    property color colorIcon
    property color colorSeparator

    property color colorLowContrast
    property color colorHighContrast

    // App specific
    property color colorDeviceWidget
    property string sidebarSelector // 'arrow' or 'bar'

    ////////////////

    // Palette colors
    property color colorLightGreen: "#09debc"
    property color colorGreen
    property color colorDarkGreen: "#1ea892"
    property color colorBlue
    property color colorYellow
    property color colorOrange
    property color colorRed
    property color colorGrey: "#555151"
    property color colorLightGrey: "#a9bcb8"

    // Fixed colors
    readonly property color colorMaterialBlue: "#2196f3"
    readonly property color colorMaterialThisblue: "#448aff"
    readonly property color colorMaterialIndigo: "#3f51b5"
    readonly property color colorMaterialPurple: "#9c27b0"
    readonly property color colorMaterialDeepPurple: "#673ab7"
    readonly property color colorMaterialRed: "#f44336"
    readonly property color colorMaterialOrange: "#ff9800"
    readonly property color colorMaterialLightGreen: "#8bc34a"

    readonly property color colorMaterialLightGrey: "#f8f8f8"
    readonly property color colorMaterialGrey: "#eeeeee"
    readonly property color colorMaterialDarkGrey: "#ececec"

    readonly property color colorNeutralDay: "#e4e4e4"
    readonly property color colorNeutralNight: "#ffb300"

    ////////////////

    // Qt Quick controls & theming
    property color colorComponent
    property color colorComponentText
    property color colorComponentContent
    property color colorComponentBorder
    property color colorComponentDown
    property color colorComponentBackground

    property int componentMargin: isPhone ? 12 : 16
    property int componentMarginL: isPhone ? 16 : 20
    property int componentMarginXL: isPhone ? 20 : 24

    property int componentHeight: (isDesktop && isHdpi) ? 36 : 40
    property int componentHeightL: (isDesktop && isHdpi) ? 44 : 48
    property int componentHeightXL: (isDesktop && isHdpi) ? 48 : 56

    property int componentRadius: 4
    property int componentBorderWidth: 2

    property int componentFontSize: isMobile ? 14 : 15

    ////////////////

    // Fonts (sizes in pixel)
    readonly property int fontSizeHeader: isPhone ? 22 : 26
    readonly property int fontSizeTitle: isPhone ? 24 : 28
    readonly property int fontSizeContentVeryVerySmall: 10
    readonly property int fontSizeContentVerySmall: 12
    readonly property int fontSizeContentSmall: 14
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContentVeryBig: 20
    readonly property int fontSizeContentVeryVeryBig: 22

    ////////////////////////////////////////////////////////////////////////////

    function getThemeIndex(name) {
        if (name === "THEME_PLANT") return ThemeEngine.THEME_PLANT
        if (name === "THEME_RAIN") return ThemeEngine.THEME_RAIN
        if (name === "THEME_SNOW") return ThemeEngine.THEME_SNOW
        if (name === "THEME_DAY") return ThemeEngine.THEME_DAY
        if (name === "THEME_NIGHT") return ThemeEngine.THEME_NIGHT
        return -1
    }
    function getThemeName(index) {
        if (index === ThemeEngine.THEME_PLANT) return "THEME_PLANT"
        if (index === ThemeEngine.THEME_RAIN) return "THEME_RAIN"
        if (index === ThemeEngine.THEME_SNOW) return "THEME_SNOW"
        if (index === ThemeEngine.THEME_DAY) return "THEME_DAY"
        if (index === ThemeEngine.THEME_NIGHT) return "THEME_NIGHT"
        return ""
    }

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: loadTheme(settingsManager.appTheme)
    Connections {
        target: settingsManager
        function onAppThemeChanged() { loadTheme(settingsManager.appTheme) }
    }

    function loadTheme(newIndex) {
        //console.log("ThemeEngine.loadTheme(" + newIndex + ")")
        var themeIndex = -1

        // Get the theme index
        if ((typeof newIndex === 'string' || newIndex instanceof String)) {
            themeIndex = getThemeIndex(newIndex)
        } else {
            themeIndex = newIndex
        }

        // Validate the result
        if (themeIndex < 0 || themeIndex >= ThemeEngine.THEME_LAST) {
            themeIndex = ThemeEngine.THEME_PLANT // default theme
        }

        // Handle day/night themes
        if (settingsManager.appThemeAuto) {
            var rightnow = new Date()
            var hour = Qt.formatDateTime(rightnow, "hh")
            if (hour >= 21 || hour <= 8) {
                themeIndex = ThemeEngine.THEME_NIGHT
            }
        }

        // Do not reload the same theme
        if (themeIndex === currentTheme) return

        // Select new theme
        if (themeIndex === ThemeEngine.THEME_SNOW) {

            colorGreen = "#85c700"
            colorBlue = "#4cafe9"
            colorYellow = "#facb00"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            themeStatusbar = Material.Light
            colorStatusbar = "white"

            colorHeader = "white"
            colorHeaderContent = "#444"
            colorHeaderHighlight = colorMaterialDarkGrey

            colorSidebar = "white"
            colorSidebarContent = "#444"
            colorSidebarHighlight = colorMaterialDarkGrey

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
            colorIcon = "#474747"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "#303030"

            colorDeviceWidget = "#fdfdfd"

            componentRadius = (componentHeight / 2)

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

            colorSidebar = colorGreen
            colorSidebarContent = "white"
            colorSidebarHighlight = "#009688"

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
            colorIcon = "#333333"
            colorSeparator = "#e8e8e8"
            colorLowContrast = "white"
            colorHighContrast = "black"

            colorDeviceWidget = "#fdfdfd"

            componentRadius = 4

            colorComponent = "#EAEAEA"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#E3E3E3"
            colorComponentDown = "#D0D0D0"
            colorComponentBackground = "#F1F1F1"

        } else if (themeIndex === ThemeEngine.THEME_RAIN) {

            colorGreen = "#8cd200"
            colorBlue = "#4cafe9"
            colorYellow = "#ffcf00"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            themeStatusbar = Material.Dark
            colorStatusbar = "#1e3c77"

            colorHeader = "#325da9"
            colorHeaderHighlight = "#0f295c"
            colorHeaderContent = "white"

            colorSidebar = "#ffcf00"
            colorSidebarContent = "white"
            colorSidebarHighlight = colorNeutralNight

            colorActionbar = colorBlue
            colorActionbarContent = "white"
            colorActionbarHighlight = "#4c8ee9"

            colorTabletmenu = "#f3f3f3"
            colorTabletmenuContent = "#9d9d9d"
            colorTabletmenuHighlight = "#0079fe"

            colorBackground = "white"
            colorForeground = colorMaterialLightGrey

            colorPrimary = "#325da9"
            colorSecondary = "#446eb7"
            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorText = "#474747"
            colorSubText = "#666666"
            colorIcon = "#474747"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "#303030"

            colorDeviceWidget = "#fdfdfd"

            componentRadius = 6

            colorComponent = "#EFEFEF"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#E8E8E8"
            colorComponentDown = "#DDDDDD"
            colorComponentBackground = "#FAFAFA"

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

            colorSidebar = "#ffcf00"
            colorSidebarContent = "white"
            colorSidebarHighlight = colorNeutralNight

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
            colorIcon = "#474747"
            colorSeparator = colorMaterialDarkGrey
            colorLowContrast = "white"
            colorHighContrast = "#303030"

            colorDeviceWidget = "#fdfdfd"

            componentRadius = 6

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
            colorHeaderContent = "white"
            colorHeaderHighlight = "#725595"

            colorSidebar = "#b16bee"
            colorSidebarContent = "white"
            colorSidebarHighlight = "#725595"

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
            colorIcon = "#EEE"
            colorSeparator = "#404040"
            colorLowContrast = "#111"
            colorHighContrast = "white"

            colorDeviceWidget = "#333"

            componentRadius = 4

            colorComponent = "#757575"
            colorComponentText = "#eee"
            colorComponentContent = "white"
            colorComponentBorder = "#777"
            colorComponentDown = "#595959"
            colorComponentBackground = "#292929"

        }


        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
