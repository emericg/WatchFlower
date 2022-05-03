import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Popup {
    id: popupBackgroundData
    x: (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height) : ((appWindow.height / 2) - (height / 2) /*- (appHeader.height)*/)

    width: singleColumn ? parent.width : 640
    height: columnContent.height + padding*2
    padding: singleColumn ? 20 : 24

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    signal confirmed()

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

    contentItem: Item {
        Column {
            id: columnContent
            width: parent.width
            spacing: 20

            Text {
                width: parent.width

                text: qsTr("You are about to enable background sensor refresh.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Column {
                width: parent.width
                spacing: 8

                Text {
                    width: parent.width

                    text: qsTr("Several Android features will prevent this application from running in the background and need <b>manual intervention</b> from you:")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width

                    text: qsTr("- autolaunch will need to be <b>enabled</b><br>" +
                               "- background location will need to be <b>enabled</b><br>" +
                               "- battery saving feature(s) will need to be <b>disabled</b><br>")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
            }

            Flow {
                id: flowContent
                width: parent.width
                height: singleColumn ? 80+24 : 40

                property var btnSize: singleColumn ? width : ((width-spacing*2) / 2)
                spacing: 16

                ButtonWireframeIconCentered {
                    width: parent.btnSize

                    text: qsTr("Device specific information")
                    primaryColor: Theme.colorSubText
                    fullColor: true
                    layoutDirection: Qt.RightToLeft
                    source: "qrc:/assets/icons_material/duotone-launch-24px.svg"

                    onClicked: {
                        Qt.openUrlExternally("https://dontkillmyapp.com/")
                        popupBackgroundData.confirmed()
                        popupBackgroundData.close()
                    }
                }
                ButtonWireframeIconCentered {
                    width: parent.btnSize

                    text: qsTr("I understand")
                    primaryColor: Theme.colorGreen
                    fullColor: true
                    layoutDirection: Qt.RightToLeft
                    source: "qrc:/assets/icons_material/baseline-check-24px.svg"

                    onClicked: {
                        popupBackgroundData.confirmed()
                        popupBackgroundData.close()
                    }
                }
            }
        }
    }
}
