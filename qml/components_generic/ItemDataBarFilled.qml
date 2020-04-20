import QtQuick 2.9

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemDataBar
    height: 16
    implicitWidth: 128

    property string legend: ""
    property string prefix: ""
    property string suffix: ""
    property int floatprecision: 0
    property bool warning: false

    property string colorText: Theme.colorText
    property string colorForeground: Theme.colorBlue
    property string colorBackground: Theme.colorForeground

    property int hhh: 16
    property bool animated: true

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
            anchors.verticalCenter: parent.verticalCenter
            width: isPhone ? 80 : 96

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
            anchors.verticalCenter: parent.verticalCenter
            width: itemDataBar.width - (item_legend.visible ? (item_legend.width + parent.spacing) : 0)
            height: hhh

            clip: true
            radius: hhh
            color: itemDataBar.colorBackground

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
                color: itemDataBar.colorForeground

                Behavior on width { NumberAnimation { duration: animated ? 333 : 0 } }
            }

            ////////

            Text {
                anchors.right: item_limit_low.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                //: Short for minimum
                text: qsTr("min")
                font.pixelSize: 12
                visible: (limitMin > 0 && limitMin > valueMin) && (x + width + 4 <= item_data.width)
                color: (limitMin <= value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin <= value) ? 0.75 : 0.25
            }
            Rectangle {
                id: item_limit_low
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMin > 0 && limitMin > valueMin)
                x: UtilsNumber.normalize(limitMin, valueMin, valueMax) * item_bg.width
                color: (limitMin <= value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin <= value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
            }
            Rectangle {
                id: item_limit_high
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMax > 0 && limitMax < valueMax)
                x: UtilsNumber.normalize(limitMax, valueMin, valueMax) * item_bg.width
                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
            }
            Text {
                anchors.left: item_limit_high.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                //: Short for maximum
                text: qsTr("max")
                font.pixelSize: 12
                visible: (limitMax > 0 && limitMax < valueMax)
                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25
            }

            ////////

            Rectangle {
                id: indicator
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                height: hhh
                width: ti.width + 12
                radius: (value <= 0 || item_data.width > indicator.width) ? hhh : 0
                color: {
                    if (value <= 0)
                        return "transparent"
                     else if (item_data.width > indicator.width)
                        return itemDataBar.colorForeground
                    else
                        return itemDataBar.colorBackground
                }

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
                        if (value < -20)
                            return " ? ";
                        else {
                            if (value % 1 === 0)
                                return prefix + value + suffix
                            else
                                return prefix + value.toFixed(floatprecision) + suffix
                        }
                    }

                    color: (item_data.width > indicator.width) ? "white" : Theme.colorText
                    font.bold: true
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                ImageSvg {
                    id: wi
                    width: hhh - 2
                    height: hhh - 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 4
                    anchors.left: {
                        if (item_data.width > indicator.width)
                            return parent.right
                        else
                            return ti.right
                    }

                    visible: (warning && value > -20 && value < limitMin)
                    color: Theme.colorRed
                    source: "qrc:/assets/icons_material/baseline-warning-24px.svg"

                    Rectangle {
                        width: hhh
                        height: hhh
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        z: -1
                        color: itemDataBar.colorBackground
                    }
                }
            }
        }
    }
}
