// UtilsPlantJournal.js
// Version 1

.pragma library

.import JournalUtils as JournalUtils
.import ThemeEngine as ThemeEngine

/* ************************************************************************** */

function getJournalEntryName(entryType) {
    var txt = ""

    if (entryType === JournalUtils.JournalUtils.JOURNAL_UNKNOWN) {
        txt = qsTr("Unknown")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_COMMENT) {
        txt = qsTr("Comment")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_PHOTO) {
        txt = qsTr("Photo")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_WATER) {
        txt = qsTr("Water")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_FERTILIZE) {
        txt = qsTr("Fertilize")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_PRUNE) {
        txt = qsTr("Prune")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_ROTATE) {
        txt = qsTr("Rotate")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_MOVE) {
        txt = qsTr("Move")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_REPOT) {
        txt = qsTr("Repot")
    }

    return txt
}

function getJournalEntryName2(entryType) {
    var txt = ""

    if (entryType === JournalUtils.JournalUtils.JOURNAL_UNKNOWN) {
        txt = qsTr("Unknown")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_COMMENT) {
        txt = qsTr("Comment")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_PHOTO) {
        txt = qsTr("Photo")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_WATER) {
        txt = qsTr("Watered")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_FERTILIZE) {
        txt = qsTr("Fertilized")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_PRUNE) {
        txt = qsTr("Pruned")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_ROTATE) {
        txt = qsTr("Rotated")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_MOVE) {
        txt = qsTr("Moved")
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_REPOT) {
        txt = qsTr("Repoted")
    }

    return txt
}

function getJournalEntryIcon(entryType) {
    var src = ""

    if (entryType === JournalUtils.JournalUtils.JOURNAL_UNKNOWN) {
        src = "qrc:/assets/icons/material-icons/duotone/edit.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_COMMENT) {
        src = "qrc:/assets/icons/material-icons/duotone/edit.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_PHOTO) {
        src = "qrc:/assets/icons/material-icons/duotone/edit.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_WATER) {
        src = "qrc:/assets/icons/material-icons/duotone/local_drink.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_FERTILIZE) {
        src = "qrc:/assets/icons/material-symbols/sensors/tonality.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_PRUNE) {
        src = "qrc:/assets/icons/material-symbols/content_cut.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_ROTATE) {
        src = "qrc:/assets/icons/material-icons/duotone/rotate_90_degrees_ccw.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_MOVE) {
        src = "qrc:/assets/icons/material-symbols/open_with.svg"
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_REPOT) {
        src = "qrc:/assets/gfx/icons/pot_flower-24px.svg"
    }

    return src
}

function getJournalEntryColor(entryType) {
    var clr = ""

    if (entryType === JournalUtils.JournalUtils.JOURNAL_WATER) {
        clr = ThemeEngine.Theme.colorBlue
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_FERTILIZE) {
        clr = ThemeEngine.Theme.colorRed
    } else if (entryType === JournalUtils.JournalUtils.JOURNAL_ROTATE ||
               entryType === JournalUtils.JournalUtils.JOURNAL_MOVE) {
        clr = ThemeEngine.Theme.colorYellow
    }  else if (entryType === JournalUtils.JournalUtils.JOURNAL_PRUNE ||
                entryType === JournalUtils.JournalUtils.JOURNAL_REPOT) {
         clr = ThemeEngine.Theme.colorGreen
     } else {
        clr = ThemeEngine.Theme.colorForeground
    }

    return clr
}

/* ************************************************************************** */
