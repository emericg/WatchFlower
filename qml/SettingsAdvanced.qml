import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Loader {
    id: settingsAdvanced

    function loadScreen() {
        // load screen
        settingsAdvanced.active = true
        settingsAdvanced.item.loadScreen()

        // change screen
        appContent.state = "SettingsAdvanced"
    }

    function backAction() {
        if (settingsAdvanced.status === Loader.Ready)
            settingsAdvanced.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: false

    sourceComponent: Item {
        id: itemSettingsAdvanced
        implicitWidth: 480
        implicitHeight: 720

        focus: parent.focus

        function loadScreen() {
            //console.log("SettingsAdvanced // loadScreen()")
            logArea.text = utilsLog.getLog()
        }

        function backAction() {
            appContent.state = "DeviceList"
        }

        ////////////////

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: column1.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: column1
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: 12
                bottomPadding: 12
                spacing: 8

                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: "Settings"
                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                ////////////////

                Item {
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 12
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + 12

                    TextFieldThemed {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        text: settingsManager.getSettingsDirectory()
                        readOnly: true

                        ButtonWireframe {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            visible: isDesktop
                            text: "open"
                            onClicked: utilsApp.openWith(parent.text)
                        }
                    }
                }

                Row {
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 12
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight
                    spacing: 8

                    ButtonWireframe {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "save"
                        onClicked: settingsManager.saveSettings()
                    }

                    ButtonWireframe {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "restore"
                        //onPressAndHold: settingsManager.restoreSettings()
                    }
                }

                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: "Database"
                    source: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                }

                ////////////////

                Item {
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 12
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + 12

                    TextFieldThemed {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        text: mainDatabase.getDatabaseDirectory()
                        readOnly: true

                        ButtonWireframe {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            visible: isDesktop
                            text: "open"
                            onClicked: utilsApp.openWith(parent.text)
                        }
                    }
                }

                Row {
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 12
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + 12
                    spacing: 8

                    ButtonWireframe {
                        anchors.verticalCenter: parent.verticalCenter

                        text: "save"
                        onClicked: mainDatabase.saveDatabase()
                    }

                    ButtonWireframe {
                        anchors.verticalCenter: parent.verticalCenter

                        text: "restore"
                        //onPressAndHold: mainDatabase.restoreDatabase()
                    }
                }

                Item {
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + 12
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + 12

                    SwitchThemedDesktop {
                        id: switch_worker
                        anchors.verticalCenter: parent.verticalCenter

                        text: "Enable MySQL database support"
                        //checked: settingsManager.mysql
                        //onClicked: settingsManager.mysql = checked
                    }
                }

                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: "Log"
                    source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                }

                ////////////////

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 640
                    anchors.margins: 12

                    color: Theme.colorBackground
                    border.width: 1
                    border.color: Theme.colorSeparator

                    ScrollView {
                        anchors.fill: parent
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        TextArea {
                            id: logArea
                            anchors.fill: parent
                            anchors.margins: 6

                            readOnly: true
                            selectByMouse: false
                            color: Theme.colorSubText
                            textFormat: Text.PlainText
                            font.pixelSize: isDesktop ? 12 : 10
                        }
                    }

                    ButtonWireframe {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 8

                        fullColor: true
                        text: "reset log"
                        onPressAndHold: {
                            utilsLog.clearLog()
                            logArea.text = utilsLog.getLog()
                        }
                    }
                }

                ////////////////
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
