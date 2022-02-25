import QtQuick 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: indicatorAirQuality
    width: 128
    height: 128

    property real value: 0
    property int valueMin: 0
    property int valueMax: 500
    property int limitMin: 500
    property int limitMax: 1000

    property string legend: "AQI"
    property string color: Theme.colorIcon

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: legendSimple
        width: parent.width + (isMobile ? 28 : 40)
        height: parent.height + (isMobile ? 28 : 40)
        anchors.centerIn: parent

        visible: true

        ProgressCircle { // arcSafe
            anchors.fill: parent
            value: 100

            animationBegin: false
            animationEnd: false
            animationValue: false

            arcWidth: (isMobile ? 7 : 10)
            arcBegin: 0
            arcEnd: ((indicatorAirQuality.limitMin/indicatorAirQuality.valueMax) * 270) - 2
            arcOffset: 225
            arcColor: (Theme.currentTheme === ThemeEngine.THEME_PLANT ? Theme.colorLightGreen : Theme.colorGreen)
            arcOpacity: 1
        }
        ProgressCircle { // arcWarning
            anchors.fill: parent
            value: 100

            animationBegin: false
            animationEnd: false
            animationValue: false

            arcWidth: (isMobile ? 7 : 10)
            arcBegin: ((indicatorAirQuality.limitMin/indicatorAirQuality.valueMax) * 270) + 2
            arcEnd: ((indicatorAirQuality.limitMax/indicatorAirQuality.valueMax) * 270) - 2
            arcOffset: 225
            arcColor: Theme.colorOrange
            arcOpacity: 1
        }
        ProgressCircle { // arcDanger
            anchors.fill: parent
            value: 100

            animationBegin: false
            animationEnd: false
            animationValue: false

            arcWidth: (isMobile ? 7 : 10)
            arcBegin: ((indicatorAirQuality.limitMax/indicatorAirQuality.valueMax) * 270) + 2
            arcEnd: 270
            arcOffset: 225
            arcColor: Theme.colorRed
            arcOpacity: 1
        }
    }

    ////////////////

    ProgressCircle { // actual indicator
        anchors.fill: parent

        arcOffset: 225
        arcBegin: 0
        arcEnd: 270
        arcWidth: isMobile ? 12 : 18
        arcColor: indicatorAirQuality.color

        background: true
        backgroundOpacity: 0.5
        backgroundColor: indicatorAirQuality.color

        from: indicatorAirQuality.valueMin
        to: indicatorAirQuality.valueMax
        value: indicatorAirQuality.value
    }

    ////////////////

    IconSvg {
        id: lungsIcon
        width: parent.width * 0.58
        height: parent.height * 0.58
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -14

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

        Connections {
            target: indicatorAirQuality
            function onValueChanged() {
                lungsAnimation.restart()
            }
        }

        SequentialAnimation on opacity {
            id: lungsAnimation
            loops: Animation.Infinite
            running: visible
            //alwaysRunToEnd: true
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

            text: (indicatorAirQuality.value > -99) ? indicatorAirQuality.value : "?"
            color: indicatorAirQuality.color
            font.pixelSize: isMobile ? 20 : 24
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: indicatorAirQuality.legend
            color: indicatorAirQuality.color
            font.pixelSize: isMobile ? 20 : 24
            font.bold: false
        }
    }
}
