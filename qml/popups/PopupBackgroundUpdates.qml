import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Popup {
    id: popupBackgroundUpdates
    x: (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height - appHeader.height) : ((appWindow.height / 2) - (height / 2))

    width: singleColumn ? parent.width : 640
    height: columnContent.height + padding*2
    padding: singleColumn ? 20 : 24

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property bool locPerm: false

    onAboutToShow: {
         locPerm = utilsApp.checkMobileBackgroundLocationPermission()
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
            id: columnContent
            width: parent.width
            spacing: 16

            Text {
                width: parent.width

                text: qsTr("About background updates")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            ////////

            Column {
                width: parent.width
                spacing: 24

                visible: !popupBackgroundUpdates.locPerm

                Column {
                    width: parent.width
                    spacing: 8

                    IconSvg {
                        width: 64
                        height: 64
                        anchors.horizontalCenter: parent.horizontalCenter

                        source: "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                        color: Theme.colorText
                    }

                    Text {
                        width: parent.width

                        text: qsTr("To use the background update feature, the <b>background location permission</b> is required, otherwise WatchFlower can't scan for Bluetooth Low Energy sensors and can't update data when the app is closed.")
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }
                }

                Flow {
                    width: parent.width

                    property var btnSize: singleColumn ? width : ((width-spacing*2) / 2)
                    spacing: 16

                    ButtonWireframeIconCentered {
                        width: parent.btnSize

                        fullColor: true
                        primaryColor: Theme.colorSecondary

                        text: qsTr("About Bluetooth permissions")
                        source: "qrc:/assets/icons_material/baseline-info-24px.svg"
                        sourceSize: 20

                        onClicked: {
                            Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower")
                        }
                    }

                    ButtonWireframeIconCentered {
                        width: (parent.btnSize / 2 - 8)

                        fullColor: true
                        primaryColor: Theme.colorSubText

                        text: qsTr("Cancel")
                        source: "qrc:/assets/icons_material/baseline-close-24px.svg"

                        onClicked: {
                            popupBackgroundUpdates.close()
                        }
                    }

                    ButtonWireframeIconCentered {
                        width: (parent.btnSize / 2 - 8)

                        fullColor: true
                        primaryColor: Theme.colorGreen

                        text: qsTr("Enable")
                        source: "qrc:/assets/icons_material/baseline-check-24px.svg"

                        onClicked: {
                            utilsApp.getMobileBackgroundLocationPermission()
                            popupBackgroundUpdates.locPerm = true
                        }
                    }
                }
            }

            ////////

            Column {
                width: parent.width
                spacing: 24

                visible: popupBackgroundUpdates.locPerm

                Column {
                    width: parent.width
                    spacing: 8

                    IconSvg {
                        width: 64
                        height: 64
                        anchors.horizontalCenter: parent.horizontalCenter

                        source: "qrc:/assets/icons_material/baseline-battery_alert-24px.svg"
                        color: Theme.colorText
                    }

                    Text {
                        width: parent.width
                        text: qsTr("Your phone will do its best to prevent this application from running in the background.") + "<br>" +
                              qsTr("Some settings need to be switched <b>manually</b> from the Android <b>application info panel</b>:")
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        width: parent.width
                        text: qsTr("- autolaunch will need to be <b>enabled</b>") + "<br>" +
                              qsTr("- battery saving feature(s) will need to be <b>disabled</b>")
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }
                }

                Flow {
                    width: parent.width

                    property var btnSize: singleColumn ? width : ((width-spacing*2) / 2)
                    spacing: 16

                    ButtonWireframeIconCentered {
                        width: parent.btnSize

                        fullColor: true
                        primaryColor: Theme.colorSecondary

                        text: qsTr("About battery savers")
                        source: "qrc:/assets/icons_material/baseline-info-24px.svg"
                        sourceSize: 20

                        onClicked: {
                            Qt.openUrlExternally("https://dontkillmyapp.com/")
                        }
                    }

                    ButtonWireframeIconCentered {
                        width: parent.btnSize

                        fullColor: true
                        primaryColor: Theme.colorPrimary

                        text: qsTr("Application info panel")
                        source: "qrc:/assets/icons_material/duotone-tune-24px.svg"
                        sourceSize: 20

                        onClicked: {
                            utilsApp.openAndroidAppInfo("com.emeric.watchflower")
                        }
                    }

                    ButtonWireframeIconCentered {
                        width: parent.btnSize

                        fullColor: true
                        primaryColor: Theme.colorGreen
                        layoutDirection: Qt.RightToLeft

                        text: qsTr("I understand")
                        source: "qrc:/assets/icons_material/baseline-check-24px.svg"

                        onClicked: {
                            popupBackgroundUpdates.close()
                        }
                    }
                }
            }

            ////////
        }
    }
}
