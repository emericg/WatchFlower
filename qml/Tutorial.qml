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
import QtGraphicalEffects 1.0
import com.watchflower.theme 1.0

Rectangle {
    id: element
    width: 480
    height: 640
    anchors.fill: parent

    color: Theme.colorHeader

    property string goBackTo: "DeviceList"
    onGoBackToChanged: swipeView.currentIndex = 0 // reset

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.bottomMargin: 48

        currentIndex: 0
        onCurrentIndexChanged: {
            if (currentIndex < 0) currentIndex = 0
            if (currentIndex > 2) {
                currentIndex = 0 // reset
                content.state = goBackTo
            }
        }

        ////////

        Item {
            id: page1

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    id: element1
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("WatchFlower is a plant monitoring application for Xiaomi / MiJia '<b>Flower Care</b>' and '<b>Ropot</b>' bluetooth devices.")
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Theme.colorHeaderContent
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }
                Image {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    source: "qrc:/assets/devices/welcome-devices.svg"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        Item {
            id: page2

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    id: element2
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("To start using WatchFlower, you'll need to <b>scan for compatible bluetooth devices</b> near you.")
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }
                Image {
                    anchors.right: parent.right
                    anchors.rightMargin: 64
                    anchors.left: parent.left
                    anchors.leftMargin: 64

                    source: "qrc:/assets/devices/welcome-bluetooth-searching.svg"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    id: element55
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: ""
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }
            }
        }

        Item {
            id: page3

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    id: element3
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("Once devices are <b>paired</b>, the application will periodically <b>sync</b> these devices datas.")
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }
                Image {
                    id: element4
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    source: "qrc:/assets/devices/welcome-app-connected.svg"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    id: element5
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("You can also <b>name your plants</b>, and customize settings like <b>optimal water level</b>...")
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }
            }
        }
    }

    ////////

    Text {
        id: pagePrevious
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: pageIndicator.verticalCenter

        visible: (swipeView.currentIndex != 0)

        text: qsTr("Previous")
        color: Theme.colorHeaderContent
        font.bold: true
        font.pixelSize: 16

        Behavior on opacity {
            OpacityAnimator { duration: 100 }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.opacity = 0.8
            onExited: parent.opacity = 1
            onClicked: swipeView.currentIndex--
        }
    }

    Text {
        id: pageNext
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: pageIndicator.verticalCenter

        text: (swipeView.currentIndex === 2) ? qsTr("Allright!") : qsTr("Next")
        color: Theme.colorHeaderContent
        font.bold: true
        font.pixelSize: 16

        Behavior on opacity {
            OpacityAnimator { duration: 100 }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.opacity = 0.8
            onExited: parent.opacity = 1
            onClicked: swipeView.currentIndex++
        }
    }

    PageIndicator {
        id: pageIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16

        count: 3
        currentIndex: swipeView.currentIndex

        delegate: Rectangle {
            implicitWidth: 12
            implicitHeight: 12

            radius: width / 2
            color: Theme.colorHeaderContent

            opacity: index === pageIndicator.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

            Behavior on opacity {
                OpacityAnimator { duration: 100 }
            }
        }
    }
}
