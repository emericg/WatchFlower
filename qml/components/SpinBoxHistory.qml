import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Qt5Compat.GraphicalEffects

import ThemeEngine
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.SpinBox {
    id: control
    implicitWidth: 240
    implicitHeight: Theme.componentHeight

    //width: contentText.width + 32 + control.height*2 + 6*2

    from: -2
    to: 0
    value: 0
    editable: false

    font.pixelSize: Theme.componentFontSize
    opacity: enabled ? 1 : 0.4

    property var hhh // history mode

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 240
        implicitHeight: Theme.componentHeight

        radius: control.height
        color: Theme.colorBackground
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorComponentBorder
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Text {
            anchors.centerIn: parent

            text: {
                if (control.value === 0) {
                    if (control.hhh === ChartHistory.Span.Monthly) return qsTr("last 30 days")
                    else if (control.hhh === ChartHistory.Span.Weekly) return qsTr("last 7 days")
                    else if (control.hhh === ChartHistory.Span.Daily) return qsTr("last 24 hours")
                } else if (control.value === -1) {
                    if (control.hhh === ChartHistory.Span.Monthly) return qsTr("last month")
                    else if (control.hhh === ChartHistory.Span.Weekly) return qsTr("last week")
                    else if (control.hhh === ChartHistory.Span.Daily) return qsTr("yesterday")
                } else {
                    var nb = ""
                    if (control.value === -2) nb = qsTr("two")
                    else if (control.value === -3) nb = qsTr("three")
                    else if (control.value === -4) nb = qsTr("four")
                    else if (control.value === -5) nb = qsTr("five")
                    else if (control.value === -6) nb = qsTr("six")

                    var dr = ""
                    if (control.hhh === ChartHistory.Span.Monthly) dr = qsTr("months")
                    else if (control.hhh === ChartHistory.Span.Weekly) dr = qsTr("weeks")
                    else if (control.hhh === ChartHistory.Span.Daily) dr = qsTr("days")

                    //: Used like this: "two months ago", or "one week ago"
                    return qsTr("%0 %1 ago").arg(nb).arg(dr)
                }
            }

            color: Theme.colorSubText
            font: control.font
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            //Rectangle {
            //    anchors.centerIn: parent
            //    width: contentText.contentWidth + 32
            //    height: control.height
            //    radius: control.height
            //    z: -1

            //    color: Theme.colorBackground
            //    border.width: Theme.componentBorderWidth
            //    border.color: Theme.colorComponentBorder
            //}
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    up.indicator: Rectangle {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        x: control.mirrored ? 0 : control.width - width
        anchors.verticalCenter: control.verticalCenter

        width: control.height + 12
        height: control.height
        radius: control.height

        color: enabled ? Theme.colorPrimary : Theme.colorComponentBorder
        border.width: Theme.componentBorderWidth
        border.color: enabled ? Theme.colorPrimary : Theme.colorComponentBorder

        IconSvg {
            width: 24
            height: 24
            anchors.centerIn: parent
            color: "white"
            source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    down.indicator: Rectangle {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        x: control.mirrored ? control.width - width : 0
        anchors.verticalCenter: control.verticalCenter

        width: control.height + 12
        height: control.height
        radius: control.height

        color: enabled ? Theme.colorPrimary : Theme.colorComponentBorder
        border.width: Theme.componentBorderWidth
        border.color: enabled ? Theme.colorPrimary : Theme.colorComponentBorder

        IconSvg {
            width: 24
            height: 24
            anchors.centerIn: parent
            color: "white"
            source: "qrc:/assets/icons_material/baseline-chevron_left-24px.svg"
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
