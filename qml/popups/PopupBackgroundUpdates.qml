import QtQuick
import QtQuick.Effects
import QtQuick.Controls

import ComponentLibrary

Popup {
    id: popupBackgroundUpdates

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

    property bool locPerm: false

    onAboutToShow: {
         locPerm = utilsApp.checkMobileBackgroundLocationPermission()
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.5; to: 1.0; duration: 133; } }
    //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.24 : 0.48
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

                text: qsTr("About background updates")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginXL

                visible: !popupBackgroundUpdates.locPerm

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 8

                    IconSvg {
                        width: 64
                        height: 64
                        anchors.horizontalCenter: parent.horizontalCenter

                        source: "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"
                        color: Theme.colorText
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("To use the background update feature, the <b>background location permission</b> is required, otherwise WatchFlower can't scan for Bluetooth Low Energy sensors and can't update data when the app is closed.")
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }
                }

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Theme.componentMargin

                    property int btnSize: singleColumn ? width : ((width-spacing*2) / 2)

                    ButtonFlat {
                        width: parent.btnSize
                        color: Theme.colorSecondary

                        text: qsTr("About Bluetooth permissions")
                        source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
                        sourceSize: 20

                        onClicked: {
                            if (utilsApp.getAndroidSdkVersion() >= 12)
                                Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android12-or-higher")
                            else
                                Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower")
                        }
                    }

                    ButtonFlat {
                        width: (parent.btnSize / 2 - 8)
                        color: Theme.colorGrey

                        text: qsTr("Cancel")
                        source: "qrc:/IconLibrary/material-symbols/close.svg"

                        onClicked: {
                            popupBackgroundUpdates.close()
                        }
                    }

                    ButtonFlat {
                        width: (parent.btnSize / 2 - 8)
                        color: Theme.colorSuccess

                        text: qsTr("Enable")
                        source: "qrc:/IconLibrary/material-symbols/check.svg"

                        onClicked: {
                            utilsApp.getMobileBackgroundLocationPermission()
                            popupBackgroundUpdates.locPerm = true
                        }
                    }
                }
            }

            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginXL

                visible: popupBackgroundUpdates.locPerm

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 8

                    IconSvg {
                        width: 64
                        height: 64
                        anchors.horizontalCenter: parent.horizontalCenter

                        source: "qrc:/IconLibrary/material-icons/duotone/battery_alert.svg"
                        color: Theme.colorText
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("Your phone will do its best to prevent this application from running in the background.") + "<br>" +
                              qsTr("Some settings need to be switched <b>manually</b> from the Android <b>application info panel</b>:")
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("- autolaunch will need to be <b>enabled</b>") + "<br>" +
                              qsTr("- battery saving feature(s) will need to be <b>disabled</b>")
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                        wrapMode: Text.WordWrap
                    }
                }

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Theme.componentMargin

                    property int btnSize: singleColumn ? width : ((width-spacing*2) / 2)

                    ButtonFlat {
                        width: parent.btnSize
                        color: Theme.colorSecondary

                        text: qsTr("About battery savers")
                        source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
                        sourceSize: 20

                        onClicked: {
                            Qt.openUrlExternally("https://dontkillmyapp.com/")
                        }
                    }

                    ButtonFlat {
                        width: parent.btnSize
                        color: Theme.colorPrimary

                        text: qsTr("Application info panel")
                        source: "qrc:/IconLibrary/material-icons/duotone/tune.svg"
                        sourceSize: 20

                        onClicked: {
                            utilsApp.openAndroidAppInfo("com.emeric.watchflower")
                        }
                    }

                    ButtonFlat {
                        width: parent.btnSize
                        color: Theme.colorGreen
                        layoutDirection: Qt.RightToLeft

                        text: qsTr("I understand")
                        source: "qrc:/IconLibrary/material-symbols/check.svg"

                        onClicked: {
                            popupBackgroundUpdates.close()
                        }
                    }
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
