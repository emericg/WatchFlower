import QtQuick 2.9

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemDataBar
    height: 28
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0

    property string legend: "legend"
    property string unit: ""
    property int floatprecision: 0
    property string color: "blue"
    property int hhh: 16

    property real value: 0
    property int valueMin: 0
    property int valueMax: 100
    property int limitMin: -1
    property int limitMax: -1

    Text {
        id: item_legend
        width: isPhone ? 80 : 96
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: item_bg.verticalCenter

        text: legend
        font.bold: true
        font.pixelSize: 12
        font.capitalization: Font.AllUppercase
        color: Theme.colorSubText
        horizontalAlignment: Text.AlignRight
    }

    Rectangle {
        id: item_bg
        color: Theme.colorForeground
        height: hhh
        radius: hhh
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: item_legend.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 20

        Rectangle {
            id: item_data
            width: {
                var res = UtilsNumber.normalize(value, valueMin, valueMax) * item_bg.width
                if (res > item_bg.width) res = item_bg.width
                return res
            }
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            radius: hhh
            color: itemDataBar.color

            Behavior on width { NumberAnimation { duration: 333 } }
        }

        ////////

        Text {
            anchors.right: item_limit_low.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0

            text: qsTr("min")
            font.pixelSize: 12
            visible: (limitMin > 0 && limitMin > valueMin)
            color: (limitMin < value) ? "white" : "black"
            opacity: (limitMin < value) ? 0.75 : 0.25
        }
        Rectangle {
            id: item_limit_low
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            visible: (limitMin > 0 && limitMin > valueMin)
            x: UtilsNumber.normalize(limitMin, valueMin, valueMax) * item_bg.width
            color: (limitMin < value) ? "white" : "black"
            opacity: (limitMin < value) ? 0.75 : 0.25

            Behavior on x { NumberAnimation { duration: 333 } }
        }
        Rectangle {
            id: item_limit_high
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            visible: (limitMax > 0 && limitMax < valueMax)
            x: UtilsNumber.normalize(limitMax, valueMin, valueMax) * item_bg.width
            color: (limitMax < value) ? "white" : "black"
            opacity: (limitMax < value) ? 0.75 : 0.25

            Behavior on x { NumberAnimation { duration: 333 } }
        }
        Text {
            anchors.left: item_limit_high.right
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0

            text: qsTr("max")
            font.pixelSize: 12
            visible: (limitMax > 0 && limitMax < valueMax)
            color: (limitMax < value) ? "white" : "black"
            opacity: (limitMax < value) ? 0.75 : 0.25
        }

        ////////

        Rectangle {
            id: indicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0

            height: hhh
            width: ti.width + 12
            radius: hhh
            color: (item_data.width > indicator.width) ? itemDataBar.color : "transparent"

            x: {
                if (value === 0)
                    return 0
                else if (item_data.width > indicator.width)
                    return item_data.width - indicator.width
                else
                    return item_data.width
            }

            Text {
                id: ti
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                anchors.horizontalCenter: parent.horizontalCenter

                text: {
                    if (value < 0)
                        return " ? ";
                    else {
                        if (value % 1 === 0)
                            return value + unit
                        else
                            return value.toFixed(floatprecision) + unit
                    }
                }

                color: (item_data.width > indicator.width) ? "white" : Theme.colorText
                font.bold: true
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
