import QtQuick 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: control
    implicitWidth: 40
    implicitHeight: 40

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // states
    property bool hovered: false
    property bool selected: false

    // settings
    property string text: ""
    property int btnSize: height
    property int txtSize: (height * 0.4)
    property string highlightMode: "circle" // available: circle, color, both, off

    property bool border: false
    property bool background: false

    // colors
    property string textColor: Theme.colorText
    property string highlightColor: Theme.colorPrimary
    property string borderColor: Theme.colorComponentBorder
    property string backgroundColor: Theme.colorComponent

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: control
        propagateComposedEvents: false
        hoverEnabled: true

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()

        onEntered: {
            hovered = true
            bgRect.opacity = (highlightMode === "circle" || highlightMode === "both" || control.background) ? 1 : 0.75
        }
        onExited: {
            hovered = false
            bgRect.opacity = control.background ? 0.75 : 0
        }
        onCanceled: {
            hovered = false
            bgRect.opacity = control.background ? 0.75 : 0
        }
    }

    Rectangle {
        id: bgRect
        width: btnSize
        height: btnSize
        radius: btnSize
        anchors.verticalCenter: control.verticalCenter

        visible: (highlightMode === "circle" || highlightMode === "both" || control.background)
        color: control.backgroundColor

        border.width: control.border ? 1 : 0
        border.color: control.borderColor

        opacity: control.background ? 0.75 : 0
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    Text {
        id: contentText
        anchors.centerIn: bgRect

        text: control.text
        textFormat: Text.PlainText
        font.bold: true
        font.pixelSize: control.txtSize
        font.capitalization: Font.AllUppercase

        opacity: control.enabled ? 1.0 : 0.75
        color: {
            if (selected === true) {
                control.highlightColor
            } else if (highlightMode === "color" || highlightMode === "both") {
                control.hovered ? control.highlightColor : control.textColor
            } else {
                control.textColor
            }
        }
    }
}
