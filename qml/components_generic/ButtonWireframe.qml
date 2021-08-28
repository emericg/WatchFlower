import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0

Button {
    id: control
    implicitWidth: contentTextInvisible.contentWidth + 24
    implicitHeight: Theme.componentHeight

    font.pixelSize: Theme.fontSizeComponent
    font.bold: fullColor ? true : false

    focusPolicy: Qt.NoFocus

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // colors
    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorComponentBackground

    // animation
    property bool hoverAnimation: isDesktop

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        opacity: enabled ? (control.down && !hoverAnimation ? 0.8 : 1.0) : 0.33
        color: fullColor ? control.primaryColor : control.secondaryColor
        border.width: Theme.componentBorderWidth
        border.color: fullColor ? control.primaryColor : Theme.colorComponentBorder

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
            hoverEnabled: hoverAnimation

            onClicked: {
                control.clicked()
            }
            onPressed: {
                control.pressed()
                control.down = true
                mouseBackground.width = background.width*2
                mouseBackground.opacity = 0.16
            }
            onPressAndHold: {
                control.pressAndHold()
                control.down = true
            }
            onReleased: {
                control.released()
                control.down = false
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }
            onEntered: {
                mouseBackground.width = 72
                mouseBackground.opacity = 0.16
            }
            onExited: {
                control.down = false
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }
            onCanceled: {
                control.down = false
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }

            Rectangle {
                id: mouseBackground
                width: 0; height: width; radius: width;
                x: parent.mouseX - (mouseBackground.width / 2)
                y: parent.mouseY - (mouseBackground.width / 2)

                visible: hoverAnimation
                color: "white"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on width { NumberAnimation { duration: 200 } }
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
        Text {
            id: contentTextInvisible
            // this one is just used for size reference
            text: control.text
            textFormat: Text.PlainText
            font: control.font
            visible: false
        }
        Text {
            id: contentText
            anchors.fill: parent

            text: control.text
            textFormat: Text.PlainText
            font: control.font
            opacity: enabled ? (control.down && !hoverAnimation ? 0.8 : 1.0) : 0.33
            color: fullColor ? fulltextColor : control.primaryColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            //elide: Text.ElideMiddle
            wrapMode: Text.WordWrap
        }
    }
}
