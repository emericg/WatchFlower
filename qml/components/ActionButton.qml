import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: actionButton
    height: isPhone ? 36 : 40
    anchors.left: parent.left
    anchors.leftMargin: Theme.componentBorderWidth
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentBorderWidth

    signal buttonClicked()

    property int index
    property string button_text
    property string button_source

    property alias contentWidth: tButton.contentWidth

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: viewButton
        anchors.fill: parent
        color: "transparent"

        Text {
            id: tButton
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            text: button_text
            font.bold: false
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
        }

        ImageSvg {
            id: iButton
            width: parent.height * 0.6
            height: parent.height * 0.6
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            source: button_source
            color: Theme.colorSubText
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: isDesktop && visible
            onEntered: viewButton.state = "hovered"
            onExited: viewButton.state = "normal"
            onCanceled: viewButton.state = "normal"

            onClicked: {
                buttonClicked()
                viewButton.state = "normal"
            }
        }

        states: [
            State {
                name: "normal";
                PropertyChanges { target: viewButton; color: "transparent"; }
                PropertyChanges { target: tButton; color: "#3d3d3d"; }
                PropertyChanges { target: iButton; color: "#3d3d3d"; }
            },
            State {
                name: "hovered";
                PropertyChanges { target: viewButton; color: Theme.colorForeground; }
                PropertyChanges { target: tButton; color: Theme.colorPrimary; }
                PropertyChanges { target: iButton; color: Theme.colorPrimary; }
            }
        ]
    }
}
