import QtQuick 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: chartThermometerMinMaxBar
    width: 64
    height: parent.height

    property var mmd: null
    property int www: 20

    Component.onCompleted: {
        setTemp()
        computeSize()
    }

    Connections {
        target: settingsManager
        function onTempUnitChanged() { setTemp() }
    }

    onHeightChanged: computeSize()

    function computeSize() {
        if (mmd.tempMean < -10) {
            rectangle_temp.visible = false
            rectangle_water_low.visible = false
            rectangle_water_high.visible = false
        } else {
            var ttt = 1.15
            var bbb = 0.85
            var base = containerbar.height
            var base2 = containerbar.height - rectangle_temp_mean.height
            var h = UtilsNumber.normalize(mmd.tempMax, graphMin*bbb, graphMax*ttt)
            var m = UtilsNumber.normalize(mmd.tempMean, graphMin*bbb, graphMax*ttt)
            var l = UtilsNumber.normalize(mmd.tempMin, graphMin*bbb, graphMax*ttt)

            rectangle_temp.visible = true
            rectangle_temp.y = base - (base * h)
            rectangle_temp.height = ((base * h) - (base * l))

            if (rectangle_temp.height < www) {
                rectangle_temp.y -= (www - rectangle_temp.height) / 2
                rectangle_temp.height = www
            }

            rectangle_temp_mean.visible = ((mmd.tempMax - mmd.tempMin) > 0.5)
            rectangle_temp_mean.y = base2 - ((base2) * m) - rectangle_temp.y

            if ((mmd.tempMax === mmd.tempMin && mmd.hygroMax === mmd.hygroMin)) {
                text_temp_low.visible = false
                rectangle_water_low.visible = false
            } else {
                text_temp_low.visible = true
                rectangle_water_low.visible = true
            }
            rectangle_water_high.visible = true
        }
    }

    function setTemp() {
        var th = mmd.tempMax
        var tl = mmd.tempMin

        if (settingsManager.tempUnit === "F") {
            th = UtilsNumber.tempCelsiusToFahrenheit(mmd.tempMax)
            tl = UtilsNumber.tempCelsiusToFahrenheit(mmd.tempMin)
        }

        text_temp_high.text = th.toFixed(1) + "°"
        text_temp_low.text = tl.toFixed(1) + "°"
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.fill: parent
        color: (index % 2 === 0) ? Theme.colorBackground : Theme.colorForeground
        opacity: 0.66
    }

    ImageSvg {
        id: nodata
        width: 20; height: 20;
        anchors.bottom: dayoftheweek.top
        anchors.bottomMargin: isPhone ? 12 : 16
        anchors.horizontalCenter: parent.horizontalCenter

        asynchronous: true
        color: Theme.colorSubText
        source: (mmd.tempMean < -40) ? "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg" : ""
    }

    Text {
        id: dayoftheweek
        anchors.bottom: parent.bottom
        anchors.bottomMargin: isPhone ? 10 : 16
        anchors.horizontalCenter: parent.horizontalCenter

        text: mmd.day
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContent
        font.bold: mmd.today
        color: Theme.colorText
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: containerbar
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 56

        Rectangle {
            id: rectangle_temp
            width: www
            height: 0
            radius: 16
            anchors.horizontalCenter: parent.horizontalCenter

            color: Theme.colorGreen
            opacity: 0.9

            border.color: "#77eeeeee"
            border.width: 1

            Rectangle {
                id: rectangle_temp_mean
                width: UtilsNumber.alignTo(www*0.666, 2)
                height: width
                radius: width
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                opacity: 0.9
            }

            Text {
                id: text_temp_high
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 2

                color: Theme.colorSubText
                font.pixelSize: 12
            }

            Text {
                id: text_temp_low
                anchors.top: parent.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 2

                color: Theme.colorSubText
                font.pixelSize: 12
            }
        }

        ////////

        Rectangle {
            id: rectangle_water_high
            width: 32
            height: 32
            radius: 16
            anchors.bottom: rectangle_temp.top
            anchors.bottomMargin: 32
            anchors.horizontalCenter: parent.horizontalCenter

            color: Theme.colorBlue
            opacity: 0.9

            border.color: "#2695c5"
            border.width: 2

            Row {
                anchors.centerIn: parent

                Text {
                    id: element_water_high
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    text: mmd.hygroMax
                    font.pixelSize: 12
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    text: "%"
                    font.pixelSize: 8
                }
            }
        }

        Rectangle {
            id: rectangle_water_low
            width: 32
            height: 32
            radius: 16
            anchors.top: rectangle_temp.bottom
            anchors.topMargin: 32
            anchors.horizontalCenter: parent.horizontalCenter

            color: Theme.colorBlue
            opacity: 0.9

            border.color: "#2695c5"
            border.width: 2

            Row {
                anchors.centerIn: parent

                Text {
                    id: text_water_low
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    text: mmd.hygroMin
                    font.pixelSize: 12
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    text: "%"
                    font.pixelSize: 8
                }
            }
        }
    }
}
