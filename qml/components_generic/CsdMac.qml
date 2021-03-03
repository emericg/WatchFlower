import QtQuick 2.12

import ThemeEngine 1.0

Item {
    id: csdMac
    implicitWidth: 48
    implicitHeight: 24

    visible: (settingsManager.appThemeCSD && Qt.platform.os === "osx")

    MouseArea {
        id: buttonsArea
        anchors.fill: buttonsRow
        hoverEnabled: true
        property bool hovered: false
        onEntered: hovered = true
        onExited: hovered = false
    }
    Row {
        id: buttonsRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
            width: 12; height: 12; radius: 12;
            color: "#FE5F57"
            border.color: "#E24037"

            ImageSvg {
                width: 10; height: 10;
                anchors.centerIn: parent
                source: "qrc:/assets/icons_material/baseline-close-24px.svg"
                opacity: buttonsArea.hovered ? 0.6 : 0
                //Behavior on opacity { OpacityAnimator { duration: 100 } }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: appWindow.close()
            }
        }
        Rectangle {
            width: 12; height: 12; radius: 12;
            color: "#FEBC2F"
            border.color: "#E19D17"
            Rectangle {
                width: 8; height: 1;
                anchors.centerIn: parent
                color: "grey"
                opacity: buttonsArea.hovered ? 0.8 : 0
                //Behavior on opacity { OpacityAnimator { duration: 100 } }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: appWindow.showMinimized()
            }
        }
        Rectangle {
            width: 12; height: 12; radius: 12;
            color: "#28C940"
            border.color: "#10A923"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (appWindow.visibility === ApplicationWindow.Maximized)
                        appWindow.showNormal()
                    else
                        appWindow.showMaximized()
                }
            }
        }
    }
}
