import QtQuick 2.9

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemDataBar
    height: 24
    implicitWidth: 128

    property string legend: "legend"
    property string prefix: ""
    property string suffix: ""
    property int floatprecision: 0
    property bool warning: false

    property string colorText: Theme.colorText
    property string colorForeground: Theme.colorBlue
    property string colorBackground: Theme.colorForeground

    property real value: 0
    property int valueMin: 0
    property int valueMax: 100
    property int limitMin: -1
    property int limitMax: -1

    ////////////////////////////////////////////////////////////////////////////

    Row {
        anchors.fill: parent
        spacing: 12

        Text {
            id: item_legend
            width: isPhone ? 80 : 96
            anchors.verticalCenter: item_bg.verticalCenter

            visible: (legend.length)
            text: legend
            font.bold: true
            font.pixelSize: 12
            font.capitalization: Font.AllUppercase
            color: Theme.colorSubText
            horizontalAlignment: Text.AlignRight
        }

        ////////

        Rectangle {
            id: item_bg
            height: 8
            width: itemDataBar.width - (item_legend.visible ? (item_legend.width + parent.spacing) : 0)
            anchors.bottom: parent.bottom

            radius: 4
            color: itemDataBar.colorBackground

            Rectangle {
                id: item_data
                width: {
                    var res = UtilsNumber.normalize(value, valueMin, valueMax) * item_bg.width

                    if (value <= valueMin || value >= valueMax)
                        res += 0
                    else
                        res += 1.5*radius // +radius, so the indicator arrow point to the real value, not the rounded end of the data bar

                    if (res > item_bg.width)
                        res = item_bg.width

                     return res
                }
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                radius: 3
                color: itemDataBar.colorForeground

                Behavior on width { NumberAnimation { duration: 333 } }
            }

            Rectangle {
                id: item_limit_low
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMin > 0 && limitMin > valueMin)
                x: UtilsNumber.normalize(limitMin, valueMin, valueMax) * item_bg.width
                color: (limitMin < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin < value) ? 0.66 : 0.33

                Behavior on x { NumberAnimation { duration: 333 } }
            }
            Rectangle {
                id: item_limit_high
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMax > 0 && limitMax < valueMax)
                x: UtilsNumber.normalize(limitMax, valueMin, valueMax) * item_bg.width
                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.66 : 0.33

                Behavior on x { NumberAnimation { duration: 333 } }
            }

            Text {
                id: condu_indicator
                height: 15
                y: -22
                x: {
                    if (item_data.width < ((width / 2) + 8)) { // left
                        if (item_data.width > 12)
                            item_indicator_triangle.anchors.horizontalCenterOffset = (item_data.width - ((width / 2) + 8))
                        else
                            item_indicator_triangle.anchors.horizontalCenterOffset = -((width / 2) - 4)

                        return 4
                    } else if ((item_bg.width - item_data.width) < (width / 2)) { // right
                        item_indicator_triangle.anchors.horizontalCenterOffset = -((item_bg.width - item_data.width) - (width / 2)) - 4

                        return item_bg.width - width - 4
                    } else { // whatever
                        item_indicator_triangle.anchors.horizontalCenterOffset = 0

                        return item_data.width - (width / 2) - 4
                    }
                }

                color: "white"
                text: {
                    if (value < -20)
                        return " ? ";
                    else {
                        if (value % 1 === 0)
                            return prefix + value + suffix
                        else
                            return prefix + value.toFixed(floatprecision) + suffix
                    }
                }

                font.bold: true
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter

                Rectangle {
                    height: 18
                    anchors.left: parent.left
                    anchors.leftMargin: -4
                    anchors.right: parent.right
                    anchors.rightMargin: -4
                    anchors.verticalCenter: parent.verticalCenter

                    z: -1
                    radius: 1
                    color: itemDataBar.colorForeground

                    Rectangle {
                        id: item_indicator_triangle
                        width: 6
                        height: 6
                        anchors.top: parent.bottom
                        anchors.topMargin: -3
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 0

                        radius: 1
                        rotation: 45
                        color: itemDataBar.colorForeground
                    }
                }
            }
        }
    }
}
