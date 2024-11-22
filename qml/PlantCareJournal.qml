import QtQuick
import QtQuick.Controls

import ThemeEngine

import JournalUtils
import "qrc:/js/UtilsPlantJournal.js" as UtilsPlantJournal

Item {
    id: plantCareJournal

    // 1: single column (single column view)
    // 2: single column, with calendar unfolded (portrait tablet)
    // 3: wide mode (wide view)
    property int uiMode: (singleColumn) ? 1 : ((isTablet && screenOrientation === Qt.PortraitOrientation) ? 2 : 3)

    function load() {
        journalEntries.active = true
    }

    function backAction() {
        if (journalEditorLoader.status === Loader.Ready) {
            if (journalEditorLoader.item.isEditing()) {
                journalEditorLoader.item.stopEditing()
                return
            }
            if (journalEditorLoader.item.isEditorOpen()) {
                journalEditorLoader.item.closeEditor()
                return
            }
        }

        screenDeviceList.loadScreen()
    }

    ////////////////////////////////////////////////////////////////////////////

    ItemNoJournal {
        visible: !currentDevice.hasJournal
        enabled: !currentDevice.hasJournal
        onClicked: {
            journalEditorLoader.active = true
            journalEditorLoader.item.openEditor()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: journalEntries
        anchors.fill: parent

        active: false
        asynchronous: true

        sourceComponent: ListView {
            id: entriesView
            anchors.fill: parent
            anchors.margins: 16

            visible: currentDevice.hasJournal
            enabled: currentDevice.hasJournal

            topMargin: isPhone ? 8 : 12
            bottomMargin: isPhone ? 8 : 12
            spacing: 16

            property int entrySelected: -1

            function deselectEntries() {
                entrySelected = -1
            }

            onCountChanged: {
                deselectEntries()
                Qt.callLater(entriesView.positionViewAtEnd)
            }

            header: Item {
                height: 80
                anchors.left: parent.left
                anchors.right: parent.right

                RoundButtonIcon {
                    id: startPlantIcon
                    width: 40
                    height: 40
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: singleColumn ? 0 : 112

                    source: "qrc:/assets/gfx/icons/pot_flower-24px.svg"
                    iconColor: "white"
                    backgroundVisible: true
                    backgroundColor: Theme.colorGreen

                    Rectangle {
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 3
                        height: 40
                        z: -1
                        color: Theme.colorSeparator
                    }
                }

                Text {
                    anchors.left: startPlantIcon.right
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.verticalCenter: startPlantIcon.verticalCenter

                    text: {
                        if (currentDevice.plantNameDisplay.length)
                            qsTr("%1 tracked since %2").arg(currentDevice.plantNameDisplay).arg(currentDevice.plantStart.toLocaleString(Locale.ShortFormat))
                        else
                            qsTr("Plant tracked since %1").arg(currentDevice.plantStart.toLocaleString(Locale.ShortFormat))
                    }
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContentBig
                }
            }

            model: currentDevice.journalEntries
            delegate: JournalWidget {
                width: entriesView.width
            }

            footer: Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52
                z: 2

                RoundButtonIcon {
                    id: add
                    width: 40
                    height: 40
                    anchors.left: parent.left
                    anchors.leftMargin: singleColumn ? 0 : 112
                    anchors.bottom: parent.bottom

                    source: "qrc:/IconLibrary/material-symbols/add.svg"
                    iconColor: "white"
                    backgroundVisible: true
                    backgroundColor: Theme.colorPrimary

                    onClicked: {
                        journalEditorLoader.active = true
                        journalEditorLoader.item.openEditor()
                    }

                    ButtonFlat {
                        height: 36
                        anchors.left: parent.right
                        anchors.leftMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSecondary
                        text: qsTr("Add a new entry")

                        onClicked: {
                            entriesView.deselectEntries()
                            journalEditorLoader.active = true
                            journalEditorLoader.item.openEditor()
                        }
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: journalEditorLoader
        anchors.fill: parent

        active: false
        asynchronous: false

        sourceComponent: Item {

            function isEditorOpen() {
                return entryEditor.visible
            }
            function openEditor() {
                entryEditor.open()
            }
            function editEditor(eee) {
                entryEditor.edit(eee)
            }
            function closeEditor() {
                entryEditor.close()
            }

            function isEditing() {
                return entryComment.focus
            }
            function stopEditing() {
                entryComment.focus = false
            }

            Rectangle {
                id: entryEditor
                anchors.fill: parent

                visible: false
                color: Theme.colorBackground

                property var currentDateTime: new Date()

                property var entry: null
                property int entryType: JournalUtils.JOURNAL_WATER

                ////////////

                function open() {
                    currentDateTime = new Date() // to reset date
                    datePicker.openDate(currentDateTime)

                    entry = null
                    entryType = JournalUtils.JOURNAL_WATER
                    entryComment.text = ""

                    entryEditor.visible = true
                }

                function edit(eee) {
                    currentDateTime = eee.date
                    datePicker.openDate(currentDateTime)

                    entry = eee
                    entryType = eee.type
                    entryComment.text = eee.comment

                    entryEditor.visible = true
                }

                function close() {
                    entryComment.focus = false
                    entryEditor.visible = false
                }

                ////////////

                PopupDate {
                    id: popupDate
                    onUpdateDate: (newdate) => {
                        //console.log("onUpdateDate(" + newdate + ")")
                        entryEditor.currentDateTime = newdate
                    }
                }

                ////////////

                Grid {
                    id: rowrowrow
                    anchors.fill: parent
                    anchors.topMargin: Theme.componentMargin
                    anchors.leftMargin: Theme.componentMargin
                    anchors.rightMargin: Theme.componentMargin
                    anchors.bottomMargin: Theme.componentMargin
                    spacing: Theme.componentMargin

                    columns: (uiMode === 3) ? 2 : 1
                    rows: 2

                    Item {
                        width: (uiMode === 2) ? rowrowrow.width : ((rowrowrow.width * 0.4) - (rowrowrow.spacing / 2))
                        height: (uiMode === 2) ? 320 : rowrowrow.height
                        visible: (uiMode !== 1)

                        DatePicker {
                            id: datePicker
                            anchors.fill: parent

                            onUpdateDate: (newdate) => {
                                //console.log("onUpdateDate(" + newdate + ")")
                                entryEditor.currentDateTime = newdate
                            }
                        }
                    }

                    ////

                    Column {
                        width: (uiMode !== 3) ? parent.width : (rowrowrow.width * 0.6) - (rowrowrow.spacing / 2)
                        spacing: Theme.componentMargin

                        ButtonFlat {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: (uiMode === 1) ? 40 : 44

                            text: entryEditor.currentDateTime.toLocaleDateString(Qt.locale())
                            color: Theme.colorSecondary
                            onClicked: {
                                if (uiMode === 1)
                                    popupDate.openDate(entryEditor.currentDateTime)
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: colEntryType.height + 20

                            radius: Theme.componentRadius
                            color: Theme.colorForeground
                            border.width: (uiMode === 1) ? 0 : 2
                            border.color: Theme.colorSeparator

                            Grid {
                                id: colEntryType
                                anchors.centerIn: parent

                                spacing: (uiMode === 1) ? Theme.componentMargin : Theme.componentMarginL
                                columns: (uiMode === 1) ? 3 : 6
                                rows: (uiMode === 1) ? 2 : 1

                                Repeater {
                                    model: [JournalUtils.JOURNAL_WATER, JournalUtils.JOURNAL_FERTILIZE, JournalUtils.JOURNAL_PRUNE,
                                            JournalUtils.JOURNAL_ROTATE, JournalUtils.JOURNAL_MOVE, JournalUtils.JOURNAL_REPOT]

                                    Column {
                                        width: btn.width + 20
                                        spacing: 4

                                        RoundButtonIcon {
                                            id: btn
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 52
                                            height: 52

                                            source: UtilsPlantJournal.getJournalEntryIcon(modelData)
                                            iconColor: Theme.colorSubText
                                            backgroundVisible: true
                                            backgroundColor: Theme.colorBackground
                                            borderVisible: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            highlighted: (entryEditor.entryType === modelData)
                                            onClicked: entryEditor.entryType = modelData
                                        }
                                        Text {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: 16

                                            text: UtilsPlantJournal.getJournalEntryName(modelData)
                                            textFormat: Text.PlainText
                                            color: btn.highlighted ? Theme.colorPrimary : Theme.colorText

                                            fontSizeMode: Text.HorizontalFit
                                            font.pixelSize: Theme.fontSizeContentSmall
                                            minimumPixelSize: Theme.fontSizeContentVerySmall

                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }

                        TextAreaThemed {
                            id: entryComment
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: isPhone ? 128 : 160

                            colorBackground: Theme.colorBackground
                            placeholderText: qsTr("Add a comment")
                        }
                    }
                }

                ////////////////

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.componentMargin
                    spacing: Theme.componentMargin

                    ButtonFlat {
                        color: Theme.colorSubText

                        text: qsTr("Cancel")
                        onClicked: entryEditor.close()
                    }

                    ButtonFlat {
                        id: buttonEdit

                        visible: entryEditor.entry

                        text: qsTr("Edit entry")
                        source: "qrc:/IconLibrary/material-icons/duotone/edit.svg"

                        onClicked: {
                            //console.log("Edit entry: " + newEntry.entryType + " / " + newEntry.currentDateTime + " / " + entryComment.text)
                            entryEditor.entry.editEntry(entryEditor.entryType, entryEditor.currentDateTime, entryComment.text)
                            entryEditor.close()
                        }
                    }

                    ButtonFlat {
                        id: buttonAdd

                        visible: !entryEditor.entry

                        text: qsTr("Add entry")
                        source: "qrc:/IconLibrary/material-symbols/add.svg"

                        onClicked: {
                            //console.log("Add entry: " + newEntry.entryType + " / " + newEntry.currentDateTime + " / " + entryComment.text)
                            currentDevice.addJournalEntry(entryEditor.entryType, entryEditor.currentDateTime, entryComment.text)
                            entryEditor.close()
                        }
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
