import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

import JournalUtils 1.0
import "qrc:/js/UtilsPlantJournal.js" as UtilsPlantJournal

Item {
    id: plantCareJournal

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

        appContent.state = "DeviceList"
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
            onCountChanged: {
                entrySelected = -1
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
                    anchors.leftMargin: singleColumn ? 0 : 88

                    source: "qrc:/assets/icons_custom/pot_flower-24px.svg"
                    iconColor: "white"
                    background: true
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
                    anchors.leftMargin: singleColumn ? 0 : 88
                    anchors.bottom: parent.bottom

                    source: "qrc:/assets/icons_material/baseline-add-24px.svg"
                    iconColor: "white"
                    background: true
                    backgroundColor: Theme.colorPrimary

                    onClicked: entryEditor.open()

                    ButtonWireframe {
                        height: 36
                        anchors.left: parent.right
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        fullColor: true
                        primaryColor: Theme.colorSecondary
                        text: qsTr("Add a new entry")

                        onClicked: {
                            journalEditorLoader.active = true
                            journalEditorLoader.item.openEditor()
                        }
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////

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
                    datePicker.openDate(currentDateTime) // to keep date
                    //datePicker.openDate(new Date()) // to reset date

                    entry = null
                    entryType = JournalUtils.JOURNAL_WATER
                    entryComment.text = ""

                    entryEditor.visible = true
                }

                function edit(eee) {
                    datePicker.openDate(eee.date)

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

                Row {
                    id: rowrowrow
                    anchors.fill: parent
                    anchors.topMargin: isPhone ? 14 : 16
                    anchors.leftMargin: isPhone ? 12 : 16
                    anchors.rightMargin: isPhone ? 12 : 16
                    anchors.bottomMargin: 80
                    spacing: 20

                    Item {
                        width: (rowrowrow.width * 0.4) - (rowrowrow.spacing / 2)
                        height: rowrowrow.height
                        visible: !singleColumn

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
                        width: singleColumn ? parent.width : (rowrowrow.width * 0.6) - (rowrowrow.spacing / 2)
                        spacing: isPhone ? 12 : 20

                        ButtonWireframe {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: singleColumn ? 40 : 44

                            //visible: singleColumn
                            fullColor: true
                            text: entryEditor.currentDateTime.toLocaleDateString(Qt.locale())
                            primaryColor: Theme.colorSecondary
                            onClicked: {
                                if (singleColumn)
                                    popupDate.openDate(entryEditor.currentDateTime)
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: colEntryType.height + 20

                            radius: Theme.componentRadius
                            color: Theme.colorForeground
                            border.width: singleColumn ? 0 : 2
                            border.color: Theme.colorSeparator

                            Grid {
                                id: colEntryType
                                anchors.centerIn: parent

                                //property bool doubletrouble: (parent.width < (6*52 + 5*24))
                                rows: singleColumn ? 2 : 1
                                columns: singleColumn ? 3 : 6
                                spacing: singleColumn ? 16 : 20

                                Repeater {
                                    model: [JournalUtils.JOURNAL_WATER, JournalUtils.JOURNAL_FERTILIZE, JournalUtils.JOURNAL_PRUNE,
                                            JournalUtils.JOURNAL_ROTATE, JournalUtils.JOURNAL_MOVE, JournalUtils.JOURNAL_REPOT]

                                    Column {
                                        spacing: 4
                                        width: btn.width

                                        RoundButtonIcon {
                                            id: btn
                                            width: 52
                                            height: 52

                                            source: UtilsPlantJournal.getJournalEntryIcon(modelData)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (entryEditor.entryType === modelData)
                                            onClicked: entryEditor.entryType = modelData
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter

                                            text: UtilsPlantJournal.getJournalEntryName(modelData)
                                            textFormat: Text.PlainText
                                            color: btn.selected ? Theme.colorPrimary : Theme.colorText
                                            //font.bold: btn.selected
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }
                                }
                            }
                        }

                        TextAreaThemed {
                            id: entryComment
                            width: parent.width
                            height: isPhone ? 128 : 160

                            colorBackground: Theme.colorBackground
                            placeholderText: qsTr("Add a comment")
                        }
                    }
                }

                ////////////////

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 16
                    spacing: 16

                    ButtonWireframe {
                        fullColor: true
                        primaryColor: "grey"

                        text: qsTr("Cancel")
                        onClicked: entryEditor.close()
                    }

                    ButtonWireframeIcon {
                        id: buttonEdit

                        visible: entryEditor.entry

                        text: qsTr("Edit entry")
                        fullColor: true
                        primaryColor: Theme.colorPrimary
                        source: "qrc:/assets/icons_material/duotone-edit-24px.svg"

                        onClicked: {
                            //console.log("Add entry: " + newEntry.entryType + " / " + newEntry.currentDateTime + " / " + entryComment.text)
                            entryEditor.entry.editEntry(entryEditor.entryType, entryEditor.currentDateTime, entryComment.text)
                            entryEditor.close()
                        }
                    }

                    ButtonWireframeIcon {
                        id: buttonAdd

                        visible: !entryEditor.entry

                        text: qsTr("Add entry")
                        fullColor: true
                        primaryColor: Theme.colorPrimary
                        source: "qrc:/assets/icons_material/baseline-add-24px.svg"

                        onClicked: {
                            //console.log("Add entry: " + newEntry.entryType + " / " + newEntry.currentDateTime + " / " + entryComment.text)
                            currentDevice.addJournalEntry(entryEditor.entryType, entryEditor.currentDateTime, entryComment.text)
                            entryEditor.close()
                        }
                    }
                }
            }

            ////////////////////////////////////////////////////////////////////
        }
    }
}
