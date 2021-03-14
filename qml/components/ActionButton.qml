import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: actionButton
    height: isPhone ? 36 : 40
    width: parent.width

    property string button_text
    property string button_source
    property int index

    property alias contentWidth: tButton.contentWidth

    property bool clicked
    signal buttonClicked

    function viewButtonHovered() {
        viewButton.state = "hovered"
    }

    function viewButtonExited() {
        if (clicked == false) {
            viewButton.state = ""
        } else {
            viewButton.state = "clicked"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: viewButton
        height: parent.height
        width: parent.width
        color: "transparent"

        Text {
            id: tButton
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: isPhone ? 12 : 16
            anchors.verticalCenter: parent.verticalCenter

            text: button_text
            font.bold: false
            font.pixelSize: Theme.fontSizeContentBig
            color: Theme.colorText
        }

        ImageSvg {
            id: iButton
            width: parent.height * 0.6
            height: parent.height * 0.6
            anchors.right: parent.right
            anchors.rightMargin: isPhone ? 12 : 16
            anchors.verticalCenter: parent.verticalCenter

            source: button_source
            color: Theme.colorSubText
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: isDesktop
            onEntered: viewButtonHovered()
            onExited: viewButtonExited()
            
            onClicked: buttonClicked()
        }

        states: [
            State {
                name: "clicked";
                PropertyChanges { target: viewButton; color: "transparent"; }
                PropertyChanges { target: tButton; color: "#286E1E"; }
                PropertyChanges { target: iButton; color: "#286E1E"; }
            },
            State {
                name: "hovered";
                PropertyChanges { target: viewButton; color: Theme.colorForeground; }
                PropertyChanges { target: tButton; color: Theme.colorPrimary; }
                PropertyChanges { target: iButton; color: Theme.colorPrimary; }
            },
            State {
                name: "normal";
                PropertyChanges { target: viewButton; color: "transparent"; }
                PropertyChanges { target: tButton; color: "#3d3d3d"; }
                PropertyChanges { target: iButton; color: "#3d3d3d"; }
            }
        ]
    }
}
