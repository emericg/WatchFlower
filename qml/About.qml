import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: aboutScreen
    width: 480
    height: 640
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        color: Theme.colorDeviceHeader
        height: 80
        z: 5

        visible: isDesktop

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        // prevent clicks below this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        Text {
            id: textTitle
            anchors.left: parent.left
            anchors.leftMargin: 16 + screenPaddingLeft
            anchors.top: parent.top
            anchors.topMargin: 12

            text: qsTr("About")
            font.bold: true
            font.pixelSize: Theme.fontSizeTitle
            color: Theme.colorText
        }

        Text {
            id: textSubtitle
            anchors.left: parent.left
            anchors.leftMargin: 16 + screenPaddingLeft
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14

            text: qsTr("What do you want to know?")
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentBig
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: (rectangleHeader.visible) ? rectangleHeader.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            anchors.fill: parent
            anchors.leftMargin: 16 + screenPaddingLeft
            anchors.rightMargin: 16 + screenPaddingRight

            topPadding: 8
            bottomPadding: 8
            spacing: 8

            ////////

            Item {
                id: logo
                height: 80
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Image {
                    id: imageLogo
                    width: 80
                    height: 80
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/logos/logo.svg"
                    sourceSize: Qt.size(width, height)
                }

                Text {
                    id: textVersion
                    anchors.left: imageLogo.right
                    anchors.leftMargin: 18
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8

                    color: Theme.colorSubText
                    text: qsTr("version %1%2").arg(utilsApp.appVersion()).arg(settingsManager.getDemoString())
                    font.pixelSize: Theme.fontSizeContentBig
                }

                Text {
                    id: textName
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    anchors.left: imageLogo.right
                    anchors.leftMargin: 16

                    text: "WatchFlower"
                    color: Theme.colorText
                    font.pixelSize: 28
                }
            }

            ////////

            Row {
                id: buttonsRow
                height: 56

                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: isMobile
                spacing: 16

                onWidthChanged: {
                    var ww = (scrollView.width - 48 - screenPaddingLeft - screenPaddingRight) / 2;
                    if (ww > 0) { websiteBtn.width = ww; githubBtn.width = ww; }
                }

                ButtonWireframeImage {
                    id: websiteBtn
                    width: 180
                    anchors.verticalCenter: parent.verticalCenter

                    imgSize: 28
                    fullColor: true
                    primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    text: qsTr("WEBSITE")
                    source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                    onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                }

                ButtonWireframeImage {
                    id: githubBtn
                    width: 180
                    anchors.verticalCenter: parent.verticalCenter

                    imgSize: 22
                    fullColor: true
                    primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    text: qsTr("SUPPORT")
                    source: "qrc:/assets/icons_material/baseline-support-24px.svg"
                    onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower/support.html")
                }
            }

            ////////

            Item { height: 1; width: 1; visible: isDesktop; } // spacer

            Item {
                id: desc
                height: Math.max(UtilsNumber.alignTo(description.contentHeight, 8), 48)
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: descImg
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: desc.verticalCenter

                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    color: Theme.colorText
                }

                Text {
                    id: description
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: desc.verticalCenter

                    text: qsTr("A plant monitoring application for Xiaomi 'Flower Care' and 'RoPot' Bluetooth sensors and thermometers.")
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

                ImageSvg {
                    id: authorImg
                    width: 31
                    height: 31
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-supervised_user_circle-24px.svg"
                    color: Theme.colorText
                }

                Text {
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
                        acceptedButtons: Qt.NoButton
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
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

                ImageSvg {
                    id: rateImg
                    width: 31
                    height: 31
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-stars-24px.svg"
                    color: Theme.colorText
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Rate the application")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -16
                        onClicked: {
                            if (Qt.platform.os === "android")
                                Qt.openUrlExternally("market://details?id=com.emeric.watchflower")
                            else if (Qt.platform.os === "ios")
                                Qt.openUrlExternally("itms-apps://itunes.apple.com/app/1476046123")
                        }
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

                ImageSvg {
                    id: tutoImg
                    width: 27
                    height: 27
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-import_contacts-24px.svg"
                    color: Theme.colorText
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Open the tutorial")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -16
                        onClicked: screenTutorial.reopen()
                    }
                }
            }

            ////////

            Item {
                id: website
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: !isMobile

                ImageSvg {
                    id: websiteImg
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: -1
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                    color: Theme.colorText
                }

                Text {
                    id: websiteTxt
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 48

                    text: qsTr("Website")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -16
                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                    }
                }
            }

            ////////

            Item {
                id: github
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: !isPhone

                ImageSvg {
                    id: githubImg
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/logos/github.svg"
                    color: Theme.colorText
                }

                Text {
                    id: githubTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("GitHub page")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -12
                        onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower")
                    }
                }
            }

            ////////

            ImageSvg {
                id: imageDevices
                height: 96
                anchors.left: parent.left
                anchors.leftMargin: 48
                anchors.right: parent.right
                anchors.rightMargin: 8

                visible: isPhone

                fillMode: Image.PreserveAspectFit
                source: "qrc:/assets/devices/welcome-devices.svg"
                color: Theme.colorPrimary
            }

            ////////

            Item {
                height: 16
                anchors.left: parent.left
                anchors.right: parent.right

                visible: (Qt.platform.os === "android")

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: permissions
                height: 32
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: (Qt.platform.os === "android")

                ImageSvg {
                    id: permissionsImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-flaky-24px.svg"
                    color: Theme.colorText
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

                ImageSvg {
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
                    color: Theme.colorText
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: screenPermissions.loadScreen()
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
                    anchors.right: parent.right
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

                ImageSvg {
                    id: dependenciesImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.top: parent.top
                    anchors.topMargin: 12

                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                    color: Theme.colorText
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

                        text: "- Qt (LGPL 3)"
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
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: "- MobileUI & SingleApplication (MIT)"
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
                    anchors.right: parent.right
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

                ImageSvg {
                    id: translatorsImg
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: translatorsLabel.verticalCenter

                    source: "qrc:/assets/icons_material/duotone-translate-24px.svg"
                    color: Theme.colorText
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

                        text: "- Guttorm Flatabø (Norwegian Nynorsk)"
                        textFormat: Text.PlainText
                        color: Theme.colorText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
