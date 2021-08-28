import QtQuick 2.12

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 80
    implicitHeight: 48

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // states
    property bool hovered: false
    property bool selected: false

    // settings
    property int imgSize: 32
    property url source: ""
    property string menuText: ""
    property string highlightMode: "background" // available: background, text

    // colors
    property string colorContent: Theme.colorHeaderContent
    property string colorBackground: Theme.colorForeground

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        hoverEnabled: true

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()

        onEntered: {
            hovered = true
            bgFocus.opacity = 0.5
        }
        onExited: {
            hovered = false
            bgFocus.opacity = 0
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent

        visible: (selected && highlightMode === "background")
        color: control.colorBackground
    }
    Rectangle {
        id: bgFocus
        anchors.fill: parent

        visible: (highlightMode === "background")
        color: control.colorBackground
        opacity: 0
        Behavior on opacity { OpacityAnimator { duration: 250 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    ImageSvg {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.horizontalCenter: control.horizontalCenter
        anchors.verticalCenter: control.verticalCenter
        anchors.verticalCenterOffset: -8

        source: control.source
        color: (!selected && highlightMode === "text") ? control.colorBackground : control.colorContent
        opacity: control.enabled ? 1.0 : 0.3
    }

    Text {
        id: contentText
        height: control.height
        anchors.top: contentImage.bottom
        anchors.topMargin: -4
        anchors.verticalCenter: control.verticalCenter

        text: menuText
        font.pixelSize: 14
        font.bold: true
        color: (!selected && highlightMode === "text") ? control.colorBackground : control.colorContent
        verticalAlignment: Text.AlignVCenter
    }
}
