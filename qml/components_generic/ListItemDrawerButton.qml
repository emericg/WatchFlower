import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import ThemeEngine

T.ItemDelegate {
    id: control

    implicitWidth: parent.width
    implicitHeight: Theme.componentHeightL

    padding: Theme.componentMargin
    spacing: Theme.componentMargin
    verticalPadding: 0

    property string iconSource
    property string iconColor: Theme.colorIcon
    property int iconSize: 24

    property bool iconAnimated: false
    property string iconAnimation // fade or rotate

    property string textColor: Theme.colorText
    property int textSize: 13

    ////////////////

    background: Item {
        implicitHeight: Theme.componentHeightL

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            radius: Theme.componentRadius
            color: control.down ? Theme.colorForeground : "transparent"
            opacity: control.down
            Behavior on opacity { OpacityAnimator { duration: 133 } }
        }
    }

    ////////////////

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: screenPaddingRight + Theme.componentMargin / 2

        Item {
            Layout.preferredWidth: Theme.componentHeightL - screenPaddingLeft - Theme.componentMargin
            Layout.preferredHeight: Theme.componentHeightL
            Layout.alignment: Qt.AlignTop

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: (32 - control.iconSize) / 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: (control.height !== Theme.componentHeightL) ? -(Theme.componentMargin / 2) : 0

                width: control.iconSize
                height: control.iconSize
                color: control.iconColor
                source: control.iconSource

                SequentialAnimation on opacity { // fade animation
                    loops: Animation.Infinite
                    running: (control.iconAnimated && control.iconAnimation === "fade")
                    alwaysRunToEnd: true

                    PropertyAnimation { to: 0.33; duration: 750; }
                    PropertyAnimation { to: 1; duration: 750; }
                }
                NumberAnimation on rotation { // rotate animation
                    duration: 2000
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    running: (control.iconAnimated && control.iconAnimation === "rotate")
                    alwaysRunToEnd: true
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: control.text
            color: control.textColor
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: control.textSize
        }
    }

    ////////////////
}
