import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Qt5Compat.GraphicalEffects

import ThemeEngine

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    font.pixelSize: Theme.componentFontSize
    font.bold: fullColor ? true : false

    focusPolicy: Qt.NoFocus

    // colors
    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorComponentBackground
    property string borderColor: Theme.colorComponentBorder

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.4
        color: control.fullColor ? control.primaryColor : control.secondaryColor
        border.width: Theme.componentBorderWidth
        border.color: control.fullColor ? control.primaryColor : control.borderColor
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font: control.font
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.66
        color: control.fullColor ? control.fulltextColor : control.primaryColor
    }
}
