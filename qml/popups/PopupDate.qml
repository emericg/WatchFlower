import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary

Popup {
    id: popupDate

    x: singleColumn ? 0 : (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height)
                    : ((appWindow.height / 2) - (height / 2))

    width: singleColumn ? appWindow.width : 640
    padding: 0
    margins: 0

    dim: true
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    ////////////////////////////////////////////////////////////////////////////

    //property var locale: Qt.locale()

    property date today: new Date()
    property date initialDate
    property date selectedDate

    property bool isSelectedDateToday: false

    property var minDate: null
    property var maxDate: null

    ////////

    signal updateDate(var newdate)

    function openDate(date) {
        //console.log("openDate(" + date + ")")

        today = new Date()
        minDate = null
        maxDate = null

        initialDate = date
        selectedDate = date
        grid.year = date.getFullYear()
        grid.month = date.getMonth()

        printDate()

        popupDate.open()
    }

    function openDate_limits(datetime, min, max) {
        openDate(datetime)

        minDate = min
        maxDate = max
    }

    function printDate() {
        bigDay.text = selectedDate.toLocaleString(locale, "dddd")
        bigDate.text = selectedDate.toLocaleString(locale, "dd MMMM yyyy")

        var thismonth = new Date(grid.year, grid.month)
        bigMonth.text = thismonth.toLocaleString(locale, "MMMM")

        if (thismonth.getFullYear() !== today.getFullYear())
            bigMonth.text += " " + thismonth.toLocaleString(locale, "yyyy")

        isSelectedDateToday = (today.toLocaleString(locale, "dd MMMM yyyy") === selectedDate.toLocaleString(locale, "dd MMMM yyyy"))
    }

    function resetView() {
        grid.month = today.getMonth()
        grid.year = today.getFullYear()
        printDate()
    }
    function resetDate() {
        selectedDate = initialDate
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 133; } }
    //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.24 : 0.48
    }

    background: Rectangle {
        radius: singleColumn ? 0 : Theme.componentRadius
        color: Theme.colorBackground

        Item {
            anchors.fill: parent

            Rectangle { // title area
                anchors.left: parent.left
                anchors.right: parent.right
                height: 80
                color: Theme.colorPrimary
            }

            Rectangle { // border
                anchors.fill: parent
                radius: Theme.componentRadius
                color: "transparent"
                border.color: Theme.colorSeparator
                border.width: singleColumn ? 0 : Theme.componentBorderWidth
                opacity: 0.4
            }

            layer.enabled: !singleColumn
            layer.effect: MultiEffect { // clip
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
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

    contentItem: Column {
        bottomPadding: screenPaddingNavbar + screenPaddingBottom

        Item { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true
            height: 80

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    id: bigDay
                    text: selectedDate.toLocaleString(locale, "dddd") // "Vendredi"
                    font.pixelSize: 24
                    font.capitalization: Font.Capitalize
                    color: "white"
                }
                Text {
                    id: bigDate
                    text: selectedDate.toLocaleString(locale, "dd MMMM yyyy") // "15 octobre 2020"
                    font.pixelSize: 20
                    color: "white"
                }
            }

            RoundButtonSunken { // reset view
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                width: height

                visible: !(grid.year === today.getFullYear() && grid.month === today.getMonth())
                source: "qrc:/IconLibrary/material-icons/duotone/restart_alt.svg"

                colorBackground: Theme.colorPrimary
                colorHighlight: Qt.lighter(Theme.colorPrimary, 0.95)
                colorIcon: "white"

                onClicked: resetView()
            }
        }

        ////////////////

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: Theme.componentMarginXL
            bottomPadding: Theme.componentMarginXL

            ////////

            Rectangle { // month selector
                anchors.left: parent.left
                anchors.leftMargin: parent.Theme.componentBorderWidth
                anchors.right: parent.right
                anchors.rightMargin: parent.Theme.componentBorderWidth

                height: Theme.componentHeightXL
                color: Theme.colorForeground

                SquareButtonSunken { // previous month
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.componentHeightL
                    height: Theme.componentHeightL

                    source: "qrc:/IconLibrary/material-symbols/chevron_left.svg"
                    colorBackground: parent.color

                    onClicked: {
                        if (grid.month > 0) {
                            grid.month--
                        } else {
                            grid.month = 11
                            grid.year--
                        }
                        printDate()
                    }
                }

                Text {
                    id: bigMonth
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: selectedDate.toLocaleString(locale, "MMMM") // "Octobre"
                    font.capitalization: Font.Capitalize
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                }

                SquareButtonSunken { // next month
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.componentHeightL
                    height: Theme.componentHeightL

                    source: "qrc:/IconLibrary/material-symbols/chevron_right.svg"
                    colorBackground: parent.color

                    onClicked: {
                        if (grid.month < 11) {
                            grid.month++
                        } else {
                            grid.month = 0
                            grid.year++
                        }
                        printDate()
                    }
                }
            }

            ////////

            ColumnLayout { // days
                id: daysSelector
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin

                DayOfWeekRow {
                    id: dow

                    Layout.fillWidth: true
                    Layout.fillHeight: Theme.componentHeight
                    //locale: popupDate.locale

                    delegate: Text {
                        text: model.shortName.substring(0, 1).toUpperCase()
                        color: Theme.colorText
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MonthGrid {
                    id: grid

                    Layout.fillWidth: true
                    //locale: popupDate.locale

                    delegate: Text {
                        width: (grid.width / 7)
                        height: width
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        property bool isSelected: (model.day === selectedDate.getDate() &&
                                                   model.month === selectedDate.getMonth() &&
                                                   model.year === selectedDate.getFullYear())

                        property bool isToday: (model.day === popupDate.today.getDate() &&
                                                model.month === popupDate.today.getMonth() &&
                                                model.year === popupDate.today.getFullYear())

                        text: model.day
                        font: grid.font
                        //font.bold: model.today
                        color: isSelected ? "white" : Theme.colorSubText
                        opacity: (model.month === grid.month ? 1 : 0.2)

                        Rectangle {
                            z: -1
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 8
                            color: isSelected ? Theme.colorSecondary : "transparent"
                            opacity: (isSelected || isToday) ? 1 : 0.66
                            border.color: Theme.colorSecondary
                            border.width: {
                                if (isToday) return Theme.componentBorderWidth
                                if (mouse.hovered && model.month === grid.month) return Theme.componentBorderWidth
                                return 0
                            }
                        }

                        HoverHandler {
                            id: mouse
                            acceptedDevices: PointerDevice.Mouse
                        }
                    }

                    onClicked: (date) => {
                        if (date.getMonth() === grid.month) {
                            // validate date (min / max)
                            if (minDate && maxDate) {
                                const diffMinTime = (minDate - date)
                                const diffMinDays = -Math.ceil(diffMinTime / (1000 * 60 * 60 * 24) - 1)
                                //console.log(diffMinDays + " diffMinDays")
                                const diffMaxTime = (minDate - date);
                                const diffMaxDays = -Math.ceil(diffMaxTime / (1000 * 60 * 60 * 24) - 1)
                                //console.log(diffMaxDays + " diffMaxDays")

                                if (diffMinDays > -1 && diffMaxDays < 1) {
                                    date.setHours(selectedDate.getHours(),
                                                  selectedDate.getMinutes(),
                                                  selectedDate.getSeconds())
                                    selectedDate = date
                                }
                            } else {
                                const diffTime = (today - date)
                                const diffDays = -Math.ceil(diffTime / (1000 * 60 * 60 * 24) - 1)
                                //console.log(diffDays + " days")

                                // validate date (-21 / today)
                                if (diffDays > -21 && diffDays < 1) {
                                    date.setHours(selectedDate.getHours(),
                                                  selectedDate.getMinutes(),
                                                  selectedDate.getSeconds())
                                    selectedDate = date
                                }
                            }

                            printDate()
                        }
                    }
                }
            }

            ////////
        }

        ////////////////

        Flow {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.componentMarginXL
            bottomPadding: Theme.componentMarginXL
            spacing: Theme.componentMargin

            property int btnCount: 2
            property int btnSize: singleColumn ? width : ((width-(spacing*(btnCount-1))) / btnCount)

            ButtonClear {
                width: parent.btnSize
                color: Theme.colorGrey

                text: qsTr("Cancel")
                onClicked: popupDate.close()
            }

            ButtonFlat {
                width: parent.btnSize

                text: qsTr("Select")
                onClicked: {
                    updateDate(selectedDate)
                    popupDate.close()
                }
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
