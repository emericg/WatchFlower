import QtQuick 2.12

import ThemeEngine 1.0

// Based on the ProgressCircle component from ByteBau (Jörn Buchholz) @bytebau.com

Item {
    id: control
    width: 256
    height: width

    property bool isPie: false          // paint a pie instead of an arc

    property real arcBegin: 0           // start arc angle in degree
    property real arcEnd: 270           // end arc angle in degree
    property real arcOffset: -90 -135   // rotation

    property bool background: false     // a full circle as a background of the arc
    property real lineWidth: 18         // width of the line
    property string colorCircle: "#CC3333"
    property string colorBackground: "#779933"

    property alias beginAnimation: animationArcBegin.enabled
    property alias endAnimation: animationArcEnd.enabled
    property int animationDuration: 233

    onIsPieChanged: canvas.requestPaint()
    onArcBeginChanged: canvas.requestPaint()
    onArcEndChanged: canvas.requestPaint()

    Connections {
        target: ThemeEngine
        onCurrentThemeChanged: canvas.requestPaint()
    }

    Behavior on arcBegin {
       id: animationArcBegin
       enabled: true
       NumberAnimation {
           duration: control.animationDuration
           easing.type: Easing.InOutCubic
       }
    }

    Behavior on arcEnd {
       id: animationArcEnd
       enabled: true
       NumberAnimation {
           duration: control.animationDuration
           easing.type: Easing.InOutCubic
       }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: parent.arcOffset

        onPaint: {
            var ctx = getContext("2d")
            var x = width / 2
            var y = height / 2
            var start = Math.PI * (parent.arcBegin / 180)
            var end = Math.PI * (parent.arcEnd / 180)
            ctx.reset()

            if (control.isPie) {
                if (control.background) {
                    ctx.beginPath()
                    ctx.fillStyle = control.colorBackground
                    ctx.moveTo(x, y)
                    ctx.arc(x, y, (width / 2), 0, (Math.PI * 2), false)
                    ctx.lineTo(x, y)
                    ctx.fill()
                }
                ctx.beginPath()
                ctx.fillStyle = control.colorCircle
                ctx.moveTo(x, y)
                ctx.arc(x, y, (width / 2), start, end, false)
                ctx.lineTo(x, y)
                ctx.fill()
            } else {
                if (control.background) {
                    ctx.beginPath();
                    ctx.arc(x, y, (width / 2) - (parent.lineWidth / 2), 0, (Math.PI * 2), false)
                    ctx.lineWidth = control.lineWidth
                    ctx.strokeStyle = control.colorBackground
                    ctx.stroke()
                }
                ctx.beginPath();
                ctx.arc(x, y, (width / 2) - (parent.lineWidth / 2), start, end, false)
                ctx.lineWidth = control.lineWidth
                ctx.strokeStyle = control.colorCircle
                ctx.stroke()
            }
        }
    }
}
