import QtQuick
import QtQuick.Effects
import QtQuick.Controls

import ThemeEngine

Popup {
    id: popupMacAddress

    x: singleColumn ? 0 : (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height)
                    : ((appWindow.height / 2) - (height / 2))

    width: singleColumn ? appWindow.width : 720
    height: columnContent.height + padding*2 + screenPaddingNavbar + screenPaddingBottom
    padding: Theme.componentMarginXL
    margins: 0

    dim: true
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    ////////////////////////////////////////////////////////////////////////////

    onAboutToShow: {
        textInputMacAddr.text = selectedDevice.deviceAddressMAC
        textInputMacAddr.focus = false
    }
    onAboutToHide: {
        textInputMacAddr.focus = false
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.5; to: 1.0; duration: 133; } }
    //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: ThemeEngine.isLight ? 0.24 : 0.48
    }

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: singleColumn ? 0 : Theme.componentBorderWidth
        radius: singleColumn ? 0 : Theme.componentRadius

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.componentBorderWidth

            visible: singleColumn
            color: Theme.colorSeparator
        }

        layer.enabled: !singleColumn
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            blurMax: 48
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#aa000000" : "#cc000000"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Column {
            id: columnContent
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginXL

            ////////

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Set sensor MAC address.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("The MAC address of the sensor must be set in order for the history synchronization to work.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Sorry for the inconvenience.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }

                TextFieldThemed {
                    id: textInputMacAddr
                    anchors.left: parent.left
                    anchors.right: parent.right

                    font.pixelSize: 18
                    font.bold: false
                    color: Theme.colorText

                    overwriteMode: true
                    maximumLength: 17
                    //inputMask: "HH:HH:HH:HH:HH:HH"
                    //validator: RegularExpressionValidator { regularExpression: /[0-9A-F]+/ }
                    inputMethodHints: Qt.ImhNoPredictiveText

                    placeholderText: "AA:BB:CC:DD:EE:FF"
                }
/*
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Theme.componentHeight

                    radius: Theme.componentRadius
                    color: Theme.colorComponentBackground

                    border.width: 2
                    border.color: textInputMacAddr.activeFocus ? Theme.colorPrimary : Theme.colorComponentBorder

                    TextInput {
                        id: textInputMacAddr
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 4

                        font.pixelSize: 18
                        font.bold: false
                        color: Theme.colorHighContrast

                        inputMask: "HH:HH:HH:HH:HH:HH"
                        validator: RegularExpressionValidator { regularExpression: /[0-9A-F]+/ }

                        onEditingFinished: {
                            focus = false
                        }
                    }
                }
*/
            }

            ////////

            Flow {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMargin

                property int btnSize: singleColumn ? width : ((width-spacing) / 2)

                ButtonClear {
                    width: parent.btnSize
                    color: Theme.colorGrey

                    text: qsTr("Cancel")
                    onClicked: {
                        textInputMacAddr.focus = false
                        popupMacAddress.close()
                    }
                }

                ButtonFlat {
                    width: parent.btnSize
                    color: Theme.colorPrimary

                    text: qsTr("Set MAC")
                    onClicked: {
                        if (selectedDevice) {
                             selectedDevice.deviceAddressMAC = textInputMacAddr.text
                        }
                        popupMacAddress.close()
                    }
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
