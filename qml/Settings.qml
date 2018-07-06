/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    id: settingsRectangle
    width: 450
    height: 700

    property var mySettings

    Header {
        id: header
        anchors.top: parent.top

        backAvailable.visible: true
        scanAvailable.visible: false

        onBackClicked: {
            pageLoader.source = "main.qml"
        }
    }

    Rectangle {
        id: rectangleBody
        color: "#e0fae7"
        border.width: 0

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        MouseArea {
            id: mouseArea // so the underlying stuff doesn't hijack clicks
            anchors.fill: parent
        }

        Rectangle {
            id: rectangleHeader
            height: 80
            color: "#e8e9e8"
            border.width: 0

            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            Text {
                id: textAddr
                y: 46
                width: 375
                height: 16
                text: "Change persistent settings here"
                font.pixelSize: 16
                anchors.left: parent.left
                anchors.leftMargin: 13
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: text1
                height: 32
                color: "#454b54"
                text: qsTr("Settings")
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.top: parent.top
                anchors.topMargin: 12
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 26
            }
        }

        Rectangle {
            id: rectangleSettings
            y: 41
            width: 368
            height: 230
            color: "#f2f2f2"
            border.width: 0
            anchors.top:rectangleHeader.bottom
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Image {
                id: image_systray
                x: 12
                width: 40
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: parent.top
                anchors.topMargin: 8
                source: "../assets/app/watchflower_tray.svg"
            }

            CheckBox {
                id: checkBox_systray
                width: 332
                height: 40
                text: qsTr("Enable system tray icon")
                font.pixelSize: 16
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 12
                checked: mySettings.systray

                onCheckStateChanged: {
                    mySettings.systray = checked
                }
            }

            SpinBox {
                id: spinBox_update
                width: 128
                height: 40
                anchors.top: checkBox_systray.bottom
                anchors.topMargin: 16
                from: 30
                stepSize: 30
                to: 120
                anchors.left: parent.left
                anchors.leftMargin: 12
                value: mySettings.interval

                onValueChanged: {
                    mySettings.interval = value
                }
            }

            Text {
                id: text2
                width: 234
                height: 40
                anchors.top: spinBox_update.top
                anchors.topMargin: 0
                anchors.left: spinBox_update.right
                anchors.leftMargin: 16

                verticalAlignment: Text.AlignVCenter

                text: qsTr("Update interval in minutes")
                font.pixelSize: 16
            }

            Text {
                id: text3
                x: 3
                y: 128
                height: 40
                text: qsTr("Temperature unit:")
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: 16
                anchors.top: spinBox_update.bottom
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 12
                verticalAlignment: Text.AlignVCenter
            }

            RadioDelegate {
                id: radioDelegateCelsius
                height: 40
                text: qsTr("°C")
                anchors.left: text3.right
                anchors.leftMargin: 8
                anchors.top: text3.top
                anchors.topMargin: 0

                checked: {
                    if (mySettings.tempunit === 'C') {
                        radioDelegateCelsius.checked = true;
                        radioDelegateFahrenheit.checked = false;
                    } else {
                        radioDelegateCelsius.checked = false;
                        radioDelegateFahrenheit.checked = true;
                    }
                }

                onCheckedChanged: {
                    if (checked == true)
                        mySettings.tempunit = 'C';
                }
            }

            RadioDelegate {
                id: radioDelegateFahrenheit
                height: 40
                text: qsTr("°F")
                anchors.left: radioDelegateCelsius.right
                anchors.leftMargin: 0
                anchors.top: text3.top
                anchors.topMargin: 0

                checked: {
                    if (mySettings.tempunit === 'F') {
                        radioDelegateCelsius.checked = false;
                        radioDelegateFahrenheit.checked = true;
                    } else {
                        radioDelegateFahrenheit.checked = false;
                        radioDelegateCelsius.checked = true;
                    }
                }

                onCheckedChanged: {
                    if (checked === true)
                        mySettings.tempunit = 'F';
                }
            }

            Text {
                id: text4
                height: 40
                text: qsTr("Default graph:")
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                anchors.top: text3.bottom
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 12
            }

            ComboBox {
                id: comboBox_view
                anchors.left: text4.right
                anchors.leftMargin: 16
                anchors.top: text4.top
                anchors.topMargin: 0
                model: ListModel {
                    id: cbItemsView
                    ListElement { text: "daily"; }
                    ListElement { text: "hourly"; }
                }
                Component.onCompleted: {
                    currentIndex = find(mySettings.graphview);
                    if (currentIndex === -1) { currentIndex = 0 }
                }
                property bool cbinit: false
                onCurrentIndexChanged: {
                    if (cbinit)
                        mySettings.graphview = cbItemsView.get(currentIndex).text;
                    else
                        cbinit = true;
                }
            }

            ComboBox {
                id: comboBox_data
                anchors.left: comboBox_view.right
                anchors.leftMargin: 16
                anchors.top: comboBox_view.top
                anchors.topMargin: 0
                model: ListModel {
                    id: cbItemsData
                    ListElement { text: "hygro"; }
                    ListElement { text: "temp"; }
                    ListElement { text: "luminosity"; }
                    ListElement { text: "conductivity"; }
                }
                Component.onCompleted: {
                    currentIndex = find(mySettings.graphdata);
                    if (currentIndex === -1) { currentIndex = 0 }
                }
                property bool cbinit: false
                onCurrentIndexChanged: {
                    if (cbinit)
                        mySettings.graphdata = cbItemsData.get(currentIndex).text;
                    else
                        cbinit = true;
                }
            }
        }

        Rectangle {
            id: rectangleInfos
            x: 0
            y: 365
            height: 100
            color: "#00000000"
            anchors.top: rectangleSettings.bottom
            anchors.topMargin: 16
            opacity: 1
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Text {
                id: textUrl
                y: 92
                color: "#343434"
                text: qsTr("Visit the project page on") + " <html><style type=\"text/css\"></style><a href=\"https://github.com/emericg/WatchFlower\">github</a></html>!"
                anchors.verticalCenterOffset: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: imageLogo.right
                anchors.leftMargin: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
                onLinkActivated: Qt.openUrlExternally("https://github.com/emericg/WatchFlower")
            }

            Image {
                id: imageLogo
                x: 167
                y: 4
                width: 80
                height: 80
                anchors.horizontalCenterOffset: -159
                anchors.verticalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/app/watchflower.png"
            }

            Text {
                id: textVersion
                y: 45
                height: 20
                color: "#343434"
                text: { mySettings.getAppVersion() }
                anchors.verticalCenterOffset: -8
                anchors.left: imageLogo.right
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
            }
        }

        Rectangle {
            id: rectangleReset
            height: 58
            color: "#f75a5a"

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16

            property bool weAreBlinking: false

            function startTheBlink() {
                if (weAreBlinking === true) {
                    mySettings.resetSettings();
                    stopTheBlink();
                } else {
                    weAreBlinking = true;
                    timerReset.start();
                    blinkReset.start();
                    textReset.text = qsTr("!!! Click again to confirm !!!");
                }
            }
            function stopTheBlink() {
                weAreBlinking = false;
                timerReset.stop();
                blinkReset.stop();
                textReset.text = qsTr("Reset everything!");
                rectangleReset.color = "#f75a5a";
            }

            SequentialAnimation on color {
                id: blinkReset
                running: false
                loops: Animation.Infinite
                ColorAnimation { from: "#f75a5a"; to: "#ff0000"; duration: 750 }
                ColorAnimation { from: "#ff0000"; to: "#f75a5a"; duration: 750 }
            }

            Timer {
                id: timerReset
                interval: 4000
                running: false
                repeat: false
                onTriggered: {
                    rectangleReset.stopTheBlink()
                }
            }

            Text {
                id: textReset
                anchors.fill: parent
                color: "#ffffff"
                text: qsTr("Reset everything!")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 20
            }
            MouseArea {
                anchors.fill: parent

                onPressed: {
                    rectangleReset.anchors.bottomMargin = rectangleReset.anchors.bottomMargin + 4
                    rectangleReset.anchors.leftMargin = rectangleReset.anchors.leftMargin + 4
                    rectangleReset.anchors.rightMargin = rectangleReset.anchors.rightMargin + 4
                    rectangleReset.width = rectangleReset.width - 8
                    rectangleReset.height = rectangleReset.height - 8
                }
                onReleased: {
                    rectangleReset.anchors.bottomMargin = rectangleReset.anchors.bottomMargin - 4
                    rectangleReset.anchors.leftMargin = rectangleReset.anchors.leftMargin - 4
                    rectangleReset.anchors.rightMargin = rectangleReset.anchors.rightMargin - 4
                    rectangleReset.width = rectangleReset.width + 8
                    rectangleReset.height = rectangleReset.height + 8
                }
                onClicked: {
                    rectangleReset.startTheBlink()
                }
            }
        }
    }
}
