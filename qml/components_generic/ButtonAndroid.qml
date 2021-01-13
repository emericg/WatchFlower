import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Button {
    id: control
    width: contentText.width + 24
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    property string primaryColor: Theme.colorPrimary

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        opacity: control.down ? 0.1 : 0.0
        color: control.primaryColor
        clip: true
        Behavior on opacity { NumberAnimation { duration: 133 } }
/*
        MouseArea {
            id: mmmm
            anchors.fill: parent
            acceptedButtons: Qt.NoButton

            enabled: hoverAnimation
            visible: hoverAnimation
            hoverEnabled: hoverAnimation

            onPressed: {
                mouseBackground.width = parent.width
                mouseBackground.height = parent.height
                mouseBackground.opacity = 0.1
            }
            onClicked: {
                control.clicked()
            }
            onReleased: {
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }

            Rectangle {
                id: mouseBackground
                width: 0; height: 0; radius: Theme.componentRadius;
                x: mmmm.mouseX + 4 - (mouseBackground.width / 2)
                y: mmmm.mouseY + 4 - (mouseBackground.width / 2)
                color: "#fff"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 133 } }
                Behavior on width { NumberAnimation { duration: 133 } }
            }
        }*/
    }

    contentItem: Item {
        anchors.fill: parent

        Text {
            id: contentText
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            text: control.text
            font.bold: false
            font.pixelSize: 14
            font.family: fontTextMedium.name
            font.capitalization: Font.AllUppercase

            opacity: enabled ? 1.0 : 0.33
            color: control.primaryColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
