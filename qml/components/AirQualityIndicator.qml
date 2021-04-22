import QtQuick 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: indicatorAirQuality
    width: 128
    height: 128

    property real value: 25
    property real valueMin: 0
    property real valueMax: 500
    property string legend: "AQI"
    property string color: Theme.colorIcon

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: legendSimple
        width: parent.width + 40
        height: parent.height + 40
        anchors.centerIn: parent

        visible: true

        ProgressCircle {
            anchors.fill: parent

            lineWidth: 10
            arcBegin: 0
            arcEnd: 86
            colorCircle: Theme.colorGreen
            opacity: 0.8
        }
        ProgressCircle {
            anchors.fill: parent

            lineWidth: 10
            arcBegin: 94
            arcEnd: 176
            colorCircle: Theme.colorOrange
            opacity: 0.9
        }
        ProgressCircle {
            anchors.fill: parent

            lineWidth: 10
            arcBegin: 184
            arcEnd: 270
            colorCircle: Theme.colorRed
            opacity: 0.75
        }
    }

    ////////////////

    ProgressCircle { // background
        anchors.fill: parent
        lineWidth: isMobile ? 16 : 20
        colorCircle: indicatorAirQuality.color
        opacity: 0.75
    }
    ProgressCircle { // value
        anchors.fill: parent
        lineWidth: isMobile ? 16 : 20
        colorCircle: indicatorAirQuality.color
        arcEnd: UtilsNumber.mapNumber(indicatorAirQuality.value,
                                      indicatorAirQuality.valueMin, indicatorAirQuality.valueMax,
                                      0, 270)
    }

    ////////////////

    ImageSvg {
        id: lungsIcon
        width: parent.width * 0.6
        height: parent.height * 0.6
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -12

        color: indicatorAirQuality.color
        opacity: 0.6
        source: "qrc:/assets/icons_fontawesome/lungs-solid.svg"

        property real minOpacity: 0.4
        property real maxOpacity: 0.85
        property int minDuration: 250
        property int maxDuration: 2000
        property int duration: UtilsNumber.mapNumber(indicatorAirQuality.value,
                                                     indicatorAirQuality.valueMin, indicatorAirQuality.valueMax,
                                                     maxDuration, minDuration)

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

            text: indicatorAirQuality.value
            font.pixelSize: 24
            font.bold: true
            color: indicatorAirQuality.color
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: indicatorAirQuality.legend
            font.pixelSize: 24
            font.bold: false
            color: indicatorAirQuality.color
        }
    }
}
