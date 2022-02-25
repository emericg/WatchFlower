import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.ToolTip {
    id: control

    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: -implicitHeight - 8

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 6
    padding: 6

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    // colors
    property string textColor: Theme.colorText
    property string backgroundColor: Theme.colorComponent

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font: control.font
        wrapMode: Text.Wrap
        color: control.textColor
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: control.backgroundColor
        radius: 4

        Rectangle { // arrow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top

            width: 12; height: 12; rotation: 45
            color: control.backgroundColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
/*
Item { // fully manual implementation // deprecated
    id: tooltip
    anchors.fill: parent

    visible: control.tooltipText
    property bool tooltipVisible: (control.compact && control.hovered)
    onTooltipVisibleChanged: ttT.checkPosition()

    opacity: (tooltipVisible) ? 1 : 0
    Behavior on opacity { OpacityAnimator { duration: 133 } }

    state: "left"//control.tooltipPosition
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
        color: control.backgroundColor
    }
    Rectangle {
        id: ttBg
        anchors.fill: ttT
        anchors.margins: -6
        radius: 4
        color: control.backgroundColor
    }
    Text {
        id: ttT
        anchors.topMargin: 16
        anchors.leftMargin: (tooltip.state === "topLeft" || tooltip.state === "bottomLeft") ? 8 : 16
        anchors.rightMargin: (tooltip.state === "topRight" || tooltip.state === "bottomRight") ? 8 : 16
        anchors.bottomMargin: 16

        text: control.tooltipText
        textFormat: Text.PlainText
        color: control.textColor

        function checkPosition() {
            if (!control.tooltipText) return
            if (!control.hovered) return

            var obj = mapToItem(appContent, x, y)
            var thestart = obj.x
            var theend = obj.x + 12*2 + ttT.width

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
    }
}
*/
