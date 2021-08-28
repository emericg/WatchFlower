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
    property int btnSize: height
    property int imgSize: UtilsNumber.alignTo(height * 0.666, 2)
    property url source: ""
    property int rotation: 0

    property bool border: false
    property bool background: false
    property string highlightMode: "circle" // available: circle, color, both, off

    // colors
    property string iconColor: Theme.colorIcon
    property string highlightColor: Theme.colorPrimary
    property string backgroundColor: Theme.colorComponent
    property string borderColor: Theme.colorComponentBorder

    // animation
    property string animation: "" // available: rotate, fade
    property bool animationRunning: false

    // tooltip
    property string tooltipPosition: "bottom"
    property string tooltipText: ""

    Behavior on width { NumberAnimation { duration: 133 } }

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
        Behavior on opacity { NumberAnimation { duration: 333 } }

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

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: tooltip
        anchors.fill: bgRect

        visible: control.tooltipText
        enabled: control.tooltipText

        property bool tooltipVisible: control.hovered
        onTooltipVisibleChanged: ttT.checkPosition()

        opacity: tooltipVisible ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 133 } }

        state: control.tooltipPosition
        states: [
            State {
                name: "top"
                AnchorChanges {
                    target: ttA
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            },
            State {
                name: "topLeft"
                AnchorChanges {
                    target: ttA
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.top: parent.bottom
                    anchors.left: parent.left
                }
            },
            State {
                name: "topRight"
                AnchorChanges {
                    target: ttA
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.top: parent.bottom
                    anchors.right: parent.right
                }
            },
            State {
                name: "bottom"
                AnchorChanges {
                    target: ttA
                    anchors.top: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.top: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            },
            State {
                name: "bottomLeft"
                AnchorChanges {
                    target: ttA
                    anchors.top: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.top: parent.bottom
                    anchors.left: parent.left
                }
            },
            State {
                name: "bottomRight"
                AnchorChanges {
                    target: ttA
                    anchors.top: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.top: parent.bottom
                    anchors.right: parent.right
                }
            },
            State {
                name: "left"
                AnchorChanges {
                    target: ttA
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.right: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            },
            State {
                name: "right"
                AnchorChanges {
                    target: ttA
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
                AnchorChanges {
                    target: ttT
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        ]

        Rectangle {
            id: ttA
            anchors.margins: 4
            width: 12; height: 12;
            rotation: 45
            color: backgroundColor
        }
        Rectangle {
            id: ttBg
            anchors.fill: ttT
            anchors.margins: -6
            radius: 4
            color: backgroundColor
        }
        Text {
            id: ttT
            anchors.topMargin: 16
            anchors.leftMargin: (tooltip.state === "topLeft" || tooltip.state === "bottomLeft") ? 8 : 16
            anchors.rightMargin: (tooltip.state === "topRight" || tooltip.state === "bottomRight") ? 8 : 16
            anchors.bottomMargin: 16

            function checkPosition() {
                if (!text) return;
                if (!control.hovered) return;

                var obj = mapToItem(appContent, x, y)
                var thestart = obj.x - 12
                var theend = obj.x + 12 + 12 + ttT.contentWidth

                if (tooltip.state === "top") {
                    if (thestart < 0) {
                        tooltip.state = "topLeft"
                    } else if (theend > appContent.width) {
                        tooltip.state = "topRight"
                    } else {
                        tooltip.state = "top"
                    }
                } else if (tooltip.state === "bottom") {
                    if (thestart < 0) {
                        tooltip.state = "bottomLeft"
                    } else if (theend > appContent.width) {
                        tooltip.state = "bottomRight"
                    } else {
                        tooltip.state = "bottom"
                    }
                }
            }

            text: control.tooltipText
            textFormat: Text.PlainText
            color: iconColor
        }
    }
}
