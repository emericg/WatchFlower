import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Popup {
    id: itemPopupDelete
    implicitWidth: 480
    implicitHeight: 180

    signal confirmed()

    padding: 24
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        radius: 8
    }

    contentItem: Item {
        Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 32

            Text {
                width: parent.width

                text: qsTr("Are you sure you want to delete selected device(s)?")
                font.pixelSize: 20
                color: Theme.colorText
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                height: 40
                spacing: 24
                anchors.horizontalCenter: parent.horizontalCenter

                ButtonWireframe {
                    id: buttonCancel
                    width: 128
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Cancel")
                    onClicked: itemPopupDelete.close()
                }
                ButtonWireframe {
                    id: buttonConfirm
                    width: 128
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Delete")
                    primaryColor: Theme.colorRed
                    fullColor: true
                    onClicked: {
                        itemPopupDelete.confirmed()
                        itemPopupDelete.close()
                    }
                }
            }
        }
    }
}
