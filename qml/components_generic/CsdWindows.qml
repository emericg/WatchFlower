import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeEngine 1.0

Loader {
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0

    width: 138
    height: 28

    //enabled: (settingsManager.appThemeCSD && Qt.platform.os === "windows")
    //visible: (settingsManager.appThemeCSD && Qt.platform.os === "windows")

    asynchronous: true
    sourceComponent: (settingsManager.appThemeCSD && Qt.platform.os === "windows")
                         ? componentCsdWindows : null

    Component {
        id: componentCsdWindows

        Row {
            id: csdWindows
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            spacing: 0

            ////////

            Rectangle { // button minimize
                width: 46; height: 28;
                color: hovered ? "#33aaaaaa" : "transparent"

                property bool hovered: false

                Rectangle {
                    width: 10; height: 1;
                    anchors.centerIn: parent
                    color: "transparent"
                    border.width: 1
                    border.color: parent.hovered ? Theme.colorHighContrast : Theme.colorIcon
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onCanceled: parent.hovered = false
                    onClicked: appWindow.showMinimized()
                }
            }

            ////////

            Rectangle { // button maximize
                width: 46; height: 28;
                color: hovered ? "#33aaaaaa" : "transparent"

                property bool hovered: false

                Rectangle {
                    width: 10; height: 10;
                    anchors.centerIn: parent
                    color: "transparent"
                    border.width: 1
                    border.color: parent.hovered ? Theme.colorHighContrast : Theme.colorIcon
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onCanceled: parent.hovered = false
                    onClicked: {
                        if (appWindow.visibility === ApplicationWindow.Maximized)
                            appWindow.showNormal()
                        else
                            appWindow.showMaximized()
                    }
                }
            }

            ////////

            Rectangle { // button close
                width: 46; height: 28;
                color: hovered ? "red" : "transparent"

                property bool hovered: false

                IconSvg {
                    width: 16; height: 16;
                    anchors.centerIn: parent

                    source: "qrc:/assets/icons_material/baseline-close-24px.svg"
                    color: parent.hovered ? "white" : Theme.colorIcon
                }
        /*
                Rectangle {
                    width: 12; height: 1;
                    anchors.centerIn: parent
                    rotation: 45
                    color: parent.hovered ? "white" : Theme.colorIcon
                }
                Rectangle {
                    width: 12; height: 1;
                    anchors.centerIn: parent
                    rotation: -45
                    color: parent.hovered ? "white" : Theme.colorIcon
                }
        */
                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onCanceled: parent.hovered = false
                    onClicked: appWindow.close()
                }
            }
        }
    }
}
