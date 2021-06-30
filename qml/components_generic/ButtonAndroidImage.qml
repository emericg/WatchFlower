import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Button {
    id: control
    implicitWidth: contentRow.width + 16 + (source && !text ? 0 : 16)
    implicitHeight: 58

    focusPolicy: Qt.NoFocus

    property url source: ""
    property int imgSize: 26

    property string primaryColor: Theme.colorPrimary

    ////////////////////////////////////////////////////////////////////////////

    background: Item {

        Rectangle {
            id: rect
            anchors.fill: parent
            border.color: "#eee"
            radius: Theme.componentRadius
            border.width: 1
            color: "white"
        }
        DropShadow {
            anchors.fill: rect
            cached: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 4.0
            samples: 8
            color: "#20000000"
            source: rect
        }

        ////////

        MouseArea {
            id: mmmm
            anchors.fill: parent

            enabled: true
            visible: true
            hoverEnabled: false
            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true

            onClicked: control.clicked()

            onPressed: {
                mouseBackground.width = mmmm.width*2
                mouseBackground.opacity = 0.1
            }
            onReleased: {
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }

            Rectangle {
                id: mouseBackground
                width: 0; height: width; radius: width;
                x: mmmm.mouseX + 4 - (mouseBackground.width / 2)
                y: mmmm.mouseY + 4 - (mouseBackground.width / 2)

                color: "#222"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 333 } }
                Behavior on width { NumberAnimation { duration: 333 } }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: Theme.componentRadius
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Row {
            id: contentRow
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 8
            spacing: 8

            ImageSvg {
                id: contentImage
                width: imgSize
                height: imgSize
                anchors.verticalCenter: parent.verticalCenter

                visible: source
                source: control.source
                color: control.primaryColor
                opacity: enabled ? 1.0 : 0.33
            }
            Text {
                id: contentText
                height: parent.height

                text: control.text
                textFormat: Text.PlainText
                font.bold: true
                font.pixelSize: Theme.fontSizeComponent
                font.family: fontTextMedium.name

                color: control.primaryColor
                opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
}
