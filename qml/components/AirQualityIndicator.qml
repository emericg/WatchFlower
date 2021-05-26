import QtQuick 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: indicatorAirQuality
    width: 128
    height: 128

    property real value: 250
    property real valueMin: 0
    property real valueMax: 500
    property string legend: "AQI"
    property string color: Theme.colorIcon

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: legendSimple
        width: parent.width + (isMobile ? 30 : 40)
        height: parent.height + (isMobile ? 30 : 40)
        anchors.centerIn: parent

        visible: true

        ProgressCircle {
            anchors.fill: parent
            value: 100
            arcWidth: (isMobile ? 8 : 10)
            arcBegin: 0
            arcEnd: 88
            arcOffset: 225
            arcColor: (Theme.currentTheme === ThemeEngine.THEME_GREEN ? Theme.colorLightGreen : Theme.colorGreen)
            //arcOpacity: 0.95
        }
        ProgressCircle {
            anchors.fill: parent
            value: 100
            arcWidth: (isMobile ? 8 : 10)
            arcBegin: 92
            arcEnd: 178
            arcOffset: 225
            arcColor: Theme.colorOrange
            //arcOpacity: 0.95
        }
        ProgressCircle {
            anchors.fill: parent
            value: 100
            arcWidth: (isMobile ? 8 : 10)
            arcBegin: 182
            arcEnd: 270
            arcOffset: 225
            arcColor: Theme.colorRed
            //arcOpacity: 0.95
        }
    }

    ////////////////

    ProgressCircle {
        anchors.fill: parent

        arcOffset: 225
        arcBegin: 0
        arcEnd: 270
        arcWidth: isMobile ? 14 : 18
        arcColor: indicatorAirQuality.color

        background: true
        backgroundOpacity: 0.75
        backgroundColor: indicatorAirQuality.color

        from:indicatorAirQuality.valueMin
        to: indicatorAirQuality.valueMax
        value: indicatorAirQuality.value
    }

    ////////////////

    ImageSvg {
        id: lungsIcon
        width: parent.width * 0.58
        height: parent.height * 0.58
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
            running: visible
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
            color: indicatorAirQuality.color
            font.pixelSize: isMobile ? 22 : 24
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: indicatorAirQuality.legend
            color: indicatorAirQuality.color
            font.pixelSize: isMobile ? 22 : 24
            font.bold: false
        }
    }
}
