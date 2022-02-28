import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Popup {
    id: popupCalibration
    x: (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height) : ((appWindow.height / 2) - (height / 2) /*- (appHeader.height)*/)

    width: singleColumn ? parent.width : 640
    height: columnContent.height + padding*2
    padding: singleColumn ? 20 : 24

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    signal confirmed()

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: singleColumn ? 0 : Theme.componentBorderWidth
        radius: singleColumn ? 0 : Theme.componentRadius

        Rectangle {
            width: parent.width
            height: Theme.componentBorderWidth
            visible: singleColumn
            color: Theme.colorSeparator
        }
    }

    contentItem: Item {
        Column {
            id: columnContent
            width: parent.width
            spacing: 20

            Text {
                width: parent.width

                text: qsTr("You are about to start sensor calibration.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Column {
                width: parent.width
                spacing: 8

                Text {
                    width: parent.width

                    text: qsTr("Calibration is only needed when the values from the sensor stop making sense.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width

                    text: qsTr("Before starting the calibration, please note that you need to place this sensor either <b>outside</b>, <b>next to a window</b>, or <b>inside a very well ventilated room</b>.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width

                    text: qsTr("The calibration process will take around 10 minutes to complete.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
            }

            Flow {
                id: flowContent
                width: parent.width
                height: singleColumn ? 80+16 : 40

                property var btnSize: singleColumn ? width : ((width-spacing) / 2)
                spacing: 16

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Cancel")
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground

                    onClicked: popupCalibration.close()
                }
                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Start calibration")
                    primaryColor: Theme.colorPrimary
                    fullColor: true

                    onClicked: {
                        if (selectedDevice) {
                             selectedDevice.actionCalibrate()
                        }
                        popupCalibration.confirmed()
                        popupCalibration.close()
                    }
                }
            }
        }
    }
}
