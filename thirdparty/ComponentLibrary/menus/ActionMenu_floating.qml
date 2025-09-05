import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Qt.labs.qmlmodels

import ComponentLibrary

T.Popup {
    id: actionMenu

    width: 200
    height: contentColumn.height

    padding: 0
    margins: 0

    modal: true
    dim: false
    focus: isMobile
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside
    //parent: T.Overlay.overlay // let it float

    property string titleTxt
    property string titleSrc

    property var model: null

    property int layoutDirection: Qt.LeftToRight

    signal menuSelected(var index)

    ////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

    ////////////////

    background: Rectangle {
        color: Theme.colorComponentBackground
        radius: Theme.componentRadius
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowOpacity: 0.24
            shadowColor: background.border.color
        }
    }

    ////////////////

    contentItem: Item {
        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right

            topPadding: 10
            bottomPadding: 10
            spacing: 2

            ////

            ActionMenuItem_button {
                width: actionMenu.width
                visible: actionMenu.titleTxt
                text: actionMenu.titleTxt
                source: actionMenu.titleSrc
                opacity: 0.8
                layoutDirection: actionMenu.layoutDirection
                onClicked: actionMenu.close()
            }
            ActionMenuItem_separator {
                width: actionMenu.width
                visible: actionMenu.titleTxt
                opacity: 0.8
            }

            ////

            Repeater {
                model: actionMenu.model
                delegate: DelegateChooser {
                    role: "t"
                    DelegateChoice {
                        roleValue: "sep"
                        ActionMenuItem_separator {
                            width: actionMenu.width
                        }
                    }
                    DelegateChoice {
                        roleValue: "itm"
                        ActionMenuItem_button {
                            width: actionMenu.width
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
            }

            ////
        }
    }

    ////////////////
}
