import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

import JournalUtils 1.0
import "qrc:/js/UtilsPlantJournal.js" as UtilsPlantJournal

Loader {
    id: plantCareJournal

    sourceComponent: null
    asynchronous: true

    function load() {
        if (!sourceComponent) {
            sourceComponent = componentCareJournal
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: componentCareJournal

        Item {
            ListView {
                id: entries
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                model: currentDevice.journalEntries
                delegate: JournalWidget {
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -28
                    visible: (entries.count <= 0)

                    IconSvg {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: (isDesktop || isTablet || (isPhone && appWindow.screenOrientation === Qt.LandscapeOrientation)) ? 256 : (parent.width*0.666)
                        height: width

                        source: "qrc:/assets/icons_material/baseline-import_contacts-24px.svg"
                        fillMode: Image.PreserveAspectFit
                        color: Theme.colorIcon
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("There is no entry in the journal...")
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }
                }
            }

            ////////////////////////////////////////////////////////////////////////////

            RoundButtonIcon {
                id: add
                width: 48
                height: 48
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20

                source: "qrc:/assets/icons_material/baseline-add-24px.svg"
                iconColor: "white"
                background: true
                backgroundColor: Theme.colorPrimary

                onClicked: newEntry.visible = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 32
                    anchors.verticalCenter: parent.verticalCenter

                    visible: (entries.count <= 0)
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeComponent
                    text: qsTr("You can add new entries here!")

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -12
                        z: -1
                        radius: Theme.componentRadius
                        color: Theme.colorForeground
                        border.width: Theme.componentBorderWidth
                        border.color: Theme.colorSeparator
                    }
                }
            }

            ////////////////////////////////////////////////////////////////////////////

            Rectangle {
                id: newEntry
                anchors.fill: parent

                visible: false
                color: Theme.colorForeground
                //height: parent.height * 0.66

                property var currentLocale: Qt.locale()
                property var currentDateTime: new Date()
                property int entryType: JournalUtils.JOURNAL_WATER

                PopupDate {
                    id: popupDate
                    locale: newEntry.currentLocale
                    onUpdateDate: {
                        //console.log("onUpdateDate(" + newdate + ")")
                        newEntry.currentDateTime = newdate
                    }
                }

                onVisibleChanged: {
                    datePicker.openDate(currentDateTime)
                    entryType = JournalUtils.JOURNAL_WATER
                    entryComment.text = ""
                }

                ////////////////

                Row {
                    id: rowrowrow
                    anchors.fill: parent
                    anchors.margins: 24
                    anchors.bottomMargin: 80
                    spacing: singleColumn ? 16 : 20

                    DatePicker {
                        id: datePicker
                        width: (newEntry.width * 0.4) - (24+10)
                        height: rowrowrow.height
                        visible: !singleColumn

                        onUpdateDate: {
                            //console.log("onUpdateDate(" + newdate + ")")
                            newEntry.currentDateTime = newdate
                        }
                    }

                    ////

                    Column {
                        width: singleColumn ? parent.width : ((newEntry.width * 0.6) - (24+10))
                        spacing: 24

                        ButtonWireframe {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: singleColumn ? 40 : 44

                            //visible: singleColumn
                            fullColor: true
                            text: newEntry.currentDateTime.toLocaleDateString(newEntry.currentLocale)
                            primaryColor: Theme.colorSecondary
                            onClicked: {
                                if (singleColumn)
                                    popupDate.openDate(newEntry.currentDateTime)
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: singleColumn ? colEntryType.height : colEntryType.height + 24

                            radius: Theme.componentRadius
                            color: Theme.colorForeground
                            border.width: singleColumn ? 0 : 2
                            border.color: Theme.colorSeparator

                            Grid {
                                id: colEntryType
                                anchors.centerIn: parent

                                //property bool doubletrouble: (parent.width < (6*52 + 5*24))
                                rows: singleColumn ? 2 : 1
                                columns: singleColumn ? 1 : 2
                                spacing: singleColumn ? 16 : 20

                                Row {
                                    spacing: 24

                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52

                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_WATER)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_WATER)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_WATER
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_WATER)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }
                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52
                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_FERTILIZE)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_FERTILIZE)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_FERTILIZE
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_FERTILIZE)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }
                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52
                                            sourceSize: 32
                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_PRUNE)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_PRUNE)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_PRUNE
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_PRUNE)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }
                                }
        /*
                                Row {
                                    visible: false // disabled
                                    spacing: 24

                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52
                                            sourceSize: 32
                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_COMMENT)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_COMMENT)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_COMMENT
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_COMMENT)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }

                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52
                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_PHOTO)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_PHOTO)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_PHOTO
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_PHOTO)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }
                                }
        */
                                Row {
                                    spacing: 24

                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52
                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_ROTATE)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_ROTATE)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_ROTATE
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_ROTATE)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }

                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52
                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_MOVE)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_MOVE)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_MOVE
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_MOVE)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }

                                    Column {
                                        width: 52
                                        spacing: 4

                                        RoundButtonIcon {
                                            width: 52
                                            height: 52
                                            source: UtilsPlantJournal.getJournalEntryIcon(JournalUtils.JOURNAL_REPOT)
                                            iconColor: Theme.colorSubText
                                            background: true
                                            backgroundColor: Theme.colorBackground
                                            border: true
                                            borderColor: selected ? Theme.colorPrimary : Theme.colorComponentBorder
                                            highlightMode: "border"

                                            selected: (newEntry.entryType === JournalUtils.JOURNAL_REPOT)
                                            onClicked: newEntry.entryType = JournalUtils.JOURNAL_REPOT
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: UtilsPlantJournal.getJournalEntryName(JournalUtils.JOURNAL_REPOT)
                                            color: Theme.colorText
                                            font.pixelSize: Theme.fontSizeContentSmall
                                        }
                                    }
                                }
                            }
                        }

                        TextAreaThemed {
                            id: entryComment
                            width: parent.width
                            height: 160

                            colorBackground: Theme.colorBackground
                            placeholderText: qsTr("Add a comment")
                        }
                    }
                }

                ////////////////

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    spacing: 20

                    ButtonWireframe {
                        fullColor: true
                        primaryColor: "grey"

                        text: qsTr("Cancel")
                        onClicked: newEntry.visible = false
                    }

                    ButtonWireframeIcon {
                        fullColor: true
                        primaryColor: Theme.colorPrimary
                        source: "qrc:/assets/icons_material/baseline-add-24px.svg"

                        text: qsTr("Add")
                        onClicked: {
                            //console.log("Add entry: " + newEntry.entryType + " / " + newEntry.currentDateTime + " / " + entryComment.text)
                            entryComment.focus = false
                            currentDevice.addJournalEntry(newEntry.entryType, newEntry.currentDateTime, entryComment.text)
                            newEntry.visible = false
                        }
                    }
                }
            }
        }
    }
}
