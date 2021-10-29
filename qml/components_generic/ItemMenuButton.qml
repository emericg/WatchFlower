import QtQuick 2.12

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 64
    implicitHeight: 64

    width: 16 + imgSize * 1.5 + contentText.contentWidth + 16
    //height: parent.height

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
    property string highlightMode: "background" // available: background & text

    // colors
    property string colorContent: Theme.colorHeaderContent
    property string colorHighlight: Theme.colorBackground
    property string colorBackground: Theme.colorForeground

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()

        onEntered: hovered = true
        onExited: hovered = false
        onCanceled: hovered = false
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
        color: colorHighlight
        opacity: hovered ? 0.5 : 0
        Behavior on opacity { OpacityAnimator { duration: 333 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    ImageSvg {
        id: contentImage
        width: imgSize
        height: imgSize
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: control.verticalCenter

        source: control.source
        color: (!selected && highlightMode === "text") ? control.colorBackground : control.colorContent
        opacity: control.enabled ? 1.0 : 0.33
    }

    Text {
        id: contentText
        height: parent.height
        anchors.left: contentImage.right
        anchors.leftMargin: (imgSize / 3)
        anchors.verticalCenter: control.verticalCenter

        text: menuText
        font.pixelSize: Theme.fontSizeComponent
        font.bold: true
        color: (!selected && highlightMode === "text") ? control.colorBackground : control.colorContent
        verticalAlignment: Text.AlignVCenter
    }
}
