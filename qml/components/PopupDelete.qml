import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Popup {
    id: popupDelete
    x: (appWindow.width / 2) - (popupDelete.width / 2)
    y: singleColumn ? (appWindow.height - popupDelete.height) : ((appWindow.height / 2) - (popupDelete.height / 2) - appHeader.height)

    implicitWidth: 560
    implicitHeight: 320
    width: singleColumn ? parent.width : implicitWidth
    height: columnContent.height + gridcontContent.height + padding
    padding: singleColumn ? 24 : 32

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
            spacing: 24

            Text {
                width: parent.width

                text: qsTr("Are you sure you want to delete selected sensor(s)?")
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width

                text: qsTr("Data from the sensors are kept for an additional 90 days, in case you would like to re-add a sensor later.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
            }

            Grid {
                id: gridcontContent
                width: parent.width
                height: singleColumn ? 80+16 : 32
                anchors.horizontalCenter: parent.horizontalCenter

                columns: singleColumn ? 1 : 2
                rows: singleColumn ? 2 : 1
                spacing: 24

                ButtonWireframe {
                    id: buttonCancel
                    width: buttonConfirm.width

                    text: qsTr("Cancel")
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground
                    onClicked: popupDelete.close()
                }
                ButtonWireframe {
                    id: buttonConfirm
                    width: singleColumn ? parent.width : ((parent.width / 2) - (parent.spacing / 2))

                    text: qsTr("Delete")
                    primaryColor: Theme.colorRed
                    fullColor: true
                    onClicked: {
                        popupDelete.confirmed()
                        popupDelete.close()
                    }
                }
            }
        }
    }
}
