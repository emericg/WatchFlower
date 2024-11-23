import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary

Popup {
    id: popupBlacklistDevice

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

    property string deviceName
    property string deviceAddress
    property bool deviceIsBlacklisted: false

    onAboutToShow: {
        deviceIsBlacklisted = deviceManager.isBleDeviceBlacklisted(deviceAddress)
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

                text: !deviceIsBlacklisted ?
                          qsTr("Are you sure you want to blacklist the selected sensor?") :
                          qsTr("Are you sure you want to whitelist the selected sensor?")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 36
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: deviceNameTxt.contentWidth + 24
                        Layout.preferredHeight: 36
                        color: Theme.colorForeground

                        Text {
                            id: deviceNameTxt
                            anchors.centerIn: parent

                            text: deviceName
                            textFormat: Text.PlainText
                            font.bold: false
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                            wrapMode: Text.WordWrap
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: Theme.colorForeground

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            text: deviceAddress
                            textFormat: Text.PlainText
                            font.bold: false
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                            wrapMode: Text.WordWrap
                        }
                    }
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Blacklisting a sensor will prevent it from being scanned by the application. You can un-blacklist the sensor at any time.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("If the sensor is already handled by the application, nothing will happen unless you delete it from the sensor list.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
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

                    onClicked: popupBlacklistDevice.close()
                }

                ButtonFlat {
                    width: parent.btnSize

                    text: !deviceIsBlacklisted ? qsTr("Blacklist") : qsTr("Whitelist")
                    color: !deviceIsBlacklisted ? Theme.colorRed : Theme.colorGreen

                    onClicked: {
                        if (deviceIsBlacklisted)
                            deviceManager.whitelistBleDevice(deviceAddress)
                        else
                            deviceManager.blacklistBleDevice(deviceAddress)

                        popupBlacklistDevice.close()
                    }
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
