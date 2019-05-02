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

import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

Item {
    id: aboutScreen
    width: 480
    height: 640
    anchors.fill: parent

    Rectangle {
        id: rectangleAboutTitle
        height: 80
        color: Theme.colorMaterialDarkGrey

        visible: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Text {
            id: textTitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 12

            font.bold: true
            font.pixelSize: 26
            color: Theme.colorText
            text: qsTr("About")
        }

        Text {
            id: textSubtitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14

            text: qsTr("What do you want to know?")
            font.pixelSize: 16
        }
    }

    ScrollView {
        id: scrollView
        clip: true
        contentWidth: -1

        anchors.top: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") ? rectangleAboutTitle.bottom : parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            id: column
            spacing: 8
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 16
            anchors.rightMargin: 16
            anchors.leftMargin: 16

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

                    source: "qrc:/assets/logo.svg"
                    sourceSize: Qt.size(width, height)
                }

                Text {
                    id: textVersion
                    anchors.left: imageLogo.right
                    anchors.leftMargin: 18
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10

                    color: Theme.colorSubText
                    text: qsTr("version") + " " + settingsManager.getAppVersion()
                    font.pixelSize: 16
                }

                Text {
                    id: element1
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: imageLogo.right
                    anchors.leftMargin: 16

                    text: qsTr("WatchFlower")
                    color: Theme.colorText
                    font.pixelSize: 36
                }
            }

            Item {
                id: website
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                ImageSvg {
                    id: websiteImg
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                    color: Theme.colorText
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 48

                    color: Theme.colorText
                    text: "Website"
                    font.pixelSize: 16

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally("https://emeric.io/WatchFlower.html")
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

                ImageSvg {
                    id: githubImg
                    width: 28
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    source: "qrc:/assets/github.svg"
                    color: Theme.colorText
                }

                Text {
                    id: link
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    horizontalAlignment: Text.AlignHCenter

                    color: Theme.colorText
                    text: "GitHub page"
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower")
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
                    width: 30
                    height: 30
                    anchors.left: parent.left
                    anchors.leftMargin: 1
                    anchors.top: parent.top
                    anchors.topMargin: 8
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
                        id: mouseArea1
                        anchors.fill: parent
                        onClicked: {
                            screenTutorial.goBackTo = "About"
                            content.state = "Tutorial"
                        }
                    }
                }
            }

            Item {
                id: desc
                height: 180
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                ImageSvg {
                    id: descImg
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    color: Theme.colorText
                    anchors.verticalCenter: description.verticalCenter
                }

                TextArea {
                    id: description
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 40

                    color: Theme.colorText
                    text: qsTr("A plant monitoring application for Xiaomi / MiJia 'Flower Care' and 'Ropot' bluetooth devices.")
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    wrapMode: Text.WordWrap
                    readOnly: true
                    font.pixelSize: 16
                }

                ImageSvg {
                    id: imageDevices
                    height: 96
                    anchors.left: description.left
                    anchors.leftMargin: 0
                    anchors.right: description.right
                    anchors.rightMargin: 0

                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/assets/devices/welcome-devices.svg"
                    color: Theme.colorGreen
                    anchors.top: description.bottom
                    anchors.topMargin: 24
                }
            }
        }
    }
}
