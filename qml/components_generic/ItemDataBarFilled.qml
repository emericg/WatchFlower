import QtQuick 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemDataBar
    height: 16
    implicitWidth: 128

    property string legend: ""
    property int legendWidth: 80
    property int legendContentWidth: item_legend.contentWidth

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
            width: legendWidth
            anchors.verticalCenter: parent.verticalCenter

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
            width: itemDataBar.width - (item_legend.visible ? (item_legend.width + parent.spacing) : 0)
            height: hhh
            anchors.verticalCenter: parent.verticalCenter

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

            Rectangle {
                id: item_limit_low
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMin > 0 && limitMin > valueMin && limitMin < valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)
                x: UtilsNumber.normalize(limitMin, valueMin, valueMax) * item_bg.width
                color: (limitMin <= value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin <= value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Text {
                anchors.right: item_limit_low.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                visible: (limitMin > 0 && limitMin > valueMin && limitMin < valueMax) &&
                         (width < item_limit_low.x) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                //: Short for minimum
                text: qsTr("min")

                font.pixelSize: 12
                color: (limitMin <= value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin <= value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Rectangle {
                anchors.horizontalCenter: item_limit_low.horizontalCenter
                anchors.verticalCenter: item_limit_low.bottom
                //width: 6; height: 6; radius: 1; rotation: 45; // little triangle
                width: 6; height: 3; // little bar
                z: 2

                visible: (limitMin > 0 && limitMin > valueMin && limitMin < valueMax) &&
                         (!(x-2 < indicator.x || x+2 > indicator.x+indicator.width) ||
                          !(x+width-2 < indicator.x || x+width+2 > indicator.x+indicator.width))

                color: (limitMin < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin < value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }

            ////////

            Rectangle {
                id: item_limit_high
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMax > 0 && limitMax > valueMin && limitMax < valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                x: UtilsNumber.normalize(limitMax, valueMin, valueMax) * item_bg.width
                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Text {
                anchors.left: item_limit_high.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                visible: (limitMax > 0 && limitMax > valueMin && limitMax < valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                //: Short for maximum
                text: qsTr("max")

                font.pixelSize: 12
                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Rectangle {
                anchors.horizontalCenter: item_limit_high.horizontalCenter
                anchors.verticalCenter: item_limit_high.bottom
                //width: 6; height: 6; radius: 1; rotation: 45; // little triangle
                width: 6; height: 3; // little bar
                z: 2

                visible: (limitMax > 0 && limitMax > valueMin && limitMax < valueMax) &&
                         (!(x-2 < indicator.x || x+2 > indicator.x+indicator.width) ||
                          !(x+width-2 < indicator.x || x+width+2 > indicator.x+indicator.width))

                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }

            ////////

            Rectangle {
                id: indicator
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                height: hhh
                width: textIndicator.width + 12
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
                    if (item_data.width > indicator.width)
                        return item_data.width - indicator.width
                    else
                        return item_data.width
                }

                Text {
                    id: textIndicator
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
                    id: warningIndicator
                    width: hhh - 2
                    height: hhh - 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 4
                    anchors.left: {
                        if (item_data.width > indicator.width)
                            return parent.right
                        else
                            return textIndicator.right
                    }

                    color: Theme.colorRed
                    opacity: (warning && value > -20 && value < limitMin) ? 1 : 0
                    Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
                    source: "qrc:/assets/icons_material/baseline-warning-24px.svg"

                    Rectangle {
                        width: hhh
                        height: hhh
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        z: -1
                        color: itemDataBar.colorBackground
                        visible: (parent.opacity === 1)
                    }
                }
            }
        }
    }
}
