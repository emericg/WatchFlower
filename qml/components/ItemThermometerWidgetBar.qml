
import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: thermoWidgetBar
    width: 64
    height: parent.height

    property var mmd: null
    property int hhh: 22

    //Component.onCompleted: computeSize()
    onHeightChanged: computeSize()

    function computeSize() {
        var base = height
        var h = UtilsNumber.normalize(mmd.tempMax, graphMin*0.94, graphMax*1.06)
        var m = UtilsNumber.normalize(mmd.tempMean, graphMin*0.94, graphMax*1.06)
        var l = UtilsNumber.normalize(mmd.tempMin, graphMin*0.94, graphMax*1.06)

        rectangle_temp.y = base - (base * h)
        rectangle_temp.height = ((base * h) - (base * l))

        rectangle_temp_mean.visible = ((mmd.tempMax - mmd.tempMin) > 0.2)
        rectangle_temp_mean.y = base - (base * m) -  rectangle_temp.y

        if (rectangle_temp.height < hhh) {
            rectangle_temp.y -= (hhh - rectangle_temp.height) / 2
            rectangle_temp.height = hhh
        }

        if ((mmd.tempMax === mmd.tempMin) && (mmd.hygroMax === mmd.hygroMin)) {
            text_temp_low.visible = false
            rectangle_water_low.visible = false
        }

        //console.log("h : " + h)
        //console.log("m : " + m)
        //console.log("l : " + l)
        //console.log("base : " + base)
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        //anchors.margins: -8
        color: (index % 2 === 0) ? Theme.colorForeground : "transparent"
        opacity: 0.66
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter

        text: modelData.day
        color: Theme.colorText
        font.pixelSize: 16
    }

    ////////

    Rectangle {
        id: rectangle_temp
        width: hhh
        height: 0
        radius: 16
        //anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        color: Theme.colorGreen
        opacity: 0.9

        border.color: "#6db300" //"#70b700"
        border.width: 1

        Rectangle {
            id: rectangle_temp_mean
            width: hhh*0.66; height: hhh*0.66; radius: hhh;
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
            text: mmd.tempMax.toFixed(1) + "°"
            font.pixelSize: 12
        }

        Text {
            id: text_temp_low
            anchors.top: parent.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 2

            color: Theme.colorSubText
            text: mmd.tempMin.toFixed(1) + "°"
            font.pixelSize: 12
        }
    }

    ////////////////////////////////////////////////////////////////////////////

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
        border.width: 1

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

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
        border.width: 1

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

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
