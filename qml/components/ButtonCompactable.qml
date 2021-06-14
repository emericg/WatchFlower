import QtQuick 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: buttonCompactable
    implicitWidth: 40
    implicitHeight: 40

    width: compact ? height : (contentRow.width + 12 + ((source && !text) ? 0 : 16))

    signal clicked()
    signal pressed()
    signal longPressed()

    property bool compact: true

    property alias source: contentImage.source
    property alias text: contentText.text

    property int iconSize: UtilsNumber.alignTo(height * 0.666, 2)
    property string iconColor: Theme.colorIcon
    property string backgroundColor: Theme.colorComponent

    // animation
    property var animation: "" // rotate / fade
    property var animationRunning: false

    // hover animation
    property bool hovered: false
    property bool hoverAnimation: (isDesktop && !compact)

    // tooltip
    property string tooltipPosition: "bottom"
    property string tooltipText: ""

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: bgRect
        anchors.fill: parent

        radius: compact ? (parent.height / 2) : Theme.componentRadius
        color: backgroundColor
        opacity: (!compact || hovered) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 333 } }

        MouseArea {
            id: mmmm
            anchors.fill: parent

            onClicked: buttonCompactable.clicked()
            onPressed: mouseBackground.width = bgRect.width*2

            hoverEnabled: isDesktop
            onEntered: {
                hovered = true
                if (hoverAnimation) {
                    mouseBackground.width = 80
                    mouseBackground.opacity = 0.16
                }
            }
            onExited: {
                hovered = false
                if (hoverAnimation) {
                    mouseBackground.width = 0
                    mouseBackground.opacity = 0
                }
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
        }

        layer.enabled: hoverAnimation
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: bgRect.x
                y: bgRect.y
                width: bgRect.width
                height: bgRect.height
                radius: bgRect.radius
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        ImageSvg {
            id: contentImage
            width: iconSize
            height: iconSize

            opacity: buttonCompactable.enabled ? 1.0 : 0.4
            Behavior on opacity { NumberAnimation { duration: 333 } }

            source: buttonCompactable.source
            color: iconColor

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

        Text {
            id: contentText
            anchors.verticalCenter: parent.verticalCenter
            visible: !compact

            textFormat: Text.PlainText
            color: buttonCompactable.iconColor
            font.pixelSize: Theme.fontSizeComponent
            font.bold: true
            elide: Text.ElideRight
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: tooltip
        anchors.fill: bgRect

        visible: tooltipText
        enabled: tooltipText

        property bool tooltipVisible: (buttonCompactable.compact && buttonCompactable.hovered)
        onTooltipVisibleChanged: ttT.checkPosition()

        opacity: tooltipVisible ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 133 } }

        state: buttonCompactable.tooltipPosition
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
            width: 12; height: 12; rotation: 45
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
                if (!hovered) return;

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

            text: tooltipText
            textFormat: Text.PlainText
            color: iconColor
        }
    }
}
