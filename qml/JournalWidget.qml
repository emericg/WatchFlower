import QtQuick 2.15

import ThemeEngine 1.0
import JournalUtils 1.0
import "qrc:/js/UtilsPlantJournal.js" as UtilsPlantJournal

Rectangle {
    id: journalWidget
    implicitWidth: 640
    implicitHeight: 80

    radius: 4
    color: Qt.lighter(UtilsPlantJournal.getJournalEntryColor(modelData.type), 1.2)
    border.width: 2
    border.color: UtilsPlantJournal.getJournalEntryColor(modelData.type)

    ButtonIcon {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 56; height: 56;

        border: true
        background: true
        backgroundColor: Theme.colorBackground
        iconColor: Qt.darker(UtilsPlantJournal.getJournalEntryColor(modelData.type), 1.1)
        source: UtilsPlantJournal.getJournalEntryIcon(modelData.type)
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: modelData.date.toLocaleString(locale, "dd MMMM yyyy")
            color: Theme.colorLowContrast
            font.pixelSize: Theme.fontSizeContentVeryBig
        }

        Text {
            text: modelData.comment
            color: Qt.darker(Theme.colorLowContrast, 1.1)
            font.pixelSize: Theme.fontSizeContentBig
        }
    }
}
