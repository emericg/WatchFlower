import QtQuick 2.12

MouseArea {
    id: swipeArea

    preventStealing: false
    propagateComposedEvents: false

    property real prevX: 0
    property real prevY: 0
    property real velocityX: 0.0
    property real velocityY: 0.0
    property int startX: 0
    property int startY: 0
    property bool tracing: false

    signal swipeLeft()
    signal swipeRight()
    signal swipeUp()
    signal swipeDown()

    onPressed: {
        startX = mouse.x
        startY = mouse.y
        prevX = mouse.x
        prevY = mouse.y
        velocityX = 0
        velocityY = 0
        tracing = true
    }

    onPositionChanged: {
        if (!tracing) return
        var currVelX = (mouse.x - prevX)
        var currVelY = (mouse.y - prevY)

        velocityX = (velocityX + currVelX) / 2.0
        velocityY = (velocityY + currVelY) / 2.0

        prevX = mouse.x
        prevY = mouse.y

        if (velocityX > 15 && mouse.x > swipeArea.width * 0.25) {
            tracing = false
            swipeArea.swipeRight()
        } else if (velocityX < -15 && mouse.x < swipeArea.width * 0.75) {
            tracing = false
            swipeArea.swipeLeft()
        } else if (velocityY > 15 && mouse.y > swipeArea.height * 0.25) {
            tracing = false
            swipeArea.swipeDown()
        } else if (velocityY < -15 && mouse.y < swipeArea.height * 0.75) {
            tracing = false
            swipeArea.swipeUp()
        }
    }
}
