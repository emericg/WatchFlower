import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.qmlmodels 1.0

import ThemeEngine 1.0

Popup {
    id: actionMenu
    width: parent.width

    padding: 0
    margins: 0

    parent: Overlay.overlay
    modal: true
    dim: false
    focus: isMobile
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var model: null
    property int layoutDirection: Qt.LeftToRight

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    property int yHidden: appWindow.height + actionMenu.height
    property int yTarget: appWindow.height - actionMenu.height

    enter: Transition {
        //NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; }
        NumberAnimation { property: "y"; from: actionMenu.yHidden; to: actionMenu.yTarget; duration: 233; }
    }
    exit: Transition {
        //NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; }
        NumberAnimation { property: "y"; from: actionMenu.yTarget; to: actionMenu.yHidden; duration: 233; }
    }

    ////////
/*
    states: [
        State {
            name: "visible"
            PropertyChanges { target: background; opacity: 1 }
        },
        State {
            name: "hidden"
            PropertyChanges { target: background; opacity: 0 }
        }
    ]

    enter: Transition {
        //NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; }
        NumberAnimation { property: "y"; from: actionMenu.yHidden; to: actionMenu.yTarget; duration: 233; }
    }
    exit: Transition {
        //NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; }
        NumberAnimation { property: "y"; from: actionMenu.yTarget; to: actionMenu.yHidden; duration: 233; }
    }

/*
    transitions: [
        Transition {
            from: "hidden"; to: "visible"
            SequentialAnimation {
                PropertyAction { target: popup; property: "visible"; value: true }
                NumberAnimation {
                    target: background
                    property: "opacity"
                    duration: 200
                    easing.type: Easing.Bezier; easing.bezierCurve: [0.4, 0, 0.2, 1, 1, 1]
                }
            }
        },
        Transition {
            from: "visible"; to: "hidden"
            SequentialAnimation {
                NumberAnimation {
                    target: background
                    property: "opacity"
                    duration: 200
                    easing.type: Easing.Bezier; easing.bezierCurve: [0.4, 0, 0.2, 1, 1, 1]
                }
                PropertyAction { target: popup; property: "visible"; value: false }
            }
        }
    ]
*/
    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        radius: Theme.componentRadius
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        padding: Theme.componentBorderWidth

        topPadding: 8
        bottomPadding: 8
        spacing: 4

        DelegateChooser {
            id: chooser
            role: "t"
            DelegateChoice {
                roleValue: "sep"
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Theme.componentBorderWidth
                    color: Theme.colorSeparator
                }
            }
            DelegateChoice {
                roleValue: "itm"
                ActionMenuItem {
                    index: idx
                    text: txt
                    source: src
                    layoutDirection: actionMenu.layoutDirection
                    onClicked: {
                        actionMenu.menuSelected(idx)
                        actionMenu.close()
                    }
                }
            }
        }

        Repeater {
            model: actionMenu.model
            delegate: chooser
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
