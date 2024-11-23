import QtQuick
import QtQuick.Controls

import ComponentLibrary

Item {
    id: vocBar

    implicitWidth: 16
    implicitHeight: 128

    property int valueMin
    property int valueMean
    property int valueMax

    property int graphMin
    property int graphMax

    property int limitMin
    property int limitMax

    ///////////////

    Component.onCompleted: loadValues()

    function loadValues() {
        if (currentDevice.primary === "voc" ||
            currentDevice.primary === "hcho") {
            valueMin = modelData.vocMin
            valueMean = modelData.vocMean
            valueMax = modelData.vocMax
        } else if (currentDevice.primary === "co2") {
            valueMin = modelData.co2Min
            valueMean = modelData.co2Mean
            valueMax = modelData.co2Max
        } else if (currentDevice.primary === "pm25") {
            valueMin = modelData.pm25Min
            valueMean = modelData.pm25Mean
            valueMax = modelData.pm25Max
        } else if (currentDevice.primary === "pm10") {
            valueMin = modelData.pm10Min
            valueMean = modelData.pm10Mean
            valueMax = modelData.pm10Max
        }

        if (vocBar.valueMax > vocBar.graphMax) vocBar.valueMax = vocBar.graphMax
        if (vocBar.valueMean > vocBar.graphMax) vocBar.valueMean = vocBar.graphMax
    }

    ///////////////

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 2

        color: Theme.colorSeparator
        opacity: 0.25
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter

        radius: 20
        width: vocBar.width - 8 + 1
        height: (vocBar.valueMax / vocBar.graphMax) * (vocBar.height - 4)
        Behavior on height { NumberAnimation { duration: 333 } }

        color: {
            if (vocBar.valueMax > vocBar.limitMax)
                return Theme.colorOrange
            else if (vocBar.valueMax > vocBar.limitMin)
                return Theme.colorYellow
            else
                return Theme.colorGreen
        }
        Behavior on color { ColorAnimation { duration: 333 } }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: {
                if (vocBar.valueMean >= vocBar.graphMax) return 1
                return (parent.height - ((vocBar.valueMean / vocBar.graphMax) * parent.height))
            }
            visible: (vocBar.valueMean > 0)
            width: parent.width - 2
            height: width
            radius: width
            color: "white"
            opacity: 0.8
        }
    }

    ///////////////

    Text { // days legend
        anchors.top: parent.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter

        rotation: -45
        text: modelData.day
        color: Theme.colorSubText
        font.bold: modelData.today
        font.pixelSize: Theme.fontSizeContentVerySmall
    }

    ///////////////
}
