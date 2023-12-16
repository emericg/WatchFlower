import QtQuick
import QtQuick.Controls

import ThemeEngine

Popup {
    id: popupMacAddress

    x: singleColumn ? 0 : (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height)
                    : ((appWindow.height / 2) - (height / 2))

    width: singleColumn ? parent.width : 640
    height: contentColumn.height + padding*2 + screenPaddingNavbar + screenPaddingBottom
    padding: Theme.componentMarginXL

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    ////////////////////////////////////////////////////////////////////////////

    signal confirmed()

    onAboutToShow: {
        textInputMacAddr.text = selectedDevice.deviceAddressMAC
        textInputMacAddr.focus = false
    }
    onAboutToHide: {
        textInputMacAddr.focus = false
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: singleColumn ? 0 : Theme.componentBorderWidth
        radius: singleColumn ? 0 : Theme.componentRadius

        Rectangle {
            width: parent.width
            height: Theme.componentBorderWidth
            visible: singleColumn
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.componentMarginXL

            ////////

            Text {
                width: parent.width

                text: qsTr("Set sensor MAC address.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            ////////

            Column {
                width: parent.width
                spacing: 8

                Text {
                    width: parent.width

                    text: qsTr("The MAC address of the sensor must be set in order for the history synchronization to work.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width

                    text: qsTr("Sorry for the inconvenience.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }

                TextFieldThemed {
                    id: textInputMacAddr
                    width: parent.width

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
                    width: parent.width
                    height: Theme.componentHeight

                    radius: Theme.componentRadius
                    color: Theme.colorComponentBackground

                    border.width: 2
                    border.color: textInputMacAddr.activeFocus ? Theme.colorPrimary : Theme.colorComponentBorder

                    TextInput {
                        id: textInputMacAddr
                        width: parent.width
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
                width: parent.width
                spacing: Theme.componentMargin

                property var btnSize: singleColumn ? width : ((width-spacing) / 2)

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Cancel")
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground

                    onClicked: {
                        textInputMacAddr.focus = false
                        popupMacAddress.close()
                    }
                }

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Set MAC")
                    primaryColor: Theme.colorPrimary
                    fullColor: true

                    onClicked: {
                        if (selectedDevice) {
                             selectedDevice.deviceAddressMAC = textInputMacAddr.text
                        }
                        textInputMacAddr.focus = false
                        popupMacAddress.confirmed()
                        popupMacAddress.close()
                    }
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
