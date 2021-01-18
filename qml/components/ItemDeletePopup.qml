import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Popup {
    id: itemDeletePopup
    implicitWidth: 560
    implicitHeight: 320

    property bool singleColumn: (isPhone || appWindow.width < implicitWidth)
    signal confirmed()

    width: singleColumn ? parent.width : implicitWidth
    height: columnContent.height + gridcontContent.height + 24
    x: (appWindow.width / 2) - (itemDeletePopup.width / 2)
    y: singleColumn ? (appWindow.height - height) : ((appWindow.height / 2) - (itemDeletePopup.height / 2) - appHeader.height)

    padding: 24
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

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
                    primaryColor: Theme.colorHeaderHighlight
                    onClicked: itemDeletePopup.close()
                }
                ButtonWireframe {
                    id: buttonConfirm
                    width: singleColumn ? parent.width : ((parent.width / 2) - (parent.spacing / 2))

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
