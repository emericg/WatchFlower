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

import QtQuick 2.7
import QtQuick.Controls 2.0

import QtGraphicalEffects 1.0
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
        border.width: 0

        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Text {
            id: textTitle
            color: Theme.colorTitles
            text: qsTr("About")
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12
            font.bold: true
            font.pixelSize: 26
        }

        Text {
            id: textSubtitle
            text: qsTr("What do you want to know?")
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
        }
    }

    Rectangle {
        id: rectangleContent
        color: "#00000000"
        anchors.top: rectangleAboutTitle.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: 0
    }

    Column {
        id: column
        anchors.top: rectangleAboutTitle.bottom
        anchors.topMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16

        Item {
            id: logo
            height: 100
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Image {
                id: imageLogo
                width: 88
                height: 88
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left

                source: "qrc:/assets/desktop/watchflower.svg"
                sourceSize: Qt.size(width, height)
            }

            Text {
                id: textVersion
                anchors.left: imageLogo.right
                anchors.leftMargin: 18

                color: "#343434"
                text: qsTr("version") + " " + settingsManager.getAppVersion()
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                font.pixelSize: 17
            }

            Text {
                id: element1
                text: qsTr("WatchFlower")
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.left: imageLogo.right
                anchors.leftMargin: 16
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

            Image {
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0

                source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }

            Text {
                color: "#343434"
                text: "Website"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 48
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 17

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

            Image {
                id: image4
                width: 28
                height: 28
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 2

                source: "qrc:/assets/github.png"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }

            Text {
                id: link
                color: "#343434"
                text: "GitHub page"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 48
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 17

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

            visible: false

            Image {
                width: 32
                height: 32
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 8

                source: "qrc:/assets/icons_material/baseline-import_contacts-24px.svg.png"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 48
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Tutorial")
                color: "#343434"
                font.pixelSize: 17

                MouseArea {
                    id: mouseArea1
                    anchors.fill: parent
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

            Image {
                width: 32
                height: 32
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 0

                source: "qrc:/assets/icons_material/outline-info-24px.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Theme.colorIcons
                }
            }
            TextArea {
                id: description

                text: qsTr("WatchFlower is a plant monitoring application that reads and plots datas from these Xiaomi / Mijia bluetooth devices:")
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 40
                wrapMode: Text.WordWrap
                readOnly: true
                font.pixelSize: 18
            }

            Item {
                id: rectangleIcons
                height: 96
                anchors.top: description.bottom
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0

                Image {
                    id: image3
                    width: 80
                    height: 80
                    anchors.left: image2.right
                    anchors.leftMargin: 32
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/devices/hygrotemp.svg"
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width, height)
                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Theme.colorIcons
                    }
                }

                Image {
                    id: image2
                    width: 80
                    height: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/ropot.svg"
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width, height)
                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Theme.colorIcons
                    }
                }

                Image {
                    id: image1
                    width: 80
                    height: 80
                    anchors.right: image2.left
                    anchors.rightMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/flowercare.svg"
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width, height)
                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Theme.colorIcons
                    }
                }
            }
        }
    }
}
