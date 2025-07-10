pragma Singleton

import QtQuick
import QtQuick.Controls.Material

import ComponentLibrary

Item {
    enum ThemeNames {
        // Generic mobile themes
        THEME_SNOW ,
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

    property bool isLight
    property bool isDark

    // Status bar (mobile)
    property int themeStatusbar
    property color colorStatusbar

    // Header
    property color colorHeader
    property color colorHeaderContent
    property color colorHeaderHighlight

    // Action bar (mobile)
    property color colorActionbar
    property color colorActionbarContent
    property color colorActionbarHighlight

    // Side bar (desktop)
    property color colorSidebar
    property color colorSidebarContent
    property color colorSidebarHighlight

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

    ////////////////

    // App specific (toolBLEx)
    property color colorBox: "white"
    property color colorBoxBorder: "#f4f4f4"
    property color colorBoxShadow: "#20000000"
    property color colorGrid: "#ebebeb"
    property color colorLVheader: "#fafafa"
    property color colorLVpair: "white"
    property color colorLVimpair: "#f5f5f5"
    property color colorLVselected: "#0080e0"
    property color colorLVseparator: "#e2e2e2"

    // App specific (OffloadBuddy)
    property string sidebarSelector // 'arrow' or 'bar'

    // App specific (SmartCare)
    property color colorDeviceWidget
    readonly property color colorLightGrey: "#a9bcb8"
    readonly property color colorLightGreen: "#09debc"
    readonly property color colorNeutralNight: "#ffb300"

    ////////////////

    // Palette colors
    property color colorRed: "#ff7657"
    property color colorGreen: "#8cd200"
    property color colorBlue: "#4cafe9"
    property color colorPurple: "#b563ff"
    property color colorYellow: "#ffcf00"
    property color colorOrange: "#ffa635"
    property color colorGrey: "#666"

    // Material colors
    readonly property color colorMaterialRed: "#F44336"
    readonly property color colorMaterialPink: "#E91E63"
    readonly property color colorMaterialPurple: "#9C27B0"
    readonly property color colorMaterialDeepPurple: "#673AB7"
    readonly property color colorMaterialIndigo: "#3F51B5"
    readonly property color colorMaterialBlue: "#2196F3"
    readonly property color colorMaterialLightBlue: "#03A9F4"
    readonly property color colorMaterialCyan: "#00BCD4"
    readonly property color colorMaterialTeal: "#009688"
    readonly property color colorMaterialGreen: "#4CAF50"
    readonly property color colorMaterialLightGreen: "#8BC34A"
    readonly property color colorMaterialLime: "#CDDC39"
    readonly property color colorMaterialYellow: "#FFEB3B"
    readonly property color colorMaterialAmber: "#FFC107"
    readonly property color colorMaterialOrange: "#FF9800"
    readonly property color colorMaterialDeepOrange: "#FF5722"
    readonly property color colorMaterialBrown: "#795548"
    readonly property color colorMaterialGrey: "#9E9E9E"
    readonly property color colorMaterialLightGrey: "#f8f8f8"
    readonly property color colorMaterialDarkGrey: "#ececec"

    ////////////////

    // Qt Quick Controls & theming
    property color colorComponent
    property color colorComponentText
    property color colorComponentContent
    property color colorComponentBorder
    property color colorComponentDown
    property color colorComponentBackground
    property color colorComponentShadow: "#40000000"

    property int componentRadius: 4
    property int componentBorderWidth: 2

    property int componentFontSize: isHdpi ? 14 : 15

    property int componentMarginXS: isHdpi ? 4 : 8
    property int componentMarginS: isHdpi ? 8 : 12
    property int componentMargin: isHdpi ? 12 : 16
    property int componentMarginL: isHdpi ? 16 : 20
    property int componentMarginXL: isHdpi ? 20 : 24

    property int componentHeight: {
        if (isDesktop && isHdpi) return 34
        if (isDesktop) return 38
        return 40
    }
    property int componentHeightL: {
        if (isDesktop && isHdpi) return 40
        if (isDesktop) return 44
        return 48
    }
    property int componentHeightXL: {
        if (isDesktop && isHdpi) return 44
        if (isDesktop) return 48
        return 52
    }

    ////////////////

    // Fonts (sizes in pixel)
    readonly property int fontSizeHeader: isMobile ? 22 : 26
    readonly property int fontSizeTitle: isMobile ? 24 : 28
    readonly property int fontSizeContentVeryVerySmall: 10
    readonly property int fontSizeContentVerySmall: 12
    readonly property int fontSizeContentSmall: 14
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContentVeryBig: 20
    readonly property int fontSizeContentVeryVeryBig: 22

    // Fonts
    property font headerFont: Qt.font({
        family: 'Encode Sans',
        weight: Font.Black,
        italic: false,
        pixelSize: fontSizeHeader
    })

    ////////////////////////////////////////////////////////////////////////////

    function getThemeIndex(name) {
        if (name === "THEME_SNOW") return Theme.THEME_SNOW
        return -1
    }

    function getThemeName(index) {
        if (index === Theme.THEME_SNOW) return "THEME_SNOW"
        return ""
    }

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: loadTheme(Theme.THEME_SNOW)
    Connections {
        target: settingsManager
        function onAppThemeChanged() { loadTheme(Theme.THEME_SNOW) }
    }

    function loadTheme(newIndex) {
        //console.log("Theme.loadTheme(" + newIndex + ")")
        var themeIndex = Theme.THEME_SNOW

        // Do not reload the same theme
        if (themeIndex === currentTheme) return

        colorGreen = "#58CF77"
        colorBlue = "#4dceeb"
        colorYellow = "#fcc632"
        colorOrange = "#ff8f35"
        colorRed = "#e8635a"

        isLight = true
        isDark = false

        themeStatusbar = Material.Dark
        colorStatusbar = "#0E6B15"

        colorHeader                 = "#0E6B15"
        colorHeaderContent          = "white"
        colorHeaderHighlight        = "#0E6B15"

        colorSidebar                = "#333"
        colorSidebarContent         = "#444"
        colorSidebarHighlight       = "#666"

        colorActionbar              = colorGreen
        colorActionbarContent       = "white"
        colorActionbarHighlight     = "#4dabeb"

        colorTabletmenu             = "#292929"
        colorTabletmenuContent      = "#808080"
        colorTabletmenuHighlight    = "#bb86fc"

        colorBackground             = "white"
        colorForeground             = "black"

        colorPrimary                = "#0E6B15"
        colorSecondary              = "#0E6B15"
        colorSuccess                = colorGreen
        colorWarning                = colorOrange
        colorError                  = colorRed

        colorText                   = "#111"
        colorSubText                = "#404040"
        colorIcon                   = "#404040"
        colorSeparator              = "#AAA"
        colorLowContrast            = "#EEE"
        colorHighContrast           = "#404040"

        colorComponent              = "#AAA"
        colorComponentText          = "#292929"
        colorComponentContent       = "#292929"
        colorComponentBorder        = "#AAA"
        colorComponentDown          = "#EEE"
        colorComponentBackground    = "#EEE"

        componentRadius = 4
        componentBorderWidth = 2

        // (app)
        colorDeviceWidget = "#EEE"


        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
