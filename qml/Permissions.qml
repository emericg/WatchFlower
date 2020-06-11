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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Item {
    id: permissionsScreen
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

        visible: isDesktop

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: textTitle
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 12

            text: qsTr("Permissions")
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

            text: qsTr("Why are we using these permissions?")
            color: Theme.colorSubText
            font.pixelSize: 18
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
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            topPadding: 16
            bottomPadding: 16
            spacing: 16

            ////////

            Item {
                id: element_gps
                height: 32
                anchors.right: parent.right
                anchors.left: parent.left

                Text {
                    id: text_gps
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: switch_gps.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Location")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_gps
                    anchors.right: parent.right
                    anchors.rightMargin: -8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    enabled: (!checked)
                    Component.onCompleted: checked = utilsApp.checkMobileLocationPermission()
                    onCheckedChanged: checked = utilsApp.getMobileLocationPermission()
                }
            }
            Text {
                id: legend_gps
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                topPadding: -8
                bottomPadding: 0

                text: qsTr("Android operating system requires applications to ask for device location permission in order to scan for nearby Bluetooth LE sensors.<br>" +
                           "This permission is only needed while scanning for new sensors.<br>" +
                           "WatchFlower doesn't use, store nor communicate your location to anyone or anything.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }
            ButtonWireframe {
                height: 32

                text: qsTr("Official information")
                primaryColor: Theme.colorPrimary
                onClicked: Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth-le#permissions")
            }

            ////////
/*
            Item {
                height: 8
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
                id: element_storage
                height: 32
                anchors.right: parent.right
                anchors.left: parent.left

                Text {
                    id: text_storage
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: switch_storage.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Storage write permission")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_storage
                    anchors.right: parent.right
                    anchors.rightMargin: -8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    enabled: false // (!checked)

                    Component.onCompleted: checked = utilsApp.checkMobileStoragePermissions()
                    onCheckedChanged: checked = utilsApp.getMobileStoragePermissions()
                }
            }
            Text {
                id: legend_storage
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                topPadding: -8
                bottomPadding: 0

                text: qsTr("Storage write permission can be needed for exporting sensors data to the SD card.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }
*/
            ////////

            Item {
                height: 8
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
                id: element_bluetooth
                height: 32
                anchors.right: parent.right
                anchors.left: parent.left

                Text {
                    id: text_bluetooth
                    height: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: switch_bluetooth.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Bluetooth control")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchThemedMobile {
                    id: switch_bluetooth
                    anchors.right: parent.right
                    anchors.rightMargin: -8
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    enabled: (!checked)
                    checked: true
                }
            }
            Text {
                id: legend_bluetooth
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                topPadding: -8
                bottomPadding: 0

                text: qsTr("WatchFlower can activate your device's Bluetooth in order to operate.")
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: 14
            }

            ////////
        }
    }
}
