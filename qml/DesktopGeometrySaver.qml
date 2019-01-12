import QtQuick 2.7
import QtQuick.Window 2.7
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0

Item {
    property Window window
    property string windowName: ""

    Settings {
        id: s
        category: windowName

        property int x
        property int y
        property int width
        property int height
        property int visibility
    }

    Component.onCompleted: {
        if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") {
            if (s.width && s.height) {
                window.x = s.x;
                window.y = s.y;
                window.width = s.width;
                window.height = s.height;
                window.visibility = s.visibility;
            }
        }
    }

    Connections {
        target: window
        onXChanged: saveSettingsTimer.restart()
        onYChanged: saveSettingsTimer.restart()
        onWidthChanged: saveSettingsTimer.restart()
        onHeightChanged: saveSettingsTimer.restart()
        onVisibilityChanged: saveSettingsTimer.restart()
    }

    Timer {
        id: saveSettingsTimer
        interval: 1000
        repeat: false
        onTriggered: saveSettings()
    }

    function saveSettings() {
        if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") {
            switch(window.visibility) {
            case ApplicationWindow.Windowed:
                s.x = window.x;
                s.y = window.y;
                s.width = window.width;
                s.height = window.height;
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.FullScreen:
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.Maximized:
                s.visibility = window.visibility;
                break;
            }
        }
    }
}
