import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.impl

import ThemeEngine

T.Control {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight /*+ topInset + bottomInset*/,
                             implicitContentHeight /*+ topPadding + bottomPadding*/,
                             topPadding + bottomPadding)

    padding: Theme.componentMargin
    spacing: Theme.componentMargin
    verticalPadding: 0

    property string iconSource
    property string iconColor: Theme.colorIcon
    property int iconSize: 32

    property string text
    property string textColor: Theme.colorText
    property int textSize: Theme.fontSizeContent

    ////////////////

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: screenPaddingRight + Theme.componentMargin / 2

        Item {
            Layout.preferredWidth: 56 - screenPaddingLeft - Theme.componentMargin
            Layout.preferredHeight: Theme.componentHeightXL
            Layout.alignment: Qt.AlignTop

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: (32 - control.iconSize) / 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: (control.height !== Theme.componentHeightXL) ? -(Theme.componentMargin / 2) : 0

                width: control.iconSize
                height: control.iconSize
                color: control.iconColor
                source: control.iconSource
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: control.text
            color: control.textColor
            wrapMode: Text.WordWrap
            font.pixelSize: control.textSize
        }
    }

    ////////////////

    background: Rectangle {
        implicitHeight: Theme.componentHeightXL

        color: Theme.colorBackground
    }

    ////////////////
}
