import QtQuick 2.12
import QtGraphicalEffects 1.12 // Qt5
//import Qt5Compat.GraphicalEffects // Qt6

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
    property url source: ""

    property string highlightMode: "circle" // available: border, circle, color, both (circle+color), off
    property bool border: false
    property bool background: false

    property int rotation: 0
    property int btnSize: height
    property int imgSize: UtilsNumber.alignTo(height * 0.666, 2)

    // colors
    property string iconColor: Theme.colorIcon
    property string highlightColor: Theme.colorPrimary
    property string borderColor: Theme.colorComponentBorder
    property string backgroundColor: Theme.colorComponent

    // animation
    property string animation: "" // available: rotate, fade
    property bool animationRunning: false

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: control

        hoverEnabled: true
        propagateComposedEvents: false

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()

        onEntered: hovered = true
        onExited: hovered = false
        onCanceled: hovered = false
    }

    ////////
/*
    Glow {
        id: bgBlur
        anchors.fill: bgRect
        source: bgRect

        cached: true
        radius: 8
        samples: 16
        opacity: 0.33
        color: Theme.colorSecondary
    }
*/
    DropShadow {
        anchors.fill: bgRect
        source: bgRect

        horizontalOffset: 1
        verticalOffset: 2

        cached: true
        radius: 8
        samples: 17
        color: "#aaa"
    }

    ////////

    Rectangle {
        id: bgRect
        width: btnSize
        height: btnSize
        radius: btnSize
        anchors.centerIn: control

        visible: (highlightMode === "circle" || highlightMode === "both" || control.background)
        color: control.backgroundColor

        border.width: {
            if (control.border || ((hovered || selected) && highlightMode === "border"))
                return Theme.componentBorderWidth
            return 0
        }
        border.color: control.borderColor

        opacity: {
            if (hovered) {
               return (highlightMode === "circle" || highlightMode === "both" || control.background) ? 1 : 0.75
            } else {
                return control.background ? 0.75 : 0
            }
        }
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    ////////

    ImageSvg {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.centerIn: control

        rotation: control.rotation
        opacity: control.enabled ? 1.0 : 0.33
        Behavior on opacity { NumberAnimation { duration: 333 } }

        source: control.source
        color: {
            if ((selected || hovered) && (highlightMode === "color" || highlightMode === "both")) {
                return control.highlightColor
            }
            return control.iconColor
        }

        SequentialAnimation on opacity {
            running: (animation === "fade" && animationRunning)
            alwaysRunToEnd: true
            loops: Animation.Infinite

            PropertyAnimation { to: 0.33; duration: 750; }
            PropertyAnimation { to: 1; duration: 750; }
        }
        NumberAnimation on rotation {
            running: (animation === "rotate" && animationRunning)
            alwaysRunToEnd: true
            loops: Animation.Infinite

            duration: 1500
            from: 0
            to: 360
            easing.type: Easing.Linear
        }
    }
}
