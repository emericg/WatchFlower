/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Item {
    id: aboutScreen
    width: 480
    height: 640
    anchors.fill: parent
    anchors.leftMargin: screenLeftPadding
    anchors.rightMargin: screenRightPadding

    Rectangle {
        id: rectangleHeader
        color: Theme.colorForeground
        height: 80
        z: 5

        visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: textTitle
            anchors.left: parent.left
            anchors.leftMargin: 16
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
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14

            text: qsTr("What do you want to know?")
            color: Theme.colorSubText
            font.pixelSize: 18
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ScrollView {
        id: scrollView
        contentWidth: -1

        anchors.top: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") ? rectangleHeader.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

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
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left

                    source: "qrc:/assets/logos/logo.svg"
                    sourceSize: Qt.size(width, height)
                }

                Text {
                    id: textVersion
                    anchors.left: imageLogo.right
                    anchors.leftMargin: 18
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10

                    color: Theme.colorSubText
                    text: qsTr("version %1%2").arg(utilsApp.appVersion()).arg(settingsManager.getDemoString())
                    font.pixelSize: 18
                }

                Text {
                    id: textName
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    anchors.left: imageLogo.right
                    anchors.leftMargin: 16

                    text: "WatchFlower"
                    color: Theme.colorText
                    font.pixelSize: 28
                }
            }

            Row {
                id: websiteANDgithub
                height: 56

                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: isMobile
                spacing: 16

                onWidthChanged: {
                    var ww = (scrollView.width - 48 - screenLeftPadding - screenRightPadding) / 2
                    if (ww > 0) { websiteBtn.width = ww; githubBtn.width = ww; }
                }

                ButtonWireframeImage {
                    id: websiteBtn
                    width: 180
                    anchors.verticalCenter: parent.verticalCenter

                    imgSize: 26
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

                    imgSize: 20
                    fullColor: true
                    primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    text: qsTr("SUPPORT")
                    source: "qrc:/assets/icons_material/baseline-support-24px.svg"
                    onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower/support.html")
                }
            }

            Item {
                id: desc
                height: 64
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
                    anchors.verticalCenter: description.verticalCenter

                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    color: Theme.colorText
                }

                TextArea {
                    id: description
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 40
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    color: Theme.colorText
                    text: qsTr("A plant monitoring application for Xiaomi 'Flower Care' and 'RoPot' Bluetooth sensors and thermometers.")
                    wrapMode: Text.WordWrap
                    readOnly: true
                    font.pixelSize: 16
                }
            }

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

                    color: Theme.colorText
                    linkColor: Theme.colorText
                    font.pixelSize: 16
                    text: qsTr("Application by <a href=\"https://emeric.io\">Emeric Grange</a><br>Visual design by <a href=\"https://dribbble.com/chrisdiaz\">Chris Díaz</a>")
                    onLinkActivated: Qt.openUrlExternally(link)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }
            }

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
                    color: Theme.colorText
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (Qt.platform.os === "android")
                                Qt.openUrlExternally("market://details?id=com.emeric.watchflower")
                            else if (Qt.platform.os === "ios")
                                Qt.openUrlExternally("itms-apps://itunes.apple.com/app/1476046123")
                        }
                    }
                }
            }

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
                    color: Theme.colorText
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        onClicked: screenTutorial.reopen("About")
                    }
                }
            }

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

                    color: Theme.colorText
                    text: qsTr("Website")
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower")
                    }
                }
            }

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

                    color: Theme.colorText
                    text: qsTr("GitHub page")
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower")
                    }
                }
            }

            Item {
                id: permissions
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                visible: isMobile

                ImageSvg {
                    id: permissionsImg
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-flaky-24px.svg"
                    color: Theme.colorText
                }

                Text {
                    id: permissionsTxt
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorText
                    text: qsTr("Permissions")
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        onClicked: appContent.state = "Permissions"
                    }
                }
            }

            ImageSvg {
                id: imageDevices
                height: 128
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 0

                fillMode: Image.PreserveAspectFit
                source: "qrc:/assets/devices/welcome-devices.svg"
                color: Theme.colorPrimary
            }

            ////////

            Item {
                height: 16
                anchors.right: parent.right
                anchors.left: parent.left

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: dependencies
                height: 64 + dependenciesColumn.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: dependenciesImg
                    width: 27
                    height: 27
                    anchors.left: parent.left
                    anchors.leftMargin: 2
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
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                    font.pixelSize: 16
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

                        text: qsTr("- Qt (LGPL 3)")
                        color: Theme.colorText
                        font.pixelSize: 16
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: qsTr("- Google Material Icons (MIT)")
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                        font.pixelSize: 16
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: qsTr("- StatusBar & SingleApplication (MIT)")
                        color: Theme.colorText
                        font.pixelSize: 16
                    }
                }
            }

            ////////

            Item {
                height: 16
                anchors.right: parent.right
                anchors.left: parent.left

                Rectangle {
                    height: 1
                    color: Theme.colorSeparator
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: translators
                height: 48 + translatorsColumn.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: translatorsImg
                    width: 27
                    height: 27
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.top: parent.top
                    anchors.topMargin: 12

                    source: "qrc:/assets/icons_material/baseline-translate-24px.svg"
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
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                    font.pixelSize: 16
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

                        text: qsTr("- Chris Díaz (Spanish)")
                        color: Theme.colorText
                        font.pixelSize: 16
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: qsTr("- FYr76 (Danish, Dutch, Frisian)")
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                        font.pixelSize: 16
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 12

                        text: qsTr("- Megachip (German)")
                        color: Theme.colorText
                        font.pixelSize: 16
                    }
                }
            }
        }
    }
}
