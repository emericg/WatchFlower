import QtCore
import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Dialogs

import ComponentLibrary
import WatchFlower

Popup {
    id: popupRestoreBackup

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
    closePolicy: (mode === "working") ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
    parent: Overlay.overlay

    property string mode: "summary" // "summary", "working" or "error"
    property var backupInfos: ({})
    property string errorText: ""

    ////////////////////////////////////////////////////////////////////////////

    function openFile() {
        // Desktop: start in Documents (Qt's own dialog otherwise opens in the working directory)
        if (isDesktop) fileDialog.currentFolder = StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileDialog.open()
    }

    function loadFile(fileUrl) {
        backupInfos = DatabaseManager.readBackup(fileUrl)

        if (backupInfos.ok) {
            checkData.checked = (backupInfos.devices > 0)
            checkSettings.checked = backupInfos.hasSettings
            mode = "summary"
        } else {
            errorText = errorMessage(backupInfos.error)
            mode = "error"
        }

        open()
    }

    function errorMessage(error) {
        if (error === "unreadable") return qsTr("Could not read this file.")
        if (error === "newer") return qsTr("This backup was made by a newer version of WatchFlower. Update the app and try again.")
        if (error === "older") return qsTr("This backup is from an older version of WatchFlower and can't be restored.")
        return qsTr("This is not a WatchFlower backup.")
    }

    function formatDate(date) {
        return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
    }

    function restore() {
        var restoreData = checkData.checked
        var restoreSettings = checkSettings.checked
        var restored = DatabaseManager.restoreDatabase(restoreData, restoreSettings)

        // Devices were reloaded (restored or rolled back): listen for them again, like when the app becomes active
        if (restoreData) deviceManager.refreshDevices_listen()

        if (restored) {
            if (restoreSettings) {
                // These are not applied automatically when the settings change
                utilsLanguage.loadLanguage(SettingsManager.appLanguage)
                Theme.loadTheme(SettingsManager.appTheme) // also picks up a restored appThemeAuto
                if (sunAndMoon && SettingsManager.sunandmoon) {
                    sunAndMoon.set(SettingsManager.latitude, SettingsManager.longitude, new Date())
                }
                if (SettingsManager.orderBy === "location") deviceManager.orderby_location()
                else if (SettingsManager.orderBy === "plant") deviceManager.orderby_plant()
                else if (SettingsManager.orderBy === "waterlevel") deviceManager.orderby_waterlevel()
                else if (SettingsManager.orderBy === "model") deviceManager.orderby_model()
                else if (SettingsManager.orderBy === "insideoutside") deviceManager.orderby_insideoutside()
            }

            close()
            if (restoreData) screenDeviceList.loadScreen() // a settings-only restore stays where it was started
        } else {
            errorText = qsTr("Restore failed. Your current data was not changed.")
            mode = "error"
        }
    }

    // Cancel, Close, Esc or press outside: delete the staged copy (a no-op after a completed restore)
    onClosed: DatabaseManager.discardBackup()

    ////////////////////////////////////////////////////////////////////////////

    FileDialog {
        id: fileDialog
        title: qsTr("Open backup")
        parentWindow: appWindow // declared inside a Popup, which is not an Item
        fileMode: FileDialog.OpenFile
        // No filter on mobile: Android turns filters into MIME types, and backups often come back as generic files
        nameFilters: isDesktop ? [qsTr("WatchFlower backup (*.db)"), qsTr("All files (*)")] : []
        onAccepted: popupRestoreBackup.loadFile(selectedFile)
    }

    Timer {
        id: restoreTimer
        interval: 100 // let the "Restoring…" state be drawn first, as the restore blocks the UI
        repeat: false
        onTriggered: popupRestoreBackup.restore()
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.5; to: 1.0; duration: 133; } }

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

                text: (popupRestoreBackup.mode === "error") ? popupRestoreBackup.errorText : qsTr("Restore this backup?")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            ////////

            Column { // backup summary
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMargin / 2

                visible: (popupRestoreBackup.mode !== "error")

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: (popupRestoreBackup.backupInfos.createdAt !== undefined)
                    text: visible ? qsTr("Created on %1 with WatchFlower %2")
                                        .arg(popupRestoreBackup.formatDate(popupRestoreBackup.backupInfos.createdAt))
                                        .arg(popupRestoreBackup.backupInfos.appVersion) : ""
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("%n sensor(s)", "", popupRestoreBackup.backupInfos.devices || 0)
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: (popupRestoreBackup.backupInfos.firstDate !== undefined &&
                              popupRestoreBackup.backupInfos.lastDate !== undefined)
                    text: visible ? qsTr("History from %1 to %2")
                                        .arg(popupRestoreBackup.formatDate(popupRestoreBackup.backupInfos.firstDate))
                                        .arg(popupRestoreBackup.formatDate(popupRestoreBackup.backupInfos.lastDate)) : ""
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
            }

            ////////

            Column { // what to restore
                anchors.left: parent.left
                anchors.right: parent.right

                visible: (popupRestoreBackup.mode !== "error")

                CheckBoxThemed {
                    id: checkData
                    text: qsTr("Sensors, plants and history")
                    enabled: (popupRestoreBackup.mode === "summary" && popupRestoreBackup.backupInfos.devices > 0)
                }
                CheckBoxThemed {
                    id: checkSettings
                    text: qsTr("App settings")
                    enabled: (popupRestoreBackup.mode === "summary" && popupRestoreBackup.backupInfos.hasSettings === true)
                }
            }

            ////////

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                visible: (popupRestoreBackup.mode === "summary" && checkData.checked)
                text: qsTr("Your current sensors, plants and history will be replaced.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorWarning
                wrapMode: Text.WordWrap
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                visible: (popupRestoreBackup.mode === "working")
                text: qsTr("Restoring…")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
                wrapMode: Text.WordWrap
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

                    visible: (popupRestoreBackup.mode !== "error")
                    enabled: (popupRestoreBackup.mode === "summary")

                    text: qsTr("Cancel")
                    onClicked: popupRestoreBackup.close()
                }

                ButtonFlat {
                    width: parent.btnSize
                    color: Theme.colorWarning

                    visible: (popupRestoreBackup.mode !== "error")
                    enabled: (popupRestoreBackup.mode === "summary" && (checkData.checked || checkSettings.checked))

                    text: qsTr("Restore")
                    onClicked: {
                        popupRestoreBackup.mode = "working"
                        restoreTimer.start()
                    }
                }

                ButtonFlat {
                    width: parent.width // alone in the error state
                    color: Theme.colorPrimary

                    visible: (popupRestoreBackup.mode === "error")

                    text: qsTr("Close")
                    onClicked: popupRestoreBackup.close()
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
