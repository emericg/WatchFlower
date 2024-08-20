import QtQuick

import ThemeEngine

Rectangle {
    id: mobileExit

    anchors.left: parent.left
    anchors.leftMargin: Theme.componentMarginL
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentMarginL
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.componentMarginL + screenPaddingNavbar + screenPaddingBottom

    height: Theme.componentHeightL
    radius: Theme.componentRadius

    ////////////////

    property alias timerRunning: exitTimer.running

    function timerStart() {
        exitTimer.start()
    }

    Timer {
        id: exitTimer
        interval: 2222
        running: false
        repeat: false
    }

    ////////////////

    color: Theme.colorComponentBackground
    border.color: Theme.colorSeparator
    border.width: Theme.componentBorderWidth

    visible: opacity

    opacity: exitTimer.running ? 1 : 0
    Behavior on opacity { OpacityAnimator { duration: 233 } }

    Text {
        anchors.centerIn: parent

        text: qsTr("Press one more time to exit...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorText
    }

    ////////////////
}
