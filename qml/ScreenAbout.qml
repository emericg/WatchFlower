import QtQuick
import QtQuick.Controls

import ComponentLibrary
import SmartCare

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

    sourceComponent: Flickable {
        anchors.fill: parent
        contentWidth: -1
        contentHeight: contentColumn.height

        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar { visible: false }

        function backAction() {
            screenDeviceList.loadScreen()
        }

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right

            ////////////////

            Rectangle { // header area
                anchors.left: parent.left
                anchors.leftMargin: -screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: -screenPaddingRight

                height: 96
                color: headerUnicolor ? Theme.colorForeground : Theme.colorBackground

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                    anchors.verticalCenter: parent.verticalCenter

                    z: 2
                    height: 96
                    spacing: Theme.componentMargin

                    Image { // logo
                        anchors.verticalCenter: parent.verticalCenter
                        width: 96
                        height: 96

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
                            text: "SmartCare"
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
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin
                    anchors.verticalCenter: parent.verticalCenter

                    visible: wideWideMode
                    spacing: Theme.componentMargin

                    ButtonSolid {
                        width: isPhone ? 150 : 160
                        height: 40

                        text: qsTr("WEBSITE")
                        source: "qrc:/IconLibrary/material-symbols/link.svg"
                        sourceSize: 28
                        font.bold: true
                        color: Theme.colorPrimary

                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                    }

                    ButtonSolid {
                        width: isPhone ? 150 : 160
                        height: 40

                        text: qsTr("SUPPORT")
                        source: "qrc:/IconLibrary/material-symbols/support.svg"
                        sourceSize: 22
                        font.bold: true
                        color:  Theme.colorPrimary

                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower/support.html")
                    }

                    ButtonSolid {
                        width: isPhone ? 150 : 160
                        height: 40

                        visible: (appWindow.width > 800)

                        text: qsTr("GitHub")
                        source: "qrc:/assets/gfx/logos/github.svg"
                        sourceSize: 22
                        font.bold: true
                        color: Theme.colorPrimary

                        onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower")
                    }
                }

                ////////

                Rectangle { // bottom separator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 2
                    visible: isDesktop
                    border.color: Theme.colorSeparator
                }
            }

            ////////////////

            Row { // mobile buttons row
                height: 72

                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin

                visible: !wideWideMode
                spacing: Theme.componentMargin

                ButtonFlat {
                    anchors.verticalCenter: parent.verticalCenter
                    width: ((parent.width - parent.spacing) / 2)
                    height: 40

                    text: qsTr("WEBSITE")
                    source: "qrc:/IconLibrary/material-symbols/link.svg"
                    sourceSize: 28
                    font.bold: true
                    color: Theme.colorPrimary

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
                    color: Theme.colorPrimary

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

            IconSvg { // image devices
                anchors.left: parent.left
                anchors.leftMargin: appHeader.headerPosition
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin

                height: 96
                visible: isPhone
                source: isPhone ? "qrc:/assets/gfx/tutorial/welcome-devices.svg" : ""
                fillMode: Image.PreserveAspectFit
                color: Theme.colorPrimary
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
                            "Google Material Icons (MIT)",
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

    ////////////////////////////////////////////////////////////////////////////
}
