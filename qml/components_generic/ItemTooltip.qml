import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemTooltip

    property var itemTooltipParent: itemTooltip.parent
    property string text: ""
/*
    visible: text
    enabled: text
    //opacity: parent.highlighted ? 1 : 0
*/
    visible: true
    enabled: true
    opacity: 1

    Behavior on opacity { OpacityAnimator { duration: 133 } }
    Behavior on width { NumberAnimation { duration: 133 } }

    state: "bottom"
    states: [
        State {
            name: "top"
            AnchorChanges {
                target: itemTooltip
                anchors.bottom: itemTooltip.parent.top
                anchors.horizontalCenter: itemTooltip.parent.horizontalCenter
            }
            AnchorChanges {
                target: ttA
                anchors.bottom: itemTooltip.parent.top
                anchors.horizontalCenter: itemTooltip.parent.horizontalCenter
            }
            AnchorChanges {
                target: ttT
                anchors.bottom: itemTooltip.parent.top
                anchors.horizontalCenter: itemTooltip.parent.horizontalCenter
            }
            //PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
        },
        State {
            name: "bottom"
            AnchorChanges {
                target: itemTooltip
                anchors.top: itemTooltip.parent.bottom
                anchors.horizontalCenter: itemTooltip.parent.horizontalCenter
            }
            AnchorChanges {
                target: ttA
                anchors.top: itemTooltip.parent.bottom
                anchors.horizontalCenter: itemTooltip.parent.horizontalCenter
            }
            AnchorChanges {
                target: ttT
                anchors.top: itemTooltip.parent.bottom
                anchors.horizontalCenter: itemTooltip.parent.horizontalCenter
            }
            //PropertyChanges { target: screenTutorial; enabled: false; visible: false; }
        },
        State {
            name: "left"
            AnchorChanges {
                target: itemTooltip
                anchors.right: itemTooltip.parent.left
                anchors.verticalCenter: itemTooltip.parent.verticalCenter
            }
            AnchorChanges {
                target: ttA
                anchors.right: itemTooltip.parent.left
                anchors.verticalCenter: itemTooltip.parent.verticalCenter
            }
            AnchorChanges {
                target: ttT
                anchors.right: itemTooltip.parent.left
                anchors.verticalCenter: itemTooltip.parent.verticalCenter
            }
        },
        State {
            name: "right"
            AnchorChanges {
                target: itemTooltip
                anchors.left: itemTooltip.parent.right
                anchors.verticalCenter: itemTooltip.parent.verticalCenter
            }
            AnchorChanges {
                target: ttA
                anchors.left: itemTooltip.parent.right
                anchors.verticalCenter: itemTooltip.parent.verticalCenter
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
        width: 10; height: 10; rotation: 45
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
        anchors.margins: 16

        text: itemTooltip.text
        color: iconColor
    }
}
