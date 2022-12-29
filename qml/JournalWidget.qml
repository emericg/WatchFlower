import QtQuick

import ThemeEngine 1.0
import JournalUtils 1.0
import "qrc:/js/UtilsPlantJournal.js" as UtilsPlantJournal

Item {
    id: journalWidget
    implicitWidth: 480
    implicitHeight: 720

    height: rowheader.height + (modelData.comment.length > 0 ? ccccc.contentHeight : 8) + 16

    property bool selected: (entriesView.entrySelected === index)

    ////////

    Row {
        id: rowheader
        anchors.left: parent.left
        anchors.leftMargin: singleColumn ? 8 : 12

        layoutDirection: singleColumn ? Qt.RightToLeft : Qt.LeftToRight
        spacing: 12

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: singleColumn ? 48 : 72

            text: modelData.date.toLocaleString(Qt.locale(), "dd MMMM")
            horizontalAlignment: isPhone ? Text.AlignLeft : Text.AlignRight
            color: Theme.colorSubText
            font.bold: false
            font.pixelSize: isPhone ? Theme.fontSizeContent : Theme.fontSizeContentBig
        }

        Rectangle {
            width: 24
            height: 24
            radius: 24
            anchors.verticalCenter: parent.verticalCenter

            color: UtilsPlantJournal.getJournalEntryColor(modelData.type)
            border.color: Theme.colorSeparator
            border.width: 4

            Rectangle {
                anchors.fill: parent
                anchors.margins: -6
                radius: width
                z: -1
                opacity: selected ? 0.5 : 0
                Behavior on opacity { OpacityAnimator { duration: 133 } }
                color: (Theme.currentTheme === ThemeEngine.THEME_SNOW) ? Theme.colorPrimary : Theme.colorHeader
            }

            Rectangle {
                anchors.top: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                width: 3
                height: journalWidget.height - 8
                z: -1
                color: Theme.colorSeparator
            }
        }
    }

    ////////

    Text {
        id: ttttt
        anchors.left: rowheader.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: rowheader.verticalCenter

        text: UtilsPlantJournal.getJournalEntryName2(modelData.type)
        wrapMode: Text.WordWrap
        color: Theme.colorText
        font.pixelSize: Theme.fontSizeContentBig
    }

    Text {
        id: ccccc
        anchors.top: ttttt.bottom
        anchors.topMargin: 8
        anchors.left: ttttt.left
        anchors.right: parent.right
        anchors.rightMargin: 12

        visible: (modelData.comment.length > 0)
        text: modelData.comment
        color: Theme.colorSubText
        font.pixelSize: Theme.fontSizeContentBig
    }

    ////////

    MouseArea {
        anchors.fill: parent
        anchors.margins: -8
/*
        propagateComposedEvents: true
        hoverEnabled: false
        onEntered: buttonrow.opacity = 1
        onExited: buttonrow.opacity = 0
*/
        onClicked: {
            utilsApp.vibrate(25)

            if (selected)
                entriesView.entrySelected = -1
            else
                entriesView.entrySelected = index
        }
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: rowheader.verticalCenter

        spacing: 8
        enabled: selected
        opacity: selected ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 200 } }

        RoundButtonIcon {
            source: "qrc:/assets/icons_material/duotone-edit-24px.svg"

            onClicked: {
                journalEditorLoader.active = true
                journalEditorLoader.item.editEditor(modelData)
            }
        }
        RoundButtonIcon {
            source: "qrc:/assets/icons_material/baseline-delete-24px.svg"

            onClicked: {
                currentDevice.removeJournalEntry(modelData.id)
            }
        }
    }

    ////////
}
