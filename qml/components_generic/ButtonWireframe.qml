import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0

Button {
    id: control
    width: contentText.width + 24
    implicitHeight: Theme.componentHeight

    font.pixelSize: Theme.fontSizeComponent
    font.bold: fullColor ? true : false

    focusPolicy: Qt.NoFocus

    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorComponentBackground
    property bool hoverAnimation: isDesktop

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33
        color: fullColor ? control.primaryColor : control.secondaryColor
        border.width: Theme.componentBorderWidth
        border.color: fullColor ? control.primaryColor : Theme.colorComponentBorder

        MouseArea {
            id: mmmm
            anchors.fill: parent
            acceptedButtons: Qt.NoButton

            enabled: hoverAnimation
            visible: hoverAnimation
            hoverEnabled: hoverAnimation

            onPressed: {
                mouseBackground.width = background.width*2
            }
            onEntered: {
                mouseBackground.width = 80
                mouseBackground.opacity = 0.16
            }
            onExited: {
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }

            Rectangle {
                id: mouseBackground
                width: 0; height: width; radius: width;
                x: mmmm.mouseX - (mouseBackground.width / 2)
                y: mmmm.mouseY - (mouseBackground.width / 2)

                color: "#fff"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 133 } }
                Behavior on width { NumberAnimation { duration: 133 } }
            }

            layer.enabled: hoverAnimation
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: background.radius
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        anchors.fill: parent

        Text {
            id: contentText
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            text: control.text
            textFormat: Text.PlainText
            font: control.font
            opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33
            color: fullColor ? fulltextColor : control.primaryColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
