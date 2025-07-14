import QtQuick

import ComponentLibrary

Column {
    id: plantCalendarWidget
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 2

    property int www: Math.ceil((width-8) / 12)
    property int hhh: 18
    property int rrr: 18

    property var colorBackground: Theme.colorBackground

    property var plant: null

    ////////////////////////////////////////////////////////////////////////////

    Row { // legend // month names
        anchors.left: parent.left
        anchors.right: parent.right

        Repeater {
            model: 12

            Text {
                width: www
                height: hhh

                text: locale.monthName(modelData, Locale.NarrowFormat)
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right

        height: col.height + 4
        radius: 8

        color: colorBackground
        border.width: 2
        border.color: Theme.colorSeparator

        Column {
            id: col
            anchors.centerIn: parent
            spacing: 0

            Row { // planting
                height: 20
                spacing: 0

                Repeater {
                    model: plant && plant.calendarPlanting
                    delegate: BulletMonth {
                        dataSelection: (modelData === "1")
                        colorSelection: Theme.colorGreen
                    }
                }
            }

            Row { // fertilizing
                height: 20
                spacing: 0

                Repeater {
                    model: plant && plant.calendarFertilizing
                    BulletMonth {
                        dataSelection: (modelData === "1")
                        colorSelection: Theme.colorOrange
                    }
                }
            }

            Row { // growing
                height: 20
                spacing: 0

                Repeater {
                    model: plant && plant.calendarGrowing
                    BulletMonth {
                        dataSelection: (modelData === "1")
                        colorSelection: Theme.colorGreen
                    }
                }
            }

            Row { // blooming
                height: 20
                spacing: 0

                Repeater {
                    model: plant && plant.calendarBlooming
                    BulletMonth {
                        dataSelection: (modelData === "1")
                        colorSelection: Theme.colorYellow
                    }
                }
            }

            Row { // fruiting
                height: 20
                spacing: 0

                Repeater {
                    model: plant && plant.calendarFruiting
                    BulletMonth {
                        dataSelection: (modelData === "1")
                        colorSelection: Theme.colorRed
                    }
                }
            }
        }
    }

    component BulletMonth: Item {
        anchors.verticalCenter: parent.verticalCenter
        width: www
        height: hhh

        property bool dataSelection: false
        property color colorSelection

        Rectangle {
            radius: rrr
            anchors.fill: parent
            anchors.margins: 1
            border.width: dataSelection ? 1 : 0
            border.color: Theme.colorLowContrast
            color: dataSelection ? colorSelection : "transparent"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Row { // legend // periods
        spacing: 8
        height: hhh + 4

        Text {
            height: hhh
            visible: (plant && plant.calendarPlanting.length > 0)
            text: qsTr("planting")
            textFormat: Text.PlainText
            color: Theme.colorRed
            font.pixelSize: Theme.fontSizeContent
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            height: hhh
            visible: (plant && plant.calendarFertilizing.length > 0)
            text: qsTr("fertilizing")
            textFormat: Text.PlainText
            color: Theme.colorOrange
            font.pixelSize: Theme.fontSizeContent
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            height: hhh
            visible: (plant && plant.calendarGrowing.length > 0)
            text: qsTr("growing")
            textFormat: Text.PlainText
            color: Theme.colorGreen
            font.pixelSize: Theme.fontSizeContent
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            height: hhh
            visible: (plant && plant.calendarBlooming.length > 0)
            text: qsTr("blooming")
            textFormat: Text.PlainText
            color: Theme.colorYellow
            font.pixelSize: Theme.fontSizeContent
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            height: hhh
            visible: (plant && plant.calendarFruiting.length > 0)
            text: qsTr("fruiting")
            textFormat: Text.PlainText
            color: Theme.colorRed
            font.pixelSize: Theme.fontSizeContent
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
