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
        Text {
            id: textArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            text: qsTr("Are you sure you want to delete selected device(s)?")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 18
            color: Theme.colorText
        }

        Row {
            id: rowButtons
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            spacing: 24

            ButtonWireframe {
                id: buttonCancel
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Cancel")
                onClicked: itemPopupDelete.close()
            }
            ButtonWireframe {
                id: buttonConfirm
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Delete")
                primaryColor: Theme.colorRed
                fullColor: true
                onClicked: {
                    itemPopupDelete.confirmed();
                    itemPopupDelete.close();
                }
            }
        }
    }
}
