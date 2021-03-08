import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Button {
    id: control
    width: contentText.width + 24
    implicitHeight: 58

    focusPolicy: Qt.NoFocus

    property string primaryColor: Theme.colorPrimary

    ////////////////////////////////////////////////////////////////////////////

    background: Item {
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

                color: control.primaryColor
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
        Text {
            id: contentText
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            text: control.text
            textFormat: Text.PlainText
            font.bold: false
            font.pixelSize: Theme.fontSizeComponent
            font.family: fontTextMedium.name
            font.capitalization: Font.AllUppercase

            color: control.primaryColor
            opacity: enabled ? 1.0 : 0.33

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
