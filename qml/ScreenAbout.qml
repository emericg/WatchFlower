import QtQuick
import QtQuick.Controls

import ComponentLibrary

Loader {
    id: screenAbout
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        screenAbout.active = true

        // change screen
        appContent.state = "ScreenAbout"
    }

    function backAction() {
        if (screenAbout.status === Loader.Ready)
            screenAbout.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: false

    sourceComponent: Item {
        anchors.fill: parent

        ////////////////

        function backAction() {
            screenMainView.loadScreen()
        }

        Rectangle { // hide the space between the top of the screen and the top of scanWidget
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            height: contentHeader.height - contentFlickable.contentY
            color: contentHeader.color
            visible: singleColumn
        }

        ////////////////

        Flickable {
            id: contentFlickable
            anchors.fill: parent

            contentWidth: -1
            contentHeight: contentColumn.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: contentColumn

                anchors.left: parent.left
                anchors.leftMargin: ((singleColumn || isPhone) ? 0 : parent.width * 0.12)
                anchors.right: parent.right
                anchors.rightMargin: ((singleColumn || isPhone) ? 0 : parent.width * 0.12)

                ////////////////

                Item { width: 16; height: 16; visible: !(singleColumn || isPhone); }

                Rectangle { // header area
                    id: contentHeader
                    anchors.left: parent.left
                    anchors.leftMargin: -screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -screenPaddingRight

                    height: 112
                    radius: (singleColumn || isPhone) ? 0 : 8
                    color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

                    border.width: (singleColumn || isPhone) ? 0 : Theme.componentBorderWidth
                    border.color: Theme.colorSeparator

                    property int availaleWidth: (contentHeader.width - rowTitle.width)

                    ////////

                    Row {
                        id: rowTitle
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        z: 2
                        height: 112
                        spacing: Theme.componentMargin

                        Image { // logo
                            anchors.verticalCenter: parent.verticalCenter
                            width: 112
                            height: width

                            source: "qrc:/assets/gfx/logos/logo.svg"
                            sourceSize: Qt.size(width, height)

                            MouseArea {
                                anchors.fill: parent
                                onClicked: screenSettingsAdvanced.loadScreen()
                            }
                        }

                        Column { // title
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 4

                            Text {
                                text: "WatchFlower"
                                textFormat: Text.PlainText
                                color: Theme.colorText
                                font.pixelSize: Theme.fontSizeTitle
                            }
                            Text {
                                text: qsTr("version %1 %2").arg(utilsApp.appVersion()).arg(utilsApp.appBuildMode())
                                textFormat: Text.PlainText
                                color: Theme.colorSubText
                                font.pixelSize: Theme.fontSizeContentBig
                            }
                        }
                    }

                    ////////

                    Row { // desktop buttons row
                        anchors.right: parent.right
                        anchors.rightMargin: screenPaddingRight + Theme.componentMarginL
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: Theme.componentMargin
                        visible: (contentHeader.availaleWidth > 560)

                        ButtonSolid {
                            visible: (width*3 < contentHeader.availaleWidth)
                            width: isPhone ? 150 : 160
                            height: 40

                            text: qsTr("WEBSITE")
                            source: "qrc:/IconLibrary/material-symbols/link.svg"
                            sourceSize: 28
                            font.bold: true
                            color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                            onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                        }

                        ButtonSolid {
                            visible: (width*2 < contentHeader.availaleWidth)
                            width: isPhone ? 150 : 160
                            height: 40

                            text: qsTr("SUPPORT")
                            source: "qrc:/IconLibrary/material-symbols/support.svg"
                            sourceSize: 22
                            font.bold: true
                            color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                            onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower/support.html")
                        }

                        ButtonSolid {
                            visible: (width*1 < contentHeader.availaleWidth)
                            width: isPhone ? 150 : 160
                            height: 40

                            text: qsTr("GitHub")
                            source: "qrc:/assets/gfx/logos/github.svg"
                            sourceSize: 22
                            font.bold: true
                            color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                            onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower")
                        }
                    }

                    ////////
                }

                Item { width: 16; height: 16; visible: !(singleColumn || isPhone); }

                ////////////////

                Row { // mobile buttons row
                    height: 72

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    spacing: Theme.componentMargin
                    visible: (contentHeader.availaleWidth <= 560)

                    ButtonFlat {
                        anchors.verticalCenter: parent.verticalCenter
                        width: ((parent.width - parent.spacing) / 2)
                        height: 40

                        text: qsTr("WEBSITE")
                        source: "qrc:/IconLibrary/material-symbols/link.svg"
                        sourceSize: 28
                        font.bold: true
                        color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                    }
                    ButtonFlat {
                        anchors.verticalCenter: parent.verticalCenter
                        width: ((parent.width - parent.spacing) / 2)
                        height: 40

                        text: qsTr("SUPPORT")
                        source: "qrc:/IconLibrary/material-symbols/support.svg"
                        sourceSize: 22
                        font.bold: true
                        color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower/support.html")
                    }
                }

                ////////////////

                ListItem { // description
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("A plant monitoring application that reads and plots data from compatible Bluetooth sensors and thermometers like Xiaomi 'Flower Care' or Parrot 'Flower Power'.")
                    source: "qrc:/IconLibrary/material-symbols/info.svg"
                }

                ListItemClickable { // authors
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Application by <a href=\"https://emeric.io\">Emeric Grange</a><br>Visual design by <a href=\"https://dribbble.com/chrisdiaz\">Chris Díaz</a>")
                    source: "qrc:/IconLibrary/material-symbols/supervised_user_circle.svg"
                    indicatorSource: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

                    onClicked: Qt.openUrlExternally("https://emeric.io")
                }

                ListItemClickable { // rate
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                    text: qsTr("Rate the application")
                    source: "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                    indicatorSource: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

                    onClicked: {
                        if (Qt.platform.os === "android")
                            Qt.openUrlExternally("market://details?id=com.emeric.watchflower")
                        else if (Qt.platform.os === "ios")
                            Qt.openUrlExternally("itms-apps://itunes.apple.com/app/1476046123")
                        else
                            Qt.openUrlExternally("https://github.com/emericg/WatchFlower/stargazers")
                    }
                }

                ListItemClickable { // release notes
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Release notes")
                    source: "qrc:/IconLibrary/material-symbols/new_releases.svg"
                    sourceSize: 28
                    indicatorSource: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

                    onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower/releases")
                }

                ListItemClickable { // supported sensors
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Supported sensors")
                    source: "qrc:/IconLibrary/material-symbols/check_circle.svg"
                    sourceSize: 28
                    indicatorSource: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

                    onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower/blob/master/docs/README.md")
                }

                IconSvg { // image devices
                    anchors.left: parent.left
                    anchors.leftMargin: appHeader.headerPosition
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    visible: isPhone
                    height: width*0.2347222

                    source: "qrc:/assets/gfx/tutorial/welcome-devices.svg"
                    fillMode: Image.PreserveAspectFit
                    color: Theme.colorPrimary
                }

                ////////

                ListSeparator { }

                ListItemClickable { // tutorial
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Open the tutorial")
                    source: "qrc:/IconLibrary/material-symbols/import_contacts-fill.svg"
                    sourceSize: 24
                    indicatorSource: "qrc:/IconLibrary/material-symbols/chevron_right.svg"

                    onClicked: screenTutorial.loadScreenFrom("ScreenAbout")
                }

                ////////

                ListSeparator { visible: (Qt.platform.os === "android" || Qt.platform.os === "ios") }

                ListItemClickable { // permissions
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                    text: qsTr("About app permissions")
                    source: "qrc:/IconLibrary/material-symbols/flaky.svg"
                    sourceSize: 24
                    indicatorSource: "qrc:/IconLibrary/material-symbols/chevron_right.svg"

                    onClicked: screenAboutPermissions.loadScreenFrom("ScreenAbout")
                }

                ListSeparator { }

                ////////

                Item { // list dependencies
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    height: 40 + dependenciesText.height + dependenciesColumn.height

                    IconSvg {
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: dependenciesText.verticalCenter

                        source: "qrc:/IconLibrary/material-symbols/settings.svg"
                        color: Theme.colorSubText
                    }

                    Text {
                        id: dependenciesText
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.left: parent.left
                        anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                        anchors.right: parent.right
                        anchors.rightMargin: 8

                        text: qsTr("This application is made possible thanks to a couple of third party open source projects:")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        id: dependenciesColumn
                        anchors.top: dependenciesText.bottom
                        anchors.topMargin: 8
                        anchors.left: parent.left
                        anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        spacing: 4

                        Repeater {
                            model: [
                                "Qt6 (LGPL v3)",
                                "MobileUI (MIT)",
                                "MobileSharing (MIT)",
                                "SingleApplication (MIT)",
                                "Google Material Icons (Apache 2.0)",
                            ]
                            delegate: Text {
                                anchors.left: parent.left
                                anchors.right: parent.right

                                text: "- " + modelData
                                textFormat: Text.PlainText
                                color: Theme.colorSubText
                                font.pixelSize: Theme.fontSizeContent
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                ////////

                ListSeparator { }

                Item { // list translators
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    height: 40 + translatorsText.height + translatorsColumn.height

                    IconSvg {
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: translatorsText.verticalCenter

                        source: "qrc:/IconLibrary/material-icons/duotone/translate.svg"
                        color: Theme.colorSubText
                    }

                    Text {
                        id: translatorsText
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.left: parent.left
                        anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                        anchors.right: parent.right
                        anchors.rightMargin: 8

                        text: qsTr("Special thanks to our translators:")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        id: translatorsColumn
                        anchors.top: translatorsText.bottom
                        anchors.topMargin: 8
                        anchors.left: parent.left
                        anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        spacing: 4

                        Repeater {
                            model: [
                                "Chris Díaz (Español)",
                                "FYr76 (Nederlands, Frysk, Dansk)",
                                "Megachip (Deutsch)",
                                "Pavel Markin (Russian)",
                                "Guttorm Flatabø (Norwegian)",
                                "Vic L. (Chinese)",
                                "Andrzej Dopierała (Polish)",
                            ]
                            delegate: Text {
                                anchors.left: parent.left
                                anchors.right: parent.right

                                text: "- " + modelData
                                textFormat: Text.PlainText
                                color: Theme.colorSubText
                                font.pixelSize: Theme.fontSizeContent
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                ListSeparator { }

                ////////
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
