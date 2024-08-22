import QtQuick
import QtQuick.Controls

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

Loader {
    id: settingsAdvanced
    anchors.fill: parent

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
            //logArea.text = utilsLog.getLog()
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
                spacing: Theme.componentMarginL

                ////////////////

                ListTitle {
                    text: "App info"
                    source: "qrc:/assets/icons/material-symbols/settings.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin + 8
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin + 8
                    spacing: Theme.componentMargin / 2

                    Text {
                        color: Theme.colorSubText
                        text: "app name: %1".arg(utilsApp.appName())
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "app version: %1".arg(utilsApp.appVersion())
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "build mode: %1".arg(utilsApp.appBuildModeFull())
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "build architecture: %1".arg(utilsApp.qtArchitecture())
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "build date: %1".arg(utilsApp.appBuildDateTime())
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Qt version: %1".arg(utilsApp.qtVersion())
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Qt Connectivity patched: %1".arg(qtConnectivityPatched ? "TRUE" : "FALSE")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
/*
                    Text {
                        color: Theme.colorSubText
                        text: "OS name: %1".arg(utilsSysInfo.os_name)
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "OS version: %1".arg(utilsSysInfo.os_version)
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                    }
*/
                }

                ////////////////

                ListTitle {
                    text: "Remote database"
                    source: "qrc:/assets/icons/material-symbols/storage.svg"

                    visible: isDesktop
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin + 8
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin + 8
                    spacing: Theme.componentMargin / 2

                    visible: isDesktop

                    SwitchThemedDesktop {
                        id: switch_mysql

                        text: "Enable MySQL database support"
                        checked: settingsManager.mysql
                        onClicked: settingsManager.mysql = checked
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.right: parent.right
                        anchors.rightMargin: 4

                        text: qsTr("Connects to a remote MySQL compatible database, instead of the embedded database. Allows multiple instances of the application to share data. Database setup is at your own charge.")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContentSmall
                    }
                }

                ////////

                Loader {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin + 8
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin + 8

                    active: isDesktop && settingsManager.mysql
                    asynchronous: true
                    sourceComponent: dbSettingsScalable
                }

                ////////////////

                ListTitle {
                    text: "Local database"
                    source: "qrc:/assets/icons/material-symbols/storage.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin + 8
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin + 8
                    spacing: Theme.componentMargin / 2

                    TextFieldThemed {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: mainDatabase.getDatabaseDirectory()
                        readOnly: true

                        ButtonFlat {
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

                        enabled: false // isDesktop

                        ButtonFlat {
                            text: "save"
                            onClicked: mainDatabase.saveDatabase()
                        }

                        ButtonFlat {
                            color: Theme.colorWarning

                            text: "restore"
                            //onPressAndHold: mainDatabase.restoreDatabase()
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: "Local settings"
                    source: "qrc:/assets/icons/material-icons/duotone/tune.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin + 8
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin + 8
                    spacing: Theme.componentMargin / 2

                    TextFieldThemed {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: settingsManager.getSettingsDirectory()
                        readOnly: true

                        ButtonFlat {
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

                        enabled: false // isDesktop

                        ButtonFlat {
                            anchors.verticalCenter: parent.verticalCenter

                            text: "save"
                            onClicked: settingsManager.saveSettings()
                        }

                        ButtonFlat {
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.colorWarning

                            text: "restore"
                            //onPressAndHold: settingsManager.restoreSettings()
                        }
                    }
                }

                ////////////////
/*
                ListTitle {
                    text: "Logs"
                    source: "qrc:/assets/icons/material-icons/duotone/edit.svg"
                }

                ////////////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin + 8
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin + 8
                    spacing: Theme.componentMargin

                    SwitchThemedDesktop {
                        id: switch_logs

                        text: "Enable logging"
                        //checked: settingsManager.logging
                        //onClicked: settingsManager.logging = checked
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Theme.componentMargin / 2

                        ButtonFlat {
                            text: "show logs"

                            onPressed: {
                                logFrame.visible
                            }
                        }

                        ButtonFlat {
                            color: Theme.colorWarning

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
*/
                ////////////////
            }
        }

        ////////////////

        Component {
            id: dbSettingsScalable

            Grid {
                anchors.left: parent.left
                anchors.right: parent.right

                rows: 4
                columns: singleColumn ? 1 : 2
                spacing: 12

                property int sz: singleColumn ? width : Math.min((width / 2), 512) - 4

                TextFieldThemed {
                    id: tf_database_host
                    width: parent.sz
                    height: 36

                    placeholderText: qsTr("Host")
                    text: settingsManager.mysqlHost
                    onEditingFinished: settingsManager.mysqlHost = text
                    selectByMouse: true

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons/material-symbols/storage.svg"
                    }
                }

                TextFieldThemed {
                    id: tf_database_port
                    width: parent.sz
                    height: 36

                    placeholderText: qsTr("Port")
                    text: settingsManager.mysqlPort
                    onEditingFinished: settingsManager.mysqlPort = parseInt(text, 10)
                    validator: IntValidator { bottom: 1; top: 65535; }
                    selectByMouse: true

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons/material-symbols/pin.svg"
                    }
                }

                TextFieldThemed {
                    id: tf_database_user
                    width: parent.sz
                    height: 36

                    placeholderText: qsTr("User")
                    text: settingsManager.mysqlUser
                    onEditingFinished: settingsManager.mysqlUser = text
                    selectByMouse: true

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons/material-icons/duotone/manage_accounts.svg"
                    }
                }

                TextFieldThemed {
                    id: tf_database_pwd
                    width: parent.sz
                    height: 36

                    placeholderText: qsTr("Password")
                    text: settingsManager.mysqlPassword
                    onEditingFinished: settingsManager.mysqlPassword = text
                    selectByMouse: true
                    echoMode: TextInput.PasswordEchoOnEdit

                    IconSvg {
                        width: 20; height: 20;
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: "qrc:/assets/icons/material-symbols/password.svg"
                    }
                }
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
