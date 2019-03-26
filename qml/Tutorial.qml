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

Rectangle {
    id: element
    width: 480
    height: 640
    anchors.fill: parent

    color: (Qt.platform.os !== "android" && Qt.platform.os !== "ios") ? Theme.colorHeaderDesktop : Theme.colorHeaderMobile

    property string goBackTo: "DeviceList"
    onGoBackToChanged: currentIndex = 0 // reset

    SwipeView {
        id: swipeView
        anchors.fill: parent

        currentIndex: 0
        onCurrentIndexChanged: {
            if (currentIndex < 0) currentIndex = 0
            if (currentIndex > 2) {
                currentIndex = 0 // reset
                content.state = goBackTo
            }
        }

        Item {
            id: page1

            Text {
                id: element1
                anchors.right: parent.right
                anchors.rightMargin: 32
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -70

                text: qsTr("WatchFlower is a plant monitoring application for Xiaomi / MiJia 'Flower Care' and 'Ropot' bluetooth devices.")
                color: "white"
                wrapMode: Text.WordWrap
                //horizontalAlignment: Text.AlignHCenter
                font.bold: true
                font.pixelSize: 18
            }
            Row {
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: element1.bottom
                anchors.topMargin: 32
                spacing: 32

                ImageSvg {
                    width: 80
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/hygrotemp.svg"
                    color: "white"
                }
                ImageSvg {
                    width: 80
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/ropot.svg"
                    color: "white"
                }
                ImageSvg {
                    width: 80
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/flowercare.svg"
                    color: "white"
                }
            }
        }

        Item {
            id: page2

            Text {
                id: element2
                anchors.right: parent.right
                anchors.rightMargin: 32
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -70

                text: qsTr("To start using WatchFlower, you first need to search for compatible bluetooth devices near you.")
                color: "white"
                wrapMode: Text.WordWrap
                //horizontalAlignment: Text.AlignHCenter
                font.bold: true
                font.pixelSize: 18
            }
            Row {
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: element2.bottom
                anchors.topMargin: 32
                spacing: 32

                ImageSvg {
                    width: 64
                    height: 64
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/flowercare.svg"
                    color: "white"
                }
                ImageSvg {
                    width: 80
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-bluetooth_searching-24px.svg"
                    color: "white"
                }
                ImageSvg {
                    width: 64
                    height: 64
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/ropot.svg"
                    color: "white"
                }
            }
        }

        Item {
            id: page3

            Text {
                id: element3
                anchors.right: parent.right
                anchors.rightMargin: 32
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -70

                text: qsTr("Once devices are paired, the application will periodically sync these devices datas.\nYou can set name to your plants and customize settings like optimal water level...")
                color: "white"
                wrapMode: Text.WordWrap
                //horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18
                font.bold: true
            }
            Row {
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: element3.bottom
                anchors.topMargin: 32
                spacing: 32

                ImageSvg {
                    width: 80
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                    color: "white"
                }
                ImageSvg {
                    width: 64
                    height: 64
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/devices/flowercare.svg"
                    color: "white"
                }
                ImageSvg {
                    width: 80
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-tune-24px.svg"
                    color: "white"
                }
            }
        }
    }

    Text {
        id: pagePrevious
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: pageIndicator.verticalCenter

        visible: (swipeView.currentIndex != 0)

        text: qsTr("Previous")
        color: "white"
        font.bold: true
        font.pixelSize: 16

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
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

        text: (swipeView.currentIndex == 2) ? qsTr("Start!") : qsTr("Next")
        color: "white"
        font.bold: true
        font.pixelSize: 16

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
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
            color: "white"

            opacity: index === pageIndicator.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

            Behavior on opacity {
                OpacityAnimator {
                    duration: 100
                }
            }
        }
    }
}
