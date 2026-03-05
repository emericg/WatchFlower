import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: implicitBackgroundWidth
    implicitHeight: implicitBackgroundHeight

    flat: true
    checkable: false
    hoverEnabled: isDesktop
    focusPolicy: Qt.NoFocus

    property bool hugeMode: false

    // icon
    property url source
    property int sourceSize: hugeMode ? 28 : 24

    // colors
    property color color: Theme.colorPrimary
    property color colorBackground: Qt.rgba(color.r, color.g, color.b, 0.2)
    //property color colorRipple: Qt.rgba(color.r, color.g, color.b, 0.2)

    // tooltip
    property string tooltipText

    ////////////////

    background: Item {
        implicitWidth: control.hugeMode ? 36 : 32
        implicitHeight: control.hugeMode ? 36 : 32

        Rectangle {
            anchors.fill: parent
            radius: width
            color: control.color

            opacity: 0.08
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PropertyAnimation { to: 0.24; duration: 1333; }
                PropertyAnimation { to: 0.08; duration: 1333; }
            }
        }
/*
        RippleThemed {
            anchors.fill: parent
            anchor: control

            pressed: control.pressed
            active: control.enabled && (control.down || control.hovered || control.visualFocus)
            color: control.colorRipple

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.width
                    }
                }
            }
        }
*/
    }

    ////////////////

    contentItem: Item {
        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            opacity: control.enabled ? 1 : 0.66
            color: control.color
            source: control.source
        }

        ToolTipFlat {
            visible: (control.hovered || control.down)
            text: control.tooltipText
            textColor: control.color
            tooltipPosition: "left"
            backgroundColor: control.colorBackground
        }
    }

    ////////////////
}

////////////////////////////////////////////////////////////////////////////////
/*
IconSvg {
    id: control

    width: hugeMode ? 28 : 24
    height: hugeMode ? 28 : 24
    //anchors.verticalCenter: parent.verticalCenter

    property bool hugeMode: false

    Rectangle {
        anchors.fill: parent
        anchors.margins: -8
        height: width
        radius: width

        z: -1
        color: parent.color
        opacity: 0.08

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            PropertyAnimation { to: 0.24; duration: 1333; }
            PropertyAnimation { to: 0.08; duration: 1333; }
        }
    }
}
*/
////////////////////////////////////////////////////////////////////////////////
