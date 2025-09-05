import QtQuick

import ComponentLibrary

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
        id: legend
        anchors.fill: parent
        anchors.margins: 0

        ProgressCircle { // arcSafe
            anchors.fill: parent
            value: 100

            animationBegin: false
            animationEnd: false
            animationValue: false

            arcWidth: (isMobile ? 7 : 10)
            arcBegin: 0
            arcEnd: ((indicatorAirQuality.limitMin/indicatorAirQuality.valueMax) * 270) - 2.5
            arcOffset: 225

            arcColor: (Theme.currentTheme === Theme.THEME_PLANT ? Theme.colorLightGreen : Theme.colorGreen)
            arcOpacity: 1
            arcCap: "round"
        }
        ProgressCircle { // arcWarning
            anchors.fill: parent
            value: 100

            animationBegin: false
            animationEnd: false
            animationValue: false

            arcWidth: (isMobile ? 7 : 10)
            arcBegin: ((indicatorAirQuality.limitMin/indicatorAirQuality.valueMax) * 270) + 2.5
            arcEnd: ((indicatorAirQuality.limitMax/indicatorAirQuality.valueMax) * 270) - 2.5
            arcOffset: 225

            arcColor: Theme.colorOrange
            arcOpacity: 1
            arcCap: "round"
        }
        ProgressCircle { // arcDanger
            anchors.fill: parent
            value: 100

            animationBegin: false
            animationEnd: false
            animationValue: false

            arcWidth: (isMobile ? 7 : 10)
            arcBegin: ((indicatorAirQuality.limitMax/indicatorAirQuality.valueMax) * 270) + 2.5
            arcEnd: 270
            arcOffset: 225

            arcColor: Theme.colorRed
            arcOpacity: 1
            arcCap: "round"
        }
    }

    ////////////////

    ProgressCircle { // actual indicator
        id: indicator
        anchors.fill: parent
        anchors.margins: (isMobile ? 11 : 16)

        arcOffset: 225
        arcBegin: 0
        arcEnd: 270

        arcWidth: isMobile ? 12 : 18
        arcColor: indicatorAirQuality.color
        arcCap: "round"

        background: true
        backgroundOpacity: 0.5
        backgroundColor: indicatorAirQuality.color

        valueMin: indicatorAirQuality.valueMin
        valueMax: indicatorAirQuality.valueMax
        value: indicatorAirQuality.value
    }

    ////////////////

    IconSvg {
        id: lungsIcon
        width: indicator.width * 0.58
        height: indicator.height * 0.58
        anchors.horizontalCenter: indicator.horizontalCenter
        anchors.verticalCenter: indicator.verticalCenter
        anchors.verticalCenterOffset: -12

        color: indicatorAirQuality.color
        smooth: true
        opacity: 0.6
        source: "qrc:/assets/gfx/icons/lungs.svg"

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
        anchors.bottomMargin: 8
        spacing: -4

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

    ////////////////////////////////////////////////////////////////////////////
}
