import QtQuick 2.15
import QtQuick.Layouts 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Button {
    id: control

    implicitWidth: 64
    implicitHeight: 64

    width: Math.max(parent.height, content.width + 32)
    height: parent.height // height drive the size of this element

    focusPolicy: Qt.NoFocus

    // settings
    property url source
    property int sourceSize: 32
    property string highlightMode: "background" // available: background, indicator, content

    // colors
    property string colorContent: Theme.colorHeaderContent
    property string colorHighlight: Theme.colorHeaderHighlight

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: 64

        width: (control.highlightMode === "circle") ? height : parent.width
        height: parent.height
        radius: (control.highlightMode === "circle") ? width : 0

        visible: (control.highlightMode === "background" ||
                  control.highlightMode === "indicator" ||
                  control.highlightMode === "circle")
        color: control.colorHighlight
        opacity: {
            if (control.highlighted) return 1
            if (control.hovered) return 0.5
            return 0
        }
        Behavior on opacity { OpacityAnimator { duration: 233 } }

        Rectangle { // backgroundIndicator
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            width: 6
            visible: (control.highlighted && control.highlightMode === "indicator")
            color: Theme.colorPrimary
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8

        IconSvg {
            width: control.sourceSize
            height: control.sourceSize

            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize

            visible: source.toString().length

            source: control.source
            color: (!control.highlighted && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            opacity: control.enabled ? 1.0 : 0.33
        }

        Text {
            height: parent.height

            visible: text

            text: control.text
            textFormat: Text.PlainText
            color: (!control.highlighted && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            font.pixelSize: Theme.componentFontSize
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
