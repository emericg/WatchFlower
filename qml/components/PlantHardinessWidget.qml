import QtQuick

import ThemeEngine 1.0
import PlantUtils 1.0
import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase

Column {
    id: plantHardinessWidget
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 4

    property var plant: null

    property int maxtoshow: 6

    property int hardiness_min
    property int hardiness_max
    property var vvv: []

    onPlantChanged: {
        if (typeof plant === "undefined" || !plant) return
        if (typeof plant.hardiness === "undefined" || !plant.hardiness) return

        var plantHardiness_min = plant.hardiness.split('-')[0]
        var plantHardiness_max = plant.hardiness.split('-')[1]

        if (plantHardiness_min.endsWith('a') || plantHardiness_min.endsWith('b'))
            hardiness_min = plantHardiness_min.slice(0, -1)
        if (plantHardiness_max.endsWith('a') || plantHardiness_max.endsWith('b'))
            hardiness_max = plantHardiness_max.slice(0, -1)

        var bbb = ((maxtoshow - (hardiness_max - hardiness_min + 1)) / 2).toFixed(0)
        for (var i = hardiness_min - bbb; i <= hardiness_max + bbb && i <= 13 && vvv.length < maxtoshow; i++) {
            vvv.push(i)
        }

        one.visible = vvv.includes(1)
        two.visible = vvv.includes(2)
        three.visible = vvv.includes(3)
        four.visible = vvv.includes(4)
        five.visible = vvv.includes(5)
        six.visible = vvv.includes(6)
        seven.visible = vvv.includes(7)
        eight.visible = vvv.includes(8)
        nine.visible = vvv.includes(9)
        ten.visible = vvv.includes(10)
        eleven.visible = vvv.includes(11)
        twelve.visible = vvv.includes(12)
        thirteen.visible = vvv.includes(13)
    }

    ////////////////////////////////////////////////////////////////////////////

    Text { // hardinessText
        anchors.left: parent.left
        anchors.right: parent.right

        text: plant && UtilsPlantDatabase.getHardinessText(plant.hardiness, settingsManager.tempUnit)
        color: Theme.colorText
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeContentBig
    }

    ////////////////////////////////////////////////////////////////////////////

    Row { // hardinessScale // 1 to 13
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: 4
        property int hdsz: ((width - (maxtoshow+1)*spacing) / maxtoshow)

        Rectangle { // 1
            id: one
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 1 && hardiness_max >= 1) ? 1 : 0.33
            color: "#d7d6fe"

            Text {
                anchors.centerIn: parent
                text: "1"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 2
            id: two
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 2 && hardiness_max >= 2) ? 1 : 0.33
            color: "#aaabd9"

            Text {
                anchors.centerIn: parent
                text: "2"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 3
            id: three
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 3 && hardiness_max >= 3) ? 1 : 0.33
            color: "#e091ec"

            Text {
                anchors.centerIn: parent
                text: "3"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 4
            id: four
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 4 && hardiness_max >= 4) ? 1 : 0.33
            color: "#a66cff"

            Text {
                anchors.centerIn: parent
                text: "4"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 5
            id: five
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 5 && hardiness_max >= 5) ? 1 : 0.33
            color: "#73a1ff"

            Text {
                anchors.centerIn: parent
                text: "5"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 6
            id: six
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 6 && hardiness_max >= 6) ? 1 : 0.33
            color: "#49ad4a"

            Text {
                anchors.centerIn: parent
                text: "6"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 7
            id: seven
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 7 && hardiness_max >= 7) ? 1 : 0.33
            color: "#abd66a"

            Text {
                anchors.centerIn: parent
                text: "7"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 8
            id: eight
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 8 && hardiness_max >= 8) ? 1 : 0.33
            color: "#ece185"

            Text {
                anchors.centerIn: parent
                text: "8"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 9
            id: nine
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 9 && hardiness_max >= 9) ? 1 : 0.33
            color: "#debb47"

            Text {
                anchors.centerIn: parent
                text: "9"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 10
            id: ten
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 10 && hardiness_max >= 10) ? 1 : 0.33
            color: "#e58026"

            Text {
                anchors.centerIn: parent
                text: "10"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 11
            id: eleven
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 11 && hardiness_max >= 11) ? 1 : 0.33
            color: "#e88e6c"

            Text {
                anchors.centerIn: parent
                text: "11"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 12
            id: twelve
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 12 && hardiness_max >= 12) ? 1 : 0.33
            color: "#d45a4f"

            Text {
                anchors.centerIn: parent
                text: "12"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
        Rectangle { // 13
            id: thirteen
            width: parent.hdsz
            height: 20
            radius: 4

            opacity: (hardiness_min <= 13 && hardiness_max >= 13) ? 1 : 0.33
            color: "#962f1e"

            Text {
                anchors.centerIn: parent
                text: "13"
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
