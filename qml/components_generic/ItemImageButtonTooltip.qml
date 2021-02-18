import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemImageButton
    implicitWidth: 40
    implicitHeight: 40

    signal clicked()

    // states
    property bool hovered: false
    property bool selected: false
    property bool highlighted: false

    // settings
    property int btnSize: height
    property int imgSize: UtilsNumber.alignTo(height * 0.666, 2)
    property url imgSource: ""
    property url source: ""

    property bool border: false
    property bool background: false
    property string highlightMode: "circle" // circle / color / both / off

    // colors
    property string iconColor: Theme.colorIcon
    property string highlightColor: Theme.colorPrimary
    property string backgroundColor: Theme.colorComponent
    property string borderColor: Theme.colorComponentBorder

    // animation
    property var animation: "rotation" // rotation / fade
    property var animationRunning: false

    // tooltip
    property string tooltipPosition: "bottom"
    property string tooltipText: ""

    Behavior on width { NumberAnimation { duration: 133 } }

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: itemImageButton
        onClicked: itemImageButton.clicked()

        hoverEnabled: true
        onEntered: {
            hovered = true
            highlighted = true
            bgRect.opacity = (highlightMode === "circle" || highlightMode === "both" || itemImageButton.background) ? 1 : 0.75
        }
        onExited: {
            hovered = false
            highlighted = false
            bgRect.opacity = itemImageButton.background ? 0.75 : 0
        }
    }

    Rectangle {
        id: bgRect
        width: btnSize
        height: btnSize
        radius: btnSize
        anchors.verticalCenter: itemImageButton.verticalCenter

        visible: (highlightMode === "circle" || highlightMode === "both" || itemImageButton.background)
        color: itemImageButton.backgroundColor

        border.width: itemImageButton.border ? 1 : 0
        border.color: itemImageButton.borderColor

        opacity: itemImageButton.background ? 0.75 : 0
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    ImageSvg {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.centerIn: bgRect

        opacity: itemImageButton.enabled ? 1.0 : 0.33
        Behavior on opacity { NumberAnimation { duration: 333 } }

        source: itemImageButton.source
        color: {
            if (selected === true) {
                itemImageButton.highlightColor
            } else if (highlightMode === "color" || highlightMode === "both") {
                itemImageButton.highlighted ? itemImageButton.highlightColor : itemImageButton.iconColor
            } else {
                itemImageButton.iconColor
            }
        }

        SequentialAnimation on opacity {
            running: animation === "fade" && animationRunning
            alwaysRunToEnd: true
            loops: Animation.Infinite

            PropertyAnimation { to: 0.33; duration: 750; }
            PropertyAnimation { to: 1; duration: 750; }
        }
        NumberAnimation on rotation {
            running: animation === "rotate" && animationRunning
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

        visible: itemImageButton.tooltipText
        enabled: itemImageButton.tooltipText

        property var tooltipVisible: itemImageButton.highlighted
        onTooltipVisibleChanged: ttT.checkPosition()

        opacity: tooltipVisible ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 133 } }

        state: itemImageButton.tooltipPosition
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
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 16

            function checkPosition() {
                if (!text) return;
                if (!itemImageButton.highlighted) return;

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

            text: itemImageButton.tooltipText
            color: iconColor
        }
    }
}
