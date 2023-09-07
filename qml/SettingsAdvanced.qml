import QtQuick
import QtQuick.Controls

import ThemeEngine
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Loader {
    id: settingsAdvanced

    property string entryPoint: "About"

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        settingsAdvanced.active = true
        settingsAdvanced.item.loadScreen()

        // change screen
        appContent.state = "SettingsAdvanced"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        loadScreen()
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
            screenAbout.loadScreen()
        }

        ////////////////

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: contentColumn.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: Theme.componentMargin
                bottomPadding: Theme.componentMargin
                spacing: Theme.componentMargin

                ////////////////

                ListTitle {
                    text: "App info"
                    icon: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin
                    spacing: Theme.componentMargin / 2

                    Text {
                        color: Theme.colorSubText
                        text: "app name: %1".arg(utilsApp.appName())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "app version: %1".arg(utilsApp.appVersion())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "build mode: %1".arg(utilsApp.appBuildModeFull())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "build date: %1".arg(utilsApp.appBuildDateTime())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Qt version: %1".arg(utilsApp.qtVersion())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Qt Connectivity patched? %1".arg(qtConnectivityPatched ? "TRUE" : "FALSE")
                        font.pixelSize: Theme.fontSizeContent
                    }
                }

                ////////////////

                ListTitle {
                    text: "Local settings"
                    icon: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin
                    spacing: Theme.componentMargin / 2

                    TextFieldThemed {
                        anchors.left: parent.left
                        anchors.right: parent.right

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

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Theme.componentMargin / 2

                        ButtonWireframe {
                            anchors.verticalCenter: parent.verticalCenter
                            fullColor: true

                            text: "save"
                            onClicked: settingsManager.saveSettings()
                        }

                        ButtonWireframe {
                            anchors.verticalCenter: parent.verticalCenter
                            fullColor: true
                            primaryColor: Theme.colorWarning

                            text: "restore"
                            //onPressAndHold: settingsManager.restoreSettings()
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: "Local database"
                    icon: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin
                    spacing: Theme.componentMargin / 2

                    TextFieldThemed {
                        anchors.left: parent.left
                        anchors.right: parent.right

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

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Theme.componentMargin / 2

                        ButtonWireframe {
                            fullColor: true

                            text: "save"
                            onClicked: mainDatabase.saveDatabase()
                        }

                        ButtonWireframe {
                            fullColor: true
                            primaryColor: Theme.colorWarning

                            text: "restore"
                            //onPressAndHold: mainDatabase.restoreDatabase()
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: "Remote database"
                    icon: "qrc:/assets/icons_material/baseline-storage-24px.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin
                    spacing: Theme.componentMargin / 2

                    SwitchThemed {
                        id: switch_worker

                        text: "Enable MySQL database support"
                        //checked: settingsManager.mysql
                        //onClicked: settingsManager.mysql = checked
                    }
                }

                ////////////////

                ListTitle {
                    text: "Logs"
                    icon: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + Theme.componentMargin
                    spacing: Theme.componentMargin

                    SwitchThemed {
                        id: switch_logs

                        text: "Enable logging"
                        //checked: settingsManager.logging
                        //onClicked: settingsManager.logging = checked
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Theme.componentMargin / 2

                        ButtonWireframe {
                            fullColor: true
                            text: "show logs"

                            onPressed: {
                                logFrame.visible
                            }
                        }

                        ButtonWireframe {
                            fullColor: true
                            primaryColor: Theme.colorWarning

                            text: "reset log"
                            onPressAndHold: {
                                utilsLog.clearLog()
                                logArea.text = utilsLog.getLog()
                            }
                        }
                    }

                    Rectangle {
                        id: logFrame
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 640
                        anchors.margins: 12

                        visible: false
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
                    }
                }

                ////////////////
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
