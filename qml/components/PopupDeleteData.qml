import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Popup {
    id: popupDelete
    x: (appWindow.width / 2) - (popupDelete.width / 2)
    y: singleColumn ? (appWindow.height - popupDelete.height) : ((appWindow.height / 2) - (popupDelete.height / 2) - appHeader.height)

    implicitWidth: 640
    implicitHeight: 320
    width: singleColumn ? parent.width : implicitWidth
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

                text: qsTr("Are you sure you want to delete data for this sensor?")
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width

                text: qsTr("You can either delete data from the application, or from both the sensor and application.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
            }

            Flow {
                id: flowContent
                width: parent.width
                height: singleColumn ? 120+32 : 40
                anchors.horizontalCenter: parent.horizontalCenter

                property var btnSize: singleColumn ? width : ((width-spacing*2) / 3)
                spacing: 16

                ButtonWireframe {
                    id: buttonCancel
                    width: parent.btnSize

                    text: qsTr("Cancel")
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground
                    onClicked: popupDelete.close()
                }
                ButtonWireframe {
                    id: buttonConfirm1
                    width: parent.btnSize

                    text: qsTr("Delete local data")
                    primaryColor: Theme.colorYellow
                    fullColor: true
                    onClicked: {
                        if (selectedDevice) {
                             // TODO
                        }

                        popupDelete.confirmed()
                        popupDelete.close()
                    }
                }
                ButtonWireframe {
                    id: buttonConfirm2
                    width: parent.btnSize

                    text: qsTr("Delete sensor data")
                    primaryColor: Theme.colorRed
                    fullColor: true
                    onClicked: {
                        if (selectedDevice) {
                             //selectedDevice.actionClearHistory()
                        }
                        popupDelete.confirmed()
                        popupDelete.close()
                    }
                }
            }
        }
    }
}
