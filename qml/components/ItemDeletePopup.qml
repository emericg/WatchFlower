import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Popup {
    id: itemDeletePopup
    implicitWidth: 560
    implicitHeight: 320

    width: singleColumn ? parent.width : implicitWidth
    height: columnContent.height + gridcontContent.height + 24
    x: (appWindow.width / 2) - (itemDeletePopup.width / 2)
    y: singleColumn ? (appWindow.height - height) : ((appWindow.height / 2) - (itemDeletePopup.height / 2) - appHeader.height)

    padding: singleColumn ? 24 : 32
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property bool singleColumn: (isPhone || appWindow.width < implicitWidth)

    signal confirmed()

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        radius: singleColumn ? 0 : 4
    }

    contentItem: Item {
        Column {
            id: columnContent
            width: parent.width
            spacing: 24

            Text {
                width: parent.width

                text: qsTr("Are you sure you want to delete selected device(s)?")
                font.pixelSize: 20
                color: Theme.colorText
                wrapMode: Text.WordWrap
                //verticalAlignment: Text.AlignVCenter
                //horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width

                text: qsTr("Data from the device(s) will be kept for an additional 90 days, if you want to re-add this device later.")
                font.pixelSize: 16
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                //verticalAlignment: Text.AlignVCenter
                //horizontalAlignment: Text.AlignHCenter
            }

            Grid {
                id: gridcontContent
                width: singleColumn ? parent.width : 300+24
                height: singleColumn ? 80+16 : 40
                anchors.horizontalCenter: parent.horizontalCenter

                columns: singleColumn ? 1 : 2
                rows: singleColumn ? 2 : 1
                spacing: 24

                ButtonWireframe {
                    id: buttonCancel
                    width: singleColumn ? parent.width : 150

                    text: qsTr("Cancel")
                    primaryColor: Theme.colorHeaderHighlight
                    onClicked: itemDeletePopup.close()
                }
                ButtonWireframe {
                    id: buttonConfirm
                    width: singleColumn ? parent.width : 150

                    text: qsTr("Delete")
                    primaryColor: Theme.colorRed
                    fullColor: true
                    onClicked: {
                        itemDeletePopup.confirmed()
                        itemDeletePopup.close()
                    }
                }
            }
        }
    }
}
