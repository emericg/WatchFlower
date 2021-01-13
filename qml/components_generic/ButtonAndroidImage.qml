import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Button {
    id: control
    width: contentRow.width + 16 + (source && !text ? 0 : 16)
    implicitHeight: 58 // Theme.componentHeight

    focusPolicy: Qt.NoFocus

    property url source: ""
    property int imgSize: 26 // UtilsNumber.alignTo(height * 0.666, 2)
    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorBackground

    ////////////////////////////////////////////////////////////////////////////

    background: Item {
        id: background

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
            anchors.margins: 0

            clip: true
            enabled: true
            visible: true
            hoverEnabled: false
            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true

            onPressed: {
                mouseBackground.width = mmmm.width*3
                mouseBackground.opacity = 0.1
            }
            onClicked: {
                control.clicked()
            }
            onReleased: {
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }/*
            onPositionChanged: {
                console.log("onPositionChanged")
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }*/

            Rectangle {
                id: mouseBackground
                width: 0; height: width; radius: width;
                x: mmmm.mouseX + 4 - (mouseBackground.width / 2)
                y: mmmm.mouseY + 4 - (mouseBackground.width / 2)
                color: "#222"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on width { NumberAnimation { duration: 200 } }
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
                opacity: enabled ? 1.0 : 0.33
                source: control.source
                color: fullColor ? fulltextColor : control.primaryColor
            }
            Text {
                id: contentText
                height: parent.height
                opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33

                text: control.text
                font.bold: true
                font.pixelSize: 14
                font.family: fontTextMedium.name

                color: fullColor ? fulltextColor : control.primaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
}
