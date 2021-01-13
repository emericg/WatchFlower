import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: csdWindows
    implicitWidth: 144
    implicitHeight: 40

    visible: (settingsManager.clientSideDecoration && Qt.platform.os !== "osx")

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
        spacing: 16

        ItemImageButton {
            width: 32; height: 32;
            highlightMode: "color"

            source: "qrc:/assets/icons_material/baseline-minimize-24px.svg"
            onClicked: appWindow.showMinimized()
        }

        ItemImageButton {
            width: 32; height: 32;
            highlightMode: "color"

            source: "qrc:/assets/icons_material/baseline-maximize-24px.svg"
            onClicked: {
                if (appWindow.visibility === ApplicationWindow.Maximized)
                    appWindow.showNormal()
                else
                    appWindow.showMaximized()
            }
        }

        ItemImageButton {
            width: 32; height: 32;
            highlightMode: "color"

            source: "qrc:/assets/icons_material/baseline-close-24px.svg"
            onClicked: appWindow.close()
        }
    }
}
