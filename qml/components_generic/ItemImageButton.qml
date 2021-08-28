import QtQuick 2.12

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
    property int btnSize: height
    property int imgSize: UtilsNumber.alignTo(height * 0.666, 2)
    property string highlightMode: "circle" // available: circle, color, both, off

    property int rotation: 0
    property bool border: false
    property bool background: false

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
    }

    Rectangle {
        id: bgRect
        width: btnSize
        height: btnSize
        radius: btnSize
        anchors.verticalCenter: control.verticalCenter

        visible: (highlightMode === "circle" || highlightMode === "both" || control.background)
        color: control.backgroundColor

        border.width: control.border ? Theme.componentBorderWidth : 0
        border.color: control.borderColor

        opacity: control.background ? 0.75 : 0
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    ImageSvg {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.centerIn: bgRect

        rotation: control.rotation
        opacity: control.enabled ? 1.0 : 0.33

        source: control.source
        color: {
            if (selected === true) {
                control.highlightColor
            } else if (highlightMode === "color" || highlightMode === "both") {
                control.hovered ? control.highlightColor : control.iconColor
            } else {
                control.iconColor
            }
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
