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

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Column {
            id: columnContent
            width: parent.width
            spacing: 8

            Text {
                width: parent.width

                text: qsTr("About background updates.")
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

                    text: qsTr("Android will prevent this application from running in the background.<br>
                                Some settings needs to be switched <b>manually</b> from the <b>application info panel</b>:")
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

                property var btnSize: singleColumn ? width : ((width-spacing*2) / 2)
                spacing: 16

                ButtonWireframeIconCentered {
                    width: parent.btnSize

                    fullColor: true
                    primaryColor: Theme.colorSubText

                    text: qsTr("Unofficial information")
                    source: "qrc:/assets/icons_material/outline-info-24px.svg"
                    sourceSize: 20

                    onClicked: {
                        Qt.openUrlExternally("https://dontkillmyapp.com/")
                        popupBackgroundData.confirmed()
                        popupBackgroundData.close()
                    }
                }

                ButtonWireframeIconCentered {
                    width: parent.btnSize

                    fullColor: true
                    primaryColor: Theme.colorPrimary

                    text: qsTr("Application info panel")
                    source: "qrc:/assets/icons_material/duotone-tune-24px.svg"
                    sourceSize: 20

                    onClicked: utilsApp.openAndroidAppInfo("com.emeric.watchflower")
                }

                ButtonWireframeIconCentered {
                    width: parent.btnSize

                    fullColor: true
                    primaryColor: Theme.colorGreen
                    layoutDirection: Qt.RightToLeft

                    text: qsTr("I understand")
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
