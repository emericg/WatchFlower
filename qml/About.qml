import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Loader {
    id: aboutScreen

    function loadScreen() {
        // load screen
        aboutScreen.active = true

        // change screen
        appContent.state = "About"
    }

    function backAction() {
        if (aboutScreen.status === Loader.Ready)
            aboutScreen.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: false

    sourceComponent: Flickable {
        anchors.fill: parent
        contentWidth: -1
        contentHeight: column.height

        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar { visible: false }

        Column {
            id: column
            anchors.left: parent.left
            anchors.leftMargin: screenPaddingLeft + 16
            anchors.right: parent.right
            anchors.rightMargin: screenPaddingRight + 16

            topPadding: 0
            bottomPadding: 8
            spacing: 8

            ////////////////

            Rectangle { // header
                anchors.left: parent.left
                anchors.leftMargin: -(screenPaddingLeft + 16)
                anchors.right: parent.right
                anchors.rightMargin: -(screenPaddingRight + 16)

                height: 96
                color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    z: 2
                    height: 92
                    spacing: 16

                    Image { // logo
                        width: 92
                        height: 92
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/logos/logo.svg"
                        sourceSize: Qt.size(width, height)
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 2
                        spacing: 0

                        Text {
                            text: "WatchFlower"
                            color: Theme.colorText
                            font.pixelSize: 28
                        }
                        Text {
                            color: Theme.colorSubText
                            text: qsTr("version %1 %2").arg(utilsApp.appVersion()).arg(utilsApp.appBuildMode())
                            font.pixelSize: Theme.fontSizeContentBig
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    visible: wideWideMode
                    spacing: 16

                    ButtonWireframeIconCentered {
                        width: 160
                        sourceSize: 28
                        fullColor: true
                        primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        text: qsTr("WEBSITE")
                        source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                    }

                    ButtonWireframeIconCentered {
                        width: 160
                        sourceSize: 22
                        fullColor: true
                        primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        text: qsTr("SUPPORT")
                        source: "qrc:/assets/icons_material/baseline-support-24px.svg"
                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower/support.html")
                    }

                    ButtonWireframeIconCentered {
                        visible: (appWindow.width > 800)
                        width: 160
                        sourceSize: 22
                        fullColor: true
                        primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        text: qsTr("GitHub")
                        source: "qrc:/assets/logos/github.svg"
                        onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower")
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    visible: isDesktop
                    color: Theme.colorSeparator
                }
            }

            ////////////////

            Row {
                id: buttonsRow
                height: 56

                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: !wideWideMode
                spacing: 16

                ButtonWireframeIconCentered {
                    width: ((parent.width - 16) / 2)
                    anchors.verticalCenter: parent.verticalCenter

                    sourceSize: 28
                    fullColor: true
                    primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    text: qsTr("WEBSITE")
                    source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                    onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                }
                ButtonWireframeIconCentered {
                    width: ((parent.width - 16) / 2)
                    anchors.verticalCenter: parent.verticalCenter

                    sourceSize: 22
                    fullColor: true
                    primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    text: qsTr("SUPPORT")
                    source: "qrc:/assets/icons_material/baseline-support-24px.svg"
                    onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower/support.html")
                }
            }

            ////////////////

            Item { height: 1; width: 1; visible: isDesktop; } // spacer

            Item {
                id: desc
                height: Math.max(UtilsNumber.alignTo(description.contentHeight, 8), 48)
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: descImg
                    width: 32
                    height: 32
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left

                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: description
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: desc.verticalCenter

                    text: qsTr("A plant monitoring application that reads and plots data from compatible Bluetooth sensors and thermometers like Xiaomi 'Flower Care' or Parrot 'Flower Power'.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                }
            }

            ////////

            Item {
                id: authors
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: authorImg
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-supervised_user_circle-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: authorTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Application by <a href=\"https://emeric.io\">Emeric Grange</a><br>Visual design by <a href=\"https://dribbble.com/chrisdiaz\">Chris Díaz</a>")
                    textFormat: Text.StyledText
                    onLinkActivated: Qt.openUrlExternally(link)
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    linkColor: Theme.colorText

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -12
                        acceptedButtons: Qt.NoButton
                        cursorShape: authorTxt.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                IconSvg {
                    width: 20
                    height: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    visible: singleColumn

                    source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                    color: Theme.colorIcon
                }
            }

            ////////

            Item {
                id: rate
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                IconSvg {
                    id: rateImg
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-stars-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: rateTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Rate the application")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                IconSvg {
                    width: 20
                    height: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    visible: singleColumn

                    source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                    color: Theme.colorIcon
                }

                MouseArea {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: singleColumn ? parent.right : rateTxt.right
                    anchors.rightMargin: singleColumn ? 0 : -24
                    anchors.bottom: parent.bottom

                    onClicked: {
                        if (Qt.platform.os === "android")
                            Qt.openUrlExternally("market://details?id=com.emeric.watchflower")
                        else if (Qt.platform.os === "ios")
                            Qt.openUrlExternally("itms-apps://itunes.apple.com/app/1476046123")
                        else
                            Qt.openUrlExternally("https://github.com/emericg/WatchFlower/stargazers")
                    }
                }
            }

            ////////

            Item {
                id: tuto
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    width: 28
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-import_contacts-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: tutoTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Open the tutorial")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                IconSvg {
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.rightMargin: -2
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
                    color: Theme.colorIcon
                }

                MouseArea {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: singleColumn ? parent.right : tutoTxt.right
                    anchors.rightMargin: singleColumn ? 0 : -24
                    anchors.bottom: parent.bottom

                    onClicked: screenTutorial.loadScreenFrom("About")
                }
            }

            ////////

            Item {
                id: permissions
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: (Qt.platform.os === "android")

                IconSvg {
                    id: permissionsImg
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-flaky-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: permissionsTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("About permissions")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                IconSvg {
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.rightMargin: -2
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
                    color: Theme.colorIcon
                }

                MouseArea {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: singleColumn ? parent.right : permissionsTxt.right
                    anchors.rightMargin: singleColumn ? 0 : -24
                    anchors.bottom: parent.bottom

                    onClicked: screenPermissions.loadScreenFrom("About")
                }
            }
            ////////

            IconSvg {
                id: imageDevices
                height: 96
                anchors.left: parent.left
                anchors.leftMargin: 48
                anchors.right: parent.right
                anchors.rightMargin: 8

                visible: isPhone
                source: isPhone ? "qrc:/assets/tutorial/welcome-devices.svg" : ""

                color: Theme.colorPrimary
                fillMode: Image.PreserveAspectFit
            }

            ////////

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.left: parent.left
                    anchors.leftMargin: -(screenPaddingLeft + 16)
                    anchors.right: parent.right
                    anchors.rightMargin: -(screenPaddingRight + 16)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: releasenotes
                height: 32
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: releasenotesImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/outline-new_releases-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: releasenotesTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Release notes")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                IconSvg {
                    width: 20
                    height: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                    color: Theme.colorIcon
                }

                MouseArea {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: singleColumn ? parent.right : releasenotesTxt.right
                    anchors.rightMargin: singleColumn ? 0 : -24
                    anchors.bottom: parent.bottom

                    onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower/releases")
                }
            }

            ////////

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.left: parent.left
                    anchors.leftMargin: -(screenPaddingLeft + 16)
                    anchors.right: parent.right
                    anchors.rightMargin: -(screenPaddingRight + 16)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: supportedsensors
                height: 32
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: supportedsensorsImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: supportedsensorsTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Supported sensors")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                IconSvg {
                    width: 20
                    height: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                    color: Theme.colorIcon
                }

                MouseArea {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: singleColumn ? parent.right : supportedsensorsTxt.right
                    anchors.rightMargin: singleColumn ? 0 : -24
                    anchors.bottom: parent.bottom

                    onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower/blob/master/docs/README.md")
                }
            }

            ////////

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.left: parent.left
                    anchors.leftMargin: -(screenPaddingLeft + 16)
                    anchors.right: parent.right
                    anchors.rightMargin: -(screenPaddingRight + 16)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: dependencies
                height: 24 + dependenciesLabel.height + dependenciesColumn.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: dependenciesImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: dependenciesLabel.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: dependenciesLabel
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    text: qsTr("This application is made possible thanks to a couple of third party open source projects:")
                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                    wrapMode: Text.WordWrap
                }

                Column {
                    id: dependenciesColumn
                    anchors.top: dependenciesLabel.bottom
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    spacing: 4

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- Qt6 (LGPL v3)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- MobileUI (MIT)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- MobileSharing (MIT)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- SingleApplication (MIT)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- Google Material Icons (MIT)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ////////

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.left: parent.left
                    anchors.leftMargin: -(screenPaddingLeft + 16)
                    anchors.right: parent.right
                    anchors.rightMargin: -(screenPaddingRight + 16)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: translators
                height: 24 + translatorsLabel.height + translatorsColumn.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                IconSvg {
                    id: translatorsImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: translatorsLabel.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-translate-24px.svg"
                    color: Theme.colorIcon
                }

                Text {
                    id: translatorsLabel
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    text: qsTr("Special thanks to our translators:")
                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                    wrapMode: Text.WordWrap
                }

                Column {
                    id: translatorsColumn
                    anchors.top: translatorsLabel.bottom
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    spacing: 4

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- Chris Díaz (Español)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- FYr76 (Nederlands, Frysk, Dansk)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- Megachip (Deutsch)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- Pavel Markin (Russian)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- Guttorm Flatabø (Norwegian)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- Vic L. (Chinese)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ////////
        }
    }
}
