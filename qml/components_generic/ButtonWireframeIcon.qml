import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import QtGraphicalEffects 1.15 // Qt5
//import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    width: {
        if (source.toString().length && text) return contentTextInvisible.contentWidth + sourceSize + 32
        if (source.toString().length <= 0 && text) return contentTextInvisible.contentWidth + 24
        return height
    }

    font.pixelSize: Theme.fontSizeComponent
    font.bold: fullColor ? true : false

    focusPolicy: Qt.NoFocus

    // settings
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)
    property bool sourceRightToLeft: false

    // colors
    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorComponentBackground

    // animation
    property bool hoverAnimation: isDesktop

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mousearea
        anchors.fill: parent
        enabled: control.hoverAnimation

        hoverEnabled: control.hoverAnimation
        property bool hovered: false

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: {
            control.down = true
            mouseBackground.width = (control.width * 2)
            mouseBackground.opacity = 0.16
        }
        onReleased: {
            control.down = false
            //mouseBackground.width = 0
            //mouseBackground.opacity = 0
        }

        onEntered: {
            mousearea.hovered = true
            mouseBackground.width = 72
            mouseBackground.opacity = 0.16
        }
        onExited: {
            mousearea.hovered = false
            control.down = false
            mouseBackground.width = 0
            mouseBackground.opacity = 0
        }
        onCanceled: {
            mousearea.hovered = false
            control.down = false
            mouseBackground.width = 0
            mouseBackground.opacity = 0
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        anchors.fill: control

        radius: Theme.componentRadius
        opacity: enabled ? (control.down && !control.hoverAnimation ? 0.8 : 1.0) : 0.4
        color: control.fullColor ? control.primaryColor : control.secondaryColor
        border.width: Theme.componentBorderWidth
        border.color: control.fullColor ? control.primaryColor : Theme.colorComponentBorder

        Rectangle {
            id: mouseBackground
            width: 0; height: width; radius: width;
            x: mousearea.mouseX - (width / 2)
            y: mousearea.mouseY - (width / 2)

            visible: control.hoverAnimation
            color: "white"
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 333 } }
            Behavior on width { NumberAnimation { duration: 200 } }
        }

        layer.enabled: control.hoverAnimation
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

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Text { // this one is just used for size reference
            id: contentTextInvisible
            text: control.text
            textFormat: Text.PlainText
            font: control.font
            visible: false
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            layoutDirection: (control.sourceRightToLeft) ? Qt.RightToLeft : Qt.LeftToRight
            spacing: 8

            IconSvg {
                id: contentImage
                width: control.sourceSize
                height: control.sourceSize
                anchors.verticalCenter: parent.verticalCenter

                visible: control.source.toString().length
                source: control.source
                opacity: enabled ? 1.0 : 0.66
                color: control.fullColor ? control.fulltextColor : control.primaryColor
            }
            Text {
                id: contentText
                height: control.height
                visible: control.text
                anchors.verticalCenter: parent.verticalCenter

                text: control.text
                textFormat: Text.PlainText
                font: control.font
                opacity: enabled ? (control.down && !control.hoverAnimation ? 0.8 : 1.0) : 0.66
                color: control.fullColor ? control.fulltextColor : control.primaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                //elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
        }
    }
}
