import QtQuick 2.12

import ThemeEngine 1.0

Item {
    id: indicatorAirQuality
    width: 128
    height: 128

    property real aqi: 25
    property string color: Theme.colorIcon

    ////////////////////////////////////////////////////////////////////////////

    ProgressCircle {
        width: parent.width * 1.22
        anchors.centerIn: parent

        lineWidth: 10
        arcBegin: 0
        arcEnd: 30
        colorCircle: Theme.colorRed//"#a17cb8" // Theme.colorRed
        //colorCircle: Theme.colorRed
        opacity: 1
    }
    ProgressCircle {
        width: parent.width * 1.22
        anchors.centerIn: parent

        lineWidth: 10
        arcBegin: 34
        arcEnd: 95
        colorCircle: "#f0805f" // Theme.color
        //colorCircle: Theme.colorRed
        opacity: 1
    }
    ProgressCircle {
        width: parent.width * 1.22
        anchors.centerIn: parent

        lineWidth: 10
        arcBegin: 100
        arcEnd: 185
        colorCircle: "#f0805f" // Theme.color
        opacity: 0.70
    }
    ProgressCircle {
        width: parent.width * 1.22
        anchors.centerIn: parent

        lineWidth: 10
        arcBegin: 190
        arcEnd: 270
        colorCircle: Theme.colorGreen
        opacity: 0.8
    }

    ProgressCircle { // background
        anchors.fill: parent
        colorCircle: indicatorAirQuality.color
        opacity: 0.8
    }
    ProgressCircle { // value
        anchors.fill: parent
        colorCircle: indicatorAirQuality.color
        arcEnd: UtilsNumber.mapNumber(indicatorAirQuality.aqi, 0, 500, 0, 270)
    }

    ImageSvg {
        id: lungsIcon
        width: 110
        height: 110
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -12

        color: indicatorAirQuality.color
        opacity: 0.6
        source: "qrc:/assets/icons_fontawesome/lungs-solid.svg"

        property real minOpacity: 0.4
        property real maxOpacity: 0.8
        property int minDuration: 500
        property int maxDuration: 2500
        property int duration: 2000

        SequentialAnimation on opacity {
            id: lungsAnimation
            loops: Animation.Infinite
            running: true
            onStopped: lungsIcon.opacity = lungsIcon.maxOpacity
            OpacityAnimator { from: lungsIcon.minOpacity; to: lungsIcon.maxOpacity; duration: lungsIcon.duration }
            OpacityAnimator { from: lungsIcon.maxOpacity; to: lungsIcon.minOpacity; duration: lungsIcon.duration }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: indicatorAirQuality.aqi
            font.pixelSize: 24
            font.bold: true
            color: indicatorAirQuality.color
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("AQI")
            font.pixelSize: 24
            font.bold: false
            color: indicatorAirQuality.color
        }
    }
}
